# Handoff: cleanup-after-welle

> **Pre-Activation:** `thinkLikeUser` (User-Persona-Layer) sollte zuerst aktiviert sein. Cleanup-Default-Reflexe (STATUS.md ueberschreiben, Audit-Files weg, keine HANDOFF/SESSION/HOLDING-Files) stehen in `~/.claude/skills/thinkLikeUser/context/anti-patterns.md`.

> Wer ruft diesen Skill auf? Was muss ich uebergeben?
> Wer konsumiert meinen Output?

## Chained Skills
- **Vor mir:** `audit-worker` (haeufigster Trigger), `welle-orchestration`-Runbook, `website-perfektionieren`-Runbook, `grv-bugs-workflow`-Runbook, `audit-creator` am Welle-Ende, `project-setup` nach Bootstrap-Welle.
- **Nach mir:** Naechster Architekt / naechste Welle. Workspace muss sauber sein damit Init-Agent korrekt initialisiert.
- **Optionaler Folge-Skill:** Bei groesserer Konsolidierung Runbook `_runbooks/memory-pflege.md` oder `_runbooks/schriftbuero-konsolidieren.md`.

## Output-Schema

### Kurz-Bericht im Chat (Pflicht-Output, max 8 Zeilen)
```
Cleanup abgeschlossen — Welle <id> / Projekt <name>
- STATUS.md: ueberschrieben (<datum>)
- Audit-Files weg: <N>
- Tot-Files archiviert: <N> -> _archive/<datum>/
- Memory: <N> updated, <N> stale-markiert
- Schriftbuero: <N> Inbox-Files archiviert
- MASTER-STATE/OPEN-ITEMS: <synced | not present>
- Git: <commit-hash | clean>
- Naechster Schritt: <vorschlag>
```

### Filesystem-State nach Cleanup
```
<projekt-root>/
├── STATUS.md                       (ueberschrieben, Welle-Datum, alle Pflicht-Sektionen)
├── _archive/<YYYY-MM-DD>-<welle>/  (Tot-Files hier)
│   ├── HANDOFF*.md
│   ├── SESSION-*.md
│   ├── temp-*
│   └── draft-*
├── (keine *.audit.md mehr)
└── (keine HANDOFF*.md / SESSION-*.md / HOLDING_* / CURRENT-AUDIT.md im Root)

~/.claude/projects/<workspace>/memory/
├── MEMORY.md                       (Count = Filesystem-Count)
└── *.md                            (updated bei Drift, stale-markiert sonst)

<projekt>/_schriftbuero/             (falls vorhanden)
├── Inbox/                           (max 4 Wochen alt)
├── Antworten/                       (Status != "verstanden")
├── Briefings/                       (max letzte 3)
└── _archive/<YYYY-MM-DD>/           (aeltere Files hier)
```

## Pre-Conditions
- Eine Welle ist abgeschlossen (Worker-Run, Audit-Run, Hotfix-Run o.ae.)
- STATUS.md-Inhalt vom Worker bereitgestellt (oder ableitbar aus Audit-Outcome)
- Welle-ID bekannt
- `_control/templates/status-template.md` lesbar
- Bei Memory-Drift: betroffene Memory-Files identifiziert

## Post-Conditions
- `Glob <projekt>/**/*.audit.md` -> 0 Files
- STATUS.md Datum = heute (oder Welle-Datum)
- `_archive/<datum>-<welle>/` existiert mit verschobenen Tot-Files
- MEMORY.md Count = Filesystem-Count
- git status sauber (oder erwarteter Commit gepusht)
- Kurz-Bericht im Chat gepostet
- Naechster Architekt kann sofort initialisieren ohne Halluzinations-Risiko

## Failure-Modes
- Cross-Projekt-Cleanup ohne expliziten Auftrag (verstoesst L6-Isolation)
- L6-Isolations-Verletzung (BrandFive-Files aus BrandOne aufraeumen)
- Hard-Delete ohne git-Backup
- Notion-Kommentare als Teil von Cleanup setzen (verboten — siehe feedback_notion_workflow.md)
- HANDOFF.md / SESSION-* anlegen (verboten)
- Memory-Update als "optional" behandeln bei Drift
- User-Folge-Wuensche schlucken bei Erledigt-Markierung von User-Anleitungen
