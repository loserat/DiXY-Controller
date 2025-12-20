# DiXY RDWC Controller

> **Achtung:** Dieses Projekt befindet sich in einer öffentlich einsehbaren Entwicklungsphase und ist noch nicht voll funktionsfähig. Viele Features sind experimentell, Änderungen erfolgen laufend, und ein stabiler Betrieb ist derzeit nicht garantiert. Die Nutzung erfolgt auf eigenes Risiko!

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version: siehe Release Notes](https://img.shields.io/badge/Version-aktuell-blue.svg)](RELEASE_NOTES.md)

---

## Projektüberblick

**DiXY** ist ein modulares, DIY-freundliches Hydroponik-Steuerungssystem für Home Assistant und ESP32.

- 6 spezialisierte ESP32-Knoten (Hydro, Dosierung, Klima, Zelt, Kamera)
- Home Assistant Integration (MQTT, Automationen, Dashboard)
- KI-Features sind vorbereitet, aber noch nicht Teil des aktuellen Systems (geplant für spätere Versionen)

---

## Quickstart

1. Repository klonen:
   ```bash
   git clone https://github.com/loserat/DiXY-Controller.git
   cd DiXY-Controller
   bash scripts/setup.sh
   ```
2. Lies die Hinweise in [RELEASE_NOTES.md](RELEASE_NOTES.md) für alle aktuellen Änderungen, ToDos und den täglichen Fahrplan.
3. Folge der Anleitung in [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) für die vollständige Einrichtung.

---


## Hinweise

- **Alle Änderungen, Bugfixes, Roadmap und ToDos findest du ab sofort ausschließlich in [RELEASE_NOTES.md](RELEASE_NOTES.md).**
- Für detaillierte Anleitungen siehe [docs/](docs/) und [QUICKSTART.md](QUICKSTART.md).
- **Hinweis:** Alle Dummy-Sensorwerte (Simulation) werden mit der fertigen PCB durch echte Messwerte ersetzt. Die Simulation entfällt dann vollständig.
