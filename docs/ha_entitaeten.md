# Home‑Assistant Entitäten – DiXY (ESPHome)

Diese Datei dokumentiert die Home‑Assistant‑Entitäten, die aus den ESPHome‑YAMLs im Repository entstehen.  
Sie ist rein beschreibend (keine Konfigurationsanleitung).

---

## Zeltknoten (zeltsensor_v2.8)

### 🌡 Sensorik
- **sensor.Blatttemperatur Dummy**  
  → Platzhalter‑Wert für Blatt‑Temperatur.  
  Anzeige/Monitoring, keine Regelung.
- **sensor.EC Dummy**  
  → Platzhalter‑Wert für EC.  
  Anzeige/Monitoring.
- **sensor.Relative Luftfeuchte**  
  → Luftfeuchte im Zelt.  
  Anzeige/Monitoring; Basis für VPD‑Anzeige.
- **sensor.pH Dummy**  
  → Platzhalter‑Wert für pH.  
  Anzeige/Monitoring.
- **sensor.CO2 Dummy**  
  → Platzhalter‑Wert für CO₂.  
  Anzeige/Monitoring.
- **sensor.VPD Dummy**  
  → Platzhalter‑Wert für VPD.  
  Anzeige/Monitoring (aus Temp/RH abgeleitet).
- **sensor.Zeltlampe Helligkeit**  
  → Rückmeldung der Lampen‑Helligkeit.  
  Anzeige/Monitoring der Lichtlogik.
- **sensor.DS18B20 Dummy**  
  → Platzhalter‑Temperatur.  
  Anzeige/Monitoring.
- **sensor.ESP WiFi Signal**  
  → WLAN‑Signalstärke des ESP.  
  Diagnose.
- **sensor.ESP Uptime**  
  → Laufzeit des ESP.  
  Diagnose.
- **sensor.PPFD (µmol/m²s)**  
  → Photonenfluss‑Dichte (Lichtsensorik).  
  Anzeige/Monitoring.
- **sensor.LUX (AS7341)**  
  → Helligkeit aus AS7341.  
  Anzeige/Monitoring.
- **sensor.DLI (mol/m²d)**  
  → Tages‑Lichtintegral.  
  Anzeige/Monitoring.

### 🔆 Steuerung
- **light.Zeltlampe**  
  → Haupt‑Lichtentität.  
  Wird durch interne Lichtlogik gesteuert.
- **switch.AUTO**  
  → Aktiviert AUTO‑Modus.  
  Steuert die automatische Lichtlogik.
- **switch.MANUELL**  
  → Aktiviert MANUELL‑Modus.  
  Überschreibt AUTO.
- **switch.Zeltlampe SA/SU aktiv**  
  → Aktiviert/Deaktiviert Sonnenaufgang/Sonnenuntergang‑Rampen.  
  Wirkt nur im AUTO‑Modus.
- **number.Auto Max Helligkeit**  
  → Zielhelligkeit im AUTO‑Modus.  
  Wird in der Lichtlogik verwendet.
- **number.Manuelle Helligkeit**  
  → Zielhelligkeit im MANUELL‑Modus.  
  Wirkt nur bei MANUELL.
- **number.Sonnenaufgang Dauer**  
  → Rampendauer beim Einschalten (AUTO).  
  Wird nur bei aktiver SA/SU‑Funktion genutzt.
- **number.Sonnenuntergang Dauer**  
  → Rampendauer beim Ausschalten (AUTO).  
  Wird nur bei aktiver SA/SU‑Funktion genutzt.

### 🧠 Diagnose / Status
- **binary_sensor.ESP Status**  
  → Verbindungs‑/Online‑Status des ESP.  
  Diagnose.
- **text_sensor.Geraetename**  
  → Geräte‑Identifier.  
  Diagnose.
- **text_sensor.Zeltlampe Modus**  
  → Aktueller Modus (AUS/AUTO/MANUELL).  
  Statusanzeige.
- **text_sensor.Zeltlampe Aktuelle Phase**  
  → Aktuelle Phase (AUS, AUTO‑SA/PLATEAU/SU, MANUELL).  
  Statusanzeige.
- **text_sensor.SA/SU Status**  
  → SA/SU aktiviert/deaktiviert.  
  Diagnose.
- **text_sensor.AUTO Einschaltzeit**  
  → AUTO‑Einschaltzeit im Format HH:MM.  
  Anzeige (Zeitbasis).
- **text_sensor.AUTO Ausschaltzeit**  
  → AUTO‑Ausschaltzeit im Format HH:MM.  
  Anzeige (Zeitbasis).
- **text_sensor.SA Startzeit**  
  → SA‑Startzeit (HH:MM oder „Automatik deaktiviert“).  
  Anzeige.
- **text_sensor.SU Startzeit**  
  → SU‑Startzeit (HH:MM oder „Automatik deaktiviert“).  
  Anzeige.
- **text_sensor.Zeltsensor Version**  
  → Firmware/Projektversion.  
  Diagnose.
- **text_sensor.ESP IP Adresse**  
  → IP‑Adresse des ESP.  
  Diagnose.
- **text_sensor.ESP WiFi SSID**  
  → Verbundene SSID.  
  Diagnose.
- **text_sensor.ESP WiFi BSSID**  
  → Verbundene BSSID.  
  Diagnose.
- **text_sensor.ESP MAC Adresse**  
  → MAC‑Adresse des ESP.  
  Diagnose.

---

## Hydroknoten (hydroknoten_v2.2)

### 🌡 Sensorik
- **sensor.Hydroknoten EC Sensor**  
  → EC‑Messwert.  
  Referenzwert für die Dosierung.
- **sensor.Hydroknoten pH Sensor**  
  → pH‑Messwert.  
  Referenzwert für die Dosierung.
- **sensor.Hydroknoten Temperatur**  
  → Wassertemperatur.  
  Monitoring und Kontext für Messwerte.
- **sensor.Hydroknoten Zelttemperatur außen**  
  → Außentemperatur/Umgebung.  
  Anzeige/Monitoring.

### 🧪 Kalibrierung
- **binary_sensor.EC Kalibrierung – Lösung 1**  
  → Kalibrier‑Trigger für EC‑Sonde (Lösung 1).  
  Status/Trigger‑Signal in HA.
- **binary_sensor.EC Kalibrierung – Lösung 2**  
  → Kalibrier‑Trigger für EC‑Sonde (Lösung 2).  
  Status/Trigger‑Signal in HA.
- **binary_sensor.pH Kalibrierung – Lösung 1**  
  → Kalibrier‑Trigger für pH‑Sonde (Lösung 1).  
  Status/Trigger‑Signal in HA.
- **binary_sensor.pH Kalibrierung – Lösung 2**  
  → Kalibrier‑Trigger für pH‑Sonde (Lösung 2).  
  Status/Trigger‑Signal in HA.

### 🧠 Diagnose / Status
- **text_sensor.Hydroknoten Version**  
  → Firmware/Projektversion.  
  Diagnose.
- **text_sensor.ESP IP Adresse**  
  → IP‑Adresse des ESP.  
  Diagnose.
- **text_sensor.ESP WiFi SSID**  
  → Verbundene SSID.  
  Diagnose.
- **text_sensor.ESP WiFi BSSID**  
  → Verbundene BSSID.  
  Diagnose.
- **text_sensor.ESP MAC Adresse**  
  → MAC‑Adresse des ESP.  
  Diagnose.

**Zusammenhang / Abhängigkeit:**  
Die Dosierung nutzt **EC‑ und pH‑Sensoren** dieses Knotens als Referenz.  
Fällt der Hydroknoten aus oder liefert ungültige Werte, blockiert die Dosierung.

---

## Dosierungsknoten (dosierung_2.2)

### 🧪 Dosierung (Zielwerte & Wirksamkeit)
- **number.EC Zielwert**  
  → EC‑Sollwert für die Berechnung der Dosierung.  
  Grundlage der EC‑Regelung.
- **number.pH Zielwert**  
  → pH‑Sollwert für die pH‑Korrektur.  
  Grundlage der pH‑Regelung.
- **number.Pumpe A – EC pro ml/100L**  
  → Wirksamkeit von Pumpe A.  
  Wird für EC‑Berechnung genutzt.
- **number.Pumpe B – EC pro ml/100L**  
  → Wirksamkeit von Pumpe B.  
  Wird für EC‑Berechnung genutzt.
- **number.Pumpe C – EC pro ml/100L**  
  → Wirksamkeit von Pumpe C.  
  Wird für EC‑Berechnung genutzt.
- **number.Pumpe D – EC pro ml/100L**  
  → Wirksamkeit Pumpe D (pH Down, EC‑Anteil i. d. R. 0).  
  Anzeige/Parameter.
- **number.pH Down – Änderung pro ml/100L**  
  → Wirksamkeit der pH‑Down‑Pumpe.  
  Wird für pH‑Berechnung genutzt.

### 🧪 Dosierung (Flow‑Rate & Laufzeit)
- **number.Pumpe A – Flow Rate**  
  → Förderrate von Pumpe A (ml/s).  
  Bestimmt Laufzeit pro Dosierung.
- **number.Pumpe B – Flow Rate**  
  → Förderrate von Pumpe B (ml/s).  
  Bestimmt Laufzeit pro Dosierung.
- **number.Pumpe C – Flow Rate**  
  → Förderrate von Pumpe C (ml/s).  
  Bestimmt Laufzeit pro Dosierung.
- **number.Pumpe D – Flow Rate**  
  → Förderrate von Pumpe D (ml/s).  
  Bestimmt Laufzeit pro Dosierung.

### 🛑 Sicherheit / Limits
- **number.Pumpe A – Max ml/Tag**  
  → Tageslimit Pumpe A.  
  Blockiert bei Überschreitung.
- **number.Pumpe B – Max ml/Tag**  
  → Tageslimit Pumpe B.  
  Blockiert bei Überschreitung.
- **number.Pumpe C – Max ml/Tag**  
  → Tageslimit Pumpe C.  
  Blockiert bei Überschreitung.
- **number.Pumpe D – Max ml/Tag**  
  → Tageslimit Pumpe D (pH Down).  
  Blockiert bei Überschreitung.
- **number.Max Dosis pro Zyklus**  
  → Maximale Dosiermenge pro Zyklus.  
  Sicherheitslimit.
- **number.Min. Rührzeit zwischen Dosierungen**  
  → Sperrzeit zwischen Dosierungen.  
  Blockiert neue Dosierungen bis Ablauf.
- **number.Durchmischungs‑Dauer (System‑Zyklus)**  
  → Ziel‑Mixdauer für Durchmischung.  
  Anzeige/Monitoring.

### 🌀 Rühren
- **number.Rührmotor – Dauer (Sekunden)**  
  → Rührzeit nach Dosierung.  
  Bestimmt Dauer des Mischvorgangs.
- **number.Rührmotor – PWM Speed**  
  → Rührmotor‑Leistung.  
  Einfluss auf Durchmischung.

### 🎛 Steuerung (Pumpen)
- **number.Pumpe 1 – Drehzahl**  
  → PWM‑Drehzahl Pumpe 1.  
  Manuelle Vorgabe/Servicebetrieb.
- **number.Pumpe 2 – Drehzahl**  
  → PWM‑Drehzahl Pumpe 2.  
  Manuelle Vorgabe/Servicebetrieb.
- **number.Pumpe 3 – Drehzahl**  
  → PWM‑Drehzahl Pumpe 3.  
  Manuelle Vorgabe/Servicebetrieb.
- **number.Pumpe 4 – Drehzahl**  
  → PWM‑Drehzahl Pumpe 4 (pH Down).  
  Manuelle Vorgabe/Servicebetrieb.
- **switch.Pumpe 1 – Steuerung**  
  → Schaltet Pumpe 1.  
  Manuelle Kontrolle.
- **switch.Pumpe 2 – Steuerung**  
  → Schaltet Pumpe 2.  
  Manuelle Kontrolle.
- **switch.Pumpe 3 – Steuerung**  
  → Schaltet Pumpe 3.  
  Manuelle Kontrolle.
- **switch.Pumpe 4 – Steuerung**  
  → Schaltet Pumpe 4 (pH Down).  
  Manuelle Kontrolle.

### 📊 Statistik / Zähler
- **sensor.Pumpe A – ml heute**  
  → Tagesdosis Pumpe A.  
  Sicherheits‑ und Verlaufskontrolle.
- **sensor.Pumpe B – ml heute**  
  → Tagesdosis Pumpe B.  
  Sicherheits‑ und Verlaufskontrolle.
- **sensor.Pumpe C – ml heute**  
  → Tagesdosis Pumpe C.  
  Sicherheits‑ und Verlaufskontrolle.
- **sensor.Pumpe D – ml heute**  
  → Tagesdosis Pumpe D (pH Down).  
  Sicherheits‑ und Verlaufskontrolle.
- **sensor.Pumpe A – Total Lifetime ml**  
  → Gesamtdosis seit Inbetriebnahme.  
  Statistik.
- **sensor.Pumpe B – Total Lifetime ml**  
  → Gesamtdosis seit Inbetriebnahme.  
  Statistik.
- **sensor.Pumpe C – Total Lifetime ml**  
  → Gesamtdosis seit Inbetriebnahme.  
  Statistik.
- **sensor.Pumpe D – Total Lifetime ml**  
  → Gesamtdosis seit Inbetriebnahme.  
  Statistik.
- **sensor.Pumpe A – Dosier‑Zyklen**  
  → Anzahl Dosierzyklen Pumpe A.  
  Statistik.
- **sensor.Pumpe B – Dosier‑Zyklen**  
  → Anzahl Dosierzyklen Pumpe B.  
  Statistik.
- **sensor.Pumpe C – Dosier‑Zyklen**  
  → Anzahl Dosierzyklen Pumpe C.  
  Statistik.
- **sensor.Pumpe D – Dosier‑Zyklen**  
  → Anzahl Dosierzyklen Pumpe D.  
  Statistik.

### 🧠 Diagnose / Status
- **text_sensor.Dosierung IP**  
  → IP‑Adresse des ESP.  
  Diagnose.
- **text_sensor.Dosierung WLAN SSID**  
  → Verbundene SSID.  
  Diagnose.
- **text_sensor.Dosierung WLAN BSSID**  
  → Verbundene BSSID.  
  Diagnose.
- **text_sensor.Dosierung MAC**  
  → MAC‑Adresse des ESP.  
  Diagnose.
- **text_sensor.ESPHome Version**  
  → ESPHome‑Version.  
  Diagnose.
- **text_sensor.Projekt Version**  
  → Projektversion des Knotens.  
  Diagnose.
- **text_sensor.Dosierung Status Zusammenfassung**  
  → Kurzüberblick über Pumpen‑Drehzahlen.  
  Diagnose.
- **text_sensor.Dosierung Pumpen Status**  
  → AN/AUS‑Status der Pumpen.  
  Diagnose.
- **text_sensor.Dosierung Reset Grund**  
  → Letzter Reset‑Grund.  
  Diagnose.
- **text_sensor.Dosierung Aktive Dosierung**  
  → Zeigt laufende Dosierart (EC/pH/keine).  
  Statusanzeige.
- **text_sensor.Dosierung Status**  
  → EC‑Status (dosing/blocked/idle).  
  Steuerungs‑/Sicherheits‑Status.
- **text_sensor.Dosierung Blockgrund**  
  → Blockgrund der EC‑Dosierung.  
  Diagnose.
- **text_sensor.pH Dosierung Status**  
  → pH‑Status (dosing/blocked/idle).  
  Steuerungs‑/Sicherheits‑Status.
- **text_sensor.pH Dosierung Blockgrund**  
  → Blockgrund der pH‑Dosierung.  
  Diagnose.

### 🛑 Sicherheit (Binary‑Sensoren)
- **binary_sensor.Status verbunden**  
  → ESP online/offline.  
  Diagnose.
- **binary_sensor.Rührzeit abgelaufen**  
  → TRUE = Dosierung erlaubt.  
  Blockiert Dosierungen bei FALSE.
- **binary_sensor.Hydroknoten Online**  
  → Messwerte verfügbar.  
  Blockiert Dosierungen bei FALSE.
- **binary_sensor.Pumpe A – Safety Limit Warning**  
  → 90 % des Tageslimits erreicht.  
  Warnung.
- **binary_sensor.Pumpe B – Safety Limit Warning**  
  → 90 % des Tageslimits erreicht.  
  Warnung.
- **binary_sensor.Pumpe C – Safety Limit Warning**  
  → 90 % des Tageslimits erreicht.  
  Warnung.
- **binary_sensor.Pumpe D – Safety Limit Warning**  
  → 90 % des Tageslimits erreicht.  
  Warnung.
- **binary_sensor.Pumpe A – Tageslimit erreicht**  
  → Tageslimit erreicht.  
  Blockiert Dosierung.
- **binary_sensor.Pumpe B – Tageslimit erreicht**  
  → Tageslimit erreicht.  
  Blockiert Dosierung.
- **binary_sensor.Pumpe C – Tageslimit erreicht**  
  → Tageslimit erreicht.  
  Blockiert Dosierung.
- **binary_sensor.Pumpe D – Tageslimit erreicht**  
  → Tageslimit erreicht.  
  Blockiert Dosierung.
- **binary_sensor.Dosierung aktiv**  
  → Mindestens eine Pumpe aktiv.  
  Statusanzeige.

### 🔗 Abhängigkeiten (Zusammenhang)
- **EC Aktuell / pH Aktuell / System Volumen** werden von der Dosierlogik ausgewertet.  
- **Zielwerte (EC/pH)** steuern die Berechnung der Dosiermenge.  
- **Limits & Rührzeit** blockieren Dosierung bei Überschreitung oder Sperrzeit.

