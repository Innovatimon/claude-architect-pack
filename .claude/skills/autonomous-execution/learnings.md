# Learnings: autonomous-execution

> Stand: 2026-05-11
> Letzter Run: implizit bei JEDER User-Anweisung (kein einzelner trackbarer Run)

## Was funktioniert (bestaetigte Patterns)
- Schleifen drehen (Plan -> Build -> Test -> Commit -> Deploy -> Verify -> Cleanup) bis Vision erfuellt — verhindert "halb-fertig"-Drift.
- Live-Verifikation als Pflicht-Output spart Re-Audits.
- User-Anleitung bei Stop-Punkt mit klarem "Naechster Schritt: Y" reduziert Hin-und-Her.

## Was nicht funktioniert (Anti-Patterns)
- Nachfragen wo selbst entschieden werden kann (User-Stil ist Auto-Default).
- "Build koennte failen" als Ausrede fuer Stop nutzen — kein echter Stop-Punkt.
- Behauptung ohne Beweis ("ich habe das deployed") — verboten.

## Optimierungs-Hypothesen
- Pro Loop-Iteration eine 1-Zeilen-Status-Notiz im Chat haelt User informiert ohne zu blocken.
- Stop-Punkt-Klassifikation kann aus Memory `feedback_anthropic_subscription.md` und Co. abgeleitet werden.

## Run-History (letzte 5)
- (implizit aktiv, nicht einzeln getrackt — siehe pro-Welle-Berichte in `audit-creator` / `audit-worker`)

## Bekannte Schwachstellen aus Vor-Runs (vor Eval-Pattern)
- Halluzinations-Risiko bei L6-Cross-Marken-Snatch (Architekt-Audit Pflicht).
- "Welche Variante ist besser" als Stop-Punkt missverstanden — sollte mit Architekt-Default selbst entschieden werden.
- Doku in falscher Ebene angelegt (CLAUDE.md statt Runbook etc.) — siehe Skill-Konvention in CLAUDE.md.

## Cross-Skill-Hinweise
- Ueberlagert ALLE anderen Skills. Wenn ein Skill sagt "frage den User", diese Doktrin sagt "nur bei Stop-Punkt".
- Pflicht-Cleanup-Trigger nach jeder Welle: `cleanup-after-welle`.
- Bei Audit-Wellen: orchestriert via `audit-creator`, ausgefuehrt via `audit-worker`.
