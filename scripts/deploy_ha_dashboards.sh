#!/bin/bash

################################################################################
# DiXY Controller – Dashboard Auto-Deploy für Home Assistant
#
# Importiert automatisch alle DiXY-Dashboards, Automationen und Input Helpers
# in die Home Assistant Installation.
#
# Verwendung:
#   bash scripts/deploy_ha_dashboards.sh [HA_CONFIG_PATH]
################################################################################

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Standard HA_CONFIG ermitteln
if [ -n "$1" ]; then
    HA_CONFIG="$1"
elif [ -d ~/.homeassistant ]; then
    HA_CONFIG=~/.homeassistant
elif [ -d ~/homeassistant ]; then
    HA_CONFIG=~/homeassistant
else
    HA_CONFIG="/root/config"  # HAOS
fi

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_error() {
    echo -e "${RED}✗ FEHLER: $1${NC}"
    exit 1
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# ═══════════════════════════════════════════════════════════════
# SCHRITT 1: VALIDIERUNG
# ═══════════════════════════════════════════════════════════════

print_header "Schritt 1: Validierung"

if [ ! -d "$HA_CONFIG" ]; then
    print_error "Home Assistant Config Verzeichnis nicht gefunden: $HA_CONFIG"
fi

print_success "HA Config gefunden: $HA_CONFIG"

if [ ! -d "$PROJECT_DIR/Home-Assistant" ]; then
    print_error "DiXY Home-Assistant Verzeichnis nicht gefunden: $PROJECT_DIR/Home-Assistant"
fi

print_success "DiXY Konfiguration gefunden"

# ═══════════════════════════════════════════════════════════════
# SCHRITT 2: BACKUPS ERSTELLEN
# ═══════════════════════════════════════════════════════════════

print_header "Schritt 2: Backups erstellen"

BACKUP_DIR="$HA_CONFIG/.dixy_backup_$(date +%s)"
mkdir -p "$BACKUP_DIR"

backup_file() {
    local file=$1
    if [ -f "$HA_CONFIG/$file" ]; then
        cp "$HA_CONFIG/$file" "$BACKUP_DIR/"
        print_success "Backup: $file"
    fi
}

backup_file "automations.yaml"
backup_file "scripts.yaml"
backup_file "input_numbers.yaml"
backup_file "input_selects.yaml"
backup_file "input_booleans.yaml"
backup_file "configuration.yaml"

print_info "Backups unter: $BACKUP_DIR"

# ═══════════════════════════════════════════════════════════════
# SCHRITT 3: AUTOMATIONEN MERGEN
# ═══════════════════════════════════════════════════════════════

print_header "Schritt 3: Automationen und Scripts"

# Automationen
if [ -f "$PROJECT_DIR/Home-Assistant/automations.yaml" ]; then
    if [ -f "$HA_CONFIG/automations.yaml" ]; then
        # Merge: Neue Automationen hinzufügen
        echo "" >> "$HA_CONFIG/automations.yaml"
        tail -n +2 "$PROJECT_DIR/Home-Assistant/automations.yaml" >> "$HA_CONFIG/automations.yaml"
        print_success "Automationen gemergt"
    else
        cp "$PROJECT_DIR/Home-Assistant/automations.yaml" "$HA_CONFIG/"
        print_success "Automationen kopiert"
    fi
fi

# Scripts
if [ -f "$PROJECT_DIR/Home-Assistant/scripts.yaml" ]; then
    if [ -f "$HA_CONFIG/scripts.yaml" ]; then
        echo "" >> "$HA_CONFIG/scripts.yaml"
        tail -n +2 "$PROJECT_DIR/Home-Assistant/scripts.yaml" >> "$HA_CONFIG/scripts.yaml"
        print_success "Scripts gemergt"
    else
        cp "$PROJECT_DIR/Home-Assistant/scripts.yaml" "$HA_CONFIG/"
        print_success "Scripts kopiert"
    fi
fi

# ═══════════════════════════════════════════════════════════════
# SCHRITT 4: INPUT HELPERS
# ═══════════════════════════════════════════════════════════════

print_header "Schritt 4: Input Helpers"

for file in input_numbers.yaml input_selects.yaml input_booleans.yaml; do
    if [ -f "$PROJECT_DIR/Home-Assistant/$file" ]; then
        if [ -f "$HA_CONFIG/$file" ]; then
            echo "" >> "$HA_CONFIG/$file"
            tail -n +2 "$PROJECT_DIR/Home-Assistant/$file" >> "$HA_CONFIG/$file"
            print_success "$file gemergt"
        else
            cp "$PROJECT_DIR/Home-Assistant/$file" "$HA_CONFIG/"
            print_success "$file kopiert"
        fi
    fi
done

# ═══════════════════════════════════════════════════════════════
# SCHRITT 5: DASHBOARDS
# ═══════════════════════════════════════════════════════════════

print_header "Schritt 5: Dashboards"

if [ -d "$PROJECT_DIR/Home-Assistant/dashboards" ]; then
    mkdir -p "$HA_CONFIG/dashboards"
    
    for dashboard in "$PROJECT_DIR/Home-Assistant/dashboards"/*.yaml; do
        if [ -f "$dashboard" ]; then
            filename=$(basename "$dashboard")
            cp "$dashboard" "$HA_CONFIG/dashboards/$filename"
            print_success "Dashboard: $filename"
        fi
    done
else
    print_warning "Dashboards Verzeichnis nicht gefunden"
fi

# ═══════════════════════════════════════════════════════════════
# SCHRITT 6: CONFIGURATION.YAML AKTUALISIERUNG
# ═══════════════════════════════════════════════════════════════

print_header "Schritt 6: configuration.yaml Includes"

update_configuration_yaml() {
    local config_file="$HA_CONFIG/configuration.yaml"
    
    if [ ! -f "$config_file" ]; then
        print_warning "configuration.yaml nicht gefunden - überspringe"
        return
    fi
    
    # Prüfe ob Include bereits existiert
    if grep -q "^automation:.*!include automations.yaml" "$config_file"; then
        print_info "automation Include bereits vorhanden"
    else
        echo "automation: !include automations.yaml" >> "$config_file"
        print_success "automation Include hinzugefügt"
    fi
    
    if grep -q "^script:.*!include scripts.yaml" "$config_file"; then
        print_info "script Include bereits vorhanden"
    else
        echo "script: !include scripts.yaml" >> "$config_file"
        print_success "script Include hinzugefügt"
    fi
    
    if grep -q "^input_number:.*!include input_numbers.yaml" "$config_file"; then
        print_info "input_number Include bereits vorhanden"
    else
        echo "input_number: !include input_numbers.yaml" >> "$config_file"
        print_success "input_number Include hinzugefügt"
    fi
    
    if grep -q "^input_select:.*!include input_selects.yaml" "$config_file"; then
        print_info "input_select Include bereits vorhanden"
    else
        echo "input_select: !include input_selects.yaml" >> "$config_file"
        print_success "input_select Include hinzugefügt"
    fi
}

update_configuration_yaml

# ═══════════════════════════════════════════════════════════════
# SCHRITT 7: ABSCHLUSS
# ═══════════════════════════════════════════════════════════════

print_header "Dashboard Deployment Abgeschlossen!"

echo "DiXY-Konfiguration wurde zu Home Assistant hinzugefügt!"
echo ""
echo "Nächste Schritte:"
echo ""
echo "1. Home Assistant neu starten (Settings → System → Restart)"
echo ""
echo "2. Überprüfe die installierten Automationen:"
echo "   Settings → Automations and Scenes"
echo ""
echo "3. Öffne das DiXY Dashboard:"
echo "   http://homeassistant.local:8123/dashboard/dixy"
echo ""
echo "Bei Fehlern kannst du das Backup verwenden:"
echo "   cp -r $BACKUP_DIR/* $HA_CONFIG/"
echo ""
print_success "Viel Spaß mit DiXY!"
