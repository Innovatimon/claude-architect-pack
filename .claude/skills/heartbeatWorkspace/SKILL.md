---
name: heartbeatWorkspace
description: Cron-Heartbeat-Skill der Workspace scannt + Drift erkennt + Auto-Fix-Vorschlaege macht. Aktivieren bei "Heartbeat Check", "Workspace-Drift pruefen", "Stale-Audit pruefen", oder via cron alle 6h.
---

# Skill: heartbeatWorkspace — Workspace-Drift-Erkennung

## Wann aktivieren
- Manuell: "Heartbeat Check", "Drift pruefen"
- Automatisch: via /schedule alle 6h
- Beim Session-Start (zusaetzlich zur 9-Schritte-Init)

## Was es macht (6 Scans)

### Scan 1: Stale Audit-Files
Glob `**/*.audit.md` im Workspace.
- Output: Liste mit Pfad + Alter
- Auto-Fix-Vorschlag: "Diese N Audits sind aelter als 3 Tage. Soll ich `cleanup-after-welle` aufrufen?"

### Scan 2: STATUS.md Frische
Glob `**/STATUS.md` (Top-Level Projekte).
- Wenn aelter als 14 Tage UND letzter git-Commit am Projekt war juenger: WARNING
- Auto-Fix: "STATUS.md fuer <Projekt> ist veraltet. Letzte Welle nicht dokumentiert?"

### Scan 3: MEMORY.md vs Filesystem-Drift
- Liste alle Memory-Files
- Vergleiche mit MEMORY.md-Index
- Output: Phantom-Eintraege (Index referenziert geloeschte Files), Waisen-Files (Files ohne Index-Eintrag)

### Scan 4: Phantom User-Anleitungen
Glob `_schriftbuero/User-Anleitungen/ACT-*.md`.
- Vergleiche mit INDEX.md falls vorhanden
- Output: Phantom-Refs

### Scan 5: Skill-Eval-Drift
Glob `~/.claude/skills/*/`.
- Pruefe ob jeder Skill: SKILL.md + eval.json + learnings.md + last-output.md hat
- Output: Skills denen Eval-Files fehlen

### Scan 6: Runbook-Mitlern-Drift
Glob `_runbooks/*.md` (+ `Projekte/**/_runbooks/*.md`), ohne `INDEX.md`.
- **Fehlende `## Run-Log` Sektion** — Runbook hat den Pflicht-Abschnitt nicht (Grep `(?m)^##\s+Run-Log`). Härter: auch `## Learnings` fehlt.
- **Stale Run-Log** — letzter (oberster) Datums-Eintrag im `## Run-Log` ist > 45 Tage alt, obwohl das Runbook einen aktiven Bereich betrifft (Projekt-Status AKTIV in CLAUDE.md, oder L2/L4-global). Heuristik, nicht hart — markieren, nicht loeschen.
- **Header-Drift** — `> Klassifikation:` oder `> Stand:` fehlt.
- **INDEX-Phantom** — Runbook nicht in `_runbooks/INDEX.md` referenziert (bzw. INDEX zeigt auf nicht-existentes Runbook).
- Output: Liste Runbook + welcher Mangel. Auto-Fix-Vorschlag: "Run-Log-Sektion nachruesten (Vorlage `_control/templates/runbook-template.md`)" bzw. "Runbook <X> wurde seit <datum> nicht genutzt-protokolliert — noch aktuell? `runbook-erstellen.md` Mitlern-Pflicht."

## Output-Format (Markdown-Bericht)
```
# Heartbeat-Bericht <YYYY-MM-DD HH:MM>

## Stale Audits (N gefunden)
- ...

## Veraltete STATUS.md (M gefunden)
- ...

## Memory-Drift (P Phantome, Q Waisen)
- ...

## Phantom User-Anleitungen (R gefunden)
- ...

## Skill-Eval-Drift (S Skills unvollstaendig)
- ...

## Runbook-Mitlern-Drift (T Runbooks: U ohne Run-Log, V stale, W Header/INDEX-Drift)
- ...

## Auto-Fix-Vorschlaege (Architekt entscheidet)
1. Cleanup-after-welle aufrufen
2. STATUS-Update fuer <Projekt> initiieren
3. Memory-Pflege Runbook ausfuehren
4. Runbook-Run-Log-Sektionen nachruesten / veraltete Runbooks ueberarbeiten
```

## Doktrin
- Niemals automatisch loeschen — nur reporten + Vorschlaege
- ASCII (interne Agent-Doku)
- Bericht IMMER an gleicher Stelle: `_schriftbuero/Heartbeat/<YYYY-MM-DD-HHMM>.md`

## Boundaries
- Read-only Scan, keine Edits
- Nicht laenger als 60s laufen (Cron-Friendly)

## Voraussetzungen
- Glob/Grep-Tools
- Working Directory = workspace root
- Optional: /schedule fuer Cron
