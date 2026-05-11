# Runbook: Agent-Initialisierung (Session-Setup)
> Klassifikation: L2

> **Trigger:** "Initiiere dich", "Session starten", "neuer Agent", "lies dich ein", "wo stehen wir", "uebernimm die Architekten-Rolle"
>
> **Zielbild:** Nach dieser Routine ist der Agent in <5 Minuten voll handlungsfaehig:
> kennt aktuellen Live-Stand, hat die Run-Geschichte im Kopf, weiss welche Wellen laufen,
> welche User-Aktionen ausstehen und welches Runbook fuer welche Aufgabe greift.

---

## Pflicht-Reihenfolge (9 Schritte, parallel wo moeglich)

### Schritt 1 — Memory + CLAUDE.md (10 Sekunden)
Beides ist im System-Reminder bereits geladen, aber **bewusst nochmal durchgehen**:
- `MEMORY.md` (im System-Reminder) — Pointer auf alle Memory-Files
- `CLAUDE.md` Workspace-Root — Architekt-Modus, L1-L7-Klassifikation
- `CLAUDE.user.md` — User-Overrides, Projekt-Liste, External Sources

**Was du danach wissen musst:**
- Liste der Projekte aus `CLAUDE.user.md`
- **Klassifikations-Ebene des aktuellen Projekts**
- Memory-Eintraege als Pointer (nicht komplett re-lesen)

### Schritt 2 — INDEX der Runbooks (10 Sekunden)
```
Read _runbooks/INDEX.md
```
Im Kopf: welches Runbook gilt fuer welchen Trigger.

### Schritt 3 — Live-Status pruefen (parallele Bash) — Pflicht
Wenn dein aktives Projekt eine Live-URL / einen Server / einen Service hat:

```bash
# Beispiel-Template — anpassen an dein Projekt:
git log --oneline -5 origin/main && \
curl -sL -o /dev/null -w 'HTTP %{http_code} | %{time_total}s\n' https://YOUR_PROJECT_URL
```

**Was du danach wissen musst:**
- Aktuelle Live-Version (Commit / BUILD_ID)
- Service-Status (active running / failed)
- Eventuelle Crashes der letzten Stunde

### Schritt 4 — Workspace-Stand-Files lesen (parallel Read)
Pflicht-Reads:
- `MASTER-STATE.md` falls vorhanden (Workspace-Root, Schnell-Status aller Projekte)
- `OPEN-ITEMS.md` falls vorhanden (offene User-Aktionen + blockierte Wellen)
- `<aktives-projekt>/STATUS.md`

**Was du danach wissen musst:**
- Aktueller Status des Projekts
- Welche Worker offen sind (`TaskList` als Cross-Check)
- Welche User-Aktionen blockieren

### Schritt 5 — Tasks pruefen
```
TaskList
```

### Schritt 6 — Letzten Audit-Bericht ueberfliegen (optional bei nicht-trivialer Aufgabe)
```
Glob <projekt>/_archive/*-berichte/*-final-bericht.md
```
Letztes File lesen (Executive Summary + Score-Trajectory).

### Schritt 7 — Aktiv laufende Background-Worker (falls vorhanden)
Bei Notification-Reminders im Kontext: Liste was noch laeuft. Niemals neue Wellen spawnen wenn parallele Worker an gleichen Files arbeiten koennten — siehe `multi-worker-coordination.md`.

### Schritt 8 — User-Antwort (Standard-Format)
```
Initialisiert. Aktueller Stand:
- Live: <version-info> (Service <status>)
- Smoke: <N>/<N> Routes 200 (falls Web-Projekt)
- Aktive Phase: <X>
- Tasks: <N> in_progress, <N> pending, <N> completed
- Offene User-Actions: <N> (siehe <pfad-zu-actions>)
- Cleanup-Flags: <N> (siehe Schritt 9, ggf. leer)
- Naechster Schritt-Vorschlag: <konkrete Aktion oder Frage>
```

### Schritt 9 — Cleanup-Check (Pflicht, max 30 Sekunden)

Bevor du die Hauptaufgabe annimmst, kurz Stale-State pruefen:

**9.1 Audit-Files (Welle abgeschlossen?)**
```
Glob **/*.audit.md
```
- Aelter als 24h -> Welle nicht ordentlich abgeraeumt. Im Status-Bericht als `Cleanup-Flag` markieren.
- Bei eindeutiger Tot-Datei und offensichtlichem Cleanup -> Skill `cleanup-after-welle` triggern.

**9.2 STATUS.md-Frische**
- STATUS.md aelter als 7 Tage und Projekt-Status "AKTIV" -> Drift-Flag.

**9.3 Master-Drift**
- `MASTER-STATE.md` zeigt Projekt X als "live BUILD Y"?
- `Projekte/<X>/STATUS.md` zeigt aber BUILD Z?
- -> Drift markieren als `Master-Drift: <projekt>`.

**Output:** Cleanup-Flags-Zeile im Standard-Antwort-Format Schritt 8.

---

## Was du NICHT tun sollst beim Initiieren

- **Kein Code-Edit** vor erstem User-Befehl
- **Kein Worker spawnen** ohne expliziten User-Trigger
- **Nicht alles neu lesen** wenn es im Memory steht (Memory ist Cache!)
- **Keine "Vorschau"-Antwort** mit allen Findings — User will erst Status, dann Aufgabe geben
- **Nicht in fremde Projekt-Ordner abdriften** — nur Kontext des aktiven Projekts laden

---

## Verifizieren

- [ ] Live-Status gepruft (frischer Bash-Aufruf, falls Web/Service-Projekt)
- [ ] MASTER-STATE.md gelesen (falls vorhanden)
- [ ] OPEN-ITEMS.md gelesen (falls vorhanden)
- [ ] STATUS.md des aktiven Projekts gelesen
- [ ] TaskList ueberprueft
- [ ] User-Antwort enthaelt: Status + Tasks + Naechster-Schritt-Vorschlag
- [ ] Schritt 9 Cleanup-Check durchgefuehrt

---

## Learnings

### Memory ist Cache, nicht Wahrheit
Memory-Files koennen aelter als 24h sein. Die Live-Pruefung ist Pflicht — Memory ist Kontext, nicht Wahrheit. Bei Diskrepanz: Live-Stand zaehlt, Memory updaten.

### 9 Schritte sind das Minimum
Weniger fuehrt zu Annahmen-basierten Antworten. Mehr als 12 Schritte ist Overkill — der Agent sollte nach <5 Min handlungsfaehig sein.

### Initiierungs-Antwort ist Standard-Format
Nicht improvisieren. Immer 6-7 Zeilen: Status + Smoke + Phase + Tasks + Offene User-Actions + Cleanup-Flags + Naechster-Schritt-Vorschlag. Der User scannt das in 5 Sekunden und gibt dann den naechsten Befehl.

### SSH-Drift-Check bei verteilten Setups
Wenn dein Workspace mit einem Server arbeitet: Workspace-Doku alleine zeigt nicht alle Drifts. SSH-Audit bei Init kann aufdecken: tote Services, Secret-Leaks in Git-Configs, Container-Tag-Drift. Fuehre den als Schritt 9.4 hinzu wenn relevant.
