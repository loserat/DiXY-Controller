"""
DiXY Plant Stress Detector v0.1-beta

Multisensor KI-Analyse für Pflanzenstress-Detektion mit:
- Wasserverbrauch-Anomalieerkennung
- Blattfarb-Analyse (HSV)
- VPD/EC/pH/Temp Multi-Sensor Analyse
- Wachstumsstadien-basierte Targeting
- Learning Mode mit Tipps
"""

import logging

import cv2
import numpy as np

# ===============================================================
# Wachstumsstadien-Definition mit Targets
# ===============================================================

STAGE_TARGETS = {
    "keimling": {
        "ec_ideal": 0.6,
        "ec_min": 0.4,
        "ec_max": 0.8,
        "vpd_ideal": 0.6,
        "ppfd": 300,
        "temp_ideal": 22,
        "ph_ideal": 5.8,
        "water_consumption": 0.5,  # L/day
    },
    "vegetativ_week_1_2": {
        "ec_ideal": 1.0,
        "ec_min": 0.8,
        "ec_max": 1.2,
        "vpd_ideal": 0.8,
        "ppfd": 500,
        "temp_ideal": 23,
        "ph_ideal": 5.8,
        "water_consumption": 1.0,
    },
    "vegetativ_week_3_4": {
        "ec_ideal": 1.4,
        "ec_min": 1.2,
        "ec_max": 1.6,
        "vpd_ideal": 1.0,
        "ppfd": 600,
        "temp_ideal": 23,
        "ph_ideal": 5.8,
        "water_consumption": 1.5,
    },
    "pre_bluete": {
        "ec_ideal": 1.6,
        "ec_min": 1.4,
        "ec_max": 1.8,
        "vpd_ideal": 1.05,
        "ppfd": 700,
        "temp_ideal": 22,
        "ph_ideal": 5.8,
        "water_consumption": 2.0,
    },
    "bluete_frueh": {
        "ec_ideal": 1.8,
        "ec_min": 1.6,
        "ec_max": 2.0,
        "vpd_ideal": 1.15,
        "ppfd": 800,
        "temp_ideal": 21,
        "ph_ideal": 5.8,
        "water_consumption": 2.5,
    },
    "bluete_spaet": {
        "ec_ideal": 1.6,
        "ec_min": 1.4,
        "ec_max": 1.8,
        "vpd_ideal": 1.2,
        "ppfd": 750,
        "temp_ideal": 20,
        "ph_ideal": 5.8,
        "water_consumption": 2.0,
    },
    "flush": {
        "ec_ideal": 0.3,
        "ec_min": 0.2,
        "ec_max": 0.5,
        "vpd_ideal": 1.0,
        "ppfd": 600,
        "temp_ideal": 20,
        "ph_ideal": 6.0,
        "water_consumption": 1.5,
    },
}

# ===============================================================
# Sensorwerte Globals
# ===============================================================

WATER_HISTORY = []  # Sliding window of last 48 hours
EC_HISTORY = []
VPD_HISTORY = []
TEMP_HISTORY = []
PH_HISTORY = []

TANK_LEVEL_SENSORS = [
    "binary_sensor.hydroknoten_tank1_wasserstand",
    "binary_sensor.hydroknoten_tank2_wasserstand",
    "binary_sensor.hydroknoten_tank3_wasserstand",
    "binary_sensor.hydroknoten_tank4_wasserstand",
    "binary_sensor.hydroknoten_tank5_wasserstand",
    "binary_sensor.hydroknoten_tank6_wasserstand",
]

_LOGGER = logging.getLogger(__name__)


# ===============================================================
# Hilfsfunktionen
# ===============================================================

def get_float_state(hass, entity_id, default=0.0):
    """Safely read a numeric state; returns default on missing/invalid."""
    state_obj = hass.states.get(entity_id)
    if not state_obj:
        return default
    try:
        return float(state_obj.state)
    except (TypeError, ValueError):
        return default


def get_binary_state(hass, entity_id):
    """Return 'on'/'off'/None for a binary sensor."""
    state_obj = hass.states.get(entity_id)
    return state_obj.state.lower() if state_obj and state_obj.state else None

def detect_growth_stage(hass):
    """
    Erkennt Wachstumsstadium automatisch oder nutzt manuellen Override.
    
    Auto-Erkennung basiert auf:
    - Lichtzyklus (18/6 = Vegetativ, 12/12 = Blüte)
    - Wasserverbrauch (Baseline pro Stage)
    - Manuelle Übersteuerung via input_select
    """
    growth_stage_select = hass.states.get("input_select.growth_stage")
    
    if not growth_stage_select:
        return "vegetativ_week_1_2"
    
    current = growth_stage_select.state
    
    # Manual Override
    if current != "Auto":
        return current.lower().replace(" ", "_")
    
    # Auto-Detection via Light Cycle
    light_cycle = hass.states.get("input_select.light_cycle")
    if light_cycle:
        if "18/6" in light_cycle.state or "20/4" in light_cycle.state:
            return "vegetativ_week_3_4"
        elif "12/12" in light_cycle.state:
            return "bluete_frueh"
    
    return "vegetativ_week_3_4"


def analyze_plant_stress(hass, growth_stage=None):
    """
    Haupt-Stress-Analyse mit Multi-Sensor Integration
    
    Prüft nacheinander:
    1. Wasserverbrauch (Anomalieerkennung)
    2. Blattfarben (HSV)
    3. VPD/EC/pH/Temp (vs Stage Targets)
    4. Wachstums-Geschwindigkeit (Pixel-Diff)
    """
    
    if not growth_stage:
        growth_stage = detect_growth_stage(hass)
    
    targets = STAGE_TARGETS.get(growth_stage, STAGE_TARGETS["vegetativ_week_3_4"])
    
    results = {
        "stage": growth_stage,
        "targets": targets,
        "stress_level": 0,
        "findings": [],
        "recommendations": [],
    }
    
    # STEP 0: Wasserverbrauch-Analyse
    water_stress = analyze_water_consumption(hass, targets)
    results["water_analysis"] = water_stress
    
    # STEP 1: EC/pH/Temp/VPD Analyse
    sensor_stress = analyze_sensors(hass, targets)
    results["sensor_analysis"] = sensor_stress
    
    # STEP 2: Blattfarbe-Analyse (falls Kamera-Bild vorhanden)
    leaf_color = analyze_leaf_color(hass)
    results["leaf_color"] = leaf_color
    
    # STEP 3: Wachstums-Geschwindigkeit (Canopy-Pixel-Diff)
    growth_rate = detect_canopy_growth(hass)
    results["growth_rate"] = growth_rate
    
    # Aggregiere Stress-Level
    results["stress_level"] = int(
        (water_stress.get("severity", 0) +
         sensor_stress.get("severity", 0) +
         leaf_color.get("stress_percent", 0)) / 3
    )
    
    return results


def analyze_water_consumption(hass, targets):
    """
    Analysiert Wasserverbrauch auf Anomalien.
    
    +50% Abweichung = Hitzestress, VPD zu niedrig
    -50% Abweichung = Wurzelprobleme, Rohre verstopft
    """
    
    # Priorisiere aggregierten Sensor (leer/ok)
    tank_empty_state = get_binary_state(hass, "binary_sensor.hydroknoten_tank_leer")
    if tank_empty_state == "on":
        return {
            "status": "LOW",
            "severity": 90,
            "message": "Tank leer erkannt",
            "action": "Sofort nachfüllen",
        }
    
    # Fallback: prüfe einzelne Tank-Level-Sensoren falls verfügbar
    available_level_sensors = [
        ent for ent in TANK_LEVEL_SENSORS if hass.states.get(ent) is not None
    ]
    if not tank_empty_state and not available_level_sensors:
        return {"status": "PENDING", "message": "Tank sensor not available"}
    
    if available_level_sensors:
        empty_sensors = [ent for ent in available_level_sensors if get_binary_state(hass, ent) == "on"]
        if empty_sensors:
            return {
                "status": "LOW",
                "severity": 60,
                "message": f"Tank-Level Sensor(en) kritisch: {', '.join(empty_sensors)}",
                "action": "Fuellstand pruefen und nachfuellen",
            }
    
    baseline = targets.get("water_consumption", 1.5)
    # Placeholder: echte Berechnung benötigt Verbrauch/day
    consumption_rate = baseline  # TODO: Berechne echte Rate aus History
    
    if consumption_rate > baseline * 1.5:
        return {
            "status": "HIGH",
            "severity": 70,
            "message": "Heat Stress detected: +50% water consumption",
            "action": "Decrease VPD, increase cooling",
        }
    elif consumption_rate < baseline * 0.5:
        return {
            "status": "LOW",
            "severity": 60,
            "message": "Root problem suspected: -50% water consumption",
            "action": "Check roots, clean filters",
        }
    else:
        return {
            "status": "NORMAL",
            "severity": 0,
            "message": "Water consumption within range",
        }


def analyze_sensors(hass, targets):
    """
    Prüft EC, pH, VPD, Temp gegen Stage-Targets
    """
    
    ec = get_float_state(hass, "sensor.hydroknoten_ec_wert")
    ph = get_float_state(hass, "sensor.hydroknoten_ph_wert")
    vpd = get_float_state(hass, "sensor.zeltsensor_vpd")
    temp = get_float_state(hass, "sensor.zeltsensor_lufttemperatur")
    
    findings = []
    severity = 0
    
    # EC Check
    if ec < targets["ec_min"]:
        findings.append(f"EC too low: {ec:.2f} (target {targets['ec_ideal']})")
        severity += 20
    elif ec > targets["ec_max"]:
        findings.append(f"EC too high: {ec:.2f} (target {targets['ec_ideal']})")
        severity += 30
    
    # pH Check
    if ph < 5.5 or ph > 6.5:
        findings.append(f"pH out of range: {ph:.2f} (target 5.8)")
        severity += 25
    
    # VPD Check
    if vpd < targets["vpd_ideal"] - 0.2:
        findings.append(f"VPD too low: {vpd:.2f} (target {targets['vpd_ideal']})")
        severity += 15
    elif vpd > targets["vpd_ideal"] + 0.2:
        findings.append(f"VPD too high: {vpd:.2f} (target {targets['vpd_ideal']})")
        severity += 20
    
    # Temp Check
    if temp < targets["temp_ideal"] - 3:
        findings.append(f"Temp too low: {temp:.1f}°C")
        severity += 15
    elif temp > targets["temp_ideal"] + 3:
        findings.append(f"Temp too high: {temp:.1f}°C")
        severity += 20
    
    return {
        "status": "OK" if severity < 50 else "WARNING",
        "severity": min(severity, 100),
        "findings": findings,
    }


def analyze_leaf_color(hass):
    """
    HSV-Farb-Analyse der Detail-Kamera.
    
    Green: 35-85 H
    Yellow: 20-30 H (Chlorose - N Mangel)
    Brown: 10-20 H (Nekrose - Ca/Mg Mangel oder Überfeuchte)
    """
    
    # TODO: Implementiere echte OpenCV Bildanalyse
    # Placeholder-Werte
    
    return {
        "green_health_percent": 85,
        "yellow_chlorosis_percent": 10,
        "brown_necrosis_percent": 5,
        "stress_percent": 15,
        "status": "HEALTHY",
    }


def detect_canopy_growth(hass):
    """
    Pixel-Differenz zwischen gestrigem und heutigem Timelapse-Bild.
    
    Misst Wachstums-Geschwindigkeit relativ zu erwarteter Rate pro Stage.
    """
    
    # TODO: Implementiere echte Bildvergleich mit OpenCV
    # Placeholder
    
    return {
        "growth_percentage_change": 2.5,
        "status": "NORMAL",
        "message": "Growth on track for vegetative stage",
    }


def get_water_consumption_rate(hass):
    """
    Berechnet L/day aus Tank-Level History (48h Sliding Window)
    
    Formula: (Level_today - Level_yesterday) * tank_volume / 24h
    """
    
    # TODO: Implementiere echte History-Berechnung
    # Placeholder
    
    return 1.8  # L/day


# ===============================================================
# Main Service Handler
# ===============================================================

def analyze_plant_stress_service(call):
    """
    Home Assistant Service: plant_stress_detector.analyze
    
    Beispiel Aufruf:
    service: plant_stress_detector.analyze
    data:
      growth_stage: "vegetativ_week_3_4"
    """
    
    hass = call.hass
    growth_stage = call.data.get("growth_stage")
    
    # Führe Analyse durch
    result = analyze_plant_stress(hass, growth_stage)
    
    # Speichere Ergebnis als Attribute
    hass.states.set("sensor.plant_stress_analysis", "complete", result)
    
    # Logging
    _LOGGER.info(f"Plant Stress Analysis: {result['stress_level']}% - {result}")


# ===============================================================
# Setup
# ===============================================================

async def async_setup(hass, config):
    """Setup Plant Stress Detector"""
    
    hass.services.async_register(
        "plant_stress_detector",
        "analyze",
        analyze_plant_stress_service,
    )
    
    return True
