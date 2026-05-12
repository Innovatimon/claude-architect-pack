# Learnings: audit-worker

> Stand: 2026-05-11
> Letzter Run: noch nicht dokumentiert (Eval-Pattern eingefuehrt 2026-05-11)

## Was funktioniert (bestaetigte Patterns)
- (leer initial — wird nach erstem Run mit Eval-File gefuellt)

## Was nicht funktioniert (Anti-Patterns)
- (leer initial)

## Optimierungs-Hypothesen
- Bei grossen Audits Agent Teams nutzen statt sequentielle Single-Worker-Phasen.
- Worktrees fuer parallele Sub-Tasks (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1).
- Bei Build-Fehlern: 1x Fix-Versuch, dann blockieren statt Endlos-Retry.

## Run-History (letzte 5)
- (leer)

## Bekannte Schwachstellen aus Vor-Runs (vor Eval-Pattern)
- STATUS.md vergessen / nur Append statt Ueberschreiben.
- Audit-File nicht geloescht nach Abschluss (verwirrt naechsten Init-Agent).
- Build-Fehler ignoriert ("ich fixe das spaeter") — verstoesst Zero-Bug-Policy.
- HANDOFF.md / SESSION-* angelegt obwohl verboten.
- Bei Server-Projekten faelschlich `git push` ausgefuehrt (AgentOS/ProjectBeta/ProjectZeta nutzen SSH).

## Cross-Skill-Hinweise
- Input kommt von `audit-creator` (oder direkt vom User per "arbeite das Audit ab").
- Output triggert `cleanup-after-welle` — STATUS.md-Format muss kompatibel sein.
- Bei Reviewer-Welle: erst nach Reviewer-PASS Notion-Kommentare schreiben (Runbook arbeitsweise-notion.md Schritt 8).
