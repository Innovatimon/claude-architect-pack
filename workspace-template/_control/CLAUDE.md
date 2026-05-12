# _control/CLAUDE.md — L3 Governance Pointer

> Stand: 2026-05-11
> Ebene: **L3 — Governance Global** (siehe Root-`CLAUDE.md` Sektion "Klassifikations-Hierarchie")
> Single-Source-of-Truth fuer Architekt-Doktrin, Audit-Format, L1-L7-Hierarchie,
> Umlaut-Pflicht, Skill-Konvention, Projekt-Tabelle, GitHub-Repos: **Root-`CLAUDE.md`**.

Dieses File ist KEINE zweite Doktrin. Es ist nur ein Wegweiser durch `_control/`.

## Was hier liegt (Inhalts-Inventar)

| Pfad | Zweck |
|------|-------|
| `_control/credentials-map.md` | Wo ALLE Credentials liegen (nur Dateipfade, niemals Werte) |
| `_control/server-config.md` | Server-Konfiguration, Domains, Docker, Deploy-Befehle (W2-C) |
| `_control/projects/` | Pro-Projekt-State-Dateien (W2-A) — muss aktuell gehalten werden |
| `_control/features/` | Claude-Code-Feature-Doku (Agent Teams, Auto Mode, Channels, Cloud Tasks, Worktrees) |
| `_control/templates/` | Vorlagen fuer wiederkehrende Doku-Artefakte |
| `_control/skills/` | L3-spezifische Skill-Definitionen (globale Skills liegen unter `~/.claude/skills/`) |
| `_control/_archive/` | Alte Versionen (z.B. `CLAUDE-2026-05-11.md`) |

## L3-spezifische Konvention: Suffix-System fuer parallele Audits

(Behalten, weil Root-CLAUDE.md das Suffix-Detail nicht hat — gilt nur fuer Audit-Worker.)

- Jeder Worker arbeitet auf **einem** Suffix: `[prefix].audit.md` -> `[prefix].handoff.md`.
- Mehrere Agents koennen PARALLEL auf verschiedenen Suffixen im gleichen Projekt-Ordner arbeiten.
- Du ueberschreibst NUR deinen Suffix. Andere Suffixe gehoeren anderen Agents.
- Handoff-Format: Status (PASS/FAIL), Datum ISO 8601, Was gemacht (Bullets), Geaenderte Dateien, Tests, Offene Punkte.

Alles Weitere (5-Sektionen-Audit-Format, Zero-Bug-Policy, Features, Server-Zugang,
Projekt-Liste, GitHub-Repos, Umlaut-Regeln, Klassifikations-Hierarchie) steht in
Root-`CLAUDE.md`.
