# `_control/` — Governance Global (L3)

> Template-File. Bei Updates ueberschrieben.

Diese Ebene ist die **Steuerungs-Quelle**. Hier liegen Pfade auf
Credentials (NICHT die Werte!), Server-Konfigurationen, Feature-Docs
und Templates.

## Was hier liegt (Empfehlung)

| Datei | Was | Wer pflegt |
|-------|-----|------------|
| `CLAUDE.md` | dieses Doc (Template) | Update-Skill |
| `credentials-map.md` | NUR Pfade auf Credentials-Stores (z.B. `~/.ssh/`, `1Password`, `.env-Path`) | User |
| `server-config.md` | Hosts, Domains, Caddy/Nginx-Config-Pfade, Docker-Compose-Pfade | User |
| `templates/status-template.md` | STATUS.md-Pflicht-Sektionen | Update-Skill |
| `templates/audit-template.md` | 5-Sektionen-Audit-Template | Update-Skill |
| `projects/<name>.md` | Pro-Projekt-State (Tabelle, Stand, naechster Schritt) | User / Agent |
| `features/*.md` | Claude-Code-Features die du nutzt (Agent-Teams, Worktrees, Auto-Mode, Cloud-Tasks) | User / Update-Skill |

## Update-Verhalten

- `CLAUDE.md` (dieses File): wird vom Updater ueberschrieben
- `templates/status-template.md`: ueberschrieben
- `templates/audit-template.md`: ueberschrieben (falls vorhanden)
- `credentials-map.md`: **nie** angefasst (user_owned)
- `server-config.md`: **nie** angefasst (user_owned)
- `projects/**`: **nie** angefasst (user_owned)

## Sicherheits-Regel

Diese Ebene darf **keine** Credentials enthalten. Nur Pfade.
Falls du Credentials hier siehst (z.B. weil ein vorheriger Agent gepatzt hat),
sofort entfernen + rotieren.

## Erweiterung

Wenn du eigene Steuerungs-Files brauchst (z.B. `costs.md`, `monitoring.md`):
lege sie hier ab, sie sind L3 und ueberleben Updates wenn sie nicht im
Update-Manifest stehen.
