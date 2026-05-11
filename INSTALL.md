# Installation

## Voraussetzungen

- **Claude Code** installiert ([claude.com/claude-code](https://claude.com/claude-code))
- **git** verfuegbar
- **Windows:** PowerShell 5.1+ oder PowerShell 7
- **Linux / macOS:** bash 4+

## Schnelle Installation (1 Befehl)

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/Innovatimon/claude-architect-pack/main/scripts/install.ps1 | iex
```

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/Innovatimon/claude-architect-pack/main/scripts/install.sh | bash
```

Das Script fragt dich:
1. **Workspace-Pfad** (default: `~/my-workspace`)
2. **Workspace-Name** (default: `my-workspace`, wird in CLAUDE.md eingesetzt)
3. **Skills global oder lokal?** (default: global in `~/.claude/skills/`)

Anschliessend:
- Clont das Repo nach `~/claude-architect-pack` (versteckt nur die Tools, nicht dein Workspace)
- Kopiert `workspace-template/*` in deinen Workspace
- Kopiert `.claude/skills/*` in `~/.claude/skills/`
- Erstellt initial leeres `CLAUDE.user.md` als Override-Anker
- Initialisiert dein Workspace-Verzeichnis als git-Repo (optional)

## Was passiert konkret

```
Vorher:
  ~/.claude/skills/       (leer oder nur deine eigenen Skills)
  ~/my-workspace/         (leer)

Nachher:
  ~/.claude/skills/
    autonomous-execution/SKILL.md
    audit-creator/SKILL.md
    audit-worker/SKILL.md
    cleanup-after-welle/SKILL.md
    project-setup/SKILL.md
    init-architect-pack/SKILL.md
    update-architect-pack/SKILL.md

  ~/my-workspace/
    CLAUDE.md                  (Template, wird gepflegt)
    CLAUDE.user.md             (DEINS, leeres Template)
    _runbooks/
      INDEX.md
      agent-initialisierung.md
      ...
    _control/
      CLAUDE.md
      templates/
        status-template.md
    _user-overrides/
      README.md                (erklaert das Override-System)

  ~/claude-architect-pack/      (geklontes Repo, Tools-Quelle)
    .git/
    scripts/
    docs/
```

## Manuelle Installation

Falls du das Script nicht nutzen willst:

```bash
# 1. Repo klonen
git clone https://github.com/Innovatimon/claude-architect-pack.git ~/claude-architect-pack

# 2. Workspace-Template kopieren
mkdir -p ~/my-workspace
cp -r ~/claude-architect-pack/workspace-template/* ~/my-workspace/
cp -r ~/claude-architect-pack/workspace-template/.* ~/my-workspace/ 2>/dev/null

# 3. CLAUDE.user.md aus Example anlegen (falls nicht da)
[ -f ~/my-workspace/CLAUDE.user.md ] || cp ~/my-workspace/CLAUDE.user.md.example ~/my-workspace/CLAUDE.user.md

# 4. Skills nach ~/.claude installieren
mkdir -p ~/.claude/skills
cp -r ~/claude-architect-pack/.claude/skills/* ~/.claude/skills/
```

Unter Windows / PowerShell analog mit `Copy-Item -Recurse`.

## Erster Lauf

In Claude Code in deinem Workspace-Verzeichnis:

```
cd ~/my-workspace
claude
```

Dann:

```
Initiiere dich
```

Der Agent liest `_runbooks/agent-initialisierung.md` und faehrt das Standard-Init durch.

## Konfiguration anpassen

Editiere `CLAUDE.user.md` — diese Datei wird bei Updates **nie** ueberschrieben.
Mehr dazu: [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md)

## Update

```
/update-architect-pack
```

oder im Workspace:

```bash
~/claude-architect-pack/scripts/update.sh
```

```powershell
~/claude-architect-pack/scripts/update.ps1
```

## Deinstallation

```bash
# Skills entfernen
rm -rf ~/.claude/skills/{autonomous-execution,audit-creator,audit-worker,cleanup-after-welle,project-setup,init-architect-pack,update-architect-pack}

# Repo entfernen
rm -rf ~/claude-architect-pack

# Workspace bleibt — du musst manuell entscheiden was du behalten willst
```

## Troubleshooting

### "Skills werden nicht erkannt"
Pruefe ob die Skill-Files unter `~/.claude/skills/<name>/SKILL.md` liegen (nicht `~/.claude/skills/<name>.md`).
Starte Claude Code neu.

### "CLAUDE.md wird nicht gelesen"
Stelle sicher dass du Claude Code im Workspace-Root startest, wo `CLAUDE.md` liegt.

### "Update zerstoert meine Anpassungen"
Pruefe: Hast du in `CLAUDE.user.md` oder `_user-overrides/` editiert? Dort ueberlebt alles.
Direkt in `CLAUDE.md` oder Runbook-Files editierte Aenderungen werden ueberschrieben — das ist beabsichtigt.

### Skill triggert nicht
Pruefe Frontmatter: `name:` und `description:` muessen vorhanden sein.
Der Trigger ist die `description` — wenn dein Prompt keinen Trigger-Begriff enthaelt, wird der Skill nicht aktiv.
