#!/bin/bash
################################################################################
# DiXY RDWC Controller - Installation Script für Home Assistant (Raspberry Pi)
# 
# Installiert alle Dependencies für v0.1-beta
# Macht automatische Backups
################################################################################

set -e

echo "🌱 DiXY RDWC Controller - Home Assistant Installation"
echo "======================================================"
echo ""

# ===== Farben für Output =====
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ===== Backup erstellen =====
echo -e "${YELLOW}📦 Creating backup...${NC}"
BACKUP_DIR="/backup/dixy_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r /config/esphome "$BACKUP_DIR/" 2>/dev/null || true
cp -r /config/www "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}✅ Backup saved to: $BACKUP_DIR${NC}"
echo ""

# ===== Python Packages =====
echo -e "${YELLOW}📚 Installing Python packages...${NC}"

pip install opencv-python==4.8.1.78
pip install numpy==1.24.3
pip install pillow>=10.0.0

echo -e "${GREEN}✅ Python packages installed${NC}"
echo ""

# ===== Ordnerstruktur erstellen =====
echo -e "${YELLOW}📂 Creating folder structure...${NC}"

mkdir -p /config/www/timelapse/canopy
mkdir -p /config/www/timelapse/detail
mkdir -p /config/www/timelapse/videos
mkdir -p /config/python_scripts
mkdir -p /config/esphome

echo -e "${GREEN}✅ Folders created${NC}"
echo ""

# ===== ESPHome Secrets Template =====
echo -e "${YELLOW}🔐 Creating secrets template...${NC}"

if [ ! -f /config/esphome/secrets.yaml ]; then
    cat > /config/esphome/secrets.yaml << 'EOF'
# ESPHome Secrets - Ergänze mit deinen echten Werten!
wifi_ssid: "DEIN_WLAN_NAME"
wifi_password: "DEIN_WLAN_PASSWORT"

# Fallback APs
hydroknoten_ap_ssid: "HYDROKNOTEN_Fallback"
hydroknoten_ap_password: "DEIN_FALLBACK_PASSWORT"

dosierung_ap_ssid: "DOSIERUNG_Fallback"
dosierung_ap_password: "DEIN_FALLBACK_PASSWORT"

zeltsensor_ap_ssid: "ZELT_Fallback"
zeltsensor_ap_password: "DEIN_FALLBACK_PASSWORT"

klimaknoten_ap_ssid: "KLIMAKNOTEN_Fallback"
klimaknoten_ap_password: "DEIN_FALLBACK_PASSWORT"

canopy_cam_ap_ssid: "Canopy-Cam Fallback"
canopy_cam_ap_password: "DEIN_FALLBACK_PASSWORT"

detail_cam_ap_ssid: "Detail-Cam Fallback"
detail_cam_ap_password: "DEIN_FALLBACK_PASSWORT"

# OTA Passwords
ota_password: "DEIN_OTA_PASSWORT"
hydroknoten_ota_password: "DEIN_OTA_PASSWORT"
dosierung_ota_password: "DEIN_OTA_PASSWORT"
zeltsensor_ota_password: "DEIN_OTA_PASSWORT"
klimaknoten_ota_password: "DEIN_OTA_PASSWORT"
camera_ota_password: "DEIN_OTA_PASSWORT"

# Web Server
web_username: "admin"
web_password: "DEIN_WEB_PASSWORT"

# Static IPs
gateway_ip: "192.168.30.1"
subnet_mask: "255.255.255.0"
canopy_cam_ip: "192.168.30.95"
detail_cam_ip: "192.168.30.96"
EOF
    
    chmod 600 /config/esphome/secrets.yaml
    echo -e "${GREEN}✅ secrets.yaml template created${NC}"
    echo -e "${YELLOW}⚠️  WICHTIG: Bearbeite /config/esphome/secrets.yaml mit deinen Werten!${NC}"
else
    echo -e "${GREEN}✅ secrets.yaml bereits vorhanden${NC}"
fi
echo ""

# ===== Home Assistant Config-Dirs =====
echo -e "${YELLOW}🔧 Checking Home Assistant configuration...${NC}"

if [ ! -d /config/python_scripts ]; then
    mkdir -p /config/python_scripts
fi

echo -e "${GREEN}✅ Home Assistant ready${NC}"
echo ""

# ===== ESP32-CAM Flash-Anweisung =====
echo -e "${YELLOW}🎥 ESP32-CAM Flash Instructions:${NC}"
cat << 'EOF'

Die ESP32-CAM Module benötigen FTDI-Adapter für den Initial-Flash:

1. Verbinde FTDI mit ESP32-CAM:
   - FTDI 5V → ESP32-CAM VCC
   - FTDI GND → ESP32-CAM GND
   - FTDI TX → ESP32-CAM RX
   - FTDI RX → ESP32-CAM TX
   - Jumper: IO0 ← GND (Flash Mode!)

2. Terminal öffnen:
   esphome run ESP32-Knoten/kameraknoten_canopy.yaml

3. Nach erfolgreichem Flash: IO0 Jumper entfernen

4. Strom neustarten - Kamera sollte jetzt über OTA updates unterstützen!

Weitere Infos: docs/GITHUB_UPLOAD_GUIDE.md
EOF

echo ""

# ===== Fertig =====
echo -e "${GREEN}======================================================"
echo "✅ Installation abgeschlossen!"
echo "======================================================"
echo ""
echo "📋 Nächste Schritte:"
echo "1. Bearbeite /config/esphome/secrets.yaml"
echo "2. Flashe ESP32 Nodes über ESPHome Dashboard"
echo "3. Importiere automations.yaml in configuration.yaml"
echo "4. Starte Home Assistant neu"
echo ""
echo "🌱 Viel Erfolg mit deinem RDWC-System!"
echo ""
