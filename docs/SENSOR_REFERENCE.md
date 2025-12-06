# Sensor-Referenz: DiXY RDWC System

## Übersicht

Vollständige technische Spezifikationen aller Sensoren im DiXY-System mit Kalibrierungsverfahren, I2C-Adressen, GPIO-Zuordnungen und Datenblatt-Links.

## Sensor-Inventar

| Sensor | Typ | Anzahl | ESP32-Knoten | I2C/GPIO | Messbereich | Genauigkeit |
|--------|-----|--------|--------------|----------|-------------|-------------|
| ADS1115 | 16-bit ADC | 1 | Hydroknoten | I2C 0x48 | 0-6.144V | ±0.003V |
| DS18B20 | Temp (1-Wire) | 2 | Hydroknoten | GPIO 14 | -55 bis +125°C | ±0.5°C |
| D1CS-D | Wasserlevel | 6 | Hydroknoten | GPIO 32-35,25-26 | Binär (On/Off) | - |
| AS7341 | Spektral (11-Kanal) | 1 | Zeltsensor | I2C 0x39 | 405-910nm | - |
| SHT31 | Temp/Humidity | 2 | Zeltsensor, Klimaknoten | I2C 0x44 | -40 bis +125°C, 0-100% RH | ±0.3°C, ±2% |
| BMP280 | Druck/Temp | 1 | Zeltsensor | I2C 0x76 | 300-1100 hPa | ±1 hPa |
| MLX90614 | IR-Thermometer | 1 | Klimaknoten | I2C 0x5A | -70 bis +380°C | ±0.5°C |
| OV2640 | Kamera | 2 | Kameraknoten | CSI (Parallel) | 2MP (1600x1200) | - |

---

## 1. ADS1115 - 16-Bit Analog-Digital Converter

### Technische Daten
- **Hersteller:** Texas Instruments
- **Interface:** I2C (400 kHz)
- **Adresse:** 0x48 (Standard), konfigurierbar via ADDR-Pin
- **Auflösung:** 16 Bit (65536 Schritte)
- **Eingänge:** 4 Single-Ended oder 2 Differential
- **Programmable Gain Amplifier (PGA):** ±6.144V bis ±0.256V
- **Sample Rate:** 8-860 SPS (Standard: 128 SPS)
- **Versorgung:** 2.0-5.5V
- **Stromaufnahme:** 150 µA (kontinuierlich)

### Verwendung im DiXY-System
**Knoten:** Hydroknoten (192.168.30.91)

**Kanal-Belegung:**
- **A0:** EC-Elektrode (0-3.3V → 0-20 mS/cm)
- **A1:** pH-Elektrode (0-3.3V → pH 0-14)
- **A2:** Reserviert (zukünftig ORP)
- **A3:** Reserviert

### Kalibrierung: EC-Elektrode

**2-Punkt-Kalibrierung:**

1. **Kalibrierlösung 1:** 1.41 mS/cm (@ 25°C)
   - Elektrode in Lösung 3min equilibrieren
   - Rohwert notieren: z.B. `raw_value_1 = 12500`
   
2. **Kalibrierlösung 2:** 12.88 mS/cm (@ 25°C)
   - Elektrode spülen mit destilliertem Wasser
   - In Lösung 2 eintauchen (3min)
   - Rohwert notieren: z.B. `raw_value_2 = 52300`

3. **ESPHome Kalibrierung:**
```yaml
sensor:
  - platform: ads1115
    name: "EC Rohwert"
    id: ec_raw
    multiplexer: 'A0_GND'
    gain: 6.144
    update_interval: 10s
    filters:
      - calibrate_linear:
          - 12500 -> 1.41
          - 52300 -> 12.88
      - lambda: |-
          // Temperaturkompensation (25°C Referenz)
          float temp = id(water_temp).state;
          float ec_25 = x / (1 + 0.0185 * (temp - 25));
          return ec_25;
    unit_of_measurement: "mS/cm"
```

**Wartung:**
- Wöchentlich: Elektrode in destilliertem Wasser spülen
- Monatlich: Neukalibrierung
- Bei Drift >5%: Elektrode ersetzen

### Kalibrierung: pH-Elektrode

**2-Punkt-Kalibrierung:**

1. **Pufferlösung pH 7.0 (Neutral)**
   - Rohwert: z.B. `raw_value_ph7 = 32768` (Mittelwert)

2. **Pufferlösung pH 4.0 (Sauer)**
   - Rohwert: z.B. `raw_value_ph4 = 41000`

3. **ESPHome Kalibrierung:**
```yaml
sensor:
  - platform: ads1115
    name: "pH Wert"
    multiplexer: 'A1_GND'
    gain: 6.144
    filters:
      - calibrate_linear:
          - 41000 -> 4.0
          - 32768 -> 7.0
    unit_of_measurement: "pH"
```

**Wartung:**
- Elektrode in KCl-Lösung lagern (3M)
- Alle 6 Monate: Neukalibrierung
- Bei Drift >0.2 pH: Elektrode ersetzen

### Datasheet
[ADS1115 Texas Instruments](https://www.ti.com/lit/ds/symlink/ads1115.pdf)

---

## 2. DS18B20 - 1-Wire Temperatursensor

### Technische Daten
- **Hersteller:** Maxim Integrated (jetzt Analog Devices)
- **Interface:** 1-Wire (Dallas Protocol)
- **Messbereich:** -55°C bis +125°C
- **Genauigkeit:** ±0.5°C (-10°C bis +85°C)
- **Auflösung:** 9-12 Bit konfigurierbar (Standard: 12-Bit = 0.0625°C)
- **Konversionszeit:** 750ms (12-Bit)
- **Versorgung:** 3.0-5.5V oder parasitär
- **Eindeutige ID:** 64-Bit ROM-Code

### Verwendung im DiXY-System
**Knoten:** Hydroknoten (192.168.30.91)

**Sensoren:**
1. **Nährlösungstemperatur** (Tauchfühler in Tank)
   - ROM-Adresse: `0x28FF1234567890AB` (Beispiel)
   - Verwendung: EC-Temperaturkompensation
   
2. **Umgebungstemperatur** (außerhalb Tank)
   - ROM-Adresse: `0x28FF0987654321CD`
   - Verwendung: Klima-Monitoring

### Konfiguration ESPHome
```yaml
dallas:
  - pin: GPIO14
    update_interval: 5s

sensor:
  - platform: dallas
    address: 0x28FF1234567890AB
    name: "Nährlösung Temperatur"
    id: water_temp
    accuracy_decimals: 2
    
  - platform: dallas
    address: 0x28FF0987654321CD
    name: "Umgebungstemperatur"
    accuracy_decimals: 2
```

### Kalibrierung
**Vergleichsmessung mit Referenzthermometer:**
1. Beide Sensoren in Wasserbad (20°C, 30°C, 40°C)
2. Abweichung dokumentieren
3. Bei >0.5°C Differenz: Sensor ersetzen (keine Software-Kalibrierung)

### Verdrahtung
- **VCC:** 3.3V (ESP32)
- **GND:** GND
- **DATA:** GPIO 14 + 4.7kΩ Pull-Up zu 3.3V

### Datasheet
[DS18B20 Maxim Integrated](https://www.analog.com/media/en/technical-documentation/data-sheets/ds18b20.pdf)

---

## 3. D1CS-D - Optischer Wasserlevel-Sensor

### Technische Daten
- **Typ:** Optisch (IR-LED + Phototransistor)
- **Ausgangssignal:** Binär (NPN Open Collector)
- **Schaltabstand:** ±2mm
- **Reaktionszeit:** <1s
- **Versorgung:** 5-24V DC
- **Stromaufnahme:** 5mA
- **Ausgangsstrom:** Max 100mA

### Verwendung im DiXY-System
**Knoten:** Hydroknoten (192.168.30.91)

**6x Sensoren für RDWC-Tanks:**
- Tank 1: GPIO 32
- Tank 2: GPIO 33
- Tank 3: GPIO 34 (Input Only!)
- Tank 4: GPIO 35 (Input Only!)
- Tank 5: GPIO 25
- Tank 6: GPIO 26

### Funktionsweise
- **Trocken (kein Wasser):** Sensor HIGH → Binärsensor OFF
- **Nass (Wasser vorhanden):** Sensor LOW → Binärsensor ON

### ESPHome Konfiguration
```yaml
binary_sensor:
  - platform: gpio
    pin:
      number: GPIO32
      mode: INPUT_PULLUP
      inverted: true  # LOW = Wasser vorhanden
    name: "Tank 1 Level"
    device_class: moisture
```

**WICHTIG:** GPIO 34/35 sind Input-Only (kein Pull-Up intern verfügbar) → Externe 10kΩ Pull-Up Widerstände erforderlich!

### Montage
- Höhe: 5cm unter Tank-Oberkante
- Befestigung: M12-Gewinde oder Kabelbinder
- Kabel: Max 10m (bei >10m: Schirmung empfohlen)

### Troubleshooting
- **Falscher Alarm:** Luftblasen an Sensor → Position anpassen
- **Kein Signal:** Pull-Up prüfen (besonders GPIO 34/35)
- **Drift:** Sensor verschmutzt → Reinigen mit Isopropanol

### Datasheet
Generischer D1CS-D Sensor (diverse Hersteller)

---

## 4. AS7341 - 11-Kanal Spektralsensor

### Technische Daten
- **Hersteller:** AMS OSRAM
- **Interface:** I2C (400 kHz)
- **Adresse:** 0x39 (fest)
- **Spektrale Kanäle:** 11
  - F1 (405-425 nm) - Violett
  - F2 (435-455 nm) - Blau
  - F3 (470-490 nm) - Cyan
  - F4 (505-525 nm) - Grün
  - F5 (545-565 nm) - Gelb-Grün
  - F6 (580-600 nm) - Orange
  - F7 (620-640 nm) - Rot
  - F8 (670-690 nm) - Tiefrot
  - Clear (ungefiltert)
  - NIR (845-870 nm) - Nahinfrarot
  - Flicker (Störlicht-Detektion)
- **Auflösung:** 16 Bit pro Kanal
- **Versorgung:** 1.7-3.6V
- **Stromaufnahme:** 100 µA (aktiv), <1 µA (Sleep)

### Verwendung im DiXY-System
**Knoten:** Zeltsensor (192.168.30.93)

**Anwendungen:**
1. **PPFD-Messung** (Photosynthetically Active Radiation)
2. **PAR-Spektrum-Analyse** (400-700nm)
3. **DLI-Berechnung** (Daily Light Integral)
4. **Lichtqualität** (R:FR Ratio, Blau:Rot)

### Integration Time & Gain
```yaml
sensor:
  - platform: as7341
    address: 0x39
    gain: 8x  # 0.5x, 1x, 2x, 4x, 8x, 16x, 32x, 64x, 128x, 256x, 512x
    atime: 100  # Integration Time = (ATIME + 1) × (ASTEP + 1) × 2.78 µs
    astep: 599  # ASTEP: 0-65534
```

**Empfohlene Settings für LED-Grow-Lights:**
- **ATIME:** 100
- **ASTEP:** 599
- **Gain:** 8x
- **Messintervall:** 60s

### PPFD-Kalibrierung

**Benötigtes Equipment:**
- Apogee Quantum Sensor (Referenz, ±5% Genauigkeit)
- Grow-Light bei 100% Leistung
- Messhöhe: Pflanzenebene (z.B. 30cm unter LED)

**Verfahren:**
1. Apogee-Sensor auslesen: z.B. 850 µmol/m²/s
2. AS7341 Rohwerte notieren:
   - F1: 12000
   - F2: 45000
   - F3: 32000
   - F4: 28000
   - F5: 31000
   - F6: 18000
   - F7: 52000
   - F8: 38000
   
3. **Gewichtete Summe berechnen:**
   ```
   PAR_raw = 0.8×F1 + 1.0×F2 + 1.0×F3 + 1.0×F4 + 1.0×F5 + 0.9×F6 + 1.0×F7 + 0.7×F8
   PAR_raw = 0.8×12000 + 1.0×45000 + ... = 235000 (Beispiel)
   ```

4. **Kalibrierfaktor:**
   ```
   cal_factor = PPFD_apogee / PAR_raw = 850 / 235000 = 0.003617
   ```

5. **ESPHome Template:**
```yaml
sensor:
  - platform: template
    name: "PPFD"
    id: ppfd
    unit_of_measurement: "µmol/m²/s"
    accuracy_decimals: 0
    lambda: |-
      float f1 = id(as7341_f1).state;
      float f2 = id(as7341_f2).state;
      float f3 = id(as7341_f3).state;
      float f4 = id(as7341_f4).state;
      float f5 = id(as7341_f5).state;
      float f6 = id(as7341_f6).state;
      float f7 = id(as7341_f7).state;
      float f8 = id(as7341_f8).state;
      
      float par_raw = 0.8*f1 + 1.0*f2 + 1.0*f3 + 1.0*f4 + 
                      1.0*f5 + 0.9*f6 + 1.0*f7 + 0.7*f8;
      
      return par_raw * 0.003617;  // Kalibrierfaktor
    update_interval: 60s
```

### Spektrale Interpretation
Siehe detaillierte Dokumentation in `AS7341_SPECTRAL_GUIDE.md`

### Datasheet
[AS7341 AMS OSRAM](https://ams.com/documents/20143/36005/AS7341_DS000504_3-00.pdf)

---

## 5. SHT31 - Temperatur & Luftfeuchtigkeit

### Technische Daten
- **Hersteller:** Sensirion
- **Interface:** I2C (1 MHz)
- **Adresse:** 0x44 (Standard) oder 0x45 (via ADDR-Pin)
- **Temp-Bereich:** -40°C bis +125°C
- **Temp-Genauigkeit:** ±0.3°C (0-65°C)
- **RH-Bereich:** 0-100%
- **RH-Genauigkeit:** ±2% (10-90%)
- **Auflösung:** 14-Bit (Temp), 14-Bit (RH)
- **Versorgung:** 2.4-5.5V
- **Stromaufnahme:** 600 µA (Messung), <0.5 µA (Sleep)

### Verwendung im DiXY-System
**Knoten:** 
- Zeltsensor (192.168.30.93) - Zelt-Klima
- Klimaknoten (192.168.30.94) - Backup

### ESPHome Konfiguration
```yaml
i2c:
  sda: GPIO21
  scl: GPIO22
  scan: true

sensor:
  - platform: sht3xd
    address: 0x44
    temperature:
      name: "Temperatur"
      id: temp
    humidity:
      name: "Luftfeuchtigkeit"
      id: humidity
    update_interval: 10s
```

### VPD-Berechnung
Siehe `FORMULAS_REFERENCE.md` und `VPD_REGULATION.md`

### Wartung
- Alle 6 Monate: Sensor-Reset via I2C Command 0x3041
- Bei RH-Drift: Regeneration bei 100°C für 10 Stunden (nur ohne Gehäuse!)

### Datasheet
[SHT31 Sensirion](https://www.sensirion.com/media/documents/213E6A3B/63A5A569/Datasheet_SHT3x_DIS.pdf)

---

## 6. BMP280 - Barometrischer Drucksensor

### Technische Daten
- **Hersteller:** Bosch Sensortec
- **Interface:** I2C (3.4 MHz) oder SPI (10 MHz)
- **I2C-Adresse:** 0x76 (Standard) oder 0x77
- **Druckbereich:** 300-1100 hPa
- **Genauigkeit:** ±1 hPa (absolut)
- **Temp-Bereich:** -40°C bis +85°C
- **Versorgung:** 1.71-3.6V
- **Stromaufnahme:** 2.7 µA (1 Hz sampling)

### Verwendung im DiXY-System
**Knoten:** Zeltsensor (192.168.30.93)

**Anwendung:** Luftdruck-Monitoring (optional für präzise VPD-Berechnung)

### ESPHome Konfiguration
```yaml
sensor:
  - platform: bmp280
    address: 0x76
    temperature:
      name: "BMP280 Temperatur"
      oversampling: 16x
    pressure:
      name: "Luftdruck"
      unit_of_measurement: "hPa"
    update_interval: 60s
```

### Datasheet
[BMP280 Bosch](https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bmp280-ds001.pdf)

---

## 7. MLX90614 - Infrarot-Thermometer

### Technische Daten
- **Hersteller:** Melexis
- **Interface:** I2C (SMBus)
- **Adresse:** 0x5A (Standard, umprogrammierbar)
- **Objekttemp-Bereich:** -70°C bis +380°C
- **Genauigkeit:** ±0.5°C (0-50°C)
- **Field of View:** 90° (Standard-Modell)
- **Emissivity:** Konfigurierbar (Standard: 1.0)
- **Versorgung:** 3.6-5V
- **Reaktionszeit:** <200ms

### Verwendung im DiXY-System
**Knoten:** Klimaknoten (192.168.30.94)

**Anwendung:** Berührungslose Blatttemperatur-Messung für präzise VPD-Berechnung

### ESPHome Konfiguration
```yaml
sensor:
  - platform: mlx90614
    address: 0x5A
    ambient:
      name: "MLX Umgebungstemp"
    object:
      name: "Blatttemperatur"
      id: leaf_temp
    emissivity: 0.95  # Typisch für Pflanzenblätter
    update_interval: 10s
```

### Kalibrierung Emissivity
**Pflanzenblätter:** Emissivity = 0.93-0.97 (Standard: 0.95)

### Montage
- **Abstand:** 10-20 cm vom Blatt
- **Winkel:** 45° (verhindert Reflexion)
- **FOV-Bereich:** Bei 20cm Abstand = Messfleck Ø 20cm

### Datasheet
[MLX90614 Melexis](https://www.melexis.com/-/media/files/documents/datasheets/mlx90614-datasheet-melexis.pdf)

---

## 8. OV2640 - 2MP Kamera-Sensor

### Technische Daten
- **Hersteller:** OmniVision
- **Auflösung:** 2 Megapixel (1600x1200 UXGA)
- **Bildrate:** 15 fps (UXGA), 30 fps (SVGA)
- **Interface:** Parallel (8-bit), SCLK bis 24 MHz
- **Output Format:** YUV, RGB565, JPEG
- **Versorgung:** 2.5-3.0V (Core), 1.7-3.0V (I/O)
- **Stromaufnahme:** 120 mW (aktiv)
- **Objektiv:** M12 Mount (Field of View: 66°)

### Verwendung im DiXY-System
**Knoten:** 
- Kameraknoten Canopy (192.168.30.95) - Übersicht
- Kameraknoten Detail (192.168.30.96) - Nahaufnahme

### ESP32-CAM Konfiguration
```yaml
esp32_camera:
  name: "DiXY Canopy Kamera"
  external_clock:
    pin: GPIO0
    frequency: 20MHz
  i2c_pins:
    sda: GPIO26
    scl: GPIO27
  data_pins: [GPIO5, GPIO18, GPIO19, GPIO21, GPIO36, GPIO39, GPIO34, GPIO35]
  vsync_pin: GPIO25
  href_pin: GPIO23
  pixel_clock_pin: GPIO22
  power_down_pin: GPIO32
  
  resolution: 1600x1200
  jpeg_quality: 12  # 10 = höchste Qualität, 63 = niedrigste
  max_framerate: 5 fps
  idle_framerate: 0.1 fps
```

### Flash LED
```yaml
output:
  - platform: gpio
    pin: GPIO4
    id: camera_flash

light:
  - platform: binary
    output: camera_flash
    name: "Kamera Flash"
```

### Bildoptimierung
- **Timelapse:** JPEG Quality 15, 1600x1200
- **Blattanalyse:** JPEG Quality 10, 1600x1200 (beste Qualität für HSV-Analyse)
- **Live-Stream:** 800x600 SVGA, JPEG Quality 25

### Datasheet
[OV2640 OmniVision](https://www.ovt.com/sensors/OV2640)

---

## I2C-Bus Übersicht

### Zeltsensor (192.168.30.93)
| Adresse | Sensor | Konflikt? |
|---------|--------|-----------|
| 0x39 | AS7341 Spektral | ✅ Eindeutig |
| 0x44 | SHT31 Temp/RH | ✅ Eindeutig |
| 0x76 | BMP280 Druck | ✅ Eindeutig |

**Bus-Konfiguration:**
- SDA: GPIO 21
- SCL: GPIO 22
- Pull-Up: 4.7kΩ (extern)
- Bus-Geschwindigkeit: 100 kHz (kompatibel mit allen Sensoren)

### Hydroknoten (192.168.30.91)
| Adresse | Sensor | Konflikt? |
|---------|--------|-----------|
| 0x48 | ADS1115 ADC | ✅ Eindeutig |
| 0x3C | SSD1306 OLED | ✅ Eindeutig |

### Klimaknoten (192.168.30.94)
| Adresse | Sensor | Konflikt? |
|---------|--------|-----------|
| 0x44 | SHT31 | ✅ Eindeutig |
| 0x5A | MLX90614 | ✅ Eindeutig |

**Keine I2C-Adresskonflikte im System!**

---

## Stromversorgung

### ESP32-DevKit Nodes (Hydro/Dosier/Zelt/Klima)
- **Versorgung:** 5V via USB oder VIN-Pin
- **Regelung:** AMS1117 3.3V LDO (max 800mA)
- **Sensoren gesamt:** ~150mA peak
- **Empfehlung:** 5V 2A Netzteil pro Node

### ESP32-CAM Nodes (Kameras)
- **Versorgung:** 5V (VIN-Pin, **NICHT USB!**)
- **Stromaufnahme:** 120mA (Standby), 300mA (Snapshot)
- **Flash LED:** +200mA (bei aktiviert)
- **Empfehlung:** 5V 1A Netzteil

### Gesamtsystem
- **6x ESP32:** ~800mA
- **Pumpen (4x Dosierung):** ~1.2A (peak)
- **Relais:** ~80mA
- **Gesamt:** ~2.1A @ 5V = 10.5W

---

## Kalibrierungs-Checkliste

| Sensor | Intervall | Verfahren | Erforderliche Ausrüstung |
|--------|-----------|-----------|--------------------------|
| EC-Elektrode | Monatlich | 2-Punkt (1.41 + 12.88 mS/cm) | Kalibrierlösungen, destilliertes Wasser |
| pH-Elektrode | Monatlich | 2-Punkt (pH 4.0 + 7.0) | Pufferlösungen, KCl-Lager-Lösung |
| AS7341 PPFD | Pro Grow | Vergleich mit Apogee Quantum | Apogee MQ-500 oder ähnlich |
| DS18B20 | Halbjährlich | Vergleich mit Referenz | Präzisions-Thermometer |
| MLX90614 | Einmalig | Emissivity-Anpassung | Kontakt-Thermometer an Blatt |
| SHT31 | Halbjährlich | Regeneration (optional) | Ofen 100°C |

---

## Troubleshooting

### I2C-Sensor nicht erkannt
1. ESPHome-Log prüfen: `i2c.scan: true`
2. Pull-Up Widerstände (4.7kΩ) vorhanden?
3. Kabelüberlänge? (Max 50cm empfohlen)
4. Versorgungsspannung korrekt? (3.3V für meiste Sensoren)

### EC/pH-Werte instabil
1. Elektroden-Kalibrierung wiederholen
2. Rührer läuft? (Homogene Lösung erforderlich)
3. Temperaturkompensation aktiv?
4. Elektrode verschmutzt? → Reinigen

### AS7341 PPFD zu niedrig/hoch
1. Gain anpassen (8x Standard, 16x bei schwachem Licht)
2. Kalibrierfaktor überprüfen
3. Sensor-Position korrekt? (Horizontal, Linse frei)

### DS18B20 liefert 85°C
- **Typischer Fehler:** Sensor antwortet nicht (Default-Wert)
- **Lösung:** Pull-Up 4.7kΩ prüfen, Kabel max 10m

### Kamera zeigt nur Rauschen
1. Flash-LED zu hell? → Dimmen oder Abstand erhöhen
2. Objektiv verschmutzt?
3. Stromversorgung ausreichend? (min 5V 1A)

---

## Weiterführende Dokumentation

- **AS7341 Spektralanalyse:** `AS7341_SPECTRAL_GUIDE.md`
- **Formeln & Berechnungen:** `FORMULAS_REFERENCE.md`
- **GPIO-Pinouts:** `HARDWARE_WIRING.md`
- **System-Architektur:** `SYSTEM_ARCHITECTURE.md`

---
*Version: v0.1-beta | Erstellt: Dezember 2024*
