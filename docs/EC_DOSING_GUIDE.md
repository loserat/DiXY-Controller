# 💉 EC Auto-Dosierung - DiXY RDWC

## Hardware
- **Dosierknoten**: ESP32-DevKit
- **4x Peristaltikpumpen**: GPIO12-15 (LEDC PWM)
- **Rührmotor**: MCP4131 SPI (Digital Poti)
- **Inline-Fan**: MCP4131 SPI

## Dosier-Logik

### EC-Regelung:
```
Wenn EC_Ist < (EC_Soll - Toleranz):
  → Pumpe A einschalten (Haupt-Nährstoff)
  → Dosierung: X ml/min für Y Sekunden
  → Rührmotor starten (5 Min)
  → Warten 30 Min (Durchmischung)
  → Erneut messen
```

### Parameter:
- **EC Sollwert**: 0.5-3.0 mS/cm (via input_number)
- **Toleranz**: ±0.1-0.5 mS/cm (Standard: ±0.2)
- **Dosiervolumen**: 0.5-10 ml/min
- **Wartezeit**: 30 Min zwischen Dosierungen

## Pumpen-Zuordnung
- **Pumpe 1 (GPIO12)**: Haupt-Nährstoff (EC-A)
- **Pumpe 2 (GPIO13)**: pH Down
- **Pumpe 3 (GPIO14)**: pH Up
- **Pumpe 4 (GPIO15)**: Additiv (Calmag/Enzyme)

## Sicherheits-Features
- Max 3 Dosierungen/Stunde
- EC-Anstieg > 0.5 mS/cm → ALARM
- Rührmotor nach jeder Dosierung
- Inline-Fan für Umwälzung

## Kalibrierung
- 2-Punkt EC: 1.41 + 12.88 mS/cm
- Temperaturkompensation: 25°C
- Kalibrierung in Flash gespeichert

**💡 Auto-Dosierung nur bei stabilem pH verwenden!**
