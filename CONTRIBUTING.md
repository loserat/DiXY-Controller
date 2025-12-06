# Contributing to DiXY RDWC Controller

Danke dass du zu DiXY beitragen möchtest! 🌱

## Wie du helfen kannst

- 🐛 **Bugs melden**: Erstelle ein GitHub Issue
- ✨ **Features vorschlagen**: Diskussion starten
- 📝 **Dokumentation verbessern**: Pull Requests willkommen
- 🔧 **Code beitragen**: Features implementieren

## Development Setup

```bash
# Fork & Clone
git clone https://github.com/YOUR_USERNAME/dixy-rdwc-controller.git
cd dixy-rdwc-controller

# Create secrets.yaml lokal
cp secrets.yaml.example secrets.yaml
nano secrets.yaml  # Deine Werte

# Create Feature Branch
git checkout -b feature/my-feature

# Mache Änderungen...
git add .
git commit -m "feat: Add my feature"
git push -u origin feature/my-feature

# Erstelle Pull Request auf GitHub!
```

## Commit Messages

Format: `<type>: <description>`

- `feat:` Neues Feature
- `fix:` Bugfix
- `docs:` Dokumentation
- `refactor:` Code-Umstrukturierung
- `test:` Tests hinzugefügt

Beispiel:
```
feat: Add ML pest detection via YOLO

- Integrate YOLOv8 for pest identification
- Add confidence threshold config
- Update dashboard with pest alerts
```

## Testing

```bash
# ESPHome YAML validieren
esphome config ESP32-Knoten/hydroknoten.yaml

# Python Code testen
python -m pytest Home-Assistant/
```

## Lizenz

Durch einen Beitrag stimmst du zu, dass dein Code unter MIT License lizenziert wird.

---

**Questions?** Erstelle ein GitHub Discussion!

🌱 Viel Spaß beim Beitragen!
