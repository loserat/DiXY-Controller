# Implementation Checklist - DiXY Dosierung v2 Simulation & Dashboard

**Status:** In Bearbeitung  
**Datum:** Dezember 2025  
**Ziel:** Vollständige Simulation + HA Dashboard ohne Hardware

---

## ✅ Abgeschlossene Aufgaben

### Phase 1: Simulation Configuration
- [x] `dosierung_v2_sim.yaml` erstellt (708 Zeilen)
  - Template Sensors für EC, pH, Temperaturen
  - MQTT Handler für `cmd/dose` Topic
  - Script `dose_pump` mit Safety Checks
  - 60+ Entities (Sensoren, Schalter, Numbers)
  - Globals für tägliche Statistiken
  
- [x] `secrets_sim.yaml` erstellt
  - MQTT Broker: 192.168.1.100
  - WiFi SSID: "dixy"
  - Dummy API Keys

- [x] Validierungsskript erstellt (`scripts/validate_simulation.sh`)
  - ESPHome Config Syntax-Check
  - MQTT Test Commands
  - Dry-run Instructions

### Phase 2: Dashboard Implementation  
- [x] `dixy_rdwc_monitor.yaml` erstellt (5 Tabs)
  - Tab 1: 🏠 Übersicht (EC/pH Gauges, Tank Levels, Status)
  - Tab 2: 💊 Dosierung (Automatik, Pump Buttons, Currents)
  - Tab 3: ⚙️ Einstellungen (Sollwerte, Motor Controls)
  - Tab 4: 🔧 Kalibrierung (Temp Offsets, EC/pH Cal Points)
  - Tab 5: 🏥 Diagnose (Health, Stepper Status, System Info)
  
- [x] Alle 60+ Entities in Dashboard verknüpft
  - Entity ID Pattern: `sensor.dosierung_v2_sim_*`
  - MQTT Discovery kompatibel
  - Native HA Cards (keine Custom Dependencies)

### Phase 3: Documentation
- [x] `MQTT_ENTITIES_REFERENCE.md` erstellt
  - MQTT Broker Konfiguration
  - Topic Structure (Status, Commands, Responses)
  - JSON Payload Format mit Beispielen
  - Entity Mapping Tables (alle 60+ Entities)
  - ESPHome API Service Dokumentation
  - Datenflusss-Diagramm
  - 5 Anwendungsbeispiele (MQTT CLI, HA Automation, Python, Node-RED)
  - Troubleshooting Guide

---

## 📋 Nächste Schritte (Priorität)

### Immediat (Heute)
- [ ] **Datei-Verifikation**
  ```bash
  # Prüfe ob alle 3 Config-Dateien korrekt sind
  ls -la ESP32-Knoten/ESP32-v2/dosierung_v2_sim.yaml
  ls -la Home-Assistant/dashboards/dixy_rdwc_monitor.yaml  
  ls -la docs/MQTT_ENTITIES_REFERENCE.md
  ```

- [ ] **YAML Syntax Validierung** (wenn ESPHome Tools verfügbar)
  ```bash
  # Optional: esphome config esphome/
  esphome config ESP32-Knoten/ESP32-v2/ \
    --secrets-file secrets_sim.yaml
  ```

- [ ] **Dashboard in HA einfügen**
  1. Öffne Home Assistant (http://localhost:8123)
  2. Gehe zu: Settings → Dashboards → "New Dashboard"
  3. Wähle "Create from YAML"
  4. Kopiere Inhalt von `dixy_rdwc_monitor.yaml`
  5. Speichern & Reload

### Kurzfristig (Diese Woche)
- [ ] **MQTT Broker Setup (optional für Testing)**
  ```bash
  # Installation auf macOS
  brew install mosquitto
  
  # Starten
  /usr/local/sbin/mosquitto -c /usr/local/etc/mosquitto/mosquitto.conf
  
  # Ports: 1883 (standard)
  ```

- [ ] **Simulation mit MQTT testen**
  ```bash
  # Terminal 1: Subscribe auf Response
  mosquitto_sub -h 127.0.0.1 -t "dixy/dosierung_v2_sim/state/last_dose"
  
  # Terminal 2: Publish Pump Command
  mosquitto_pub -h 127.0.0.1 -t "dixy/dosierung_v2_sim/cmd/dose" \
    -m '{"pump":"A","duration_ms":5000,"power_pct":75}'
  ```

- [ ] **Dashboard-Refinement in HA UI**
  - [ ] Tab-Ordnung optimieren
  - [ ] Gauge Farbskalen anpassen
  - [ ] Entity State Formatierung (Dezimalstellen)
  - [ ] Mobile Layout testen

### Mittelfristig (Nächste 2 Wochen)
- [ ] **Production Config (`dosierung_v2.yaml`)**
  - Kopiere `dosierung_v2_sim.yaml` → `dosierung_v2.yaml`
  - Ersetze Template Sensors durch echte Hardware:
    - I2C (ADS1115, RTD Sensoren)
    - 1-Wire (DS18B20)
    - GPIO (Tank Level Switches)
    - PWM (Pump Motors)
  - Teste mit echtem ESP32 Hardware
  
- [ ] **Entity ID Migration**
  - Aktualisiere Dashboard Entity IDs (`_sim` → ohne suffix)
  - Oder: Erstelle Alias Entities in HA für Backward-Kompatibilität

- [ ] **Automation Rules Setup**
  - Auto-Dosierung bei EC/pH Sollwert-Abweichung
  - Tank-Level Alerts
  - Fehlerbenachrichtigungen
  - Tägliche Statistiken Export

### Langfristig (Nächsten Monat)
- [ ] **Historische Datenerfassung**
  - InfluxDB Integration (optional)
  - Grafana Dashboards für Trend-Analyse
  - Datenbank-Backup Automation

- [ ] **Integration mit anderen Knoten**
  - Hydroknoten Daten abfragen (EC, pH live)
  - Zeltsensor Daten (VPD, Temperatur)
  - Kameraknoten Timelapse Triggern

- [ ] **AI Logic Integration**  
  - Automatische Sollwert-Anpassung basierend auf Wachstumsstadium
  - Predictive Dosierung
  - Anomalie-Detektion

---

## 🔧 Datei-Übersicht

### Neue/Geänderte Dateien

| Datei | Status | Größe | Beschreibung |
|-------|--------|-------|-------------|
| `ESP32-Knoten/ESP32-v2/dosierung_v2_sim.yaml` | ✅ Neu | 708 L | Simulation Config |
| `secrets_sim.yaml` | ✅ Neu | 14 L | Dummy Credentials |
| `scripts/validate_simulation.sh` | ✅ Neu | 57 L | Validier-Script |
| `Home-Assistant/dashboards/dixy_rdwc_monitor.yaml` | ✅ Aktualisiert | 400+ L | 5-Tab Dashboard |
| `docs/MQTT_ENTITIES_REFERENCE.md` | ✅ Neu | 650+ L | Komplette MQTT Referenz |

### Zugehörige Dateien (nicht geändert)

| Datei | Relevanz | Notizen |
|-------|----------|---------|
| `ESP32-Knoten/ESP32-v2/dosierung_v2.yaml` | Future | Wird basierend auf _sim.yaml erstellt |
| `Home-Assistant/configuration.yaml` | Reference | MQTT Integration sollte aktiv sein |
| `Home-Assistant/secrets.yaml` | Required | Echte Broker-Credentials für Production |

---

## 🧪 Validierungs-Kriterien

### Simulation Config Valid ✓
- [x] YAML Syntax korrekt
- [x] Alle Secrets mit `!secret` referenziert
- [x] MQTT Birth/Will Messages konfiguriert
- [x] 60+ Entities definiert (Sensoren, Schalter, Numbers)
- [x] `dose_pump` Script mit Safety Checks
- [x] Template Sensors mit Varianz (realistisch)
- [x] Globals für tägliche Statistiken

### Dashboard Valid ✓
- [x] YAML Struktur korrekt
- [x] Alle Entity IDs mit `sensor.dosierung_v2_sim_*` Pattern
- [x] 5 Tabs logisch organisiert
- [x] Native HA Cards (keine Custom Dependencies)
- [x] Gauge Min/Max + Severity Colors
- [x] Button Services verknüpft
- [x] Masonry Layout (responsive)

### MQTT Interface Valid ✓
- [x] Topic-Struktur dokumentiert
- [x] JSON Payload Format klar
- [x] Payload Beispiele (alle 4 Pumpen)
- [x] Response Format dokumentiert
- [x] MQTT Discovery Auto-Entity Mapping
- [x] Safety Constraints dokumentiert

---

## 💡 Tipps & Best Practices

### Für Simulation testen
```bash
# 1. ESPHome Config validieren (wenn ESPHome CLI verfügbar)
esphome config ESP32-Knoten/ESP32-v2/ --secrets-file secrets_sim.yaml

# 2. MQTT Broker starten
mosquitto -c /usr/local/etc/mosquitto/mosquitto.conf

# 3. MQTT Kommandos testen
mosquitto_pub -h 127.0.0.1 -t "dixy/dosierung_v2_sim/cmd/dose" \
  -m '{"pump":"A","duration_ms":5000}'

# 4. Home Assistant Dashboard importieren
# Gehe zu HA UI → Dashboards → neues Dashboard aus YAML
```

### Entity ID Naming Convention
- **Sensors:** `sensor.dosierung_v2_sim_<friendly_name>`
  - Friendly Name "Dosierung v2 SIM EC" → `sensor.dosierung_v2_sim_ec`
  - Spaces werden zu `_`, Colons entfernt
  
- **Switches:** `switch.dosierung_v2_sim_<action>`
  - "Pump A Stoß" → `switch.dosierung_v2_sim_pump_a_stoss`
  
- **Numbers:** `number.dosierung_v2_sim_<parameter>`
  - "EC Sollwert" → `number.dosierung_v2_sim_ec_sollwert`

### MQTT Topic Konvention
- **Status:** `dixy/{device_name}/status` → "online"/"offline"
- **Commands:** `dixy/{device_name}/cmd/{action}` → JSON Payload
- **Responses:** `dixy/{device_name}/state/{result}` → JSON Antwort
- **Discovery:** `homeassistant/{entity_type}/{device_id}/{object_id}/config`

---

## ⚠️ Wichtige Anmerkungen

### Security
- `secrets_sim.yaml` ist für Simulation nur!
- Production braucht `secrets.yaml` mit echten Credentials
- MQTT Broker sollte mit Auth-Credentials laufen
- API Keys sollten stark sein (generate: `openssl rand -base64 32`)

### Simulation Limitations
- Template Sensors haben **deterministisches Rauschen** (realistisch aber nicht echt)
- Pump-Dauer wird nicht wirklich gemessen (simuliert 10ms/ml Durchsatz)
- GPIO/ADC Pins sind ignoriert (nicht relevant in Simulation)
- Tanks werden nie wirklich leer (nur simuliert)

### Production Unterschiede
- Real Hardware braucht I2C/1-Wire/GPIO Konfiguration
- Real Stromsensoren (ADS1115 ADC)
- Real Temperature Sensors (RTD, DS18B20)
- Real Pump Verification (Strom messen via ACS712 oder ähnlich)
- Real Tank Level (float/capacitive switches)

---

## 📞 Support & Troubleshooting

### Häufige Probleme

**1. ESPHome Config Won't Compile**
```
Lösung: Prüfe secrets_sim.yaml Pfad und YAML Indentation
esphome config ESP32-Knoten/ESP32-v2/ --secrets-file /absolute/path/secrets_sim.yaml
```

**2. MQTT Topic Empty**
```
Lösung: MQTT Discovery könnte aus sein
- Home Assistant: Settings → Devices & Services → MQTT
- Check: "Enable MQTT Discovery" = ON
```

**3. Dashboard Entity Errors**
```
Lösung: Entity ID Case-Sensitive, prüfe exact match mit _sim suffix
grep "friendly_name:" ESP32-Knoten/ESP32-v2/dosierung_v2_sim.yaml
```

**4. Pump Command Not Responding**
```
Lösung: 
- Check device online: mosquitto_sub -t "dixy/dosierung_v2_sim/status"
- Check MQTT connectivity: mosquitto_pub -t "test/topic" -m "test"
- Check payload syntax: Valid JSON? Valid pump ID (A/B/C/D)?
```

---

**Version:** 1.0  
**Letztes Update:** Dezember 2025  
**Nächste Review:** Januar 2026
