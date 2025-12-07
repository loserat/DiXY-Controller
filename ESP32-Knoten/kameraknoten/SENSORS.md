# Kameraknoten – Sensor & Stream Dokumentation

## Streams & Snapshots

### Canopy Kamera

| Entity ID / URL | Funktion |
|-----------------|----------|
| `camera.kameraknoten_canopy_snapshot` | Aktuelles Bild |
| `http://kameraknoten_canopy.local:8080/stream` | MJPEG Live Stream |
| `http://kameraknoten_canopy.local:8080/capture` | JPEG Snapshot |

**Resolution:** 1024×768 (Standard)  
**Quality:** 80% JPEG (Balance Speed/Size)  
**Framerate:** ~15 FPS (MJPEG)

### Detail Kamera

| Entity ID / URL | Funktion |
|-----------------|----------|
| `camera.kameraknoten_detail_snapshot` | Aktuelles Bild |
| `http://kameraknoten_detail.local:8080/stream` | MJPEG Live Stream |
| `http://kameraknoten_detail.local:8080/capture` | JPEG Snapshot |

**Resolution:** 1280×960  
**Quality:** 85% JPEG  
**Framerate:** ~10 FPS

---

## Timelapse & Archivierung

### Automated Timelapse Capture

**Home Assistant Automation:**
```yaml
automation:
  - alias: "Timelapse Canopy alle 5min"
    trigger:
      platform: time_pattern
      minutes: "/5"
    action:
      - service: camera.snapshot
        target:
          entity_id: camera.kameraknoten_canopy_snapshot
        data:
          filename: >
            /media/timelapse/canopy/{{ now().strftime("%Y%m%d_%H%M%S") }}.jpg

  - alias: "Timelapse Detail alle 10min"
    trigger:
      platform: time_pattern
      minutes: "/10"
    action:
      - service: camera.snapshot
        target:
          entity_id: camera.kameraknoten_detail_snapshot
        data:
          filename: >
            /media/timelapse/detail/{{ now().strftime("%Y%m%d_%H%M%S") }}.jpg
```

### Video Assembly (FFmpeg)

```bash
# Canopy: 5min Intervall → 12 Frames/h × 24h = 288 Frames/Tag
# @ 30 FPS Video = 10s Duration
ffmpeg -framerate 30 -i timelapse/canopy/%Y%m%d_%H%M%S.jpg \
  -vf scale=1280:720 -c:v libx264 -crf 18 \
  timelapse_canopy_$(date +%Y%m%d).mp4

# Detail: 10min Intervall → 144 Frames/Tag
# @ 24 FPS Video = 6s Duration
ffmpeg -framerate 24 -i timelapse/detail/%Y%m%d_%H%M%S.jpg \
  -vf scale=1280:720 -c:v libx264 -crf 18 \
  timelapse_detail_$(date +%Y%m%d).mp4
```

---

## Plant Stress Detector Integration

### HA Script: Snapshot → Python Analysis

```yaml
script:
  analyze_plant_stress:
    description: "Analyze latest snapshot for plant stress"
    fields:
      source_entity:
        description: "Camera entity ID"
        example: "camera.kameraknoten_canopy_snapshot"
    sequence:
      - service: camera.snapshot
        target:
          entity_id: "{{ source_entity }}"
        data:
          filename: /config/python_scripts/temp_snapshot.jpg
      
      - service: shell_command.run_plant_detector
        data:
          image: /config/python_scripts/temp_snapshot.jpg
```

### Python Script (plant_stress_detector.py)

```python
import cv2
import numpy as np
from datetime import datetime

def analyze_leaf_color(image_path):
    """
    Analyze leaf color for stress indicators
    Green/Yellow/Red ratio
    """
    img = cv2.imread(image_path)
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    
    # Green detection (H: 35-85)
    green_mask = cv2.inRange(hsv, (35, 40, 40), (85, 255, 255))
    green_ratio = np.count_nonzero(green_mask) / green_mask.size
    
    # Yellow detection (H: 20-35) - Early stress
    yellow_mask = cv2.inRange(hsv, (20, 100, 100), (35, 255, 255))
    yellow_ratio = np.count_nonzero(yellow_mask) / yellow_mask.size
    
    # Red detection (H: 0-20, 160-180) - Advanced stress
    red_mask1 = cv2.inRange(hsv, (0, 100, 100), (20, 255, 255))
    red_mask2 = cv2.inRange(hsv, (160, 100, 100), (180, 255, 255))
    red_ratio = (np.count_nonzero(red_mask1) + np.count_nonzero(red_mask2)) / hsv.size
    
    return {
        "green": float(green_ratio),
        "yellow": float(yellow_ratio),
        "red": float(red_ratio),
        "stress_level": classify_stress(green_ratio, yellow_ratio, red_ratio)
    }

def classify_stress(green, yellow, red):
    """Classify stress level"""
    if red > 0.05:
        return "CRITICAL"
    elif yellow > 0.15 or green < 0.50:
        return "HIGH"
    elif yellow > 0.05 or green < 0.65:
        return "MODERATE"
    else:
        return "NORMAL"

if __name__ == "__main__":
    result = analyze_leaf_color("/config/python_scripts/temp_snapshot.jpg")
    print(f"Stress: {result['stress_level']} | Green {result['green']:.1%} | Yellow {result['yellow']:.1%} | Red {result['red']:.1%}")
```

---

## Flash LED Control (Optional)

| Entity ID | Function |
|-----------|----------|
| `switch.kameraknoten_canopy_flash` | LED ON/OFF |
| `switch.kameraknoten_detail_flash` | LED ON/OFF |

- GPIO: 4 (Standard)
- Current: ~200mA (max, limiting recommended)
- Brightness: High (ggf. mit Resistor begrenzen)

---

## System Health

| Entity ID | Bedeutung |
|-----------|-----------|
| `sensor.kameraknoten_canopy_psram` | Free PSRAM in MB |
| `sensor.kameraknoten_detail_uptime` | Runtime in hours |

---

## Streaming Integration

### HA Lovelace Card

```yaml
type: picture-elements
entities:
  - camera.kameraknoten_canopy_snapshot
    type: image
    image: /api/camera_proxy/camera.kameraknoten_canopy_snapshot?cache=false
    width: 80%
```

### MotionEye Integration (Optional)

```
https://github.com/ccrisan/motioneye

# Add camera via Web UI:
URL: http://kameraknoten_canopy.local:8080/capture
Upload: Local folder: /media/timelapse/
Schedule: Every 5min
```

---

## Troubleshooting

### Camera Black Image
**Ursachen:** Fokus falsch, Flash zu hell, Hardware-Problem  
**Lösung:** Camera-Module nachjustieren, Flash ausschalten

### Stream laggy
**Ursachen:** WiFi schwach, Resolution zu hoch, zu viele Clients  
**Lösung:** Resolution reduzieren, Quality-Setting senken

### PSRAM Fehler
**Ursachen:** Board nicht PSRAM-equipped, Speicher-Konflikt  
**Lösung:** Auf ESP32-S3 mit 4MB PSRAM upgraden

---

## Spezifikationen

| Parameter | Canopy | Detail |
|-----------|--------|--------|
| Resolution | 1024×768 | 1280×960 |
| JPEG Quality | 80% | 85% |
| Framerate | 15 FPS | 10 FPS |
| Timelapse Interval | 5min | 10min |
| Storage/Tag (~2KB/img) | ~576 KB | ~288 KB |

