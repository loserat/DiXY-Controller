# Node-RED Vorschläge (DiXY)

Dieses Verzeichnis enthält importierbare Node-RED-Flow-Dateien als Vorlage. Bestehende Projektdateien werden nicht verändert.

## Dateien
- `flows_dosing.json`: Targets/Sensoren → MQTT Spiegel + einfache EC/pH-Dosierlogik (Hysterese, Tank-Check, Auto-ML-Schuss, manuelle Shots).
- `flows_lighting.json`: Basis-Lichtsteuerung (Zeitfenster, Manuell/Auto, PPFD-Hysterese) mit `dixy/light/cmd`.
- `flows_lighting_sunfade.json`: Erweiterte Lichtsteuerung mit Sunrise/Sunset (sensor.sun_* + Offset), Fade (1–30 Min einstellbar), Manuell/Auto/PPFD-Modus.
- `flows_ack_error.json`: MQTT-Listener für `dixy/ack/#` und `dixy/error/#` mit Debug-Ausgabe.

## Voraussetzungen (HA Entities)
- Setpoints/Helper (siehe `proposals/ha_helpers.yaml`): u. a. `input_select.light_mode`, `input_datetime.light_manual_on_time/off_time`, `input_number.light_manual_intensity`, `input_number.light_auto_sunrise_offset`, `input_number.light_auto_sunset_offset`, `input_number.light_fade_duration`, `input_number.light_ppfd_*`, Pumpen-Setpoints.
- Sensoren/Aktoren: `sensor.zeltsensor_ppfd`, `number.zeltsensor_v2_light_intensity`, `sensor.hydroknoten_ec_wert`, `sensor.hydroknoten_ph_wert`, Tank-Binary-Sensoren.
- MQTT-Broker: Bitte in jedem Flow den Broker-Node auf deine Instanz setzen.

## MQTT-Konvention
- Targets: `dixy/targets/...`
- Sensoren: `dixy/sensors/...`
- Kommandos: `dixy/dosing/pumpX/cmd` (`{ "ml": <Menge> }`), `dixy/light/cmd` (`"off"` oder `{ "level": 0-100 }`)
- Rückmeldungen: `dixy/ack/#`, `dixy/error/#`

## Nutzung
1. HA-Helpers laut `proposals/ha_helpers.yaml` anlegen.
2. Passende Flow-Datei in Node-RED importieren.
3. Broker-Node und HA-Server-Node im Flow konfigurieren.
4. Optional: Acks/Errors weiterverarbeiten (Notify/HA-Sensor) statt nur Debug.
