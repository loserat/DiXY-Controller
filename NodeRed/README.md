# Node-RED Flows für DiXY-Controller

## Übersicht
Hier befinden sich alle Node-RED Flows für die DiXY-Controller-Umgebung. Die Flows sind in einzelne Test- und Anwendungsbereiche unterteilt:

- `flows-test/01_Sensorwerte.json` – Beispiel-Flow für Sensordaten
- `flows-test/02_Beleuchtung.json` – PWM- und Lichtsteuerung
- `flows-test/x_flows_gemischt_alt..json` – gemischte/ältere Flows

## Nutzung
1. Öffne Node-RED (z.B. über Home Assistant oder Standalone).
2. Importiere die gewünschte Flow-JSON über das Node-RED Menü (Import > Datei).
3. Passe ggf. MQTT-Topics, Home Assistant-Entity-IDs oder Logik an deine Umgebung an.

## Hinweise
- Die Flows sind für die Zusammenarbeit mit ESPHome-Knoten und Home Assistant optimiert.
- Für die Lichtsteuerung kann sowohl MQTT als auch das Home Assistant Plugin genutzt werden.
- Weitere Beispiele und Dokumentation findest du im Haupt-README und in den jeweiligen Flow-Kommentaren.


---

**Hinweis:** Die aktuellen Flows unterstützen sowohl simulierte Dummy-Sensorwerte als auch echte Messwerte. Mit der fertigen PCB werden die Dummy-Flows nicht mehr benötigt.

Letzte Aktualisierung: 18.12.2025
