# DiXY RDWC System-Architektur

## Systemübersicht

Das DiXY-System ist eine vollautomatische hydroponische RDWC-Anlage (Recirculating Deep Water Culture) mit verteilter ESP32-basierter Sensorik und KI-gestützter Regelung.

### 3-Schicht-Architektur

```
┌─────────────────────────────────────────────────────┐
│  INTELLIGENCE LAYER (Home Assistant)                │
│  - plant_stress_detector.py (Regelbasierte KI v0.1) │
│  - ai_data_collector.py (ML-Datensatz-Generator)    │
│  - Automatisierungen & Dashboards                   │
└─────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────┐
│  CONTROL LAYER (6x ESP32 mit ESPHome)               │
│  - Hydroknoten (EC/pH/Level-Monitoring)             │
│  - Dosierknoten (4x Pumpen + Rührer)                │
│  - Zeltsensor (Spektral/Klima)                      │
│  - Klimaknoten (VPD-Regelung Backup)                │
│  - 2x Kameraknoten (Timelapse/Blattanalyse)         │
└─────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────┐
│  HARDWARE LAYER                                      │
│  - Sensoren (ADS1115, AS7341, SHT31, DS18B20, ...)  │
│  - Aktoren (Pumpen, Relais, Lüfter)                 │
│  - 6-Tank RDWC-System mit Zentralreservoir          │
└─────────────────────────────────────────────────────┘
```

## Datenfluss-Beispiel: EC Auto-Dosing

```
1. ADS1115 (Hydroknoten) misst EC-Elektrode
   ↓
2. ESP32 sendet Wert → Home Assistant (192.168.30.50)
   ↓
3. plant_stress_detector.py vergleicht mit STAGE_TARGETS
   ↓
4. Bei EC < Sollwert: Automation triggert Dosierknoten
   ↓
5. Dosierknoten aktiviert Pumpe via PWM (MCP4131)
   ↓
6. Nach Dosierung: Warte 60s → Erneute EC-Messung
   ↓
7. Schleife bis EC im Zielbereich (±0.1 mS/cm)
```

## Netzwerk-Topologie

**Subnet:** 192.168.30.0/24  
**Gateway:** 192.168.30.1

| Gerät | IP | Hardware | Funktion |
|-------|-----|----------|----------|
| Home Assistant | 192.168.30.50 | Raspberry Pi 4 | Zentrale Steuerung, KI-Analyse |
| Hydroknoten | 192.168.30.91 | ESP32-DevKit | EC/pH/Temp/Level-Monitoring |
| Dosierknoten | 192.168.30.92 | ESP32-DevKit | 4x Peristaltik-Pumpen + Rührer |
| Zeltsensor | 192.168.30.93 | ESP32-DevKit | AS7341 Spektral + SHT31/BMP280 |
| Klimaknoten | 192.168.30.94 | ESP32-DevKit | VPD-Regelung (Backup) |
| Kamera Canopy | 192.168.30.95 | ESP32-CAM | Timelapse von oben |
| Kamera Detail | 192.168.30.96 | ESP32-CAM | Blattanalyse 4x täglich |

**WiFi:** SSID `dixy` / WPA2  
**Kommunikation:** ESPHome Native API (Port 6053) + Fallback Web Server (Port 80)

## ESP32-Knoten Details

### 1. Hydroknoten (192.168.30.91)
**Hauptfunktion:** Nährlösung-Monitoring

**Sensoren:**
- ADS1115 (16-bit ADC, I2C 0x48)
  - Kanal A0: EC-Elektrode (0-3.3V → 0-20 mS/cm)
  - Kanal A1: pH-Elektrode (0-3.3V → pH 0-14)
- 2x DS18B20 (1-Wire, GPIO 14)
  - Nährlösungstemperatur
  - Umgebungstemperatur
- 6x D1CS-D Wasserlevel-Sensoren (GPIO 32-35, 25-26)
  - Tank 1-6 Füllstand (binär: voll/leer)

**Aktoren:**
- SSD1306 OLED 128x64 (I2C 0x3C)
- Rotary Encoder Menü (GPIO 16-17, Button GPIO 18)

**Kalibrierung:**
- EC: 2-Punkt (1.41 + 12.88 mS/cm)
- pH: 2-Punkt (pH 4.0 + pH 7.0)

### 2. Dosierknoten (192.168.30.92)
**Hauptfunktion:** Automatische Nährstoff-Dosierung

**Aktoren:**
- 4x Peristaltik-Pumpen (LEDC PWM)
  - Pump A: GPIO 12 → A-Komponente (Wachstum)
  - Pump B: GPIO 13 → B-Komponente (Blüte)
  - Pump C: GPIO 14 → pH Down
  - Pump D: GPIO 15 → Cal-Mag
- 2x MCP4131 Digital-Potentiometer (SPI)
  - CS1 GPIO 5: Rührer-Motor Drehzahl
  - CS2 GPIO 17: Pumpen-Durchflussrate

**Dosier-Logik:**
- Liest EC von `sensor.hydroknoten_ec_wert` (via HA API)
- Pumpt 5ml → Warte 60s → Erneute Messung
- Safety: Max 50ml pro Dosierung, Timeout nach 10min

### 3. Zeltsensor (192.168.30.93)
**Hauptfunktion:** Lichtspektrum-Analyse + Klima

**Sensoren:**
- AS7341 11-Kanal Spektralsensor (I2C 0x39)
  - F1-F8: 405-690nm (8 Bänder)
  - Clear + NIR (845nm)
  - PPFD/PAR/DLI Berechnung
- SHT31 Temp/Humidity (I2C 0x44)
- BMP280 Luftdruck (I2C 0x76)

**Berechnungen:**
- VPD via Magnus-Formel
- PPFD aus AS7341 gewichtetem Spektrum
- DLI = PPFD × Photoperiode

### 4. Klimaknoten (192.168.30.94)
**Hauptfunktion:** VPD-Regelung (Backup/Redundanz)

**Sensoren:**
- SHT31 (I2C 0x44)
- MLX90614 IR-Thermometer (I2C 0x5A) - Blatttemperatur

**Aktoren:**
- 4x Relais (GPIO 16-19)
  - Heizung, Entfeuchter, Befeuchter, Reserve
- PWM-Lüfter (GPIO 25, 25kHz)

**Betriebsmodus:** Nur aktiv wenn Zeltsensor ausfällt

### 5. Kameraknoten Canopy (192.168.30.95)
**Hardware:** ESP32-CAM AI-Thinker

**Konfiguration:**
- OV2640 Sensor (2MP, 1600x1200)
- Flash LED GPIO 4
- Timelapse: Stündlich (6-22 Uhr)
- Web Server: Basic Auth (Username: `!secret web_username`)

### 6. Kameraknoten Detail (192.168.30.96)
**Hardware:** ESP32-CAM AI-Thinker

**Konfiguration:**
- OV2640 Sensor (2MP, 1600x1200)
- Flash LED GPIO 4 (Auto bei Nachtaufnahmen)
- Blattanalyse: 4x täglich (8:00, 12:00, 16:00, 20:00)
- Web Server: Basic Auth

## Home Assistant Integration

### Boot-Sequenz
1. HA startet → Wartet auf ESPHome API (autodiscover mDNS)
2. ESP32-Knoten booten → Senden Verfügbarkeit
3. HA lädt Automatisierungen
4. `plant_stress_detector.py` startet als AppDaemon
5. `ai_data_collector.py` startet als Systemd Service (alle 5min)

### Zustandsverwaltung
- **Entities:** 60+ Sensoren, 20+ Schalter, 10+ Zahlen-Eingaben
- **Persistenz:** SQLite DB (7 Tage History)
- **Recorder:** Alle `sensor.*` und `binary_sensor.*`
- **History:** InfluxDB für Langzeit-Analyse (ai_data_collector.py)

### Wachstums-Phasen (input_select.growth_stage)
1. `keimling` - Keimlingsphase (Tag 1-7)
2. `veg_early` - Frühe Vegi (Tag 8-21)
3. `veg_late` - Späte Vegi (Tag 22-35)
4. `transition` - Übergangsphase (Tag 36-42)
5. `bloom_early` - Frühe Blüte (Tag 43-56)
6. `bloom_mid` - Hauptblüte (Tag 57-70)
7. `bloom_late` - Spätblüte/Flush (Tag 71-84)

## KI-Pipeline (3 Stufen)

### Stufe 1: Datensammlung
**Komponente:** `ai_data_collector.py`

- Pollt alle 5min 40+ Sensor-Entities
- Schreibt CSV: `data/sensor_timeseries.csv`
- Struktur: `timestamp, entity_id, state, attributes_json`
- Verwendung: ML-Training-Datensatz für KI v2

### Stufe 2: Stress-Analyse (Regelbasiert)
**Komponente:** `plant_stress_detector.py`

**Analysemethoden:**
1. **Multi-Sensor Analyse**
   - Vergleicht EC/pH/VPD/Temp mit `STAGE_TARGETS`
   - Severity-Score: 0-100 (gewichtet)

2. **Wasserverbrauch-Anomalie**
   - Baseline: 7-Tage Durchschnitt
   - Alarm bei ±50% Abweichung
   - Indikator: Wurzelprobleme/Krankheit

3. **HSV Farbanalyse** (Placeholder)
   - Green: 80-100% → Gesund
   - Yellow: 10-30% → Nährstoffmangel
   - Brown: >20% → Nekrose/Tod

4. **Wachstums-Geschwindigkeit**
   - Pixel-Diff zwischen Timelapse-Frames
   - Baseline: 2-5% täglich (Vegi)

**Output:**
- Severity-Score pro Kategorie
- Recommendations (Liste von Strings)
- Auto-Correction: True/False (Lernmodus)

### Stufe 3: Empfehlungen (Future: ML-Modell)
**Status:** Geplant für v0.2

- Scikit-learn Random Forest
- Features: Sensor-Timeseries (lag 24h)
- Labels: Erfolgreiche vs. problematische Grows
- Deployment: ONNX Runtime in HA

## Sicherheit

### Secrets Management
- **Datei:** `secrets.yaml` (Git-ignored)
- **Verwendung:** `!secret wifi_ssid` in allen YAMLs
- **Niemals committen:** OTA-Passwörter, WiFi-Credentials, API-Keys

### Netzwerk-Isolation
- IoT-VLAN (optional empfohlen)
- Firewall: ESP32 → HA erlaubt, ESP32 → Internet blockiert
- mDNS nur im lokalen Subnet

### Failsafe-Mechanismen
- Watchdog-Timer auf allen ESP32 (120s)
- Deep-Sleep bei kritischem Fehler
- Relay-Failsafe: Bei Boot alle AUS

## Performance-Metriken

| Komponente | Update-Intervall | CPU Last | RAM Nutzung |
|------------|------------------|----------|-------------|
| Hydroknoten | 10s (EC/pH), 5s (Temp) | 12% | 82 KB |
| Dosierknoten | Event-basiert | 8% | 76 KB |
| Zeltsensor | 60s (AS7341), 10s (SHT31) | 18% | 94 KB |
| Klimaknoten | 10s | 10% | 78 KB |
| Kamera Canopy | 1 Foto/h | 45% (Snapshot) | 124 KB |
| Kamera Detail | 4 Fotos/Tag | 45% (Snapshot) | 124 KB |
| HA plant_stress_detector | 5min | 5% (Pi4) | 80 MB |
| ai_data_collector | 5min | 2% (Pi4) | 40 MB |

**WiFi-Bandbreite:**
- Normal: 5-10 KB/s (Sensor-Updates)
- Kamera-Snapshot: 150-300 KB burst

## Wartung & Kalibrierung

### Wöchentlich
- EC/pH Elektroden in destilliertem Wasser spülen
- OLED-Display auf Fehlermeldungen prüfen

### Monatlich
- EC/pH 2-Punkt-Kalibrierung wiederholen
- AS7341 PPFD-Kalibrierung mit Quantum-Sensor (Apogee)
- DS18B20 Temp-Vergleich (±0.5°C Toleranz)

### Pro Grow
- Nährlösung komplett wechseln
- Pumpen-Schläuche auf Verstopfung prüfen
- Kamera-Linsen reinigen
- CSV-Datensatz archivieren

## Weiterführende Dokumentation

- **Sensor-Referenz:** `SENSOR_REFERENCE.md` - Detaillierte Specs, Datasheets, Kalibrierung
- **KI-Logik:** `AI_LOGIC_EXPLAINED.md` - Algorithmen, Entscheidungsbäume, Formeln
- **AS7341 Guide:** `AS7341_SPECTRAL_GUIDE.md` - Spektralanalyse, Photosynthese-Mapping
- **Hardware:** `HARDWARE_WIRING.md` - Vollständige GPIO-Pinouts
- **Formeln:** `FORMULAS_REFERENCE.md` - VPD, EC, PPFD, DLI Mathematik
- **VPD:** `VPD_REGULATION.md` - VPD-Regelung Details
- **EC:** `EC_DOSING_GUIDE.md` - EC Auto-Dosing Logik

---
*Version: v0.1-beta | Erstellt: Dezember 2024 | Autor: DiXY Team*
