# 🔐 Secrets Management Guide

## Quick Overview

```
LOKAL (bei dir - NICHT in Git):
secrets.yaml ← Deine echten Passwörter (in .gitignore)

GITHUB (öffentlich - GIT-SICHER):
hydroknoten.yaml ← Nur !secret Referenzen (keine echten Werte!)
```

---

## Wie es funktioniert

### Lokale Secrets:
```yaml
# secrets.yaml (LOKAL nur für dich)
wifi_ssid: "dixy"
wifi_password: "monochrome1"
ota_password: "nickler"
```

### In YAMLs:
```yaml
wifi:
  ssid: !secret wifi_ssid              # ESPHome ersetzt beim Flash
  password: !secret wifi_password      # mit echten Werten aus secrets.yaml
```

### GitHub sieht:
```yaml
wifi:
  ssid: !secret wifi_ssid              # ← NUR DIESE Referenz!
  password: !secret wifi_password      # Keine echten Werte!
```

---

## Sicherheits-Checkliste

- [ ] `secrets.yaml` ist in `.gitignore`
- [ ] Alle YAMLs nutzen `!secret` statt hardcoded Passwörter
- [ ] `git status` zeigt KEINE `secrets.yaml`
- [ ] Backup von `secrets.yaml` gemacht (optional)

---

**Mehr Details**: Siehe `SECRETS_MANAGEMENT.md` in `/docs`
