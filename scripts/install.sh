#!/bin/bash

################################################################################
# DiXY Controller – Intelligentes Installationsskript
#
# Erkennt automatisch, ob Home Assistant bereits installiert ist und führt die
# entsprechende Installation durch (Fresh Install oder Add-on Mode).
#
# Verwendung:
#   bash scripts/install.sh
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
# SCHRITT 1: HOME ASSISTANT ERKENNUNG
# ═══════════════════════════════════════════════════════════════

print_header "Schritt 1: Home Assistant Erkennung"

detect_ha_installation() {
    # Prüfe Docker (Home Assistant Container/Compose)
    if command -v docker &> /dev/null; then
        if docker ps 2>/dev/null | grep -q "homeassistant\|ha-"; then
            echo "docker-container"
            return
        fi
    fi
    
    # Prüfe OS (Home Assistant OS / HassOS)
    if [ -f /etc/os-release ]; then
        if grep -q "HOME_ASSISTANT_OS\|HAOS" /etc/os-release 2>/dev/null; then
            echo "haos"
            return
        fi
    fi
    
    # Prüfe lokales HA Verzeichnis
    if [ -d ~/.homeassistant ] || [ -d ~/homeassistant ]; then
        echo "standalone"
        return
    fi
    
    # Prüfe über SSH/Shell Command (wenn HA läuft)
    if command -v hass &> /dev/null; then
        echo "python-venv"
        return
    fi
    
    echo "none"
}

HA_MODE=$(detect_ha_installation)

print_info "Erkannte Installation: ${YELLOW}$HA_MODE${NC}"

# ═══════════════════════════════════════════════════════════════
# SCHRITT 2: SETUP AUSFÜHREN (FALLS NÖTIG)
# ═══════════════════════════════════════════════════════════════

print_header "Schritt 2: Setup-Konfiguration"

if [ ! -f "Home-Assistant/secrets.yaml" ]; then
    print_warning "secrets.yaml nicht gefunden - Setup wird ausgeführt"
    
    if [ ! -x "scripts/setup.sh" ]; then
        chmod +x scripts/setup.sh
    fi
    
    bash scripts/setup.sh || print_error "Setup fehlgeschlagen"
    print_success "Setup abgeschlossen"
else
    print_success "secrets.yaml bereits vorhanden"
fi

# ═══════════════════════════════════════════════════════════════
# SCHRITT 3: INSTALLATION BASIEREND AUF MODE
# ═══════════════════════════════════════════════════════════════

print_header "Schritt 3: DiXY Installation"

case "$HA_MODE" in
    docker-container)
        install_docker_container
        ;;
    haos)
        install_haos
        ;;
    standalone)
        install_standalone
        ;;
    python-venv)
        install_python_venv
        ;;
    none)
        install_fresh_ha
        ;;
    *)
        print_error "Unbekannter HA-Modus: $HA_MODE"
        ;;
esac

# ═══════════════════════════════════════════════════════════════
# INSTALLATION FUNKTIONEN
# ═══════════════════════════════════════════════════════════════

install_fresh_ha() {
    print_header "FRESH INSTALL – Neue Home Assistant Installation"
    
    echo "Für einen Fresh Install mit DiXY integriert, folge bitte dieser Anleitung:"
    echo ""
    echo "1. Lade Home Assistant runter (https://www.home-assistant.io/installation/)"
    echo "2. Installiere auf deinem System (Docker, VirtualMachine, oder native)"
    echo "3. Starte Home Assistant und führe das Setup durch"
    echo "4. Danach führe dieses Skript erneut aus:"
    echo ""
    echo "    bash $PROJECT_DIR/scripts/install.sh"
    echo ""
    echo "Oder kopiere direkt die Konfiguration:"
    echo "    cp -r $PROJECT_DIR/Home-Assistant/automations.yaml ~/.homeassistant/"
    echo ""
    exit 1
}

install_docker_container() {
    print_header "Installation für Docker Container"
    
    HA_CONFIG="${HA_CONFIG:-.config/homeassistant}"
    
    if [ ! -d "$HA_CONFIG" ]; then
        print_error "Home Assistant Config Verzeichnis nicht gefunden: $HA_CONFIG"
    fi
    
    print_info "Kopiere DiXY-Konfiguration nach: $HA_CONFIG"
    
    # Kopiere Automationen, Scripts, Input Helpers
    cp "$PROJECT_DIR/Home-Assistant/automations.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/scripts.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/input_numbers.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/input_selects.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/input_booleans.yaml" "$HA_CONFIG/" || true
    
    # Kopiere Dashboards
    mkdir -p "$HA_CONFIG/dashboards"
    cp "$PROJECT_DIR/Home-Assistant/dashboards/"* "$HA_CONFIG/dashboards/" || true
    
    print_success "Konfiguration kopiert"
    
    # Dashboard Auto-Deploy
    deploy_dashboards "$HA_CONFIG"
}

install_haos() {
    print_header "Installation auf Home Assistant OS"
    
    HA_CONFIG="/root/config"
    
    print_info "Home Assistant OS erkannt - verwende: $HA_CONFIG"
    
    # SSH-Zugriff benötigt
    if ! ssh root@homeassistant.local "ls /root/config" &>/dev/null; then
        print_error "SSH-Zugriff zu Home Assistant OS nicht möglich"
    fi
    
    print_info "Kopiere Dateien via SCP..."
    scp -r "$PROJECT_DIR/Home-Assistant/"* root@homeassistant.local:$HA_CONFIG/ || true
    
    print_success "Konfiguration via SSH deployed"
}

install_standalone() {
    print_header "Installation für Standalone Home Assistant"
    
    # Erkenne Verzeichnis
    if [ -d ~/.homeassistant ]; then
        HA_CONFIG=~/.homeassistant
    elif [ -d ~/homeassistant ]; then
        HA_CONFIG=~/homeassistant
    else
        print_error "Home Assistant Verzeichnis nicht gefunden"
    fi
    
    print_info "Verwende HA Config: $HA_CONFIG"
    
    # Kopiere Dateien
    cp "$PROJECT_DIR/Home-Assistant/automations.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/scripts.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/input_numbers.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/input_selects.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/input_booleans.yaml" "$HA_CONFIG/" || true
    
    mkdir -p "$HA_CONFIG/dashboards"
    cp "$PROJECT_DIR/Home-Assistant/dashboards/"* "$HA_CONFIG/dashboards/" || true
    
    print_success "Konfiguration kopiert"
    
    # Dashboard Auto-Deploy
    deploy_dashboards "$HA_CONFIG"
}

install_python_venv() {
    print_header "Installation für Python venv"
    
    HA_CONFIG=~/.homeassistant
    
    if [ ! -d "$HA_CONFIG" ]; then
        print_error "Home Assistant Config nicht gefunden: $HA_CONFIG"
    fi
    
    print_info "Kopiere Dateien..."
    
    cp "$PROJECT_DIR/Home-Assistant/automations.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/scripts.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/input_numbers.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/input_selects.yaml" "$HA_CONFIG/" || true
    cp "$PROJECT_DIR/Home-Assistant/input_booleans.yaml" "$HA_CONFIG/" || true
    
    mkdir -p "$HA_CONFIG/dashboards"
    cp "$PROJECT_DIR/Home-Assistant/dashboards/"* "$HA_CONFIG/dashboards/" || true
    
    print_success "Konfiguration kopiert"
    
    deploy_dashboards "$HA_CONFIG"
}

deploy_dashboards() {
    local ha_config=$1
    
    print_info "Starte Dashboard Auto-Deploy..."
    
    if [ -x "$PROJECT_DIR/scripts/deploy_ha_dashboards.sh" ]; then
        bash "$PROJECT_DIR/scripts/deploy_ha_dashboards.sh" "$ha_config"
    else
        print_warning "deploy_ha_dashboards.sh nicht ausführbar - Dashboard-Konfiguration manuell aktualisieren"
    fi
}

# ═══════════════════════════════════════════════════════════════
# FINALE INFORMATIONEN
# ═══════════════════════════════════════════════════════════════

print_header "Installation Abgeschlossen!"

echo "DiXY Konfiguration wurde installiert!"
echo ""
echo "Nächste Schritte:"
echo ""
echo "1. Home Assistant UI öffnen:"
echo "   http://homeassistant.local:8123"
echo ""
echo "2. ESPHome flashing:"
echo "   cd $PROJECT_DIR"
echo "   esphome run ESP32-Knoten/hydroknoten.yaml"
echo ""
echo "3. Überprüfen Sie die Automationen unter:"
echo "   Settings → Automations and scenes"
echo ""
echo "Dokumentation: $PROJECT_DIR/docs/SETUP_GUIDE.md"
echo ""
