# Learnings: thinkLikeUser

> Stand: 2026-05-11 (initial)

## Was funktioniert
- (leer initial — gefuellt nach erstem produktiven Run)

## Was nicht funktioniert
- (leer initial)

## Anti-Patterns die der Skill verhindern soll
- Agent fragt "welche Option ist besser?" obwohl User-Default klar im context/entscheidungen.md steht
- Sub-Agent vergisst die Persona, weil "thinkLikeUser" nicht im Spawn-Prompt war
- Skill wird nur einmal pro Conversation gelesen, dann driftet das Verhalten

## Optimierungs-Hypothesen
- Vielleicht 6 context-Files zu viele — testen ob 3 (doktrin/reflexe/anti-patterns) ausreichen fuer 80% der Faelle
- Eval-Score-Tracking ueber Run-History: wenn unter 0.85 in 3 aufeinanderfolgenden Runs → Persona-Drift, Skill erweitern
- Trigger-Set evtl. zu breit ("ohne Fragen" koennte false-positive triggern) — beobachten

## Run-History (max 5, Round-Robin)

### Run 1 — 2026-05-11 (Bootstrap)
- **Input:** "Ueberlege wie wir es hinbekommen dass wir nicht immer alle Fragen beantworten muessen. Uebernimm meine Denkweise."
- **Output:** Skill thinkLikeUser angelegt, 4 Pflicht-Files + 6 context-Files, CLAUDE.md + MEMORY.md aktualisiert, andere Skills verlinkt
- **Score:** TBD nach User-Feedback
- **Notes:** Erste Implementierung, basiert auf Destillat aus CLAUDE.md + 40 Memories. Live-Verifikation = mentale Aktivierung (Skill-Tool sieht Trigger?). Naechster Schritt: realer Run mit "denk wie ich"-Trigger in neuer Session.
