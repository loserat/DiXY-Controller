# 🔌 Hardware-Verdrahtung - DiXY RDWC

## Hydroknoten (EC/pH + 6x Wasserstand)

### Sensoren:
- **ADS1115** (I2C 0x48): EC + pH Analog
- **DS18B20** (OneWire GPIO4): Wassertemperatur
- **6x D1CS-D** (Digital GPIOs): Wasserstand
  - Tank 1: GPIO32 (inverted: true)
  - Tank 2: GPIO33
  - Tank 3: GPIO14
  - Tank 4: GPIO12
  - Tank 5: GPIO13
  - Tank 6: GPIO15

### Display:
- **OLED SSD1306** (I2C): 128x64
- **Rotary Encoder**:
  - CLK: GPIO26
  - DT: GPIO27
  - SW: GPIO25

---

## Dosierknoten (4x Pumpen + Rührmotor)

### Pumpen (LEDC PWM):
- Pumpe 1: GPIO12
- Pumpe 2: GPIO13
- Pumpe 3: GPIO14
- Pumpe 4: GPIO15

### MCP4131 (SPI):
- SCK: GPIO2
- MOSI: GPIO3
- CS Inline-Fan: GPIO1
- CS Rührmotor: GPIO4

---

## Zeltsensor (Licht + Klima)

### I2C Sensoren:
- AS7341 (0x39): Spektral-Sensor
- SHT31 (0x44): Temp/Humidity
- BMP280 (0x76): Luftdruck

### I2C Bus:
- SDA: GPIO21
- SCL: GPIO22

---

## Klimaknoten (VPD-Regelung)

### I2C Sensoren:
- SHT31 (0x44): Temp/Humidity
- MLX90614 (0x5A): IR Blatttemp
- BMP280 (0x76): Luftdruck

### Relays:
- GPIO16: Befeuchter
- GPIO17: Entfeuchter
- GPIO18: Heizung
- GPIO19: Umluft-Fan

### PWM:
- GPIO25: Abluft-Fan (LEDC)

---

## ESP32-CAM (2x Kameras)

### OV2640 Pins:
- PWDN: GPIO32
- RESET: -1 (extern)
- XCLK: GPIO0
- SIOD: GPIO26 (I2C SDA)
- SIOC: GPIO27 (I2C SCL)
- Y9-Y2: GPIO35,34,39,36,21,19,18,5
- VSYNC: GPIO25
- HREF: GPIO23
- PCLK: GPIO22

### Flash LED:
- GPIO4: Flash (für Nacht-Aufnahmen)

### IPs:
- Canopy: 192.168.30.95
- Detail: 192.168.30.96

---

## Stromversorgung

- **ESP32-DevKit**: 5V/1A (USB oder externe Versorgung)
- **ESP32-CAM**: 5V/2A (hoher Stromverbrauch durch Kamera!)
- **Peristaltikpumpen**: 12V/0.5A pro Pumpe
- **Relays**: 5V Logic, 230V AC Last
- **Sensoren**: 3.3V (vom ESP32)

**⚠️ Wichtig**: ESP32-CAM niemals über USB-Programmierer betreiben (zu wenig Strom)!

---

## I2C-Adressen Übersicht

| Sensor | Adresse | Node |
|--------|---------|------|
| ADS1115 | 0x48 | Hydroknoten |
| AS7341 | 0x39 | Zeltsensor |
| SHT31 | 0x44 | Zeltsensor, Klimaknoten |
| BMP280 | 0x76 | Zeltsensor, Klimaknoten |
| MLX90614 | 0x5A | Klimaknoten |
| OLED SSD1306 | 0x3C | Hydroknoten |
