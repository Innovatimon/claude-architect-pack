---
name: autonomous-execution
description: Globale Doktrin fuer vollautonomes Arbeiten in diesem Workspace. Aktivieren bei JEDER User-Anweisung (User-Stil ist Auto-Default), oder bei "executeAutonomously", "autonomLoop". Agent arbeitet eigenstaendig bis er auf einen echten Stop-Punkt trifft (Credential, Webseiten-Zugang, externe Genehmigung) und schreibt dann eine User-Anleitung. Schleifen bis Vision/Anweisung erfuellt ist.
---

# Autonomous Execution — Pointer

> **Single-Source-of-Truth ist `C:\Users\YourUser\.YourWorkspace\CLAUDE.md`** (Sektion "TOP-DOKTRIN: Vollautonom arbeiten").
> Dieser Skill existiert nur fuer die Trigger-Mechanik (Frontmatter-Description aktiviert ihn bei jeder User-Anweisung im `~/.your-workspace/` Workspace).

## Was du tun musst, wenn dieser Skill triggert

1. Lies die Sektion **"TOP-DOKTRIN: Vollautonom arbeiten"** in der Root-`CLAUDE.md`.
2. Lies die Sektion **"Umlaut-Pflicht"** (ASCII in interner Doku, Umlaute in User-facing/UI/Mail).
3. Lies die Sektion **"Klassifikations-Hierarchie (L1-L7)"** wenn du Doku schreibst.
4. Lies die Sektion **"Skill-Konvention"** wenn der User "Skill: ..." sagt.

## Kurzform (falls CLAUDE.md unzugaenglich)

- Sofort starten, vollautonom arbeiten, nicht nachfragen wo du selbst entscheiden kannst.
- Schleifen drehen: Plan → Build → Test → Commit → Deploy → Verify → Cleanup → wiederholen.
- Stop NUR bei: Credential fehlt, Webseiten-Login nur User, Bezahl-Aktion, Hardware, strategische User-Entscheidung, destruktive Ambiguitaet.
- Bei Stop: User-Anleitung in `_schriftbuero/User-Anleitungen/ACT-YYYY-MM-DD-NNN.md` + Chat-Hinweis "BLOCKED weil X, naechster Schritt Y".
- Live-Verifikation Pflicht (curl / BUILD_ID / Smoke). Behauptung ohne Beweis ist verboten.
- Cleanup nach jeder Welle: Tot-Files weg, Audit-Files loeschen, STATUS.md ueberschreiben, Memory pflegen.

## Trigger
Implizit bei JEDER User-Anweisung in `~/.your-workspace/`. Explizite Trigger:
"Arbeite das ab", "Mach es fertig", "Vollautonom", "Schalte X live", "Iteriere bis perfekt", "Skill: X".

## Beziehung zu anderen Skills
- `thinkLikeUser`: **Parallel-Layer (Persona-Substanz).** Ich (autonomous-execution) triggere bei jeder User-Anweisung im Workspace, thinkLikeUser liefert die User-Werte/Reflexe/Anti-Patterns/Entscheidungen. Bei Sub-Agent-Spawn beide im Prompt aktivieren.
- `audit-creator`: orchestriert Audit-Wellen
- `audit-worker`: arbeitet einzelnen Audit ab
- `project-setup`: bootstrap-Doku fuer neue Projekte
- `loop`/`schedule`: Recurring Tasks (orthogonal)

`autonomous-execution` ueberlagert alle anderen — wenn ein Skill sagt "frage den User", diese Doktrin sagt "nur bei Stop-Punkt".

## Stand
2026-05-11 — auf Pointer reduziert (Master-Konsolidierung W1-A). Vorherige Vollversion archiviert im Git-History.
