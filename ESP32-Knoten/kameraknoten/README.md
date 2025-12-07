# Kameraknoten – Timelapse & Bildanalyse

## Funktion
2x ESP32-CAM für Canopy-View + Detail-Dokumentation. Timelapse-Bilder für Plant Stress Detector (Python/OpenCV).

## Hardware (x2)
- **Microcontroller:** ESP32-DevKit oder ESP32-S3 (mit Camera Interface)
- **Kamera:** OV2640 (2MP, JPEG)
- **Flash LED:** Optional (GPIO4)
- **PSRAM:** 4MB (für höhere Auflösung)
- **Versorgung:** 5V/1A (VIN-Pin, NICHT USB!)

## Varianten

### Canopy (Übersicht)
- Position: Oben, Top-down
- Resolution: 1024×768 (Balance Speed/Quality)
- Timelapse: Jede 5min
- Fokus: Gesamtansicht Pflanzendach

### Detail (Nah)
- Position: Unten/Seite, Blatt-Detail
- Resolution: 1280×960
- Timelapse: Jede 10min
- Fokus: Einzelne Blatt-Strukturen

## Dependencies
- **Eigenständig** ✅
- Optional: Home Assistant für Zeitplan + Speicher

## Features
- **MJPEG Stream:** Live HTTP-Access
- **Timelapse:** JPEG-Sequenz speichern (SD-Karte optional)
- **Snapshot:** Einzelbild abrufen
- **Plant Stress Detector:** Automatische Bildanalyse (Python-Script in HA)

## YAML-Varianten
- **`kameraknoten_canopy_v2.yaml`** – Top-Down
- **`kameraknoten_detail_v2.yaml`** – Nahaufnahme

## Sensor-Dokumentation
→ Stream-URLs, Snapshot-Integration siehe [`SENSORS.md`](SENSORS.md)

## Storage & Archiv
→ Timelapse-Videos, MotionEye Integration siehe [`README.md`](README.md)

## Board-Support
- Arduino ESP32-S3 Framework (für CAM-spezifische Treiber)
- ESPHome 2024.1+

