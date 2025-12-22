# CHANGELOG

## v2.8 (beta) – Zeltsensor (Datum: 2025-12-22)
Verglichen mit Version: v2.7  
Entwicklungsstatus: aktiv (beta), keine Stabilitätsgarantie.

### Änderungen & Erweiterungen
- ➕ Neue Status‑Textsensoren für Modus/Phase/SA‑SU/AUTO‑Zeiten.
- ➕ AUTO‑Zeitübernahme über `input_datetime`‑Attribute (hour/minute) statt String‑Parsing.
- ➖ Entfernte SA/SU‑Startzeit‑Slider (Minuten).
- 🔄 SA/SU‑Phasenberechnung relativ zum AUTO‑Zeitfenster mit Überlappungsschutz.
- ➕ Lokales Web‑Dashboard (Anzeige‑Only).
- ➕ CO2‑Regelung (Sollwert + Hysterese) mit Automatik‑Schalter und Ausgang.
- ➕ CO2‑Differenz‑Textsensor (Sollwert‑Abweichung).
- 🔄 CO2‑Simulation reagiert auf Dosierung (mit Ausklingen; später Hardware‑Ersatz).
- 🔧 Logger auf INFO gesetzt.
- 🔄 CO2‑Dosierung jetzt in einstellbaren Stößen (Stoßdauer = Wartezeit).

### Added
- Textsensoren: `AUTO Einschaltzeit`, `AUTO Ausschaltzeit`, `Geraetename`,
  `Zeltlampe Modus`, `Zeltlampe Aktuelle Phase`, `SA/SU Status`,
  `SA Startzeit`, `SU Startzeit`.
- Webserver für lokales Dashboard.
- Interne HA‑Zeit‑Eingänge (hour/minute) zur Minutenbasis‑Übernahme.
- CO2‑Automatik: `CO2 Automatik`, `CO2 Dosierung`, `CO2 Sollwert`, `CO2 Hysterese`.
- Textsensor: `CO2 Differenz Sollwert`.
- Number: `CO2 Dosierstoßdauer`.

### Changed
- SA/SU‑Startzeiten werden nur noch angezeigt (Automatik‑Status), keine Eingabe‑Slider.
- SA/SU‑Phasenlogik an das AUTO‑Zeitfenster gekoppelt.
- AUTO‑Zeitübernahme ohne Text‑Parsing.
- CO2‑Simulation mit schnellerem Verlauf und Dosier‑Offset.

### Fixed
- Keine dokumentierten Änderungen.

### Nicht geändert
- Licht‑Entität, AUTO/MANUELL‑Schalter und SA/SU‑Dauer‑Slider bleiben erhalten.

## v1.2 (beta) – Tankknoten (Datum: 2025-12-22)
Verglichen mit Version: v1.1  
Entwicklungsstatus: aktiv (beta), keine Stabilitätsgarantie.

### Änderungen & Erweiterungen
- ➕ Manuelle Level‑Eingänge (Level 1–6) als Schalter.
- ➕ Füllstand in L/% aus Level‑Eingängen berechnet.
- ➕ Befüll‑Taster (Start/Stop) für Haupttank und RDWC.
- ➕ Not‑Aus und Leckage‑Kontakt integriert.
- ➕ Zeitstempel: letzter Voll‑ und Leer‑Stand pro Tank.

### Added
- Textsensoren: `Tankregelung RDWC Version`, `Tankregelung Haupttank Version`.
- Zeitstempel‑Sensoren: `Haupttank Zuletzt Voll/Leer`, `RDWC Zuletzt Voll/Leer`.

### Changed
- Versionswerte in HA mit `v`‑Prefix.

### Fixed
- Keine dokumentierten Änderungen.

## v2.7 (experimentell) – Dosierungsknoten (Datum: 2025-12-22)
Verglichen mit Version: v2.6  
Entwicklungsstatus: experimentell, nicht kalibriert.

### Added
- Tag/Nacht‑Statusanzeige (Quelle: Zeltlampe).
- Blockgrund‑Texte für Nachtphase (EC/pH).
- Textsensoren: `Dosierung Version`, `pH Regelung Version`.

### Changed
- Automatik startet Dosierungen nur in Tagphase.
- EC‑ und pH‑Dosierung stoppen in der Nachtphase.
- Versionswerte in HA mit `v`‑Prefix.

### Fixed
- Keine dokumentierten Änderungen.

### Nicht geändert
- Sicherheitslogik, Limits und Pumpen‑Zuweisung bleiben unverändert.

## v2.7 (beta) – Zeltsensor (2025-12-19)
### Added
- State‑Machine für Lichtsteuerung (MANUAL/AUTO/SA/SU) vollständig auf ESP verlagert.
- Persistente Parameter für Lichtprofile und Rampen.

### Changed
- Home‑Assistant‑Entitäten für Modus und Parameter.

### Fixed
- Fehlerbehandlung und Robustheit verbessert.

## v2.6 (beta) – Zeltsensor (2025-12-18)
### Added
- `entity_category: diagnostic` für Versions‑Textsensor ergänzt.

### Changed
- YAML‑Struktur und Kommentare überarbeitet.

### Fixed
- Bugfixes bei der Modusumschaltung und Rampenlogik.

## v2.5 (beta) – Zeltsensor (Zusammenfassung v2.2–v2.5)
### Added
- Keine dokumentierten Änderungen.

### Changed
- Diverse Verbesserungen an Dummy‑Sensoren, Zeitsteuerung und YAML‑Struktur.
- Versionierung und Dokumentation konsolidiert.

### Fixed
- Keine dokumentierten Änderungen.

### Notes
- Zwischenstände v2.2–v2.5 sind in den Release Notes nur zusammengefasst dokumentiert.

## v2.4 (beta) – Dosierungsknoten (Datum: 2025-12-22)
Verglichen mit Version: v2.3  
Entwicklungsstatus: aktiv (beta), keine Stabilitätsgarantie.

### Änderungen & Erweiterungen
- 🔄 Dosierabläufe aus blockierenden Lambdas in nicht‑blockierende Script‑Schritte verlagert.
- 🔄 EC‑Dosierung prüft nach jeder Rührzeit erneut den Zielwert.
- 🔄 pH‑Dosierung nutzt denselben Pumpenlauf‑Ablauf wie EC.
- 🔧 Minimale Rührzeiten (zwischen Dosierungen und Rührmotor‑Dauer) auf 1 s gesetzt.

### Added
- Internes `run_pump`‑Script für sequenzielles Pumpen‑Timing und Zähler‑Updates.
- Interne Laufvariablen für Pumpenlauf, Dosis‑Menge und Dosierart.

### Changed
- EC‑Verteilung und Pumpenlauf werden schrittweise mit Zwischen‑Checks ausgeführt.
- pH‑Dosierung verwendet die gleiche nicht‑blockierende Pumpenlogik.
- Mindestwerte für Rührzeit‑Parameter reduziert.

### Fixed
- Keine dokumentierten Änderungen.

### Nicht geändert
- Entitäten, IDs und Pumpen‑Zuordnung bleiben unverändert.

## v2.5 (beta) – Hydroknoten (Datum: 2025-12-22)
Verglichen mit Version: v2.4  
Entwicklungsstatus: aktiv (beta), keine Stabilitätsgarantie.

### Added
- `Hydroknoten Temperatur Offset` (korrigiert die Wassertemperatur).

### Changed
- Versionswerte in HA mit `v`‑Prefix.

### Fixed
- Keine dokumentierten Änderungen.

## v2.3 (experimentell) – Hydroknoten (Datum: 2025-12-22)
Verglichen mit Version: v2.2  
Entwicklungsstatus: experimentell, nicht kalibriert.

### Änderungen & Erweiterungen
- ➕ Dosierungs‑Modulator: kleiner, gedämpfter Offset auf bestehende EC/pH‑Simulation.
- 🔄 Reaktion auf Dosierungen des Dosierungsknotens über Tages‑ml‑Werte.
- ⏱ Ausklingen des Effekts über Zeit (kein dauerhafter Drift).

### Added
- Interne Eingänge für Tages‑ml‑Zähler (Micro/Grow/Bloom/pH Down).
- Interne Offset‑Variablen für EC/pH‑Modulation.

### Changed
- Simulierter EC/pH‑Wert erhält einen kleinen Zusatz‑Offset nach Dosierungen.

### Fixed
- Keine dokumentierten Änderungen.

### Nicht geändert
- Bestehende Simulationslogik (Sinus) bleibt vollständig erhalten.
- Sensor‑Namen und Entitäten bleiben unverändert.

### Notes
- Simulation ist ein Debug‑/Visualisierungswerkzeug und kein Ersatz für echte Sensorik.

## v2.2 (beta) – Hydroknoten (Datum: 2025-12-22)
Verglichen mit Version: v2.1  
Entwicklungsstatus: aktiv (beta), keine Stabilitätsgarantie.

### Änderungen & Erweiterungen
- 🔄 Simulationswerte (EC/pH/Temperatur) laufen sinusförmig über 1 Stunde.
- ⏱ Update‑Intervall der Simulationssensoren auf 60 s gesetzt.

### Added
- Keine neuen Entitäten.

### Changed
- EC/pH/Temperatur‑Simulation von Zufallswerten auf Sinus‑Verlauf umgestellt.

### Fixed
- Keine dokumentierten Änderungen.

### Nicht geändert
- Entitätenliste und Home‑Assistant‑Sichtbarkeit bleiben unverändert.

## v0.2 (alpha) – Repository‑Konsolidierung (2025-12-14)
### Added
- Dummy‑Sensoren und Dummy‑Buttons für Home Assistant hinzugefügt.

### Changed
- YAML‑Struktur bereinigt (Indents, Blockstruktur, Duplikate entfernt).
- Versionsnummern in YAMLs und Loggern konsolidiert.
- README/Changelog für Hydroknoten und Zeltsensor ergänzt.

### Fixed
- Problematische Komponenten (uptime, status) entfernt (ESPHome‑Linkerfehler).

## v0.1 (alpha) – Baseline Release (2025-12-08)
### Added
- Hydroknoten (EC/pH/Temperatur + Tank‑Levels).
- Dosierungsknoten (4× Pumpen + Rührmotor).
- Zeltsensor (AS7341‑Spektrum + Klima‑Monitoring).
- Klimaknoten (VPD + 4× Relais).
- Kameraknoten (Canopy + Detail‑Timelapse).

### Changed
- Dokumentation und Entitätenstruktur für Home Assistant aufgebaut.
- MQTT‑Discovery‑Struktur dokumentiert.
- Versionssynchronisierung über Komponenten hinweg dokumentiert.

### Fixed
- Keine dokumentierten Änderungen.

### Notes
- Node‑RED‑Flows in `proposals/` benötigen Validierung.
- HACS‑Integration ist nicht umgesetzt.
- Flash‑Wizard‑Script fehlt.
- Docker‑Compose‑Stack ist nicht vorhanden.
