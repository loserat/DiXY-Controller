# Klimaknoten v2 – VPD-Regelung & Backup-Sensorik

## Funktion
Standalone VPD-Regelung für Zelt-Klima (Backup, falls Zeltsensor offline). Steuert Relays für Befeuchter, Entfeuchter, Heizung, Umluft-Fan.

## Hardware
- **Microcontroller:** ESP32-DevKit
- **I2C Sensoren:**
  - SHT31 (0x44): Temperatur + Feuchte
  - MLX90614 (0x5A): IR Blatt-Temperatur (kontaktlos)
  - BMP280 (0x76): Luftdruck
- **Relays:** 4-Kanal Modul (5V logic input)
  - GPIO16: Befeuchter (Humidifier)
  - GPIO17: Entfeuchter (Dehumidifier)
  - GPIO18: Heizung (Heater)
  - GPIO19: Umluft-Fan (Circulation Fan)
- **Status LED:** GPIO2
- **Versorgung:** 5V/1A

## Pinning
| Funktion | Pin | Typ | Bemerkung |
|----------|-----|-----|----------|
| Relay 1 (Humidifier) | GPIO16 | Output | Active HIGH |
| Relay 2 (Dehumidifier) | GPIO17 | Output | Active HIGH |
| Relay 3 (Heater) | GPIO18 | Output | Active HIGH |
| Relay 4 (Fan) | GPIO19 | Output | Active HIGH |
| I2C SDA | GPIO21 | I2C | 400kHz |
| I2C SCL | GPIO22 | I2C | 400kHz |
| Status LED | GPIO2 | Output | – |

## Substitutions
```yaml
substitutions:
  device_name: klimaknoten_v2
  friendly_name: "Klimaknoten v2"
  project_version: "0.2-beta"
  
  # GPIO
  humidifier_pin: "16"
  dehumidifier_pin: "17"
  heater_pin: "18"
  fan_pin: "19"
  
  # I2C
  sht31_addr: "0x44"
  mlx_addr: "0x5A"
  bmp280_addr: "0x76"
```

## Dependencies
- **Optional Backup:** Wenn Zeltsensor offline, Klimaknoten übernimmt VPD-Regelung
- **Eigenständig:** Funkioniert auch komplett allein

## YAML-Varianten
- **`klimaknoten_v2.yaml`** – Produktiv

## Sensor-Dokumentation
→ VPD-Regelung, Relay-Logik siehe [`SENSORS.md`](SENSORS.md)

## Relay-Steuerung
- **Hysterese:** Verhindert Flackern bei Sollwert-Nähe
- **Verzögerung:** Min 5min zwischen Schaltvorgängen
- **Priorität:** Heater > Dehumidifier > Humidifier

## Board-Support
- Arduino ESP32 Framework
- ESPHome 2024.1+
