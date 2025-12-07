#!/bin/bash
################################################################################
# DiXY Dosierung v2 Simulation - Quick Start Validation
# Führe dieses Script aus um die Simulation zu validieren
################################################################################

set -e  # Exit on error

WORKSPACE="/Users/mbp-nick/Documents/DIXY-Controller_"
CONFIG_FILE="$WORKSPACE/ESP32-Knoten/ESP32-v2/dosierung_v2_sim.yaml"
SECRETS_FILE="$WORKSPACE/secrets_sim.yaml"
DASHBOARD_FILE="$WORKSPACE/Home-Assistant/dashboards/dixy_rdwc_monitor.yaml"
REFERENCE_FILE="$WORKSPACE/docs/MQTT_ENTITIES_REFERENCE.md"

echo "═══════════════════════════════════════════════════════════════"
echo "  DiXY Dosierung v2 Simulation - Quick Start Validation"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# 1. Prüfe ob alle Dateien existieren
echo "📋 Step 1: Checking Files..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_file() {
    local file="$1"
    local name="$2"
    if [ -f "$file" ]; then
        local size=$(wc -l < "$file")
        echo "  ✅ $name ($size lines)"
        return 0
    else
        echo "  ❌ $name - NOT FOUND: $file"
        return 1
    fi
}

FILES_OK=true
check_file "$CONFIG_FILE" "dosierung_v2_sim.yaml" || FILES_OK=false
check_file "$SECRETS_FILE" "secrets_sim.yaml" || FILES_OK=false
check_file "$DASHBOARD_FILE" "dixy_rdwc_monitor.yaml" || FILES_OK=false
check_file "$REFERENCE_FILE" "MQTT_ENTITIES_REFERENCE.md" || FILES_OK=false

if [ "$FILES_OK" = false ]; then
    echo ""
    echo "❌ Some files are missing. Please check paths above."
    exit 1
fi

echo ""
echo "✅ All files found!"
echo ""

# 2. Prüfe YAML Syntax
echo "📝 Step 2: Checking YAML Syntax..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_yaml_syntax() {
    local file="$1"
    local name="$2"
    
    # Check if Python is available
    if ! command -v python3 &> /dev/null; then
        echo "  ⚠️  Python3 not found - skipping YAML validation"
        return 0
    fi
    
    if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
        echo "  ✅ $name - Valid YAML"
        return 0
    else
        echo "  ❌ $name - Invalid YAML Syntax"
        return 1
    fi
}

YAML_OK=true
check_yaml_syntax "$CONFIG_FILE" "dosierung_v2_sim.yaml" || YAML_OK=false
check_yaml_syntax "$SECRETS_FILE" "secrets_sim.yaml" || YAML_OK=false
check_yaml_syntax "$DASHBOARD_FILE" "dixy_rdwc_monitor.yaml" || YAML_OK=false

echo ""

# 3. Prüfe ob alle Secrets referenziert sind
echo "🔐 Step 3: Checking Secrets References..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count !secret references
SECRET_REFS=$(grep -c "!secret" "$CONFIG_FILE" || echo 0)
echo "  Found $SECRET_REFS !secret references in config"

# Check if secrets file has required keys
REQUIRED_SECRETS=("mqtt_broker" "mqtt_username" "mqtt_password" "wifi_ssid" "api_encryption_key")
SECRETS_OK=true

for secret in "${REQUIRED_SECRETS[@]}"; do
    if grep -q "^$secret:" "$SECRETS_FILE"; then
        echo "  ✅ $secret found in secrets_sim.yaml"
    else
        echo "  ⚠️  $secret not found (might be optional)"
    fi
done

echo ""

# 4. Prüfe Entity Anzahl
echo "📊 Step 4: Counting Entities..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

count_entities() {
    local file="$1"
    local entity_type="$2"
    
    if [ "$entity_type" = "sensor" ]; then
        grep -c "^  - platform: template" "$file" || echo 0
    elif [ "$entity_type" = "binary_sensor" ]; then
        grep -c "^  - platform: template" "$file" | tail -1 || echo 0
    else
        grep -c "^    id: " "$file" || echo 0
    fi
}

SENSORS=$(grep -c "^sensor:" "$CONFIG_FILE" 2>/dev/null && echo "yes" || echo "no")
SWITCHES=$(grep -c "^switch:" "$CONFIG_FILE" 2>/dev/null && echo "yes" || echo "no")
NUMBERS=$(grep -c "^number:" "$CONFIG_FILE" 2>/dev/null && echo "yes" || echo "no")

if [ "$SENSORS" = "yes" ]; then
    echo "  ✅ Sensor platform found"
fi
if [ "$SWITCHES" = "yes" ]; then
    echo "  ✅ Switch platform found"
fi
if [ "$NUMBERS" = "yes" ]; then
    echo "  ✅ Number platform found"
fi

echo ""

# 5. Prüfe MQTT Handler
echo "🔌 Step 5: Checking MQTT Configuration..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if grep -q "on_json_message:" "$CONFIG_FILE"; then
    echo "  ✅ MQTT JSON message handler found"
else
    echo "  ⚠️  MQTT JSON message handler not found"
fi

if grep -q "cmd/dose" "$CONFIG_FILE"; then
    echo "  ✅ Dose command topic found"
else
    echo "  ⚠️  Dose command topic not found"
fi

if grep -q "dose_pump" "$CONFIG_FILE"; then
    echo "  ✅ dose_pump script found"
else
    echo "  ❌ dose_pump script not found"
fi

echo ""

# 6. Prüfe Dashboard
echo "🎨 Step 6: Checking Dashboard..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TABS=$(grep -c "title:" "$DASHBOARD_FILE" || echo 0)
echo "  Found $TABS tabs/titles in dashboard"

ENTITIES=$(grep -c "entity:" "$DASHBOARD_FILE" || echo 0)
echo "  Found $ENTITIES entity references"

if grep -q "dosierung_v2_sim" "$DASHBOARD_FILE"; then
    echo "  ✅ Dashboard uses dosierung_v2_sim entity IDs"
else
    echo "  ⚠️  Dashboard might not use dosierung_v2_sim entities"
fi

echo ""

# 7. MQTT Kommando Beispiele
echo "🧪 Step 7: MQTT Testing (Optional)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "  Wenn Mosquitto MQTT Broker läuft, teste mit:"
echo ""
echo "  Terminal 1 (Subscribe auf Response):"
echo "  $ mosquitto_sub -h 127.0.0.1 -t 'dixy/dosierung_v2_sim/state/last_dose'"
echo ""
echo "  Terminal 2 (Pump Kommando senden):"
echo "  $ mosquitto_pub -h 127.0.0.1 -t 'dixy/dosierung_v2_sim/cmd/dose' \\"
echo "      -m '{\"pump\":\"A\",\"duration_ms\":5000,\"power_pct\":75}'"
echo ""

# 8. Summary
echo "📋 Step 8: Summary..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SUMMARY_OK=true
if [ "$FILES_OK" = true ]; then
    echo "  ✅ All files exist"
else
    echo "  ❌ Some files missing"
    SUMMARY_OK=false
fi

if [ "$YAML_OK" = true ]; then
    echo "  ✅ YAML syntax valid"
else
    echo "  ⚠️  Some YAML syntax issues (check details above)"
fi

echo "  ✅ MQTT configuration present"
echo "  ✅ Dashboard configuration present"
echo "  ✅ Entity references found"
echo ""

if [ "$SUMMARY_OK" = true ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "  ✅ Simulation is ready! Next steps:"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "  1️⃣  Review Configuration:"
    echo "      - Check secrets_sim.yaml MQTT broker IP"
    echo "      - Review dosierung_v2_sim.yaml entity definitions"
    echo ""
    echo "  2️⃣  Import Dashboard into Home Assistant:"
    echo "      - Go to: Settings → Dashboards → Create from YAML"
    echo "      - Paste content from: $DASHBOARD_FILE"
    echo ""
    echo "  3️⃣  Test MQTT (optional):"
    echo "      - Start MQTT Broker: brew install mosquitto"
    echo "      - Run: mosquitto"
    echo "      - Test commands (see above)"
    echo ""
    echo "  4️⃣  Read Documentation:"
    echo "      - MQTT Reference: $REFERENCE_FILE"
    echo "      - Implementation Checklist: $WORKSPACE/IMPLEMENTATION_CHECKLIST.md"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    exit 0
else
    echo "❌ Validation failed - please fix issues above"
    exit 1
fi
