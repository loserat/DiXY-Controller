# DiXY Quick Start – 5 Minuten

Die schnellste Weg zu deinem eigenen DiXY System.

## 1️⃣ Klonen & Setup

```bash
git clone https://github.com/loserat/DiXY-Controller.git
cd DiXY-Controller
bash scripts/setup.sh
```

## 2️⃣ Während setup.sh eingeben

```
WiFi SSID:              [dein-wlan-name]
WiFi Passwort:          [dein-passwort]
OTA Passwort:           [neues-sicheres-passwort]
HA URL:                 http://homeassistant.local:8123
HA Token:               [von HA kopiert]
Statische IP nutzen?:   nein
MQTT nutzen?:           nein
```

**HA Token erstellen:**
1. Home Assistant öffnen: http://homeassistant.local:8123
2. Account → Profil → Scrollen zu "Longdevicetoken"
3. "Neuen Token erstellen" → Token kopieren

## 3️⃣ Installation

```bash
bash scripts/install.sh
```

Das Skript:
- Erkennt deine HA-Installation automatisch
- Kopiert alle Konfigurationen
- Deployed die Dashboards

## 4️⃣ ESP32 flashen

Mit USB anschließen:
```bash
esphome run ESP32-Knoten/hydroknoten.yaml
```

Oder über Home Assistant ESPHome UI (http://homeassistant.local:6052)

## 5️⃣ Fertig! 🎉

Öffne das Dashboard:
```
http://homeassistant.local:8123/dashboard/dixy
```

---

## 🚀 Die erste Stunde

| Zeit | Was | Wo |
|------|-----|-----|
| 0–5 Min | Setup & Installation | Terminal |
| 5–15 Min | ESP32 über USB flashen | ESPHome |
| 15–30 Min | Sensoren kalibrieren (optional) | DiXY Dashboard |
| 30–60 Min | VPD Einstellung vornehmen | DiXY Settings |

---

## ⚠️ Wenn etwas nicht funktioniert

```bash
# Teste das Setup
bash scripts/test-setup.sh

# Prüfe HA Logs
curl http://homeassistant.local:8123/api/

# ESP32 Logs
esphome logs ESP32-Knoten/hydroknoten.yaml

# Secrets prüfen
cat Home-Assistant/secrets.yaml | head
```

---

👉 **Mehr Info?** Siehe `docs/SETUP_GUIDE.md`
