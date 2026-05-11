# Runbook: Schriftbuero anlegen
> Klassifikation: L2

> **Trigger:** "Schriftbuero anlegen", "User-Kommunikations-Layer", "Inbox + Briefings", "wir brauchen einen Ort fuer Uploads und Fragen"

## Was ist ein Schriftbuero?

Ein Verzeichnis-Pattern fuer **strukturierte User-Agent-Kommunikation**.
Statt allem im Chat verstreut zu lassen, lebt es in 6 Ordnern:

```
_schriftbuero/
  Templates/            # Vorlagen fuer User-Anleitungen, Briefings
  Inbox/                # User-Uploads, Screenshots, Doku-Snippets
  Briefings/            # Agent → User: Statusberichte, Vorschlaege
  Fragenkataloge/       # Agent → User: Klarstellungsfragen-Listen
  Antworten/            # User → Agent: Antworten auf Briefings/Fragen
  Kontinuitaet/         # Session-Continuation: Initiator-Dokumente
  User-Anleitungen/     # ACT-* Files (siehe user-anleitungen-erstellen.md)
  MASTER-ACTIONS.md     # Index aller offenen ACT-Files
```

## Wann ein Schriftbuero anlegen?

- Projekt mit viel User-Input (Uploads, Screenshots, externe Doku)
- Projekt mit vielen Stop-Punkten (User-Aktionen, Credentials)
- Projekt das ueber mehrere Sessions laeuft (Kontinuitaet wichtig)
- Workspace-Root: ja, wenn man mehrere Projekte hat
- Pro-Projekt: ja wenn das spezifische Projekt komplex ist

**Kein Schriftbuero:** Single-File-Hacks, One-Shot-Skripte, triviale Projekte.

## Schritt-fuer-Schritt

### 1. Pfad festlegen

| Scope | Pfad |
|-------|------|
| Workspace-Global | `<workspace-root>/_schriftbuero/` |
| Pro Projekt | `<workspace-root>/Projekte/<name>/_schriftbuero/` |

### 2. Verzeichnis-Struktur anlegen

```bash
SB="<schriftbuero-pfad>"
mkdir -p "$SB/Templates" "$SB/Inbox" "$SB/Briefings" "$SB/Fragenkataloge" "$SB/Antworten" "$SB/Kontinuitaet" "$SB/User-Anleitungen"
```

### 3. README.md im Schriftbuero

```markdown
# Schriftbuero — <Scope>

> User-Agent-Kommunikations-Layer.

## Ordner

| Ordner | Wer fuellt | Was rein |
|--------|------------|----------|
| `Inbox/` | User | Uploads, Screenshots, externe Doku |
| `Briefings/` | Agent | Statusberichte, Vorschlaege (`BRIEF-YYYY-MM-DD-NNN.md`) |
| `Fragenkataloge/` | Agent | Klarstellungsfragen (`FRAGEN-YYYY-MM-DD-NNN.md`) |
| `Antworten/` | User | Antworten auf Briefings/Fragen (Inline-Format) |
| `Kontinuitaet/` | Agent | Initiator-Dokumente fuer Session-Uebergabe |
| `User-Anleitungen/` | Agent | ACT-Files (siehe Runbook `user-anleitungen-erstellen.md`) |
| `Templates/` | Agent | Pflege-Templates fuer alle obigen |
| `MASTER-ACTIONS.md` | Agent | Index aller offenen ACT-Files |
```

### 4. Templates anlegen

**`Templates/briefing-template.md`** — Agent → User
**`Templates/fragenkatalog-template.md`** — Agent → User
**`Templates/anleitung-template.md`** — Agent → User (ACT-Format)
**`Templates/kontinuitaet-template.md`** — Session-Uebergabe

Inhalte siehe Skill `~/.claude/skills/project-setup/SKILL.md` oder generiere generische Templates.

### 5. MASTER-ACTIONS.md (Initial)

```markdown
# Master-Actions — <Scope>

> Index aller offenen User-Aktionen (ACT-Files).

| ID | Topic | Prio | Status | Pfad |
|----|-------|------|--------|------|

> Aktuell keine offenen Aktionen.
```

### 6. .gitkeep fuer leere Ordner

```bash
touch "$SB/Inbox/.gitkeep" "$SB/Briefings/.gitkeep" "$SB/Fragenkataloge/.gitkeep" "$SB/Antworten/.gitkeep" "$SB/Kontinuitaet/.gitkeep" "$SB/User-Anleitungen/.gitkeep"
```

### 7. CLAUDE.md (Workspace oder Projekt) erweitern

In der relevanten `CLAUDE.md` einen Verweis auf das Schriftbuero ergaenzen:

```markdown
## Schriftbuero

User-Agent-Kommunikation lebt in `_schriftbuero/`.
- User-Uploads: `_schriftbuero/Inbox/`
- Pending Actions: `_schriftbuero/MASTER-ACTIONS.md`
- Briefings + Fragenkataloge: `_schriftbuero/Briefings/`, `Fragenkataloge/`
```

## Verifizieren

- [ ] 7 Unterordner + `MASTER-ACTIONS.md` existieren
- [ ] `README.md` im Schriftbuero
- [ ] 4 Templates vorhanden
- [ ] CLAUDE.md verweist auf Schriftbuero
- [ ] git status zeigt neue Files (`.gitkeep` etc.)

## Learnings

### 6-Ordner-Struktur ist Minimum
Weniger -> Files verstreuen sich. Mehr -> User verliert Uebersicht.

### Inline-Antworten gewinnen
Statt User soll im Chat antworten: User schreibt direkt in `Antworten/` oder am Ende der `User-Anleitungen/ACT-*.md`. Naechster Agent sieht alles strukturiert.

### Kontinuitaet ist wichtig fuer Sessions ueber Tage
Initiator-Dokument am Anfang jeder neuen Session beschreibt: wo stehen wir, was offen, naechste Schritte. Verhindert "ich muss mich erstmal einlesen"-Sessions.
