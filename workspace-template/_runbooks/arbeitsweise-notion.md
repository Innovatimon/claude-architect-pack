# Runbook: Arbeitsweise externe Aufgaben-Quelle
> Klassifikation: L2

> **Trigger:** "Lies Notion und arbeite alles ab", "Inbox abarbeiten", "Linear-Tickets durcharbeiten", "Issues abarbeiten", "Orchestrator starten"

## Kontext

Dieses Runbook ist die Single-Source-of-Truth fuer den **Orchestrator-Modus** (Skill `audit-creator`). Es beschreibt wie der Agent eine externe Aufgaben-Quelle (Notion-DB, Linear, GitHub Issues, Markdown-Inbox) wellenweise abarbeitet.

Konfiguration der Aufgaben-Quelle: `CLAUDE.user.md` Sektion "External Sources".

## Schritt-fuer-Schritt (10 Schritte)

### 1. Aufgaben-Quelle queryen

Aus `CLAUDE.user.md`:
```yaml
audit_source:
  type: notion         # oder: github_issues, linear, trello, markdown_inbox
  database_id: YOUR_ID
  filter: status=open
```

**Notion (per MCP):**
```
mcp__<server>__API-post-search  oder API-query-data-source
```

**GitHub Issues:**
```bash
gh issue list --state open --repo <owner>/<repo>
```

**Linear (per MCP):**
```
mcp__linear__list-issues
```

**Markdown-Inbox:**
```
Glob _schriftbuero/Inbox/**/*.md
```

### 2. Pro Eintrag: Projekt-Zuordnung

- Tags oder Labels auswerten
- Falls keine Zuordnung: Heuristik (Keyword-Match im Titel)
- Falls Heuristik nicht eindeutig: User-Frage formulieren statt zu raten

### 3. Projekt-Kontext laden

Pro identifiziertes Projekt:
```
Read Projekte/<name>/STATUS.md
Read Projekte/<name>/VISION.md
Read Projekte/<name>/CLAUDE.md
```

### 4. Audits schreiben (5-Sektionen-Format)

Pro Aufgabe ein File:
```
Projekte/<name>/<id>.audit.md
```

Format siehe `_control/templates/audit-template.md`:
- MISSION OBJECTIVE
- PHASEN-EXEKUTION
- THE ARCHITECT'S PRIDE
- THE CRUCIBLE
- DEPLOYMENT & HANDOFF

**Wichtig:** 1 Thema = 1 Audit. Grosse Notizen aufsplitten.

### 5. Worker-Agents spawnen

Siehe `welle-orchestration.md`:
- pro Audit ein Worker
- run_in_background: true
- model: opus (Max Effort)
- Disjunkte File-Bereiche pro Worker

### 6. Worker-Output reviewen

Pro Worker-Bericht:
- CRUCIBLE-Tests erneut laufen (Live-curl, Build-Check)
- Architect's-Pride pruefen (Qualitaets-Ansprueche)
- Bei FAIL: bis zu 2 Korrektur-Runden, dann melden

### 7. Lead-Hotfix-Phase (falls noetig)

Cross-Worker-Konsolidierung:
- Schema-Diskrepanzen
- Cross-Worker-Konflikt-Aufloesung
- Audit-Falsch-Positives klaeren

### 8. Externe Aufgaben-Quelle aufraeumen

**ERST nach Live + Reviewer-PASS:**

**Notion:**
- Status-Property auf "Erledigt"
- Inline-Callout am Page-Ende mit Outcome
- Format:
  ```
  ✅ Erledigt YYYY-MM-DD
  Outcome: <kurz>
  Commit: <hash>
  Live: <url>
  Welle: <id>
  ```

**GitHub Issues:**
```bash
gh issue close <number> --comment "Erledigt in <commit>. Live: <url>"
```

**Linear:**
- Status auf "Done"
- Comment mit Commit + Live-URL

**Markdown-Inbox:**
- File ins `_archive/<datum>/` verschieben
- `Antworten/<id>.md` anlegen mit Outcome

### 9. Doku-Pflege

- `<projekt>/STATUS.md` ueberschreiben
- `MASTER-STATE.md` syncen
- `OPEN-ITEMS.md` syncen
- Memory updaten falls Drift-relevant

### 10. Abschluss-Bericht

```
Inbox-Welle abgeschlossen:
- Quelle: <typ>
- Aufgaben gelesen: <N>
- Audits geschrieben: <N>
- Worker erfolgreich: <N>/<N>
- Live-Verify: PASS / FAIL
- Externe Quelle aktualisiert: <N> Status, <N> Comments
- Naechste Schritte: <vorschlag>
```

## Doktrin

- **Status in externer Quelle ERST nach Live + Reviewer-PASS** — keine "im Anflug"-Stempel.
- **Max 2 Korrektur-Runden** pro Worker, dann eskalieren.
- **STATUS.md ueberschreiben** nach jedem Audit. Kein HANDOFF.md.

## Boundaries

- Du bist Architekt — du gestaltest, Worker arbeiten ab.
- L6-Isolation: Cross-Brand-Lernen via Architekt-Audit, nicht via Worker.
- Bei Stop-Punkten (Credentials, Bezahl-Aktion): User-Anleitung im Schriftbuero.

## Verifizieren

- [ ] Pro Audit ein Worker erfolgreich
- [ ] Externe Quelle aktualisiert (Status + Inline-Outcome)
- [ ] STATUS.md ueberschrieben
- [ ] Abschluss-Bericht im Chat
- [ ] Audit-Files (`*.audit.md`) geloescht (Cleanup-Skill triggert)

## Learnings

### Status-Update NUR nach Reviewer-PASS
Frueher: Status auf "Erledigt" sobald Worker fertig war. Folge: zwei mal kam es vor dass Reviewer FAIL meldete, Worker hatte aber bereits den Status gesetzt — Notion-Mitleser dachten alles fertig. Lesson: Status-Update gehoert HINTER die Reviewer-Phase.

### Worker-Output != Live-Stand
Worker meldet "Audit erfolgreich" — bevor du Status in der Quelle aktualisierst: curl die Live-URL, pruefe BUILD_ID, pruefe Service-Status. Discrepanzen sind haeufig.

### Audit-File loeschen am Ende
Wenn das Audit erfolgreich abgearbeitet ist und STATUS.md geschrieben, MUSS die `.audit.md` weg. Sonst verwirrt sie den naechsten Init-Agenten.
