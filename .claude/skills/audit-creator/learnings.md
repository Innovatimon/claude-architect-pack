# Learnings: audit-creator

> Stand: 2026-05-11
> Letzter Run: noch nicht dokumentiert (Eval-Pattern eingefuehrt 2026-05-11)

## Was funktioniert (bestaetigte Patterns)
- (leer initial — wird nach erstem Run mit Eval-File gefuellt)

## Was nicht funktioniert (Anti-Patterns)
- (leer initial)

## Optimierungs-Hypothesen
- Notion-Notizen vor Audit-Erstellung in Themen-Cluster gruppieren reduziert "1-Notiz-1-Audit"-Overhead.
- Welle-IDs (W4, W5, W4-Hotfix) in Audit-Suffix einbauen erleichtert Cleanup-Trace.

## Run-History (letzte 5)
- (leer)

## Bekannte Schwachstellen aus Vor-Runs (vor Eval-Pattern)
- Notion-Kommentare zu frueh gesetzt (vor Live + Reviewer-PASS) — Memory feedback_notion_workflow.md.
- "1 Mega-Audit" statt Aufteilung — Memory feedback_agent_splitting.md.
- Live-Verifikation vergessen, Behauptung ohne Beweis — Memory feedback_deploy_verify.md.

## Cross-Skill-Hinweise
- Output dieses Skills wird von `audit-worker` konsumiert. Audit-Format muss exakt 5 Sektionen halten, sonst Worker-Drift.
- Cleanup-Phase delegiert an `cleanup-after-welle` — STATUS.md-Sektion in Audit-Template muss kompatibel bleiben.
