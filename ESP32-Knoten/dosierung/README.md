# Dosierung v2 – Intelligente Auto-Dosierung & Pumpensteuerung

## Funktion
Steuert 4 peristaltische Pumpen zur automatischen EC/pH-Dosierung basierend auf Hydroknoten-Messwerten. Integriert auch Rührmotor-Steuerung für Durchmischung. **MQTT + Home Assistant API für zentrale Steuerung.**

## Hardware
- **Microcontroller:** ESP32-DevKit (WiFi + MQTT + API)
- **Sensoren:** Dual DS18B20 Temperaturen (wie Hydroknoten)
- **ADS1115 Sensor:** EC/pH Analog-Input (wie Hydroknoten integriert)
- **Wasserstands-Sensoren:** 6x D1CS-D (wie Hydroknoten)
- **Pumpen:** 4x PWM LEDC Peristaltik (GPIO 25,26,27,16)
  - Pumpe A (GPIO25): EC-Dünger
  - Pumpe B (GPIO26): pH Down (Phosphorsäure)
  - Pumpe C (GPIO27): pH Up (Kaliumhydroxid)
  - Pumpe D (GPIO16): Additive (CalMag/Enzyme)
- **Rührmotor:** PWM LEDC (GPIO17, 1000 Hz)
- **Durchflussregler:** 0-10V PWM für DC Runner Aqua Medic (GPIO11)
- **Stepper-Motoren:** 4x NEMA17 via MCP23017 I2C Expander (optional, v0.3+)
- **Stromverwerfung:** ACS712 Current Sensors (GPIO 34-37, optional)
- **Status LED:** GPIO2
- **Versorgung:** 5V/2A empfohlen (Pumpen sind stromhungrig)

## Pinning
| Funktion | Pin | Typ | Bemerkung |
|----------|-----|-----|----------|
| Pumpe A | GPIO25 | LEDC PWM | 1000 Hz, 0–100% |
| Pumpe B | GPIO26 | LEDC PWM | 1000 Hz, 0–100% |
| Pumpe C | GPIO27 | LEDC PWM | 1000 Hz, 0–100% |
| Pumpe D | GPIO16 | LEDC PWM | 1000 Hz, 0–100% |
| Rührmotor | GPIO17 | LEDC PWM | 1000 Hz, 0–100% |
| DC Runner 0-10V | GPIO11 | LEDC PWM | 0–100% → 0–10V |
| Pumpe A Current | GPIO34 | ADC | ACS712-5A, optional |
| Pumpe B Current | GPIO35 | ADC | ACS712-5A, optional |
| Pumpe C Current | GPIO36 | ADC | ACS712-5A, optional |
| Pumpe D Current | GPIO37 | ADC | ACS712-5A, optional |
| UI Button 1 | GPIO38 | Digital | OK/Select |
| UI Button 2 | GPIO39 | Digital | Cancel/Back |
| UI Button 3 | GPIO40 | Digital | Up |
| UI Button 4 | GPIO41 | Digital | Down |
| Encoder CLK | GPIO19 | Pulse Counter | Menu Navigation |
| Encoder DT | GPIO18 | Digital | Encoder Data |
| Encoder SW | GPIO23 | Digital | Button |
| Stepper 1-4 DIR | MCP23017 0-6 | GPIO Expander | via I2C 0x20 |
| Stepper 1-4 STEP | MCP23017 1-7 | GPIO Expander | – |
| I2C SDA | GPIO21 | I2C | 400 kHz |
| I2C SCL | GPIO22 | I2C | 400 kHz |
| 1-Wire (Temp1) | GPIO4 | 1-Wire | DS18B20 |
| 1-Wire (Temp2) | GPIO5 | 1-Wire | DS18B20 |
| Tank Levels | GPIO32-15 | Digital | 6x D1CS-D |
| Status LED | GPIO2 | Output | – |

## Substitutions (Anpassbar)
```yaml
substitutions:
  device_name: dosierung_v2
  friendly_name: "Dosierung v2"
  project_version: "0.2-beta"
  
  # Pumpen Defaults
  pump_default_power_pct: "75"      # Default Power (0–100%)
  max_pump_duration_ms: "30000"     # Max 30 Sekunden pro Dosierung (Safety!)
  pump_shot_ms: "10000"             # Quick "Stoß" Button Duration (10s)
  
  # Alle GPIO Pins austauschbar für custom PCB
  pump_a_pin: "25"
  pump_b_pin: "26"
  pump_c_pin: "27"
  pump_d_pin: "16"
  stirrer_pin: "17"
  dc_runner_pwm_pin: "11"
  ... (siehe oben)
  
  # I2C Adressen
  ads1115_address: "0x48"
  mcp23017_address: "0x20"
```

## Dependencies
- **Dosierknoten braucht Hydroknoten:** EC/pH-Werte via HA API
  - Wenn Hydroknoten offline: Dosierung blockiert (Safety!)
- **Optional:** Stepper-Motoren für präzise Peristaltik-Pumpen-Alternativen
- **Optional:** ACS712 Current Sensors für Pump-Verifizierung (Ist Pumpe wirklich am laufen?)

## Dosierungs-Logik (Script: `dose_pump`)

### Safety Checks
1. **Tank nicht leer?** Blockiert sofort wenn `any_tank_empty` = TRUE
2. **Dauer begrenzt?** Max ${max_pump_duration_ms} = 30s pro Dosierung
3. **Power clamped?** 0–100%, default 75%

### Ablauf
```
1. MQTT-Befehl eingehen: dixy/dosierung_v2/cmd/dose
   Payload: {"pump":"A","duration_ms":5000,"power_pct":75}

2. Script `dose_pump` execute:
   - EC/pH-Regulierung (optional, Platzhalter)
   - PWM-Output setzen
   - delay(duration_ms)
   - PWM ausschalten
   
3. MQTT Response publish: dixy/dosierung_v2/state/last_dose
   Payload: {"pump":"A","ms":5000,"pct":75}
   
4. Globals Update:
   - pump_a_total_ml_today += geschätzt_ml
   - pump_a_cycles++
```

### MQTT-Interface
- **Command Topic:** `dixy/dosierung_v2/cmd/dose`
- **Status Topic:** `dixy/dosierung_v2/status` (online/offline)
- **Response Topic:** `dixy/dosierung_v2/state/last_dose`

### Home Assistant API Service
```yaml
# Service: esphome.dosierung_v2_dose_pump
service: esphome.dosierung_v2_dose_pump
data:
  pump: "A"           # A, B, C, D
  duration_ms: 5000   # 1–30000
  power_pct: 75       # 0–100 (optional, default 75)
```

## YAML-Varianten
- **`dosierung_v2.yaml`** – Produktiv (mit echten PWM-Pumpen + ACS712)
- **`dosierung_v2_sim.yaml`** – Simulation (Template-Sensoren, keine Hardware)

## Sensor-Dokumentation
→ Detaillierte Pump-Controls, Stepper-Status, Sollwerte siehe [`SENSORS.md`](SENSORS.md)

## Hardware-Verdrahtung
→ PWM-Pin Layout, MCP23017 Pinout, ACS712-Anschluss siehe [`hardware_wiring.md`](hardware_wiring.md)

## Troubleshooting

### Pumpen laufen nicht
**Ursachen:**
- `any_tank_empty` blockiert → Tank-Level prüfen
- PWM-Pin falsch
- ESP32 Stromversorgung unzureichend (2A min!)

**Lösung:**
1. `binary_sensor.dosierung_v2_tank_*` prüfen
2. MQTT-Command manuell testen: `mosquitto_pub -t dixy/dosierung_v2/cmd/dose -m '{"pump":"A","duration_ms":1000}'`
3. ESPHome Logs prüfen (GPIO-Konflikt?)
4. Stromversorgung kontrollieren (Spannungsabfall unter Last?)

### ACS712 Current immer 0
**Ursachen:**
- ADC-Pin falsch
- Conversion Factor falsch (0.185 für ACS712-5A)
- Sensor nicht angeschlossen

**Lösung:**
1. ADS-Pin ohne Sensor prüfen: sollte ~1.65V sein (Ruhespannung)
2. Sensor Pinout überprüfen (VCC/GND richtig?)
3. Multiplikator anpassen (0.185 für 5A Typ, 0.100 für 20A, etc.)

### Stepper-Motoren zucken
**Ursachen:**
- MCP23017 nicht erkannt (I2C-Adresse falsch?)
- GPIO-Expander keine Stromversorgung
- Step-Impuls zu kurz

**Lösung:**
1. I2C Scan: MCP23017 sollte auf 0x20 antworten
2. 5V-Versorgung für Expander überprüfen
3. `delay: 10ms` zwischen DIR und STEP halten

---

## Versionshistorie
- **v0.2-beta** (aktuell): Cleanup, MQTT/API, 4-Pump Support, Stepper Prep
- **v0.1-beta:** Initial mit HA-Integration

## Board-Support
- Arduino ESP32 Framework
- ESPHome 2024.1+
