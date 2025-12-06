# VPD-Regelung DiXY RDWC

## VPD-Formel
VPD = SVP_Blatt - (SVP_Luft × RH/100)
SVP = 0.6108 × e^((17.27 × T) / (T + 237.7))

## Zielwerte
- Keimling: 0.4-0.8 kPa
- Veg: 0.8-1.2 kPa  
- Blüte: 1.1-1.5 kPa

## Hardware
- Zeltsensor: SHT31 + BMP280
- Klimaknoten: SHT31 + MLX90614 + 4 Relays + PWM Fan

## Aktoren
- VPD zu niedrig → Entfeuchter EIN
- VPD zu hoch → Befeuchter EIN
- Abluft-Fan PWM: 0-100%
