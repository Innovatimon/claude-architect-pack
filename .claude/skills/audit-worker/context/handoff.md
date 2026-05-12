# Handoff: audit-worker

> **Pre-Activation:** `thinkLikeUser` (User-Persona-Layer) sollte zuerst aktiviert sein. Wenn ich als Sub-Agent gespawnt werde, muss der Parent "Aktiviere thinkLikeUser sofort" im Prompt mitgeben — sonst arbeite ich ohne User-Default-Heuristiken.

> Wer ruft diesen Skill auf? Was muss ich uebergeben?
> Wer konsumiert meinen Output?

## Chained Skills
- **Vor mir:** `audit-creator` (haeufigster Trigger) ODER direkter User-Trigger ODER AgentOS Task-Dispatch.
- **Nach mir:** `cleanup-after-welle` (Pflicht bei jeder Welle, raeumt STATUS, Audit-Files, Memory).
- **Optional vor `cleanup-after-welle`:** Reviewer-Welle die meinen Output validiert und Notion-Kommentare freigibt.

## Output-Schema

### STATUS.md (kanonisch, _control/templates/status-template.md)
```markdown
# Status — <Projektname>

## Stand: <YYYY-MM-DD>
## Letztes Audit: <AUDIT-ID>

## Was funktioniert
- <Liste>

## Was kaputt ist
- <Liste>

## Was zuletzt geaendert wurde
- <Dateien, Features>

## Naechster Schritt
- <Was als naechstes passieren sollte>
```

### Git-Commit-Message
```
<scope>: <kurz-outcome> (audit <ID>)

<optional body>

(bei mehreren commits in einer Welle: `welle: <id> — <kurz-outcome>` als Final-Commit)
```

### Chat-Bericht (Pflicht-Output am Welle-Ende)
```
Audit <ID> abgeschlossen
- Phasen: <N>/<N> PASS
- Crucible: <N>/<N> PASS
- Build: PASS / FAIL
- Live-Verifikation: <BUILD_ID / curl-Output>
- STATUS.md: ueberschrieben
- Audit-File: geloescht
- Commit: <hash>
- Naechster Schritt: <vorschlag>
```

## Pre-Conditions
- `<suffix>.audit.md` existiert im aktuellen Projekt-Ordner
- Audit folgt 5-Sektionen-Format (sonst Worker-Drift)
- Projekt-Repo cloned + Build-Tools installiert
- Bei Server-Projekten: SSH-Zugang funktioniert (`ssh YOUR_SERVER` / `ssh YOUR_SERVER`)
- Bei Notion-Welle: MCP Server verbunden

## Post-Conditions
- Alle CRUCIBLE-Tests PASS dokumentiert
- STATUS.md mit aktuellem Stand ueberschrieben
- `<suffix>.audit.md` geloescht
- Git-Commit existiert (lokal oder pushed je nach Projekt)
- Bei Server-Projekten: Live-Service erreichbar + BUILD_ID verifiziert
- Bei Blocker: STATUS.md "Was kaputt ist" + Chat-Eskalation

## Failure-Modes
- HANDOFF.md / SESSION-*.md / HOLDING_*.md erstellt (verboten)
- STATUS.md nur appendet statt ueberschrieben
- Audit-File nicht geloescht
- Build-Fehler ignoriert
- Mehr als 2 Korrektur-Runden ohne Eskalation
- `git push` gegen Server-Projekte (AgentOS/ProjectBeta/ProjectZeta)
