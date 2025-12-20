# DiXY RDWC Controller

> **Achtung:** Dieses Projekt befindet sich in einer öffentlich einsehbaren Entwicklungsphase und ist noch nicht voll funktionsfähig. Viele Features sind experimentell, Änderungen erfolgen laufend, und ein stabiler Betrieb ist derzeit nicht garantiert. Die Nutzung erfolgt auf eigenes Risiko!

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version: siehe Release Notes](https://img.shields.io/badge/Version-aktuell-blue.svg)](RELEASE_NOTES.md)

---

## Gesamtprojektübersicht

**DiXY** ist ein modulares Hydroponik-Steuerungssystem auf Basis von ESP32-Knoten und Home Assistant. Ziel ist die flexible, skalierbare Steuerung und Überwachung von Hydroponik-Anlagen mit Fokus auf Transparenz, Erweiterbarkeit und Open-Source-Ansatz.

- **Modulare Architektur:** Jeder Knoten übernimmt eine klar definierte Aufgabe (z.B. Klima, EC/pH, Dosierung, Kamera).
- **Home Assistant Integration:** Zentrale Visualisierung, Automatisierung und Historie.
- **ESPHome:** Firmware-Basis für alle Knoten, einfache Anpassung per YAML.
- **Node-RED:** Optionale Automatisierungs- und Logikschicht für komplexe Abläufe.

---

## Knotentypen & Aufgaben

| Knoten         | Aufgabe/Beschreibung                                                                 |
|---------------|--------------------------------------------------------------------------------------|
| **Zeltknoten**      | Klima- und Lichtsensorik, Lichtsteuerung, VPD, Spektrum, Statusdiagnose                |
| **Hydroknoten**     | EC/pH/Temperatur-Messung, Referenz für Dosierung, Kalibrierung, Systemvolumen         |
| **Dosierungsknoten**| Nährstoff- und pH-Dosierung, Pumpensteuerung, Tageslimits, Rührzeitmanagement         |
| **Kameraknoten**    | (optional) Timelapse, Blattanalyse, Bildübertragung                                   |
| **Klimaknoten**     | (optional) Relaissteuerung, VPD-Regelung, Klimaüberwachung                            |
| **Node-RED**        | (optional) Erweiterte Automatisierung, Flow-Logik, MQTT-Integration                   |

---

## Kommunikationsüberblick

- **ESPHome API:** Hauptkommunikation zwischen Knoten und Home Assistant (sicher, verschlüsselt, bidirektional)
- **MQTT (optional):** Für Node-RED, externe Tools oder Integrationen
- **Home Assistant API:** Visualisierung, Automatisierung, Dashboard
- **Keine direkte Knoten-zu-Knoten-Kommunikation:** Alle Daten laufen über Home Assistant

---

## Dokumentation & Changelog

- **Detaillierte Änderungen, Bugfixes und Roadmap:** Siehe [RELEASE_NOTES.md](RELEASE_NOTES.md)
- **Knoten-spezifische Sensoren und Entitäten:** Siehe jeweilige YAML-Dateien und SENSORS.md pro Knoten
- **Node-RED Flows und Automationen:** Siehe Verzeichnis `NodeRed/` und `proposals/`

---

## Hinweise

- Dieses Projekt ist in aktiver Entwicklung. Funktionen, Schnittstellen und YAML-Struktur können sich ändern.
- Für Fragen, Issues oder Beiträge: Siehe GitHub-Issues oder erstelle einen Pull Request.
