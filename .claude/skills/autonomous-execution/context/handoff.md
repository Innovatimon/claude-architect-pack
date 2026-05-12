# Handoff: autonomous-execution

> Wer ruft diesen Skill auf? Was muss ich uebergeben?
> Wer konsumiert meinen Output?

## Chained Skills
- **Vor mir:** Implizit JEDE User-Anweisung. Kein expliziter Caller.
- **Parallel-Layer:** `thinkLikeUser` — `autonomous-execution` triggert die Persona-Aktivierung (Auto-Default ist an), `thinkLikeUser` liefert die Persona-Substanz (Werte/Reflexe/Anti-Patterns/Entscheidungen/Domain). Beide laufen zusammen. Bei jedem Sub-Agent-Spawn beide aktivieren.
- **Ueberlagert:** ALLE anderen Skills (`audit-creator`, `audit-worker`, `cleanup-after-welle`, `project-setup`, `share-workspace`). Wenn ein Skill sagt "frage den User", ueberschreibt diese Doktrin mit "nur bei echtem Stop-Punkt".
- **Ruft auf:** `cleanup-after-welle` (Pflicht nach jeder Welle), `audit-creator` (bei Notion-Welle), `audit-worker` (bei Single-Audit), `project-setup` (bei neuem Projekt), `thinkLikeUser` (impliziter Auto-Layer).

## Output-Schema

### User-Anleitung bei Stop-Punkt
```
Pfad: _schriftbuero/User-Anleitungen/ACT-YYYY-MM-DD-NNN.md

Struktur:
# ACT-YYYY-MM-DD-NNN — <Kurz-Titel>

## Warum geblockt
<Konkreter Stop-Punkt: Credential X fehlt / Login Y nur User / Bezahlung Z>

## Was ich gemacht habe
<Bisheriger Fortschritt mit Live-Verifikation>

## Was du tun musst
1. <Schritt 1, ggf. mit Link / URL>
2. <Schritt 2>
...

## Sobald erledigt
<Wie der Agent weitermacht: "sage 'X erledigt' / lege Datei Y unter Z ab">
```

### Chat-Hinweis bei Stop
```
BLOCKED weil <konkreter-grund>
Naechster Schritt: <was-du-tun-musst>
Anleitung: _schriftbuero/User-Anleitungen/ACT-YYYY-MM-DD-NNN.md
```

### Loop-Iterationen-Output
Pro Iteration eine 1-Zeilen-Status-Notiz im Chat:
- "Iteration N: <kurz-was-gerade-geschieht>"

## Pre-Conditions
- User hat eine Anweisung gegeben ODER ein Skill triggert mich implizit
- Workspace `~/.your-workspace/` lesbar
- Root-`CLAUDE.md` lesbar (Single-Source-of-Truth fuer Doktrin)

## Post-Conditions
- Vision/Anweisung vollstaendig erfuellt ODER expliziter Stop-Punkt mit User-Anleitung
- Live-Verifikation dokumentiert (curl / BUILD_ID / Smoke)
- Cleanup-Schleife abgeschlossen (`cleanup-after-welle` getriggert)
- Memory bei Drift gepflegt

## Failure-Modes
- Vorzeitiges Nachfragen ("welche Variante ist besser?") statt selbst entscheiden
- Behauptung ohne Beweis ("ist deployed", aber kein curl-Output)
- Loop abgebrochen bei "Build koennte failen" statt diagnostizieren + fixen
- Cleanup vergessen
- Stop-Punkt-Halluzination (Stop wo eigentlich Architekt-Default greifen koennte)

## Spezial-Hinweis: Skill-Konvention
Wenn User sagt "Skill: X" — selbst entscheiden wohin (Skill/Runbook/CLAUDE.md/Memory),
gemaess Tabelle in Root-`CLAUDE.md` Sektion "Skill-Konvention".
Im Zweifel spezifischer als globaler.
