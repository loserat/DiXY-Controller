MQTT Topic Vorschlag (DiXY)
============================

Prefix: `dixy/`

Setpoints (aus HA-Helpers gespiegelt)
- `dixy/targets/ec` (mS/cm)
- `dixy/targets/ph`
- `dixy/targets/light/on`, `dixy/targets/light/off` (HH:MM)
- `dixy/targets/ppfd` (optional)
- Pumpen: `dixy/targets/pump1/manual_ml` … `pump4/manual_ml`
- Pumpen-Trigger: `dixy/targets/pump1/manual_trigger` … `pump4/manual_trigger`
- Pumpen-Kalibrierung: `dixy/targets/pump1/rate_ml_per_sec` … `pump4/rate_ml_per_sec`
- Auto-Dosis-Schritte: `dixy/targets/pump1/auto_ml` (EC), `pump2/auto_ml` (pH+), `pump3/auto_ml` (pH-)
- Toleranzen: `dixy/targets/ec_tolerance`, `dixy/targets/ph_tolerance`

Sensoren/Istwerte
- `dixy/sensors/ec/state`, `dixy/sensors/ph/state`, `dixy/sensors/temp_water/state`
- `dixy/sensors/temp_air/state`, `dixy/sensors/rh/state`, `dixy/sensors/vpd/state`
- `dixy/sensors/ppfd/state`, `dixy/sensors/dli/state`
- Wasserstand: `dixy/sensors/tanks/1/level` … `/6/level`, `dixy/sensors/tanks/any_empty`
- Plugs (optional Rückmeldung): `dixy/sensors/plugs/<name>/state`, `/power`

Kommandos an Aktoren
- Dosierpumpen: `dixy/dosing/pump1/cmd` … `pump4/cmd` (`{ "ml": <Menge> }`)
- Licht: `dixy/light/cmd` (`"on"`/`"off"` oder `{ "level": 0-100 }`)
- Plugs/Relais: `dixy/plugs/<name>/cmd` (`"on"`/`"off"`)
- Klima (wenn getrennt): `dixy/fans/cmd`, `dixy/humidifier/cmd`, `dixy/heater/cmd`, `dixy/co2/cmd`

Rückmeldungen
- `dixy/ack/pumpX`, `dixy/error/pumpX`
- `dixy/ack/light`, `dixy/error/light`
- `dixy/ack/plugs/<name>`, `dixy/error/plugs/<name>`

Kalibrierung
- `dixy/cal/ec`, `dixy/cal/ph`
- `dixy/cal/pump1_rate` … `pump4_rate` (ml/s, alternativ `targets/*/rate_ml_per_sec`)

Status/Diagnose
- `dixy/status/hydroknoten`, `dixy/status/dosierung`, `dixy/status/zeltsensor`, `dixy/status/klimaknoten`
- Optional: `dixy/log/<component>`
