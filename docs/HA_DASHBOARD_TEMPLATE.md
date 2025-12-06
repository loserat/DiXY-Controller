# DiXY RDWC Dashboard – Home Assistant Template

**Stand:** 06.12.2025  
**Format:** YAML für Home Assistant UI (Lovelace)  
**Installation:** Unter `configuration.yaml` oder in separate YAML inkludieren

---

## 📦 Installationsanleitung

### Schritt 1: Input Numbers & Selects konfigurieren

Füge in `configuration.yaml` oder separate YAML-Dateien hinzu:

```yaml
# configuration.yaml
homeassistant:
  packages:
    dixy_rdwc: !include packages/dixy_rdwc.yaml
    
# Oder einzeln:
input_number: !include input_numbers.yaml
input_select: !include input_selects.yaml
script: !include scripts.yaml
automation: !include automations/dixy_automations.yaml
```

### Schritt 2: Dashboard YAML laden

Entweder:
- **UI-Editor:** Settings → Dashboards → Dashboard erstellen → "Code anschauen" → YAML einfügen
- **YAML-Datei:** `config/dashboards/dixy_rdwc.yaml` erstellen

### Schritt 3: Automation importieren

- Kopiere `.yaml`-Dateien nach `automations/`
- HA Restart → Automations laden automatisch

---

## 🎨 Dashboard: DiXY RDWC Monitor

```yaml
# dashboards/dixy_rdwc_monitor.yaml
# Haupt-Dashboard für RDWC System Übersicht

title: DiXY RDWC Monitor
path: dixy-rdwc
icon: mdi:water-circle
panel: false
layout:
  type: masonry
  columns: 3

views:
  - title: "🏠 Übersicht"
    path: overview
    icon: mdi:home-circle
    cards:
      # ═══════════════════════════════════════════════════════════
      # TOP: System Status 3-Column
      # ═══════════════════════════════════════════════════════════
      - type: glance
        title: "🟢 System Status"
        entities:
          - entity: binary_sensor.hydroknoten_online
            name: "Hydro"
          - entity: binary_sensor.dosierung_online
            name: "Dosier"
          - entity: binary_sensor.zeltsensor_online
            name: "Zelt"
        columns: 3

      # ═══════════════════════════════════════════════════════════
      # EC/pH LIVE (Gauges)
      # ═══════════════════════════════════════════════════════════
      - type: horizontal-stack
        cards:
          - type: gauge
            entity: sensor.hydroknoten_ec_wert
            min: 0
            max: 3
            unit: mS/cm
            severity:
              green: 1.2
              yellow: 1.0
              red: 0.8
            title: "EC Wert"

          - type: gauge
            entity: sensor.hydroknoten_ph_wert
            min: 4.5
            max: 8
            unit: pH
            severity:
              green: 6.0
              yellow: 5.8
              red: 5.5
            title: "pH Wert"

      # ═══════════════════════════════════════════════════════════
      # Temperatur + Luftfeuchte (Zaltsensor)
      # ═══════════════════════════════════════════════════════════
      - type: horizontal-stack
        cards:
          - type: gauge
            entity: sensor.zeltsensor_lufttemperatur
            unit: "°C"
            min: 15
            max: 35
            severity:
              green: 25
              yellow: 28
              red: 32

          - type: gauge
            entity: sensor.zeltsensor_luftfeuchte
            unit: "%"
            min: 20
            max: 90
            severity:
              green: 60
              yellow: 75
              red: 85

      # ═══════════════════════════════════════════════════════════
      # VPD Alarm + Taupunkt
      # ═══════════════════════════════════════════════════════════
      - type: horizontal-stack
        cards:
          - type: gauge
            entity: sensor.zeltsensor_vpd
            min: 0.2
            max: 2.0
            unit: kPa
            severity:
              green: 0.85
              yellow: 1.2
              red: 1.6
            title: "VPD"

          - type: gauge
            entity: sensor.zeltsensor_taupunkt
            unit: "°C"
            title: "Taupunkt (Schimmel-Alarm <0)"

      # ═══════════════════════════════════════════════════════════
      # PPFD + DLI (Licht)
      # ═══════════════════════════════════════════════════════════
      - type: horizontal-stack
        cards:
          - type: gauge
            entity: sensor.zeltsensor_ppfd
            min: 0
            max: 1500
            unit: µmol/m²/s
            severity:
              green: 800
              yellow: 500
              red: 200
            title: "PPFD"

          - type: gauge
            entity: sensor.zeltsensor_dli
            min: 0
            max: 40
            unit: mol/m²/d
            severity:
              green: 15
              yellow: 12
              red: 8

      # ═══════════════════════════════════════════════════════════
      # EC/pH TARGETS + LIMITS (Inputs)
      # ═══════════════════════════════════════════════════════════
      - type: horizontal-stack
        cards:
          - type: entities
            title: "⚙️ Nährstoff-Ziele"
            entities:
              - entity: input_number.ec_target
                name: "EC Soll"
              - entity: input_number.ph_target
                name: "pH Soll"
              - entity: input_number.rdwc_system_liters
                name: "System-Volumen (L)"

          - type: entities
            title: "🛡️ Safety Limits"
            entities:
              - entity: number.dosierung_max_dose_per_cycle
                name: "Max ml/Dosierung"
              - entity: number.dosierung_max_ml_per_day
                name: "Max ml/Tag"

      # ═══════════════════════════════════════════════════════════
      # WASSERSTAND SENSOREN
      # ═══════════════════════════════════════════════════════════
      - type: horizontal-stack
        cards:
          - type: entities
            title: "💧 Wasserstand"
            entities:
              - entity: binary_sensor.hydroknoten_tank1_wasserstand
                name: "Tank 1"
              - entity: binary_sensor.hydroknoten_tank2_wasserstand
                name: "Tank 2"
              - entity: binary_sensor.hydroknoten_tank3_wasserstand
                name: "Tank 3"
              - entity: binary_sensor.hydroknoten_tank4_wasserstand
                name: "Tank 4"
              - entity: binary_sensor.hydroknoten_tank5_wasserstand
                name: "Tank 5"
              - entity: binary_sensor.hydroknoten_tank6_wasserstand
                name: "Tank 6"

          - type: conditional
            conditions:
              - entity: binary_sensor.hydroknoten_tank_leer
                state: "on"
            card:
              type: button
              entity: button.hydroknoten_restart
              name: "⚠️ TANK LEER – Nachfüllen!"
              color: red

  # ═══════════════════════════════════════════════════════════
  # TAB 2: Dosierung & Rührzeit
  # ═══════════════════════════════════════════════════════════
  - title: "💊 Dosierung & Rührzeit"
    path: dosing
    icon: mdi:water-pump
    cards:
      - type: entities
        title: "🔄 Rührzeit-Status"
        entities:
          - entity: sensor.dosierung_zeit_seit_dosierung
            name: "Zeit seit letzter Dosierung"
          - entity: sensor.dosierung_durchmischung_countdown
            name: "Durchmischungs-Countdown"
          - entity: binary_sensor.dosierung_ruehrzeit_ok
            name: "Rührzeit-Check OK"

      # ═══════════════════════════════════════════════════════════
      # Pumpen Manual Control
      # ═══════════════════════════════════════════════════════════
      - type: horizontal-stack
        cards:
          - type: entities
            title: "Pumpe A (EC)"
            entities:
              - entity: switch.dosierung_pumpe_a
                name: "On/Off"
              - entity: number.dosierung_pumpe_a_flow_rate
                name: "Flow Rate (ml/s)"
              - entity: number.dosierung_pumpe_a_ec_effectiveness
                name: "EC Effectiveness"

          - type: entities
            title: "Pumpe B (pH Down)"
            entities:
              - entity: switch.dosierung_pumpe_b
                name: "On/Off"
              - entity: number.dosierung_pumpe_b_flow_rate
                name: "Flow Rate"

          - type: entities
            title: "Pumpe C (pH Up)"
            entities:
              - entity: switch.dosierung_pumpe_c
                name: "On/Off"
              - entity: number.dosierung_pumpe_c_flow_rate
                name: "Flow Rate"

          - type: entities
            title: "Pumpe D (Additive)"
            entities:
              - entity: switch.dosierung_pumpe_d
                name: "On/Off"
              - entity: number.dosierung_pumpe_d_flow_rate
                name: "Flow Rate"

      # ═══════════════════════════════════════════════════════════
      # Rührmotor + MCP4131 Steuerung
      # ═══════════════════════════════════════════════════════════
      - type: entities
        title: "🌀 Rührmotor + Lüfter"
        entities:
          - entity: switch.dosierung_ruehrmotor
            name: "Rührmotor"
          - entity: number.dosierung_ruehrmotor_pwm
            name: "Rührmotor PWM (0-100%)"
          - entity: number.dosierung_inline_luefter_pwm
            name: "Inline-Lüfter PWM (0-100%)"

      # ═══════════════════════════════════════════════════════════
      # Daily Counter + Safety Warnings
      # ═══════════════════════════════════════════════════════════
      - type: horizontal-stack
        cards:
          - type: entities
            title: "📊 Tages-Zähler"
            entities:
              - entity: sensor.dosierung_pumpe_a_daily_ml
                name: "Pumpe A (ml/Tag)"
              - entity: sensor.dosierung_pumpe_b_daily_ml
                name: "Pumpe B (ml/Tag)"

          - type: entities
            title: "⚠️ Safety Warnungen"
            entities:
              - entity: binary_sensor.dosierung_pumpe_a_safety_warning
                name: "Pumpe A 90%"
              - entity: binary_sensor.dosierung_pumpe_b_safety_warning
                name: "Pumpe B 90%"
              - entity: button.dosierung_daily_reset
                name: "Reset Counter"

  # ═══════════════════════════════════════════════════════════
  # TAB 3: Kalibrierungen & Diagnose
  # ═══════════════════════════════════════════════════════════
  - title: "🔧 Kalibrierungen"
    path: calibration
    icon: mdi:tools
    cards:
      - type: entities
        title: "⏰ Kalibrierungs-Zeitstempel"
        entities:
          - entity: text_sensor.hydroknoten_ec_kalibrierung_zuletzt
            name: "EC Kalibrierung"
          - entity: text_sensor.hydroknoten_ph_kalibrierung_zuletzt
            name: "pH Kalibrierung"
          - entity: button.hydroknoten_ec_kalibrierung_markieren
            name: "EC Mark Cal"
          - entity: button.hydroknoten_ph_kalibrierung_markieren
            name: "pH Mark Cal"

      # EC/pH Kalibrierungs-Parameter
      - type: horizontal-stack
        cards:
          - type: entities
            title: "EC Kalibrierpunkte"
            entities:
              - entity: number.hydroknoten_ec_kalibrierpunkt_1413
                name: "Low (1.413 mS/cm)"
              - entity: number.hydroknoten_ec_kalibrierpunkt_12_88
                name: "High (12.88 mS/cm)"

          - type: entities
            title: "pH Kalibrierpunkte"
            entities:
              - entity: number.hydroknoten_ph_kalibrierpunkt_7_0
                name: "pH 7.0"
              - entity: number.hydroknoten_ph_kalibrierpunkt_4_0
                name: "pH 4.0"

      # Temperatur-Offsets
      - type: entities
        title: "🌡️ Temperatur-Offsets"
        entities:
          - entity: number.hydroknoten_temp1_offset
            name: "Tank Temp Offset"
          - entity: number.hydroknoten_temp2_offset
            name: "Rücklauf Temp Offset"

      # PPFD Kalibrierung
      - type: entities
        title: "💡 PPFD Kalibrierung"
        entities:
          - entity: number.zeltsensor_ppfd_cal_factor
            name: "PPFD Cal Factor (Standard: 0.003415)"
          - entity: input_number.photoperiode_stunden
            name: "Photoperiode (h)"

  # ═══════════════════════════════════════════════════════════
  # TAB 4: Diagnose & System Health
  # ═══════════════════════════════════════════════════════════
  - title: "🏥 Diagnose"
    path: diagnostics
    icon: mdi:hospital-box
    cards:
      # ═══════════════════════════════════════════════════════════
      # Hydroknoten Health
      # ═══════════════════════════════════════════════════════════
      - type: entities
        title: "Hydroknoten Health"
        entities:
          - entity: binary_sensor.hydroknoten_ads1115_fehler
            name: "ADS1115 (EC/pH ADC)"
          - entity: binary_sensor.hydroknoten_temperatursensoren_fehler
            name: "DS18B20 (Temperatur)"
          - entity: binary_sensor.hydroknoten_online
            name: "Online-Status"
          - entity: sensor.hydroknoten_wifi_signal
            name: "WiFi Signal (dBm)"
          - entity: sensor.hydroknoten_uptime
            name: "Uptime (h)"
          - entity: sensor.hydroknoten_free_heap
            name: "Free Heap (kB)"

      # ═══════════════════════════════════════════════════════════
      # Dosierknoten Health
      # ═══════════════════════════════════════════════════════════
      - type: entities
        title: "Dosierknoten Health"
        entities:
          - entity: binary_sensor.dosierung_hydroknoten_online
            name: "Hydroknoten Check"
          - entity: binary_sensor.dosierung_online
            name: "Online-Status"
          - entity: sensor.dosierung_wifi_signal
            name: "WiFi Signal (dBm)"
          - entity: sensor.dosierung_uptime
            name: "Uptime (h)"
          - entity: sensor.dosierung_free_heap
            name: "Free Heap (kB)"

      # ═══════════════════════════════════════════════════════════
      # Zeltsensor Health
      # ═══════════════════════════════════════════════════════════
      - type: entities
        title: "Zeltsensor Health"
        entities:
          - entity: binary_sensor.zeltsensor_sht31_fehler
            name: "SHT31 (Temp/RH)"
          - entity: binary_sensor.zeltsensor_as7341_fehler
            name: "AS7341 (Spektral)"
          - entity: binary_sensor.zeltsensor_bmp280_fehler
            name: "BMP280 (Druck)"
          - entity: sensor.zeltsensor_wifi_signal
            name: "WiFi Signal (dBm)"

      # ═══════════════════════════════════════════════════════════
      # WiFi Adressen & Verbindung
      # ═══════════════════════════════════════════════════════════
      - type: entities
        title: "🌐 WiFi-Info"
        entities:
          - entity: text_sensor.hydroknoten_ip_adresse
            name: "Hydro IP"
          - entity: text_sensor.hydroknoten_verbundenes_wlan
            name: "Hydro SSID"
          - entity: text_sensor.hydroknoten_access_point_bssid
            name: "Hydro BSSID"
          - entity: text_sensor.hydroknoten_mac_adresse
            name: "Hydro MAC"
          - entity: text_sensor.dosierung_ip_adresse
            name: "Dosier IP"
          - entity: text_sensor.zeltsensor_ip_adresse
            name: "Zelt IP"

  # ═══════════════════════════════════════════════════════════
  # TAB 5: Wachstum & Analytics
  # ═══════════════════════════════════════════════════════════
  - title: "📊 Wachstum & Analytics"
    path: analytics
    icon: mdi:chart-line
    cards:
      # ═══════════════════════════════════════════════════════════
      # Growth Stage + Light Cycle
      # ═══════════════════════════════════════════════════════════
      - type: horizontal-stack
        cards:
          - type: entities
            title: "🌱 Wachstumsstadium"
            entities:
              - entity: input_select.growth_stage
                name: "Wachstum"
              - entity: input_select.light_cycle
                name: "Lichtzyklus"

          - type: entities
            title: "📈 Nutrient Strategy"
            entities:
              - entity: input_select.nutrient_strategy
                name: "Nährstoff-Strategie"

      # ═══════════════════════════════════════════════════════════
      # EC/pH Trend (History)
      # ═══════════════════════════════════════════════════════════
      - type: history-stats
        entity: sensor.hydroknoten_ec_wert
        name: "EC Trend (24h)"
        title: "EC Wert Statistik"

      - type: history-stats
        entity: sensor.hydroknoten_ph_wert
        name: "pH Trend (24h)"
        title: "pH Wert Statistik"

      # ═══════════════════════════════════════════════════════════
      # Lifetime Statistics (Dosierknoten)
      # ═══════════════════════════════════════════════════════════
      - type: entities
        title: "♾️ Lifetime-Statistik"
        entities:
          - entity: sensor.dosierung_pumpe_a_total_ml
            name: "Pumpe A Total (ml)"
          - entity: sensor.dosierung_pumpe_b_total_ml
            name: "Pumpe B Total (ml)"
          - entity: sensor.dosierung_pumpe_c_total_ml
            name: "Pumpe C Total (ml)"
          - entity: sensor.dosierung_pumpe_d_total_ml
            name: "Pumpe D Total (ml)"
          - entity: sensor.dosierung_ruehrmotor_runtime
            name: "Rührmotor Laufzeit (min)"

  # ═══════════════════════════════════════════════════════════
  # TAB 6: Kameras
  # ═══════════════════════════════════════════════════════════
  - title: "📷 Kameras"
    path: cameras
    icon: mdi:camera
    cards:
      - type: picture-entity
        entity: camera.canopy_camera
        camera_view: live
        title: "Canopy Top-Down Timelapse"

      - type: picture-entity
        entity: camera.detail_camera
        camera_view: live
        title: "Detail Blatt-Analyse (Macro)"

      - type: entities
        title: "📸 Snapshot-Info"
        entities:
          - entity: text_sensor.canopy_last_snapshot
            name: "Canopy Letzter"
          - entity: text_sensor.detail_last_snapshot
            name: "Detail Letzter"
          - entity: button.canopy_manual_snapshot
            name: "Canopy Snapshot"
          - entity: button.detail_manual_snapshot
            name: "Detail Snapshot"
```

---

## 🤖 Automations Bundle

```yaml
# automations/dixy_rdwc_automations.yaml
# Home Assistant Automations für DiXY RDWC

# ═══════════════════════════════════════════════════════════
# AUTO DOSIERUNG: EC-Nährstoff
# ═══════════════════════════════════════════════════════════
- alias: "DiXY – Auto Dosierung EC"
  description: "EC-Hauptdünger dosieren wenn zu niedrig"
  trigger:
    platform: time_pattern
    minutes: "/30"  # Alle 30 Min prüfen
  condition:
    - condition: numeric_state
      entity_id: sensor.hydroknoten_ec_wert
      below: !input_number ec_target
    - condition: binary_sensor.dosierung_ruehrzeit_ok
      state: "on"
  action:
    - service: script.dose_ec_nutrients
      data:
        system_volume: !input_number rdwc_system_liters
        ec_target: !input_number ec_target

# ═══════════════════════════════════════════════════════════
# AUTO DOSIERUNG: pH Correction
# ═══════════════════════════════════════════════════════════
- alias: "DiXY – Auto Dosierung pH"
  description: "pH Up/Down dosieren wenn außerhalb Range"
  trigger:
    platform: time_pattern
    minutes: "/30"
  condition:
    - condition: or
      conditions:
        - condition: numeric_state
          entity_id: sensor.hydroknoten_ph_wert
          below: !input_number ph_target
          value_template: "{{ float(trigger.payload_json) - 0.2 }}"
        - condition: numeric_state
          entity_id: sensor.hydroknoten_ph_wert
          above: !input_number ph_target
          value_template: "{{ float(trigger.payload_json) + 0.2 }}"
  action:
    - service: script.dose_ph_correction
      data:
        ph_target: !input_number ph_target

# ═══════════════════════════════════════════════════════════
# AUTO LÜFTER: VPD-basierte Steuerung
# ═══════════════════════════════════════════════════════════
- alias: "DiXY – Lüfter Auto VPD"
  description: "Inline-Lüfter basierend auf VPD + Temperatur"
  trigger:
    platform: state
    entity_id: sensor.zeltsensor_vpd
  action:
    - service: number.set_value
      target:
        entity_id: number.dosierung_inline_luefter_pwm
      data:
        value: >
          {% set vpd = states('sensor.zeltsensor_vpd') | float(0) %}
          {% set air_temp = states('sensor.zeltsensor_lufttemperatur') | float(0) %}
          
          {# Temperatur-Override #}
          {% if air_temp > 28 %}
            {{ [((vpd - 0.4) / 0.8 * 100) | int(0), 50] | max }}
          {% elif air_temp > 32 %}
            100
          
          {# VPD-basiert #}
          {% elif vpd > 1.2 %}
            100
          {% elif vpd < 0.4 %}
            0
          {% else %}
            {{ ((vpd - 0.4) / 0.8 * 100) | int(0) }}
          {% endif %}

# ═══════════════════════════════════════════════════════════
# WARNUNG: EC/pH Out of Range
# ═══════════════════════════════════════════════════════════
- alias: "DiXY – Alert EC/pH Kritisch"
  description: "Benachrichtigung wenn EC/pH außerhalb Range"
  trigger:
    - platform: numeric_state
      entity_id: sensor.hydroknoten_ec_wert
      below: 0.8
    - platform: numeric_state
      entity_id: sensor.hydroknoten_ec_wert
      above: 2.5
    - platform: numeric_state
      entity_id: sensor.hydroknoten_ph_wert
      below: 5.5
    - platform: numeric_state
      entity_id: sensor.hydroknoten_ph_wert
      above: 7.0
  action:
    - service: notify.persistent_notification
      data:
        title: "⚠️ DiXY RDWC – EC/pH Alarm"
        message: >
          EC: {{ states('sensor.hydroknoten_ec_wert') }} mS/cm
          pH: {{ states('sensor.hydroknoten_ph_wert') }} pH

# ═══════════════════════════════════════════════════════════
# WARNUNG: Tank Leer
# ═══════════════════════════════════════════════════════════
- alias: "DiXY – Alert Tank Leer"
  description: "Warnung wenn Wasserstand-Sensor Tank leer meldet"
  trigger:
    platform: state
    entity_id: binary_sensor.hydroknoten_tank_leer
    to: "on"
  action:
    - service: notify.persistent_notification
      data:
        title: "🚨 DiXY RDWC – TANK LEER!"
        message: >
          Mindestens einer der 6 Tanks ist leer.
          Bitte sofort nachfüllen!

# ═══════════════════════════════════════════════════════════
# WARNUNG: VPD Kritisch
# ═══════════════════════════════════════════════════════════
- alias: "DiXY – Alert VPD Kritisch"
  description: "Warnung wenn VPD < 0.4 (Fungus) oder > 1.6 (Stress)"
  trigger:
    - platform: numeric_state
      entity_id: sensor.zeltsensor_vpd
      below: 0.4
    - platform: numeric_state
      entity_id: sensor.zeltsensor_vpd
      above: 1.6
  action:
    - service: notify.persistent_notification
      data:
        title: "⚠️ VPD Kritisch!"
        message: >
          VPD: {{ states('sensor.zeltsensor_vpd') }} kPa
          Lufttemp: {{ states('sensor.zeltsensor_lufttemperatur') }} °C
          RH: {{ states('sensor.zeltsensor_luftfeuchte') }} %

# ═══════════════════════════════════════════════════════════
# SENSOR FEHLER: ADS1115
# ═══════════════════════════════════════════════════════════
- alias: "DiXY – Health Alert ADS1115"
  description: "Warnung wenn ADS1115 ADC offline"
  trigger:
    platform: state
    entity_id: binary_sensor.hydroknoten_ads1115_fehler
    to: "on"
  action:
    - service: notify.persistent_notification
      data:
        title: "🔴 Sensor-Fehler: ADS1115"
        message: "EC/pH Sensor antwortet nicht. I2C-Kabel prüfen."

# ═══════════════════════════════════════════════════════════
# DAILY RESET: Tages-Counter Mitternacht
# ═══════════════════════════════════════════════════════════
- alias: "DiXY – Daily Reset Counter"
  description: "Tages-Counter um 00:00 UTC zurücksetzen"
  trigger:
    platform: time
    at: "00:00:00"
  action:
    - service: button.press
      target:
        entity_id: button.dosierung_daily_reset

# ═══════════════════════════════════════════════════════════
# KAMERA: Stündlicher Canopy-Snapshot
# ═══════════════════════════════════════════════════════════
- alias: "DiXY – Canopy Snapshot Hourly"
  description: "Stündliche Canopy Top-Down Snapshots für Timelapse"
  trigger:
    platform: time_pattern
    hours: "*"
    minutes: "0"
  action:
    - service: camera.snapshot
      target:
        entity_id: camera.canopy_camera
      data:
        filename: "/config/snapshots/canopy_{{ now().strftime('%Y%m%d_%H%M%S') }}.jpg"

# ═══════════════════════════════════════════════════════════
# KAMERA: 4x Daily Detail-Snapshots
# ═══════════════════════════════════════════════════════════
- alias: "DiXY – Detail Camera 4x Daily"
  description: "Detail Blatt-Snapshots um 08:00, 14:00, 20:00, 02:00"
  trigger:
    - platform: time
      at: "08:00:00"
    - platform: time
      at: "14:00:00"
    - platform: time
      at: "20:00:00"
    - platform: time
      at: "02:00:00"
  action:
    - service: camera.snapshot
      target:
        entity_id: camera.detail_camera
      data:
        filename: "/config/snapshots/detail_{{ now().strftime('%Y%m%d_%H%M%S') }}.jpg"
    # Optional: Flash LED einschalten für 02:00
    - condition: time
      at: "02:00:00"
      action:
        - service: switch.turn_on
          target:
            entity_id: switch.detail_camera_led
```

---

## 📋 Input Numbers & Selects

```yaml
# input_numbers.yaml
# Home Assistant Input Numbers für Ziele + Parameter

input_number:
  ec_target:
    name: "EC Soll (mS/cm)"
    unit_of_measurement: mS/cm
    min: 0.5
    max: 3.0
    step: 0.1
    initial: 1.5
    icon: mdi:water-circle
    mode: slider

  ph_target:
    name: "pH Soll"
    unit_of_measurement: pH
    min: 5.0
    max: 7.5
    step: 0.1
    initial: 6.0
    icon: mdi:water-percent
    mode: slider

  rdwc_system_liters:
    name: "RDWC System-Volumen (L)"
    unit_of_measurement: L
    min: 10
    max: 500
    step: 5
    initial: 50
    icon: mdi:water-alert
    mode: slider

  photoperiode_stunden:
    name: "Photoperiode (Stunden)"
    unit_of_measurement: h
    min: 12
    max: 24
    step: 1
    initial: 18
    icon: mdi:weather-sunny
    mode: slider
```

---

## 🚀 Quick Start Installation

1. **Kopiere die YAML-Dateien:**
   ```bash
   cp -r Home-Assistant/dashboards/* ~/.homeassistant/dashboards/
   cp Home-Assistant/automations.yaml ~/.homeassistant/automations/dixy_rdwc.yaml
   cp Home-Assistant/input_numbers.yaml ~/.homeassistant/input_numbers.yaml
   ```

2. **Updatet `configuration.yaml`:**
   ```yaml
   automation: !include automations/dixy_rdwc.yaml
   input_number: !include input_numbers.yaml
   input_select: !include input_selects.yaml
   ```

3. **HA Restart:**
   ```bash
   Developer Tools → YAML → Restart Home Assistant
   ```

4. **Dashboard öffnen:**
   - Home Assistant → Dashboards → DiXY RDWC Monitor

---

**Nächste Schritte:**
- [ ] Automations testen mit `Developer Tools → Services`
- [ ] Kalibrierungs-Targets einstellen (EC, pH, DLI)
- [ ] Snapshot-Pfade prüfen (müssen existieren)
- [ ] Telegram/Email Notifications konfigurieren (optional)
