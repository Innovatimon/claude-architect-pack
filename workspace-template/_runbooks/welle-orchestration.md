# Runbook: Welle-Orchestration (Wie wellenweise arbeiten)
> Klassifikation: L2

## Trigger
"Starte eine Welle", "Welle X starten", "Iteriere bis perfekt", "alle Tasks abarbeiten", "Agenten-Team auf Max Effort"

## Was eine Welle ist

Eine Welle ist ein klar abgegrenzter Arbeitsblock mit:
- 3-7 parallelen Worker-Agents (Max-Effort)
- Klar disjunkte File-/Modul-Bereiche pro Agent (kein Konflikt-Risiko)
- Pro Welle: gemeinsames Ziel (z.B. "Welle 4-A: Foundation + Admin")
- Reviewer-Phase danach (Independent-Sub oder Lead-self): Validiert alles

## Welle-Typen

| Typ | Zweck | Anzahl Agents |
|-----|-------|---------------|
| **Foundation-Welle** | Neue Module + grosse Features | 5-7 |
| **Cleanup-Welle** | Tech-Debt, Doku, Health | 4-5 |
| **Inbox-Welle** | Externe Aufgabenquelle abarbeiten | 3-4 |
| **Reviewer-Welle** | Independent Sub-Pruefung gegen Vision | 1 |
| **Polish-Welle** | UI/UX-Feinschliff | 2-3 |
| **Iteration-Welle** | Wenn Reviewer "noch nicht perfekt" sagt | 2-5 |

## Schritt-fuer-Schritt

### 1. Welle planen
- User-Auftrag verstehen
- TaskList lesen (was ist offen)
- Pro geplanter Agent: scharf abgegrenztes Aufgabengebiet definieren (welche Files, welche Migrations, welche API-Routes, welche Doku)
- Konflikt-Risiken pruefen:
  - Migration-Nummern: pro Agent eigene Nummer
  - Admin-Pages: pro Agent disjunkte URL
  - i18n-Files: parallel-edit-bar wenn nur eigene Keys
  - `package.json`: nur EIN Agent macht `npm install` pro Welle (sonst Lock-Konflikt)

### 2. Tasks anlegen
- Pro Agent ein Task via `TaskCreate`
- Subject "Welle X-Y: <Agent-Titel>" Format
- Description mit klarer Acceptance-Criteria
- TaskUpdate(in_progress, owner=<agent-name>) wenn gespawned

### 3. Agents spawnen
- `Agent`-Tool mit:
  - description: Kurz-Titel
  - subagent_type: general-purpose oder Explore (je nach Aufgabe)
  - model: opus (fuer Max Effort)
  - run_in_background: true
  - name: eindeutiger Identifier (z.B. "welle-4b-theme")
  - prompt: vollstaendig self-contained — Quellen, Aufgaben, Constraints, Erfolgskriterium

### 4. Pro Agent: Erfolgskriterium

Jeder Agent-Prompt MUSS enthalten:
- **Vorarbeit**: was lesen vor Coden
- **Aufgaben**: nummeriert
- **Build-Pflicht**: `npm run build` / `tsc` / etc. 0 Errors vor commit
- **Commit-Konvention**: `[AGENT-TITEL] kurz-summary`
- **Push** (oder SSH-Deploy je nach Projekt — definiert in `CLAUDE.user.md`)
- **Live-Verifikation**: curl auf eigene neue Routen
- **Bericht**: `<projekt>/_archive/<datum>-berichte/welle-X-Y-bericht.md`
- **Constraints**: keine Geheimnisse, ASCII-Doku, externe Quellen-Kommentare NUR nach Reviewer-PASS

### 5. Konflikt-Mitigation
- Vor Push: `git pull --rebase <remote> <branch>`
- Bei Merge-Konflikt: rebase, fix, weiter — kein force push
- Wenn 2 Agents am gleichen File: Reihenfolge nach Spawn-Zeit (erste pushed zuerst)

### 6. Reviewer-Phase (immer nach Foundation/Cleanup-Welle)

Independent Sub-Reviewer ODER Lead-self:
- Liest ALLE Berichte der vorherigen Welle
- Pruefung: User-Auftrag erfuellt? Vision-konform? Live verifizierbar?
- Live-Tests: curl, DB-Queries, BUILD_ID-Konsistenz
- Externe Inline-Kommentare (Notion / Linear / GitHub) posten (NUR nach PASS)
- `OPEN-ITEMS.md` + `MASTER-STATE.md` bereinigen
- Verdikt: PASS / FAIL pro Agent, neue P0/P1 fuer naechste Welle

### 7. Iteration-Loop (User-Wunsch "perfekt")

Wenn Reviewer "noch nicht perfekt":
- Iteration-Welle starten mit Fix-Liste
- Wieder Reviewer-Phase
- Loop bis Reviewer "PASS"

WICHTIG: Loop muss ein **Stop-Kriterium** haben:
- Maximal 3 Iterationen
- ODER: User sagt explizit "stop"
- ODER: Diminishing Returns (Aenderungen werden trivial)

### 8. Doku-Pflege

Nach jeder Welle:
- `MASTER-STATE.md` aktualisieren (Wellen-Historie, Naechste-Wellen-Plan)
- `OPEN-ITEMS.md` aktualisieren (Erledigtes streichen, Neues voranstellen)
- **`<projekt>/STATUS.md` ueberschreiben (Pflicht-Output, kein Append)** — Template: `_control/templates/status-template.md`. Ohne STATUS-Update gilt die Welle als NICHT abgeschlossen.
- Pro Welle ein Welle-Bericht in `_archive/<datum>-berichte/`
- Memory-Files: nach Bedarf aktualisieren

### 9. Cleanup nach Welle

Skill `cleanup-after-welle` ausloesen — siehe `~/.claude/skills/cleanup-after-welle/SKILL.md`.

## Welle-Naming-Schema

- Welle 1, 2, 3 — frueh-Phase grosse Brocken
- Welle 4-A, 4-B, 4-C, 4-D — komplexe Mehrphasen-Welle
- Welle 5 — Cleanup
- Welle 6 — Externe Inbox-Abarbeitung
- Welle 7 — Independent Reviewer

Notation `Welle X-Y`: X = Welle-Nummer, Y = Phase innerhalb der Welle.

## Worker-Naming-Konvention

- **W-A** = Welle 1 Phase A (P0)
- **W-B** = Welle 1 Phase B (P1)
- **W-C** = Welle 2 Phase A (Re-Audit)
- **W-D** = Welle 2 Phase B (P2)
- **W-E** = Welle 3 Phase A (Final)

Plus Domain-Suffix: `W-A1-seo`, `W-A2-i18n`. Macht Multi-Worker-Logs lesbar.

## Anti-Patterns (was NICHT tun)

- **NICHT** alle Agents an gleichem File arbeiten lassen
- **NICHT** Migrations mit kollidierenden Nummern
- **NICHT** externe Kommentare DURING Welle (nur NACH Live + Reviewer-PASS)
- **NICHT** mehr als ein Agent macht `npm install` pro Welle
- **NICHT** Reviewer ohne Live-Tests — der Reviewer muss curl-en
- **NICHT** `OPEN-ITEMS` direkt vom Worker-Agent updaten (Reviewer macht das)
- **NICHT** force-push, `--no-verify`, oder shortcuts

## Verifizieren

```bash
# Welle ist sauber abgeschlossen wenn:
# 1. Live-Service laeuft (curl 200 / Service active)
# 2. STATUS.md ueberschrieben (Datum = heute)
# 3. _archive/<datum>-berichte/welle-X-*.md existieren (pro Agent + Reviewer)
# 4. Reviewer-PASS dokumentiert
# 5. Audit-Files entfernt (Glob **/*.audit.md = 0)
```

## Learnings

- **Pro Welle 5-7 Agents** ist Sweet-Spot. Mehr → Konflikt-Risiko + Coordinations-Overhead. Weniger → Welle dauert zu lange.
- **Reviewer-Welle ist Pflicht** — ohne den brutal-ehrlichen Sub-Pruefer entstehen Doku-Drift + falsche "Erledigt"-Markierungen.
- **Stop-Kriterium muss klar sein** — "Iteriere bis perfekt" kann unendlich laufen, daher Max 3 Iterationen.
- **Migrations-Nummern frueh planen** (vor Spawn-Zeit) — sonst Race auf Nummer-Vergabe.
- **Worker-File-Absorption durch shared Stage-Index** — `git add -A` blind ist gefaehrlich wenn parallele Worker laufen. Loesung: explizit `git add <SPEZIFISCHE-FILES>` + atomare add+commit-Bloecke.
- **6 Worker parallel ist Sweet-Spot bestaetigt** — bei 7+ Worker: Stash-Race-Conditions auf gemeinsamen Files.
