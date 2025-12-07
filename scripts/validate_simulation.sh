#!/bin/bash
################################################################################
# DiXY ESPHome Simulation Validator
# Validiert dosierung_v2_sim.yaml ohne Hardware oder echte MQTT-Verbindung
################################################################################

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && cd ../../ && pwd)"
SIM_CONFIG="$REPO_ROOT/ESP32-Knoten/ESP32-v2/dosierung_v2_sim.yaml"
SIM_SECRETS="$REPO_ROOT/secrets_sim.yaml"

echo "═══════════════════════════════════════════════════════════════════"
echo "DiXY Dosierung v2 - Simulation Config Validator"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Config: $SIM_CONFIG"
echo "Secrets: $SIM_SECRETS"
echo ""

# Check if ESPHome is installed
if ! command -v esphome &> /dev/null; then
    echo "❌ ESPHome not found. Install with: pip install esphome"
    exit 1
fi

echo "✓ ESPHome found: $(esphome version)"
echo ""

# Validate Config with Simulation Secrets
echo "Validating dosierung_v2_sim.yaml with secrets_sim.yaml..."
echo "────────────────────────────────────────────────────────────────"

if esphome config "$SIM_CONFIG" --secrets "$SIM_SECRETS" > /dev/null 2>&1; then
    echo "✓ Config validation PASSED"
    echo ""
else
    echo "❌ Config validation FAILED"
    echo ""
    esphome config "$SIM_CONFIG" --secrets "$SIM_SECRETS"
    exit 1
fi

echo "═══════════════════════════════════════════════════════════════════"
echo "✓ Simulation validation successful!"
echo ""
echo "Next steps:"
echo "1. To test with dry-run (no flashing):"
echo "   esphome run ESP32-Knoten/ESP32-v2/dosierung_v2_sim.yaml --no-install --no-upload"
echo ""
echo "2. To test MQTT payload handling, publish to MQTT broker:"
echo "   mosquitto_pub -h <broker> -t 'dixy/dosierung_v2_sim/cmd/dose' -m '{\"pump\":\"A\",\"duration_ms\":5000,\"power_pct\":75}'"
echo ""
echo "3. Check web_server at http://<ip>:80 for entity list"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
