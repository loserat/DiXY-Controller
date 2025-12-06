#!/bin/bash

################################################################################
# DiXY Controller – Quick Setup Test
# 
# Testet die Setup-System-Dateien in wenigen Sekunden
# 
# Verwendung:
#   bash scripts/test-setup.sh
################################################################################

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

passed=0
failed=0

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

test_file() {
    local file=$1
    local name=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $name"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $name (FEHLT: $file)"
        ((failed++))
    fi
}

test_content() {
    local file=$1
    local pattern=$2
    local name=$3
    
    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $name"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $name"
        ((failed++))
    fi
}

# ═══════════════════════════════════════════════════════════════
# TEST 1: DATEIEN VORHANDEN?
# ═══════════════════════════════════════════════════════════════

print_header "TEST 1: Erforderliche Dateien"

test_file "scripts/setup.sh" "scripts/setup.sh"
test_file "scripts/install.sh" "scripts/install.sh"
test_file "scripts/deploy_ha_dashboards.sh" "scripts/deploy_ha_dashboards.sh"
test_file "dixy.config.yaml" "dixy.config.yaml"
test_file "Home-Assistant/secrets.yaml.example" "secrets.yaml.example"
test_file "docs/SETUP_GUIDE.md" "SETUP_GUIDE.md"
test_file ".gitignore" ".gitignore"

# ═══════════════════════════════════════════════════════════════
# TEST 2: BASH SYNTAX
# ═══════════════════════════════════════════════════════════════

print_header "TEST 2: Bash-Syntax Validierung"

if bash -n scripts/setup.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} scripts/setup.sh Syntax OK"
    ((passed++))
else
    echo -e "${RED}✗${NC} scripts/setup.sh hat Syntaxfehler"
    ((failed++))
fi

if bash -n scripts/install.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} scripts/install.sh Syntax OK"
    ((passed++))
else
    echo -e "${RED}✗${NC} scripts/install.sh hat Syntaxfehler"
    ((failed++))
fi

# ═══════════════════════════════════════════════════════════════
# TEST 3: SECRETS TEMPLATE VOLLSTÄNDIGKEIT
# ═══════════════════════════════════════════════════════════════

print_header "TEST 3: Secrets Template Vollständigkeit"

required_secrets=(
    "wifi_ssid"
    "wifi_password"
    "ota_password"
    "web_username"
    "web_password"
    "ha_url"
    "ha_token"
)

for secret in "${required_secrets[@]}"; do
    test_content "Home-Assistant/secrets.yaml.example" "$secret" "Secret: $secret"
done

# ═══════════════════════════════════════════════════════════════
# TEST 4: CONFIG.YAML INHALTE
# ═══════════════════════════════════════════════════════════════

print_header "TEST 4: dixy.config.yaml Inhalte"

test_content "dixy.config.yaml" "project_name" "project_name definiert"
test_content "dixy.config.yaml" "vpd_" "VPD Parameter definiert"
test_content "dixy.config.yaml" "dosing:" "Dosing Sektion vorhanden"
test_content "dixy.config.yaml" "climate:" "Climate Sektion vorhanden"

# ═══════════════════════════════════════════════════════════════
# TEST 5: .GITIGNORE PRÜFUNG
# ═══════════════════════════════════════════════════════════════

print_header "TEST 5: .gitignore Sicherheit"

if grep -q "^secrets.yaml$" .gitignore; then
    echo -e "${GREEN}✓${NC} secrets.yaml ist in .gitignore"
    ((passed++))
else
    echo -e "${RED}✗${NC} secrets.yaml ist NICHT korrekt in .gitignore!"
    ((failed++))
fi

# ═══════════════════════════════════════════════════════════════
# TEST 6: DOKUMENTATION
# ═══════════════════════════════════════════════════════════════

print_header "TEST 6: Dokumentation Vollständigkeit"

test_content "docs/SETUP_GUIDE.md" "Quick" "Quick Start Anleitung"
test_content "docs/SETUP_GUIDE.md" "Home Assistant Token" "HA Token Anleitung"
test_content "docs/SETUP_GUIDE.md" "esphome run" "ESPHome Flashen Anleitung"

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════

print_header "TEST SUMMARY"

echo "Bestanden: ${GREEN}$passed${NC}"
echo "Fehlgeschlagen: ${RED}$failed${NC}"
echo ""

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}✓ ALLE TESTS BESTANDEN!${NC}"
    echo ""
    echo "Setup-System ist bereit für Verwendung."
    exit 0
else
    echo -e "${RED}✗ $failed Test(s) FEHLGESCHLAGEN${NC}"
    exit 1
fi
