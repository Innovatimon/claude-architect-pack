# Architektur — Claude Architect Pack

## Konzept

Der Pack stellt eine **Multi-Projekt-Workspace-Architektur** bereit, in der ein
einzelner Architekt-Agent mehrere Projekte gleichzeitig steuern kann, ohne dass
Sub-Agenten Konzepte oder Code aus anderen Projekten halluzinieren.

## Vier Saeulen

### 1. L1-L7 Klassifikations-Hierarchie

Jeder Ordner, jede Datei hat eine **Ebene** zugeordnet:

| Ebene | Pfad | Wer arbeitet hier? | Wer darf lesen? |
|-------|------|---------------------|-----------------|
| **L1 — Master** | `CLAUDE.md`, `CLAUDE.user.md`, `VISION.md`, `MASTER-STATE.md`, `OPEN-ITEMS.md` | Architekt | Alle |
| **L2 — Workflow Global** | `_runbooks/` | Architekt + alle Sub-Agenten | Alle |
| **L3 — Governance Global** | `_control/` | Architekt + System-Agenten | Alle |
| **L4 — System** | `_system/` (eigene OS-Tools) | System-Agenten | Alle (read) |
| **L5 — Framework** | `Projekte/<group>/_framework/` | Architekt + Group-Agenten | Group-Agenten (read), L7 nicht |
| **L6 — Brand** | `Projekte/<group>/Sub/<brand>/` | Nur Marken-eigener Agent | Architekt + diese Marke |
| **L7 — Einzel-Projekt** | `Projekte/<name>/` | Nur Projekt-eigener Agent | Architekt + dieses Projekt |

**Warum?** Ein Sub-Agent in `Projekte/AppX/` darf nicht den Framework-Code aus
`Projekte/GroupY/_framework/` lesen — sonst halluziniert er Konzepte die nicht
zu seinem Projekt gehoeren.

### 2. Audit-Wellen mit 5-Sektionen-Format

Statt freihaendigem Code-Edit organisiert der Architekt Arbeit in **Wellen**:

1. **Audit schreiben** (5 Sektionen: MISSION / PHASEN / PRIDE / CRUCIBLE / DEPLOYMENT)
2. **Worker spawnen** (3-7 parallele Sub-Agenten)
3. **Reviewer** (Independent Sub oder Lead-self mit Live-Tests)
4. **Cleanup** (`cleanup-after-welle` Skill)

Vorteile:
- Klar abgegrenzte Arbeitsblocks → kein Scope-Creep
- Live-Tests in der CRUCIBLE-Sektion → keine "Es sollte funktionieren"-Antworten
- STATUS.md pro Welle ueberschrieben → kein Doku-Friedhof

### 3. Schriftbuero (User-Agent-Kommunikation)

Statt User-Aufgaben im Chat verstreuen: **strukturiertes Verzeichnis** mit:

```
_schriftbuero/
  Templates/            # Vorlagen
  Inbox/                # User-Uploads
  Briefings/            # Agent → User
  Fragenkataloge/       # Agent → User: Klarstellung
  Antworten/            # User → Agent
  Kontinuitaet/         # Session-Uebergaben
  User-Anleitungen/     # ACT-* Files
  MASTER-ACTIONS.md     # Index
```

User-Anleitungen folgen dem `ACT-YYYY-MM-DD-NNN-<topic>.md` Pattern und
unterstuetzen Inline-Konversation (User antwortet direkt im File).

### 4. User-Override-Layer

`CLAUDE.user.md` und `_user-overrides/` ueberleben Updates des Pack-Repos.

```
workspace/
  CLAUDE.md              ← Pack-Template, wird aktualisiert
  CLAUDE.user.md         ← User-Anpassungen, bleibt
  _runbooks/
    INDEX.md             ← Pack-Template
    custom-*.md          ← User-eigene Runbooks (bleibt)
  _user-overrides/       ← Belebige User-Files (bleibt)
  Projekte/              ← User-Inhalt (bleibt)
```

Update-Logik in `MANIFEST.yml`:
- `template_managed:` Liste der Files die ueberschrieben werden
- `user_owned:` Liste der Files / Pfade die nie angefasst werden

## Skill-Konvention

Wenn der User "Skill: X" sagt, entscheidet der Agent selbst wohin:

| Inhalt | Ablage |
|--------|--------|
| Globale Doktrin / Workflow ueber alle Projekte | `~/.claude/skills/<name>/SKILL.md` |
| Wiederkehrender Schritt-Prozess | `_runbooks/<name>.md` + INDEX-Eintrag |
| Hard-Rule die immer gilt | `CLAUDE.md` (Root) |
| Projekt-spezifische Konvention | `<Projekt>/CLAUDE.md` |
| User-Profil / Feedback | Memory `feedback_*.md` / `user_*.md` |
| Projekt-State (wer-wo-was) | Memory `project_*.md` |
| Eine konkrete User-Schritt-Anleitung | `_schriftbuero/User-Anleitungen/ACT-*.md` |

**Im Zweifel spezifischer als globaler.** Vermeidet Halluzination bei
nicht-zustaendigen Agenten.

## Doktrin: Vollautonom

Der Pack ist auf **autonomen Modus** optimiert:

- Sofort starten, nicht nachfragen wo selbst entscheidbar
- Schleifen drehen: Plan → Build → Test → Commit → Deploy → Verify → Cleanup
- Stop NUR bei echten Stop-Punkten: Credential, externer Login, Bezahl-Aktion,
  Hardware, strategische Entscheidung, destruktive Ambiguitaet
- Bei Stop: User-Anleitung im Schriftbuero
- Live-Verifikation Pflicht (curl / BUILD_ID / Smoke)

User kann das via `CLAUDE.user.md` Sektion "Doktrin-Overrides" abschwaechen.

## Anti-Patterns

### "HANDOFF.md zwischen Sessions"
Stattdessen: `STATUS.md` ueberschreiben + `_archive/<datum>-berichte/`.

### "Audit-Files behalten falls noch jemand schaut"
Audit-File ist Sub-Agent-Auftrag. Nach Erledigung MUSS weg. Sonst verwirrt es den naechsten Init-Agenten.

### "Worker macht direkt externen Status-Update"
Status in externen Systemen (Notion/Linear/Issues) wird ERST nach Reviewer-PASS aktualisiert.

### "git add -A"
Wenn parallele Worker laufen: explizit `git add <SPEZIFISCHE-FILES>`. Sonst absorbieren sich Files ueber Stage-Index.

### "Memory updaten ist optional"
Bei jeder Welle die Drift verursacht: Memory aktualisieren oder Stale-markieren. Sonst halluziniert der naechste Agent.

## Weiterfuehrende Doku

- [INSTALL.md](../INSTALL.md) — Installation
- [docs/CUSTOMIZATION.md](CUSTOMIZATION.md) — Wie du den Pack anpasst
- [MANIFEST.yml](../MANIFEST.yml) — Was bei Updates ueberschrieben wird
