# Learnings: project-setup

> Stand: 2026-05-11
> Letzter Run: noch nicht dokumentiert (Eval-Pattern eingefuehrt 2026-05-11)

## Was funktioniert (bestaetigte Patterns)
- 5-Pflicht-Files Pattern (CLAUDE.md / VISION.md / STATUS.md / PROJECT.md / SETUP.md) ist robust ueber alle Projekttypen.
- Sub-Projekte erben L-Klasse vom Eltern (z.B. ProjectEpsilon = L7 wie ProjectZeta).
- "Im Zweifel spezifischer als globaler" reduziert Halluzinations-Risiko bei Doku-Klassifikation.

## Was nicht funktioniert (Anti-Patterns)
- Schriftbuero als Default anlegen — nur bei "viel User-Input + Uploads".
- Credentials in CLAUDE.md / SETUP.md inline — verboten, nur Pfade.
- L5/L7-Verwechslung (Shop-Projekt unter `Projekte/<Name>/` statt `Projekte/MultiBrandShops/Shops/<Marke>/`).

## Optimierungs-Hypothesen
- Pflicht-Templates aus `_control/templates/` ziehen statt jedes Mal neu schreiben.
- Bei Server-Projekten zusaetzlich `/opt/agentos/projects/<name>/project.json` anlegen.

## Run-History (letzte 5)
- (leer)

## Bekannte Schwachstellen aus Vor-Runs (vor Eval-Pattern)
- Root-`CLAUDE.md` Tabelle vergessen zu updaten — naechster Architekt sieht das Projekt nicht.
- Memory-Eintrag vergessen — Drift bei naechster Session.
- STATUS.md mit Generic-Text statt projektspezifischem Template-Inhalt.

## Cross-Skill-Hinweise
- Output kann von `audit-creator` konsumiert werden, sobald erstes Audit faellig ist.
- Cleanup nach Bootstrap-Welle via `cleanup-after-welle`.
- Bei Bootstrap-Interview-basiertem Pfad: alternative Skill `bootstrapNewProject` (Worker 5 spawnt diesen — orthogonal).
