# KI-Logik: DiXY Plant Stress Detection System

## Übersicht

Das DiXY-System verwendet einen **3-stufigen KI-Ansatz** zur Pflanzenüberwachung:

1. **v0.1 (Regelbasiert):** `plant_stress_detector.py` - Schwellenwert-basierte Analyse
2. **v0.2 (ML-Hybrid):** Geplant - Scikit-learn für Mustervorhersage
3. **v1.0 (Deep Learning):** Langfristig - CNN für Bildanalyse

Diese Dokumentation fokussiert auf **v0.1 (regelbasiert)**, den aktuellen Produktionsstatus.

---

## Architektur: plant_stress_detector.py

### Datenfluss

```
┌─────────────────────────────────────────────────────┐
│  INPUT: Home Assistant State API                    │
│  - 40+ Sensor-Entities (EC, pH, VPD, Temp, etc.)   │
│  - 2x Kamera-Snapshots (Canopy + Detail)           │
│  - input_select.growth_stage (7 Phasen)            │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│  ANALYSE-PIPELINE (5min Intervall)                  │
│                                                      │
│  1. detect_growth_stage()                           │
│     → Auto-Detection oder manuell                   │
│                                                      │
│  2. analyze_sensors()                               │
│     → EC, pH, VPD, Temp vs STAGE_TARGETS           │
│                                                      │
│  3. analyze_water_consumption()                     │
│     → Baseline-Abweichung (±50%)                    │
│                                                      │
│  4. analyze_image_hsv()                             │
│     → Grün/Gelb/Braun Verhältnis                    │
│                                                      │
│  5. analyze_growth_rate()                           │
│     → Pixel-Diff zwischen Timelapse-Frames          │
│                                                      │
│  6. calculate_severity_score()                      │
│     → Gewichtete Aggregation 0-100                  │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│  OUTPUT: Aktionen & Empfehlungen                    │
│  - notify.mobile_app (Push-Benachrichtigung)       │
│  - automation Trigger (EC/pH-Dosierung)            │
│  - sensor.stress_score (History-Tracking)          │
│  - Text-Empfehlungen (Liste von Strings)           │
└─────────────────────────────────────────────────────┘
```

---

## 1. Wachstumsphasen-Erkennung

### Methode: `detect_growth_stage()`

**Automatische Erkennung basierend auf:**
- Tage seit Keimung (via `input_datetime.grow_start_date`)
- Pixel-Größe der Pflanze (Canopy-Kamera)
- PPFD-Anforderung (Zeltsensor AS7341)

**Manuelle Überschreibung:**
- `input_select.growth_stage_mode = "manual"`
- User wählt Phase in `input_select.growth_stage`

### STAGE_TARGETS Dictionary

```python
STAGE_TARGETS = {
    "keimling": {
        "days": (1, 7),
        "ec_range": (0.4, 0.8),      # mS/cm
        "ph_range": (5.8, 6.2),
        "vpd_range": (0.4, 0.8),     # kPa
        "temp_range": (22, 26),      # °C
        "ppfd_target": 200,          # µmol/m²/s
        "photoperiod": 18,           # Stunden
    },
    "veg_early": {
        "days": (8, 21),
        "ec_range": (0.8, 1.2),
        "ph_range": (5.8, 6.0),
        "vpd_range": (0.8, 1.0),
        "temp_range": (22, 25),
        "ppfd_target": 400,
        "photoperiod": 18,
    },
    "veg_late": {
        "days": (22, 35),
        "ec_range": (1.2, 1.6),
        "ph_range": (5.8, 6.0),
        "vpd_range": (1.0, 1.2),
        "temp_range": (22, 25),
        "ppfd_target": 600,
        "photoperiod": 18,
    },
    "transition": {
        "days": (36, 42),
        "ec_range": (1.4, 1.8),
        "ph_range": (5.8, 6.0),
        "vpd_range": (1.0, 1.2),
        "temp_range": (21, 24),
        "ppfd_target": 700,
        "photoperiod": 12,  # Umstellung auf Blüte
    },
    "bloom_early": {
        "days": (43, 56),
        "ec_range": (1.6, 2.0),
        "ph_range": (6.0, 6.2),
        "vpd_range": (1.1, 1.3),
        "temp_range": (20, 23),
        "ppfd_target": 800,
        "photoperiod": 12,
    },
    "bloom_mid": {
        "days": (57, 70),
        "ec_range": (1.8, 2.2),
        "ph_range": (6.0, 6.3),
        "vpd_range": (1.2, 1.5),
        "temp_range": (20, 23),
        "ppfd_target": 900,
        "photoperiod": 12,
    },
    "bloom_late": {
        "days": (71, 84),
        "ec_range": (0.8, 1.2),      # Flush: Reduzierte EC
        "ph_range": (6.0, 6.5),
        "vpd_range": (1.3, 1.6),
        "temp_range": (18, 21),      # Kühlere Temps für Terpene
        "ppfd_target": 700,
        "photoperiod": 12,
    },
}
```

### Logik-Ablauf

```python
def detect_growth_stage(self):
    mode = self.get_state("input_select.growth_stage_mode")
    
    if mode == "manual":
        # User hat manuell gewählt
        return self.get_state("input_select.growth_stage")
    
    else:  # "auto"
        start_date = self.get_state("input_datetime.grow_start_date")
        days_elapsed = (datetime.now() - start_date).days
        
        for stage, targets in STAGE_TARGETS.items():
            if targets["days"][0] <= days_elapsed <= targets["days"][1]:
                return stage
        
        return "unknown"
```

---

## 2. Multi-Sensor-Analyse

### Methode: `analyze_sensors()`

**Überprüft EC, pH, VPD, Temperatur gegen Sollwerte**

```python
def analyze_sensors(self, stage):
    targets = STAGE_TARGETS[stage]
    issues = []
    severity = 0
    
    # EC-Analyse
    ec_value = float(self.get_state("sensor.hydroknoten_ec_wert"))
    ec_min, ec_max = targets["ec_range"]
    
    if ec_value < ec_min:
        deviation = (ec_min - ec_value) / ec_min * 100
        issues.append(f"EC zu niedrig: {ec_value:.2f} mS/cm (Soll: {ec_min}-{ec_max})")
        severity += min(deviation * 0.5, 25)  # Max 25 Punkte
        
    elif ec_value > ec_max:
        deviation = (ec_value - ec_max) / ec_max * 100
        issues.append(f"EC zu hoch: {ec_value:.2f} mS/cm (Soll: {ec_min}-{ec_max})")
        severity += min(deviation * 0.8, 30)  # Max 30 Punkte (ernster!)
    
    # pH-Analyse (analog zu EC)
    ph_value = float(self.get_state("sensor.hydroknoten_ph_wert"))
    # ... (siehe plant_stress_detector.py)
    
    # VPD-Analyse
    vpd_value = float(self.get_state("sensor.zeltsensor_vpd"))
    # ... 
    
    # Temperatur-Analyse
    temp_value = float(self.get_state("sensor.zeltsensor_temperatur"))
    # ...
    
    return {
        "issues": issues,
        "severity": severity,  # 0-100 Score
    }
```

### Severity-Gewichtung

| Parameter | Gewicht | Begründung |
|-----------|---------|------------|
| EC zu hoch | 0.8 | Nährstoffverbrennung (kritisch) |
| EC zu niedrig | 0.5 | Mangelerscheinungen (moderat) |
| pH außerhalb | 0.7 | Nährstoffaufnahme gestört |
| VPD zu hoch | 0.6 | Transpiration/Wasserstress |
| VPD zu niedrig | 0.4 | Schimmelgefahr (langsam) |
| Temp zu hoch | 0.7 | Hitze-Stress |
| Temp zu niedrig | 0.5 | Wachstum verlangsamt |

---

## 3. Wasserverbrauch-Anomalie-Erkennung

### Methode: `analyze_water_consumption()`

**Konzept:**
- Normale Pflanzen haben konstanten Wasserverbrauch (±10% Variation)
- Plötzliche Änderung (±50%) = Wurzelprobleme, Krankheit, Leckage

**Datenquelle:**
- `sensor.water_level_tank_1` bis `sensor.water_level_tank_6`
- Binäre Sensoren (D1CS-D) liefern Füllstand-Events
- HA trackt Nachfüllungen pro Tag

### Baseline-Berechnung

```python
def analyze_water_consumption(self):
    # Hole Historie: Letzte 7 Tage
    consumption_history = []
    for day in range(7):
        date = datetime.now() - timedelta(days=day)
        daily_consumption = self.get_history(
            entity_id="sensor.daily_water_refill",
            start_time=date,
            end_time=date + timedelta(days=1)
        )
        consumption_history.append(sum(daily_consumption))
    
    # Baseline = Durchschnitt der letzten 7 Tage
    baseline = sum(consumption_history) / len(consumption_history)
    
    # Heutiger Verbrauch
    today_consumption = float(self.get_state("sensor.daily_water_refill"))
    
    # Abweichung berechnen
    deviation_percent = ((today_consumption - baseline) / baseline) * 100
    
    if abs(deviation_percent) > 50:
        return {
            "anomaly": True,
            "severity": min(abs(deviation_percent), 100),
            "message": f"Wasserverbrauch-Anomalie: {deviation_percent:+.1f}% vs. Baseline ({baseline:.1f}L)"
        }
    else:
        return {"anomaly": False}
```

### Interpretation

| Abweichung | Mögliche Ursache | Empfehlung |
|------------|------------------|------------|
| +50% bis +100% | Hitze-Stress, erhöhte Transpiration | VPD prüfen, Lüftung erhöhen |
| +100% bis +200% | Leckage im System | Tanks visuell prüfen! |
| -50% bis -100% | Wurzelfäule, Krankheit | Wurzeln inspizieren, H2O2 behandeln |
| -100% (kein Verbrauch) | Pumpe defekt oder Sensor-Fehler | Hardware-Check |

---

## 4. HSV Farbanalyse (Bildverarbeitung)

### Methode: `analyze_image_hsv()`

**Ziel:** Blattgesundheit anhand Farbverteilung bewerten

**HSV-Farbraum:** (Hue, Saturation, Value)
- **Hue:** Farbton (0-179° in OpenCV)
- **Saturation:** Farbsättigung (0-255)
- **Value:** Helligkeit (0-255)

### Farbdefinitionen

```python
# HSV-Bereiche für Pflanzenfarben
COLOR_RANGES = {
    "green": {
        "lower": np.array([35, 40, 40]),   # Hue 35-85° = Grün
        "upper": np.array([85, 255, 255]),
        "health": "healthy",
    },
    "yellow": {
        "lower": np.array([20, 40, 40]),   # Hue 20-35° = Gelb
        "upper": np.array([35, 255, 255]),
        "health": "nutrient_deficiency",
    },
    "brown": {
        "lower": np.array([10, 40, 20]),   # Hue 10-20° = Braun
        "upper": np.array([20, 255, 100]),
        "health": "necrosis",
    },
}
```

### Analyse-Ablauf

```python
def analyze_image_hsv(self, image_path):
    import cv2
    
    # Bild laden (von Kamera Detail Node)
    img = cv2.imread(image_path)
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    
    total_pixels = img.shape[0] * img.shape[1]
    color_percentages = {}
    
    # Jede Farbe analysieren
    for color, ranges in COLOR_RANGES.items():
        mask = cv2.inRange(hsv, ranges["lower"], ranges["upper"])
        pixel_count = cv2.countNonZero(mask)
        percentage = (pixel_count / total_pixels) * 100
        color_percentages[color] = percentage
    
    # Gesundheits-Score berechnen
    green_pct = color_percentages["green"]
    yellow_pct = color_percentages["yellow"]
    brown_pct = color_percentages["brown"]
    
    health_score = 100  # Start bei perfekt
    
    # Abzüge
    if yellow_pct > 10:
        health_score -= yellow_pct * 2  # Gelb = Mangel
    
    if brown_pct > 5:
        health_score -= brown_pct * 4  # Braun = kritisch
    
    if green_pct < 70:
        health_score -= (70 - green_pct) * 1.5  # Zu wenig Grün
    
    return {
        "green": green_pct,
        "yellow": yellow_pct,
        "brown": brown_pct,
        "health_score": max(health_score, 0),
        "severity": 100 - health_score,
    }
```

### Interpretation

| Grün % | Gelb % | Braun % | Diagnose | Severity |
|--------|--------|---------|----------|----------|
| 80-100 | 0-10 | 0-5 | Gesund | 0-10 |
| 60-80 | 10-20 | 0-5 | Leichter Mangel | 10-30 |
| 40-60 | 20-40 | 5-15 | Nährstoffmangel | 30-60 |
| 20-40 | 30-50 | 15-30 | Schwere Mangelerscheinung | 60-80 |
| <20 | >50 | >30 | Kritisch (Nekrose) | 80-100 |

### Typische Farb-Muster

**Stickstoff-Mangel (N):**
- Grün: 50-60%
- Gelb: 30-40% (untere Blätter zuerst)
- Braun: 5-10%

**Phosphor-Mangel (P):**
- Grün: 60-70% (dunkel)
- Violett/Braun: 20-30% (an Blattspitzen)
- Hue-Shift in Richtung Violett (HSV 280-300°)

**Kalium-Mangel (K):**
- Grün: 50-60%
- Gelb: 20-30% (Blattränder)
- Braun: 15-25% (verbrannte Ränder)

---

## 5. Wachstumsgeschwindigkeit

### Methode: `analyze_growth_rate()`

**Konzept:** Pixel-Differenz zwischen aufeinanderfolgenden Timelapse-Frames

**Datenquelle:**
- Canopy-Kamera: Stündliche Snapshots (6-22 Uhr)
- Gespeichert in `/config/www/timelapse/`

### Algorithmus

```python
def analyze_growth_rate(self):
    import cv2
    import numpy as np
    
    # Letzte 2 Bilder (24h Abstand)
    img_today = cv2.imread("/config/www/timelapse/latest.jpg", cv2.IMREAD_GRAYSCALE)
    img_yesterday = cv2.imread("/config/www/timelapse/yesterday.jpg", cv2.IMREAD_GRAYSCALE)
    
    # Pixel-Differenz berechnen
    diff = cv2.absdiff(img_today, img_yesterday)
    
    # Schwellenwert: Nur signifikante Änderungen
    _, thresh = cv2.threshold(diff, 25, 255, cv2.THRESH_BINARY)
    
    # Anzahl geänderter Pixel
    changed_pixels = cv2.countNonZero(thresh)
    total_pixels = img_today.shape[0] * img_today.shape[1]
    
    growth_percent = (changed_pixels / total_pixels) * 100
    
    # Baseline: 2-5% täglich (Vegi), 1-3% (Blüte)
    stage = self.detect_growth_stage()
    
    if "veg" in stage:
        expected_range = (2, 5)
    else:  # bloom
        expected_range = (1, 3)
    
    if growth_percent < expected_range[0]:
        return {
            "growth_rate": growth_percent,
            "status": "slow",
            "severity": 20,
            "message": f"Langsames Wachstum: {growth_percent:.1f}% (Erwartet: {expected_range[0]}-{expected_range[1]}%)"
        }
    elif growth_percent > expected_range[1] * 2:
        return {
            "growth_rate": growth_percent,
            "status": "excessive",
            "severity": 15,
            "message": "Ungewöhnlich schnelles Wachstum (Streckung?)"
        }
    else:
        return {
            "growth_rate": growth_percent,
            "status": "normal",
            "severity": 0,
        }
```

### Erwartete Wachstumsraten

| Phase | Pixel-Änderung/Tag | Tatsächl. Wachstum |
|-------|--------------------|--------------------|
| Keimling | 1-2% | 0.5-1 cm |
| Veg Early | 3-5% | 2-4 cm |
| Veg Late | 5-8% | 4-6 cm |
| Transition | 8-12% | 6-10 cm (Streckung!) |
| Bloom Early | 3-5% | 2-4 cm |
| Bloom Mid | 1-2% | 1-2 cm |
| Bloom Late | 0-1% | <1 cm |

---

## 6. Severity-Score Aggregation

### Methode: `calculate_severity_score()`

**Kombiniert alle Analyse-Ergebnisse zu einem 0-100 Score**

```python
def calculate_severity_score(self):
    # Sammle alle Teilscores
    sensor_result = self.analyze_sensors(self.current_stage)
    water_result = self.analyze_water_consumption()
    image_result = self.analyze_image_hsv()
    growth_result = self.analyze_growth_rate()
    
    # Gewichtung
    weights = {
        "sensors": 0.35,      # 35% (EC/pH/VPD kritisch)
        "water": 0.25,        # 25% (Wasserverbrauch)
        "image": 0.30,        # 30% (Visuelle Gesundheit)
        "growth": 0.10,       # 10% (Wachstumsrate)
    }
    
    total_severity = (
        sensor_result["severity"] * weights["sensors"] +
        water_result.get("severity", 0) * weights["water"] +
        image_result["severity"] * weights["image"] +
        growth_result["severity"] * weights["growth"]
    )
    
    return min(total_severity, 100)  # Cap bei 100
```

### Severity-Klassifikation

| Score | Status | Aktion |
|-------|--------|--------|
| 0-20 | Gesund | Keine Aktion |
| 21-40 | Beobachten | Notification (Info) |
| 41-60 | Warnung | Notification (Warning) + Empfehlungen |
| 61-80 | Kritisch | Notification (Error) + Auto-Correction (falls aktiviert) |
| 81-100 | Notfall | Notification (Critical) + Alarm + Auto-Correction erzwingen |

---

## 7. Empfehlungs-Engine

### Methode: `generate_recommendations()`

**Generiert actionable Empfehlungen basierend auf erkannten Problemen**

```python
def generate_recommendations(self, issues):
    recommendations = []
    
    for issue in issues:
        if "EC zu niedrig" in issue:
            recommendations.append("Nährstoffe dosieren: A+B Komponente")
            if self.get_state("input_boolean.auto_dosing_enabled") == "on":
                recommendations.append("→ Auto-Dosierung aktiv (Ziel-EC wird angefahren)")
        
        elif "EC zu hoch" in issue:
            recommendations.append("Wasser nachfüllen (verdünnen) oder Nährlösung wechseln")
        
        elif "pH" in issue:
            if "zu hoch" in issue:
                recommendations.append("pH Down dosieren (Ziel: 5.8-6.2)")
            else:
                recommendations.append("pH Up dosieren oder Nährlösung wechseln")
        
        elif "VPD zu hoch" in issue:
            recommendations.append("Luftfeuchtigkeit erhöhen (Befeuchter) oder Temperatur senken")
        
        elif "VPD zu niedrig" in issue:
            recommendations.append("Entfeuchter aktivieren oder Temperatur erhöhen")
        
        elif "Wasserverbrauch" in issue:
            if "+" in issue:  # Erhöhter Verbrauch
                recommendations.append("VPD/Temperatur prüfen → Evtl. zu hohe Transpiration")
            else:  # Reduzierter Verbrauch
                recommendations.append("WARNUNG: Wurzeln inspizieren (Fäule möglich!)")
                recommendations.append("H2O2-Behandlung erwägen (3ml/L)")
        
        elif "yellow" in issue.lower():
            recommendations.append("Nährstoffmangel: EC erhöhen oder Cal-Mag dosieren")
        
        elif "brown" in issue.lower():
            recommendations.append("KRITISCH: Nekrose erkannt → EC senken + Wurzeln prüfen")
        
        elif "Wachstum" in issue and "langsam" in issue.lower():
            recommendations.append("Lichtintensität prüfen (PPFD-Soll erreicht?)")
            recommendations.append("Temperatur/VPD optimieren")
    
    return recommendations
```

### Auto-Correction Modus

**Wenn `input_boolean.auto_correction_mode = ON`:**

```python
def execute_auto_correction(self, issue):
    if "EC zu niedrig" in issue:
        # Trigger Dosierung
        self.call_service("switch/turn_on", entity_id="switch.dosierung_pump_a")
        self.run_in(self.stop_dosing, delay=5)  # 5ml dosieren
    
    elif "pH zu hoch" in issue:
        self.call_service("switch/turn_on", entity_id="switch.dosierung_pump_ph_down")
        self.run_in(self.stop_dosing, delay=2)  # 2ml pH Down
    
    elif "VPD zu hoch" in issue:
        self.call_service("switch/turn_on", entity_id="switch.klimaknoten_befeuchter")
    
    # etc.
```

**Safety-Mechanismen:**
- Max 3 Auto-Corrections pro Stunde (verhindert Oszillation)
- Nur bei Severity 60+ aktiviert
- User-Notification bei jeder Auto-Correction

---

## 8. ML-Pipeline v0.2 (Geplant)

### Datensatz-Generierung

**Komponente:** `ai_data_collector.py`

**Sammelt:**
- Sensor-Timeseries (alle 5min): EC, pH, VPD, Temp, PPFD, etc.
- Kamera-Features: HSV-Histogramme, Pixel-Diff
- Labels: User-Rating (`input_number.plant_health_rating` 1-10 Skala)

**Output:** `data/sensor_timeseries.csv`

```csv
timestamp,entity_id,state,attributes
2024-12-06 10:00:00,sensor.hydroknoten_ec_wert,1.45,"{""unit"": ""mS/cm""}"
2024-12-06 10:00:00,sensor.zeltsensor_vpd,1.15,"{""unit"": ""kPa""}"
...
```

### Feature-Engineering

**Geplante Features (100+):**
- **Lag-Features:** EC_t-1h, EC_t-24h, EC_t-7d
- **Rolling-Statistiken:** VPD_mean_24h, VPD_std_7d
- **Differenzen:** ΔEC/Δt, ΔVPD/Δt
- **Ratios:** PPFD/PPFD_target, EC/EC_target
- **Zeit-Features:** hour_of_day, day_of_week, day_in_grow_cycle
- **Bild-Features:** HSV_green_mean, HSV_yellow_std, pixel_diff_7d

### ML-Modell

**Scikit-learn Random Forest Classifier**

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

# Features: Sensor-Timeseries (lag 24h)
X = df[["ec_t0", "ec_t1h", "ec_t24h", "vpd_t0", "vpd_t1h", ...]]

# Labels: Severity-Kategorie (0=gesund, 1=warnung, 2=kritisch)
y = df["severity_category"]

# Train/Test Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Training
model = RandomForestClassifier(n_estimators=100, max_depth=10)
model.fit(X_train, y_train)

# Feature Importance
importances = model.feature_importances_
print(f"Top Features: {sorted(zip(X.columns, importances), key=lambda x: x[1], reverse=True)[:10]}")
```

**Deployment:**
- Export als ONNX: `sklearn-onnx` Library
- Inference in HA: `onnxruntime` Python Package
- Latency: <100ms pro Prediction

### Erwartete Verbesserungen

| Metrik | v0.1 (Regelbasiert) | v0.2 (ML) |
|--------|---------------------|-----------|
| Precision | 65% | 85% (Ziel) |
| Recall | 70% | 90% (Ziel) |
| False Positives | 20% | 8% (Ziel) |
| Vorhersage-Horizon | 0h (reaktiv) | 6-12h (prädiktiv) |

---

## 9. Code-Beispiel: Vollständiger Analyse-Loop

```python
import appdaemon.plugins.hass.hassapi as hass
import datetime

class PlantStressDetector(hass.Hass):
    
    def initialize(self):
        # Analyse alle 5 Minuten
        self.run_every(self.analyze_plant_health, 
                       datetime.datetime.now(), 
                       5 * 60)
    
    def analyze_plant_health(self, kwargs):
        # 1. Wachstumsphase erkennen
        stage = self.detect_growth_stage()
        self.log(f"Aktuelle Phase: {stage}")
        
        # 2. Multi-Sensor Analyse
        sensor_result = self.analyze_sensors(stage)
        
        # 3. Wasserverbrauch
        water_result = self.analyze_water_consumption()
        
        # 4. Bildanalyse
        image_path = "/config/www/timelapse/latest.jpg"
        image_result = self.analyze_image_hsv(image_path)
        
        # 5. Wachstumsrate
        growth_result = self.analyze_growth_rate()
        
        # 6. Gesamt-Severity berechnen
        severity = self.calculate_severity_score()
        
        # 7. Sensor in HA aktualisieren
        self.set_state("sensor.plant_stress_score", 
                       state=severity,
                       attributes={
                           "stage": stage,
                           "sensor_issues": sensor_result["issues"],
                           "water_anomaly": water_result.get("anomaly", False),
                           "green_pct": image_result["green"],
                           "growth_rate": growth_result["growth_rate"],
                       })
        
        # 8. Empfehlungen generieren
        all_issues = sensor_result["issues"] + water_result.get("messages", [])
        recommendations = self.generate_recommendations(all_issues)
        
        # 9. Benachrichtigung bei Severity > 40
        if severity > 40:
            message = f"⚠️ Plant Stress Alert (Score: {severity}/100)\n\n"
            message += "\n".join(all_issues) + "\n\n"
            message += "Empfehlungen:\n" + "\n".join(recommendations)
            
            self.call_service("notify/mobile_app", 
                              message=message,
                              title="DiXY Stress Detection")
        
        # 10. Auto-Correction (falls aktiviert)
        if self.get_state("input_boolean.auto_correction_mode") == "on":
            if severity > 60:
                self.execute_auto_correction(all_issues)
```

---

## Zusammenfassung

**v0.1 Regelbasiertes System:**
- ✅ Robust & Nachvollziehbar
- ✅ Keine Trainingsdaten erforderlich
- ✅ Sofort einsatzbereit
- ❌ Keine Vorhersagen (nur reaktiv)
- ❌ Feste Schwellenwerte (keine Anpassung an individuelle Grows)

**v0.2 ML-Hybrid (Roadmap):**
- ✅ Prädiktive Analysen (6-12h Horizon)
- ✅ Lernt aus historischen Grows
- ✅ Erkennt komplexe Muster
- ❌ Benötigt 3+ Grows als Trainingsdaten
- ❌ "Black Box" (schwer nachvollziehbar)

**Empfehlung:** Starte mit v0.1, sammle Daten via `ai_data_collector.py`, upgrade zu v0.2 nach 3 erfolgreichen Grows.

---
*Version: v0.1-beta | Erstellt: Dezember 2024*
