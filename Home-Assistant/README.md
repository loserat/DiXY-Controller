# DiXY RDWC – Home Assistant Integration

**Setup-Level:** ⭐⭐ (Anfänger-freundlich)  
**Voraussetzung:** Home Assistant bereits installiert + ESPHome Integration  
**Installationszeit:** 15 Min

---

## 🚀 Quick Start (3 Schritte)

### Schritt 1: Dateien kopieren
```bash
# Kopiere alle .yaml Dateien aus diesem Ordner in dein HA config Verzeichnis:
cp *.yaml ~/.homeassistant/
```

### Schritt 2: configuration.yaml updaten
Öffne `~/.homeassistant/configuration.yaml` und füge am Ende hinzu:

```yaml
# DiXY RDWC Integration
homeassistant:
  packages:
    dixy_rdwc_inputs: !include input_numbers.yaml
    dixy_rdwc_selects: !include input_selects.yaml

automation: !include automations/dixy_rdwc_automations.yaml
script: !include scripts/dixy_scripts.yaml
```

### Schritt 3: HA Restart
```
Developer Tools → YAML → Restart Home Assistant
```


**Done!** Dashboard + Automations sind aktiv! 🎉

**Hinweis:** Die Dummy-Sensorwerte werden mit der finalen Hardware automatisch durch echte Werte ersetzt. Die Simulation ist dann nicht mehr nötig.

---

## 📦 Was ist enthalten?

| Datei | Beschreibung |
|-------|-------------|
| `input_numbers.yaml` | EC/pH/Volumen Schieber für Home Assistant |
| `input_selects.yaml` | Wachstumsstadium + Light Cycle Auswahl |
| `automations/dixy_rdwc_automations.yaml` | 11 Automations (EC/pH Auto-Dosierung, VPD, Alarme, etc.) |
| `scripts/dixy_scripts.yaml` | EC/pH Dosierungs-Logik + Hilfsskripte |
| `dashboards/dixy_rdwc_monitor.yaml` | Fertiges Lovelace Dashboard (6 Tabs) |

---

## ⚙️ Konfiguration

### Wichtigste Entity-IDs anpassen

Falls deine Knoten **andere Namen** haben, updatet einfach die Entity-IDs:

#### In `automations/dixy_rdwc_automations.yaml`:
```yaml
# Standard (deine Knoten):
entity_id: sensor.hydroknoten_ec_wert

# Falls anders benannt, z.B. "hydro":
entity_id: sensor.hydro_ec_wert
```

#### Alle Entity-IDs finden:
1. HA → Developer Tools → States
2. Suche nach "ec_wert" oder "ppfd"
3. Kopiere den **vollständigen entity_id**
4. Ersetze in YAML-Dateien

---

## 🎯 Dashboard laden

### Option A: Via UI (einfach)
1. **Home Assistant → Dashboards → Neues Dashboard**
2. **Drei Punkte → Code-Editor**
3. Öffne `dashboards/dixy_rdwc_monitor.yaml`
4. Kopiere kompletten Inhalt
5. Einfügen + Speichern
6. **Fertig!**

### Option B: Direkt in Ordner (wenn du YAML editieren magst)
```bash
cp dashboards/dixy_rdwc_monitor.yaml ~/.homeassistant/ui-lovelace-dashboard.yaml
```

---

## 🔌 ESPHome Knoten verbinden

### Deine ESP32 Nodes müssen diese Einstellungen haben:

```yaml
# In jedem *.yaml (hydroknoten.yaml, dosierung.yaml, etc.):

api:
  reboot_timeout: 0s

ota:
  platform: esphome
  password: !secret hydroknoten_ota_password  # oder dosierung/zeltsensor/etc
```

**✅ Das ist bereits in allen unseren YAMLs eingebaut!**

Falls deine Knoten noch nicht über ESPHome erreichbar sind:
1. HA → Settings → Devices & Services → ESPHome
2. "Create New Device" → IP-Adresse eingeben
3. Sollte deine Node automatisch erkennen

---

## ⚠️ Häufige Fehler + Lösungen

### "Fehler: input_number.ec_target nicht gefunden"
**Lösung:** `input_numbers.yaml` in HA einbinden (siehe Schritt 2)

```yaml
# In configuration.yaml
input_number: !include input_numbers.yaml
```

### "Automation funktioniert nicht / trigger nicht aktiv"
**Debug:**
1. HA → Developer Tools → Services
2. Suche "Call Service: automation.trigger"
3. Wähle Automation aus
4. "Call Service" drücken → sollte sofort triggern

### "Entity-IDs nicht erkannt"
**Fix:** Developer Tools → States → nach entity suchen

```
Suche: "ec_wert" 
Kopiere: "sensor.hydroknoten_ec_wert"
Ersetze in automation: "sensor.hydroknoten_ec_wert"
```

---

## 🎨 Dashboard anpassen

### Gauges umfärben
```yaml
type: gauge
entity: sensor.hydroknoten_ec_wert
severity:
  green: 1.2      # Grün wenn >= 1.2
  yellow: 1.0     # Gelb wenn >= 1.0
  red: 0.8        # Rot wenn < 0.8
```

### Cards verschieben
Im Dashboard einfach anfassen + ziehen! (Wenn Edit-Mode an ist)

### Neue Cards hinzufügen
1. **Edit-Modus An** (Stift-Icon oben rechts)
2. **+ Card** unten links
3. Typ auswählen (Gauge, Entities, History-Stats, etc.)
4. Entity auswählen
5. Speichern!

---

## 📊 Automations aktivieren

### Standard: Alle aktiv
Automations laden automatisch und starten sofort.

### Deaktivieren falls gewünscht:
1. HA → Settings → Automations & Scenes
2. Automation auswählen
3. Toggle **Off**

### Manuell testen:
1. Automation auswählen
2. Drei Punkte → **Execute**
3. Sollte sofort triggern (z.B. EC-Dosierung startet)

---

## 🔐 Secrets (WiFi Passwörter, OTA Keys)

### Falls noch nicht vorhanden, erstelle `secrets.yaml`:

```yaml
# ~/.homeassistant/secrets.yaml

wifi_ssid: "DeinWiFi-Name"
wifi_password: "DeinWiFi-Passwort"

hydroknoten_ota_password: "DeinOTA-Passwort"
dosierung_ota_password: "DeinOTA-Passwort"
zeltsensor_ota_password: "DeinOTA-Passwort"

# Falls Kameras mit static IP:
canopy_cam_ip: "192.168.1.100"
detail_cam_ip: "192.168.1.101"
gateway_ip: "192.168.1.1"
subnet_mask: "255.255.255.0"

# Web-UI Auth (optional):
web_username: "admin"
web_password: "passwort"
```

**⚠️ WICHTIG:** `secrets.yaml` niemals in Git committen!
- Ist in `.gitignore` → automatisch geschützt

---

## 🧪 Testing Checklist

Nach Installation diese Punkte prüfen:

- [ ] Alle Input Numbers sichtbar (EC/pH/Volumen/Photoperiode)
- [ ] Dashboard lädt ohne Fehler
- [ ] Werte der Knoten angezeigt (EC, pH, Temp, PPFD, etc.)
- [ ] Automations in Liste vorhanden
- [ ] Automation triggert manuell (Test-Knopf)
- [ ] EC-Soll Schieber zu 1.8 verschieben → Automation sollte triggern
- [ ] Keine roten Fehler im Logger

### Logs prüfen:
```
HA → Settings → System → Logs
Suche nach "automation" oder "dixy"
```

---

## 📞 Support

### Häufige Fragen:

**Q: Meine Knoten sind offline / nicht sichtbar**
A: 
1. Strom-Verbindung prüfen
2. WiFi-SSID / Passwort richtig?
3. HA gleiche Hardware-Adresse? (Settings → System → About)
4. `esphome logs hydroknoten.yaml` im Terminal ausführen

**Q: Automation triggert nicht**
A:
1. Automation aktiv? (Settings → Automations)
2. Condition richtig? (z.B. nur wenn EC < 1.5)
3. Manuelle Test: Automation auswählen → Execute
4. Logger prüfen für Fehler

**Q: Dashboard sieht komisch aus**
A:
1. Browser Reload (Strg+F5)
2. Dark Mode / Light Mode tauschen
3. Resolution prüfen (Mobile vs. Desktop)

---

## 🚀 Nächste Schritte

### Advanced Features (optional):

**1. Notifications hinzufügen:**
```yaml
# In automations, vor action:
- service: notify.mobile_app_dein_handy
  data:
    title: "EC kritisch!"
    message: "EC Wert zu niedrig: {{ states('sensor.hydroknoten_ec_wert') }}"
```

**2. Grafana Integration (Daten visualisieren):**
- InfluxDB installieren
- HA → Integrations → InfluxDB
- Grafana auf Port 3000 starten
- Dashboards erstellen

**3. Python Automations (Custom Scripts):**
- `packages/dixy_python_scripts.yaml` erstellen
- Custom Python für komplexe Logik

---

## 📝 Weitere Ressourcen

- **ESPHome Docs:** https://esphome.io/
- **Home Assistant Docs:** https://www.home-assistant.io/docs/
- **DiXY GitHub:** (Dein Repo Link)
- **Discord Support:** (Falls Community Discord)

---

**Viel Spaß mit DiXY! 🌱💧** Bei Fragen oder Problemen → GitHub Issues erstellen!
