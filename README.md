🌱 **DiXY RDWC Controller - Distributed Intelligence Hydroponic System**

# DiXY RDWC Controller v0.1-beta

> **D**istributed **I**ntelligence Hydroponic **XY** - Programmierbare RDWC-Steuerung mit AI-gestützter Pflanzenstress-Erkennung

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version: 0.1-beta](https://img.shields.io/badge/Version-0.1--beta-orange.svg)](RELEASE_NOTES.md)
[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-Integration-blue.svg)](https://www.home-assistant.io/)
[![ESPHome](https://img.shields.io/badge/ESPHome-Nodes-green.svg)](https://esphome.io/)

---

## 🎯 Überblick

**DiXY** ist ein vollständig DIY-programmierbares RDWC (Recirculating Deep Water Culture) Steuerungssystem mit:

- ✅ **6 verteilte ESP32 Knoten** für spezialisierte Funktionen
- ✅ **Home Assistant Integration** für zentrale Kontrolle
- ✅ **KI Plant Stress Detector** mit Computer Vision
- ✅ **Automatische Wachstumsstadien-Optimierung**
- ✅ **Wasserverbrauch-Anomalieerkennung**
- ✅ **Timelapse + Bildanalyse mit OpenCV**

---

## 🏗️ Architektur

```
┌─────────────────────────────────────────────────────────┐
│           Home Assistant (Zentrale Kontrolle)            │
│  • Dashboard & Automationen                              │
│  • KI Plant Stress Detector (Python)                    │
│  • Entity Management & History                           │
└─────────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼────┐      ┌─────▼────┐      ┌─────▼────┐
    │Hydro   │      │Dosierung │      │Klima     │
    │Knoten  │      │Knoten    │      │Knoten    │
    └────────┘      └──────────┘      └──────────┘
        │                │                   │
   EC/pH/Temp       4x Pumpen         VPD-Regelung
   Wasserstand      Rührmotor         Fan/Heating
        │                │                   │
        └──────────────────┼──────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼────┐      ┌─────▼────┐      ┌─────▼────┐
    │Zelt     │      │Kamera    │      │Kamera    │
    │Sensor   │      │Canopy    │      │Detail    │
    └────────┘      └──────────┘      └──────────┘
        │                │                   │
   PPFD/Lux         Timelapse          Blattanalyse
   Temp/RH          Top-Down View      Macro HSV
```

---

## 📦 Hardware-Komponenten

| Komponente | Chip | Funktion | Status |
|-----------|------|----------|--------|
| **Hydroknoten** | ESP32-DevKit | EC/pH Monitoring, Wasserstand (6x D1CS-D) | ✅ v0.1-beta |
| **Dosierknoten** | ESP32-DevKit | 4x Peristaltikpumpen + Rührmotor | ✅ v0.1-beta |
| **Zeltsensor** | ESP32-DevKit | AS7341 Spektrallicht + Klima (SHT31/BMP280) | ✅ v0.1-beta |
| **Klimaknoten** | ESP32-DevKit | Standalone VPD-Regelung (Backup) | ⚠️ Backup Only |
| **Kameraknoten Canopy** | ESP32-CAM AI-Thinker | Timelapse (1600x1200, stündlich) | 🆕 v0.1-beta |
| **Kameraknoten Detail** | ESP32-CAM AI-Thinker | Blattanalyse (4x täglich, macro) | 🆕 v0.1-beta |
| **Home Assistant** | Raspberry Pi 4 | KI + Dashboard + Automationen | ✅ v0.1-beta |

---

## 🚀 Features

### 📊 Monitoring
- **EC-Wert**: 2-Punkt-Kalibrierung (1.41 + 12.88 mS/cm)
- **pH-Wert**: 2-Punkt-Kalibrierung (4.0 + 7.0)
- **Temperatur**: DS18B20 Wassersensor + IR Blatttemperatur
- **Licht**: AS7341 11-Kanal Spektralanalyse (PPFD, PAR, DLI, CCT)
- **Klima**: VPD-Berechnung (Lufttemp, Luftfeuchte, Blatttemp)
- **Wasserstand**: 6x Kapazitive D1CS-D Sensoren

### 🤖 Intelligenz
- **Growth Stage Detection**: 6 Phasen (Keimling → Flush) mit Auto-Erkennung
- **Plant Stress Detector**: 
  - HSV-Farb-Analyse (Grün/Gelb/Braun-Prozentanteile)
  - Wasserverbrauch-Anomalieerkennung (±50%)
  - VPD/EC/pH/Temp Multi-Sensor Analyse
  - Wachstums-Geschwindigkeit (Pixel-Differenz)
- **Learning Mode**: Tipps vor Auto-Optimierung

### 🎥 Bildgebung
- **Timelapse Automation**:
  - Stündliche Canopy-Snapshots (Top-Down)
  - 4x tägliche Detail-Snapshots (Macro, mit Nacht-Flash)
  - Wöchentliche Video-Generierung
  - 30-Tage Auto-Cleanup
- **Bildanalyse**:
  - HSV-Farbraum Detektion
  - Pixel-Differenz für Wachstums-Tracking
  - Blattoberflächen-Anomalieerkennung

### ⚙️ Automatisierung
- **Stage-Aware Targeting**: EC/VPD/PPFD/Temp/pH pro Wachstumsphase
- **Automatische Dosierung**: EC-Regelung mit Rührmotor-Integration
- **VPD-Regelung**: Fan/Heizung/Befeuchter/Entfeuchter
- **Manual Override**: Alle Automationen mit Selector-Überschreibung

### 🔐 Sicherheit
- **Secrets Management**: Alle Passwörter in `secrets.yaml` (Git-protected)
- **OTA Updates**: Sichere Fernaktualisierungen aller Knoten
- **Encryption**: ESPHome API Encryption + WiFi Security

---

## 📋 Installation

### Schnellstart (30 Min)

```bash
# 1. Repository klonen
git clone https://github.com/USERNAME/dixy-rdwc-controller.git
cd dixy-rdwc-controller

# 2. Secrets erstellen
cp secrets.yaml.example secrets.yaml
nano secrets.yaml  # Deine WiFi-Passwörter eintragen

# 3. ESP32 Nodes flashen (ESPHome Dashboard oder CLI)
esphome run ESP32-Knoten/hydroknoten.yaml
esphome run ESP32-Knoten/dosierung.yaml
# ... weitere Nodes

# 4. Home Assistant Integration
# Wird automatisch erkannt über ESPHome Discovery!
```

### Detaillierte Anleitung

Siehe: [`docs/GITHUB_UPLOAD_GUIDE.md`](docs/GITHUB_UPLOAD_GUIDE.md)

---

## 📂 Projektstruktur

```
dixy-rdwc-controller/
├── ESP32-Knoten/                    # ESPHome Konfigurationen
│   ├── hydroknoten.yaml             # EC/pH + Wasserstand
│   ├── dosierung.yaml               # 4x Pumpen + Rührmotor
│   ├── zeltsensor.yaml              # Spektral-Licht + Klima
│   ├── klimaknoten.yaml             # Standalone VPD (Backup)
│   ├── kameraknoten_canopy.yaml     # Timelapse Übersicht
│   └── kameraknoten_detail.yaml     # Blattanalyse
│
├── Home-Assistant/                  # HA Integrationen
│   ├── plant_stress_detector.py     # KI Stress-Analyse
│   ├── timelapse_automation.yaml    # Foto-Automation
│   ├── input_selects.yaml           # Growth Stage + Strategien
│   └── dashboard_code.yaml          # Lovelace UI (6 Tabs)
│
├── scripts/                         # Hilfs-Scripts
│   └── sanitize_credentials.sh      # Credentials für GitHub entfernen
│
├── docs/                            # Dokumentation
│   ├── SECRETS_MANAGEMENT.md        # Passwort-Handling
│   ├── GITHUB_UPLOAD_GUIDE.md       # Upload-Anleitung
│   └── QUICK_START_GITHUB.md        # 5-Min Checkliste
│
├── .gitignore                       # Git Sicherheit
├── secrets.yaml                     # 🔐 LOKAL nur! (nicht in Git)
├── secrets.yaml.example             # Template für Secrets
├── RELEASE_NOTES.md                 # Versions-Changelog
├── README.md                        # Diese Datei
└── LICENSE                          # MIT License
```

---

## 🔐 Sicherheit

### Secrets Management
- **`secrets.yaml`** enthält deine echten Passwörter (LOKAL, NICHT in Git!)
- Alle YAMLs nutzen `!secret` Referenzen statt hardcoded Werte
- `.gitignore` schützt `secrets.yaml` automatisch

```bash
# Lokale Secrets
wifi_ssid: "dixy"
wifi_password: "monochrome1"

# In YAMLs:
password: !secret wifi_password  ← GitHub sieht NUR dies!
```

**⚠️ WICHTIG**: Siehe [`docs/SECRETS_MANAGEMENT.md`](docs/SECRETS_MANAGEMENT.md)

---

## 📚 Dokumentation

| Dokument | Beschreibung |
|----------|-------------|
| [`RELEASE_NOTES.md`](RELEASE_NOTES.md) | Versions-Changelog v0.1-beta |
| [`docs/SECRETS_MANAGEMENT.md`](docs/SECRETS_MANAGEMENT.md) | Passwort-System erklärt |
| [`docs/GITHUB_UPLOAD_GUIDE.md`](docs/GITHUB_UPLOAD_GUIDE.md) | Kompletter Upload-Guide |
| [`docs/QUICK_START_GITHUB.md`](docs/QUICK_START_GITHUB.md) | 5-Min Checkliste |
| [`ESP32-Knoten/README.md`](ESP32-Knoten/README.md) | Hardware-Spezifikationen |

---

## 🐛 Known Issues (v0.1-beta)

- ⚠️ Bildanalyse nicht mit echten Kamera-Bildern getestet
- ⚠️ Wasserverbrauch-Tracking braucht echte Tank-Level-Daten
- ⚠️ Growth Stage Auto-Erkennung braucht echte Light-Schedule-Daten
- ⚠️ ESP32-CAM Flash muss manuell mit FTDI-Adapter erfolgen

---

## 🗺️ Roadmap v0.2-beta+

- [ ] ML-basierte Schädlings-Erkennung (YOLO)
- [ ] Multi-Level Tank-System (mehrere D1CS-D pro Tank)
- [ ] Custom HA Integration (statt install script)
- [ ] Video-Streaming-Optimierung (Lower Latency)
- [ ] Nacht-Modus für Kameras (Red LED)
- [ ] Automatische Growth-Stage-Transition
- [ ] Webhook-Integration für externe APIs

---

## 🤝 Beitragen

Contributions sind willkommen! 

1. **Fork** das Repository
2. **Erstelle** einen Feature Branch (`feature/my-feature`)
3. **Commit** deine Änderungen
4. **Push** zum Branch
5. **Erstelle** einen Pull Request

Siehe auch: [`CONTRIBUTING.md`](CONTRIBUTING.md) (noch zu erstellen)

---

## 📞 Support & Kontakt

- **Issues**: GitHub Issues für Bugs/Feature Requests
- **Diskussionen**: GitHub Discussions für Fragen
- **Dokumentation**: Siehe `/docs` Folder

---

## 📜 Lizenz

Dieses Projekt ist unter der **MIT License** lizenziert - siehe [`LICENSE`](LICENSE) für Details.

---

## 🙏 Credits

- **ESPHome Community** - Sensor & Integration Bibliotheken
- **Home Assistant Team** - Automation & UI Framework
- **OpenCV** - Computer Vision Bildanalyse
- **Micropython Community** - ESP32 Firmware Base

---

## 📊 Projekt-Stats

- **6** ESP32 Knoten
- **11+** Sensoren (EC, pH, Temp, Licht, Klima, Wasser)
- **4** Steuerungspumpen
- **2** Kamera-Module
- **6** Wachstumsstadien
- **100+** Automations-Möglichkeiten

---

**Last Updated**: 06.12.2025  
**Current Version**: v0.1-beta  
**Maintainer**: DiXY RDWC Project

🌱 **Viel Erfolg mit deinem RDWC-System!** 🌱
