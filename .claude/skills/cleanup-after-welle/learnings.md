# Learnings: cleanup-after-welle

> Stand: 2026-05-11
> Letzter Run: noch nicht dokumentiert (Eval-Pattern eingefuehrt 2026-05-11)

## Was funktioniert (bestaetigte Patterns)
- 8-Schritte-Routine deterministisch durchgehen — verhindert vergessene Cleanup-Aspekte.
- Hard-Delete vermeiden, Archiv unter `_archive/<datum>-<welle>/` ist sicherer.
- INDEX-Phantom-Check vor Schriftbuero-Update — kein Phantom-Verweis durchschleppen.

## Was nicht funktioniert (Anti-Patterns)
- "Ich packe alles in HANDOFF.md" — verboten (Root-CLAUDE.md).
- "Ich lasse die `.audit.md` drin" — naechster Init-Agent halluziniert dann offene Auftraege.
- Cross-Projekt-Cleanup ohne expliziten Auftrag — verstoesst L6-Isolation.
- Memory-Update als optional behandeln — bei Drift Pflicht.

## Optimierungs-Hypothesen
- Bei wiederkehrenden Files (z.B. `temp-test-*.log`) Pattern in `.gitignore` aufnehmen statt jedes Mal archivieren.
- User-Folge-Wuensche-Extraktion vor Erledigt-Markierung (Lesson aus Welle 2026-05-11: ntfy-Anleitung enthielt 2 versteckte Wuensche).

## Run-History (letzte 5)
- (leer)

## Bekannte Schwachstellen aus Vor-Runs (vor Eval-Pattern)
- HANDOFF.md / SESSION-*.md / HOLDING_*.md angelegt obwohl verboten.
- STATUS.md nur appendet statt komplett ueberschrieben.
- Audit-Files nicht geloescht nach Worker-Abschluss.
- `git add -A` blind — Secret-Risiko.

## Cross-Skill-Hinweise
- Pflicht-Trigger NACH `audit-worker`, `welle-orchestration`, `website-perfektionieren`, `grv-bugs-workflow`.
- Vor mir muss STATUS.md-Inhalt vom Worker bereitgestellt sein (sonst kann ich nicht ueberschreiben).
- Nach mir: Workspace ist sauber, naechster Architekt kann sofort weitermachen.
- Bei Memory-Drift: Vollroutine `_runbooks/memory-pflege.md`.
- Bei Schriftbuero-Konsolidierung: `_runbooks/schriftbuero-konsolidieren.md` Schritt 4a.
