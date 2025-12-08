# 🔐 DiXY Secrets Management - Anleitung

## Übersicht

Das Projekt verwendet **zwei Arten von Secrets-Dateien**:

### 1. Template-Dateien (IN Git, öffentlich)
- `secrets_sim.yaml` - Template mit Platzhaltern
- `Home-Assistant/secrets.yaml.example` - HA Template

### 2. Lokale Dateien (NICHT in Git)
- `secrets.yaml` - Echte Produktions-Secrets
- `secrets_sim_local.yaml` - Echte Simulations-Secrets

---

## 🚀 Erste Einrichtung (Copy & Paste)

### Schritt 1: Template kopieren
```bash
# Für Simulation (ohne Hardware)
cp secrets_sim.yaml secrets_sim_local.yaml

# Für Produktion (mit Hardware)
cp secrets_sim.yaml secrets.yaml

# Für Home Assistant
cp Home-Assistant/secrets.yaml.example Home-Assistant/secrets.yaml
```

### Schritt 2: Werte eintragen

Öffne die **lokale** Datei (`secrets_sim_local.yaml` oder `secrets.yaml`) und ersetze:

```yaml
# Vorher (Template):
wifi_ssid: "YOUR_WIFI_SSID"
wifi_password: "YOUR_WIFI_PASSWORD"

# Nachher (deine Werte):
wifi_ssid: "dixy"
wifi_password: "dein_echtes_wifi_passwort"
```

### Schritt 3: ESPHome Config anpassen

**Wichtig:** In deinen ESPHome YAML-Dateien muss auf die **lokale** Datei referenziert werden:

```yaml
# Für Simulation:
<<: !include secrets_sim_local.yaml

# Für Produktion:
<<: !include secrets.yaml
```

---

## 📋 Welche Datei wofür?

| Datei | Verwendung | In Git? | Passwörter? |
|-------|-----------|---------|-------------|
| `secrets_sim.yaml` | **Template** für Copy & Paste | ✅ JA | ❌ NEIN (Platzhalter) |
| `secrets_sim_local.yaml` | **Lokal** für Simulation | ❌ NEIN | ✅ JA (echt) |
| `secrets.yaml` | **Lokal** für Produktion | ❌ NEIN | ✅ JA (echt) |

---

## ⚠️ Wichtige Regeln

### ✅ DAS solltest du tun:
1. Template (`secrets_sim.yaml`) kopieren → lokale Datei erstellen
2. Nur in **lokalen** Dateien echte Passwörter eintragen
3. Lokale Dateien NIE in Git committen
4. Bei Änderungen: Template updaten, dann lokal neu kopieren

### ❌ DAS solltest du NICHT tun:
1. Echte Passwörter in `secrets_sim.yaml` (Template) eintragen
2. `secrets.yaml` oder `secrets_sim_local.yaml` committen
3. Passwörter in Slack/Discord/öffentliche Chats posten

---

## 🔄 Workflow: Neues Secret hinzufügen

### 1. Template erweitern
```yaml
# secrets_sim.yaml (Template)
new_api_key: "YOUR_API_KEY_HERE"
```

### 2. Lokal übernehmen
```bash
# Manuell in secrets_sim_local.yaml oder secrets.yaml eintragen:
new_api_key: "sk-abc123xyz..."
```

### 3. In ESPHome Config verwenden
```yaml
# dosierung_v2.yaml
api:
  encryption:
    key: !secret new_api_key
```

---

## 🛡️ Sicherheits-Checkliste

- [ ] `secrets.yaml` steht in `.gitignore`
- [ ] `secrets_sim_local.yaml` steht in `.gitignore`
- [ ] `git status` zeigt KEINE `secrets*.yaml` außer Template
- [ ] Template (`secrets_sim.yaml`) enthält NUR Platzhalter
- [ ] WiFi-Passwort wurde nach GitHub-Upload geändert
- [ ] OTA-Passwörter wurden geändert

---

## 🚨 Passwort geleakt? Sofort handeln!

### Wenn Passwort auf GitHub gelandet:
```bash
# 1. Aus Git-History entfernen
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch secrets_sim.yaml" \
  --prune-empty --tag-name-filter cat -- --all

# 2. Force-Push (⚠️ VORSICHT!)
git push origin --force --all

# 3. WICHTIG: Passwörter sofort ändern!
# - WiFi-Router neu konfigurieren
# - OTA-Passwörter in secrets.yaml ändern
# - Alle ESP32 neu flashen
```

### Einfachere Methode (empfohlen):
```bash
# 1. Passwörter ändern (Router, secrets.yaml)
# 2. Template bereinigen (bereits gemacht ✅)
# 3. Alte Commits ignorieren (History bleibt, aber neue Passwörter aktiv)
```

---

## 📖 Weitere Infos

- **Secrets Verwaltung:** `docs/SECRETS_MANAGEMENT.md`
- **ESPHome Docs:** https://esphome.io/guides/faq.html#how-do-i-use-secrets-yaml
- **Home Assistant:** https://www.home-assistant.io/docs/configuration/secrets/

---

## ✅ Quick-Check: Ist mein Setup sicher?

```bash
# Prüfe, welche Dateien Git trackt:
git ls-files | grep secrets

# Sollte NUR zeigen:
# - secrets_sim.yaml (Template)
# - Home-Assistant/secrets.yaml.example (Template)

# Wenn secrets.yaml oder secrets_sim_local.yaml erscheinen → PROBLEM!
```

---

**Stand:** 7. Dezember 2025  
**Projekt:** DiXY-Controller v0.2-beta
