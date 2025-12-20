
### v2.8 (Release Date: 2025-12-20)
**Zeltsensor**
- Autarke Lichtsteuerung mit State-Machine und SA/SU-Rampen weiter optimiert
- Home Assistant-Integration für alle Lichtparameter und Moduswahl
- Health-Monitoring für I2C-Sensoren vorbereitet
- Web-Dashboard für lokale Sensoranzeige ergänzt
- Versionierung und Diagnose-Entität für Firmwarestatus

**Hydroknoten**
- Version 2.1: Logger und Boot-Meldung integriert
- WiFi/OTA/Logger/Projekt-Metadaten konsolidiert
- API-Verschlüsselung und Fallback-AP verbessert

---

### v2.7 (Release Date: 2025-12-19)
**Zeltsensor**
- State-Machine für Lichtsteuerung (MANUAL/AUTO/SA/SU) vollständig auf ESP verlagert
- Persistente Parameter für Lichtprofile und Rampen
- Home Assistant-Entitäten für Modus und Parameter
- Fehlerbehandlung und Robustheit verbessert

---

### v2.6 (Release Date: 2025-12-18)
**Zeltsensor**
- entity_category: diagnostic für Versions-Textsensor ergänzt
- YAML-Struktur und Kommentare überarbeitet
- Bugfixes bei der Modusumschaltung und Rampenlogik

---

### v2.2–v2.5
- Diverse Verbesserungen an Dummy-Sensoren, Zeitsteuerung und YAML-Struktur
- Versionierung und Dokumentation konsolidiert

---

## 🚀 v0.2: Node-RED, ESPHome Cleanup, Docs

**Status:** 🟢 Current  
**Release Date:** Dec 14, 2025

### Changes from v0.1

- 📝 Versionsnummern in YAMLs und Loggern konsolidiert (z. B. hydroknoten_v2.1.yaml → "2.1")
- 📝 Changelog und README für hydroknoten und zeltsensor um alle Änderungen ergänzt
- 🐛 YAML-Struktur bereinigt (Indents, Blockstruktur, Duplikate entfernt)
- 🧪 Dummy-Sensoren und Dummy-Buttons für Home Assistant hinzugefügt
- 🐞 Problematische Komponenten (uptime, status) entfernt, da ESPHome-Linkerfehler

---

## 🚀 v0.1: Baseline Release

**Status:** ⚪️ Baseline  
**Release Date:** Dec 08, 2025

### Components at v0.1
- ✅ Hydroknoten (EC/pH/Temp + Tank Levels)
- ✅ Dosierung (4× Pumpen + Stirrer)
- ✅ Zeltsensor (AS7341 Spektral + Climate)
- ✅ Klimaknoten (VPD + 4× Relays)
- ✅ Kameraknoten (Canopy + Detail Timelapse)

### Features
- ✅ All 5 ESP32 nodes at v0.1 baseline
- ✅ MQTT Discovery ready
- ✅ Home Assistant integration structure
- ✅ Complete documentation (README + SENSORS.md per node)
- ✅ Version synchronization across all components

### Known Issues (for v0.2 fixes)
- [ ] Node-Red flows in proposals/ need production validation
- [ ] HA HACS integration not yet implemented
- [ ] ESP32 flash wizard script needed
- [ ] Docker-Compose stack not yet built

---

## 📝 Future Versions (Planned)

### v0.3 (Planned: Dec 22, 2025)
**Focus:** HACS Custom Integration

**Planned changes:**
- [ ] Develop custom_components/dixy_controller/
- [ ] Auto-discovery of nodes via MQTT
- [ ] Unified dashboard auto-generation
- [ ] Custom services (dose_pump, calibrate_ec)

### v1.0 (Planned: Jan 2026)
**Focus:** Production Releaser

**Planned changes:**
- [ ] Complete testing on live hardware
- [ ] Performance optimization
- [ ] Redundancy + failover mechanisms

#### Features
- ✅ EC-Wert (ADS1115, 2-Punkt-Kalibrierung, Temp-Kompensation)
- ✅ pH-Wert (ADS1115, 2-Punkt-Kalibrierung)
- ✅ Dual DS18B20 Temperaturen (Tank + Rücklauf mit Offset)
- ✅ 6× Wasserstand-Sensoren (GPIO digital mit Debounce)
- ✅ WiFi + API Encryption
- ✅ Health Monitoring (Free Heap, Uptime, Reset Grund)
- ✅ Status Summary Text

#### HA Integration
- [ ] Alle Entities erkannt (17 Sensoren)
- [ ] Dashboard Template erstellt
- [ ] Kalibrier-Buttons funktional
- [ ] Offset-Anpassung getestet

#### Features
- [ ] AS7341 Spektralsensor (8 Kanäle: VN, BN, BLUE, CYAN, GREEN, YELLOW, ORANGE, RED, NIR)
- [ ] PPFD Berechnung (µmol/m²/s)
- [ ] DLI Berechnung (mol/m²/day)
- [ ] CCT Berechnung (Farbtemperatur)
- [ ] SHT31 Luftfeuchte + Temperatur
- [ ] BMP280 Luftdruck
- [ ] AS7341 Health Check

### v0.3 (Klimaknoten Backup)
**Target:** Dec 21, 2025

#### Features
- [ ] SHT31 (Luftfeuchte + Temperatur)
- [ ] MLX90614 (Blatttemperatur IR)
- [ ] BMP280 (Luftdruck)
- [ ] VPD-Berechnung (Magnus-Formel)
- [ ] Health Monitoring (Sensor Status)

### v0.4 (Kameraknoten)
**Target:** Dec 28, 2025

#### Features
- [ ] OV2640 Kamera Integration (Canopy)
- [ ] Timelapse Mode (stündlich)
- [ ] Snapshots speichern
- [ ] WiFi Stability Testing

### v0.5 (Plant Stress Detector Baseline)
**Target:** Jan 4, 2026

#### Features
- [ ] Regelbasierte Multi-Sensor-Analyse
- [ ] Growth Stage Detection (7 Phasen)
- [ ] Stress Score Berechnung (0–100)
- [ ] Alert-Schwellen
- [ ] Home Assistant Notifications

### v0.6–0.9 (Stabilisierung & Testing)
**Target:** Jan 11–25, 2026

#### Features
- [ ] Dashboard Optimierung (Lovelace)
- [ ] Health Monitoring v2 (Failure Counter)
- [ ] Fehlerbehandlung + Watchdog
- [ ] 72h Stress-Test (WiFi Reconnect, Sensor Drift)
- [ ] Dokumentation: SETUP_GUIDE.md

#### Success Criteria
- ✅ Alle 6 Knoten laufen 2–3 Wochen stabil
- ✅ HA Dashboard übersichtlich + funktional
- ✅ Keine WiFi-Dropouts > 30 Minuten
- ✅ EC/pH Drift < 0.1 mS/cm / 0.1 pH pro Woche

---

## 🚀 v1.0–1.9: Dosierungsknoten (EC/pH Auto-Dosierung)

### v1.0 (Dosierknoten Hardware)
**Target:** Jan 25, 2026

#### Features
- [ ] 4× PWM Peristaltikpumpen (Dünger, pH Down, pH Up, Additive)
- [ ] Rührmotor MCP4131 Speed Control
- [ ] Stromsensor (ACS712) pro Pumpe → Verification
- [ ] Relay Feedback (Optokoppler)
- [ ] Safety Limits: Max ml/Zyklus, Max ml/Tag, Auto-Stop >30 Min

#### HA Integration
- [ ] Pumpe A–D Manual Control (Slider: 0–100 ml)
- [ ] Rührmotor Speed (0–100%)
- [ ] Pump Runtime Counter
- [ ] Current Monitoring

### v1.1 (EC Auto-Dosierung)
**Target:** Feb 1, 2026

#### Features
- [ ] EC Target eingeben (input_number)
- [ ] EC Hysterese (0.05–0.3 mS/cm)
- [ ] Dosierung bei EC zu niedrig: Pumpe A aktivieren
- [ ] Berechnung: ml = f(EC_error, Tank_Volume, Growth_Stage)
- [ ] Safety: Daily Limit Check

### v1.2 (pH Auto-Dosierung)
**Target:** Feb 8, 2026

#### Features
- [ ] pH Target eingeben (input_number, default 5.8)
- [ ] pH Hysterese (0.1–0.5 pH)
- [ ] Zu sauer: Pumpe C (pH Up) aktivieren
- [ ] Zu basisch: Pumpe B (pH Down) aktivieren
- [ ] Pumpen abwechselnd steuern (nicht beide gleichzeitig)

### v1.3 (Rührmotor + Safety)
**Target:** Feb 15, 2026

#### Features
- [ ] Nach jeder Dosierung: Rührmotor 5 Min @ 75%
- [ ] Wartezeit nach Dosierung: 30 Min (vor nächster Dosierung)
- [ ] Daily Limit Alert (wenn >500 ml Gesamt)
- [ ] Pump Runtime Counter persistent
- [ ] Failure Detection: Pumpe läuft, aber kein Strom → Alert

### v1.4–1.9 (Node-RED + Tuning)
**Target:** Feb 22–Mar 8, 2026

#### Features
- [ ] Flow 03: pH Dosierung dokumentiert
- [ ] Flow 05: EC Dosierung dokumentiert
- [ ] Manual Override Modes
- [ ] Testing mit echten Nährstofflösungen
- [ ] Parameter-Tuning (P/I/D für v3.0 vorbereitet)

#### Success Criteria
- ✅ EC hält ±0.15 mS/cm Zielwert
- ✅ pH hält ±0.2 pH Zielwert
- ✅ Keine Überdosierungen
- ✅ Daily Limits funktionieren

---

## 🚀 v2.0–2.9: KI-Anbindung (Plant Stress Detector ML)

### v2.0 (Plant Stress Detector v0.1 erweitert)
**Target:** Mar 15, 2026

#### Features
- [ ] 7-Phasen Growth Stage Detection
- [ ] Stage-spezifische Targets (EC, pH, VPD, PPFD)
- [ ] Multi-Sensor Anomalieerkennung
- [ ] Stress Score (0–100)
- [ ] Wasserverbrauch Baseline Tracking

### v2.1 (AI Data Collector)
**Target:** Mar 22, 2026

#### Features
- [ ] ai_data_collector.py stündliche Speicherung
- [ ] CSV Export (data/dixy_YYYYMM.csv)
- [ ] 40+ Entities pro Eintrag
- [ ] Vorbereitung für ML-Training

### v2.2 (Growth Stage Auto-Detection)
**Target:** Mar 29, 2026

#### Features
- [ ] Days Since Seed eingeben
- [ ] Automatische Phase-Erkennung
- [ ] Targets pro Phase updaten
- [ ] Umschalten mit Alert

### v2.3 (Blattfarb-Analyse)
**Target:** Apr 5, 2026

#### Features
- [ ] Kamera Detail: HSV-Analyse
- [ ] Grün / Gelb / Braun Prozentsätze
- [ ] Stress Indicator
- [ ] Nährstoffmangel-Erkennung

### v2.4–2.9 (Datensatz + ML-Vorbereitung)
**Target:** Apr 12–May 24, 2026

#### Features
- [ ] 30+ Tage Daten gesammelt
- [ ] CSV mit 40+ Features
- [ ] Feature Engineering
- [ ] Erste Scikit-learn Experimente

#### Success Criteria
- ✅ Stress Score korreliert mit visueller Assessment
- ✅ 30+ Tage Daten gesammelt
- ✅ Ready für ML-Training

---

## 🚀 v3.0–3.9: Hardware-Optimierung & Entwicklung

### v3.0 (MQTT Integration - Optional)
**Target:** May 25, 2026

#### Features
- [ ] Mosquitto Broker Setup
- [ ] ESPHome MQTT Discovery
- [ ] 265+ Topics dokumentiert
- [ ] Command/ACK/State Pattern

### v3.1 (PID-Regler)
**Target:** Jun 1, 2026

#### Features
- [ ] PID für EC-Dosierung
- [ ] PID für pH-Dosierung
- [ ] PID für Lüfter-Speed (VPD)
- [ ] Tuning Parameter (P, I, D)

### v3.2 (Multi-Zelt Support)
**Target:** Jun 8, 2026

#### Features
- [ ] 2–4 unabhängige Grow-Räume
- [ ] Separate Growth Stages pro Zelt
- [ ] Separate Targets
- [ ] Aggregierte Analysen

### v3.3 (InfluxDB + Grafana - Optional)
**Target:** Jun 15, 2026

#### Features
- [ ] InfluxDB Zeitreihen
- [ ] Grafana Dashboards
- [ ] 1+ Jahr Datenspeicherung
- [ ] Query API für ML

### v3.4 (WiFi Power-Saving + OTA)
**Target:** Jun 22, 2026

#### Features
- [ ] Kamera Sleep Modes
- [ ] Auto-Failover
- [ ] OTA Auto-Updates
- [ ] Silent Updates ohne Reboot

### v3.5–3.9 (Community + Stabilisierung)
**Target:** Jun 29–Jul 20, 2026

#### Features
- [ ] User Feedback Integration
- [ ] Performance Optimierung
- [ ] Bugfixes
- [ ] Extended Documentation

#### Success Criteria
- ✅ System läuft 30+ Tage stabil
- ✅ Datensatz für ML-Training vorhanden
- ✅ Production-Ready

---

## 🚀 v4.0+: Deep Learning & Zukunft

### v4.0 (Plant Stress Detector ML-Hybrid)
**Target:** Aug 2026

#### Features
- [ ] Random Forest Classifier (Scikit-learn)
- [ ] Training auf 3+ Monate Datensatz
- [ ] Genauigkeit >85%
- [ ] Stress-Vorhersage 48h im Voraus

### v4.1 (Disease Detection)
**Target:** Sep 2026

#### Features
- [ ] OpenCV für Blattanalyse
- [ ] Pilz/Mehltau-Erkennung
- [ ] Nährstoffmangel-Klassifikation

### v4.2 (YOLOv8 Plant Detection)
**Target:** Oct 2026

#### Features
- [ ] Real-time Plant Detection
- [ ] Growth Tracking
- [ ] Pest Detection

### v4.3+ (Advanced & Mobile)
**Target:** Q4 2026+

#### Features
- [ ] Mobile App (iOS/Android)
- [ ] REST API für externe Integrationen
- [ ] Multi-Crop Support
- [ ] Community Plugins

---

## 📌 Meilensteine

| Phase | Ziel | Datum |
|-------|------|-------|
| **v0.1** | Hydroknoten läuft | Dec 7 |
| **v0.9** | Alle Sensoren + HA Dashboard | Jan 25 |
| **v1.9** | Auto EC/pH Dosierung | Mar 8 |
| **v2.9** | Plant Stress ML-Ready (30+ Tage Daten) | May 24 |
| **v3.9** | Production-Ready, MQTT, PID, Multi-Zelt | Jul 20 |
| **v4.0+** | Deep Learning | Aug+ |

---

**Last Updated:** Dec 7, 2025  
**Next Milestone:** v0.2 (Zeltsensor) – Dec 14, 2025
- Reset Grund, Status Summary

#### **System-Sensoren (Standard auf allen Knoten):**
- ✅ WiFi Signal (dBm)
- ✅ Node Uptime (Stunden)
- ✅ MCU Temperature (°C)
- ✅ Free Heap (kB)
- ✅ ESPHome Version
- ✅ Projekt Version
- ✅ Reset Grund (ESP32 Reboot Reason)
- ✅ Status Summary (kompakt)

#### **Home Assistant Integration:**
- health_monitoring.yaml (Zeltsensor v2 Template Sensors)
- Ready für Expansion: 5 weitere Knoten Template Sensors
- Node Availability Filtering (online/offline Detection)

### 🎯 Feature-Parität erreicht

**ALLE Knoten haben jetzt:**
1. ✅ Globals (Flash-persistent wo nötig)
2. ✅ Health Monitoring V2 (Boot-Graceperiod + Failure Counter)
3. ✅ System Diagnostics (WiFi, Uptime, Heap, MCU Temp)
4. ✅ Reset Grund Detection
5. ✅ Status Summary Text Sensor
6. ✅ Binary Health OK Sensors (wo sinnvoll)

### 📊 Entity-Übersicht v0.5-beta
- **Zeltsensor v2:** ~75+ Entities
- **Klimaknoten:** ~35+ Entities (neu: +15)
- **Hydroknoten:** ~45+ Entities (neu: +1 Reset Grund)
- **Dosierung:** ~65+ Entities (neu: +2 Free Heap + Reset Grund)
- **Kameraknoten:** ~20+ Entities (neu: +12)

### 🔮 Geplant für v0.6+
- Health Monitoring Expansion auf Hydroknoten (EC/pH Health)
- MTBF Prediction (Mean Time Between Failures)
- Health Dashboard in Lovelace
- Automationen für Sensor Failure Alerts

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

## 🚀 v0.4-beta (✅ Released) – Light Control Advanced + Health Monitoring V2 (07.12.2025)

### 📦 Neu in v0.4-beta (Zeltsensor v2 ONLY)

#### **3-Modus Licht-Steuerung** 💡
- ✅ **Manuelmodus**: Feste Ein/Aus-Zeiten + feste Intensität (0-100%)
- ✅ **Automatikmodus**: Sonnenauf-/untergang mit konfigurierbarem Offset (-120 bis +120 Min)
- ✅ **PPFD-Regelung**: Kontinuierliche Anpassung der Licht-Intensität basierend auf gemessenem PPFD
  - Target PPFD: 400-1200 µmol/m²/s konfigurierbar
  - Hysterese: ±10-200 µmol/m²/s (verhindert Flackern)
  - Min/Max Grenzen: 5-100% Intensität

#### **Licht-Komfortfunktionen** 🎚️
- ✅ **Sanfte Überblendung (Fade)**: 5-600 Sekunden konfigurierbar
- ✅ **Spektrum-Profile**: Morgens/Tag/Abend (Vorbereitung für RGB-LEDs)
- ✅ **Sonnen-Integration**: Automatische Anpassung nach Sonnenauf-/untergang

#### **Sicherheit & Failsafe** 🚨
- ✅ **Temperatur-Notbremse**: >30°C → sofort Licht auf 10% (überschreibt alle Modi)
- ✅ **Hysterese & Flackerschutz**: Verhindert ständiges Umschalten bei PPFD-Regelung
- ✅ **Priorisierung**: Notbremse > Manuelle Override > Automatikmodus > PPFD

#### **Input-Entities (Home Assistant)**
- 3× input_number (Offsets, Fade-Duration)
- 8× input_number für PPFD-Regel (Target, Min%, Max%, Hysterese)
- 1× input_select für Modus (Aus / Manuell / Auto / PPFD)
- 1× input_select für Spektrum-Profil
- 2× input_datetime für Manuell Ein/Aus-Zeiten

#### **Automationen & Scripts**
- 5× Automationen (Manual ON/OFF, Auto Sunrise/Sunset, PPFD Kontinuierlich, Temp Failsafe)
- 2× Scripts (fade_light_smooth, adjust_light_ppfd)
- Proportionale Regelung mit konfigurierbarem Gain (KP)

### 📊 Entity-Übersicht v0.4-beta
**+15 neue Entities:** 8 input_numbers | 2 input_selects | 2 input_datetimes | 5 automations | 2 scripts

### 🔮 Geplant für v0.5+
- **Health Monitoring V2**: Boot-Graceperiod + Failure Counter (Node-Offline vs. Sensor-Fehler unterscheiden)
- **HA Sensor Health Dashboard**: Reliability %, Error Counters, MTBF Prediction
- RGB Spektrum-Anpassung (echte Farb-Regelung)
- VPD-basierte Light Intensity (wenn Stress erkannt)
- Plant Stress Detector Integration
- Light Efficiency Logging (DLI Historical)

---

## 🚀 v0.3-beta (✅ Released) – All Nodes Version Sync (07.12.2025)

### 📦 Änderungen in v0.3-beta

#### **Version-Synchronisierung** 🔄
Alle ESP32-Knoten auf v0.3-beta synchronisiert zur Vorbereitung der **Health Monitoring V2 Architektur**:
- ✅ Hydroknoten: v0.2 → v0.3
- ✅ Dosierknoten: v0.2 → v0.3
- ✅ Klimaknoten: v0.2 → v0.3
- ✅ Zeltsensor (Legacy): v0.2 → v0.3
- ✅ Kameraknoten Canopy: v0.2 → v0.3
- ✅ Kameraknoten Detail: v0.2 → v0.3
- ✅ DiXY-Controller (Global): v0.2 → v0.3

#### **Geplante Features für v0.3** (noch nicht implementiert)
- 🔮 Boot-Graceperiod (5min) für alle Sensoren
- 🔮 Failure-Counter mit Flash-Persistenz
- 🔮 Node-Offline vs. Sensor-Fehler Unterscheidung
- 🔮 HA-seitige Health-Templates für intelligente Fehlerdiagnose

### 📝 Notiz
v0.3-beta ist primär ein **Versions-Alignment Release**. Die Health Monitoring V2 Features werden in kommenden Commits implementiert.

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
