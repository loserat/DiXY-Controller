# Dosierung v2 – Sensor & Control Dokumentation

Detaillierte Übersicht der Pumpen-Steuerung, Sensoren, MQTT-Integration und Scripts.

## Pumpen-Steuerung

### 4x Peristaltik-Pumpen

| Entity ID | Pumpe | Funktion | GPIO | PWM Freq | Bemerkung |
|-----------|-------|----------|------|----------|-----------|
| `switch.dosierung_v2_pumpe_a_stoss` | A | EC-Dünger | 25 | 1000 Hz | Quick 10s Shot @75% |
| `switch.dosierung_v2_pumpe_b_stoss` | B | pH Down | 26 | 1000 Hz | – |
| `switch.dosierung_v2_pumpe_c_stoss` | C | pH Up | 27 | 1000 Hz | – |
| `switch.dosierung_v2_pumpe_d_stoss` | D | Additive | 16 | 1000 Hz | – |

**Script: `dose_pump(pump, duration_ms, power_pct)`**

```yaml
script:
  - id: dose_pump
    parameters:
      pump: string
      duration_ms: int
      power_pct: int
    then:
      # Safety Checks
      - if id(any_tank_empty).state: return  # Blockiert
      - if duration_ms <= 0: return
      - clamp duration_ms to max 30000
      - clamp power_pct to 0–100
      
      # PWM-Output setzen
      - set_level(<pump_pwm>, power_pct / 100)
      - delay(duration_ms)
      - set_level(<pump_pwm>, 0)  # Stop
      
      # Response
      - publish to dixy/${device_name}/state/last_dose
      - update global pump_*_total_ml_today
```

**Pump Duration Limits (Safety):**
- Minimum: 1 ms
- Maximum: 30.000 ms (30 Sekunden)
- Default (Quick Shot): 10.000 ms
- Default Power: 75%

---

### Pump Current Verification (Optional)

| Entity ID | Pump | ADC Pin | Conversion | Bekannte Fehler |
|-----------|------|---------|------------|-----------------|
| `sensor.dosierung_v2_pumpe_a_current` | A | GPIO34 | 0.185 A/V | > 100mA = running |
| `sensor.dosierung_v2_pumpe_b_current` | B | GPIO35 | 0.185 A/V | – |
| `sensor.dosierung_v2_pumpe_c_current` | C | GPIO36 | 0.185 A/V | – |
| `sensor.dosierung_v2_pumpe_d_current` | D | GPIO37 | 0.185 A/V | – |

**Hardware:** ACS712-5A Current Sensor (hall-effect)
- Output: 2.5V (0A) + proportional
- Sensitivity: 185 mV/A
- Conversion: `(raw_voltage - 2.5) * 1000 / 185 = Ampere`

**Binary Sensor (Verified Running):**

| Entity ID | Logik | Update |
|-----------|-------|--------|
| `binary_sensor.dosierung_v2_pumpe_a_running_verified` | current > 0.1A | 1s, debounce 500ms |
| `binary_sensor.dosierung_v2_pumpe_b_running_verified` | current > 0.1A | – |
| `binary_sensor.dosierung_v2_pumpe_c_running_verified` | current > 0.1A | – |
| `binary_sensor.dosierung_v2_pumpe_d_running_verified` | current > 0.1A | – |

**Troubleshooting ACS712:**
- Ruhespannung sollte ~2.5V sein
- Bei vollständig geloadenem Test: +5A → ~2.925V, -5A → ~2.075V
- Wenn immer 0A: Sensor nicht angesteckt, ADC falsch, oder Pump nicht laufen

---

## Rührmotor-Steuerung

| Entity ID | Typ | GPIO | Funktion |
|-----------|-----|------|----------|
| `number.dosierung_v2_ruehrmotor_speed` | Slider | 17 | 0–100% PWM |
| `switch.dosierung_v2_ruehrmotor_5min_start` | Toggle | 17 | Auto 5min @ 75% |

**PWM Details:**
- Frequenz: 1000 Hz
- Range: 0–100%
- Typischer Start: 5 Minuten nach jeder Dosierung

**Automation (Home Assistant):**
```yaml
automation:
  - alias: "Rührmotor nach Dosierung starten"
    trigger:
      platform: mqtt
      topic: "dixy/dosierung_v2/state/last_dose"
    action:
      service: switch.turn_on
      target:
        entity_id: switch.dosierung_v2_ruehrmotor_5min_start
```

---

## Durchflussregelung (DC Runner)

| Entity ID | Typ | GPIO | Bereich |
|-----------|-----|------|---------|
| `number.dosierung_v2_dc_runner_durchfluss` | Slider | 11 | 0–100% |

**Beschreibung:**
- 0-10V analog Output (PWM via Mosfet-Konverter)
- Steuert Aqua Medic DC Runner Durchflussregler
- Update direkt bei Slider-Change

**Kalibrierung:**
1. Slider auf 0% → 0V out (Pumpe aus)
2. Slider auf 100% → 10V out (Max Flow)
3. Zwischen-Werte linear interpoliert

---

## Setpoints / Sollwerte

| Entity ID | Typ | Bereich | Unit | Persistiert |
|-----------|-----|---------|------|-------------|
| `number.dosierung_v2_ec_soll` | Slider | 0.5–3.0 | mS/cm | ✅ Ja |
| `number.dosierung_v2_ph_soll` | Slider | 5.0–7.0 | pH | ✅ Ja |
| `number.dosierung_v2_durchfluss_soll` | Slider | 0–100 | % | ✅ Ja |

**Verwendung:** Für zukünftige Auto-Regelung (noch im Platzhalter-Stadium, v0.3+)

```yaml
# Automation: EC zu niedrig, Pumpe A dosieren
automation:
  - trigger:
      platform: numeric_state
      entity_id: sensor.dosierung_v2_ec
      below: 1.5
    action:
      service: esphome.dosierung_v2_dose_pump
      data:
        pump: "A"
        duration_ms: 5000
        power_pct: 75
```

---

## Manuelle Dosier-Slider

| Entity ID | Unit | Bereich | Bemerkung |
|-----------|------|---------|-----------|
| `number.dosierung_v2_pumpe_a_ml` | ml | 0–100 | Manual Dose Volume |
| `number.dosierung_v2_pumpe_b_ml` | ml | 0–100 | – |
| `number.dosierung_v2_pumpe_c_ml` | ml | 0–100 | – |
| `number.dosierung_v2_pumpe_d_ml` | ml | 0–100 | – |

**Interpretation:** Slider zeigt gewünschte Menge an, aktuelle Dosis kann via Script definiert werden.

---

## Stepper-Motoren (Optional, v0.3+)

### Stepper 1–4 Controls

| Entity ID | Motor | Funktion |
|-----------|-------|----------|
| `switch.dosierung_v2_stepper_1_cw_1_step` | 1 | Clockwise 1 Step |
| `switch.dosierung_v2_stepper_1_ccw_1_step` | 1 | Counter-Clockwise |
| `switch.dosierung_v2_stepper_2_cw_1_step` | 2 | – |
| `switch.dosierung_v2_stepper_2_ccw_1_step` | 2 | – |
| ... (3, 4 analog) | – | – |

**Hardware:** MCP23017 GPIO Expander (I2C 0x20)
- Pins 0–1: Stepper 1 (DIR, STEP)
- Pins 2–3: Stepper 2 (DIR, STEP)
- Pins 4–5: Stepper 3 (DIR, STEP)
- Pins 6–7: Stepper 4 (DIR, STEP)

**Stepper-Details:**
- Type: NEMA17 (Standardgröße, 1.9°/step = 200 steps/revolution)
- Frequenz: Maximal 2000 steps/s (abhängig Motortyp)
- Torque: ~40 Nm (abhängig Stromversorgung)

**Anwendung:**
- Alternative zu PWM-Pumpen für höhere Präzision
- Oder parallele Verwendung für Stepperdosierer (Kleine Portionen)

**Step-Berechnung:**
```
ml pro Step ≈ Pump_Flow_Rate / 200
z.B. 10 ml/min Pumpe → 0.05 ml pro Step
100 Steps → 5 ml
```

---

## Status Sensoren

### Temperatur (Inherited from Hydroknoten)
| Entity ID | Type | Update | Bemerkung |
|-----------|------|--------|-----------|
| `sensor.dosierung_v2_tank_temp` | Template | 15s | DS18B20 |
| `sensor.dosierung_v2_ruecklauf_temp` | Template | 15s | DS18B20 |

### EC/pH (Inherited)
| Entity ID | Type | Update |
|-----------|------|--------|
| `sensor.dosierung_v2_ec` | Template | 10s |
| `sensor.dosierung_v2_ph` | Template | 10s |

### Wasserstände (Inherited)
- `binary_sensor.dosierung_v2_tank_*_level` (6x)
- `binary_sensor.dosierung_v2_tank_leer_irgendeiner`

### WiFi & System
| Entity ID | Update |
|-----------|--------|
| `sensor.dosierung_v2_wifi_signal` | 60s |
| `sensor.dosierung_v2_uptime` | 60s |
| `sensor.dosierung_v2_mcu_temp` | 30s |
| `sensor.dosierung_v2_free_heap` | 60s |

---

## Automation / Calibration Controls

| Entity ID | Funktion |
|-----------|----------|
| `switch.dosierung_v2_ec_kalibrierung_markieren` | Timestamp EC-Cal speichern |
| `switch.dosierung_v2_ph_kalibrierung_markieren` | Timestamp pH-Cal speichern |
| `switch.dosierung_v2_automatik_aktiv` | Toggle für Auto-Regelung (Platzhalter) |
| `button.dosierung_v2_neustart` | Soft Reboot |

---

## MQTT Topics Reference

### Status
```
Topic: dixy/dosierung_v2/status
Payload: online | offline
```

### Dosier-Kommandos
```
Topic: dixy/dosierung_v2/cmd/dose
Payload: {"pump":"A|B|C|D","duration_ms":1-30000,"power_pct":0-100}

Example:
{
  "pump": "A",
  "duration_ms": 5000,
  "power_pct": 75
}
```

### Dosier-Antwort
```
Topic: dixy/dosierung_v2/state/last_dose
Payload: {"pump":"A","ms":5000,"pct":75}
```

### MQTT Discovery
- Home Assistant MQTT Discovery aktiviert
- Alle Entities auto-registriert nach Startup
- Discovery Topic: `homeassistant/+/dixy/dosierung_v2_*/config`

---

## Globals (Persistente Variablen)

| Global ID | Type | Persistiert | Initial | Verwendung |
|-----------|------|-------------|---------|-----------|
| `last_ec_cal_ts` | uint32_t | ✅ | 0 | EC-Kalibrierungs-Zeitstempel |
| `last_ph_cal_ts` | uint32_t | ✅ | 0 | pH-Kalibrierungs-Zeitstempel |
| `pump_a_total_ml_today` | float | ✅ | 0 | Dosiert heute (A) |
| `pump_b_total_ml_today` | float | ✅ | 0 | Dosiert heute (B) |
| `pump_c_total_ml_today` | float | ✅ | 0 | Dosiert heute (C) |
| `pump_d_total_ml_today` | float | ✅ | 0 | Dosiert heute (D) |
| `pump_a_total_ml_lifetime` | float | ✅ | 0 | Dosiert gesamt (A) |
| `encoder_value` | int32_t | ✅ | 0 | Encoder Impuls-Zähler |
| `ui_page` | int32_t | ✅ | 0 | Aktuelle UI-Seite (OLED) |

---

## Health Checks

| Entity ID | Device Class | Bedeutung |
|-----------|--------------|-----------|
| `binary_sensor.dosierung_v2_ads1115_ok` | `problem` | ADS-Fehler wenn TRUE |
| `binary_sensor.dosierung_v2_temp_sensoren_ok` | `problem` | Temp-Fehler wenn TRUE |
| `binary_sensor.dosierung_v2_tank_leer` | `problem` | Irgendein Tank leer wenn TRUE |

---

## Troubleshooting & Testing

### MQTT Test (manuell)
```bash
# Pumpe A für 5 Sekunden starten
mosquitto_pub -h 192.168.1.100 \
  -t "dixy/dosierung_v2/cmd/dose" \
  -m '{"pump":"A","duration_ms":5000,"power_pct":75}'

# Response abhören
mosquitto_sub -h 192.168.1.100 \
  -t "dixy/dosierung_v2/state/last_dose"
```

### Home Assistant Service Test
```yaml
# Developer Tools → Services → esphome.dosierung_v2_dose_pump
service: esphome.dosierung_v2_dose_pump
data:
  pump: "A"
  duration_ms: 3000
  power_pct: 50
```

### Logs prüfen
```bash
# ESPHome Logs live
esphome logs ESP32-Knoten/dosierung/dosierung_v2.yaml --no-update

# Nach "dose_pump" suchen
# Nach "EC/pH" Ausgaben suchen
```

---

## Sicherheitsmerkmale

1. **Tank-Empty Blockade:** Dosierung blockiert wenn `any_tank_empty` = TRUE
2. **Duration Cap:** Max 30s pro Pump (verhindert Überlauf)
3. **Power Limit:** 0–100% clamp (verhindert Überspannung)
4. **Current Monitoring:** ACS712 optional, zeigt Pump-Ausfall an
5. **Soft Timeout:** Pump stoppt nach der konfigurierten Duration (sicherheits-relevant)

---

## Performance & Timings

| Vorgang | Latenz |
|---------|--------|
| MQTT Befehl → Script Execute | < 100ms |
| Pump Start → Running Verified | 500ms–2s |
| Pump Stop → Current Drop | < 1s |
| EC/pH Update | 10s zyklus |
| Temp Update | 15s zyklus |
| Tank-Level Response | 500ms (debounce) |

---

## Integrations-Beispiele (Home Assistant)

### Automation: EC zu niedrig
```yaml
automation:
  - alias: "EC boosten – Pumpe A"
    trigger:
      platform: numeric_state
      entity_id: sensor.dosierung_v2_ec
      below: 1.4
      for: "00:05:00"
    action:
      - service: esphome.dosierung_v2_dose_pump
        data:
          pump: "A"
          duration_ms: 2000
          power_pct: 75
      - service: notify.telegram
        data:
          message: "✅ EC boosted 2s @75%"
```

### Template: Dosierungs-Status heute
```yaml
template:
  - sensor:
      - name: "Dosierung heute"
        unique_id: dosing_today
        unit_of_measurement: "ml"
        state: >
          {% set a = states('sensor.dosierung_v2_pump_a_today') | float(0) %}
          {% set b = states('sensor.dosierung_v2_pump_b_today') | float(0) %}
          {% set c = states('sensor.dosierung_v2_pump_c_today') | float(0) %}
          {% set d = states('sensor.dosierung_v2_pump_d_today') | float(0) %}
          {{ "%.1f" | format(a + b + c + d) }}
```

