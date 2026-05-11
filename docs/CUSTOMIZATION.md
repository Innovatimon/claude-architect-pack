# Customization

> Wie du den Pack persoenlich anpasst, ohne dass Updates deine Aenderungen zerstoeren.

## Drei Anpassungs-Mechanismen

### 1. CLAUDE.user.md (Primary)

Liegt im Workspace-Root, neben `CLAUDE.md`. **Wird nie ueberschrieben.**

```
workspace/
  CLAUDE.md            ← Pack-Template
  CLAUDE.user.md       ← DEIN Stil
```

Hier kommt rein:
- Persoenliches Profil (Rolle, Stil, Sprache)
- Doktrin-Overrides ("immer vor git push fragen", etc.)
- Liste deiner Projekte
- Server / Infrastruktur (NUR Pfade, keine Credentials)
- External Sources Config (Notion/Linear/etc.)
- GitHub-Account fuer neue Repos
- Memory-Pfad
- Eigene Modi

**Best Practice:** Halte `CLAUDE.md` als Template-Stand und `CLAUDE.user.md` als deine Welt.

### 2. _user-overrides/ Verzeichnis

Wenn `CLAUDE.user.md` zu lang wird (sagen wir > 300 Zeilen), lager Sub-Themen aus:

```
_user-overrides/
  doktrin.md          # Eigene Doktrin-Erweiterungen
  server.md           # Server-Doku (Pfade, KEINE Credentials)
  projekt-spezifika.md
  beispiele.md
  meine-modi/         # Custom-Modi
    spaeher.md
    marketing.md
```

In `CLAUDE.user.md` referenzieren:

```markdown
## Server / Infrastruktur
Siehe `_user-overrides/server.md`.
```

Der Agent liest beide.

### 3. Eigene Skills + Runbooks

**Custom Skills:**
```
~/.claude/skills/<dein-name>/SKILL.md
```
Werden vom Updater **nie** angefasst, solange der Name nicht mit den 7 Pack-Skills kollidiert (autonomous-execution, audit-creator, audit-worker, cleanup-after-welle, project-setup, init-architect-pack, update-architect-pack).

**Custom Runbooks:**
```
<workspace>/_runbooks/custom-<name>.md
<workspace>/_runbooks/local-<name>.md
```
Mit `custom-` oder `local-` Praefix sind sie user_owned (siehe MANIFEST.yml).

In `_runbooks/INDEX.md` eintragen — der INDEX selbst ist template_managed, du editierst dort. **Aber:** Bei Update wird `INDEX.md` ueberschrieben — sichere deinen Eintrag in `CLAUDE.user.md` oder einer Custom-Datei.

**Saubere Loesung:** Custom-Runbooks in `_runbooks/custom-INDEX.md` indexieren. Der Pack-INDEX bleibt fuer Pack-Runbooks.

## Update-Verhalten — was passiert konkret

Beim `/update-architect-pack`:

| Datei / Pfad | Verhalten |
|---------------|-----------|
| `CLAUDE.md` | ueberschrieben |
| `CLAUDE.user.md` | unangetastet |
| `CLAUDE.user.md.example` | ueberschrieben (Template-Vorlage) |
| `_runbooks/INDEX.md` | ueberschrieben |
| `_runbooks/agent-initialisierung.md` | ueberschrieben |
| `_runbooks/welle-orchestration.md` | ueberschrieben |
| `_runbooks/custom-deploy.md` | unangetastet |
| `_runbooks/local-experiment.md` | unangetastet |
| `_control/CLAUDE.md` | ueberschrieben |
| `_control/templates/*` | ueberschrieben |
| `_control/credentials-map.md` | unangetastet |
| `_control/server-config.md` | unangetastet |
| `_control/projects/*` | unangetastet |
| `_user-overrides/**` | unangetastet |
| `Projekte/**` oder `projects/**` | unangetastet |
| `~/.claude/skills/<pack-skill>/SKILL.md` | ueberschrieben |
| `~/.claude/skills/<dein-eigener-skill>/SKILL.md` | unangetastet |

Vor jedem Ueberschreiben wird ein `.bak.YYYYMMDD-HHMMSS` File angelegt — Rollback ist immer moeglich.

## Patterns die funktionieren

### Pattern 1: Doktrin-Verschaerfung

`CLAUDE.user.md` Sektion "Doktrin-Overrides":

```markdown
## Doktrin-Overrides

- Vor JEDEM git push: kurz im Chat zeigen was committet wird
- Niemals destruktive Bash-Befehle (rm -rf, force-push) ohne Bestaetigung
- npm install <package> immer mit Bestaetigung
```

Der Agent liest das nach `CLAUDE.md` und behandelt es als Vorrang-Regel.

### Pattern 2: Eigene Projekt-Liste

`CLAUDE.user.md` Sektion "Meine Projekte":

```markdown
## Meine Projekte

| Projekt | Ordner | Was | Status |
|---------|--------|-----|--------|
| MyShop | Projekte/MyShop/ | E-Commerce | AKTIV |
| MyApp | Projekte/MyApp/ | Mobile App | AKTIV |
| MyTool | Projekte/MyTool/ | CLI Tool | PAUSIERT |
```

Beim Init liest der Agent das automatisch.

### Pattern 3: Custom-Modi

`_user-overrides/meine-modi/spaeher.md`:

```markdown
# Modus: Spaeher

Aktivieren bei "Spaeh-Modus", "scout", "nur schauen".

In diesem Modus:
- Nur Read-Tools (kein Edit, Write, Bash mit Side-Effects)
- Bericht-Format: 5 Bullets + 1 Empfehlung
- Maximum 30 Tool-Calls pro Run
```

In `CLAUDE.user.md` referenzieren:

```markdown
## Eigene Modi
- Spaeher-Modus: `_user-overrides/meine-modi/spaeher.md`
```

### Pattern 4: Branch-spezifische Configs

Wenn der Workspace ein git-Repo ist und du verschiedene Branches mit verschiedenen Konfigurationen brauchst:

- `main`-Branch: Pack-Updates + Standardsetup
- `experiment`-Branch: deine experimentellen Skills + Doktrin

`_user-overrides/` und `CLAUDE.user.md` koennen pro Branch unterschiedlich sein — der Update-Skript fasst sie nicht an.

## Anti-Patterns

### ❌ Aenderungen direkt in CLAUDE.md
Das geht beim naechsten Update verloren. Stattdessen: `CLAUDE.user.md`.

### ❌ Aenderungen in `_runbooks/agent-initialisierung.md`
Wird ueberschrieben. Stattdessen: eigenes Runbook unter `_runbooks/custom-mein-init.md` mit Trigger-Anpassung.

### ❌ Skill `audit-creator` selbst patchen
Wird ueberschrieben. Stattdessen: eigener Skill (z.B. `mein-audit-creator`) der den originalen erweitert oder ablost.

### ❌ Credentials in CLAUDE.user.md
NIE. CLAUDE.user.md ist oft Teil von git-Repos.

## Tipp: Pre-Commit-Hook gegen versehentliche Credentials

In `.git/hooks/pre-commit`:

```bash
#!/bin/bash
if git diff --cached | grep -E '(sk_live_|ghp_|pk_live_|Bearer [A-Za-z0-9]{30,})'; then
    echo "Possible secret detected. Refusing commit."
    exit 1
fi
```

Ausfuehrbar machen: `chmod +x .git/hooks/pre-commit`

## Fragen?

Issues / Discussions: [github.com/Innovatimon/claude-architect-pack/issues](https://github.com/Innovatimon/claude-architect-pack/issues)
