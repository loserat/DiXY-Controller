echo "Verfügbare ESPHome YAMLs:"

#!/bin/bash
# Interaktives Flash-Script für DiXY ESPHome-Knoten (Ordner- und YAML-Auswahl)
set -e

cd "$(dirname "$0")/.."

# Knoten-Ordner finden
KNOTEN_DIRS=$(find ESP32-Knoten -mindepth 1 -maxdepth 1 -type d | sort)
if [ -z "$KNOTEN_DIRS" ]; then
  echo "Keine ESP-Knoten-Ordner gefunden!"
  exit 1
fi

echo "Verfügbare ESP-Knoten:"
select KNOTEN in $KNOTEN_DIRS; do
  if [ -n "$KNOTEN" ]; then
    YAML_LIST=$(find "$KNOTEN" -type f -name "*.yaml" ! -name "secrets.yaml" ! -name "secrets.yaml.example" ! -path "*/.esphome/*" | sort)
    if [ -z "$YAML_LIST" ]; then
      echo "Keine YAML-Dateien in $KNOTEN gefunden!"
      exit 1
    fi
    echo "\nVerfügbare YAMLs in $KNOTEN:"
    select YAML in $YAML_LIST; do
      if [ -n "$YAML" ]; then
        echo "\nStarte Flash für: $YAML"
        esphome run "$YAML"
        break 2
      else
        echo "Ungültige Auswahl. Bitte erneut versuchen."
      fi
    done
  else
    echo "Ungültige Auswahl. Bitte erneut versuchen."
  fi
done
