# ENTITY_IDS_REFERENCE.md
# DiXY RDWC Controller - Entity IDs Referenz

## 📊 Sensor Entities

### Hydroknoten (EC/pH/Temp)
```
sensor.hydroknoten_ec_value           # EC-Wert [mS/cm]
sensor.hydroknoten_ph_value           # pH-Wert
sensor.hydroknoten_water_temperature  # Wasser-Temperatur [°C]
```

### Zeltsensor (Spektral + Klima)
```
sensor.zeltsensor_ppfd                # PPFD [µmol/m²s]
sensor.zeltsensor_par                 # PAR [µmol/m²s]
sensor.zeltsensor_lux                 # Helligkeit [lux]
sensor.zeltsensor_cct                 # Farbtemperatur [K]
sensor.zeltsensor_dli                 # Daily Light Integral
sensor.zeltsensor_air_temperature     # Lufttemperatur [°C]
sensor.zeltsensor_humidity            # Luftfeuchte [%]
sensor.zeltsensor_pressure            # Luftdruck [hPa]
sensor.zeltsensor_vpd                 # VPD [kPa]
```

### Klimaknoten (Standalone)
```
sensor.klimaknoten_temperature        # Lufttemperatur [°C]
sensor.klimaknoten_humidity           # Luftfeuchte [%]
sensor.klimaknoten_vpd                # VPD [kPa]
sensor.klimaknoten_leaf_temperature   # IR Blatttemperatur [°C]
```

### KI Plant Stress Detector
```
sensor.ki_green_health_percentage     # Grün-Anteil [%]
sensor.ki_chlorosis_percentage        # Gelbstich-Anteil [%]
sensor.ki_necrosis_percentage         # Nekrose-Anteil [%]
sensor.ki_growth_percentage           # Wachstums-Geschwindigkeit [%]
sensor.ki_water_consumption_rate      # Wasser-Verbrauch [L/day]
sensor.ki_stress_level                # Gesamt Stress-Level [0-100]
sensor.ki_last_analysis_time          # Letzte Analyse [timestamp]
```

---

## 🚦 Binary Sensor Entities

### Hydroknoten (Wasserstand)
```
binary_sensor.tank_1_level            # Tank 1 Wasser vorhanden
binary_sensor.tank_2_level            # Tank 2 Wasser vorhanden
binary_sensor.tank_3_level            # Tank 3 Wasser vorhanden
binary_sensor.tank_4_level            # Tank 4 Wasser vorhanden
binary_sensor.tank_5_level            # Tank 5 Wasser vorhanden
binary_sensor.tank_6_level            # Tank 6 Wasser vorhanden
```

---

## 📷 Camera Entities

### Kameraknoten Canopy (Top-Down)
```
camera.canopy_camera                  # Live MJPEG Stream
camera.canopy_snapshot                # Letzter Snapshot
```

### Kameraknoten Detail (Macro)
```
camera.detail_camera                  # Live MJPEG Stream
camera.detail_snapshot                # Letzter Snapshot
```

---

## 💡 Light Entities

### Kameras (Flashlight)
```
light.canopy_camera_flash             # Canopy LED (GPIO4)
light.detail_camera_flash             # Detail LED (GPIO4)
```

---

## 🔌 Switch / Climate Entities

### Dosierknoten (Pumpen)
```
switch.pump_a_enable                  # Pumpe A (Haupt-Nährstoff)
switch.pump_b_enable                  # Pumpe B (pH Down)
switch.pump_c_enable                  # Pumpe C (pH Up)
switch.pump_d_enable                  # Pumpe D (Additiv)
switch.stirrer_enable                 # Rührmotor
```

### Klimaknoten (Aktoren)
```
switch.befeuchter                     # Befeuchter
switch.entfeuchter                    # Entfeuchter
switch.heizung                        # Heizung
switch.umluft_fan                     # Umluft-Ventilator
fan.exhaust_fan                       # Abluft-Ventilator (PWM)
```

---

## 📝 Input Select Entities

### Strategie-Selektoren
```
input_select.growth_stage             # Wachstumsstadium (Auto/Manual)
input_select.light_cycle              # Lichtzyklus (18/6, 20/4, 12/12, 24/0)
input_select.nutrient_strategy        # EC Target (Konservativ/Standard/Aggressiv)
input_select.vpd_strategy             # VPD Regelung (Konservativ/Standard/Aggressiv)
```

### Manual Triggers
```
input_boolean.manual_canopy_snapshot  # Canopy Foto auslösen
input_boolean.manual_detail_snapshot  # Detail Foto auslösen
input_boolean.ki_learning_mode        # KI Learning-Tipps aktivieren
```

---

## 🔄 Service Calls

### Kamera-Services
```
camera.snapshot                       # Snapshot erstellen
camera.play_stream                    # Stream starten
```

### Dosierung-Services
```
service: dosierung.dose_nutrient      # Manuelle Dosierung
data:
  pump: "pump_a"  # oder b, c, d
  duration_ms: 5000  # ms
```

### KI Services
```
service: ki.analyze_plant_stress      # KI-Analyse starten
service: ki.get_recommendations       # Empfehlungen abrufen
```

---

## 📊 Dashboard Access

### HTTP APIs (falls freigeschaltet)
```
Hydroknoten Web:    http://192.168.30.10
Dosierung Web:      http://192.168.30.11
Zeltsensor Web:     http://192.168.30.12
Klimaknoten Web:    http://192.168.30.13
Canopy Camera:      http://192.168.30.95
Detail Camera:      http://192.168.30.96
```

---

**Last Updated**: 06.12.2025
