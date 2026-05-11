---
name: init-architect-pack
description: Installiert den Claude Architect Pack in einen bestehenden oder neuen Workspace. Aktivieren bei "init architect pack", "pack installieren", "architect-pack einrichten", "Claude-Setup-Pack initialisieren".
---

# Init-Architect-Pack — Installer-Skill

Dieser Skill installiert den [Claude Architect Pack](https://github.com/Innovatimon/claude-architect-pack)
in einen bestehenden oder neuen Workspace. Er bereitet `CLAUDE.md`, Runbooks,
Skills und das User-Override-System ein und respektiert vorhandene Dateien.

## Wann aktivieren

- "init architect pack"
- "pack installieren" / "architect-pack einrichten"
- "Claude-Setup-Pack initialisieren"
- Erste Session in einem leeren Verzeichnis das ein Architect-Pack-Workspace werden soll

## Voraussetzungen

- Claude Code laeuft
- git installiert
- Schreibrechte auf `~/.claude/skills/` und gewuenschtes Workspace-Verzeichnis

## Step-by-Step

### 1. Pre-Flight

Pruefe:
- Liegt `~/claude-architect-pack/` schon vor? (Repo lokal vorhanden?)
- Gibt es ein bestehendes Workspace-Verzeichnis (z.B. `~/my-workspace/CLAUDE.md`)?
- Sind die Architect-Pack-Skills schon installiert (`~/.claude/skills/audit-creator/SKILL.md`)?

Berichte den Stand kurz im Chat (3-4 Zeilen).

### 2. Repo klonen falls noetig

Falls `~/claude-architect-pack/` fehlt:
```bash
git clone https://github.com/Innovatimon/claude-architect-pack.git ~/claude-architect-pack
```

Falls bereits vorhanden, fetch:
```bash
cd ~/claude-architect-pack && git fetch origin && git pull origin main
```

### 3. User fragen (genau einmal)

Wenn das hier ein erster Install ist:
- Wie soll der Workspace-Pfad sein? Default: `~/my-workspace`
- Wie soll der Workspace heissen? Default: `my-workspace`
- Skills global (`~/.claude/skills/`) oder Workspace-lokal (`<workspace>/.claude/skills/`)?

Diese Antworten in `~/claude-architect-pack/.install-config.json` schreiben fuer spaetere Updates.

### 4. Workspace-Template kopieren

```bash
WS="<workspace-pfad>"
mkdir -p "$WS"
cp -r ~/claude-architect-pack/workspace-template/. "$WS/"
```

Bei jeder Datei:
- Existiert nicht: kopieren
- Existiert + ist in MANIFEST `template_managed`: ueberschreiben
- Existiert + ist in MANIFEST `user_owned`: NICHT anfassen
- Existiert ausserhalb Manifest: User fragen (Konflikt-Resolution)

### 5. CLAUDE.user.md anlegen falls nicht vorhanden

```bash
[ -f "$WS/CLAUDE.user.md" ] || cp "$WS/CLAUDE.user.md.example" "$WS/CLAUDE.user.md"
```

Im Chat darauf hinweisen: "CLAUDE.user.md angelegt — hier kommen deine persoenlichen Anpassungen rein, die bei Updates erhalten bleiben."

### 6. Skills installieren

```bash
TARGET="$HOME/.claude/skills"
mkdir -p "$TARGET"
cp -r ~/claude-architect-pack/.claude/skills/. "$TARGET/"
```

Pruefe ob alle 7 Skills nun unter `$TARGET/<skill-name>/SKILL.md` liegen.

### 7. Optional: Workspace als git-Repo initialisieren

Frage den User: "Soll der Workspace-Pfad ein git-Repo werden?"
- Ja: `cd "$WS" && git init && git add . && git commit -m "init: Architect Pack installation"`
- Nein: weiter

### 8. Verifikation

Pruefe:
- [ ] `$WS/CLAUDE.md` vorhanden
- [ ] `$WS/CLAUDE.user.md` vorhanden
- [ ] `$WS/_runbooks/INDEX.md` vorhanden
- [ ] `$WS/_control/templates/status-template.md` vorhanden
- [ ] 7 Skills unter `~/.claude/skills/`
- [ ] `~/claude-architect-pack/.install-config.json` vorhanden

### 9. Erfolgs-Bericht im Chat

```
Architect Pack installiert.
- Workspace: <pfad>
- Skills: 7/7 unter ~/.claude/skills/
- User-Overrides-Anker: CLAUDE.user.md
- Naechster Schritt: cd "<pfad>" && claude — dann "Initiiere dich"
- Updates spaeter: /update-architect-pack
```

## Idempotenz

Der Skill ist idempotent — wiederholtes Ausfuehren ist ungefaehrlich:
- Bereits installierte Files werden uebersprungen (bei manueller Bearbeitung)
- `CLAUDE.user.md` wird nie ueberschrieben
- User-Choices aus `.install-config.json` werden wieder verwendet

## Was NICHT passiert

- Keine Anpassung von `~/.claude/projects/.../memory/` (das ist Conversation-spezifisch)
- Kein Eingriff in bestehende, nicht-Pack-Skills unter `~/.claude/skills/`
- Kein Loeschen von Files (selbst Tot-Files vom letzten Install bleiben — manueller Cleanup)
- Keine globale Config-Aenderung

## Troubleshooting

### "Permission denied" auf ~/.claude/skills/
- Pruefe Owner: `ls -la ~/.claude/skills/`
- Reset wenn noetig: `chmod -R u+w ~/.claude/skills/`

### Skills triggern nicht nach Install
- Pfad muss `~/.claude/skills/<name>/SKILL.md` sein (nicht `<name>.md`)
- Claude Code neu starten
- Frontmatter pruefen: `name:` und `description:` muessen vorhanden sein

### CLAUDE.user.md.example nicht da
- Pruefe ob `git pull` im Pack-Repo erfolgreich war
- Re-Clone wenn noetig

## Verifizieren

```bash
ls "$WS/CLAUDE.md" "$WS/CLAUDE.user.md" "$WS/_runbooks/INDEX.md" "$WS/_control/templates/status-template.md"
ls "$HOME/.claude/skills/audit-creator/SKILL.md" "$HOME/.claude/skills/init-architect-pack/SKILL.md" "$HOME/.claude/skills/update-architect-pack/SKILL.md"
```

Alle Files vorhanden -> Install erfolgreich.
