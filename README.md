# DiXY RDWC Controller

> **Achtung:** Dieses Projekt befindet sich in einer öffentlich einsehbaren Entwicklungsphase und ist noch nicht voll funktionsfähig. Viele Features sind experimentell, Änderungen erfolgen laufend, und ein stabiler Betrieb ist derzeit nicht garantiert. Die Nutzung erfolgt auf eigenes Risiko!

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version: siehe Release Notes](https://img.shields.io/badge/Version-aktuell-blue.svg)](RELEASE_NOTES.md)

---

## Projektübersicht

**DiXY** ist ein modulares Hydroponik‑Steuerungssystem auf Basis von ESP32‑Knoten und Home Assistant.  
Home Assistant dient als UI‑Schicht und Orchestrierung; die Logik liegt in den ESP‑Knoten.

Knotenübersicht (Systemkomponenten):
- Zeltknoten
- Hydroknoten
- Dosierungsknoten
- Weitere Knoten sind vorgesehen (z. B. Klima, Kamera), aber nicht Kern dieses Dokuments

---

## Architektur‑Übersicht

**Zeltknoten**  
Steuert und überwacht die Beleuchtung sowie Umgebungswerte im Zelt.

**Hydroknoten**  
Erfasst EC/pH/Temperatur‑Messwerte und stellt sie für andere Knoten bereit.

**Dosierungsknoten**  
Berechnet Dosierungen lokal und steuert Pumpen/Rührmotor basierend auf Hydroknoten‑Werten.

**Kommunikation**  
Die Knoten kommunizieren über die ESPHome‑API mit Home Assistant.  
Home Assistant übernimmt Anzeige, Historie und Automationen, greift aber nicht in die Kernlogik der Knoten ein.

---

## ESP‑Knoten im Detail

### Zeltknoten
- **Zweck:** Lichtsteuerung und Umgebungsüberwachung.
- **Sensoren/Aktoren:** Klimasensorik (Temperatur, Luftfeuchte, VPD), Lichtsensorik (AS7341‑Spektrum), Lampen‑PWM, Status‑ und Zeit‑Textsensoren.
- **Regelungen:** AUTO/MANUELL‑Priorität, Zeitfenster, SA/SU‑Rampen.
- **Safety‑Mechanismen:** Prioritätsregeln, definierte Default‑Zustände, Diagnose‑Status.
- **Sensorik‑Hinweise:**
  - **Klimasensorik (Temp/RH/VPD):** Überwacht das Zeltklima. VPD ist aus Temp/RH abgeleitet und dient der Einordnung der Klimagüte.
  - **AS7341 Spektrum:** Liefert spektrale Verteilung des Lichts. Dient der Analyse/Überwachung des Lichtspektrums, nicht der direkten Regelung.
  - **Anzeige vs. Regelung:** Klima‑ und Spektrumsensoren sind primär Anzeige/Monitoring; die Lichtsteuerung erfolgt über die definierte AUTO/MANUELL‑Logik.

### Hydroknoten
- **Zweck:** Messwerte für EC, pH und Temperatur bereitstellen.
- **Sensoren/Aktoren:** EC/pH/Temperatur‑Messkanäle, Diagnose‑Infos, Kalibrier‑Buttons.
- **Regelungen:** Messwertbereitstellung, optional Simulation für Tests.
- **Safety‑Mechanismen:** Plausibilisierung, Diagnose‑Status, Verfügbarkeit für andere Knoten.
- **Mess‑Referenz für Dosierung:**
  - **EC‑ & pH‑Messung:** Liefert die Referenzwerte für die Dosierungslogik. Die Dosierung nutzt diese Werte direkt und berechnet daraus die Korrekturen.
  - **Wassertemperatur:** Dient der Einordnung der Messwerte und der Systemstabilität.
  - **Systemvolumen:** Wird als Grundlage für die ml‑Berechnung in der Dosierung verwendet (Skalierung der Wirksamkeit pro ml/100L).
  - **Warum keine Sensoren im Dosierungsknoten:** Die Dosierung ist bewusst ohne eigene EC/pH‑Sensorik ausgelegt, um eine einzige Mess‑Referenz zu erzwingen und Messwert‑Drift zwischen Knoten zu vermeiden.
  - **Ausfallsicherheit:** Ist der Hydroknoten nicht erreichbar oder liefert NaN‑Werte, blockiert die Dosierung automatisch.
  - **Sicherheitsrelevant:** EC‑Ist, pH‑Ist, Systemvolumen und Verfügbarkeit des Hydroknotens.

### Dosierungsknoten
- **Zweck:** Dosierung von Nährstoffen und pH‑Korrektur.
- **Sensoren/Aktoren:** Pumpen‑Outputs, Rührmotor, Status‑ und Debug‑Sensoren.
- **Regelungen:** Sequenzielle Dosierung, EC‑Verteilung, pH‑Korrektur.
- **Safety‑Mechanismen:** Tageslimits, Max‑Dosis pro Zyklus, Rührzeit‑Sperre, Offline‑Blockierung.
- **Pumpenrollen:**
  - **Pumpe A–C:** EC‑Dünger (Teilnahme an der EC‑Verteilung)
  - **Pumpe D:** fest als **pH Down** definiert
- **EC‑Verteilungslogik:** EC‑Differenz wird ausschließlich auf Pumpen A–C verteilt. Pumpe D ist davon ausgeschlossen.
- **Rührzeit‑Management:** Nach jeder Dosierung wird eine Rührzeit erzwungen; während dieser Zeit sind weitere Dosierungen blockiert.
- **Safety‑Limits:** Max‑Dosis pro Zyklus, Tageslimits pro Pumpe und Blockierung bei Hydroknoten‑Offline.

**Ablauf eines Dosierzyklus (kurz):**
1. Safety‑Checks (Hydroknoten online, Rührzeit abgelaufen, Limits ok)
2. EC‑Berechnung (A–C) oder pH‑Korrektur (D)
3. Pumpe läuft für berechnete Zeit
4. Rührmotor aktiviert → Sperrzeit

**Blockierungsgründe (typisch):**
- Hydroknoten offline / ungültige Messwerte  
- Rührzeit noch nicht abgelaufen  
- Tageslimit erreicht  
- Max‑Dosis pro Zyklus erreicht

**Diagnose‑Textsensoren:**
- Status (EC und pH getrennt)
- Blockgrund (EC und pH getrennt)
- Rührzeit‑ und Timing‑Sensoren (z. B. verbleibende Sperrzeit)

---

## Versionshinweis

Aktueller Stand: **v0.x (beta)**  
Änderungen sind im **CHANGELOG** dokumentiert.  
Zusätzliches Projekt‑Tracking in [RELEASE_NOTES.md](RELEASE_NOTES.md).

---

## Hinweise

- Dieses README ersetzt keine Konfigurationsanleitung.
- Detaillierte Anleitungen und technische Details: `docs/`, `QUICKSTART.md`.
