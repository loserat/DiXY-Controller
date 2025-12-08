Beleuchtungssteuerung – benötigte HA-Entities
=============================================

Bereits im Projekt vorhanden (siehe `Home-Assistant/input_numbers.yaml`, `input_datetimes.yaml`, `input_selects.yaml`):
- `input_select.light_mode` (Aus / Manuell / Auto (Sonnenauf-/untergang) / PPFD-Regelung)
- `input_datetime.light_manual_on_time`, `input_datetime.light_manual_off_time`
- `input_number.light_manual_intensity`
- `input_number.light_fade_duration` (optional, im Vorschlag nicht genutzt)
- `input_number.light_auto_sunrise_offset`, `input_number.light_auto_sunset_offset` (optional, im Vorschlag nicht genutzt)
- `input_number.light_ppfd_target`
- `input_number.light_ppfd_min_percent`
- `input_number.light_ppfd_max_percent`
- `input_number.light_ppfd_hysteresis`

Sensor/Aktor (bereits referenziert im Projekt):
- `sensor.zeltsensor_ppfd` (Ist-PPFD)
- `number.zeltsensor_v2_light_intensity` (Dimmer-Intensität des Lichts, 0–100)
- Optional Switch/Light-Entity: `light.zeltsensor_wachstumslicht` (oder via MQTT `dixy/light/cmd`)

MQTT-Topics (aus dem Vorschlag):
- Setpoints: `dixy/targets/light/on`, `dixy/targets/light/off`, `dixy/targets/ppfd`
- Commands: `dixy/light/cmd` (`\"off\"` oder `{ \"level\": 0-100 }`)
- Sensors: `dixy/sensors/ppfd/state`, `dixy/sensors/light_intensity/state` (falls gespiegelt)
