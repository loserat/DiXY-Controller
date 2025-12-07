# Hydroknoten – Sensor-Dokumentation

Detaillierte Übersicht aller Sensoren, Entity-IDs, Messbereiche und Kalibrierung.

## Sensoren-Übersicht

| Entity ID | Typ | Bereich | Update | Einheit | Bemerkung |
|-----------|-----|---------|--------|---------|-----------|
| `sensor.hydroknoten_v2_ec` | Template | 0–20 | 10s | mS/cm | EC temperaturkompensiert auf 25°C |
| `sensor.hydroknoten_v2_ph` | Template | 0–14 | 10s | pH | Aus ADS1115 Voltage berechnet |
| `sensor.hydroknoten_v2_tank_temp` | Template | -20–80 | 15s | °C | DS18B20 + Offset |
| `sensor.hydroknoten_v2_ruecklauf_temp` | Template | -20–80 | 15s | °C | DS18B20 + Offset |
| `sensor.hydroknoten_v2_wifi_signal` | WiFi | -100–0 | 60s | dBm | Signal Strength |
| `sensor.hydroknoten_v2_uptime` | Uptime | 0–∞ | 60s | h | Laufzeit in Stunden |
| `sensor.hydroknoten_v2_mcu_temp` | Internal Temp | 0–100 | 30s | °C | Chip-Temperatur |
| `sensor.hydroknoten_v2_free_heap` | Template | 0–300 | 60s | kB | Freier Speicher |

## Sensoren im Detail

### 🧂 EC (Electrical Conductivity / Leitfähigkeit)

**Entity ID:** `sensor.hydroknoten_v2_ec`  
**Datentyp:** `float` (2 Dezimalstellen)  
**Bereich:** 0–20 mS/cm (praktisch: 0.5–3.0)  
**Update-Frequenz:** 10s  
**Einheit:** mS/cm (Millisiemens pro Zentimeter)

**Hardware:**
- ADS1115 Kanal A0 (Analog 0–3.3V)
- Atlas Scientific EC-Sensor
- Messbereich: 0–3300 µS/cm (0–3.3 mS/cm praktisch)

**Formel (Linearisierung):**
```
v = raw_voltage * 3.3  [V]
slope = (12.88 - 1.413) / (v_high - v_low)
offset = 1.413 - slope * v_low
ec = slope * v + offset
```

**Temperaturkompensation (auf 25°C):**
```
ec_25C = ec_measured / (1 + 0.0185 * (T - 25))
```
- T = gemessene Tank-Temperatur
- Standardformel für Hydrokultur (0.0185 = Temperaturkoeffizient)

**Kalibrierungspunkte (HA Slider):**
- `number.hydroknoten_v2_ec_cal_1_413ms` → Lower Point (1.413 mS/cm)
  - Bereich: 0.05–1.0 V
  - Initial: 0.104 V
- `number.hydroknoten_v2_ec_cal_12_88ms` → Higher Point (12.88 mS/cm)
  - Bereich: 1.0–3.3 V
  - Initial: 1.598 V

**Kalibrierungs-Ablauf:**
1. Sensor in 1.413 mS/cm Lösung tauchen
2. Wert stabil warten (10–15s)
3. Button "EC Kalibrierung markieren" drücken → `last_ec_cal_ts` gespeichert
4. Slider "EC Cal 1.413mS" auf aktuelle ADS-Spannung setzen
5. Wiederholen für 12.88 mS/cm
6. Validierung: EC sollte ±0.05 mS/cm genau sein

---

### 🧪 pH (Wasserstoff-Ionen-Konzentration)

**Entity ID:** `sensor.hydroknoten_v2_ph`  
**Datentyp:** `float` (2 Dezimalstellen)  
**Bereich:** 0–14 pH (praktisch: 4.0–8.0)  
**Update-Frequenz:** 10s  
**Einheit:** pH (log10 H⁺)

**Hardware:**
- ADS1115 Kanal A1 (Analog 0–3.3V)
- Atlas Scientific pH-Sensor
- Typ: Glas-Elektrode

**Formel (2-Punkt Linear):**
```
v = raw_voltage * 3.3  [V]
v7 = calibration_voltage_at_pH7
v4 = calibration_voltage_at_pH4
m = (4.0 - 7.0) / (v4 - v7)  [slope, negativ]
pH = m * (v - v7) + 7.0
```

**Kalibrierungspunkte (HA Slider):**
- `number.hydroknoten_v2_ph_cal_7_0` → Neutral Point (pH 7.0)
  - Bereich: 1.0–4.0 V
  - Initial: 2.50 V
- `number.hydroknoten_v2_ph_cal_4_0` → Acidic Point (pH 4.0)
  - Bereich: 1.0–4.0 V
  - Initial: 3.00 V

**Kalibrierungs-Ablauf:**
1. Sensor in pH 7.0 Pufferlösung tauchen
2. Wert stabil warten (5–10s)
3. Button "pH Kalibrierung markieren" drücken → `last_ph_cal_ts` gespeichert
4. Slider "pH Cal 7.0" auf aktuelle ADS-Spannung setzen
5. Sensor trocknen, in pH 4.0 Pufferlösung tauchen
6. Slider "pH Cal 4.0" anpassen
7. Validierung: pH sollte ±0.1 Einheiten genau sein

---

### 🌡️ Wassertemperatur (Tank)

**Entity ID:** `sensor.hydroknoten_v2_tank_temp`  
**Datentyp:** `float` (1 Dezimalstelle)  
**Bereich:** -20–80°C (praktisch: 15–30°C)  
**Update-Frequenz:** 15s  
**Einheit:** °C

**Hardware:**
- DS18B20 Digitales Temperatur-Sensor (1-Wire)
- GPIO4 (Bus 1)
- Auflösung: 0.0625°C (12-bit)

**Besonderheit:**
- `sensor.hydroknoten_v2_tank_temp_roh` (raw, ohne Offset)
- `sensor.hydroknoten_v2_tank_temp` (korrigiert mit Offset)
- Offset anpassbar via `number.hydroknoten_v2_temp1_offset` (±2°C, Schritte 0.1°C)

**Kalibrierungsverfahren:**
- Sensor neben Referenz-Thermometer (z.B. Spirit Level)
- Messwert stabil warten
- Offset = (Referenz) - (gemessen) setzen
- Beispiel: Referenz 24.5°C, Sensor zeigt 24.2°C → Offset = +0.3°C

---

### 🌡️ Rücklauf-Temperatur (Ambient)

**Entity ID:** `sensor.hydroknoten_v2_ruecklauf_temp`  
**Datentyp:** `float` (1 Dezimalstelle)  
**Bereich:** -20–80°C  
**Update-Frequenz:** 15s  
**Einheit:** °C

**Hardware:**
- DS18B20 Digitales Temperatur-Sensor (1-Wire)
- GPIO5 (Bus 2)

**Verwendung:** Umgebungstemperatur zur Diagnose (optional)

---

## Binary Sensoren (Wasserstände)

| Entity ID | Typ | Device Class | GPIO | Bemerkung |
|-----------|-----|--------------|------|-----------|
| `binary_sensor.hydroknoten_v2_tank_1_level` | GPIO | `moisture` | 32 | LOW=Wasser, Verzögerung 500ms on / 2s off |
| `binary_sensor.hydroknoten_v2_tank_2_level` | GPIO | `moisture` | 33 | D1CS-D Sensor |
| `binary_sensor.hydroknoten_v2_tank_3_level` | GPIO | `moisture` | 14 | – |
| `binary_sensor.hydroknoten_v2_tank_4_level` | GPIO | `moisture` | 12 | – |
| `binary_sensor.hydroknoten_v2_tank_5_level` | GPIO | `moisture` | 13 | – |
| `binary_sensor.hydroknoten_v2_tank_6_level` | GPIO | `moisture` | 15 | – |
| `binary_sensor.hydroknoten_v2_tank_leer_irgendeiner` | Template | `problem` | – | Logik: OR aller Tanks |

**Hardware:** D1CS-D Kapazitive Sensoren
- Messbereich: 0–30cm
- Output: Digital LOW (Wasser erkannt), HIGH (trocken)
- GPIO-Modus: INPUT_PULLUP, inverted: true
- Debouncing: 500ms on, 2s off (Stabilität)

---

## Health-Check Sensoren

| Entity ID | Device Class | Bedeutung |
|-----------|--------------|-----------|
| `binary_sensor.hydroknoten_v2_ads1115_ok` | `problem` | TRUE = Fehler! ADS1115 nicht lesbar |
| `binary_sensor.hydroknoten_v2_temp_sensoren_ok` | `problem` | TRUE = Fehler! DS18B20(s) offline |

Diese Sensoren helfen bei der Diagnose von Hardware-Ausfällen.

---

## Text Sensoren

| Entity ID | Inhalt | Update |
|-----------|--------|--------|
| `text_sensor.hydroknoten_v2_ip` | IP-Adresse | WiFi-Connect |
| `text_sensor.hydroknoten_v2_wlan` | SSID | WiFi-Connect |
| `text_sensor.hydroknoten_v2_bssid` | MAC-Adresse AP | WiFi-Connect |
| `text_sensor.hydroknoten_v2_mac` | MAC des Nodes | Startup |
| `text_sensor.hydroknoten_v2_esphome_version` | ESPHome Build | Startup |
| `text_sensor.hydroknoten_v2_projekt_version` | `0.2-beta` | 300s |
| `text_sensor.hydroknoten_v2_status_summary` | Live-String | 30s |

**Status Summary Beispiel:**
```
EC 1.60 mS/cm | pH 5.80 | T1 24.5C | T2 24.3C | WiFi -45 dBm
```

---

## Number Controls (Slider)

### Kalibrierung & Offsets

| Entity ID | Bereich | Schritt | Persistiert |
|-----------|---------|---------|-------------|
| `number.hydroknoten_v2_temp1_offset` | -2.0–2.0 | 0.1 | ✅ Ja |
| `number.hydroknoten_v2_temp2_offset` | -2.0–2.0 | 0.1 | ✅ Ja |
| `number.hydroknoten_v2_ec_cal_1_413ms` | 0.05–1.0 | 0.001 | ✅ Ja |
| `number.hydroknoten_v2_ec_cal_12_88ms` | 1.0–3.3 | 0.001 | ✅ Ja |
| `number.hydroknoten_v2_ph_cal_7_0` | 1.0–4.0 | 0.01 | ✅ Ja |
| `number.hydroknoten_v2_ph_cal_4_0` | 1.0–4.0 | 0.01 | ✅ Ja |

---

## Buttons

| Entity ID | Funktion |
|-----------|----------|
| `button.hydroknoten_v2_neustart` | Knoten neu starten |
| `button.hydroknoten_v2_ec_kalibrierung_markieren` | EC-Cal-Zeitstempel speichern |
| `button.hydroknoten_v2_ph_kalibrierung_markieren` | pH-Cal-Zeitstempel speichern |

---

## Fehlerbehebung

### EC springt wild
**Ursachen:**
- Kalibrierpunkte zu nah beieinander (beide 1.5–2.0V?)
- ADS-Gain falsch (aktuell: 6.144V)
- Sensor verschmutzt oder luftigen Blasen

**Lösung:**
1. Kalibrierpunkte testen: 1.413 mS/cm sollte ~0.1V, 12.88 mS/cm ~1.6V sein
2. Sensor spülen
3. ADS Gain ggf. auf 4.096 reduzieren (höhere Auflösung)

### pH konstant 0 oder 14
**Ursachen:**
- Kalibrierpunkte vertauscht (v4 < v7?)
- pH-Sensor offline
- Schlechte Elektrode-Kontakte

**Lösung:**
1. `ph_raw` in HA prüfen: sollte 1.0–3.0V sein
2. Elektrode-Stecker kontrollieren
3. Kalibrierpunkte neu setzen (Slider einzeln verschieben und beobachten)

### Tank-Level falsch
**Ursachen:**
- Sensor invertiert (LOW vs HIGH verwechselt)
- GPIO-Pin falsch
- Sensor zu nah/fern bei Montage

**Lösung:**
1. GPIO-Schaltplan überprüfen
2. Sensor mechanisch anders positionieren
3. `inverted: true` Togglen in YAML

### Temp-Sensoren "0.00" oder "–"
**Ursachen:**
- 1-Wire Pullup 4.7kΩ fehlt
- GPIO-Pin beschädigt
- DS18B20 nicht angesteckt

**Lösung:**
1. Pullup überprüfen (zwischen VCC und GPIO)
2. `dallas` Logs in ESPHome checken
3. Sensor physisch testen mit Multimeter

---

## Integrations-Beispiele (Home Assistant)

### Automation: EC zu hoch?
```yaml
automation:
  - alias: "EC über Sollwert"
    trigger:
      platform: numeric_state
      entity_id: sensor.hydroknoten_v2_ec
      above: 2.0
    action:
      service: notify.telegram
      data:
        message: "⚠️ EC zu hoch: {{ states('sensor.hydroknoten_v2_ec') }} mS/cm"
```

### Template Sensor: EC+pH Status
```yaml
template:
  - sensor:
      - name: "Nährlösung Status"
        unique_id: nutrient_status
        state: >
          {% if (states('sensor.hydroknoten_v2_ec') | float(0) > 2.0) or
                 (states('sensor.hydroknoten_v2_ph') | float(0) < 5.5) %}
            ⚠️ Anpassung nötig
          {% else %}
            ✅ OK
          {% endif %}
```

### History Stats: Tanks leer?
```yaml
sensor:
  - platform: history_stats
    name: "Tank 1 Zeit leer (heute)"
    entity_id: binary_sensor.hydroknoten_v2_tank_1_level
    state: "off"
    type: time
    period:
      days: 1
```

---

## Technische Spezifikationen

| Parameter | Wert | Einheit |
|-----------|------|---------|
| Messzyklus EC/pH | 1 | s |
| Ausgabe-Update EC/pH | 10 | s |
| Mess-Zyklus Temp | 15 | s |
| WiFi Abfrage | 60 | s |
| I2C Takt | 400 | kHz |
| 1-Wire Timeout | 30 | s |
| Debounce Tank-Level | 500/2000 | ms on/off |

