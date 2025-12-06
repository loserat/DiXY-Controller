# DiXY RDWC Controller – Knoten-Funktionen Übersicht

**Stand:** 06.12.2025  
**Version:** v0.2 / v0.1 (Mixed)  
**Sprache:** Deutsch

---

## 📋 Kurzübersicht aller Knoten

| Knoten | Funktion | Hardware | Version | Status |
|--------|----------|----------|---------|--------|
| **Hydroknoten** | Nährstoff-Monitoring (EC/pH) + Wasserstand | ESP32 + ADS1115 + SSD1306 + DS18B20 | v0.2-beta | ✅ Updated |
| **Dosierknoten** | Intelligente Auto-Dosierung + Rührmotor | ESP32 + MCP4131 (SPI) + 4x PWM Pumpen | v0.2-beta | ✅ Updated |
| **Zeltsensor** | Spektral-Licht + Klima + Lüfter-Auto | ESP32 + AS7341 + SHT31 + BMP280 | v0.2-beta | ✅ Updated |
| **Klimaknoten** | VPD-Regelung (Standalone Alternative zu Zelt) | ESP32 + SHT31 + MLX90614 + BMP280 | v0.1-beta | ⚠️ Backup Only |
| **Kamera Canopy** | Wachstums-Timelapse Top-Down | ESP32-CAM + OV2640 | v0.1-beta | 🆕 New Beta |
| **Kamera Detail** | Blattfarben-Analyse + Schädlings-Erkennung | ESP32-CAM + OV2640 | v0.1-beta | 🆕 New Beta |

---

## 🟢 HYDROKNOTEN v0.2-beta

### Hardware
- **Microcontroller:** ESP32-DevKit (WiFi + Bluetooth)
- **ADC:** ADS1115 (4-Kanal 16-Bit, I2C @ 0x48)
- **Sensoren:**
  - EC-Sensor (Atlas Scientific, analog → ADS1115 A0)
  - pH-Sensor (Atlas Scientific, analog → ADS1115 A1)
  - DS18B20 Wassertemperatur (OneWire, 2x Sensoren auf GPIO4+5)
  - 6x D1CS-D kapazitive Wasserstand-Sensoren (GPIO 32,33,14,12,13,15)
- **Display:** SSD1306 OLED 128x64 (I2C @ 0x3C)
- **Bedienung:** Rotary Encoder 3-pin (CLK, DT, Button) mit Menü

### Sensoren & Messungen

#### EC (Leitfähigkeit)
- **Kalibrierung:** 2-Punkt (1.413 mS/cm Low, 12.88 mS/cm High)
- **Messbereich:** 0–20 mS/cm
- **Update:** 10s
- **Besonderheit:** Temperatur-Korrektur auf 25°C (Magnus-Formel)

#### pH (Säuregrad)
- **Kalibrierung:** 2-Punkt (pH 4.0, pH 7.0)
- **Messbereich:** 0–14 pH
- **Update:** 10s
- **Besonderheit:** Roh-Spannung in mV für Diagnose

#### Wassertemperatur
- **Sensoren:** 2x DS18B20 (Tank + Rücklauf)
- **Update:** 10s
- **Offsets:** Je Sensor kalibrierbar (±2°C)
- **Anwendung:** Temp-Kompensation EC, Trend-Analyse

#### Wasserstand
- **Sensoren:** 6x D1CS-D (Tank 1–6)
- **Logik:** HIGH=Wasser vorhanden, LOW=Leer (mit 500ms Entprellung)
- **Alarm:** Binary Sensor "Tank leer (mindestens einer)" aggregiert Leer-Zustand
- **Update:** Event-basiert + 1s Debounce

### System-Funktionen

#### OLED-Menü (Rotary Encoder Navigation)
- **Seite 0 (Home):** Live EC/pH/T1/T2 Anzeige
- **Seite 1 (Hauptmenü):** 6 Optionen via Encoder
  1. Sensor-Anzeige (zurück)
  2. EC Kalibrieren (Low/High Steps)
  3. pH Kalibrieren (pH4/pH7 Steps)
  4. Offsets anpassen (T1/T2)
  5. Werkseinstellung
  6. Zurück

#### Kalibrierung
- **EC Low:** Kalibrierpunkt 1.413 mS/cm (verwieselt)
- **EC High:** Kalibrierpunkt 12.88 mS/cm (Flora Nährstoff)
- **pH 4:** Erste Referenz
- **pH 7:** Zweite Referenz
- **Speicherung:** Flash-persistent (NVS)
- **Zeitstempel:** Button markiert letzte Kalibrierungs-Zeit (Unix-Sekunden)

#### Diagnostics & Health
- **WiFi Signal:** dBm, SSID, BSSID, MAC, IP-Adresse
- **System:** Uptime (Stunden), Free Heap (kB), Chip-Temperatur
- **Sensor-Health:**
  - ADS1115 Fehler (true = NaN bei EC oder pH)
  - Temperatur Fehler (true = NaN bei T1 oder T2)
- **Alarm:** "Tank leer" (aggregiert alle 6 Level)
- **Version:** ESPHome-Version + Projekt v0.2-beta

#### Buttons & Services
- **Restart:** Neustart des Knotens
- **EC Kalibrierung markieren:** Setzt Timestamp `last_ec_cal_ts`
- **pH Kalibrierung markieren:** Setzt Timestamp `last_ph_cal_ts`

### Daten-Bereitstellung (Home Assistant)
- **Sensoren:** EC, pH, T1 (korrigiert), T2 (korrigiert), WiFi Signal, Uptime, Free Heap, Chip Temp
- **Binary:** Tank1–6 Level, Tank Leer, ADS1115 Fehler, Temp Fehler, Online-Status
- **Text:** IP, SSID, BSSID, MAC, ESPHome Ver., Projekt Ver., EC/pH Kal-Times, Status-Summary
- **Numbers:** T1/T2 Offsets, EC Cal (Low/High), pH Cal (4.0/7.0)
- **Buttons:** Restart, EC/pH Mark Cal

---

## 🟣 DOSIERKNOTEN v0.2-beta

### Hardware
- **Microcontroller:** ESP32-DevKit
- **SPI Bus:** MCP4131 Digital-Potentiometer (2x, für Lüfter + Rühren)
- **Pumpen:** 4x PWM LEDC
  - Pumpe A (GPIO12): EC-Dünger (Flora Gro/Micro/Bloom)
  - Pumpe B (GPIO13): pH Down (Phosphorsäure)
  - Pumpe C (GPIO14): pH Up (Kaliumhydroxid)
  - Pumpe D (GPIO15): Additive (CalMag/Enzyme)

### Dosier-Logik (Auto-Regelung)

#### EC-Dosierung (Pumpe A)
1. **Ist/Soll:** Hydroknoten EC-Live-Wert vs. HA `input_number.ec_target`
2. **Berechnung:**
   - Differenz: Δ EC = EC_soll - EC_ist
   - Wirksamkeit: Δ EC per ml je Pumpe (kalibrierbar)
   - Dosier-Menge: ml = Δ EC / Wirksamkeit
3. **Safety:** Max ml/Zyklus, Max ml/Tag (daily counter)
4. **Rührzeit:** Mindestens 3 Min zwischen Dosierungen
5. **Aktivierung:** Flow-basierte Laufzeit (ml/s kalibrierbar)

#### pH-Dosierung (Pumpen B + C)
1. **Ist/Soll:** Hydroknoten pH-Live-Wert vs. HA `input_number.ph_target`
2. **Richtung:**
   - pH zu niedrig → Pumpe C (pH Up) aktivieren
   - pH zu hoch → Pumpe B (pH Down) aktivieren
3. **Berechnung:**
   - Ähnlich EC: Δ pH / Wirksamkeit = ml
4. **Safety:** Identisch EC (max dose, daily limit)
5. **Aktivierung:** Flow-basiert

#### Rührmotor
- **Auto-Trigger:** Nach jeder Dosierung (EC oder pH)
- **Dauer:** 90s Standard-Rühr-Lauf
- **MCP4131-Steuerung:** PWM über digitales Poti (0–100%)
- **Volle Durchmischung:** 5 Min (full_mix_time)

### Kalibrierung & Parameter

#### Pumpen-Charakteristiken
- **Flow-Rate:** ml/s pro Pumpe (messbar in Kalibrierungs-Phase)
- **EC-Wirksamkeit:** mS/cm pro ml dosiert / System-Volumen
- **pH-Wirksamkeit:** pH-Punkte pro ml dosiert / System-Volumen
- **Speicherung:** Numbers in HA (persistent in YAML)

#### Safety-Limits
- `max_dose_per_cycle`: Max 50ml pro einzelne Dosierung
- `max_ml_per_day`: Max 200ml pro Pumpe pro Tag
- **Tages-Counter:** Automatischer Reset um 00:00 UTC
- **Button:** Manueller Reset für Tests

#### Timing-Parameter
- `min_stir_time`: 180s (3 Min Pflicht zwischen Dosierungen)
- `full_mix_time`: 300s (5 Min für RDWC-Durchmischung)
- `stir_duration`: 90s (aktive Rühr-Zeit pro Zyklus)

### System-Funktionen

#### Online-Check
- **Hydroknoten-Status:** Vor jeder Dosierung prüfen (HA API)
- **Fallback:** Kein Dosieren wenn Hydroknoten offline

#### Diagnostics
- **WiFi:** Signal (dBm), SSID, BSSID, MAC, IP
- **System:** Uptime, Free Heap, Chip Temp
- **Lifetime-Stats:** 
  - Total ml pro Pumpe (kumulativ)
  - Zyklen-Zähler pro Pumpe
  - Rühr-Motor Laufzeit total
- **Versionen:** ESPHome + Projekt v0.2-beta

#### Buttons & Services
- **Restart:** Node Neustart
- **Safe Mode:** Bootloader-Modus
- **Tages-Counter Reset:** Manuell für Tests/Wartung

### Daten-Bereitstellung (Home Assistant)
- **Sensoren:** Rührzeit seit letzter Dosierung, Durchmischungs-Countdown, WiFi Signal, Uptime, Free Heap
- **Binary:** Rührzeit OK, Hydroknoten online, Safety-Warnungen (90% Limit pro Pumpe), Dosierung aktiv
- **Text:** WiFi-Info, Status-Summary, Projekt-Version
- **Numbers:** 20+ (Wirksamkeit A/B/C/D, Flow-Rate A/B/C/D, EC/pH-Target, System-Volumen, Safety-Limits, Timing)
- **Switches:** Pumpen A/B/C/D On/Off (manuell), Rührmotor On/Off, Script Triggers
- **Buttons:** Restart, Safe Mode, Daily Reset

---

## 🔵 ZELTSENSOR v0.2-beta

### Hardware
- **Microcontroller:** ESP32-DevKit
- **I2C Sensoren:**
  - AS7341 (0x39): 11-Kanal Spektralsensor (VIS+NIR)
  - SHT31 (0x44): Temperatur + Relative Luftfeuchte
  - BMP280 (0x76): Luftdruck + berechnete Höhe
- **Optional (auskommentiert bis angeschlossen):**
  - GPIO25: PWM Inline-Lüfter (0–100%, 25 kHz)
  - GPIO26: Lüfter Tacho-Signal (RPM-Messung)

### Licht-Messungen (AS7341)

#### PPFD (Photosynthetic Photon Flux Density)
- **Einheit:** µmol/(m²·s)
- **Berechnung:** Gewichtete Summe der AS7341-Kanäle
  - F1 (Blau): Weight 0.75
  - F2 (Grün): Weight 1.0
  - F3–F6 (Rot): Weight 1.0 (Chlorophyll-Peak)
  - F7 (Far-Red): Weight 1.0
  - F5 (Green Gap): Weight 0.7
  - Summe × `ppfd_cal_factor` (0.003415 via Apogee Quantum Sensor)
- **Update:** 60s
- **Alarme:** PPFD zu niedrig (<300), zu hoch (>1200)

#### DLI (Daily Light Integral)
- **Einheit:** mol/(m²·day)
- **Berechnung:** PPFD × (Photoperiode in Stunden) × 3.6
- **Photoperiode:** Konfigurierbar via HA (default 18h)
- **Update:** 60s
- **Anwendung:** Wachstums-Phase-Targeting (Seedling/Veg/Bloom benötigen unterschiedliche DLI)

#### Spektral-Ratios
- **R:FR (Red:Far-Red):** Morphogenese-Indikator
  - Hoch (1.5+): Kompaktes Wachstum
  - Niedrig (<1.0): Streckung
- **Blue:Red:** Photomorphogenese
  - Hoch: Kompakte, dichte Pflanzen
  - Niedrig: Streckung + dünn

#### PAR (Photosynthetically Active Radiation)
- **Einheit:** µmol (absolute Menge über Photoperiode)
- **Berechnung:** Integral über 24h

### Klima-Messungen

#### Temperatur & Luftfeuchte (SHT31)
- **Temperatur:** -40 bis +125°C (genau ±2°C über interessanten Bereich)
- **Luftfeuchte:** 0–100% RH (genau ±3%)
- **Update:** 30s
- **Einsatz:** VPD-Berechnung, Trend-Analyse

#### VPD (Vapor Pressure Deficit)
- **Einheit:** kPa
- **Berechnung:** Via Magnus-Formel
  - Sättigungsdampfdruck (Temperatur)
  - Aktueller Dampfdruck (Temp + RH)
  - VPD = Sättigung – Aktuell
- **Update:** 30s
- **Ideal-Bereiche (Pflanzen-Phase abhängig):**
  - Seedling: 0.4–0.8 kPa
  - Vegetativ: 0.8–1.2 kPa
  - Blüte: 0.8–1.2 kPa
- **Alarm:** Kritisch wenn <0.4 (Fungus-Risiko) oder >1.6 (Stress)

#### Taupunkt
- **Einheit:** °C
- **Berechnung:** Magnus-Formel umgekehrt
- **Einsatz:** Schimmel-Prävention (TP sollte <Lufttemp. - 2°C)

#### Luftdruck & Höhe (BMP280)
- **Druck:** hPa
- **Höhe:** Berechnet aus Luftdruck (relativ zu Meeresspiegel)
- **Update:** 30s
- **Einsatz:** Trend (Wetterveränderungen andeuten)

### Lüfter-Auto-Steuerung (Optional)

#### VPD-basierte Regel
```
If VPD > 1.2 kPa: Fan = 100% (zu trocken, Verdunstung)
If VPD < 0.4 kPa: Fan = 0% (zu feucht, Fungus-Risiko)
Else: Linear interpoliert (0–100%)
```

#### Temperatur-Backup
```
If Air_Temp > 28°C: Fan >= 50% (Wärmestress-Prävention)
If Air_Temp > 32°C: Fan = 100% (Notfall)
```

#### Implementierung (aktuell auskommentiert)
- **MCP4131 Steuerung:** Digital-Poti für 0–100% PWM
- **Tacho-Signal:** Optional RPM-Rückmeldung (GPIO26)
- **Status:** "Fan Mode" Binary (Auto vs. Manuell)

### Diagnostics & Health
- **WiFi:** Signal, SSID, BSSID, MAC, IP
- **System:** Uptime, Free Heap, Chip Temp
- **Sensor-Health:** I2C Health (SHT31, AS7341, BMP280 present?)
- **Version:** ESPHome + Projekt v0.2-beta

### Daten-Bereitstellung (Home Assistant)
- **Sensoren (Licht):** PPFD, DLI, PAR, R:FR, Blue:Red, Lux, CCT
- **Sensoren (Klima):** Air Temp, Air RH, VPD, Taupunkt, Druck, Höhe
- **Sensoren (System):** WiFi Signal, Uptime, Free Heap, Chip Temp
- **Binary:** PPFD Alarm (Low/High), VPD Alarm, I2C Health (SHT/AS/BMP), Online
- **Text:** WiFi-Info, Projekt-Version, Status-Summary
- **Numbers:** PPFD Cal Factor, Photoperiode (Stunden)
- **Switches/PWM:** Fan Manual Control (wenn aktiviert)
- **Buttons:** Restart, Safe Mode

---

## ⚪ KLIMAKNOTEN v0.1-beta

### ⚠️ Status
**Backup-Only Alternative zu Zeltsensor** – Weniger Funktionalität, nur für Standalone-VPD-Regelung empfohlen.

### Hardware
- **Microcontroller:** ESP32-DevKit
- **I2C Sensoren:**
  - SHT31 (0x44): Temp + RH (wie Zeltsensor)
  - MLX90614 (0x5A): IR-Blatttemperatur (kontaktlos, ±0.5°C)
  - BMP280 (0x76): Luftdruck (wie Zeltsensor)
- **Relays (4-Kanal Modul):**
  - GPIO16: Befeuchter (Humidifier)
  - GPIO17: Entfeuchter (Dehumidifier)
  - GPIO18: Heizung (Heater)
  - GPIO19: Umluft-Fan (Circulation Fan)

### Funktionalität
- **VPD-Berechnung:** Identisch Zeltsensor
- **Blatt-Temperatur-Monitoring:** IR ohne Kontakt
- **Relay-Steuerung:** 4x On/Off Geräte
  - Auto-Logik für Temp/RH-Regelung (rudimentär)
  - Manueller Override in HA
- **Keine PPFD/Spektral-Messungen:** Kein Licht-Sensor
- **Keine Lüfter-PWM-Steuerung:** Nur Relays

### Anwendungsfall
- Separate Klima-Kontrolle wenn Zeltsensor nicht einsetzbar
- Einfacheres Setup (keine Licht-Messungen nötig)
- Für ältere Zeitmessungs-Systeme (nicht AS7341)

---

## 📷 KAMERA CANOPY v0.1-beta

### Hardware
- **Camera:** OV2640 2MP (ESP32-CAM AI-Thinker)
- **Storage:** Keine (Snapshots via HTTP)
- **LED:** GPIO4 White LED (optional Flash)
- **Verbindung:** WiFi nur (WLAN, keine kabelgebundene Ethernet)

### Funktionen

#### Timelapse
- **Auflösung:** 1600x1200 UXGA (2MP)
- **Qualität:** 10 (Komprimierung, schneller Upload)
- **Frequenz:** 1 FPS (1 Bild/Sekunde möglich, üblicherweise stündlich via HA-Automation)
- **View:** Top-Down (Übersicht gesamtes Zelt)

#### Live Stream
- **HTTP Port:** 80
- **Format:** MJPEG (Motion JPEG Stream)
- **Auth:** Username + Password (secrets)
- **Einsatz:** Live-Monitoring in HA Lovelace Card

#### Wachstums-Tracking (KI-Input)
- **Pixel-Differenz:** Frame-Differenz zwischen Snapshots
- **Anwendung:** Höhenwachstum (Pixel-Delta / Zeit)
- **Processing:** HA Python-Script (OpenCV) extrahiert Leaf Area

#### Helligkeit/Automatik
- **Saturation:** 0 (neutral)
- **Brightness:** 0 (auto)
- **Contrast:** 0 (auto)
- **Special Effect:** NONE (Farben)

### Daten-Bereitstellung
- **Snapshots:** Abruf via HA Service oder periodisch
- **Stream:** URL für Lovelace
- **Status:** Online, WiFi Signal, Uptime

---

## 📷 KAMERA DETAIL v0.1-beta

### Hardware
- **Camera:** OV2640 2MP (ESP32-CAM AI-Thinker, gleich wie Canopy)
- **LED:** GPIO4 White LED (automatisch @02:00 für Nacht-Detail)
- **Verbindung:** WiFi nur

### Funktionen

#### Snapshot-Schedule
- **4x täglich:** 08:00 / 14:00 / 20:00 / 02:00 UTC
- **Quality:** 5 (Maximum Detail für Blattoberfläche)
- **Auflösung:** 800x600 VGA (kompakt für Macro-View)
- **View:** Side-View Macro (Blattoberfläche, Schädlinge)

#### Blattfarben-Analyse (HSV)
- **Processing:** HA Python-Script mit OpenCV
- **Histogramm:** Green% / Yellow% / Brown%
- **Einsatz:** Nährstoff-Mängel-Detektion
  - Zu viel Gelb: N-Mangel oder Überschuß
  - Zu viel Braun: Nekrose, über-/unterbewässerung
  - Grün%-Anteil: Allgemeines Health-Indikator

#### Automatische Nacht-Beleuchtung
- **Flash:** GPIO4 LED schaltet um 02:00 an
- **Einsatz:** Nächt-Detail-Fotos ohne Lichtstress
- **Duration:** Automatisch nach Snapshot aus

### Daten-Bereitstellung
- **Snapshots:** 4x täglich, zugänglich via HA
- **Stream:** HTTP MJPEG auf Demand
- **HSV-Analyse:** HA-Entity (Green%, Yellow%, Brown%)
- **Status:** Online, Signal, Uptime

---

## 🔄 Übersicht: Daten-Fluss zwischen Knoten

```
HYDROKNOTEN (EC/pH/Temp/Water)
    ↓ (Home Assistant API)
DOSIERKNOTEN (liest EC/pH-Live-Werte)
    ↓ (PWM Pumpen + MCP4131 Rühren)
RDWC-System (Nährstoff-Mischung)
    ↓ (Zirkulation + Durchmischung)

ZELTSENSOR (PPFD/VPD/Lüfter-Auto)
    ↓
Home Assistant (Automation + Trigger)
    ↓
KLIMAKNOTEN (Alternative VPD-Regelung, Relays)

KAMERA CANOPY (Top-Down Timelapse)
    ↓ (Wachstums-Pixel-Delta)
HA Python (OpenCV)
    ↓
Plant Stress Detector AI

KAMERA DETAIL (Blattfarben HSV)
    ↓ (Nährstoff-Status)
HA Python (HSV-Histogramm)
    ↓
Fertilizer Adjustment Logic
```

---

## 📌 Zusammenfassung: Kritische Funktionen je Knoten

### Hydroknoten (Essentiell)
✅ EC/pH Messung + 2-Punkt-Kalibrierung  
✅ 6x Wasserstand-Überwachung  
✅ Temperatur-Kompensation EC  
✅ OLED-Menü mit Encoder  
✅ Health/Diagnostics  

### Dosierknoten (Essentiell)
✅ EC/pH Auto-Dosierung mit Sicherheit  
✅ Rührmotor-Management (3 Min Min, 5 Min Durchmischung)  
✅ Flow-Rate Kalibrierung  
✅ Tages-Counter + Safety-Limits  
✅ Hydroknoten-Online-Check  

### Zeltsensor (Essentiell für Optimierung)
✅ PPFD + DLI Messung (Wachstums-Phasen-Targeting)  
✅ VPD-Berechnung + Alarm  
✅ Taupunkt (Schimmel-Prävention)  
✅ Spektral-Ratios (R:FR, Blue:Red)  
✅ Lüfter-Auto-Steuerung (VPD+Temp)  

### Klimaknoten (Optional, wenn kein Zeltsensor)
⚠️ VPD + IR-Blatt-Temp  
⚠️ Relay-Steuerung (Feucht/Trocknung/Heat)  
⚠️ Kein Licht-Monitoring  

### Kameras (Tracking + Diagnose)
📷 Wachstums-Timelapse (Höhe)  
📷 Blattfarben-HSV (Nährstoff-Status)  
📷 Schädlings-Sichtung  
📷 Phänotyp-Analyse (Stress-Indikatoren)  

---

**Nächste Schritte:**
1. Klimaknoten auf v0.2 (WiFi Diag, Health, Buttons) aufwerten
2. Kameras auf v0.2 (Health, Diagnostics, Versioning) aufwerten
3. YAML-Kommentar-Sektion für Kalibrierungs-Anleitung hinzufügen
4. Python-Automation für HA-Integration (EC/pH/VPD-Targets) dokumentieren
