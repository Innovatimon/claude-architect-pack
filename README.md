# Claude Architect Pack

> Eine produktionsreife Claude-Code-Konfiguration mit Audit-Wellen,
> Multi-Agent-Orchestrierung und L1-L7-Klassifikation —
> bereit zur Installation in unter einer Minute.

## Was ist das?

Ein Setup-Paket fuer [Claude Code](https://claude.com/claude-code) und kompatible
Clients (Anthropic CLI, Antigravity, etc.), das dir eine erprobte Architektur
fuer **autonomes Multi-Projekt-Arbeiten** mit hilft.

### Was du bekommst

- **5 Production-Skills** — `autonomous-execution`, `audit-creator`,
  `audit-worker`, `cleanup-after-welle`, `project-setup`
- **13+ Workflow-Runbooks** — Agent-Initialisierung, Wellen-Orchestrierung,
  Memory-Pflege, Schriftbuero-Setup, Multi-Worker-Coordination
- **L1-L7 Klassifikations-Hierarchie** — verhindert Halluzinationen bei
  Multi-Projekt-Workspaces durch klare Lese-/Schreib-Boundaries
- **User-Override-Layer** — deine persoenlichen Anpassungen
  (`CLAUDE.user.md`) ueberleben jedes Update
- **Installer + Updater** — Ein-Befehl-Setup, Ein-Befehl-Update

### Was du *nicht* bekommst

- Keine echten Projekt-Daten — alles anonymisiert mit Platzhaltern
- Keine Credentials, IPs, Domains, API-Keys
- Keine Spezifika der Original-Wokrkflows (Notion-IDs, Server-Pfade, etc.)

## Installation

**Windows (PowerShell):**

```powershell
iwr -useb https://raw.githubusercontent.com/Innovatimon/claude-architect-pack/main/scripts/install.ps1 | iex
```

**Linux / macOS (bash):**

```bash
curl -fsSL https://raw.githubusercontent.com/Innovatimon/claude-architect-pack/main/scripts/install.sh | bash
```

**Manuell (klonen):**

```bash
git clone https://github.com/Innovatimon/claude-architect-pack.git ~/claude-architect-pack
cd ~/claude-architect-pack
./scripts/install.sh    # oder install.ps1 unter Windows
```

Volle Anleitung: [INSTALL.md](INSTALL.md)

## Wie es funktioniert

Nach der Installation hast du folgende Struktur:

```
~/.claude/skills/                  <- 7 Skills installiert
  autonomous-execution/
  audit-creator/
  audit-worker/
  cleanup-after-welle/
  project-setup/
  init-architect-pack/             <- der Installer selbst
  update-architect-pack/           <- holt Updates

<dein-workspace>/                  <- Beispiel: ~/my-workspace
  CLAUDE.md                        <- Template (wird bei Updates aktualisiert)
  CLAUDE.user.md                   <- DEIN Stil (bleibt bei Updates erhalten)
  _runbooks/
    INDEX.md
    agent-initialisierung.md
    welle-orchestration.md
    ...
  _control/
    CLAUDE.md
    templates/
      status-template.md
  _user-overrides/                 <- DEINE Custom-Files (Update-safe)
    README.md
```

Bei jedem `/update-architect-pack`:
- `CLAUDE.md`, `_runbooks/*`, `_control/templates/*`, `.claude/skills/*` werden
  ueberschrieben (Template-Updates)
- `CLAUDE.user.md`, `_user-overrides/*`, alles in `Projekte/` bleibt
  unangetastet

## Customization

Wie du dein Setup persoenlich anpasst ohne dass Updates es zerstoeren:
[docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md)

## Architektur

L1-L7-Klassifikation, Audit-5-Sektionen-Format, Schriftbuero-Pattern,
Multi-Worker-Welle: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Update

```bash
# In Claude Code:
/update-architect-pack
```

oder per Script:

```powershell
# Windows
~\claude-architect-pack\scripts\update.ps1
```

```bash
# Linux / Mac
~/claude-architect-pack/scripts/update.sh
```

## License

MIT — siehe [LICENSE](LICENSE).

## Credits

Pattern entwickelt im Antigravity-Workspace.
Architekt-Doktrin inspiriert u.a. von [Mark Kashefs Agentic-OS](https://github.com/markkashef/agentic-os) (4-Layer + Skill-Eval + Verb-Noun-Naming).

## Contributing

Pull-Requests willkommen wenn:
- Neuer Skill / Runbook generisch nutzbar ist
- Anonymisierung hart durchgezogen (kein Marken-Leak)
- Doku auf Deutsch (Workspace-Konvention) oder Englisch, konsistent in einer Datei
