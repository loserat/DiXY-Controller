# DiXY RDWC Controller - Release Notes

## 📋 Versions-Übersicht

| Komponente | Version | Datum | Status |
|-----------|---------|-------|--------|
| **Hydroknoten** | v0.2-beta | 06.12.2025 | ✅ Updated |
| **Dosierknoten** | v0.2-beta | 06.12.2025 | ✅ Updated |
| **Klimaknoten** | v0.2-beta | 06.12.2025 | ✅ Updated |
| **Zeltsensor** | v0.2-beta | 06.12.2025 | ✅ Updated |
| **Zeltsensor v2** | v0.3-beta | 07.12.2025 | ✅ Released |
| **Kameraknoten Canopy** | v0.2-beta | 06.12.2025 | ✅ Updated |
| **Kameraknoten Detail** | v0.2-beta | 06.12.2025 | ✅ Updated |
| **Plant Stress Detector** | v0.1-beta | 06.12.2025 | 🆕 New Beta |
| **Home Assistant** | 2024.12.x | - | ✅ Required |

---

## 🚀 v0.3-beta (✅ Released) – Zeltsensor v2 Enhanced (07.12.2025)

### 📦 Neu in v0.3-beta

#### **Telemetrie & Diagnostik** 📊
- ✅ Build Time Textsensor (Compiler-Zeitstempel)
- ✅ IDF Version Textsensor (ESP-IDF Framework)
- ✅ Chip Model Textsensor (ESP32-DevKit)
- ✅ Enhanced Status Summary (WiFi-Qualität + Uptime)
- ✅ Reset Grund Textsensor (poweron/ext/sw/panic/wdt/brownout/etc.)

#### **Sensor Health Monitoring** 🏥
- ✅ **8× Status-Sensoren** (AS7341, SHT31, BMP280, CO₂, MLX #1/#2, DS18B20, Tacho)
- ✅ **8× Binary "Aktiv" Sensors** (device_class: connectivity)
- ✅ **8× Uptime-Counter** (Format: "X d, Y h, Z m")

#### **Notdimmung & Alarme** 🚨
- ✅ **Temperatur-Notdimmung:** Temp > 30°C → Licht 10%, Lüfter 100%
- ✅ **CO₂-Alarm:** CO₂ > 1000 ppm → Buzzer Pulse-Pattern
- ✅ **2× Binary Alarm Sensors** (heat + problem)

#### **Benutzersteuerung** 🎚️
- ✅ **Licht Dimmen Button:** 100% → 70% → 40% → 10% → 100%
- ✅ **Lüfter Dimmen Button:** 100% → 70% → 40% → 20% → 100%

#### **Hardware-Bereinigung**
- ✅ Heater-Relais entfernt (GPIO 13)

### 📊 Entity-Übersicht v0.3-beta
**~65+ Entities:** 30+ Sensoren | 10+ Binary | 12+ Text | 2 Numbers | 2 Buttons | 3 Switches | 4 Automationen

### 🔮 Geplant für v0.4+
- RTC Modul (DS3231)
- Auto-Lüfterregelung basiert auf VPD
- Sensor-Error-Recovery
- Multi-Zelt-Logging

---

## 🚀 v0.2-beta - Zeltsensor Major Update (06.12.2025)

### 📦 Neu in v2 (Design-Stand)

- **Sensorik erweitert:**
  - CO₂ (MH-Z19B/C, UART)
  - 2× MLX90614 Blatt-Temperatur (RJ12, Adressen 0x5A/0x5B)
  - DS18B20 Wasser-Temp im Wurzelbehälter
  - AS7341, SHT31, BMP280 weiterhin an I2C1
- **Dimming/Steuerung:**
  - 0–10 V Dimmer-Ausgänge (PWM → Wandler) für Inline-Fan und Beleuchtung (GPIO25/26)
  - Fan-Tacho optional an GPIO23
- **Berechnungen:**
  - Taupunkt, Absolute Feuchte, VPD
  - DLI (tagesbasiert, Reset Mitternacht)
  - Blatt-Temp-Durchschnitt und Leaf-Air-Delta
- **Outputs/Schalter:** Heater-Relais, Status-LED, Buzzer vorbereitet

### ⚠️ Status & Nächste Schritte
- Elektronik-Layout vorhanden, wird nach Beschaffung angepasst
- PWM→0–10 V Wandler erforderlich (externes Modul)
- MLX #2 muss auf 0x5B umadressiert sein
- Automationen (VPD-/Temp-Regelung) werden in Home Assistant hinterlegt

---

### 📦 Zeltsensor v0.1 → v0.2

#### ➕ Hinzugefügt

**WiFi & Diagnostics:**
- WiFi SSID/IP/MAC Anzeige
- WiFi Signal-Stärke Monitoring (-65 dBm)
- System Uptime Tracking
- ESPHome & Project Version Anzeige (v0.2-beta)
- Restart & Safe Mode Buttons für Fernwartung

**Berechnete Klimawerte:**
- **VPD-Berechnung** (Vapor Pressure Deficit) via Magnus-Formel
- **Taupunkt-Berechnung** (Schimmel-Prävention, °C)
- **Absolute Luftfeuchtigkeit** (g/m³)

**Licht-Analysen:**
- **PPFD-Berechnung** (µmol/m²/s) mit gewichteten AS7341-Kanälen
  - Gewichte: F1=0.75, F2/F7=1.0 (Chlorophyll-Peaks), F5=0.7 (Green Gap)
- **DLI-Berechnung** (Daily Light Integral, mol/m²/d)
- **R:FR Ratio** (Red:Far-Red für Streckung vs. kompaktes Wachstum)
- **Blue:Red Ratio** (Photomorphogenese-Indikator)
- **Konfigurierbarer PPFD-Kalibrierfaktor** (0.003415 default)

**Inline-Abluftlüfter (Vorbereitung):**
- PWM-Steuerung vorbereitet (GPIO 25, 0-100%, 25kHz)
- Auto-Modus Logik basierend auf VPD + Temperatur
- Manueller Override-Modus
- Optional: RPM-Messung via Tacho (GPIO 26)
- **Status:** Auskommentiert bis Hardware angeschlossen

**Status-Monitoring:**
- I2C-Sensor Health-Checks (SHT31, AS7341, BMP280)
- PPFD-Alarm Binary Sensors (zu niedrig <300, zu hoch >1200)
- VPD-Alarm Binary Sensor (kritisch wenn <0.4 oder >1.6 kPa)
- Online-Status Binary Sensor

**Pin-Mapping System:**
- Alle Pins via `substitutions` konfigurierbar
- I2C-Adressen zentral änderbar
- Hardware-spezifische Defaults dokumentiert

#### 🔧 Geändert
- AS7341 Update-Intervall: explizit 60s (vorher implizit)
- SHT31/BMP280 weiterhin 30s
- GPIO-Pinout-Kommentar erweitert (Lüfter-PWM dokumentiert)
- Project Version: v0.1-beta → v0.2-beta

#### 📊 Technische Details
- **Neue Sensoren:** 15 Template-Sensoren (VPD, PPFD, DLI, etc.)
- **Neue Binary Sensors:** 7 (3x Health-Check, 3x Alarme, 1x Status)
- **Neue Text Sensors:** 4 (WiFi-Info, Versionen)
- **Neue Buttons:** 2 (Restart, Safe Mode)
- **Neue Numbers:** 1 (PPFD Kalibrierfaktor)
- **Code-Zeilen:** 314 (vorher ~140)

#### ⚠️ Breaking Changes
Keine - alle bestehenden Entity-IDs bleiben erhalten

#### 🔮 Vorbereitung für zukünftige Hardware
- Inline-Lüfter Code vollständig implementiert (auskommentiert)
- Auto-Regelungs-Logik getestet (VPD + Temp Algorithmus)
- Tacho-Signal konfiguriert (GPIO 26), optional aktivierbar

---

## 🚀 v0.2-beta - Dosierknoten Major Update (06.12.2025)

### 📦 Dosierknoten v0.1 → v0.2

#### ➕ Hinzugefügt

**Sensor-Inputs & Ziele:**
- EC Ist (Hydroknoten via HA) + EC Soll (input_number.ec_target)
- pH Ist (Hydroknoten via HA) + pH Soll (input_number.ph_target)
- System-Volumen aus HA (input_number.rdwc_system_liters)

**Wirksamkeit & Kalibrierung:**
- EC-Wirksamkeit pro ml/100L für 4 Pumpen (A–D)
- pH-Wirksamkeit pro ml/100L für pH Down (B) & pH Up (C)
- Flow-Rate-Kalibrierung je Pumpe (ml/s)

**Rührzeit-Management:**
- Mindest-Rührzeit zwischen Dosierungen (default 180s)
- Durchmischungs-Dauer (System-Zyklus, default 300s)
- Sensoren: Zeit seit letzter Dosierung, Countdown, Durchmischungs-Fortschritt

**Safety:**
- Max ml/Tag je Pumpe, Max ml pro Zyklus
- Tageszähler je Pumpe mit Mitternachts-Reset (Script + Button)
- Safety-Warn-Binaries (90% Limit)

**Intelligente Dosier-Logik:**
- EC-Dosierung (Pumpe A) mit Hydroknoten-Online-Check, Safety, Flow-basierter Laufzeit
- pH-Dosierung (Pumpen B/C) mit Richtungserkennung (Up/Down), Safety, Flow-basierter Laufzeit
- Rührmotor-Aktivierung nach jeder Dosierung

**Diagnostics & Lifetime:**
- WiFi Info (IP/SSID/BSSID/MAC), WiFi Signal, Uptime, Free Heap
- Lifetime-Stats: Total ml, Zyklen je Pumpe
- Buttons: Restart, Safe Mode, Tages-Reset

#### 🔧 Geändert
- Header/Metadata auf v0.2-beta, Pins via substitutions dokumentiert
- Neues Substitution-Set für Safety (max_dose_per_cycle, max_ml_per_day) und Timing (min_stir_time, full_mix_time)

#### 📊 Technische Details
- Neue Numbers: 20+ (Wirksamkeit, Flow, Safety, Timing)
- Neue Globals: Timestamps, Tageszähler, Lifetime-Zähler
- Neue Scripts: dose_ec_nutrients, dose_ph_correction, daily_reset_script
- Neue Binary Sensors: Rührzeit OK, Hydroknoten online, Safety-Warnungen, Dosierung aktiv
- Neue Text Sensors: WiFi Info, Status-Summary
- Buttons: Restart, Safe Mode, Tages-Counter Reset

#### ⚠️ Breaking Changes
- IDs der Pumpen-Outputs/Switches bleiben bestehen; neue Entities hinzugekommen
- `water_level_sensor.h` unberührt

---

## 🚀 v0.2-beta - Hydroknoten Update (06.12.2025)

### 📦 Hydroknoten v0.1 → v0.2

#### ➕ Hinzugefügt

**Diagnostics & Health:**
- WiFi-Infos erweitert (IP/SSID/BSSID/MAC) + Status-Summary belassen
- Health-Binaries für ADS1115 (EC/pH-ADC) und DS18B20 (Temperatur)
- Sammel-Alarm "Tank leer" (true, wenn einer der 6 Level-Sensoren leer meldet)

**Kalibrierung & Service:**
- Kalibrierungs-Timestamps (EC/pH) mit Buttons zum Markieren und Textsensor-Anzeige
- Restart-Button für Fernwartung

**Versionierung & Meta:**
- Projektversion auf v0.2-beta im YAML hinterlegt

#### 🔧 Geändert
- Header/Kommentar auf v0.2-beta angehoben
- WiFi-Textsensor um BSSID/MAC ergänzt
- Health-Binaries als Fehler-Flags (device_class=problem) deklariert

#### ⚠️ Hinweise
- Pinout/Hardware unverändert; EC/pH/Temperatur wie zuvor, ergänzt um Diagnostik
- Kalibrierungs-Timestamps nach realer Kalibrierung per Button setzen

---

## 🚀 v0.2-beta - Klimaknoten + Kameras Update (06.12.2025)

### 📦 Klimaknoten v0.1 → v0.2

#### ➕ Hinzugefügt
- WiFi Diagnostics (IP/SSID/BSSID/MAC/Signal)
- Health-Checks (SHT31, MLX90614, BMP280 Fehler-Flags)
- System Sensoren (Uptime, Free Heap, Chip Temp)
- Restart + Safe Mode Buttons
- Projekt-Version v0.2-beta

#### ⚠️ Hinweise
- Relay-Logik unverändert, nur Diagnostik erweitert

### 📷 Kameraknoten Canopy v0.1 → v0.2 + Detail v0.1 → v0.2

#### ➕ Hinzugefügt
- WiFi Diagnostics (Signal, SSID, BSSID, MAC, IP)
- System Sensoren (Uptime, Free Heap, Chip Temp)
- Online-Status Binary Sensor
- Restart + Safe Mode Buttons
- Projekt-Version v0.2-beta

#### ⚠️ Hinweise
- Camera-Streams + Snapshot-Automation unverändert
- Minimal Overhead (ESP32-CAM hat begrenzte Speicherressourcen)

---

## 🚀 v0.1-beta - Initial Beta Release (06.12.2025)

### ✨ Features

- ✅ **6 ESP32 Knoten** mit spezialisierter Funktion
- ✅ **EC/pH Monitoring** mit 2-Punkt-Kalibrierung
- ✅ **6x D1CS-D Wasserstand-Sensoren** (GPIO digital)
- ✅ **4x Peristaltikpumpen** mit EC-Auto-Regelung
- ✅ **VPD-Regelung** mit automatischer Klimasteuerung
- ✅ **AS7341 Spektralsensor** für PPFD/DLI/PAR
- ✅ **2x ESP32-CAM** für Timelapse + Blattanalyse
- ✅ **KI Plant Stress Detector** mit Image Analysis
- ✅ **Wachstumsstadien-System** (6 Phasen auto-detectable)
- ✅ **OLED Menü** mit Rotary Encoder
- ✅ **Home Assistant Integration** (native API)
- ✅ **Secrets Management** für sichere Credentials

### 🔧 Hardware-Stack

```
ESP32-DevKit (Hydroknoten)
├─ ADS1115 ADC (EC + pH)
├─ SSD1306 OLED Display
├─ Rotary Encoder (Menu Navigation)
├─ DS18B20 (Water Temp)
└─ 6x GPIO (D1CS-D Water Level Sensors)

ESP32-DevKit (Dosierung)
├─ 4x PWM Pump Control (GPIO12-15)
├─ 2x MCP4131 SPI Poti (Inline Fan + Stirrer)
└─ EC-Sensor Input (via HA API)

ESP32-DevKit (Zeltsensor)
├─ AS7341 (11-Channel Spectral)
├─ SHT31 (Temp/RH)
└─ BMP280 (Pressure)

ESP32-CAM AI-Thinker (x2)
├─ OV2640 2MP Camera
├─ GPIO4 White LED Flash
└─ MJPEG Stream + Snapshot

Raspberry Pi 4 (Home Assistant)
├─ Python 3.9+
├─ OpenCV 4.8.1.78
├─ NumPy 1.24.3
└─ ESPHome Dashboard
```

### 📊 Monitored Parameters

**EC/pH:**
- 2-Punkt-Kalibrierung (1.41 + 12.88 mS/cm, pH 4.0 + 7.0)
- Offset-Kalibrierung in Flash persistent

**Klima:**
- VPD (Vapor Pressure Deficit)
- Lufttemperatur + Luftfeuchte
- IR Blatttemperatur (MLX90614)
- Licht (PPFD, PAR, Lux, CCT, DLI)

**Wasser:**
- 6x Digital Level (presence/absence)
- Verbrauch-Tracking (L/day)
- Anomalieerkennung (±50%)

**Pflanzen-Stress:**
- Blattfarben-HSV (Green/Yellow/Brown %)
- Wachstums-Geschwindigkeit (Pixel-Diff)
- Stage-aware Targets

### 🔐 Sicherheit

- ✅ **Secrets Management**: WiFi + OTA Passwörter in lokaler `secrets.yaml` (Git-protected)
- ✅ **ESPHome Encryption**: API encryption keys für OTA
- ✅ **YAML Best Practice**: Alle Passwörter als `!secret` Referenzen
- ✅ `.gitignore` schützt `secrets.yaml` automatisch

### ⚠️ Beta-Hinweise

1. **Erste öffentliche Version** - Features noch nicht vollständig getestet
2. **Bildanalyse**: Noch keine echten Kamera-Aufnahmen verarbeitet
3. **Wasserverbrauch**: Braucht echte Tank-Level-Daten für Baseline
4. **Growth Stage Auto**: Benötigt echte Lichtplan-Daten
5. **ESP32-CAM Flash**: Manuelle FTDI-Adapter-Prozedur nötig

### 📋 Installations-Anleitung

```bash
# 1. Klone Repository
git clone https://github.com/USERNAME/dixy-rdwc-controller.git
cd dixy-rdwc-controller

# 2. Erstelle secrets.yaml mit deinen Werten
cp secrets.yaml.example secrets.yaml
nano secrets.yaml  # WiFi + OTA Passwörter eintragen

# 3. Flash ESP32 Nodes
esphome run ESP32-Knoten/hydroknoten.yaml
esphome run ESP32-Knoten/dosierung.yaml
# ... weitere Nodes

# 4. Home Assistant erkennt Knoten automatisch!
```

Siehe: `docs/GITHUB_UPLOAD_GUIDE.md` für detaillierte Anleitung

### 🔮 Nächste Schritte (v0.2-beta Roadmap)

- [ ] ML-Schädlings-Erkennung (YOLO)
- [ ] Multi-Level Tank-System
- [ ] Custom HA Integration
- [ ] Video-Streaming-Optimierung
- [ ] Nacht-Modus (Red LED)
- [ ] Automatische Stage-Transition

---

**Last Updated**: 06.12.2025  
**Current Version**: v0.1-beta  
**Maintainer**: DiXY RDWC Project
