# Zeltsensor – Spektral-Lichtanalyse & Klima-Monitoring

## Changelog

### [2.4] – YYYY-MM-DD
- Added:
  - Sensor zur Rückmeldung der aktuellen Lampenhelligkeit (%)
  - Klare Trennung zwischen Steuerlogik und Rückmeldung

- Changed:
  - Lichtsteuerung nutzt ausschließlich die interne ESP-Logik
  - Bestehende Light-Entität reagiert deterministisch auf AUTO/MANUELL

- Rationale:
  - Bessere Transparenz und Debugbarkeit
  - Verlässliche Visualisierung von SA/SU-Verläufen
  - Grundlage für spätere Regel- oder Analysefunktionen

### 2025-12-19 (v2.1)
- Versionsnummer in YAML auf "2.1" gesetzt
- YAML-Struktur bereinigt (Indents, Blockstruktur, Duplikate entfernt)
- Dummy-Sensoren und Dummy-Buttons für Home Assistant hinzugefügt
- Problematische Komponenten entfernt, falls ESPHome-Linkerfehler
- Dokumentation und Versionierung aktualisiert

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
- **`zeltsensor_v1.yaml`** – Minimalprofil, nur BMP280
- **`zeltsensor_v2.yaml`** – BMP280, AS7341, Diagnosesensoren

**Hinweis:** Die Dummy-Sensorwerte (z. B. CO₂, Blatttemperatur, VPD) dienen aktuell der Simulation. Mit der fertigen PCB und Bestückung werden diese durch echte Messwerte ersetzt.
- **`zeltsensor_v3.yaml`** – AS7341 HACS-kompatibel, alle Kanäle als eigene Entitäten
- **`zeltsensor_v4.yaml`** – WLAN-Status-LED, PPFD/Lux/DLI-Berechnung, Button entfernt
- **`zeltsensor_v5.yaml`** – AS7341, BMP280, Dummy-Outputs, mehrere Lampen- und Simulationsoptionen, OLED-Display (experimentell)
- **`zeltsensor_v6.yaml`** – Minimalprofil mit nur einer dimmbaren Zeltlampe (GPIO25, PWM, monochromatic), keine Display- oder Simulationsfunktionen, Home Assistant ready

## Changelog
### v5
- Dummy-Outputs für Lampen-Simulation
- Zwei Light-Entitäten (Zeltlampe, Grow Lampe), Simulations-Number, OLED-Display-Integration (experimentell)
- Komplexe Display-Lambdas, mehrere Sensor-Templates

### v6
- Minimalistische Version: Nur noch eine dimmbare Zeltlampe (GPIO25, PWM, monochromatic)
- Keine Display- oder Simulationsfunktionen mehr
- Fokus auf Home Assistant Integration und Zuverlässigkeit

### v1
- Minimalprofil, nur BMP280 (Temperatur, Luftdruck)

### v2
- Hinzugefügt: AS7341 (alle Kanäle), Diagnosesensoren (WiFi, Uptime, Status)

### v3
- AS7341-Kanäle HACS-kompatibel (f1–f8, clear, nir)
- YAML-Bereinigung, Home Assistant Integration optimiert

### v4
- Restart-Button entfernt
- WLAN-Status-LED (Onboard, GPIO2) hinzugefügt
- Template-Sensoren für PPFD, Lux, DLI (aus AS7341)
- README und Dokumentation aktualisiert
## Neue Features in v4

- **WLAN-Status-LED:** Die Onboard-LED (GPIO2) zeigt den WLAN-Status an (blinkt bei Verbindungsproblemen, leuchtet bei Verbindung).
- **PPFD, Lux, DLI:** Neue Template-Sensoren berechnen PPFD (µmol/m²s), Lux (lx) und DLI (mol/m²d) aus den AS7341-Kanälen. Die Formeln sind im YAML kommentiert und können angepasst werden.
- **Button entfernt:** Der Restart-Button ist nicht mehr enthalten, da OTA und Web-UI für Neustarts genutzt werden können.

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
