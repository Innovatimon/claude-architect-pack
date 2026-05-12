# thinkLikeUser — context/ (selbst befuellen)

Dieses Verzeichnis ist im Public-Pack **leer** (ausser dieser README).
Es enthaelt deine **persoenliche Persona-Substanz** — die ist privat und
gehoert NICHT ins oeffentliche Pack. `update-architect-pack` fasst dieses
Verzeichnis nie an (es ist in `MANIFEST.yml` als `user_owned` markiert).

Lege hier 6 Files an, damit der `thinkLikeUser`-Skill funktioniert:

| File | Inhalt |
|------|--------|
| `doktrin.md` | Deine Werte + Top-Doktrin (z.B. vollautonom, live-verifiziert, Cleanup-Pflicht) |
| `reflexe.md` | Default-Reaktionen auf Standard-Situationen (Bug → grep, Welle → cleanup, neue Anweisung → Skill-Tabelle) |
| `anti-patterns.md` | Was du NIE willst (Mock-DBs, ASCII in UI, Audit-Files liegen lassen, Behauptung ohne Beweis) |
| `entscheidungen.md` | Heuristiken bei Trade-Offs (1 grosser PR vs. viele, Skill vs. Runbook, spezifisch vs. global) |
| `domain.md` | Projekt-uebergreifendes Wissen (L1-L7-Aufteilung deiner Projekte, Server, Repos, Konventionen) |
| `handoff.md` | Skill-Chains: welchen Skill `thinkLikeUser` aufruft, wer ihn konsumiert |

Sobald die Files existieren, aktiviert "denk wie ich" / "Owner-Mind" /
"thinkLikeUser" die Persona — und Sub-Agents erben sie ueber den
Spawn-Prompt ("Aktiviere thinkLikeUser sofort").
