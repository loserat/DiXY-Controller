# Formelreferenz: DiXY RDWC System

## Übersicht

Vollständige mathematische Dokumentation aller im DiXY-System verwendeten Formeln - von VPD-Berechnung über EC-Kompensation bis hin zu PPFD/DLI-Kalkulation.

---

## 1. VPD-Berechnung (Vapor Pressure Deficit)

### Definition
**VPD** = Dampfdruckdefizit zwischen Blatt und Luft  
**Einheit:** kPa (Kilopascal)

### Formel (Standard-Methode)

$$
\text{VPD}_{\text{air}} = \text{SVP}_{\text{air}} \times \left(1 - \frac{\text{RH}}{100}\right)
$$

**Wobei:**
- $\text{SVP}_{\text{air}}$ = Sättigungsdampfdruck der Luft (kPa)
- $\text{RH}$ = Relative Luftfeuchtigkeit (%)

### Sättigungsdampfdruck (Magnus-Formel)

$$
\text{SVP} = 0.6108 \times e^{\frac{17.27 \times T}{T + 237.3}}
$$

**Wobei:**
- $T$ = Temperatur in °C
- $e$ = Eulersche Zahl (≈ 2.71828)
- Ergebnis in kPa

### ESPHome Implementation

```yaml
sensor:
  - platform: template
    name: "VPD"
    id: vpd
    unit_of_measurement: "kPa"
    accuracy_decimals: 2
    lambda: |-
      float temp = id(sht31_temp).state;  // °C
      float rh = id(sht31_humidity).state;  // %
      
      // Magnus-Formel: SVP berechnen
      float svp = 0.6108 * exp((17.27 * temp) / (temp + 237.3));
      
      // VPD berechnen
      float vpd = svp * (1 - rh / 100.0);
      
      return vpd;
    update_interval: 10s
```

### VPD mit Blatttemperatur (Präzise Methode)

**Wenn MLX90614 IR-Thermometer verfügbar:**

$$
\text{VPD}_{\text{leaf}} = \text{SVP}_{\text{leaf}} - \text{SVP}_{\text{air}} \times \frac{\text{RH}}{100}
$$

**Wobei:**
- $\text{SVP}_{\text{leaf}}$ = Sättigungsdampfdruck an Blattoberfläche
- $\text{SVP}_{\text{air}}$ = Sättigungsdampfdruck der Luft

**ESPHome:**
```yaml
lambda: |-
  float temp_air = id(sht31_temp).state;
  float temp_leaf = id(mlx90614_object).state;
  float rh = id(sht31_humidity).state;
  
  float svp_air = 0.6108 * exp((17.27 * temp_air) / (temp_air + 237.3));
  float svp_leaf = 0.6108 * exp((17.27 * temp_leaf) / (temp_leaf + 237.3));
  
  float vpd_leaf = svp_leaf - (svp_air * rh / 100.0);
  
  return vpd_leaf;
```

### Zielwerte nach Wachstumsphase

| Phase | VPD-Ziel (kPa) | Begründung |
|-------|----------------|------------|
| Keimling | 0.4 - 0.8 | Niedrige Transpiration, hohe RH für Wurzelbildung |
| Veg Early | 0.8 - 1.0 | Moderates Wachstum, Blattentwicklung |
| Veg Late | 1.0 - 1.2 | Maximale Transpiration, Nährstoffaufnahme |
| Transition | 1.0 - 1.2 | Ausgewogen |
| Bloom Early | 1.1 - 1.3 | Erhöhte Transpiration für Blütenbildung |
| Bloom Mid | 1.2 - 1.5 | Maximale Harzproduktion |
| Bloom Late | 1.3 - 1.6 | Niedrige RH gegen Schimmel |

---

## 2. EC-Temperaturkompensation

### Problem
Elektrische Leitfähigkeit (EC) ist temperaturabhängig:
- **+1°C → +~2% EC**
- Standard-Referenz: **25°C**

### Kompensations-Formel

$$
\text{EC}_{25} = \frac{\text{EC}_T}{1 + \alpha \times (T - 25)}
$$

**Wobei:**
- $\text{EC}_{25}$ = Kompensierte EC bei 25°C (mS/cm)
- $\text{EC}_T$ = Gemessene EC bei Temperatur T (mS/cm)
- $\alpha$ = Temperaturkoeffizient ≈ **0.0185** (1.85% pro °C)
- $T$ = Aktuelle Temperatur (°C)

### Beispiel

**Gemessen:**
- EC: 1.8 mS/cm bei 22°C

**Berechnung:**
$$
\text{EC}_{25} = \frac{1.8}{1 + 0.0185 \times (22 - 25)} = \frac{1.8}{1 - 0.0555} = \frac{1.8}{0.9445} = 1.906 \text{ mS/cm}
$$

**Interpretation:** Tatsächliche EC (bei Referenz 25°C) ist **1.91 mS/cm**, nicht 1.8!

### ESPHome Implementation

```yaml
sensor:
  - platform: ads1115
    name: "EC Rohwert"
    id: ec_raw
    multiplexer: 'A0_GND'
    gain: 6.144
    filters:
      - calibrate_linear:
          - 12500 -> 1.41
          - 52300 -> 12.88
      - lambda: |-
          // Temperaturkompensation
          float ec_measured = x;
          float temp = id(water_temp).state;
          float ec_25 = ec_measured / (1 + 0.0185 * (temp - 25));
          return ec_25;
    unit_of_measurement: "mS/cm"
    accuracy_decimals: 2
```

---

## 3. PPFD & DLI

### PPFD (Photosynthetic Photon Flux Density)

**Definition:** Anzahl photosynthetisch aktiver Photonen (400-700nm)  
**Einheit:** µmol/m²/s

**AS7341 Berechnung:**

$$
\text{PPFD} = \sum_{i=1}^{8} (w_i \times F_i) \times k
$$

**Wobei:**
- $w_i$ = Gewichtungsfaktor für Kanal i (siehe AS7341_SPECTRAL_GUIDE.md)
- $F_i$ = AS7341 Rohwert Kanal F1-F8
- $k$ = Kalibrierfaktor (via Apogee-Referenz)

**Gewichte:**
```
w₁ = 0.75  (F1: 405-425nm)
w₂ = 1.00  (F2: 435-455nm)
w₃ = 0.95  (F3: 470-490nm)
w₄ = 0.85  (F4: 505-525nm)
w₅ = 0.70  (F5: 545-565nm)
w₆ = 0.85  (F6: 580-600nm)
w₇ = 1.00  (F7: 620-640nm)
w₈ = 0.95  (F8: 670-690nm)
```

### DLI (Daily Light Integral)

**Definition:** Gesamt-Lichtmenge über 24h  
**Einheit:** mol/m²/d

$$
\text{DLI} = \frac{\text{PPFD} \times \text{Photoperiode} \times 3600}{1{,}000{,}000}
$$

**Wobei:**
- PPFD in µmol/m²/s
- Photoperiode in Stunden
- 3600 = Sekunden pro Stunde
- 1,000,000 = Konversion µmol → mol

**Beispiel:**
- PPFD: 800 µmol/m²/s
- Photoperiode: 12h (Blüte)

$$
\text{DLI} = \frac{800 \times 12 \times 3600}{1{,}000{,}000} = \frac{34{,}560{,}000}{1{,}000{,}000} = 34.56 \text{ mol/m²/d}
$$

---

## 4. pH-Kalibrierung (2-Punkt)

### Lineare Regression

**Gegeben:**
- Messung 1: Puffer pH 4.0 → Rohwert $V_1$ (z.B. 41000)
- Messung 2: Puffer pH 7.0 → Rohwert $V_2$ (z.B. 32768)

**Steigung (Slope):**

$$
m = \frac{\text{pH}_2 - \text{pH}_1}{V_2 - V_1} = \frac{7.0 - 4.0}{32768 - 41000} = \frac{3.0}{-8232} = -0.000364
$$

**Achsenabschnitt (Intercept):**

$$
b = \text{pH}_1 - m \times V_1 = 4.0 - (-0.000364) \times 41000 = 4.0 + 14.94 = 18.94
$$

**pH-Formel:**

$$
\text{pH} = m \times V_{\text{raw}} + b = -0.000364 \times V_{\text{raw}} + 18.94
$$

**Oder in ESPHome:**
```yaml
filters:
  - calibrate_linear:
      - 41000 -> 4.0
      - 32768 -> 7.0
```

---

## 5. Wasserverbrauch-Baseline

### Gleitender Durchschnitt (7 Tage)

$$
\text{Baseline} = \frac{1}{n} \sum_{i=0}^{n-1} C_{t-i}
$$

**Wobei:**
- $C_{t-i}$ = Verbrauch an Tag $t-i$ (Liter)
- $n$ = Anzahl Tage (Standard: 7)

### Abweichung (Prozent)

$$
\text{Deviation} = \frac{C_{\text{heute}} - \text{Baseline}}{\text{Baseline}} \times 100\%
$$

**Beispiel:**
- Baseline: 8.0 L/Tag (Durchschnitt letzte 7 Tage)
- Heute: 12.5 L

$$
\text{Deviation} = \frac{12.5 - 8.0}{8.0} \times 100 = \frac{4.5}{8.0} \times 100 = 56.25\%
$$

**Alarm:** Deviation > ±50% → Anomalie!

---

## 6. Wachstumsgeschwindigkeit (Pixel-Diff)

### Pixel-Änderung pro Tag

$$
\text{Growth Rate} = \frac{\text{Pixel}_{\text{changed}}}{\text{Pixel}_{\text{total}}} \times 100\%
$$

**Wobei:**
- $\text{Pixel}_{\text{changed}}$ = Anzahl Pixel mit Differenz >25 (Threshold)
- $\text{Pixel}_{\text{total}}$ = Gesamt-Pixel im Bild (z.B. 1600×1200 = 1,920,000)

**OpenCV Algorithmus:**
```python
import cv2

img_today = cv2.imread("latest.jpg", cv2.IMREAD_GRAYSCALE)
img_yesterday = cv2.imread("yesterday.jpg", cv2.IMREAD_GRAYSCALE)

diff = cv2.absdiff(img_today, img_yesterday)
_, thresh = cv2.threshold(diff, 25, 255, cv2.THRESH_BINARY)

changed_pixels = cv2.countNonZero(thresh)
total_pixels = img_today.shape[0] * img_today.shape[1]

growth_rate = (changed_pixels / total_pixels) * 100
```

---

## 7. HSV-Farbanalyse

### RGB → HSV Konversion

**Hue (Farbton):**

$$
H = \begin{cases}
60° \times \frac{G - B}{\Delta} & \text{if Max = R} \\
60° \times \left(2 + \frac{B - R}{\Delta}\right) & \text{if Max = G} \\
60° \times \left(4 + \frac{R - G}{\Delta}\right) & \text{if Max = B}
\end{cases}
$$

**Wobei:**
- $\Delta = \text{Max}(R, G, B) - \text{Min}(R, G, B)$
- R, G, B normalisiert auf 0-1

**Saturation (Sättigung):**

$$
S = \begin{cases}
0 & \text{if Max = 0} \\
\frac{\Delta}{\text{Max}} & \text{sonst}
\end{cases}
$$

**Value (Helligkeit):**

$$
V = \text{Max}(R, G, B)
$$

**In OpenCV (automatisch):**
```python
hsv = cv2.cvtColor(img_rgb, cv2.COLOR_BGR2HSV)
```

### Grün-Prozent Berechnung

$$
\text{Green}\% = \frac{\text{Pixel}_{\text{green}}}{\text{Pixel}_{\text{total}}} \times 100
$$

**Wobei:**
- $\text{Pixel}_{\text{green}}$ = Pixel mit $35° \leq H \leq 85°$ (Grün-Bereich in HSV)

---

## 8. Severity-Score Aggregation

### Gewichtete Summe

$$
\text{Severity}_{\text{total}} = \sum_{i=1}^{n} (w_i \times S_i)
$$

**Wobei:**
- $w_i$ = Gewicht für Kategorie i
- $S_i$ = Severity-Score Kategorie i (0-100)
- Gewichte: $\sum w_i = 1.0$

**DiXY Gewichte:**
- Sensoren (EC/pH/VPD): $w_1 = 0.35$
- Wasserverbrauch: $w_2 = 0.25$
- Bildanalyse (HSV): $w_3 = 0.30$
- Wachstumsrate: $w_4 = 0.10$

**Beispiel:**
- Sensor-Severity: 40
- Wasser-Severity: 60
- Bild-Severity: 20
- Wachstums-Severity: 10

$$
\text{Severity}_{\text{total}} = 0.35 \times 40 + 0.25 \times 60 + 0.30 \times 20 + 0.10 \times 10
$$
$$
= 14 + 15 + 6 + 1 = 36
$$

**Kategorie:** 36 → "Beobachten" (21-40 Bereich)

---

## 9. Dosier-Kalkulation

### Ziel-EC erreichen

**Benötigte Nährstoff-Menge:**

$$
V_{\text{dosierung}} = \frac{(\text{EC}_{\text{ziel}} - \text{EC}_{\text{ist}}) \times V_{\text{tank}}}{\text{EC}_{\text{konzentrat}}}
$$

**Wobei:**
- $V_{\text{dosierung}}$ = Zu dosierende Menge (ml)
- $\text{EC}_{\text{ziel}}$ = Ziel-EC (mS/cm)
- $\text{EC}_{\text{ist}}$ = Aktuelle EC (mS/cm)
- $V_{\text{tank}}$ = Tank-Volumen (Liter)
- $\text{EC}_{\text{konzentrat}}$ = EC-Erhöhung pro ml Konzentrat (z.B. 0.05 mS/cm pro ml/L)

**Beispiel:**
- Ziel: 1.8 mS/cm
- Ist: 1.2 mS/cm
- Tank: 100 L
- Konzentrat: 0.05 mS/cm pro ml/L (= 1ml auf 1L erhöht EC um 0.05)

$$
V_{\text{dosierung}} = \frac{(1.8 - 1.2) \times 100}{0.05} = \frac{0.6 \times 100}{0.05} = \frac{60}{0.05} = 1200 \text{ ml}
$$

**Safety:** Max 50ml pro Schritt → 1200ml in 24 Schritten á 50ml!

### Pump-Runtime Berechnung

**Gegeben:**
- Pumpen-Durchfluss: 5 ml/s
- Ziel: 50 ml dosieren

$$
t = \frac{V_{\text{ziel}}}{\text{Durchfluss}} = \frac{50 \text{ ml}}{5 \text{ ml/s}} = 10 \text{ s}
$$

**ESPHome:**
```yaml
script:
  - id: dose_nutrients
    then:
      - switch.turn_on: dosierung_pump_a
      - delay: 10s  # 50ml
      - switch.turn_off: dosierung_pump_a
```

---

## 10. R:FR und B:R Ratios

### Red:Far-Red Ratio

$$
\text{R:FR} = \frac{\text{Red (620-640nm)}}{\text{Far-Red (670-690nm)}} = \frac{F7}{F8}
$$

**AS7341:**
```yaml
lambda: |-
  float red = id(as7341_f7).state;
  float far_red = id(as7341_f8).state;
  return red / far_red;
```

### Blue:Red Ratio

$$
\text{B:R} = \frac{\text{Blue (435-490nm)}}{\text{Red (620-690nm)}} = \frac{F2 + F3}{F7 + F8}
$$

**AS7341:**
```yaml
lambda: |-
  float blue = id(as7341_f2).state + id(as7341_f3).state;
  float red = id(as7341_f7).state + id(as7341_f8).state;
  return blue / red;
```

---

## 11. Taupunkt (Dew Point)

### Formel (Magnus-Approximation)

$$
T_d = \frac{b \times \gamma(T, \text{RH})}{a - \gamma(T, \text{RH})}
$$

**Wobei:**

$$
\gamma(T, \text{RH}) = \frac{a \times T}{b + T} + \ln\left(\frac{\text{RH}}{100}\right)
$$

**Konstanten:**
- $a = 17.27$
- $b = 237.3$ °C

**Beispiel:**
- Temp: 25°C
- RH: 60%

$$
\gamma = \frac{17.27 \times 25}{237.3 + 25} + \ln(0.6) = \frac{431.75}{262.3} - 0.511 = 1.646 - 0.511 = 1.135
$$

$$
T_d = \frac{237.3 \times 1.135}{17.27 - 1.135} = \frac{269.34}{16.135} = 16.7°C
$$

**Interpretation:** Bei Oberflächen <16.7°C kondensiert Wasser → Schimmelgefahr!

---

## 12. PPFD → DLI pro Wachstumsphase

### Lookup-Tabelle

| Phase | Photoperiode (h) | PPFD (µmol/m²/s) | DLI (mol/m²/d) |
|-------|------------------|------------------|----------------|
| Keimling | 18 | 200 | 12.96 |
| Veg Early | 18 | 400 | 25.92 |
| Veg Late | 18 | 600 | 38.88 |
| Transition | 12 | 700 | 30.24 |
| Bloom Early | 12 | 800 | 34.56 |
| Bloom Mid | 12 | 900 | 38.88 |
| Bloom Late | 12 | 700 | 30.24 |

**Formel (wiederholt):**

$$
\text{DLI} = \frac{\text{PPFD} \times \text{Hours} \times 3600}{1{,}000{,}000}
$$

---

## 13. Kalibrierungs-Slope (Allgemein)

### 2-Punkt-Kalibrierung

**Gegeben:**
- Punkt 1: $(x_1, y_1)$ (z.B. Rohwert 12500 → EC 1.41)
- Punkt 2: $(x_2, y_2)$ (z.B. Rohwert 52300 → EC 12.88)

**Steigung:**

$$
m = \frac{y_2 - y_1}{x_2 - x_1}
$$

**Achsenabschnitt:**

$$
b = y_1 - m \times x_1
$$

**Umrechnung:**

$$
y = m \times x + b
$$

**Beispiel (EC):**

$$
m = \frac{12.88 - 1.41}{52300 - 12500} = \frac{11.47}{39800} = 0.000288
$$

$$
b = 1.41 - 0.000288 \times 12500 = 1.41 - 3.60 = -2.19
$$

$$
\text{EC} = 0.000288 \times V_{\text{raw}} - 2.19
$$

---

## 14. Exponentieller Glättungsfaktor (EMA)

### Exponentially Weighted Moving Average

**Verwendung:** Sensor-Glättung (z.B. EC/pH/VPD)

$$
S_t = \alpha \times x_t + (1 - \alpha) \times S_{t-1}
$$

**Wobei:**
- $S_t$ = Geglätteter Wert zum Zeitpunkt t
- $x_t$ = Rohmessung zum Zeitpunkt t
- $\alpha$ = Glättungsfaktor (0 < α < 1)
- $S_{t-1}$ = Vorheriger geglätteter Wert

**Empfohlene α-Werte:**
- Schnelle Reaktion: α = 0.3
- Ausgeglichen: α = 0.2
- Starke Glättung: α = 0.1

**ESPHome:**
```yaml
sensor:
  - platform: ads1115
    # ...
    filters:
      - exponential_moving_average:
          alpha: 0.2
          send_every: 5
```

---

## Zusammenfassung: Wichtigste Formeln

| Parameter | Formel | Variablen |
|-----------|--------|-----------|
| **VPD** | $\text{SVP} \times (1 - \text{RH}/100)$ | SVP via Magnus, RH in % |
| **SVP** | $0.6108 \times e^{17.27T/(T+237.3)}$ | T in °C |
| **EC₂₅** | $\text{EC}_T / (1 + 0.0185(T-25))$ | EC in mS/cm, T in °C |
| **PPFD** | $\sum (w_i \times F_i) \times k$ | AS7341 Kanäle, Kalibrierfaktor |
| **DLI** | $(PPFD \times h \times 3600) / 10^6$ | PPFD in µmol/m²/s, h in Stunden |
| **pH** | $m \times V + b$ | 2-Punkt Kalibrierung |
| **R:FR** | $F7 / F8$ | AS7341 Rot/Tiefrot |
| **B:R** | $(F2+F3) / (F7+F8)$ | AS7341 Blau/Rot |

---

## Weiterführende Dokumentation

- **VPD Details:** `VPD_REGULATION.md`
- **Spektralanalyse:** `AS7341_SPECTRAL_GUIDE.md`
- **Sensor-Kalibrierung:** `SENSOR_REFERENCE.md`
- **KI-Algorithmen:** `AI_LOGIC_EXPLAINED.md`

---
*Version: v0.1-beta | Erstellt: Dezember 2024*
