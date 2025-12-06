# AS7341 Spektralsensor Guide: Lichtanalyse für Cannabis-Cultivation

## Übersicht

Der **AS7341** (AMS OSRAM) ist ein 11-Kanal-Spektralsensor, der präzise Lichtmessungen über das gesamte sichtbare Spektrum (405-910nm) ermöglicht. Im DiXY-System wird er zur Optimierung der Lichtqualität und PPFD-Messung eingesetzt.

---

## Spektrale Kanäle: Detaillierte Zuordnung

| Kanal | Wellenlänge (nm) | FWHM* | Farbe | Photosynthese-Relevanz |
|-------|------------------|-------|-------|------------------------|
| **F1** | 405-425 | 26nm | Violett | UV-A: Trichom-Produktion, Stressreaktion |
| **F2** | 435-455 | 26nm | Blau | Chlorophyll-A Peak, Photomorphogenese |
| **F3** | 470-490 | 20nm | Cyan | Carotinoide, Phototropismus |
| **F4** | 505-525 | 20nm | Grün | Tiefenpenetration, unterere Blätter |
| **F5** | 545-565 | 20nm | Gelb-Grün | Photosynthese (gering), Schatten-Vermeidung |
| **F6** | 580-600 | 24nm | Orange | Photoperiode-Regulation |
| **F7** | 620-640 | 24nm | Rot | Chlorophyll-B Peak, Blüten-Entwicklung |
| **F8** | 670-690 | 20nm | Tiefrot | Phytochrom Pfr → Pr Konversion, Streckung |
| **Clear** | 350-1000 | - | Ungefiltert | Gesamtintensität |
| **NIR** | 845-870 | 40nm | Nahinfrarot | Pflanzen-Reflexion, Biomasse-Index |
| **Flicker** | - | - | - | 50/60Hz Störlicht-Detektion |

*FWHM = Full Width Half Maximum (Bandbreite bei 50% Transmission)

---

## Photosynthese: Wellenlängen-Mapping

### PAR-Spektrum (Photosynthetically Active Radiation)
**400-700nm** - Primär genutzte Wellenlängen für Photosynthese

```
Photosynthese-Effizienz Kurve (McCree 1972):

 100% │      ╱╲                    ╱╲
      │     ╱  ╲                  ╱  ╲
   80%│    ╱    ╲                ╱    ╲
      │   ╱      ╲              ╱      ╲
   60%│  ╱        ╲            ╱        ╲
      │ ╱          ╲          ╱          ╲
   40%│╱            ╲________╱            ╲
      │              Grünes                 
   20%│              Minimum
      │
    0%└─────────────────────────────────────
      400  450  500  550  600  650  700 nm
      Blau       Grün       Gelb    Rot
```

### Chlorophyll-Absorptionsspektrum

**Chlorophyll A:**
- **Peak 1:** 430nm (F2) - Blau
- **Peak 2:** 662nm (F7) - Rot
- Minimale Absorption: 500-600nm (Grün)

**Chlorophyll B:**
- **Peak 1:** 453nm (F2) - Blau
- **Peak 2:** 642nm (F7) - Rot

**AS7341 Kanal-Mapping:**
- **F2 (435-455nm):** Erfasst **100%** des Chlorophyll-A Blau-Peaks
- **F7 (620-640nm):** Erfasst **70%** des Chlorophyll-B Rot-Peaks
- **F8 (670-690nm):** Erfasst **100%** des Chlorophyll-A Rot-Peaks

---

## PPFD-Berechnung (Photosynthetic Photon Flux Density)

### Konzept
**PPFD** = Anzahl photosynthetisch aktiver Photonen pro Sekunde und Fläche  
**Einheit:** µmol/m²/s (Mikromol Photonen pro Quadratmeter pro Sekunde)

### Gewichtungsfaktoren

Jeder AS7341-Kanal trägt unterschiedlich zur Photosynthese bei:

```python
PHOTOSYNTHESIS_WEIGHTS = {
    "F1": 0.75,  # 405-425nm: UV-A (moderate Effizienz)
    "F2": 1.00,  # 435-455nm: Blau (maximale Effizienz)
    "F3": 0.95,  # 470-490nm: Cyan (hohe Effizienz)
    "F4": 0.85,  # 505-525nm: Grün (moderate Effizienz)
    "F5": 0.70,  # 545-565nm: Gelb-Grün (geringe Effizienz)
    "F6": 0.85,  # 580-600nm: Orange (moderate Effizienz)
    "F7": 1.00,  # 620-640nm: Rot (maximale Effizienz)
    "F8": 0.95,  # 670-690nm: Tiefrot (hohe Effizienz)
}
```

**Begründung:**
- **F2 & F7 = 1.0:** Chlorophyll-Absorptions-Peaks (höchste Effizienz)
- **F3 & F8 = 0.95:** Nah an Peaks, sehr effizient
- **F4 & F6 = 0.85:** McCree-Kurve moderate Effizienz
- **F1 = 0.75:** UV-A wirkt indirekt (Trichome, sekundäre Metaboliten)
- **F5 = 0.70:** "Green Gap" - geringste PAR-Effizienz

### Algorithmus

```python
def calculate_ppfd(as7341_raw_values, calibration_factor):
    """
    Berechnet PPFD aus AS7341 Rohwerten
    
    Args:
        as7341_raw_values: Dict mit F1-F8 Counts (0-65535)
        calibration_factor: Float (via Apogee-Referenz ermittelt)
    
    Returns:
        ppfd: Float (µmol/m²/s)
    """
    weights = PHOTOSYNTHESIS_WEIGHTS
    
    # Gewichtete Summe aller PAR-Kanäle
    par_raw = (
        weights["F1"] * as7341_raw_values["F1"] +
        weights["F2"] * as7341_raw_values["F2"] +
        weights["F3"] * as7341_raw_values["F3"] +
        weights["F4"] * as7341_raw_values["F4"] +
        weights["F5"] * as7341_raw_values["F5"] +
        weights["F6"] * as7341_raw_values["F6"] +
        weights["F7"] * as7341_raw_values["F7"] +
        weights["F8"] * as7341_raw_values["F8"]
    )
    
    # Kalibrierung
    ppfd = par_raw * calibration_factor
    
    return ppfd
```

### Kalibrierung mit Apogee Quantum Sensor

**Schritt-für-Schritt:**

1. **Setup:**
   - Grow-Light auf 100% Leistung
   - Beide Sensoren auf gleicher Höhe (z.B. 30cm unter LED)
   - 10min Warm-Up der LED

2. **Referenzmessung:**
   - Apogee MQ-500 auslesen: z.B. **850 µmol/m²/s**

3. **AS7341 Rohwerte (Beispiel):**
   ```
   F1: 10500  F2: 42000  F3: 38000  F4: 31000
   F5: 28000  F6: 19000  F7: 58000  F8: 45000
   ```

4. **PAR_raw berechnen:**
   ```
   PAR_raw = 0.75×10500 + 1.00×42000 + 0.95×38000 + 0.85×31000 +
             0.70×28000 + 0.85×19000 + 1.00×58000 + 0.95×45000
           = 7875 + 42000 + 36100 + 26350 + 19600 + 16150 + 58000 + 42750
           = 248825
   ```

5. **Kalibrierfaktor:**
   ```
   cal_factor = PPFD_apogee / PAR_raw = 850 / 248825 = 0.003415
   ```

6. **ESPHome Integration:**
   ```yaml
   sensor:
     - platform: template
       name: "PPFD Zelt"
       id: ppfd
       unit_of_measurement: "µmol/m²/s"
       accuracy_decimals: 0
       lambda: |-
         float f1 = id(as7341_f1).state;
         float f2 = id(as7341_f2).state;
         // ... (alle F3-F8 analog)
         
         float par_raw = 0.75*f1 + 1.00*f2 + 0.95*f3 + 0.85*f4 +
                         0.70*f5 + 0.85*f6 + 1.00*f7 + 0.95*f8;
         
         return par_raw * 0.003415;  // Kalibrierfaktor
       update_interval: 60s
   ```

**Wichtig:** Kalibrierfaktor ist **spezifisch für dein LED-Modell**! Bei LED-Wechsel neu kalibrieren.

---

## DLI-Berechnung (Daily Light Integral)

**DLI** = Gesamt-Lichtmenge über 24h  
**Einheit:** mol/m²/d (Mol Photonen pro Quadratmeter pro Tag)

### Formel

$$
\text{DLI} = \frac{\text{PPFD} \times \text{Photoperiode} \times 3600}{1{,}000{,}000}
$$

**Beispiel:**
- PPFD: 850 µmol/m²/s
- Photoperiode: 18h (Vegi)

```
DLI = (850 × 18 × 3600) / 1,000,000 = 55.08 mol/m²/d
```

### Zielwerte nach Wachstumsphase

| Phase | Photoperiode | PPFD-Ziel | DLI-Ziel |
|-------|--------------|-----------|----------|
| Keimling | 18h | 200 µmol/m²/s | 12.96 mol/m²/d |
| Veg Early | 18h | 400 µmol/m²/s | 25.92 mol/m²/d |
| Veg Late | 18h | 600 µmol/m²/s | 38.88 mol/m²/d |
| Transition | 12h | 700 µmol/m²/s | 30.24 mol/m²/d |
| Bloom Early | 12h | 800 µmol/m²/s | 34.56 mol/m²/d |
| Bloom Mid | 12h | 900 µmol/m²/s | 38.88 mol/m²/d |
| Bloom Late | 12h | 700 µmol/m²/s | 30.24 mol/m²/d |

### ESPHome DLI Template

```yaml
sensor:
  - platform: template
    name: "DLI Heute"
    id: dli_today
    unit_of_measurement: "mol/m²/d"
    accuracy_decimals: 2
    lambda: |-
      float ppfd = id(ppfd).state;
      int photoperiod = 18;  // Oder dynamisch via input_number
      
      float dli = (ppfd * photoperiod * 3600) / 1000000.0;
      return dli;
    update_interval: 60s
```

---

## Lichtqualität: Spektrale Ratios

### Red:Far-Red Ratio (R:FR)

**Phytochrom-Regulation:** Steuert Streckung vs. kompaktes Wachstum

$$
\text{R:FR} = \frac{\text{Red (F7: 620-640nm)}}{\text{Far-Red (F8: 670-690nm)}}
$$

**Interpretation:**
- **R:FR > 2.0:** Kompaktes Wachstum (kurze Internodien)
- **R:FR 1.0-2.0:** Ausgewogen (natürliches Sonnenlicht ≈ 1.2)
- **R:FR < 1.0:** Starke Streckung ("Shade Avoidance")

**Empfehlung:**
- **Vegi:** R:FR = 1.5-2.0 (kompakt halten)
- **Bloom Early:** R:FR = 0.8-1.2 (Streckung für Blütenbildung)
- **Bloom Mid/Late:** R:FR = 1.2-1.5 (Streckung stoppen)

### Blue:Red Ratio (B:R)

**Photomorphogenese:** Beeinflusst Blattform und Farbe

$$
\text{B:R} = \frac{\text{Blue (F2+F3: 435-490nm)}}{\text{Red (F7+F8: 620-690nm)}}
$$

**Interpretation:**
- **B:R > 1.0:** Viel Blau → Kompakte Blätter, dunkles Grün
- **B:R 0.5-1.0:** Ausgewogen
- **B:R < 0.5:** Viel Rot → Große Blätter, Streckung

**Typische LED-Spektren:**
- **Vegi-Spektrum:** B:R = 0.8-1.2
- **Bloom-Spektrum:** B:R = 0.3-0.6 (mehr Rot für Blüten)

### ESPHome Ratio-Sensoren

```yaml
sensor:
  - platform: template
    name: "R:FR Ratio"
    lambda: |-
      float red = id(as7341_f7).state;
      float far_red = id(as7341_f8).state;
      return red / far_red;
    accuracy_decimals: 2
    update_interval: 60s
  
  - platform: template
    name: "Blue:Red Ratio"
    lambda: |-
      float blue = id(as7341_f2).state + id(as7341_f3).state;
      float red = id(as7341_f7).state + id(as7341_f8).state;
      return blue / red;
    accuracy_decimals: 2
    update_interval: 60s
```

---

## Lichtspektrum-Rezepte

### Optimale Spektren nach Phase

#### 1. Keimling (Tag 1-7)
```
Ziel: Sanftes Wachstum, keine Streckung

Blau (F2+F3):  ████████████████ 40%
Grün (F4+F5):  ████████ 20%
Rot (F7):      ████████████ 30%
Tiefrot (F8):  ████ 10%
UV-A (F1):     - 0% (zu aggressiv)

PPFD: 200 µmol/m²/s
R:FR: 3.0 (sehr kompakt)
B:R: 1.3
```

#### 2. Vegetativ (Tag 8-35)
```
Ziel: Maximales Blattwachstum, kompakt

Blau (F2+F3):  ████████████ 30%
Grün (F4+F5):  ████████ 20%
Rot (F7):      ████████████████ 40%
Tiefrot (F8):  ████ 10%
UV-A (F1):     - 0%

PPFD: 400-600 µmol/m²/s
R:FR: 4.0 (kompakt)
B:R: 0.75
```

#### 3. Transition (Tag 36-42)
```
Ziel: Streckung für Blüten-Sites

Blau (F2+F3):  ████████ 20%
Grün (F4+F5):  ████ 10%
Rot (F7):      ████████████ 30%
Tiefrot (F8):  ████████████████ 40%
UV-A (F1):     - 0%

PPFD: 700 µmol/m²/s
R:FR: 0.75 (Streckung!)
B:R: 0.4
```

#### 4. Blüte (Tag 43-84)
```
Ziel: Maximale Blütenproduktion + Trichome

Blau (F2+F3):  ████████ 20%
Grün (F4+F5):  ████ 10%
Rot (F7):      ████████████████████ 50%
Tiefrot (F8):  ████████ 15%
UV-A (F1):     ██ 5% (Trichome!)

PPFD: 800-900 µmol/m²/s
R:FR: 3.3 (Streckung stoppen)
B:R: 0.35
```

---

## Advanced: Spectral Power Distribution (SPD)

### Messung der Lichtqualität

**SPD-Grafik erstellen:**

```python
import matplotlib.pyplot as plt

# AS7341 Messwerte (Beispiel: Vegi-LED)
wavelengths = [415, 445, 480, 515, 555, 590, 630, 680]
intensities = [10500, 42000, 38000, 31000, 28000, 19000, 58000, 45000]

# Normalisieren (0-100%)
max_intensity = max(intensities)
normalized = [(i / max_intensity) * 100 for i in intensities]

# Plot
plt.figure(figsize=(10, 6))
plt.bar(wavelengths, normalized, width=20, color='purple', alpha=0.7)
plt.xlabel('Wavelength (nm)')
plt.ylabel('Relative Intensity (%)')
plt.title('LED Spectral Power Distribution (AS7341)')
plt.grid(axis='y', alpha=0.3)
plt.show()
```

**Vergleich mit Sonnenlicht:**

| Wellenlänge | Sonnenlicht | Typische LED | Optimierte LED |
|-------------|-------------|--------------|----------------|
| 405-425nm (F1) | 5% | 0% | 5% (UV-A) |
| 435-455nm (F2) | 15% | 25% | 20% |
| 470-490nm (F3) | 12% | 20% | 15% |
| 505-525nm (F4) | 18% | 10% | 15% |
| 545-565nm (F5) | 20% | 5% | 10% |
| 580-600nm (F6) | 12% | 5% | 8% |
| 620-640nm (F7) | 10% | 20% | 15% |
| 670-690nm (F8) | 8% | 15% | 12% |

**"Optimierte LED"** = Spektrum, das McCree-Kurve folgt

---

## Troubleshooting

### PPFD-Werte zu niedrig
**Symptome:** PPFD <200 bei 100% LED-Leistung

**Mögliche Ursachen:**
1. **Kalibrierfaktor falsch:** Neu mit Apogee kalibrieren
2. **Gain zu niedrig:** Von 8x auf 16x erhöhen (ESPHome Config)
3. **Integration Time zu kurz:** ATIME/ASTEP erhöhen
4. **Sensor verschmutzt:** Linse reinigen (Isopropanol)

### Unplausible Spektrum-Ratios
**Symptome:** R:FR = 0.1 oder 10+ (extrem)

**Ursache:** Sättigung einzelner Kanäle (65535 = Max)

**Lösung:**
```yaml
# Gain reduzieren bei Sättigung
sensor:
  - platform: as7341
    gain: 4x  # Statt 8x
```

### NIR-Kanal immer 0
**Symptome:** F_NIR = 0 obwohl LED an

**Ursache:** Normale LEDs haben wenig NIR-Emission

**Erwartung:**
- Sonnenlicht: NIR ≈ 50% von Visible
- LED Grow-Lights: NIR ≈ 5-15% von Visible
- Reine RGB-LED: NIR ≈ 0-2%

---

## Integration in DiXY-System

### Automation: PPFD-Warnung

```yaml
automation:
  - alias: "PPFD zu niedrig"
    trigger:
      platform: numeric_state
      entity_id: sensor.ppfd_zelt
      below: 300  # µmol/m²/s
      for:
        minutes: 10
    condition:
      - condition: time
        after: "06:00:00"
        before: "22:00:00"  # Nur während Photoperiode
    action:
      - service: notify.mobile_app
        data:
          message: "⚠️ PPFD zu niedrig: {{ states('sensor.ppfd_zelt') }} µmol/m²/s (Soll: >400)"
          title: "DiXY Licht-Warnung"
```

### Spektrum-Optimierung Script

```python
# Home-Assistant Script: optimize_spectrum.py

def optimize_spectrum(growth_stage):
    """Stellt LED-Spektrum automatisch ein"""
    
    targets = {
        "veg": {"blue": 30, "red": 50, "far_red": 10, "uv": 0},
        "bloom": {"blue": 20, "red": 50, "far_red": 15, "uv": 5},
    }
    
    # Aktuelle Spektrum-Messung
    current_blue = get_state("sensor.as7341_f2") + get_state("sensor.as7341_f3")
    current_red = get_state("sensor.as7341_f7")
    # ...
    
    # Berechne Anpassungen für dimmbare LED-Kanäle
    # (Nur bei RGB+FR+UV LEDs mit separaten Kanälen)
    
    # Setze Dimmer
    call_service("light.turn_on", entity_id="light.led_blue", brightness_pct=30)
    call_service("light.turn_on", entity_id="light.led_red", brightness_pct=50)
    # ...
```

---

## Weiterführende Dokumentation

- **Sensor-Kalibrierung:** `SENSOR_REFERENCE.md`
- **Mathematische Formeln:** `FORMULAS_REFERENCE.md`
- **System-Architektur:** `SYSTEM_ARCHITECTURE.md`
- **KI-Analyse:** `AI_LOGIC_EXPLAINED.md`

---

## Referenzen

- McCree, K. J. (1972): "The action spectrum, absorptance and quantum yield of photosynthesis in crop plants"
- AMS OSRAM AS7341 Datasheet
- Apogee Instruments: "PAR & PPFD Measurement Best Practices"
- Bugbee, Bruce (Utah State University): "Optimizing LED Spectrum for Plant Growth"

---
*Version: v0.1-beta | Erstellt: Dezember 2024*
