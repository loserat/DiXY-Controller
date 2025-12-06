# DiXY Controller – Setup Anleitung

Willkommen bei DiXY RDWC! Diese Anleitung zeigt dir, wie du die Lösung installierst und konfigurierst.

## 🚀 Quick Start (5 Minuten)

### 1. Voraussetzungen
- **Home Assistant** (Docker, VM oder native Installation)
- **ESPHome** Add-on in Home Assistant installiert
- **ESP32** Mikrocontroller (6 Stück für vollständiges System)
- **Python 3.8+** und **Git** auf deinem Computer
- **MQTT Broker** (optional, für externe Automationen)

### 2. Repository klonen
```bash
git clone https://github.com/loserat/DiXY-Controller.git
cd DiXY-Controller
```

### 3. Setup ausführen
```bash
bash scripts/setup.sh
```

Dieses Skript fragt nach:
- WiFi SSID und Passwort für die ESP32s
- OTA Update Passwort
- Home Assistant URL und API Token
- Optionale Netzwerk-Konfiguration (statische IPs, MQTT)

### 4. ESPHome Flashen
```bash
# Mit esphome CLI
esphome run ESP32-Knoten/hydroknoten.yaml

# Oder über Home Assistant UI:
# 1. Öffne: http://homeassistant.local:8123/dashboard/developer-tools/yaml
# 2. Kopiere den Inhalt aus ESP32-Knoten/hydroknoten.yaml
# 3. Starte das ESPHome Dashboard und compilen/flash die Node
```

### 5. Installation in Home Assistant
```bash
bash scripts/install.sh
```

Das Skript erkennt automatisch, ob Home Assistant bereits läuft und installiert DiXY-Konfiguration.

---

## 📋 Ausführliche Installations-Modi

### Fresh Install – Neue Home Assistant + DiXY

**Für Anfänger oder dedizierte DiXY-Installation empfohlen.**

#### Schritt 1: Home Assistant installieren
```bash
# Docker (macOS/Linux)
docker run -d \
  --name homeassistant \
  --restart unless-stopped \
  -e TZ=Europe/Berlin \
  -v ~/.homeassistant:/config \
  -p 8123:8123 \
  ghcr.io/home-assistant/home-assistant:latest
```

Oder download der vollen Distribution: https://www.home-assistant.io/installation/

#### Schritt 2: Warte auf erste HA-Initialisierung (ca. 5 Min)
```bash
# Überprüfe ob HA läuft
curl http://localhost:8123
```

#### Schritt 3: ESPHome Add-on installieren
1. Home Assistant öffnen: http://localhost:8123
2. **Settings** → **Add-ons** → **Add-on Store**
3. Suche nach **ESPHome**
4. Installieren und starten

#### Schritt 4: DiXY installieren
```bash
cd /path/to/DiXY-Controller
bash scripts/setup.sh
bash scripts/install.sh
```

### Add-on Mode – DiXY zu bestehendem Home Assistant

**Wenn du bereits Home Assistant hast und nur DiXY hinzufügst.**

```bash
# 1. DiXY Repository klonen
git clone https://github.com/loserat/DiXY-Controller.git

# 2. Setup ausführen
bash DiXY-Controller/scripts/setup.sh

# 3. Installation durchführen
bash DiXY-Controller/scripts/install.sh
```

Das Skript erkennt automatisch deine bestehende HA-Installation und fügt DiXY-Komponenten ein.

---

## 🔧 Konfiguration nach Installation

### Home Assistant Token erstellen

Erforderlich für die ESP32-Kommunikation mit HA:

1. **Home Assistant öffnen**: http://homeassistant.local:8123
2. **Account-Menü** (rechts oben) → **"Longdevicetoken erstellen"** → **Profil**
3. Scroll zu **"Langzugriff-Tokens"**
4. **"Neuen Token erstellen"** klicken
5. Token name eingeben (z.B. "DiXY ESP32")
6. **Token kopieren** und in `setup.sh` eingeben (oder später in `secrets.yaml` aktualisieren)

### WiFi Konfiguration

Die `setup.sh` fragt nach:
- **SSID**: Name deines WiFi-Netzwerks
- **Passwort**: WiFi-Passwort
- **OTA Passwort**: Separates Passwort für Over-The-Air Updates

Diese werden in `Home-Assistant/secrets.yaml` gespeichert (nicht im Git).

### MQTT (Optional)

Für externe Automationen oder Integration mit anderen Systemen:

```bash
# Während setup.sh:
# Gib "ja" bei MQTT-Frage ein und Broker-Details eingeben

# Oder manuell in secrets.yaml:
mqtt_broker: "mqtt.example.com"
mqtt_port: 1883
mqtt_user: "username"
mqtt_password: "password"
```

---

## 💾 ESPHome Flashen (Detailliert)

### Option 1: Mit esphome CLI (Empfohlen)

```bash
# Installation
pip install esphome

# In DiXY-Controller Verzeichnis
cd DiXY-Controller

# Flashen über USB
esphome run ESP32-Knoten/hydroknoten.yaml
```

**Erste mal:**
- ESP32 per USB anschließen
- Option `1` wählen für USB Gerät
- esphome kompiliert und flasht automatisch

**Weitere Updates:**
- Falls WiFi konfiguriert: OTA (Over-The-Air) verwenden – ESP32 wird automatisch erkannt

### Option 2: Über Home Assistant ESPHome Add-on

1. **ESPHome öffnen**: http://homeassistant.local:6052
2. **"Create New"** klicken
3. **Device name**: z.B. "hydroknoten"
4. **Device type**: ESP32 wählen
5. **YAML Editor** → Inhalt von `ESP32-Knoten/hydroknoten.yaml` kopieren
6. **Save** → **Compile & Install** → **USB** wählen

---

## 🌱 VPD Einstellung und Regelung

VPD (Vapor Pressure Deficit) ist der Schlüssel zu optimalem Pflanzenwachstum.

### Zielwerte konfigurieren

Die Werte sind in `dixy.config.yaml` vordefiniert, können aber in Home Assistant angepasst werden:

**Vegetative Phase:**
- Ideales VPD: 0.4 – 0.8 kPa
- Optimal: 0.6 kPa
- Temperatur: 18°C – 26°C
- Luftfeuchte: 50% – 70%

**Blüte Phase:**
- Ideales VPD: 1.0 – 1.6 kPa
- Optimal: 1.4 kPa
- Temperatur: 20°C – 28°C
- Luftfeuchte: 40% – 60%

### Regelung aktivieren

1. Home Assistant öffnen
2. **Dashboard** → **DiXY Control**
3. **VPD Settings** Section
4. **Growth Stage** auf "Vegetative" oder "Bloom" setzen
5. **Fan Speed** Manual oder Automatic wählen
6. Wenn Automatic: Fan-Geschwindigkeit wird automatisch basierend auf aktuellem VPD angepasst

### Automationen monitoren

```
Settings → Automations and Scenes → Suche nach "VPD"
```

Hier siehst du alle VPD-bezogenen Automationen und kannst sie aktivieren/deaktivieren.

---

## 📊 Sensoren und Sensor-Werte

### Verfügbare Sensoren pro Node

**hydroknoten.yaml:**
- Wasser-pH
- EC (Leitfähigkeit)
- Wasser-Temperatur
- Reservoir-Level

**dosierung.yaml:**
- Pump-Status (A, B, C)
- Dosier-Mengen

**zeltsensor.yaml:**
- Lufttemperatur
- Luftfeuchte (daraus VPD berechnet)
- CO2 (optional)
- PAR/Lux (Licht)

**klimaknoten.yaml:**
- Heizelement Status
- Lüfter Status
- Befeuchtung Status

**kameraknoten_canopy.yaml / kameraknoten_detail.yaml:**
- Status (online/offline)
- Snapshots für Timelapse

### Sensor-Wertebereiche

Siehe `dixy.config.yaml`:

```yaml
sensors:
  temperature:
    min: 5    # Alarm unter 5°C
    max: 35   # Alarm über 35°C
    
  humidity:
    min: 20   # Alarm unter 20%
    max: 95   # Alarm über 95%
    
  ph:
    min: 5.0  # Alarm unter 5.0
    max: 7.5  # Alarm über 7.5
```

---

## 🚨 Troubleshooting

### ESP32 verbindet sich nicht mit WiFi

1. **secrets.yaml überprüfen**:
   ```bash
   cat Home-Assistant/secrets.yaml | grep wifi
   ```

2. **SSID und Passwort prüfen**:
   - Keine Sonderzeichen im Passwort?
   - 2.4 GHz WiFi (nicht 5 GHz)?
   - WiFi-Name hat keine Umlaute?

3. **ESP32 Reset**: Hardware-Reset durchführen (Boot + Reset Buttons drücken)

4. **Logs überprüfen** (wenn schon in ESPHome):
   ```
   esphome logs ESP32-Knoten/hydroknoten.yaml
   ```

### Home Assistant erkennt die ESP32 nicht

1. **Integration hinzufügen**:
   - Settings → Devices & Services → Create Automation
   - ESPHome API wählen
   - IP/Hostname der ESP32 eingeben

2. **Firewall überprüfen**:
   - Port 6053 (ESPHome API) offen?
   - Ping: `ping esp32-hydroknoten.local`

3. **Secrets überprüfen**: HA Token gültig?

### Automationen sind rot markiert

1. **YAML Syntax**: 
   ```bash
   # Validiere die Dateien
   bash scripts/test-setup.sh
   ```

2. **Home Assistant neustarten**:
   - Settings → System → Restart Home Assistant

3. **Logs überprüfen**:
   - Settings → System → Logs

### VPD wird nicht berechnet

1. **Sensoren überprüfen**:
   - Temperature Sensor vorhanden?
   - Humidity Sensor vorhanden?
   - Beide aktuell Werte?

2. **Automation aktivieren**:
   ```
   Settings → Automations → Suche "VPD Calculation"
   ```

---

## 📚 Weitere Ressourcen

- **GitHub Repository**: https://github.com/loserat/DiXY-Controller
- **ESPHome Dokumentation**: https://esphome.io/
- **Home Assistant**: https://www.home-assistant.io/
- **VPD Rechner**: https://www.cannabisgrower.guide/vpd/

---

## ❓ Häufig gestellte Fragen

**F: Brauche ich alle 6 ESP32?**
A: Nein, du kannst mit weniger starten. Es ist nur empfohlen, alle Funktionen zu haben.

**F: Kann ich eine andere Datenbank nutzen (InfluxDB, Prometheus)?**
A: Ja, Home Assistant hat viele Add-ons dafür. Wir nutzen die Standard-History.

**F: Was passiert, wenn WiFi/Home Assistant ausfällt?**
A: Die ESP32s haben lokale Fallback-Logik (z.B. einfache Temperaturregelung ohne HA).

**F: Kann ich die Automationen anpassen?**
A: Ja! Alle Automationen sind in `Home-Assistant/automations.yaml` und können bearbeitet werden.

**F: Wo speichert HA die Daten?**
A: Standardmäßig in SQLite (`~/.homeassistant/home-assistant_v2.db`).

---

**Viel Erfolg mit DiXY! 🌿**
