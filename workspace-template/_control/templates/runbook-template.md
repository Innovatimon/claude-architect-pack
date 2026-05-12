# Runbook: [Titel]
> Klassifikation: [L2 Global / L4 System / L5 Shop-Framework / L6 Marke / L7 Projekt]
> Stand: [YYYY-MM-DD]

> **Trigger:** "Stichwort 1", "Stichwort 2", "konkreter Userspruch den der User wirklich sagt"

<!-- HINWEIS AN JEDEN AGENTEN, DER DIESES RUNBOOK NUTZT:
     Wenn du dieses Runbook ausgefuehrt (oder geprueft und fuer ueberholt befunden) hast,
     ergaenze VOR Session-Ende eine Zeile im ## Run-Log unten. Wenn dir etwas Neues
     aufgefallen ist, fuettere zusaetzlich ## Learnings. Das ist die Mitlern-Pflicht
     (CLAUDE.md "Navigations-Doktrin"). Ein Runbook ohne gepflegtes Run-Log gilt im
     Heartbeat als Drift. -->

## Kontext (optional, max 5 Zeilen)
Was ist dieses Ding? Warum existiert es? Nur falls nicht selbsterklaerend.

## Voraussetzungen (optional)
- Tools / Zugaenge / Pfade die der Agent vorher braucht.

## Schritte

### 1. [Schrittname]
Konkrete Befehle (copy-paste-ready) oder ein klares "tu X". Bekannte Fallen direkt im Schritt erwaehnen, nicht erst in Learnings.

```bash
# echter Befehl, kein Pseudo-Code
```

### 2. [Schrittname]
...

## Verifizieren
- [ ] Pruefbares Ergebnis 1 (mit Befehl: `...`)
- [ ] Pruefbares Ergebnis 2

## Rollback (optional)
Wie macht man es rueckgaengig, wenn es schiefgeht?

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent, der dieses Runbook nutzt, ergaenzt EINE Zeile — neueste oben, max 8 Zeilen (aelteste loeschen). Das ist die kuerzeste Form der Mitlern-Pflicht: kostet 10 Sekunden, macht stale Runbooks im Heartbeat sichtbar, und zeigt dem naechsten Agenten ob das Runbook noch stimmt.
>
> **Outcome-Codes:** `PASS` = lief glatt, nichts geaendert · `PARTIAL` = lief, aber etwas war anders (Notiz!) · `FIX` = Runbook stimmte nicht mehr, Schritt korrigiert · `META` = nur am Runbook editiert, nicht ausgefuehrt.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| YYYY-MM-DD | (Erstellung) | META | Runbook angelegt. |

## Learnings

> Erkenntnisse aus realen Einsaetzen. Format: `### YYYY-MM — Kurztitel` + Problem + was geholfen hat. Optional gruppierbar nach **Was funktioniert** / **Anti-Patterns** / **Optimierungs-Hypothesen**. Halte es konkret — eine Zeile "Caddy reload statt restart, sonst WS-Drop" ist mehr wert als ein Absatz Prosa.

### YYYY-MM — [Kurztitel des ersten realen Falls]
(wird nach erstem Einsatz gefuellt)

## Related (optional)
- Verwandte Runbooks / Skills / Doku-Pfade.
