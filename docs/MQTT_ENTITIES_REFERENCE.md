# MQTT Topics & Entities Reference
## DiXY Dosierung v2 MQTT und ESPHome Entity Mapping

**Version:** 0.5  
**Datum:** Dezember 2025  
**Status:** Simulation & Production Ready

---

## Inhaltsverzeichnis

1. [MQTT-Konfiguration](#mqtt-konfiguration)
2. [Topic-Struktur](#topic-struktur)
3. [Dosier-Kommandos](#dosier-kommandos)
4. [Entity Mapping](#entity-mapping)
5. [ESPHome API Service](#esphome-api-service)
6. [Datenflusss-Diagramm](#datenflusss-diagramm)
7. [Anwendungsbeispiele](#anwendungsbeispiele)

---

## MQTT-Konfiguration

### Broker-Einstellungen

```yaml
# secrets.yaml / secrets_sim.yaml
mqtt_broker: "192.168.1.100"  # oder MQTT-Hostname
mqtt_port: 1883
mqtt_username: "dixy"
mqtt_password: "geheim"
```

### ESPHome MQTT Integration

```yaml
# In dosierung_v2.yaml / dosierung_v2_sim.yaml
mqtt:
  broker: !secret mqtt_broker
  port: 1883
  username: !secret mqtt_username
  password: !secret mqtt_password
  client_id: dosierung_v2_sim
  discovery: true
  discovery_prefix: homeassistant
  birth_message:
    topic: "dixy/dosierung_v2_sim/status"
    payload: "online"
  will_message:
    topic: "dixy/dosierung_v2_sim/status"
    payload: "offline"
```

### MQTT Discovery (Home Assistant)

Home Assistant erkennt automatisch alle ESPHome Entities über MQTT Discovery:
- Discovery Prefix: `homeassistant/`
- Entity ID Format: `sensor.dosierung_v2_sim_<sanitized_name>`
- Sanitization: Spaces→Underscores, Colons→Removed

**Beispiel Discovery Topic:**
```
homeassistant/sensor/dosierung_v2_sim/dosierung_v2_sim_ec/config
```

---

## Topic-Struktur

### Status & Presence

| Topic | Payload | Bedeutung |
|-------|---------|-----------|
| `dixy/dosierung_v2_sim/status` | `online` / `offline` | Birth/Will Message (automatisch) |
| `dixy/dosierung_v2_sim/uptime` | `3600` (Sekunden) | System Laufzeit |
| `dixy/dosierung_v2_sim/version` | `0.5-sim` | Firmware Version |

### Sensor State (Read-Only)

Alle Sensoren publizieren ihren Zustand auf Basis von `text_sensor.py_script`:

```
dixy/dosierung_v2_sim/sensors/ec → "1.234"
dixy/dosierung_v2_sim/sensors/ph → "6.45"
dixy/dosierung_v2_sim/sensors/tank_temp → "23.5"
dixy/dosierung_v2_sim/sensors/rucklauf_temp → "22.1"
dixy/dosierung_v2_sim/sensors/pump_a_current → "0.45"
```

**Hinweis:** Nicht alle Sensoren publizieren einzeln auf MQTT. Nutze Home Assistant API für Echtzeit-Abfragen.

### Kommando-Topics (Write)

```
dixy/dosierung_v2_sim/cmd/dose         → Pump Dosierung starten
dixy/dosierung_v2_sim/cmd/stop         → Alle Pumpen stoppen
dixy/dosierung_v2_sim/cmd/calibrate    → Kalibriermode starten
```

### Response Topics (Read)

```
dixy/dosierung_v2_sim/state/last_dose      → JSON mit letztem Dosierungsauftrag
dixy/dosierung_v2_sim/state/daily_totals   → JSON mit Tagesumsätzen
```

---

## Dosier-Kommandos

### Befehl: Pump Dosierung (`cmd/dose`)

**Topic:** `dixy/dosierung_v2_sim/cmd/dose`

**Payload Format (JSON):**

```json
{
  "pump": "A",           // String: A, B, C, oder D
  "duration_ms": 5000,   // Integer: 1-30000 ms (clamped)
  "power_pct": 75        // Integer: 0-100% (optional, default 75%)
}
```

#### Payload-Beispiele

**Beispiel 1: Pump A - 10 Sekunden @ 75% Power**
```json
{
  "pump": "A",
  "duration_ms": 10000
}
```

**Beispiel 2: Pump B - 5 Sekunden @ 50% Power**
```json
{
  "pump": "B",
  "duration_ms": 5000,
  "power_pct": 50
}
```

**Beispiel 3: Pump C - 2 Sekunden @ 100% Power**
```json
{
  "pump": "C",
  "duration_ms": 2000,
  "power_pct": 100
}
```

**Beispiel 4: Pump D - kurzer Stoß @ 75% (default)**
```json
{
  "pump": "D",
  "duration_ms": 3000
}
```

### Response: Last Dose (`state/last_dose`)

**Topic:** `dixy/dosierung_v2_sim/state/last_dose`

**Antwort-Payload (JSON):**

```json
{
  "pump": "A",
  "duration_ms": 10000,
  "power_pct": 75,
  "timestamp": 1702047312,
  "status": "ok",
  "tank_level_ok": true,
  "ml_delivered": 5.2
}
```

**Status Values:**
- `"ok"` - Dosierung erfolgreich abgeschlossen
- `"error_tank_empty"` - Tank zu niedrig (Absicherung)
- `"error_timeout"` - Duration überschritten Maximum
- `"error_power_invalid"` - Power außerhalb 0-100%
- `"canceled"` - Manuell abgebrochen

---

## Entity Mapping

### Sensoren (Sensors)

| Name | Entity ID | MQTT Discovery | Einheit | Min-Max | Beschreibung |
|------|-----------|------------------|---------|---------|-------------|
| EC | `sensor.dosierung_v2_sim_ec` | ✓ | mS/cm | 0-3 | Elektroleitfähigkeit |
| pH | `sensor.dosierung_v2_sim_ph` | ✓ | pH | 4-9 | pH-Wert |
| Tank Temp | `sensor.dosierung_v2_sim_tank_temp` | ✓ | °C | -10-50 | Behälter-Temperatur |
| Rücklauf Temp | `sensor.dosierung_v2_sim_rucklauf_temp` | ✓ | °C | -10-50 | Rücklauf-Temperatur |
| Pump A Current | `sensor.dosierung_v2_sim_pump_a_strom` | ✓ | A | 0-5 | Stromaufnahme Pumpe A |
| Pump B Current | `sensor.dosierung_v2_sim_pump_b_strom` | ✓ | A | 0-5 | Stromaufnahme Pumpe B |
| Pump C Current | `sensor.dosierung_v2_sim_pump_c_strom` | ✓ | A | 0-5 | Stromaufnahme Pumpe C |
| Pump D Current | `sensor.dosierung_v2_sim_pump_d_strom` | ✓ | A | 0-5 | Stromaufnahme Pumpe D |
| WiFi Signal | `sensor.dosierung_v2_sim_wifi_signal` | ✓ | dBm | -100--30 | WiFi Signalstärke |
| Uptime | `sensor.dosierung_v2_sim_uptime` | ✓ | h | 0-∞ | Betriebszeit |
| IP Address | `text_sensor.dosierung_v2_sim_ip_address` | ✓ | - | - | IP-Adresse des Geräts |
| Version | `text_sensor.dosierung_v2_sim_version` | ✓ | - | - | Firmware Version |

### Binary Sensoren (Binary Sensors)

| Name | Entity ID | MQTT Discovery | Status | Beschreibung |
|------|-----------|------------------|--------|-------------|
| Tank 1 Level | `binary_sensor.dosierung_v2_sim_tank_1_level` | ✓ | on/off | Tank 1 Pegelschalter |
| Tank 2 Level | `binary_sensor.dosierung_v2_sim_tank_2_level` | ✓ | on/off | Tank 2 Pegelschalter |
| Tank 3 Level | `binary_sensor.dosierung_v2_sim_tank_3_level` | ✓ | on/off | Tank 3 Pegelschalter |
| Tank 4 Level | `binary_sensor.dosierung_v2_sim_tank_4_level` | ✓ | on/off | Tank 4 Pegelschalter |
| Tank 5 Level | `binary_sensor.dosierung_v2_sim_tank_5_level` | ✓ | on/off | Tank 5 Pegelschalter |
| Tank 6 Level | `binary_sensor.dosierung_v2_sim_tank_6_level` | ✓ | on/off | Tank 6 Pegelschalter |
| Pump Verification | `binary_sensor.dosierung_v2_sim_pump_verification` | ✓ | on/off | Pump läuft (Strom-Basis) |
| Tank Empty Alert | `binary_sensor.dosierung_v2_sim_tank_empty_alert` | ✓ | on/off | Alert bei leerer Tank |
| ADS1115 OK | `binary_sensor.dosierung_v2_sim_ads1115_ok` | ✓ | on/off | ADC-Sensor OK |
| Temps OK | `binary_sensor.dosierung_v2_sim_temps_ok` | ✓ | on/off | Alle Temp-Sensoren OK |

### Text Sensoren (Text Sensors)

| Name | Entity ID | MQTT Discovery | Werte | Beschreibung |
|------|-----------|------------------|-------|-------------|
| Stepper A Status | `text_sensor.dosierung_v2_sim_stepper_a_status` | ✓ | IDLE, MOVING, ERROR | Status Stepper A |
| Stepper B Status | `text_sensor.dosierung_v2_sim_stepper_b_status` | ✓ | IDLE, MOVING, ERROR | Status Stepper B |
| Stepper C Status | `text_sensor.dosierung_v2_sim_stepper_c_status` | ✓ | IDLE, MOVING, ERROR | Status Stepper C |
| Stepper D Status | `text_sensor.dosierung_v2_sim_stepper_d_status` | ✓ | IDLE, MOVING, ERROR | Status Stepper D |
| WLAN Hostname | `text_sensor.dosierung_v2_sim_wlan_hostname` | ✓ | - | WLAN Hostname |
| WLAN SSID | `text_sensor.dosierung_v2_sim_wlan_ssid` | ✓ | - | Verbundenes WLAN Netzwerk |

### Number/Slider Controls (Numbers)

| Name | Entity ID | MQTT Discovery | Min-Max | Step | Beschreibung |
|------|-----------|------------------|---------|------|-------------|
| EC Sollwert | `number.dosierung_v2_sim_ec_sollwert` | ✓ | 0-3 | 0.01 | EC Target (mS/cm) |
| pH Sollwert | `number.dosierung_v2_sim_ph_sollwert` | ✓ | 4-9 | 0.1 | pH Target |
| Flow Sollwert | `number.dosierung_v2_sim_flow_sollwert` | ✓ | 0-100 | 1 | Flow Target (L/min) |
| Temp Offset Tank | `number.dosierung_v2_sim_temp_offset_tank` | ✓ | -5-5 | 0.1 | Tank Temp Kalibrieroffset |
| Temp Offset Rücklauf | `number.dosierung_v2_sim_temp_offset_rucklauf` | ✓ | -5-5 | 0.1 | Rücklauf Temp Kalibrieroffset |
| EC Calibration Point 1 | `number.dosierung_v2_sim_ec_cal_point_1` | ✓ | 0-3 | 0.01 | EC Kalibrierungspunkt 1 |
| EC Calibration Point 2 | `number.dosierung_v2_sim_ec_cal_point_2` | ✓ | 0-3 | 0.01 | EC Kalibrierungspunkt 2 |
| pH Calibration Point 1 | `number.dosierung_v2_sim_ph_cal_point_1` | ✓ | 4-9 | 0.1 | pH Kalibrierungspunkt 1 |
| pH Calibration Point 2 | `number.dosierung_v2_sim_ph_cal_point_2` | ✓ | 4-9 | 0.1 | pH Kalibrierungspunkt 2 |
| Pump A ml | `number.dosierung_v2_sim_pump_a_ml` | ✓ | 0-100 | 0.1 | Pump A Milliliter Slider |
| Pump B ml | `number.dosierung_v2_sim_pump_b_ml` | ✓ | 0-100 | 0.1 | Pump B Milliliter Slider |
| Pump C ml | `number.dosierung_v2_sim_pump_c_ml` | ✓ | 0-100 | 0.1 | Pump C Milliliter Slider |
| Pump D ml | `number.dosierung_v2_sim_pump_d_ml` | ✓ | 0-100 | 0.1 | Pump D Milliliter Slider |

### Schalter (Switches)

| Name | Entity ID | MQTT Discovery | Standard | Beschreibung |
|------|-----------|------------------|----------|-------------|
| Automatik | `switch.dosierung_v2_sim_automatik` | ✓ | off | Auto-Dosierung aktivieren |
| Pump A Stoß | `switch.dosierung_v2_sim_pump_a_stoss` | ✓ | off | Pump A Manuelle Dosierung |
| Pump B Stoß | `switch.dosierung_v2_sim_pump_b_stoss` | ✓ | off | Pump B Manuelle Dosierung |
| Pump C Stoß | `switch.dosierung_v2_sim_pump_c_stoss` | ✓ | off | Pump C Manuelle Dosierung |
| Pump D Stoß | `switch.dosierung_v2_sim_pump_d_stoss` | ✓ | off | Pump D Manuelle Dosierung |
| Mark EC Calibration | `switch.dosierung_v2_sim_mark_ec_cal` | ✓ | off | EC Kalibrierpunkt markieren |
| Mark pH Calibration | `switch.dosierung_v2_sim_mark_ph_cal` | ✓ | off | pH Kalibrierpunkt markieren |
| Stirrer 5min | `switch.dosierung_v2_sim_stirrer_5min` | ✓ | off | Rührer für 5 Minuten |

### Buttons (Service Trigger)

| Name | Entity ID | Service | Parameter | Beschreibung |
|------|-----------|---------|-----------|-------------|
| System Restart | `button.dosierung_v2_sim_restart` | `esphome.dosierung_v2_sim_restart` | - | Gerät neustarten |

---

## ESPHome API Service

### Home Assistant Service: `esphome.dosierung_v2_sim_dose_pump`

**Service Name:** `esphome.dosierung_v2_sim_dose_pump`

**Parameter:**

```yaml
pump:
  description: "Pump identifier: A, B, C, or D"
  example: "A"
duration_ms:
  description: "Duration in milliseconds (1-30000)"
  example: 5000
power_pct:
  description: "Power percentage (0-100, optional, default 75)"
  example: 75
```

### API-Service Beispiel (REST Call)

```bash
curl -X POST http://localhost:8123/api/services/esphome/dosierung_v2_sim_dose_pump \
  -H "Authorization: Bearer YOUR_LONG_LIVED_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service": "dosierung_v2_sim_dose_pump",
    "service_data": {
      "pump": "A",
      "duration_ms": 10000,
      "power_pct": 75
    }
  }'
```

### Safety Constraints (eingebaut im Script)

```yaml
# dose_pump Script in dosierung_v2_sim.yaml

# Tank-Sicherheit
- if:
    condition: binary_sensor.is_off(dosierung_v2_sim_tank_empty_alert)
    then:
      - logger.log: "Tank empty! Dosing aborted."
      - return

# Duration Clamping
- lambda: |
    if (duration_ms > 30000) {
      duration_ms = 30000;
    }
    if (duration_ms < 1) {
      duration_ms = 1;
    }

# Power Clamping
- lambda: |
    if (power_pct > 100) {
      power_pct = 100;
    }
    if (power_pct < 0) {
      power_pct = 0;
    }
```

---

## Datenflusss-Diagramm

```
┌─────────────────────────────────────────────────────────────────┐
│                    HOME ASSISTANT (UI)                          │
│  Lovelace Dashboard → dixy_rdwc_monitor.yaml (5 tabs)          │
└────────────┬────────────────────────────────────────────────────┘
             │
             ├─ API Service Call (REST)
             │  esphome.dosierung_v2_sim_dose_pump
             │
             └─ MQTT Publish
                dixy/dosierung_v2_sim/cmd/dose
                {"pump":"A","duration_ms":5000}
             
┌────────────────────────────────────────────────────────────────┐
│            MOSQUITTO MQTT BROKER (192.168.1.100)              │
│                                                                │
│  Topic: dixy/dosierung_v2_sim/cmd/dose ──→ Receive Payload   │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ MQTT Message Routing
             │
┌────────────▼────────────────────────────────────────────────────┐
│         ESPHOME (dosierung_v2_sim on ESP32)                    │
│                                                                │
│  on_json_message (cmd/dose)                                  │
│  │                                                            │
│  └─→ Parse JSON {pump, duration_ms, power_pct}              │
│      │                                                       │
│      └─→ Script: dose_pump()                                │
│          ├─ Check tank_empty_alert                          │
│          ├─ Clamp duration_ms (1-30000)                     │
│          ├─ Clamp power_pct (0-100)                         │
│          ├─ Execute PWM on pump pin                         │
│          ├─ Wait duration_ms                                │
│          ├─ Stop PWM                                        │
│          │                                                  │
│          └─→ Publish Response: state/last_dose             │
│              {"pump":"A","status":"ok",...}                │
│                                                            │
│  Parallel: Template Sensors (10ms interval)               │
│  │                                                        │
│  ├─ EC Wert (range 1.2 ± 0.5)                           │
│  ├─ pH Wert (range 6.5 ± 0.3)                           │
│  ├─ Tank Temp (range 23 ± 2)                            │
│  ├─ Rücklauf Temp (range 22 ± 1)                        │
│  ├─ Pump Currents (based on pump status)                │
│  └─ Binary Sensors (tank level, pump verification)      │
│                                                          │
│  MQTT Publish (every 60s or on change):                │
│  └─ homeassistant/sensor/.../config                    │
│     homeassistant/sensor/.../state                      │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ MQTT Discovery
             │
┌────────────▼────────────────────────────────────────────────────┐
│            HOME ASSISTANT (Backend)                            │
│                                                                │
│  MQTT Entities Auto-Discovery:                               │
│  └─ sensor.dosierung_v2_sim_ec                              │
│  └─ sensor.dosierung_v2_sim_ph                              │
│  └─ binary_sensor.dosierung_v2_sim_tank_*                   │
│  └─ switch.dosierung_v2_sim_pump_*_stoss                    │
│  └─ number.dosierung_v2_sim_*_sollwert                      │
│  (60+ Entities automatisch registriert)                     │
│                                                            │
│  Lovelace Dashboard updates (real-time):                  │
│  └─ Gauges refresh EC/pH/Temps                          │
│  └─ Tank level indicators update                        │
│  └─ Pump current graphs update                          │
└────────────────────────────────────────────────────────────────┘
```

---

## Anwendungsbeispiele

### 1. MQTT CLI - Pump A Dosierung starten

**Befehl:**
```bash
mosquitto_pub -h 192.168.1.100 -t "dixy/dosierung_v2_sim/cmd/dose" \
  -m '{"pump":"A","duration_ms":5000,"power_pct":75}'
```

**Response (subscribe im anderen Terminal):**
```bash
mosquitto_sub -h 192.168.1.100 -t "dixy/dosierung_v2_sim/state/last_dose"
```

**Erwartete Response:**
```json
{"pump":"A","duration_ms":5000,"power_pct":75,"timestamp":1702047312,"status":"ok","tank_level_ok":true,"ml_delivered":5.2}
```

### 2. Home Assistant Automation - Auto-Dosierung bei EC zu niedrig

**File:** `Home-Assistant/automations.yaml`

```yaml
automation:
  - alias: "Auto Dosierung A bei EC niedrig"
    description: "Dosiere A wenn EC < 1.0 mS/cm"
    trigger:
      - platform: numeric_state
        entity_id: sensor.dosierung_v2_sim_ec
        below: 1.0
        for:
          minutes: 5
    action:
      - service: esphome.dosierung_v2_sim_dose_pump
        data:
          pump: "A"
          duration_ms: 5000
          power_pct: 75
      - service: persistent_notification.create
        data:
          title: "Auto-Dosierung"
          message: "Pump A dosiert wegen EC zu niedrig"
```

### 3. Home Assistant Script - Mehrfach-Dosierung

**File:** `Home-Assistant/scripts.yaml`

```yaml
script:
  sequence_dosage:
    alias: "Sequence Dosage (A+B+C)"
    description: "Hintereinander Pumpen A, B, C dosieren"
    sequence:
      - alias: "Pump A"
        service: esphome.dosierung_v2_sim_dose_pump
        data:
          pump: "A"
          duration_ms: 3000
          power_pct: 50
      - delay:
          seconds: 5
      - alias: "Pump B"
        service: esphome.dosierung_v2_sim_dose_pump
        data:
          pump: "B"
          duration_ms: 3000
          power_pct: 50
      - delay:
          seconds: 5
      - alias: "Pump C"
        service: esphome.dosierung_v2_sim_dose_pump
        data:
          pump: "C"
          duration_ms: 3000
          power_pct: 50
```

### 4. Python Script - MQTT direkter Zugriff

**File:** `Home-Assistant/mqtt_dosing_client.py`

```python
#!/usr/bin/env python3
"""
DiXY Dosierung v2 MQTT Client
Bietet direkten Zugriff auf MQTT Kommandos
"""

import json
import paho.mqtt.client as mqtt
import time

BROKER = "192.168.1.100"
PORT = 1883
DEVICE = "dosierung_v2_sim"

def dose_pump(pump_id, duration_ms, power_pct=75):
    """Pump dosieren über MQTT"""
    
    client = mqtt.Client()
    client.connect(BROKER, PORT, 60)
    
    payload = {
        "pump": pump_id,
        "duration_ms": duration_ms,
        "power_pct": power_pct
    }
    
    topic = f"dixy/{DEVICE}/cmd/dose"
    client.publish(topic, json.dumps(payload))
    
    print(f"📤 Sent: {topic}")
    print(f"   Payload: {json.dumps(payload)}")
    
    # Auf Response warten
    def on_message(client, userdata, msg):
        response = json.loads(msg.payload.decode())
        print(f"📥 Response: {json.dumps(response, indent=2)}")
        client.disconnect()
    
    client.on_message = on_message
    client.subscribe(f"dixy/{DEVICE}/state/last_dose")
    client.loop_forever(timeout=5)

if __name__ == "__main__":
    # Beispiele
    print("🔹 Pump A - 5 Sekunden @ 75%")
    dose_pump("A", 5000, 75)
    
    print("\n🔹 Pump B - 3 Sekunden @ 50%")
    dose_pump("B", 3000, 50)
    
    print("\n🔹 Pump C - 10 Sekunden @ 100%")
    dose_pump("C", 10000, 100)
```

**Verwendung:**
```bash
python3 Home-Assistant/mqtt_dosing_client.py
```

### 5. Node-RED Flow - Kalibriersequenz

**Flow (JSON):**

```json
[
  {
    "id": "calibration_flow",
    "type": "function",
    "z": "workspace_id",
    "name": "EC Calibration Sequence",
    "func": "// Kalibriersequenz für EC\nconst steps = [\n  { pump: 'A', duration: 5000, power: 50, label: 'EC Point 1' },\n  { pump: 'B', duration: 5000, power: 50, label: 'EC Point 2' }\n];\n\nlet payload = steps[msg.payload.step];\nmsg.topic = 'dixy/dosierung_v2_sim/cmd/dose';\nmsg.payload = JSON.stringify({\n  pump: payload.pump,\n  duration_ms: payload.duration,\n  power_pct: payload.power\n});\n\nreturn msg;"
  },
  {
    "id": "mqtt_publish",
    "type": "mqtt out",
    "z": "workspace_id",
    "broker": "mqtt_broker_192_168_1_100",
    "topic": "dixy/dosierung_v2_sim/cmd/dose",
    "qos": "1",
    "retain": false
  }
]
```

---

## Troubleshooting

### Problem: Keine Antwort auf `cmd/dose` Befehl

**Ursachen:**
1. ESPHome nicht verbunden (check: `dixy/dosierung_v2_sim/status`)
2. Falscher Pump-ID (muss A, B, C oder D sein)
3. Duration außerhalb Bereich (muss 1-30000 ms sein)

**Lösung:**
```bash
# Status prüfen
mosquitto_sub -h 192.168.1.100 -t "dixy/dosierung_v2_sim/status"

# ESPHome Logs anschauen (wenn über Webinterface verbunden)
# http://dosierung_v2_sim.local/

# MQTT verbindung testen
mosquitto_pub -h 192.168.1.100 -t "test/topic" -m "test"
```

### Problem: Tank Level Sensoren zeigen falsch

**Ursache:** GPIO Pins nicht korrekt verdrahtet oder Sensor-Kalibrierung nötig

**Lösung:**
```yaml
# In Home Assistant: Einstellungen → Automationen
# Erstelle Test-Automatisierung für manuelle Tank-Sensorprüfung
automation:
  - alias: "Test Tank 1 Sensor"
    trigger:
      platform: manual
    action:
      service: persistent_notification.create
      data:
        title: "Tank 1 Status"
        message: "{{ state_attr('binary_sensor.dosierung_v2_sim_tank_1_level', 'friendly_name') }}"
```

### Problem: Pump Verification zeigt immer false

**Ursache:** Strommessung kalibriert nicht richtig, oder Pump läuft nicht

**Lösung:**
1. Prüfe ADC Pin Konfiguration (`current_a_pin` etc.)
2. Stelle Pumpenspannung auf 12V sicher
3. Kalibriere Stromsensor mit bekanntem Referenzstrom

---

## Zusammenfassung MQTT Interface

| Aspekt | Wert |
|--------|------|
| **Broker** | 192.168.1.100:1883 |
| **Haupttopic** | `dixy/dosierung_v2_sim` |
| **Kommando Pump** | POST `cmd/dose` mit JSON (pump, duration_ms, power_pct) |
| **Response** | `state/last_dose` mit {status, tank_ok, ml_delivered} |
| **Entities** | 60+ automatisch über MQTT Discovery |
| **API Service** | `esphome.dosierung_v2_sim_dose_pump` |
| **Max Duration** | 30 Sekunden (clamped) |
| **Safety Check** | Tank-Level vor Dosierung |
| **Simulation** | Vollständig funktionsfähig ohne Hardware |

---

**Erstellt:** Dezember 2025  
**ESPHome Version:** 2024.11+  
**Home Assistant Version:** 2024.12+  
**Status:** Production Ready ✓
