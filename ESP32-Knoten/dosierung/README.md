# Dosierung v2 – RDWC Auto‑Dosierung (ESP‑autark)

## Zweck
Der Dosierknoten berechnet EC‑Korrekturen (Dünger) und pH‑Korrektur (nur pH Down)
lokal auf dem ESP und steuert die Pumpen sequenziell. Home Assistant dient nur
als Anzeige und liefert die Messwerte (EC/pH) sowie das Systemvolumen.

## Datenquellen (Home Assistant)
- **EC Ist**: `sensor.hydroknoten_ec_sensor`
- **pH Ist**: `sensor.hydroknoten_ph_sensor`
- **Systemvolumen (L)**: `input_number.rdwc_liter`
- **pH Zielwert**: `input_number.ph_target`

## Pumpen‑Zuordnung
- **Pumpe 1–3:** Dünger (EC‑Verteilung)
- **Pumpe 4:** pH Down (Korrektur)

## Lokale Eingaben (ESP bereitgestellt)
- **EC Zielwert** (mS/cm)
- **Flow‑Rate je Pumpe** (ml/s)
- **EC‑Wirksamkeit je Pumpe** (EC pro ml/100L)
- **pH‑Wirksamkeit** (pH pro ml/100L)
- **Max Dosis pro Zyklus** (ml)
- **Max ml/Tag je Pumpe** (ml)
- **Rührzeit zwischen Dosierungen** (s)
- **Rührmotor‑Dauer** (s)
- **Rührmotor‑PWM** (min 30%)

## Funktionsprinzip
```
                 ┌──────────────────────────────┐
                 │ Home Assistant (Messwerte)   │
                 │ EC Ist / pH Ist / Volumen    │
                 └──────────────┬───────────────┘
                                │
                        ┌───────▼────────┐
                        │ ESP Dosierung  │
                        │ (Single Source)│
                        └───────┬────────┘
                                │
                 ┌──────────────▼──────────────┐
                 │ Sicherheits‑Checks           │
                 │ - Hydroknoten online?       │
                 │ - Rührzeit abgelaufen?      │
                 │ - Tageslimits ok?           │
                 └───────┬─────────┬───────────┘
                         │         │
                   BLOCKIERT     OK → weiter
                         │         │
                         ▼         ▼
              ┌──────────────────────────────┐
              │ EC‑Dosierung (Pumpe A..D)    │
              │ - EC‑Diff = Soll - Ist       │
              │ - ml = Diff / EC pro ml      │
              │ - Verteilung aktive Pumpen   │
              └──────────────┬───────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │ pH‑Korrektur (Pumpe B/C)     │
              │ - pH‑Diff = Soll - Ist       │
              │ - ml = Diff / pH pro ml      │
              └──────────────┬───────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │ Dosierung sequenziell        │
              │ → Pumpe an → Timer → aus     │
              └──────────────┬───────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │ Rührmotor + Sperrzeit        │
              │ → nächste Dosierung blockiert│
              └──────────────────────────────┘
```

## Berechnung (Kurzform)
1. `ec_diff = ec_target - ec_current`
2. `ec_per_ml_actual = ec_per_ml_100L * (100 / system_liters)`  
3. `ml_needed = ec_diff / ec_per_ml_actual`  
4. Auf aktive EC‑Pumpen verteilen  
5. Limits prüfen (Max/Zyklus, Max/Tag)  
6. Dosieren → Rühren → Sperrzeit

## pH‑Korrektur (nur pH Down)
- Wenn `ph_target < ph_current` → pH Down dosieren (Pumpe 4)
- Wenn `ph_target >= ph_current` → keine pH‑Dosierung

## Status & Debug (Home Assistant)
Diese Sensoren zeigen den internen Zustand:
- **Dosierung – Status**: `dosing` / `blocked: …` / `idle`
- **Dosierung – Blockgrund**: `hydroknoten offline` / `rührzeit abwarten` / `tageslimit pumpe …` / `ok`
- **Rührzeit abgelaufen** (binary)
- **Hydroknoten Online** (binary)
- **Zeit seit letzter Dosierung** (s)
- **Nächste Dosierung in** (s)
- **Durchmischung Fortschritt** (%)
- **Pumpe A–D – ml heute** + **Total Lifetime**

## Wichtige Regeln
- Dosierungen laufen **nie parallel**.
- Rührzeit blockiert weitere Dosierungen.
- Tageslimits werden strikt eingehalten.
- Hydroknoten offline → Dosierung blockiert.

## Hinweise
- Der ESP ist die **Single Source of Truth**.
- Home Assistant steuert **keine** Logik, sondern zeigt nur an.
