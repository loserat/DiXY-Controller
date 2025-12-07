# Zeltsensor v2 – Spektral-Lichtanalyse & Klima-Monitoring

## Funktion
Misst Lichtspektrum (AS7341 11-Kanal), Temperatur, Luftfeuchte, Luftdruck und berechnet PPFD/PAR/DLI/VPD. Optionale PWM-Steuerung von Inline-Lüfter.

## Hardware
- **Microcontroller:** ESP32-DevKit
- **I2C Sensoren:**
  - AS7341 (0x39): 11-Kanal Spektralsensor (405–925nm + NIR)
  - SHT31 (0x44): Temperatur + Relative Luftfeuchte
  - BMP280 (0x76): Luftdruck + Höhe
- **Optional:** MLX90614 (0x5A/0x5B): IR Blatt-Temperatur (kontaktlos)
- **Optional:** MH-Z19B/C (UART): CO₂-Messung
- **Optional:** PWM Inline-Lüfter (GPIO25, 0–10V via DAC Converter)
- **Optional:** PWM LED (GPIO26, 0–10V)
- **Status LED:** GPIO27
- **Buzzer:** GPIO14 (optional)
- **Versorgung:** 5V/1A

## Pinning
| Funktion | Pin | Typ | Bemerkung |
|----------|-----|-----|----------|
| AS7341 I2C | 21/22 | I2C | 0x39, 400kHz |
| SHT31 I2C | 21/22 | I2C | 0x44, 400kHz |
| BMP280 I2C | 21/22 | I2C | 0x76, 400kHz |
| MLX1 I2C | 21/22 | I2C | 0x5A (optional) |
| MLX2 I2C | 33/32 | I2C | 0x5B (optional) |
| Fan PWM | GPIO25 | PWM | 0–10V, DAC Converter |
| Light PWM | GPIO26 | PWM | 0–10V (optional) |
| Status LED | GPIO27 | Output | – |
| Buzzer | GPIO14 | Output | (optional, v0.3+) |
| MH-Z19B RX | GPIO16 | UART | 9600 baud |
| MH-Z19B TX | GPIO17 | UART | – |

## Substitutions
```yaml
substitutions:
  device_name: zeltsensor_v2
  friendly_name: "Zeltsensor v2"
  project_version: "0.2-beta"
  
  # Adressen
  as7341_addr: "0x39"
  sht31_addr: "0x44"
  bmp280_addr: "0x76"
  
  # Kalibrierung
  ppfd_cal_factor: "0.003415"  # Via Apogee Quantum ermittelt
  photoperiod_default: "18"    # Stunden
```

## Dependencies
- **Zeltsensor ist eigenständig** ✅
  - Keine Abhängigkeit von anderen Knoten
  - Dient als Basis für Klimaknoten (wenn nicht vorhanden)

## YAML-Varianten
- **`zeltsensor_v2.yaml`** – Produktiv (mit Hardware)

## Sensor-Dokumentation
→ Detaillierte Berechnung von PPFD/DLI/VPD, Entity-IDs siehe [`SENSORS.md`](SENSORS.md)

## Hardware-Verdrahtung
→ I2C Pinout, UART Anschluss siehe [`hardware_wiring.md`](hardware_wiring.md)

## Key Features
- **PPFD** (Photosynthetic Photon Flux Density) aus AS7341 Spektral-Integral
- **PAR** (Photosynthetically Active Radiation) 400–700nm Berechnung
- **DLI** (Daily Light Integral) = PPFD × Photoperiod
- **VPD** (Vapor Pressure Deficit) via Magnus-Formel
- **Lüfter-Auto** basiert auf VPD/Temperatur
- **CO₂-Optional** via MH-Z19B für Wachstums-Monitoring

## Board-Support
- Arduino ESP32 Framework
- ESPHome 2024.1+
