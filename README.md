# DiXY Controller

Entwicklungsstatus: Dieses Projekt befindet sich in aktiver Entwicklung. APIs, Entitäten,
Logik und Struktur können sich jederzeit ändern. Es gibt keine Garantie auf Stabilität
oder Produktionsreife.

## Projektübersicht (DiXY Controller)
DiXY ist ein ESPHome‑basiertes Multi‑Knoten‑System für Grow‑Umgebungen.
Die Logik läuft primär lokal auf den ESP‑Knoten; Home Assistant dient als UI,
Monitoring‑Schicht und (wo vorhanden) Orchestrierungsebene.

Visuelle Übersicht (optional): Platzhalter für Dashboard/GIF‑Link (optional)

## Was hat sich seit der letzten Version geändert?
Hinweis: Das Projekt ist in aktiver Entwicklung; Änderungen sind nicht
abwärtskompatibel garantiert.

### Zeltknoten (v2.8 vs v2.7)
- Neue Status‑Textsensoren für Modus, Phase, SA/SU‑Status und AUTO‑Zeiten.
- AUTO‑Zeitübernahme über `input_datetime`‑Attribute (hour/minute);
  SA/SU‑Startzeit‑Slider entfernt.
- Lokales Web‑Dashboard für Anzeige‑Only ergänzt.

### Hydroknoten (v2.3 vs v2.2)
- Experimenteller Zusatz‑Offset auf den bestehenden EC/pH‑Simulationen nach Dosierungen.
- Modulation ist gedämpft und klingt aus; die Basis‑Simulation bleibt unverändert.
- Warnung: Simulation nur für Entwicklung/Debug, nicht für reale Nährstoffsteuerung.

### Dosierknoten (v2.4 vs v2.3)
- Dosierabläufe auf nicht‑blockierende Script‑Schritte umgestellt.
- EC‑Dosierung prüft nach jeder Rührzeit erneut den Zielwert.
- pH‑Dosierung nutzt denselben Pumpenlauf‑Ablauf wie EC.
- Minimale Rührzeiten auf 1 s gesetzt.

## Architektur & Philosophie
- Mehrere spezialisierte ESP32‑Knoten mit klar getrennten Aufgaben.
- Lokale Berechnung und Steuerung auf den Knoten, um Abhängigkeiten zu reduzieren.
- Home Assistant als zentrale Anzeige‑ und Integrationsschicht.
- Datenflüsse sind transparent und über dokumentierte Entitäten nachvollziehbar.

## Knotenübersicht
### Zeltknoten (Zeltsensor) – Status: beta
Mess‑ und Anzeige‑Knoten für Spektrum, Klima und Lichtlogik im Zelt.

### Hydroknoten – Status: beta
Mess‑Knoten für EC/pH/Wassertemperatur und Tank‑Füllstände.

### Dosierknoten – Status: beta
Autarke EC‑ und pH‑Dosierung mit Sicherheits‑ und Sequenzlogik.

Weitere Knoten (vorhanden/experimentell):
- Klimaknoten (VPD‑Regelung, Relais‑Steuerung)
- Kameraknoten (Timelapse, Bildanalyse)
- SOG‑Knoten (Wuchs‑Messung, Grundgerüst)
- Simulation (Test‑Knoten)

## Funktionen je Knoten
### Zeltknoten
- Spektral‑Lichtsensorik (AS7341), PPFD/Lux/DLI‑Berechnung.
- Klima‑Monitoring (Temperatur, Luftfeuchte, VPD).
- Optional: CO2‑Messung, Blatt‑Temperatur, PWM‑Lichtsteuerung.

### Hydroknoten
- EC‑Messung, pH‑Messung, Wassertemperatur.
- 6× Tank‑Füllstand (digitale Level‑Sensoren).
- Lokale Kalibrierungen für EC/pH.
- Simulationen können experimentell moduliert werden (nur Test/Debug).

### Dosierknoten
- EC‑Verteilungslogik für Dünger‑Pumpen A–C.
- pH‑Down‑Korrektur über Pumpe D.
- Sequenzielle Dosierung mit Rührzeit und Sperrlogik.
- Safety‑Limits (Max/Zyklus, Max/Tag) und Blockiergründe.

## Sicherheitskonzepte
- Keine parallelen Dosierungen; Ablauf strikt sequenziell.
- Rührzeit blockiert weitere Dosierungen bis zum Ablauf.
- Tages‑ und Zyklus‑Limits verhindern Überdosierung.
- Dosierung blockiert bei fehlenden/ungültigen Messwerten.

## Abhängigkeiten
- Home Assistant (ESPHome‑Integration, Dashboards, optional Automationen).
- ESPHome (Firmware‑Build und OTA‑Update der Knoten).
- Lovelace Custom Cards (aus Dashboards im Repository):
  - `mini-graph-card`
  - `mushroom` (z. B. `mushroom-number-card`, `mushroom-light-card`)
  - `time-picker-card`
  - `as7341-spectrum-card`
- Optional: Node‑RED (Flows in `NodeRed/`).
- Datenquelle für Dosierung: Hydroknoten (EC/pH) + Systemvolumen aus HA.
- Referenz: `docs/ha_entitaeten.md` (vollständige Entitätenliste).

## Installation (Kurzform, keine Tutorials)
- ESPHome‑YAMLs aus `ESP32-Knoten/` flashen und in HA registrieren.
- Home‑Assistant‑Dateien aus `Home-Assistant/` optional einbinden (Dashboards, Inputs).
- Secrets und Zugangsdaten gemäß `README_SECRETS.md` pflegen.

## Versionsstrategie
- Projektstand: v0.x (beta).
- Knoten haben eigene Versionsstände in den YAML‑Dateien.
- Änderungen sind im `CHANGELOG.md` nachvollziehbar dokumentiert.

## Lizenz / Hinweise
- Lizenz siehe `LICENSE`.
- Sicherheitskritisches System: Änderungen dokumentieren und nachvollziehbar testen.
