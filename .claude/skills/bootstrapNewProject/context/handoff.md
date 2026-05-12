# Handoff: bootstrapNewProject

> **Pre-Activation:** `thinkLikeUser` (User-Persona-Layer) sollte zuerst aktiviert sein. Interview-Konvention + Klassifikation L5/L7 + Brand-Context-Standard stehen in `~/.claude/skills/thinkLikeUser/context/domain.md` und `entscheidungen.md`.

## Chained Skills
- `generateProjectDataMap` — wird in Schritt 3 aufgerufen fuer data_map.html
- `audit-creator` — kann nach Bootstrap erste Audits fuer neues Projekt schreiben

## Output-Schema
```yaml
project_name: string
project_path: string (absolute)
classification: L5|L7
files_created:
  - CLAUDE.md
  - VISION.md
  - STATUS.md
  - PROJECT.md
  - SETUP.md
  - context/voice.md
  - context/positioning.md
  - context/icp.md
  - context/samples.md
  - data_map.html
memory_entry: string (path to memory file)
todos: list[string]  # User-Klaerungs-Items
```

## Pre-Conditions
- User hat Projekt-Idee aber keinen Ordner
- Working Directory = workspace root

## Post-Conditions
- Projekt-Ordner existiert mit allen Pflicht-Files
- Root-CLAUDE.md hat neuen Eintrag
- Memory hat project_<name>.md
- TODO-Liste fuer User-Klaerung vorhanden
