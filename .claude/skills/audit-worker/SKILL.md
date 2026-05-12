---
name: audit-worker
description: Arbeitet ein [suffix].audit.md ab. Aktivieren wenn ein Audit im Projekt-Ordner liegt, oder bei "arbeite das Audit ab", "fuehre das Audit aus", "Audit starten", "executeAudit", "runAuditWorker".
---

# Audit-Worker Skill

## Wann diesen Skill nutzen
- Ein [suffix].audit.md liegt im aktuellen Ordner
- Der User sagt "arbeite das Audit ab" oder "Audit starten"
- AgentOS dispatcht einen Task

## Arbeitsablauf

1. **Audit finden:** [suffix].audit.md im aktuellen Ordner lesen
2. **Verstehen:** MISSION OBJECTIVE + PHASEN-EXEKUTION komplett lesen
3. **Abarbeiten:** Phasen sequentiell ausfuehren, bei grossen Aufgaben Agent Teams nutzen
4. **Qualitaet:** THE ARCHITECT'S PRIDE einhalten
5. **Testen:** THE CRUCIBLE ausfuehren — alle Tests muessen PASS sein
6. **Abschluss (Pflicht-Output am Ende JEDER Welle):**
   - **STATUS.md ueberschreiben** mit aktuellem Stand — kein Append, ueberschreiben! Template: `_control/templates/status-template.md`. Dies ist nicht optional.
   - **Genutzte Runbooks → Run-Log pflegen:** Hast du beim Abarbeiten ein Runbook (`_runbooks/*.md` oder `Projekte/<...>/_runbooks/*.md`) genutzt? -> EINE Zeile ins `## Run-Log` (neueste oben, max 8): `| Datum | Audit-ID/Welle | PASS|PARTIAL|FIX|META | Notiz |`. War ein Schritt falsch -> korrigieren + `## Learnings`-Eintrag. Mitlern-Pflicht, siehe `_runbooks/struktur-navigieren.md` Sektion 6 / `CLAUDE.md` "Navigations-Doktrin".
   - [suffix].audit.md LOESCHEN
   - Git Commit mit aussagekraeftiger Message
   - Falls Reviewer-Welle vorgesehen: erst nach Reviewer-PASS Notion-Kommentare schreiben (siehe `_runbooks/arbeitsweise-notion.md` Schritt 8)

## STATUS.md Format (nach jedem Audit ueberschreiben)

```markdown
# Status — [Projektname]

## Stand: [DATUM]
## Letztes Audit: [AUDIT-ID]

## Was funktioniert
[Liste]

## Was kaputt ist
[Liste]

## Was zuletzt geaendert wurde
[Dateien, Features]

## Naechster Schritt
[Was als naechstes passieren sollte]
```

## Regeln
- Zero-Bug-Policy: Build fehlerfrei vor Commit
- Keine Credentials in Docs (nur Dateipfade)
- **STATUS.md ueberschreiben am Ende der Welle ist Pflicht-Output** — ersetzt HANDOFF.md, SESSION-*, HOLDING_*
- Git Log ist das Archiv
- Bei Blocker: Dokumentiere in STATUS.md und breche ab
- Doktrin (Root-CLAUDE.md Top-Doktrin + `~/.claude/skills/autonomous-execution/SKILL.md`): vollautonom, max effort, erst Stop bei echten Stop-Punkten

## Features
- Auto Mode: --enable-auto-mode oder Shift+Tab
- Agent Teams: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
- Worktrees: isolation: worktree fuer parallele Arbeit
