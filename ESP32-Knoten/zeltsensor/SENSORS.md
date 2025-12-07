# Zeltsensor v2 – Sensor-Dokumentation

## Licht-Spektralsensor (AS7341)

### Entity-IDs: Spektral-Kanäle
| Entity ID | Wellenlänge | Funktion |
|-----------|-------------|----------|
| `sensor.zeltsensor_v2_f1` | 405nm | Violet |
| `sensor.zeltsensor_v2_f2` | 425nm | Violet-Blue |
| `sensor.zeltsensor_v2_f3` | 450nm | Blue (Photosynthesis) |
| `sensor.zeltsensor_v2_f4` | 475nm | Blue-Cyan |
| `sensor.zeltsensor_v2_f5` | 500nm | Cyan (Photosynthesis) |
| `sensor.zeltsensor_v2_f6` | 550nm | Green |
| `sensor.zeltsensor_v2_f7` | 575nm | Green-Yellow |
| `sensor.zeltsensor_v2_f8` | 600nm | Orange (Photosynthesis) |
| `sensor.zeltsensor_v2_clear` | Visible | White Light |
| `sensor.zeltsensor_v2_nir` | 845nm | Near-Infrared |

### Berechnung PPFD (Photons/m²/s)

```
PPFD = Σ(F1–F8, Clear) × calibration_factor
     = SUM(channels) × 0.003415

Kalibrierung:
- Referenz: Apogee Quantum Sensor
- Umgebung: direktes Sonnenlicht, 1000 µmol/m²/s
- Anpassung: ppfd_cal_factor substitution
```

**Entity ID:** `sensor.zeltsensor_v2_ppfd`
- Einheit: µmol/m²/s
- Update: 30s
- Bereich: 0–3000

### Berechnung DLI (Daily Light Integral)

```
DLI = PPFD × Photoperiod (h) × 3600s/h / 1.000.000
    = PPFD × P × 3.6 (wenn P in Stunden)

z.B.: PPFD 500 µmol/m²/s × 18h Photoperiod
    = 500 × 18 × 3.6 = 32.400 µmol/m²/d
```

**Entity ID:** `sensor.zeltsensor_v2_dli`
- Einheit: mol/m²/d
- Update: 60s (nach Photoperiod-Change)
- Bereich: 0–60

### PAR (Photosynthetically Active Radiation)

```
PAR [400–700nm] = Integral(F1–F8) 
                = Wirksame Kanäle für Photosynthese
```

**Entity ID:** `sensor.zeltsensor_v2_par`
- Einheit: % (relativ zu Clear)
- Update: 30s

---

## Klima-Sensoren

### Lufttemperatur & Feuchte (SHT31)

| Entity ID | Typ | Bereich | Update |
|-----------|-----|---------|--------|
| `sensor.zeltsensor_v2_lufttemperatur` | Float | -20–80°C | 30s |
| `sensor.zeltsensor_v2_luftfeuchte` | Float | 0–100% RH | 30s |

### Luftdruck (BMP280)

| Entity ID | Bereich | Update |
|-----------|---------|--------|
| `sensor.zeltsensor_v2_luftdruck` | 300–1100 hPa | 60s |
| `sensor.zeltsensor_v2_hoehe_berechnet` | -500–5000m | 60s |

### Blatt-Temperatur (MLX90614, optional)

| Entity ID | Typ | Bereich | Update | Bemerkung |
|-----------|-----|---------|--------|-----------|
| `sensor.zeltsensor_v2_blatt_temp_mlx1` | IR | -20–85°C | 10s | Oben |
| `sensor.zeltsensor_v2_blatt_temp_mlx2` | IR | -20–85°C | 10s | Unten (optional) |

---

## Berechnete Größen

### VPD (Vapor Pressure Deficit)

**Magnus-Formel:**
```
Magnus Constants: a=17.27, b=237.7°C

SVP(T) = 6.112 × exp(aT/(b+T))
VPD = SVP(Leaf) - SVP(Air)
```

**Entity ID:** `sensor.zeltsensor_v2_vpd`
- Einheit: kPa
- Update: 30s
- Optimal für Cannabis: 0.8–1.2 kPa
- Optimal für Gemüse: 1.0–1.5 kPa

### Taupunkt

```
Td = (b × ln(RH/100 + a×T/(b+T))) / (a - ln(RH/100 + a×T/(b+T)))
```

**Entity ID:** `sensor.zeltsensor_v2_taupunkt`
- Einheit: °C
- Update: 30s
- Indikator für Schimmelrisiko

---

## Lüfter-Steuerung

### Fan Auto-Regelung

| Entity ID | Typ | Funktion |
|-----------|-----|----------|
| `switch.zeltsensor_v2_fan_auto_enabled` | Toggle | Enable/Disable Auto |
| `number.zeltsensor_v2_fan_min_percent` | Slider | Min 20% |
| `number.zeltsensor_v2_fan_max_percent` | Slider | Max 100% |
| `number.zeltsensor_v2_fan_vpd_target` | Slider | Sollwert VPD |

**Logik:**
```
if (VPD < target_vpd):
    fan_pct = min_percent
else:
    fan_pct = map(VPD, target_vpd, target_vpd+0.5kPa, min%, max%)
```

### Fan PWM Output

**Entity ID:** `fan.zeltsensor_v2_inline_fan`
- GPIO: 25 (0–10V via DAC Converter)
- Frequenz: ~1000 Hz
- Range: 0–100%

### Fan Tacho (RPM, optional)

**Entity ID:** `sensor.zeltsensor_v2_fan_rpm`
- GPIO: 23 (Pulse Input)
- Update: 10s

---

## CO₂-Sensor (MH-Z19B, optional)

| Entity ID | Bereich | Update |
|-----------|---------|--------|
| `sensor.zeltsensor_v2_co2_ppm` | 400–5000 ppm | 30s |

**UART:** GPIO16 (RX) / GPIO17 (TX), 9600 baud

**Kalibrierung:**
- Outdoor Zero (400 ppm): Button "CO₂ Zero Cal"
- Typical Range: 400–1000 ppm (optimiert)

---

## WiFi & System

| Entity ID | Update |
|-----------|--------|
| `sensor.zeltsensor_v2_wifi_signal` | 60s |
| `sensor.zeltsensor_v2_uptime` | 60s |

---

## Home Assistant Automations

### Lüfter Auto basiert auf VPD

```yaml
automation:
  - alias: "Fan Auto VPD"
    trigger:
      platform: numeric_state
      entity_id: sensor.zeltsensor_v2_vpd
      above: 1.2
    action:
      - service: fan.turn_on
        target:
          entity_id: fan.zeltsensor_v2_inline_fan
        data:
          percentage: 75
```

### Alert bei schlechtem VPD

```yaml
automation:
  - alias: "VPD Alert"
    trigger:
      platform: numeric_state
      entity_id: sensor.zeltsensor_v2_vpd
      above: 1.5
      for: "00:10:00"
    action:
      - service: notify.telegram
        data:
          message: "⚠️ VPD {{ states('sensor.zeltsensor_v2_vpd') }} kPa - Fan erhöhen!"
```

### Light Cycle Automation

```yaml
automation:
  - alias: "Light ON"
    trigger:
      platform: time
      at: "06:00:00"
    action:
      - service: light.turn_on
        target:
          entity_id: light.zeltsensor_v2_grow_light
        data:
          brightness: 255

  - alias: "Light OFF"
    trigger:
      platform: time
      at: "24:00:00"
    action:
      - service: light.turn_off
        target:
          entity_id: light.zeltsensor_v2_grow_light
```

---

## Spezifikationen

| Parameter | Wert |
|-----------|------|
| AS7341 I2C Adresse | 0x39 |
| AS7341 Integration Time | 100ms (standard) |
| SHT31 I2C Adresse | 0x44 |
| BMP280 I2C Adresse | 0x76 |
| I2C Frequenz | 400 kHz |
| Sensor Update Cycle | 30s (Licht), 30s (Klima) |

