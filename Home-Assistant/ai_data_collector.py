"""
ai_data_collector.py

Sammler für Grow-Daten (Home Assistant → CSV)

Usage:
  - Set environment variables `HA_URL` and `HA_TOKEN` or provide a `secrets.yaml` with `ha_url` and `ha_token` entries.
  - Run once: `python ai_data_collector.py --once`
  - Run polling: `python ai_data_collector.py --interval 60`

Der Collector fragt eine definierte Liste von Entities ab und hängt die Werte an
`data/sensor_timeseries.csv` an. Ziel: einfache historische Datensammlung für ML.
"""

import os
import time
import csv
import json
import argparse
from datetime import datetime, timezone

try:
    import requests
except Exception:
    raise RuntimeError("Please install 'requests' (pip install requests)")


DEFAULT_ENTITIES = [
    # Hydro/EC/pH
    "sensor.hydroknoten_ec_value",
    "sensor.hydroknoten_ph",
    "sensor.hydroknoten_temp",
    # Zeltsensor / Klima
    "sensor.zeltsensor_vpd",
    "sensor.zeltsensor_ppfd",
    "sensor.zeltsensor_air_temperature",
    "sensor.zeltsensor_air_humidity",
    # Klimaknoten (backup)
    "sensor.klimaknoten_vpd",
    # Water levels (binary sensors)
    "binary_sensor.tank_1_level",
    "binary_sensor.tank_2_level",
    "binary_sensor.tank_3_level",
    "binary_sensor.tank_4_level",
    "binary_sensor.tank_5_level",
    "binary_sensor.tank_6_level",
]


def load_config_from_env_or_secrets():
    ha_url = os.environ.get("HA_URL")
    ha_token = os.environ.get("HA_TOKEN")
    if ha_url and ha_token:
        return ha_url.rstrip('/'), ha_token

    # fallback to secrets.yaml if present
    secrets_path = os.path.join(os.path.dirname(__file__), '..', 'secrets.yaml')
    try:
        import yaml
        with open(os.path.expanduser(secrets_path), 'r') as f:
            s = yaml.safe_load(f)
            ha_url = s.get('ha_url') or s.get('home_assistant_url')
            ha_token = s.get('ha_token') or s.get('homeassistant_long_lived_token')
            if ha_url and ha_token:
                return ha_url.rstrip('/'), ha_token
    except Exception:
        pass

    raise RuntimeError('Home Assistant URL and token not found. Set HA_URL and HA_TOKEN env vars.')


def fetch_entity_state(ha_url, token, entity_id):
    url = f"{ha_url}/api/states/{entity_id}"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    r = requests.get(url, headers=headers, timeout=10)
    if r.status_code == 200:
        return r.json()
    else:
        return None


def entity_to_value(entity_json):
    if entity_json is None:
        return None
    state = entity_json.get('state')
    # try convert to float
    try:
        return float(state)
    except Exception:
        # for binary sensors return 1/0 for on/off
        if isinstance(state, str) and state.lower() in ['on', 'true', '1']:
            return 1
        if isinstance(state, str) and state.lower() in ['off', 'false', '0']:
            return 0
        return state


def ensure_data_dir():
    data_dir = os.path.join(os.path.dirname(__file__), '..', 'data')
    os.makedirs(data_dir, exist_ok=True)
    return data_dir


def append_row(csv_path, fieldnames, row):
    file_exists = os.path.exists(csv_path)
    with open(csv_path, 'a', newline='') as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        if not file_exists:
            writer.writeheader()
        writer.writerow(row)


def collect_once(entities, out_csv):
    ha_url, token = load_config_from_env_or_secrets()
    timestamp = datetime.now(timezone.utc).isoformat()
    row = {'timestamp': timestamp}
    for ent in entities:
        data = fetch_entity_state(ha_url, token, ent)
        row[ent] = entity_to_value(data)
    # also add attributes snapshot as json (optional)
    # write
    fieldnames = ['timestamp'] + entities
    append_row(out_csv, fieldnames, row)
    return row


def run_loop(interval, entities):
    data_dir = ensure_data_dir()
    out_csv = os.path.join(data_dir, 'sensor_timeseries.csv')
    while True:
        try:
            row = collect_once(entities, out_csv)
            print(f"[{datetime.now().isoformat()}] Collected: ", row)
        except Exception as e:
            print("Collect error:", e)
        time.sleep(interval)


def main():
    parser = argparse.ArgumentParser(description='DiXY AI Data Collector')
    parser.add_argument('--interval', type=int, default=300, help='Polling interval in seconds')
    parser.add_argument('--once', action='store_true', help='Run once and exit')
    parser.add_argument('--entities', nargs='*', help='Override default entities')
    args = parser.parse_args()

    entities = args.entities if args.entities and len(args.entities) > 0 else DEFAULT_ENTITIES
    data_dir = ensure_data_dir()
    out_csv = os.path.join(data_dir, 'sensor_timeseries.csv')

    if args.once:
        r = collect_once(entities, out_csv)
        print('Done:', r)
        return

    run_loop(args.interval, entities)


if __name__ == '__main__':
    main()
