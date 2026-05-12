# Handoff: audit-creator

> **Pre-Activation:** `thinkLikeUser` (User-Persona-Layer) sollte zuerst aktiviert sein. Bei Sub-Agent-Spawn (Audit-Workers): "Aktiviere thinkLikeUser sofort" im Prompt mitgeben — sonst kennt der Worker die User-Persona nicht.

> Wer ruft diesen Skill auf? Was muss ich uebergeben?
> Wer konsumiert meinen Output?

## Chained Skills (welche Skills nutzen meinen Output)
- `audit-worker` — bekommt `<suffix>.audit.md` zur Ausfuehrung. Erwartet 5-Sektionen-Format (MISSION OBJECTIVE / PHASEN-EXEKUTION / ARCHITECT'S PRIDE / CRUCIBLE / DEPLOYMENT & HANDOFF).
- `cleanup-after-welle` — laeuft nach Welle-Abschluss, raeumt STATUS.md / Audit-Files / Memory auf. Erwartet abgeschlossene Worker-Runs + STATUS.md-Update.
- `welle-orchestration` (Runbook) — koordiniert Multi-Worker-Wellen. Erwartet eindeutige Welle-ID und Worker-Verteilung.

## Output-Schema

### Pro Audit-File
```
Pfad: <projekt-root>/<suffix>.audit.md

Struktur:
# MASTER AUDIT: <ID> — <Titel>
> Agent: Claude Code (im <ordner>/ Ordner oeffnen)
> Suffix: <name>.audit.md

## [MISSION OBJECTIVE]
<Was am Ende existieren/funktionieren muss>

## [PHASEN-EXEKUTION]
<Nummerierte Phasen mit Schritten, Code, Pfaden, Befehlen>

## [THE ARCHITECT'S PRIDE]
<Qualitaetsansprueche>

## [THE CRUCIBLE]
<Bash-Tests PASS/FAIL>

## [DEPLOYMENT & HANDOFF]
<Git Commit / STATUS.md ueberschreiben / Audit-Datei loeschen>
```

### Welle-Bericht (am Ende des Orchestrator-Loops)
```
Welle <ID> abgeschlossen
- Notizen verarbeitet: <N>
- Audits geschrieben: <N>
- Worker-Runs: <N> (PASS: <X>, FAIL: <Y>)
- Reviewer-Runs: <N>
- Live-Deploys: <N>
- Notion-Kommentare gesetzt: <N>
- Naechste Welle: <vorschlag>
```

## Pre-Conditions (was muss vorher erfuellt sein)
- Notion MCP Server verbunden (ProjectAlpha Integration, DB-ID YOUR_NOTION_DB_ID)
- Im Workspace-Root (`~/.your-workspace/`)
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` exportiert
- `_runbooks/arbeitsweise-notion.md` lesbar
- `_control/templates/audit-template.md` existiert
- Lese-Zugriff auf alle Projekt-VISION.md / STATUS.md

## Post-Conditions (was ist nach mir wahr)
- Pro Notion-Notiz mit Status "offen": entweder erledigt + Final-Callout in Notion ODER explizit als "geblockt" gekennzeichnet
- STATUS.md aller betroffenen Projekte ueberschrieben
- Alle `.audit.md` geloescht (delegiert an `cleanup-after-welle`)
- Git-Log enthaelt Welle-Commit(s) mit Format `welle: <id> — <kurz-outcome>`
- Live-Verifikation dokumentiert (BUILD_ID / Smoke / curl)
- Bei Stop-Punkten: User-Anleitung in `_schriftbuero/User-Anleitungen/ACT-*.md`

## Failure-Modes (was darf NICHT passieren)
- Notion-Kommentar VOR Live + Reviewer-PASS (Memory feedback_notion_workflow.md)
- Push gegen Server-Projekte (AgentOS/ProjectBeta/ProjectZeta nutzen SSH, kein Git)
- Cross-L6-Marken-Snatch (BrandFive-Code in BrandOne einbauen ohne Architekt-Audit)
- Mehr als 2 Korrektur-Runden pro Teammate ohne User-Eskalation
