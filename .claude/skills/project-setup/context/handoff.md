# Handoff: project-setup

> **Pre-Activation:** `thinkLikeUser` (User-Persona-Layer) sollte zuerst aktiviert sein. Konvention "5 Pflicht-Files" + L1-L7-Klassifikation stehen in `~/.claude/skills/thinkLikeUser/context/domain.md`. Fuer Interview-basiertes Bootstrap stattdessen `bootstrapNewProject` nutzen.

> Wer ruft diesen Skill auf? Was muss ich uebergeben?
> Wer konsumiert meinen Output?

## Chained Skills
- **Vor mir:** Direkter User-Trigger ODER `audit-creator` (wenn neues Projekt aus Notion-Notiz abgeleitet werden soll).
- **Nach mir:**
  - `audit-creator` / `audit-worker` koennen sofort erstes Audit fuer das neue Projekt schreiben/ausfuehren.
  - `cleanup-after-welle` raeumt Bootstrap-Welle auf.
  - `share-workspace` kann neues Projekt-CLAUDE.md anonymisiert publizieren (falls in Whitelist).
- **Orthogonale Alternative:** `bootstrapNewProject` (Interview-basiert) — nicht von mir gechained.

## Output-Schema

### Projekt-Verzeichnis-Struktur
```
<projekt-root>/
├── CLAUDE.md          # Persona / Doktrin / L-Klassifikation
├── VISION.md          # Wo wollen wir hin
├── STATUS.md          # Wo stehen wir (kanonisch ueberschreibbar)
├── PROJECT.md         # Was es ist (Stack, Architektur, Stakeholder)
├── SETUP.md           # Wie aufsetzen (Local Dev, Deps, Run-Befehle)
├── (optional) _schriftbuero/
│   ├── Templates/
│   ├── Inbox/
│   ├── Briefings/
│   ├── Fragenkataloge/
│   ├── Antworten/
│   └── Kontinuitaet/
└── (optional) .git + GitHub Remote
```

### Root-`CLAUDE.md` Tabelle-Eintrag
```
| <Projekt> | <Ordner> | <Was-es-ist> | <Status> |
```

### Memory-Eintrag
```
Pfad: ~/.claude/projects/<workspace>/memory/project_<name>.md
+ Pointer in MEMORY.md
```

## Pre-Conditions
- Projekt-Name + L-Klasse bekannt (oder ableitbar)
- `_runbooks/neues-projekt-erstellen.md` lesbar (Single-Source-of-Truth)
- `_control/templates/status-template.md` lesbar
- `_control/credentials-map.md` lesbar
- gh CLI authentifiziert (falls GitHub-Repo gewuenscht)
- Bei Server-Projekten: SSH-Zugang zu AgentOS-Server (`ssh YOUR_SERVER`)

## Post-Conditions
- 5 Pflicht-Files existieren mit minimal sinnvollem Inhalt
- Root-`CLAUDE.md` Tabelle erweitert
- Memory-Eintrag + MEMORY.md-Pointer
- Bei GitHub-Repo: erster Commit gepusht
- Bei Cloud-Task: Task-ID dokumentiert in CLAUDE.md / STATUS.md
- Naechster Architekt kann das Projekt sofort initialisieren

## Failure-Modes
- L5/L7-Verwechslung (Shop-Projekt unter falschem Pfad)
- Schriftbuero als Default angelegt obwohl nicht "viel User-Input"
- Credentials inline statt Pfad-Referenz
- Root-`CLAUDE.md` Tabelle nicht erweitert (Projekt unsichtbar fuer naechste Session)
- Memory-Eintrag vergessen (Drift bei naechster Session)
- 5 Pflicht-Files nur als Leer-Template angelegt ohne Inhalt
