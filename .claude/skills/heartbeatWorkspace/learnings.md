# Learnings: heartbeatWorkspace

> Stand: 2026-05-12

## Was funktioniert
- (leer initial)

## Was nicht funktioniert
- (leer initial)

## Optimierungs-Hypothesen
- Schwellwert "3 Tage" fuer Stale-Audits ggf. zu kurz fuer langsame Wellen
- Memory-Drift-Scan ggf. teuer bei vielen Files — Caching-Mechanismus pruefen
- Bei Cron-Mode: Diff zur letzten Heartbeat-Datei (nur neue Issues melden)
- Scan 6 (Runbook-Mitlern-Drift) "stale Run-Log > 45 Tage" ist eine Heuristik — ggf. pro L-Klasse unterschiedliche Schwellen (L2-global haeufiger genutzt als L7-projekt-spezifisch)

## Run-History
- 2026-05-12 — Scan 6 "Runbook-Mitlern-Drift" hinzugefuegt (Runbooks ohne Run-Log / stale Run-Log / Header-/INDEX-Drift). Begleitend zur Einfuehrung der Run-Log-Pflicht in allen Runbooks. Eval auf 6 Scans aktualisiert.
