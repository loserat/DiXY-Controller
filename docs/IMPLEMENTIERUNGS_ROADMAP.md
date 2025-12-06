# DiXY RDWC Controller – Implementierungs-Roadmap

**Stand:** 06.12.2025  
**Zeithorizont:** Nächste Tage bis Wochen (iterativ bei Platinen-Fertigstellung)  
**Tempo:** Flexibel, abhängig von Hardware-Verfügbarkeit

---

## 📅 Phase 1: Sofort (Nächste 3–5 Tage)

### ✅ Abgeschlossen (Stand heute)
- Hydroknoten v0.2-beta (Config + Health + Timestamps)
- Dosierknoten v0.2-beta (Config + Safety + Lifetime Stats)
- Zeltsensor v0.2-beta (Config + PPFD + VPD + Lüfter-Auto)
- Release Notes aktualisiert für alle drei Knoten

### 🔜 Zu tun diese Woche

#### 1. Klimaknoten auf v0.2 upgraden
**Arbeitsaufwand:** 30 Min (kopiere Struktur von Zeltsensor)
- [ ] Header auf v0.2-beta
- [ ] WiFi Diagnostics (SSID/BSSID/MAC/Signal)
- [ ] Health-Binaries (I2C: SHT31, MLX90614, BMP280)
- [ ] System Sensoren (Uptime, Free Heap, Chip Temp)
- [ ] Buttons (Restart, Safe Mode)
- [ ] Text Sensoren (WiFi-Info, Version, Status-Summary)
- [ ] Release Notes Abschnitt hinzufügen
- [ ] Projekt-Version: v0.2-beta im YAML

**Nächster Knoten:** Klimaknoten v0.2 YAML prüfen & patchen

#### 2. Kamera Canopy auf v0.2 upgraden
**Arbeitsaufwand:** 20 Min (minimal, nur Meta)
- [ ] Header auf v0.2-beta
- [ ] WiFi Diagnostics (Signal, SSID, IP)
- [ ] System Sensoren (Uptime, Signal Strength)
- [ ] Health-Binary (Online/Offline)
- [ ] Buttons (Restart, Safe Mode)
- [ ] Projekt-Version: v0.2-beta
- [ ] Release Notes Abschnitt

**Hinweis:** ESP32-CAM hat weniger Speicher, minimale Entities

#### 3. Kamera Detail auf v0.2 upgraden
**Arbeitsaufwand:** 20 Min (identisch mit Canopy)
- [ ] Header → v0.2-beta
- [ ] WiFi + System Sensoren
- [ ] Health + Buttons
- [ ] Release Notes

---

## 📅 Phase 2: Kalibrierungs-Vorbereitung (Woche 1–2)

### Hardware-Checklist beim Eintreffen jeder Platine

#### Beim Hydroknoten-Setup
- [ ] **Spannungsprüfung:** 3.3V an ADS1115 + SSD1306
- [ ] **OLED-Test:** Display zeigt Boot-Text
- [ ] **Encoder-Test:** Rotary Encoder Bewegung → Menü reagiert
- [ ] **Sensor-Anschlüsse prüfen:**
  - [ ] EC-Sensor an ADS1115 A0 (0–3.3V Spannung)
  - [ ] pH-Sensor an ADS1115 A1 (0–3.3V Spannung)
  - [ ] DS18B20 OneWire korrekt gepinnt
  - [ ] 6x Wasserstand-Sensoren GPIOs funktionieren
- [ ] **I2C-Scan:** HS bestätigt 0x3C (OLED) + 0x48 (ADS1115)
- [ ] **WLAN:** Node verbindet sich, IP zugewiesen
- [ ] **HA-Entities:** Alle Sensoren/Binaries/Texte sichtbar

#### Beim Dosierknoten-Setup
- [ ] **SPI-Bus Prüfung:** MCP4131 reagiert (CS-Pulses)
- [ ] **Pumpen-Test:**
  - [ ] Jede PWM-Pin einzeln testen (0–100% manuell in HA)
  - [ ] Pumpen-Laufzeit kalibrieren (ml/s messen)
- [ ] **Rührmotor-Test:** MCP4131 Poti für Stirrer funktioniert
- [ ] **WLAN + HA:** Verbindung zu Hydroknoten über API
- [ ] **Entities:** Alle Numbers, Switches, Buttons vorhanden

#### Beim Zeltsensor-Setup
- [ ] **I2C-Scan:** 0x39 (AS7341), 0x44 (SHT31), 0x76 (BMP280) erkannt
- [ ] **AS7341 Initialisierung:** Keine I2C-Fehler, Kanäle lesen
- [ ] **SHT31 Basislinie:** Temperatur + RH plausibel
- [ ] **BMP280 Druck:** Luftdruck realistisch (890–1050 hPa)
- [ ] **PPFD Kalibrierung (optional):** Mit Apogee Quantum Sensor vergleichen
- [ ] **Lüfter-PWM (wenn angeschlossen):** GPIO25 testet (0–100%)
- [ ] **WiFi + HA:** Verbindung, alle Entities sichtbar

---

## 📅 Phase 3: Kalibrierung & Validierung (Woche 2–3)

### Hydroknoten Kalibrierung

#### EC-Kalibrierung
**Voraussetzung:** Zwei EC-Referenzlösungen (1.413 mS/cm Low, 12.88 mS/cm High)

1. **Vorbereitung:**
   - [ ] EC-Sensor in 1.413-Lösung platzieren
   - [ ] Display HOME → Hauptmenü (Encoder Klick)
   - [ ] Option "2) EC Kalibrieren" wählen
   - [ ] Low-Punkt: Encoder drehen bis Spannung stabil (±0.01V), Button drücken
   - [ ] High-Punkt: Zu 12.88er-Lösung wechseln, wiederholen

2. **Validierung:**
   - [ ] EC-Wert Home-Screen zeigt ≈1.413 mS/cm in Low-Lösung
   - [ ] EC-Wert zeigt ≈12.88 mS/cm in High-Lösung
   - [ ] Abweichung <2% akzeptabel

3. **Timestamp setzen:**
   - [ ] Button "EC Kalibrierung markieren" in HA drücken
   - [ ] Text-Sensor "EC Kalibrierung zuletzt" zeigt Datum/Uhrzeit

#### pH-Kalibrierung
**Voraussetzung:** Zwei pH-Puffer (pH 4.0 + pH 7.0)

1. **Vorbereitung:**
   - [ ] pH-Sensor in pH 7.0 Puffer platzieren
   - [ ] Menü: Option "3) pH Kalibrieren"
   - [ ] pH7: Encoder justieren, Button drücken
   - [ ] pH4 Puffer: Sensor einlegen, justieren, speichern

2. **Validierung:**
   - [ ] pH-Wert pH 4.0 Puffer zeigt 4.0 ±0.2 pH
   - [ ] pH-Wert pH 7.0 Puffer zeigt 7.0 ±0.2 pH
   - [ ] Zwischen-Bereich linear

3. **Timestamp setzen:**
   - [ ] Button "pH Kalibrierung markieren" drücken
   - [ ] Text-Sensor aktualisiert

#### Temperatur-Offset Kalibrierung
1. [ ] Beide DS18B20 mit referentem Thermometer vergleichen
2. [ ] Falls Abweichung: Menü "4) Offsets anpassen" → T1/T2 korrigieren
3. [ ] Flash speichert Werte persistent

### Dosierknoten Kalibrierung

#### Flow-Rate Kalibrierung (KRITISCH!)
**Vorbereitung:** Messzylinder, Stoppuhr, Wasser

**Pro Pumpe (A, B, C, D):**
1. [ ] Schlauch in leeren Becher
2. [ ] In HA: Switch "Pumpe A On" → 10s laufen lassen
3. [ ] Wasser messen: Z.B. 15ml in 10s → 1.5 ml/s
4. [ ] Number "Pumpe A Flow Rate" in HA = 1.5 speichern
5. [ ] Wiederhole für B, C, D

#### Wirksamkeits-Kalibrierung
**EC-Wirksamkeit (Pumpe A):**
1. [ ] System-Volumen: Z.B. 50L (Number in HA)
2. [ ] EC-Soll setzen: 1.5 mS/cm (input_number.ec_target)
3. [ ] Aktuelle EC messen: 0.0 mS/cm
4. [ ] 10ml EC-Dünger manuell dosieren → Hydroknoten misst Anstieg
5. [ ] Beispiel: +0.2 mS/cm nach 10ml → Wirksamkeit = 0.2/10 = 0.02 mS/cm pro ml
6. [ ] Number "Pumpe A EC Effectiveness" = 0.02 speichern

**pH-Wirksamkeit (Pumpe B + C):**
- Identisches Prinzip mit pH-Puffer + pH-Sensor

#### Safety-Limits setzen
- [ ] `max_dose_per_cycle`: Basierend auf EC-Volatilität (z.B. 20ml)
- [ ] `max_ml_per_day`: Conservativ (z.B. 100ml bei 50L System)
- [ ] `min_stir_time`: 180s (Standard, nicht ändern)
- [ ] `full_mix_time`: 300s (Standard, nicht ändern)

### Zeltsensor Validierung

#### PPFD-Kalibrierung
**Wenn Apogee Quantum Sensor verfügbar:**
1. [ ] Beide Sensoren unter gleicher Lampe
2. [ ] AS7341 misst Z.B. PPFD_raw = 500
3. [ ] Apogee misst Z.B. PPFD = 1000 µmol/m²/s
4. [ ] ppfd_cal_factor = 1000 / 500 = 2.0
5. [ ] Im YAML: `ppfd_cal_factor: "2.0"` aktualisieren

**Hinweis:** Default 0.003415 ist Schätzung; echte Kalibrierung erhöht Genauigkeit um 10–15%

#### VPD-Validierung
1. [ ] Temperatur + RH manuell mit Hygrometer prüfen
2. [ ] VPD-Berechnung: (Sättigung – Aktuell) sollte Logik folgen
3. [ ] Beispiel: 25°C + 65% RH → VPD ≈ 0.85 kPa (angemessen für Veg)

#### Photoperiode einstellen
- [ ] In HA: Number "Photoperiode (Stunden)" = 18 (Veg) oder 12 (Blüte)
- [ ] DLI wird automatisch neu berechnet

---

## 📅 Phase 4: Integration & Automation (Woche 3–4)

### Home Assistant Automationen

#### EC/pH Auto-Dosierung aktivieren
```yaml
automation:
  - alias: "RDWC – Auto Dosierung EC"
    trigger:
      platform: time_pattern
      minutes: "/30"  # Alle 30 Min prüfen
    condition:
      - condition: numeric_state
        entity_id: sensor.hydroknoten_ec_wert
        below: !input_number rc_ec_target
    action:
      - service: script.dose_ec_nutrients
        data:
          system_volume: !input_number rdwc_system_liters
```

#### VPD-basierte Lüfter-Steuerung (Zeltsensor)
```yaml
automation:
  - alias: "Zelt – Lüfter Auto VPD"
    trigger:
      platform: state
      entity_id: sensor.zeltsensor_vpd
    action:
      - service: number.set_value
        data:
          entity_id: number.zeltsensor_fan_pwm
          value: >
            {% set vpd = states('sensor.zeltsensor_vpd') | float %}
            {% if vpd > 1.2 %}
              100
            {% elif vpd < 0.4 %}
              0
            {% else %}
              {{ ((vpd - 0.4) / 0.8 * 100) | int }}
            {% endif %}
```

#### Nährstoff-Warnungen
```yaml
automation:
  - alias: "Alert – EC/pH Out of Range"
    trigger:
      - platform: numeric_state
        entity_id: sensor.hydroknoten_ec_wert
        below: 1.0
      - platform: numeric_state
        entity_id: sensor.hydroknoten_ph_wert
        below: 5.5
      - platform: numeric_state
        entity_id: sensor.hydroknoten_ph_wert
        above: 6.8
    action:
      - service: notify.telegram
        data:
          message: "⚠️ EC/pH kritisch!"
```

### Daten-Logging (Optional aber empfohlen)

#### History Stats für Trends
- [ ] EC/pH/Temp/RH täglich aufzeichnen
- [ ] Weekly Summary erstellen (Durchschnitte)
- [ ] Monthly Report für Vergleiche

#### Grafana / InfluxDB Integration (Advanced)
- [ ] InfluxDB als Long-Term Storage
- [ ] Grafana Dashboards für PPFD, VPD, EC, Wachstum
- [ ] Prognose-Modelle (Optional: ML)

---

## 📅 Phase 5: Kamera-Integration (Woche 4–5)

### Canopy-Kamera Setup

#### Snapshot-Automation
```yaml
automation:
  - alias: "Canopy – Hourly Snapshot"
    trigger:
      platform: time_pattern
      hours: "*"
      minutes: "0"
    action:
      - service: camera.snapshot
        data:
          entity_id: camera.canopy_camera
          filename: "/config/snapshots/canopy_{{ now().strftime('%Y%m%d_%H%M%S') }}.jpg"
```

#### Timelapse-Script (Python in HA)
```python
# /config/custom_components/dixy_timelapse/timelapse.py
import cv2
import glob
from pathlib import Path

def create_timelapse(image_dir, output_file, fps=2):
    """Erstellt Timelapse aus Snapshot-Serie"""
    images = sorted(glob.glob(f"{image_dir}/*.jpg"))
    if not images:
        return False
    
    frame = cv2.imread(images[0])
    h, w = frame.shape[:2]
    
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_file, fourcc, fps, (w, h))
    
    for img in images:
        out.write(cv2.imread(img))
    
    out.release()
    return True
```

### Detail-Kamera Setup

#### HSV-Blattfarben-Analyse
```python
# /config/custom_components/dixy_leaf_health/hsv_analysis.py
import cv2
import numpy as np

def analyze_leaf_health(image_path):
    """Berechnet Green/Yellow/Brown Prozentanteile"""
    img = cv2.imread(image_path)
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    
    # Green: H 35–85
    green_mask = cv2.inRange(hsv, (35, 40, 40), (85, 255, 255))
    green_pct = np.sum(green_mask) / green_mask.size * 100
    
    # Yellow: H 20–35
    yellow_mask = cv2.inRange(hsv, (20, 40, 40), (35, 255, 255))
    yellow_pct = np.sum(yellow_mask) / yellow_mask.size * 100
    
    # Brown: H 10–20
    brown_mask = cv2.inRange(hsv, (10, 40, 40), (20, 255, 255))
    brown_pct = np.sum(brown_mask) / brown_mask.size * 100
    
    return {
        "green": green_pct,
        "yellow": yellow_pct,
        "brown": brown_pct
    }
```

#### Snapshot-Schedule (4x täglich)
```yaml
automation:
  - alias: "Detail – Morning Snapshot (08:00)"
    trigger:
      platform: time
      at: "08:00:00"
    action:
      - service: camera.snapshot
        target:
          entity_id: camera.detail_camera
        data:
          filename: "/config/snapshots/detail_{{ now().strftime('%Y%m%d_%H') }}.jpg"
```

---

## 🛠️ Troubleshooting & Fehlerbehandlung

### Wenn Platinen eintreffen

#### Häufige Probleme
| Problem | Lösung |
|---------|--------|
| **WLAN verbindet nicht** | Password in secrets.yaml prüfen, AP-SSID zurücksetzen |
| **I2C-Adressen Konflikt** | `scan: true` in YAML, `esphome logs` Ausgabe prüfen |
| **Sensor zeigt NaN** | Pin-Verbindung prüfen, Spannung messen, ggf. Pull-up Widerstände |
| **ADS1115 liest 0V** | EC/pH-Kabel angeschlossen? Bridging-Jumper geprüft? |
| **Pumpe läuft nicht** | PWM-Pin testen, MCP4131 SPI Verbindung, CS-Pins |
| **PPFD zu niedrig/hoch** | `ppfd_cal_factor` Kalibrierung, AS7341 I2C Timing |
| **VPD berechnet falsch** | Temperatur + RH Baseline-Check, Magnus-Formel verifizieren |

### Debugging-Workflow
1. [ ] **ESPHome Logs:** `esphome logs hydroknoten.yaml` → Fehler-Meldungen
2. [ ] **HA Developer Tools → States:** Entity-Werte prüfen (NaN? Null?)
3. [ ] **Multimeter:** Spannungen an Sensoren messen (0–3.3V)
4. [ ] **I2C-Scan:** `esphome logs` → `I2C scan` Ausgabe zeigt Geräte
5. [ ] **Serial Monitor:** USB-Anschluss direkt am ESP32, 115200 Baud

---

## 📊 Gantt-Zeitleiste (Grobe Schätzung)

```
Woche 1 (06.–12. Dez)
├─ [✅] Phase 1: Klimaknoten + Kameras v0.2 Upgrade
├─ [📋] Hardware-Checklist vorbereiten
└─ [📋] Kalibrierungs-Material sammeln (EC-Lösungen, pH-Puffer)

Woche 2 (13.–19. Dez)
├─ [📋] Hydroknoten Hardware-Tests
├─ [📋] Dosierknoten Flow-Rate Kalibrierung
└─ [📋] Zeltsensor AS7341 Baseline

Woche 3 (20.–26. Dez)
├─ [📋] EC/pH Kalibrierung abgeschlossen
├─ [📋] Wirksamkeits-Kalibrierung (Dosierknoten)
└─ [📋] Erste Auto-Dosierung-Tests

Woche 4+ (27. Dez+)
├─ [📋] HA Automations implementieren
├─ [📋] Kamera-Integration (Snapshots, Timelapse)
└─ [📋] Monitoring-Dashboards aufbauen
```

---

## 🎯 Checkpoints & Go/No-Go Kriterien

### Go-Kriterium für Phase 2 (Kalibrierung Start)
- [ ] Alle 6 Knoten v0.2-beta mit Health-Checks
- [ ] Alle WiFi-Verbindungen stabil
- [ ] HA erkennt mindestens 80% der Entities
- [ ] Keine I2C-Fehler in Logs

### Go-Kriterium für Phase 3 (Auto-Dosierung)
- [ ] EC/pH Kalibrierung ±2% Genauigkeit
- [ ] Flow-Rate alle 4 Pumpen ±5% Konsistenz
- [ ] Rührzeit-Logik testet OK (3 Min min, 5 Min Durchmischung)
- [ ] Hydroknoten Online-Check funktioniert

### Go-Kriterium für Phase 4 (Produktion)
- [ ] 5+ Tage stabile EC/pH-Regelung ohne manuales Eingreifen
- [ ] VPD-basierte Lüfter-Steuerung ±0.2 kPa Zielbereich
- [ ] Kamera-Snapshots täglich ohne Fehler
- [ ] Keine Safety-Warnungen ausgelöst (Limits sind sinnvoll)

---

## 💡 Tipps für reibungslosen Ablauf

1. **Fotografiere alles:** Screenshots von erfolgreichen Kalibrierungen, Fehler-Logs
2. **Gitlog Commits:** Nach jeder Kalibrierungs-Phase committen (`git add -A && git commit -m "v0.2-beta: Phase 3 Hydroknoten Kalibrierung abgeschlossen"`)
3. **Backup sekrets.yaml:** Nur lokal, nie in Git
4. **Test-Automations in HA:** Mit Service-Calls testen, bevor vollständig Auto-schalten
5. **Daten-Logging aktivieren:** Hilft später bei Anomalie-Erkennung
6. **Weekly Status:** Jeden Sonntag kurz festhalten: Was funktioniert, was fehlt noch

---

**Nächster Termin zur Absprache:** Nach Phase 1 (Upgrades) → Wenn erste Platinen eintreffen
