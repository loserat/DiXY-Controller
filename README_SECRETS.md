# Secrets Management (DiXY-Controller)

## Vorgehen für alle Knoten

1. **Beispiel-Datei nutzen:**
   - Jede Komponente enthält eine `secrets.yaml.example` mit allen nötigen Keys.
2. **Eigene secrets.yaml anlegen:**
   - Kopiere die Beispiel-Datei und trage deine echten Zugangsdaten ein.
3. **Git-Schutz:**
   - Die Datei `secrets.yaml` ist in `.gitignore` eingetragen und wird niemals ins Repository hochgeladen.

## Beispiel
```sh
cp ESP32-Knoten/zeltsensor/v2/secrets.yaml.example ESP32-Knoten/zeltsensor/v2/secrets.yaml
```

## Wichtig
- Niemals echte Passwörter oder Tokens in die Beispiel-Datei schreiben!
- Die zentrale `secrets.yaml` im Hauptverzeichnis kann für globale Werte genutzt werden.
