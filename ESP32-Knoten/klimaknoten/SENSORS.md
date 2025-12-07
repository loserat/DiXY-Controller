# Klimaknoten v2 – Sensor & Relay Dokumentation

## Sensoren (Identisch Zeltsensor)

| Entity ID | Bereich | Update |
|-----------|---------|--------|
| `sensor.klimaknoten_v2_lufttemperatur` | -20–80°C | 30s |
| `sensor.klimaknoten_v2_luftfeuchte` | 0–100% RH | 30s |
| `sensor.klimaknoten_v2_blatt_temp` | -20–85°C | 10s |
| `sensor.klimaknoten_v2_luftdruck` | 300–1100 hPa | 60s |
| `sensor.klimaknoten_v2_vpd` | 0–5 kPa | 30s |
| `sensor.klimaknoten_v2_taupunkt` | °C | 30s |

---

## Relay-Steuerung

### Befeuchter (Humidifier)

**Entity ID:** `switch.klimaknoten_v2_humidifier`
- GPIO: 16, Active HIGH
- Trigger: RH < target – 5%
- Reset: RH > target + 5% (Hysterese)
- Min. Verzögerung: 5min

### Entfeuchter (Dehumidifier)

**Entity ID:** `switch.klimaknoten_v2_dehumidifier`
- GPIO: 17, Active HIGH
- Trigger: RH > target + 5%
- Reset: RH < target – 5%
- Min. Verzögerung: 5min

### Heizung (Heater)

**Entity ID:** `switch.klimaknoten_v2_heater`
- GPIO: 18, Active HIGH
- Trigger: T < target – 1°C
- Reset: T > target + 1°C
- Min. Verzögerung: 5min

### Umluft-Fan (Circulation)

**Entity ID:** `switch.klimaknoten_v2_circulation_fan`
- GPIO: 19, Active HIGH
- Trigger: Immer AN wenn kein anderer Betriebszustand
- Oder: Manual Toggle

---

## VPD-Regelungs-Logik

```
Zielwerte (HA Slider):
- target_vpd: 1.0 kPa
- target_temp: 24°C
- target_humidity: 65% RH

Ablauf:
1. Berechne VPD aus aktueller T + RH
2. Wenn VPD < target – 0.2 → Befeuchter EIN
3. Wenn VPD > target + 0.2 → Entfeuchter EIN
4. Wenn T < target – 1 → Heizung EIN
5. Wenn T > target + 2 → Fan EIN
```

---

## Setpoints (Number Slider)

| Entity ID | Bereich | Unit | Persistiert |
|-----------|---------|------|-------------|
| `number.klimaknoten_v2_target_vpd` | 0.5–2.0 | kPa | ✅ |
| `number.klimaknoten_v2_target_temp` | 15–30 | °C | ✅ |
| `number.klimaknoten_v2_target_humidity` | 30–90 | % RH | ✅ |
| `number.klimaknoten_v2_min_fan_interval` | 5–30 | min | ✅ |

---

## Automation-Beispiele

### Heizung Nachtmodus

```yaml
automation:
  - alias: "Heizung Nachtmodus (20°C statt 24)"
    trigger:
      platform: time
      at: "20:00:00"
    action:
      - service: number.set_value
        target:
          entity_id: number.klimaknoten_v2_target_temp
        data:
          value: 20

  - alias: "Heizung Tag (24°C)"
    trigger:
      platform: time
      at: "06:00:00"
    action:
      - service: number.set_value
        target:
          entity_id: number.klimaknoten_v2_target_temp
        data:
          value: 24
```

### Alarm bei VPD-Extremen

```yaml
automation:
  - alias: "VPD zu hoch – Klimanotfall"
    trigger:
      platform: numeric_state
      entity_id: sensor.klimaknoten_v2_vpd
      above: 2.0
      for: "00:05:00"
    action:
      - service: switch.turn_on
        target:
          entity_id: switch.klimaknoten_v2_circulation_fan
      - service: notify.telegram
        data:
          message: "🚨 KLIMANOTFALL: VPD {{ states('sensor.klimaknoten_v2_vpd') }} kPa"
```

---

## Health Checks

| Entity ID | Device Class |
|-----------|--------------|
| `binary_sensor.klimaknoten_v2_sht31_ok` | `problem` |
| `binary_sensor.klimaknoten_v2_mlx_ok` | `problem` |
| `binary_sensor.klimaknoten_v2_bmp280_ok` | `problem` |

---

## Performance

| Vorgang | Zyklus |
|---------|--------|
| Sensor Abfrage | 30s (Temp/RH), 10s (Blatt) |
| VPD Berechnung | 30s |
| Relay Schalten | Nach Hysterese-Trigger |
| Min. Schalt-Intervall | 5min (verhindert Verschleiß) |

