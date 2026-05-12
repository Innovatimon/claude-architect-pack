# Handoff: heartbeatWorkspace

> **Pre-Activation:** `thinkLikeUser` (User-Persona-Layer) sollte zuerst aktiviert sein. Drift-Erkennung basiert auf Anti-Patterns aus `~/.claude/skills/thinkLikeUser/context/anti-patterns.md` (z.B. Stale-Audits, Memory >40 ohne Konsolidierung).

## Chained Skills (Vorschlaege je nach Drift)
- `cleanup-after-welle` — bei Stale-Audits
- Runbook `memory-pflege.md` — bei Memory-Drift
- Runbook `schriftbuero-konsolidieren.md` — bei Phantom-User-Anleitungen

## Output-Schema
```yaml
report_path: string  # _schriftbuero/Heartbeat/<YYYY-MM-DD-HHMM>.md
findings:
  stale_audits: list[{path, age_days}]
  stale_status: list[{project, age_days, last_commit_age_days}]
  memory_drift:
    phantoms: list[string]   # Index-Eintraege ohne File
    orphans: list[string]    # Files ohne Index-Eintrag
  phantom_actions: list[string]
  skill_eval_drift: list[{skill, missing_files: list}]
suggestions: list[string]
```

## Pre-Conditions
- Workspace hat _schriftbuero/Heartbeat/ Ordner (sonst anlegen)
- Working Directory = workspace root

## Post-Conditions
- Bericht-Datei existiert
- Architekt kann Auto-Fix-Vorschlaege akzeptieren oder ignorieren
- Niemals destruktive Aktion ohne Architekt-Bestaetigung
