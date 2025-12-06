# 🔐 DiXY Controller – Secrets Management & Setup

## ⚠️ WICHTIG: Sicherheit

Dieses Projekt enthält **sensitive Daten** (Passwörter, WiFi-Credentials, API Tokens). Diese werden **NIEMALS** in Git committet.

---

## 📁 Datei-Struktur

```
DiXY-Controller/
├── secrets.yaml                    ← 🔒 LOCAL ONLY (in .gitignore)
├── Home-Assistant/
│   └── secrets.yaml.example        ← 📖 PUBLIC Template
├── dixy.config.yaml                ← 📖 PUBLIC Config (KEINE Secrets!)
└── .gitignore                      ← Excludes secrets.yaml
```

---

## 🚀 Setup für neue User

### Schritt 1: Repository klonen

```bash
git clone https://github.com/loserat/DiXY-Controller.git
cd DiXY-Controller
```

### Schritt 2: Secrets-Datei erstellen

```bash
# Kopiere das Template
cp Home-Assistant/secrets.yaml.example secrets.yaml

# Editiere deine echten Werte
nano secrets.yaml
```

### Schritt 3: secrets.yaml füllen

Öffne `secrets.yaml` und ergänze **DEINE** Werte:

```yaml
# ===== WiFi =====
wifi_ssid: "dein_wlan_name"
wifi_password: "dein_wlan_passwort"

# ===== OTA Password =====
ota_password: "sicheres_passwort"

# ===== Home Assistant Token =====
ha_token: "dein_ha_token"
```

**Wie du einen HA Token erstellst:**
1. Home Assistant öffnen
2. Rechts unten: Profil → "Long-Lived Access Tokens"
3. "Create Token" Button
4. Name eingeben (z.B. "DiXY Controller")
5. Token kopieren und in `secrets.yaml` einfügen

### Schritt 4: Verify (optional)

```bash
# Checke dass secrets.yaml in .gitignore ist
cat .gitignore | grep secrets.yaml

# Output sollte sein:
# secrets.yaml
```

---

## 🔧 Verwendung in ESPHome

In deinen ESPHome YAML-Dateien kannst du Secrets so referenzieren:

```yaml
wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

api:
  password: !secret api_password

ota:
  password: !secret ota_password
```

ESPHome lädt automatisch die Werte aus `secrets.yaml`.

---

## 📄 Verwendung in Home Assistant

In `configuration.yaml` kannst du auch Secrets verwenden:

```yaml
homeassistant:
  api_password: !secret ha_api_password
```

---

## 🛡️ Best Practices

### ✅ RICHTIG:
```bash
# secrets.yaml ist LOCAL und wird NICHT gepusht
secrets.yaml        # ← Lokal nur bei dir
git ignore          # ← Konfiguriert, dass secrets.yaml ignoriert wird
```

### ❌ FALSCH:
```bash
# secrets.yaml mit echten Passwörtern in GitHub
git add secrets.yaml
git push             # ← NIEMALS MACHEN!
```

### 🔄 Wenn versehentlich gecommitted:

```bash
# Remove from history
git rm --cached secrets.yaml
git commit -m "🔐 Remove secrets.yaml from version control"
git push origin main

# Change all passwords!
# (falls secrets.yaml kompromittiert wurde)
```

---

## 📋 Checklist für Setup

- [ ] Repository geklont
- [ ] `secrets.yaml` aus `.example` erstellt
- [ ] WiFi-Credentials eingefügt
- [ ] OTA Passwords gesetzt
- [ ] HA Token generiert & eingefügt
- [ ] Verify: `secrets.yaml` in `.gitignore`
- [ ] Verify: `secrets.yaml` ist LOCAL only
- [ ] ESPHome kann `secrets.yaml` finden

---

## 🆘 Fehlerbehebung

### Problem: ESPHome kann secrets nicht finden

```
Could not find SECRET: wifi_ssid
```

**Lösung:**
1. Checke dass `secrets.yaml` im **ESPHome Root** liegt (nicht in Subfoldern)
2. YAML-Syntax checken (`:` nach Key, `!secret` vor Wert)
3. ESPHome Dashboard neu starten

### Problem: Git zeigt secrets.yaml an

```
git status
# Zeigt: secrets.yaml (modified)
```

**Lösung:**
```bash
# Tell git to stop tracking it
git rm --cached secrets.yaml
git commit -m "Stop tracking secrets.yaml"

# Verify
git status  # secrets.yaml sollte nicht mehr auftauchen
```

---

## 📚 Weitere Infos

- [ESPHome Secrets Documentation](https://esphome.io/guides/setup_espd.html#secrets)
- [Home Assistant Secrets](https://www.home-assistant.io/docs/configuration/secrets/)
- [GitHub Security - Removing sensitive data](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)

---

**Zuletzt aktualisiert:** 6. Dezember 2025
**Projekt:** DiXY Controller v0.2-beta
