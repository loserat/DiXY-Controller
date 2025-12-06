#!/bin/bash

################################################################################
# DiXY Controller – Interaktives Setup-Skript
# 
# Erstellt secrets.yaml interaktiv für:
# - WiFi-Konfiguration
# - OTA & API Passwörter
# - Home Assistant Integration
# - Statische IPs (optional)
# - MQTT (optional)
#
# Verwendung: bash scripts/setup.sh
################################################################################

set -e

# Farben für Terminal Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

read_input() {
    local prompt="$1"
    local default="$2"
    local input
    
    if [ -z "$default" ]; then
        read -p "$(echo -e ${BLUE}$prompt${NC})" input
    else
        read -p "$(echo -e ${BLUE}$prompt [${default}]: ${NC})" input
        input="${input:-$default}"
    fi
    
    echo "$input"
}

# ═══════════════════════════════════════════════════════════════
# MAIN SETUP
# ═══════════════════════════════════════════════════════════════

print_header "🌿 DiXY Controller – Initialisierungs-Setup"

echo "Willkommen! Dieses Setup erstellt deine persönliche secrets.yaml"
echo "Diese Datei wird NICHT zu GitHub hochgeladen (in .gitignore)"
echo ""

# Check if secrets.yaml already exists
if [ -f "secrets.yaml" ]; then
    print_warning "secrets.yaml existiert bereits!"
    response=$(read_input "Möchtest du sie überschreiben? (j/n)" "n")
    if [ "$response" != "j" ]; then
        print_error "Setup abgebrochen."
        exit 1
    fi
fi

# ═══════════════════════════════════════════════════════════════
# WIFI CONFIGURATION
# ═══════════════════════════════════════════════════════════════

print_header "📡 WiFi-Konfiguration"

wifi_ssid=$(read_input "WiFi SSID (Netzwerkname):")
wifi_password=$(read_input "WiFi Passwort:")

print_success "WiFi SSID: $wifi_ssid"

# ═══════════════════════════════════════════════════════════════
# OTA PASSWORD
# ═══════════════════════════════════════════════════════════════

print_header "🔐 OTA Update Password"
echo "Dieses Passwort wird für Over-The-Air Updates verwendet"
echo "Es sollte UNTERSCHIEDLICH vom WiFi-Passwort sein"
echo ""

ota_password=$(read_input "OTA Passwort:" "esphome_secret")

# ═══════════════════════════════════════════════════════════════
# WEB SERVER PASSWORD
# ═══════════════════════════════════════════════════════════════

print_header "🌐 Web-Server Zugang"
echo "Für ESPHome Dashboard (http://node-ip)"
echo ""

web_username=$(read_input "Web-Benutzername:" "admin")
web_password=$(read_input "Web-Passwort:" "admin123")

# ═══════════════════════════════════════════════════════════════
# HOME ASSISTANT TOKEN
# ═══════════════════════════════════════════════════════════════

print_header "🏠 Home Assistant Integration"
echo "Du brauchst einen Long-Lived Access Token aus Home Assistant"
echo ""
echo "So erhältst du den Token:"
echo "1. Gehe zu: http://deine-ha-ip:8123/profile"
echo "2. Scrolle zu 'Long-Lived Access Tokens'"
echo "3. Klicke 'Create Token' und kopiere ihn"
echo ""

ha_url=$(read_input "Home Assistant URL:" "http://192.168.1.100:8123")
ha_token=$(read_input "Home Assistant Long-Lived Token:")

if [ -z "$ha_token" ]; then
    print_warning "Kein HA Token eingegeben – kann später hinzugefügt werden"
    ha_token="ADD_YOUR_TOKEN_HERE"
fi

# ═══════════════════════════════════════════════════════════════
# NETWORK CONFIGURATION
# ═══════════════════════════════════════════════════════════════

print_header "🌍 Netzwerk-Konfiguration"
echo "Falls du statische IPs verwenden möchtest (optional)"
echo ""

use_static=$(read_input "Statische IPs verwenden? (j/n)" "n")

if [ "$use_static" = "j" ]; then
    gateway_ip=$(read_input "Gateway IP:" "192.168.1.1")
    subnet_mask=$(read_input "Subnet Mask:" "255.255.255.0")
    dns_ip=$(read_input "DNS Server:" "8.8.8.8")
    
    print_header "📍 Node-spezifische IPs"
    hydroknoten_ip=$(read_input "Hydroknoten IP:" "192.168.1.10")
    dosierung_ip=$(read_input "Dosierung IP:" "192.168.1.11")
    zeltsensor_ip=$(read_input "Zeltsensor IP:" "192.168.1.12")
    klimaknoten_ip=$(read_input "Klimaknoten IP:" "192.168.1.13")
    canopy_cam_ip=$(read_input "Canopy Camera IP:" "192.168.1.95")
    detail_cam_ip=$(read_input "Detail Camera IP:" "192.168.1.96")
else
    gateway_ip="192.168.1.1"
    subnet_mask="255.255.255.0"
    dns_ip="8.8.8.8"
    hydroknoten_ip="192.168.1.10"
    dosierung_ip="192.168.1.11"
    zeltsensor_ip="192.168.1.12"
    klimaknoten_ip="192.168.1.13"
    canopy_cam_ip="192.168.1.95"
    detail_cam_ip="192.168.1.96"
    print_success "DHCP wird verwendet (dynamische IPs)"
fi

# ═══════════════════════════════════════════════════════════════
# MQTT (Optional)
# ═══════════════════════════════════════════════════════════════

print_header "🔌 MQTT (Optional)"
echo "Falls du MQTT Broker verwenden möchtest (z.B. Mosquitto)"
echo ""

use_mqtt=$(read_input "MQTT verwenden? (j/n)" "n")

if [ "$use_mqtt" = "j" ]; then
    mqtt_broker=$(read_input "MQTT Broker IP:" "192.168.1.100")
    mqtt_username=$(read_input "MQTT Benutzername:" "mqtt_user")
    mqtt_password=$(read_input "MQTT Passwort:" "mqtt_pass")
else
    mqtt_broker="192.168.1.100"
    mqtt_username="mqtt_user"
    mqtt_password="mqtt_passwort"
fi

# ═══════════════════════════════════════════════════════════════
# CREATE secrets.yaml
# ═══════════════════════════════════════════════════════════════

print_header "💾 Erstelle secrets.yaml"

cat > secrets.yaml << EOF
# ═══════════════════════════════════════════════════════════════
# DiXY Controller – Secrets & Credentials
# ═══════════════════════════════════════════════════════════════
# Diese Datei ist in .gitignore – wird NICHT zu GitHub hochgeladen
# 
# Erstellt am: $(date)
# ═══════════════════════════════════════════════════════════════

# ===== WiFi Credentials =====
wifi_ssid: "${wifi_ssid}"
wifi_password: "${wifi_password}"

# ===== Fallback Access Points =====
hydroknoten_ap_ssid: "HYDROKNOTEN_Fallback"
hydroknoten_ap_password: "${ota_password}"

dosierung_ap_ssid: "DOSIERUNG_Fallback"
dosierung_ap_password: "${ota_password}"

zeltsensor_ap_ssid: "ZELTSENSOR_Fallback"
zeltsensor_ap_password: "${ota_password}"

klimaknoten_ap_ssid: "KLIMAKNOTEN_Fallback"
klimaknoten_ap_password: "${ota_password}"

canopy_cam_ap_ssid: "CANOPY_CAM_Fallback"
canopy_cam_ap_password: "${ota_password}"

detail_cam_ap_ssid: "DETAIL_CAM_Fallback"
detail_cam_ap_password: "${ota_password}"

# ===== OTA Update Passwords =====
ota_password: "${ota_password}"
hydroknoten_ota_password: "${ota_password}"
dosierung_ota_password: "${ota_password}"
zeltsensor_ota_password: "${ota_password}"
klimaknoten_ota_password: "${ota_password}"
camera_ota_password: "${ota_password}"

# ===== Web Server Credentials =====
web_username: "${web_username}"
web_password: "${web_password}"

# ===== Home Assistant Integration =====
ha_url: "${ha_url}"
ha_token: "${ha_token}"

# ===== Netzwerk =====
gateway_ip: "${gateway_ip}"
subnet_mask: "${subnet_mask}"
dns_ip: "${dns_ip}"

hydroknoten_static_ip: "${hydroknoten_ip}"
dosierung_static_ip: "${dosierung_ip}"
zeltsensor_static_ip: "${zeltsensor_ip}"
klimaknoten_static_ip: "${klimaknoten_ip}"
canopy_cam_ip: "${canopy_cam_ip}"
detail_cam_ip: "${detail_cam_ip}"

# ===== MQTT =====
mqtt_broker: "${mqtt_broker}"
mqtt_username: "${mqtt_username}"
mqtt_password: "${mqtt_password}"

# ===== Encryption Keys (werden von ESPHome generiert) =====
hydroknoten_encryption_key: ""
dosierung_encryption_key: ""
zeltsensor_encryption_key: ""
klimaknoten_encryption_key: ""
canopy_cam_encryption_key: ""
detail_cam_encryption_key: ""

# ===== Optional: API Keys =====
openai_api_key: ""
weatherapi_key: ""
telegram_bot_token: ""
telegram_chat_id: ""

EOF

print_success "✓ secrets.yaml erstellt!"

# ═══════════════════════════════════════════════════════════════
# VALIDATION & SUMMARY
# ═══════════════════════════════════════════════════════════════

print_header "✅ Setup abgeschlossen!"

echo "Deine Konfiguration:"
echo ""
echo "  WiFi SSID:        ${BLUE}${wifi_ssid}${NC}"
echo "  OTA Passwort:     ${BLUE}***${NC}"
echo "  Web-Zugang:       ${BLUE}${web_username} / ***${NC}"
echo "  HA Integration:   ${BLUE}${ha_url}${NC}"
echo "  Gateway:          ${BLUE}${gateway_ip}${NC}"
echo ""

echo "Nächste Schritte:"
echo ""
echo "1. ESPHome installieren:"
echo "   ${BLUE}pip install esphome${NC}"
echo ""
echo "2. Ersten ESP32 flashen:"
echo "   ${BLUE}esphome run ESP32-Knoten/hydroknoten.yaml${NC}"
echo ""
echo "3. Home Assistant konfigurieren (falls noch nicht geschehen):"
echo "   - Gehe zu: Einstellungen → Devices & Services → ESPHome"
echo "   - Alle 6 Nodes sollten automatisch erkannt werden"
echo ""
echo "4. secrets.yaml NIEMALS committen:"
echo "   ${BLUE}git status${NC}  (sollte secrets.yaml nicht anzeigen)"
echo ""

print_success "Setup erfolgreich! 🎉"
