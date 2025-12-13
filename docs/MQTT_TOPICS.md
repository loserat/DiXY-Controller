# MQTT Topics Übersicht – DiXY-Controller

Hier findest du eine Übersicht aller aktuell in den Node-RED-Flows und Proposals verwendeten MQTT-Topics (Stand: 13.12.2025).

| Topic                                         | Richtung | Beschreibung                        |
|----------------------------------------------|----------|-------------------------------------|
| dixy/sensors/zelt/light/zeit_pwm             | out      | Zeitbasierter PWM-Wert Zeltlampe    |
| dixy/sensors/zelt/light/manuell_pwm          | out      | Manueller PWM-Wert Zeltlampe        |
| dixy/sensors/zelt/light/startzeit            | out      | Startzeit für Lichtsteuerung        |
| dixy/sensors/zelt/light/endzeit              | out      | Endzeit für Lichtsteuerung          |
| dixy/sensors/zelt/light/sunrise_time         | out      | Sonnenaufgangszeit                  |
| dixy/sensors/zelt/light/sa_su_aktiv          | out      | Sonnenaufgang/-untergang aktiv      |
| dixy/sensors/zelt/light/zeitschaltuhr_aktiv  | out      | Zeitschaltuhr aktiv                 |
| dixy/sensors/zelt/light/manuell_aktiv        | out      | Manueller Modus aktiv               |
| dixy/sensors/zelt/rlf                        | out      | Relative Luftfeuchte Istwert        |
| dixy/sensors/zelt/co2                        | out      | CO2 Istwert                         |
| dixy/sensors/zelt/temp_ds18b20_1             | out      | Temperatur DS18B20                  |
| dixy/sensors/hydro/ec                        | out      | EC Istwert Hydroknoten              |
| dixy/sensors/hydro/ph                        | out      | pH Istwert Hydroknoten              |
| dixy/sensors/zelt/temp_air                   | out      | Lufttemperatur Zelt                 |
| dixy/sensors/hydro/temp_water_1              | out      | Wassertemperatur Hydroknoten        |
| dixy/ack/#                                   | in       | Acknowledge-Topic (Wildcard)        |
| dixy/error/#                                 | in       | Fehler-Topic (Wildcard)             |
| dixy/cmd/zelt/light                          | in       | Lichtsteuerungsbefehl Zelt          |
| dixy/targets/hydro/ec                        | in       | Zielwert EC Hydroknoten             |
| dixy/targets/hydro/ph                        | in       | Zielwert pH Hydroknoten             |
| dixy/targets/zelt/ppfd                       | in       | Zielwert PPFD Zelt                  |
| dixy/targets/zelt/light/on                   | in       | Licht an Zeit Zelt                  |
| dixy/targets/zelt/light/off                  | in       | Licht aus Zeit Zelt                 |
| dixy/targets/hydro/ec_tolerance              | in       | EC Toleranz Hydroknoten             |
| dixy/targets/hydro/ph_tolerance              | in       | pH Toleranz Hydroknoten             |
| dixy/targets/hydro/pump{1-4}/manual_ml       | in       | Manuelle Pumpensteuerung Hydro      |
| dixy/targets/hydro/pump{1-4}/rate_ml_per_sec | in       | Pumpenrate Hydro                    |
| dixy/targets/hydro/pump{1-4}/auto_ml         | in       | Automatische Pumpensteuerung Hydro  |
| dixy/targets/hydro/pump{1-4}/manual_trigger  | in       | Pumpen-Trigger Hydro                |
| dixy/targets/hydro/dosing_enable             | in       | Dosierung aktiv Hydro               |
| dixy/targets/zelt/light_manual               | in       | Licht manuell Zelt                  |
| dixy/sensors/hydro/ec                        | out      | EC Sensorwert Hydroknoten           |
| dixy/sensors/hydro/ph                        | out      | pH Sensorwert Hydroknoten           |
| dixy/sensors/hydro/temp_water                | out      | Wassertemperatur Hydroknoten        |
| dixy/sensors/zelt/temp_air                   | out      | Lufttemperatur Zelt                 |
| dixy/sensors/zelt/rlf                        | out      | Luftfeuchte Zelt                    |
| dixy/sensors/zelt/vpd                        | out      | VPD Wert Zelt                       |
| dixy/sensors/zelt/ppfd                       | out      | PPFD Wert Zelt                      |
| dixy/sensors/zelt/dli                        | out      | DLI Wert Zelt                       |
| dixy/sensors/hydro/tanks/any_empty           | out      | Tank leer (binary) Hydro             |
| dixy/sensors/hydro/tanks/{1-6}/level         | out      | Wasserstand Tank Hydro               |

**Hinweis:**
- Topics mit `{1-4}` oder `{1-6}` stehen für mehrere Kanäle/Pumpen/Tanks.
- Tippfehler wie `dixy/hydo/ph_ist` bitte prüfen und ggf. korrigieren.
- Diese Liste kann bei Bedarf erweitert werden.
