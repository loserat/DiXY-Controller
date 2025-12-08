# Release Notes – Node-RED Vorschläge

## 2024-xx-xx
- Neu: `flows_lighting_sunfade.json` mit Sunrise/Sunset + Fade (1–30 Min), PPFD-Modus, Manuell/Auto.
- Neu: `flows_ack_error.json` für ACK/Error-Listener.
- Anpassung: Fade-Dauer in Helper-Template (`proposals/ha_helpers.yaml`) auf 1–30 Min, Default 300s, in Sunfade-Flow geclamped.
- Bestehende Basis-Flows (`flows_dosing.json`, `flows_lighting.json`) unverändert belassen.
