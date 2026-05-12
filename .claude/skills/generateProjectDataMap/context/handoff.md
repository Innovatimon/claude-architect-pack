# Handoff: generateProjectDataMap

> **Pre-Activation:** `thinkLikeUser` (User-Persona-Layer) sollte zuerst aktiviert sein. Pantry/Prep/Plate-Metapher + Self-contained-HTML-Konvention stehen in `~/.claude/skills/thinkLikeUser/context/domain.md`.

## Chained Skills
- Aufgerufen von `bootstrapNewProject` (Schritt 3)
- Kann standalone aufgerufen werden fuer bestehende Projekte

## Output-Schema
```yaml
project_name: string
output_path: string (absolute)  # _control/projects/<name>/data_map.html
items_extracted:
  pantry: list[string]
  prep: list[string]
  plate: list[string]
todos: list[string]  # bei Extraktions-Unsicherheit
```

## Pre-Conditions
- Projekt hat CLAUDE.md mit irgendeiner Beschreibung
- Template `_control/templates/data_map_template.html` existiert

## Post-Conditions
- HTML-File liegt am richtigen Ort
- File oeffnet im Browser (sichtbares Pantry/Prep/Plate-Layout)
- Bei Unsicherheit: TODO-Liste fuer User-Klaerung im Bericht
