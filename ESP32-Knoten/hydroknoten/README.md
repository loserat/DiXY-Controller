# Hydroknoten – EC/pH-Monitoring & Wasserstandskontrolle

## Funktion
Misst Nährlösungskonzentration (EC), pH-Wert und Wassertemperatur kontinuierlich. Überwacht 6 separate Wassertanks auf Füllstand. Lokal unabhängig von anderen Knoten – zentral in Home Assistant angezeigt.

## Hardware
  - Kanal A0: EC-Sensor (Atlas Scientific, analog 0–3.3V)
  - Kanal A1: pH-Sensor (Atlas Scientific, analog 0–3.3V)
  - Tank-Temperatur (Nährlösung)
  - Rücklauf-Temperatur (Umgebung)
  - GPIO32, GPIO33, GPIO14, GPIO12, GPIO13, GPIO15

## Changelog

### 2025-12-19 (v2.1)
- Versionsnummer in YAML und Logger auf "2.1" korrigiert
- YAML-Struktur bereinigt (Indents, Blockstruktur, Duplikate entfernt)
- Dummy-Sensoren und Dummy-Buttons für Home Assistant hinzugefügt
- Problematische Komponenten (uptime, status) entfernt, da ESPHome-Linkerfehler
- Dokumentation und Versionierung aktualisiert

## Pinning
| Funktion | Pin | Typ | Bemerkung |
|----------|-----|-----|----------|
| EC-Sensor | ADS1115 A0 | Analog | Atlas Sci., Kalibrierpunkte: 1.41 + 12.88 mS/cm |
| pH-Sensor | ADS1115 A1 | Analog | Atlas Sci., Kalibrierpunkte: pH 4.0 + 7.0 |
| Tank Temp | GPIO4 (1W) | 1-Wire | DS18B20, +/- Offset konfigurierbar |
| Rücklauf Temp | GPIO5 (1W) | 1-Wire | DS18B20, +/- Offset konfigurierbar |
| Tank 1 Level | GPIO32 | Digital | D1CS-D, INPUT_PULLUP, inverted |
| Tank 2 Level | GPIO33 | Digital | D1CS-D |
| Tank 3 Level | GPIO14 | Digital | D1CS-D |
| Tank 4 Level | GPIO12 | Digital | D1CS-D |
| Tank 5 Level | GPIO13 | Digital | D1CS-D |
| Tank 6 Level | GPIO15 | Digital | D1CS-D |
| I2C SDA | GPIO21 | I2C | 400 kHz, 3.3V |
| I2C SCL | GPIO22 | I2C | 400 kHz, 3.3V |
| Status LED | GPIO2 | Output | Onboard LED |

## Substitutions (Anpassbar)
```yaml
substitutions:
  # WiFi (aus secrets_*)
  wifi_ssid: !secret wifi_ssid
  wifi_password: !secret wifi_password
  
  # GPIO Pins (austauschbar für custom PCB)
  i2c_sda_pin: "21"
  i2c_scl_pin: "22"
  onewire_pin1: "4"    # Tank Temp
  onewire_pin2: "5"    # Rücklauf Temp
  tank1_pin ... tank6_pin: GPIO Pins
  status_led_pin: "2"
  
  # I2C Adressen (Standard, anpassen falls Konflikt)
  ads1115_address: "0x48"
```

## Dependencies
  - Keine Abhängigkeit von anderen Knoten
  - Funktioniert offline mit lokal gespeicherten Kalibrierungen
  - WiFi optional (nur für HA-Integration)

## Kalibrierung
### EC (Conductivity)

### pH

### Temperatur

## YAML-Varianten

## Sensor-Dokumentation
→ Detaillierte Entity-IDs, Bereiche, Formeln siehe [`SENSORS.md`](SENSORS.md)

## Hardware-Verdrahtung
→ GPIO-Pinouts, Stecker-Belegung siehe [`hardware_wiring.md`](hardware_wiring.md)

## Troubleshooting

## Versionshistorie

## Board-Support
