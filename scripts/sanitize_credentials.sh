#!/bin/bash
################################################################################
# sanitize_credentials.sh - Entferne Passwörter für GitHub Upload
# 
# Dieses Script ersetzt alle sensiblen Daten durch Platzhalter
# ACHTUNG: Erstellt Backups mit Timestamp!
################################################################################

set -e

BACKUP_DIR="backups_$(date +%Y%m%d_%H%M%S)"
YAML_DIR="ESP32-Knoten"

echo "🔒 Sanitize Credentials für GitHub Upload"
echo "=========================================="
echo ""

# Backup erstellen
echo "📦 Erstelle Backup nach: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -r "$YAML_DIR" "$BACKUP_DIR/"
echo "✅ Backup erstellt!"
echo ""

# Liste der zu ersetzenden Credentials
declare -A replacements=(
    ['password: "monochrome1"']='password: "YOUR_WIFI_PASSWORD"'
    ['password: "nicklker"']='password: "YOUR_WIFI_PASSWORD"'
    ['password: "nickler"']='password: "YOUR_OTA_PASSWORD"'
    ['ssid: "dixy"']='ssid: "YOUR_WIFI_SSID"'
    ['ssid: "monochrome1"']='ssid: "YOUR_WIFI_SSID"'
)

echo "🔄 Ersetze Credentials in YAML-Dateien..."
echo ""

for file in "$YAML_DIR"/*.yaml; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "  📝 Bearbeite: $filename"
        
        # Ersetze alle Credentials
        for search in "${!replacements[@]}"; do
            replace="${replacements[$search]}"
            sed -i '' "s|$search|$replace|g" "$file"
        done
    fi
done

echo ""
echo "✅ Alle Credentials ersetzt!"
echo ""
echo "📋 Überprüfung:"
echo "---------------"

# Prüfe ob noch echte Passwörter vorhanden sind
if grep -r "monochrome1\|nicklker\|nickler" "$YAML_DIR" 2>/dev/null; then
    echo "⚠️  WARNUNG: Noch Credentials gefunden!"
    echo "   Bitte manuell prüfen!"
else
    echo "✅ Keine echten Credentials mehr gefunden"
fi

echo ""
echo "🎯 Nächste Schritte:"
echo "1. Überprüfe: git diff"
echo "2. Falls OK: git add ."
echo "3. Commit: git commit -m 'Initial commit v0.1-beta'"
echo "4. GitHub Remote: git remote add origin https://github.com/USERNAME/dixy-rdwc-controller.git"
echo "5. Push: git push -u origin main"
echo ""
echo "💾 Backup liegt in: $BACKUP_DIR"
