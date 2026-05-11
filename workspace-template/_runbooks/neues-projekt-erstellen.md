# Runbook: Neues Projekt erstellen
> Klassifikation: L2

> **Trigger:** "neues Projekt", "Projekt anlegen", "bootstrappen", "leg X als Projekt an"

## Schritt-fuer-Schritt (8 Schritte)

### 1. L-Klassifikation festlegen

Welche Ebene? (Details: `CLAUDE.md` Sektion "Klassifikations-Hierarchie")

| Trifft das Projekt zu? | Ebene | Pfad |
|------------------------|-------|------|
| System / Daemon / OS-Tool | L4 | `_system/<name>/` |
| Framework / Multi-Brand-Plattform | L5 | `Projekte/<group>/_framework/` |
| Eine Brand unter einem Framework | L6 | `Projekte/<group>/Sub/<brand>/` |
| Einzel-Projekt (App, Website, Service) | L7 | `Projekte/<name>/` |

**Im Zweifel:** L7 — spezifischer als globaler.

### 2. Verzeichnis anlegen

```bash
mkdir -p "Projekte/<name>"
cd "Projekte/<name>"
```

### 3. 5 Pflicht-Files erstellen

**`CLAUDE.md`** — Projekt-spezifische Architekt-Regeln
```markdown
# CLAUDE.md — <Projektname>
> Klassifikation: L<N>

## Was ist dieses Projekt?
[1-2 Saetze]

## Tech-Stack
[Liste der Frameworks, Versionen, wichtige Libraries]

## Lokale Regeln
[z.B. "Niemals mock-DB in Tests", "Mobile-First", "ASCII-only Doku"]

## Deploy
[Wie wird das Projekt deployed? Lokal / Server / Cloud?]
```

**`VISION.md`** — Wo wollen wir hin?
```markdown
# VISION — <Projektname>

## Ziel
[Was am Ende fertig sein soll]

## Nicht-Ziele
[Was wir explizit nicht machen]

## Phasen
1. [Initial]
2. [...]
```

**`STATUS.md`** — Wo stehen wir? (wird nach jeder Welle ueberschrieben)
```markdown
# Status — <Projektname>

## Stand: <DATUM>

## Was funktioniert
- [...]

## Was kaputt ist
- [...]

## Was zuletzt geaendert wurde
- [...]

## Naechster Schritt
- [...]
```

**`PROJECT.md`** — Meta-Info (Stakeholder, externe Refs)
```markdown
# Project — <Projektname>

- **Owner:** [Name]
- **Created:** <DATUM>
- **Repo:** [URL falls vorhanden]
- **Live-URL:** [falls vorhanden]
- **External Refs:** [Notion-DB, Linear-Project, Slack-Channel]
```

**`SETUP.md`** — Wie startet ein neuer Agent / Dev hier?
```markdown
# Setup — <Projektname>

## Voraussetzungen
- [...]

## Lokal starten
```bash
[copy-paste-ready]
```

## Tests
```bash
[wie laufen Tests]
```

## Deploy
```bash
[wie wird gedeployed]
```
```

### 4. Optional: Schriftbuero anlegen

Bei viel User-Input + Uploads: Skill `~/.claude/skills/project-setup/SKILL.md` oder Runbook `schriftbuero-erstellen.md` ausloesen.

### 5. Git initialisieren

```bash
git init
git add .
git commit -m "init: <Projektname> bootstrap"
```

Optional: GitHub-Repo. Account aus `CLAUDE.user.md` Sektion "GitHub":

```bash
gh repo create <ACCOUNT>/<name> --private --source=. --remote=origin --push
```

### 6. Workspace-Root-CLAUDE.user.md aktualisieren

In `CLAUDE.user.md` Sektion "Meine Projekte" das neue Projekt eintragen.

### 7. Memory-Eintrag

Falls das Projekt langfristig wichtig wird:
- Memory-File `project_<name>.md` erstellen
- Eintrag in `MEMORY.md`

### 8. Optional: Cloud Scheduled Task

Wenn das Projekt regelmaessig autonom bearbeitet werden soll:
```
/schedule
```
(Slash-Command in Claude Code)

## Verifizieren

- [ ] Verzeichnis existiert mit L-Klassifikation
- [ ] 5 Pflicht-Files vorhanden: `CLAUDE.md`, `VISION.md`, `STATUS.md`, `PROJECT.md`, `SETUP.md`
- [ ] `git log` zeigt Initial-Commit
- [ ] `CLAUDE.user.md` Eintrag in Projekt-Tabelle vorhanden
- [ ] (optional) GitHub-Repo angelegt + initial push

## Learnings

### 5-Files-Pflicht
Vorlaeufer-Setups hatten oft nur `README.md`. Lehre: Agents brauchen klare Trennung von Architekt-Regeln (CLAUDE.md) vs. Vision (VISION.md) vs. Live-Status (STATUS.md). Single-File wird zu lang und veraltet.

### STATUS.md ueberschreiben, nicht appenden
Wer STATUS.md anhaeuft, hat in 3 Wochen einen 500-Zeilen-Friedhof. Git-Log ist das Archiv. STATUS.md ist immer Live-Snapshot.

### L-Klassifikation frueh festlegen
Ein falsch klassifiziertes Projekt wandert spaeter mit Workspace-Move-Schmerzen. L4-L7 Entscheidung zu Beginn.
