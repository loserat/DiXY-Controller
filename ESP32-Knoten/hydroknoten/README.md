# Hydroknoten – EC/pH-Monitoring & Wasserstandskontrolle

## Funktion
Misst Nährlösungskonzentration (EC), pH-Wert und Wassertemperatur kontinuierlich. Überwacht 6 separate Wassertanks auf Füllstand. Lokal unabhängig von anderen Knoten – zentral in Home Assistant angezeigt.

## Hardware
- **Microcontroller:** ESP32-DevKit (WiFi + API)
- **ADC:** ADS1115 16-Bit (I2C 0x48, Versorgung 5V → 3.3V intern)
  - Kanal A0: EC-Sensor (Atlas Scientific, analog 0–3.3V)
  - Kanal A1: pH-Sensor (Atlas Scientific, analog 0–3.3V)
- **Temperatursensoren:** 2x DS18B20 (1-Wire, GPIO4 + GPIO5)
  - Tank-Temperatur (Nährlösung)
  - Rücklauf-Temperatur (Umgebung)
- **Wasserstands-Sensoren:** 6x D1CS-D kapazitiv (Digital GPIO, LOW = Wasser erkannt)
  - GPIO32, GPIO33, GPIO14, GPIO12, GPIO13, GPIO15
- **Status LED:** GPIO2 (Onboard)
- **Versorgung:** 5V USB oder VIN-Pin (2A empfohlen)

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
- **Hydroknoten ist eigenständig** ✅
  - Keine Abhängigkeit von anderen Knoten
  - Funktioniert offline mit lokal gespeicherten Kalibrierungen
  - WiFi optional (nur für HA-Integration)
- **Andere Knoten hängen von Hydroknoten ab:** Dosierknoten braucht EC/pH-Werte via HA

## Kalibrierung
### EC (Conductivity)
- **2-Punkt Kalibrierung:** 1.413 mS/cm + 12.88 mS/cm
- **Buttons in HA:** "EC Kalibrierung markieren" + Slider "EC Cal 1.413mS" / "EC Cal 12.88mS"
- **Temperaturkompensation:** Automatisch auf 25°C normalisiert
- **Update-Zyklus:** 1s Messung, 10s Verarbeitung

### pH
- **2-Punkt Kalibrierung:** pH 4.0 + pH 7.0
- **Buttons in HA:** "pH Kalibrierung markieren" + Slider "pH Cal 7.0" / "pH Cal 4.0"
- **Update-Zyklus:** 1s Messung, 10s Verarbeitung

### Temperatur
- **Offsets:** Pro Sensor anpassbar (±2°C, Schritte 0.1°C)
- **Buttons in HA:** Slider "Temp1 Offset" / "Temp2 Offset"
- **Update-Zyklus:** 15s

## YAML-Varianten
- **`hydroknoten_v2.yaml`** – Produktiv (mit Hardware)
- **`hydroknoten_v2_sim.yaml`** – Optional für Testing ohne Hardware (würde separat erstellt)

## Sensor-Dokumentation
→ Detaillierte Entity-IDs, Bereiche, Formeln siehe [`SENSORS.md`](SENSORS.md)

## Hardware-Verdrahtung
→ GPIO-Pinouts, Stecker-Belegung siehe [`hardware_wiring.md`](hardware_wiring.md)

## Troubleshooting
- **ADS1115 nicht gefunden:** I2C Scan aktiviert → Logs prüfen (0x48 sollte erkannt werden)
- **EC/pH springt wild:** Kalibrierpunkte überprüfen (zu nah beieinander?), ADS Gain ändern
- **Tank-Level falsch:** Sensor invertiert? GPIO-Modus INPUT_PULLUP + inverted: true
- **Temp-Sensoren offline:** 1-Wire Pullup 4.7kΩ installiert? GPIO4/5 frei?

## Versionshistorie
- **v0.2-beta** (aktuell): Cleanup, API-Encryption, Projektmetadata
- **v0.1-beta:** Initial Release mit OLED/Encoder

## Board-Support
- Arduino ESP32 Framework (nicht esp-idf)
- ESPHome 2024.1+
