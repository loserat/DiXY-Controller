ja bitte# 🚀 Quick Start: GitHub Upload (mit Secrets-Schutz)

## 5-Minuten-Setup

### 1️⃣ Überprüfe deine `secrets.yaml`

```bash
# Ist deine secrets.yaml mit echten Werten gefüllt?
cat secrets.yaml | head -10

# Falls LEER: Füll sie jetzt aus!
nano secrets.yaml
```

**Wichtigste Werte:**
```yaml
wifi_ssid: "dixy"
wifi_password: "monochrome1"
ota_password: "nickler"
```

### 2️⃣ Überprüfe dass `secrets.yaml` NICHT in Git ist

```bash
# Das sollte NICHTS returnen (= secrets.yaml ist geschützt)
git status | grep secrets.yaml

# Falls doch: Entferne sie aus Git
git rm --cached secrets.yaml
git commit -m "Remove secrets.yaml from tracking (will be ignored)"
```

### 3️⃣ Überprüfe .gitignore

```bash
# Sollte "secrets.yaml" enthalten
grep secrets.yaml .gitignore

# Falls NICHT: Füg hinzu
echo "secrets.yaml" >> .gitignore
git add .gitignore
git commit -m "Add secrets.yaml to gitignore"
```

### 4️⃣ Überprüfe dass YAMLs `!secret` nutzen

```bash
# Dürfen KEINE echten Passwörter zeigen
grep -r "password:" ESP32-Knoten/*.yaml | grep -v secret

# Falls noch echte Passwörter: Manuell durch !secret ersetzen
```

### 5️⃣ Final Check vor Upload

```bash
# Zeige was hochgeladen wird
git status

# Detaillierter Check: Keine Passwörter?
git diff --cached | grep -i password
# Sollte nur "!secret" zeigen, KEINE echten Werte!
```

### 6️⃣ Commit & Push

```bash
# Füge alles hinzu
git add .

# Commit
git commit -m "Initial commit: DiXY RDWC Controller v0.1-beta

Includes:
- 6 ESP32 Nodes (Hydro, Dosier, Klima, Zelt, 2x Kamera)
- Home Assistant Integration
- KI Plant Stress Detector
- Secrets Management für sichere Credentials
- Complete documentation"

# GitHub Remote (ersetze USERNAME!)
git remote add origin https://github.com/USERNAME/dixy-rdwc-controller.git

# Push
git push -u origin main
```

---

## ✅ Überprüfung auf GitHub

1. Gehe zu: `https://github.com/USERNAME/dixy-rdwc-controller`
2. Öffne eine YAML: `ESP32-Knoten/hydroknoten.yaml`
3. Suche nach `password:`
4. Sollte sehen: `password: !secret wifi_password` ← RICHTIG ✅
5. NICHT sehen: `password: "monochrome1"` ← FALSCH ❌

---

## 🔑 Wichtig: Lokale Secrets bewahren!

```bash
# Deine secrets.yaml ist lokal und NICHT in Git
# Falls du den Repo clonest später:

git clone https://github.com/USERNAME/dixy-rdwc-controller.git
cd dixy-rdwc-controller

# secrets.yaml wird NICHT mitgeklont (wegen .gitignore)
# Du kannst deine alte secrets.yaml zurückcopieren:
cp /path/to/backup/secrets.yaml .

# Oder neu erstellen:
cp secrets.yaml.example secrets.yaml
nano secrets.yaml  # Deine Werte eintragen
```

---

## 🔒 Sicherheits-Checkliste

- [ ] `secrets.yaml` ist gefüllt mit echten Passwörtern
- [ ] `secrets.yaml` ist in `.gitignore`
- [ ] Alle YAMLs nutzen `!secret` statt hardcoded Passwörter
- [ ] `git status` zeigt KEINE `secrets.yaml`
- [ ] `git diff --cached` zeigt KEINE echten Passwörter
- [ ] GitHub zeigt nur `!secret` Referenzen
- [ ] Backup von `secrets.yaml` gemacht (optional aber empfohlen)

---

## 🚨 Falls was schiefgeht

### "secrets.yaml wurde hochgeladen!"

**SOFORT:**
```bash
# Passwörter ändern (WiFi, OTA, etc.)
# Dann: Entferne aus Git History
git log --oneline | grep -i secret
# Falls gefunden:
git revert COMMIT_HASH
git push
```

### "Passwörter sind noch in der YAMLs!"

**Fix:**
```bash
# Suche hardcoded Passwörter
grep -r 'password: "' ESP32-Knoten/

# Ersetze manuell durch !secret
nano ESP32-Knoten/hydroknoten.yaml
# password: "monochrome1" → password: !secret wifi_password

# Commit & Push
git add .
git commit -m "Fix: Use secrets instead of hardcoded passwords"
git push
```

---

## 📞 Support

- **Secrets Manager Doc**: `docs/SECRETS_MANAGEMENT.md`
- **Upload Guide**: `docs/GITHUB_UPLOAD_GUIDE.md`
- **Release Notes**: `RELEASE_NOTES.md`

---

**Bereit? Gib Bescheid wenn du ready bist zu pushen! 🚀**
