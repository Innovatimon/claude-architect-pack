# Handoff: thinkLikeUser

> Wer ruft mich auf? Wen rufe ich auf? Was gebe ich weiter?

## Chained Skills

### Vor mir (Caller)
- **Jede User-Anweisung** mit Trigger-Phrase (siehe SKILL.md)
- **autonomous-execution** — laedt thinkLikeUser implizit beim Workspace-Start (Auto-Default)
- **Sub-Agent-Spawnung** — Parent-Agent muss "Aktiviere thinkLikeUser" im Sub-Prompt mitgeben, sonst kennt der Sub-Agent die Persona nicht

### Ueberlagert von
- Nichts. `thinkLikeUser` ist die Basis. Andere Skills bauen auf ihm auf.
- Ausnahme: Echter User-Stop-Punkt (Credential / Login / Bezahlung / strategische Entscheidung) ueberschreibt Auto-Entscheidung.

### Rufe auf (chained downstream)
- **autonomous-execution** — wenn Schleife noetig ist
- **cleanup-after-welle** — nach jeder Welle Pflicht
- **audit-creator** (= `generateAuditsFromNotion`) — bei "Notion abarbeiten"
- **audit-worker** (= `executeAudit`) — wenn Audit-File im Projekt-Ordner
- **bootstrapNewProject** — bei "neues Projekt"
- **generateProjectDataMap** — bei "Datamap erstellen"
- **heartbeatWorkspace** — bei "Heartbeat Check" / Cron
- **share-workspace** — bei "Pack publizieren"
- **memory-pflege** (Runbook) — wenn Memory-Drift erkannt

## Output-Schema

Dieser Skill hat **kein File-Output**. Er transformiert das Verhalten des Agents.

Indirekte Outputs (via aufgerufene Skills):
```yaml
behavior_changes:
  - decision_default: "selbst entscheiden mit Architekt-Default statt fragen"
  - verification_mode: "live (curl/BUILD_ID/Smoke) statt code-read"
  - cleanup_required: true
  - umlauts_in_user_facing: true
  - sub_agent_persona_inheritance: "explizit im Prompt mitgeben"
indirect_files:
  - _schriftbuero/User-Anleitungen/ACT-*.md  # bei Stop-Punkt
  - STATUS.md updates  # nach Welle
  - memory/feedback_*.md  # bei neuem Pattern
  - memory/MEMORY.md  # Index-Updates
```

## Pre-Conditions
- Working Directory `C:\Users\YourUser\.YourWorkspace\` ist Workspace-Root
- Root-`CLAUDE.md` lesbar (Single-Source-of-Truth)
- `MEMORY.md` lesbar
- Alle 6 context-Files unter `~/.claude/skills/thinkLikeUser/context/` vorhanden

## Post-Conditions
- Agent kennt User-Werte, Reflexe, Anti-Patterns, Entscheidungs-Heuristiken, Domain
- Agent entscheidet statt zu fragen (sofern kein echter Stop-Punkt)
- Sub-Agents (falls gespawnt) wissen sie sollen "Aktiviere thinkLikeUser" im Prompt nutzen

## Failure-Modes

| Failure | Ursache | Fix |
|---------|---------|-----|
| Agent fragt obwohl Default klar ist | context/entscheidungen.md nicht gelesen | SKILL.md Step 1 strikter |
| Sub-Agent driftet | "Aktiviere thinkLikeUser" fehlte im Spawn-Prompt | Parent-Agent muss Prompt-Pattern lernen |
| Skill driftet | Memory wird nicht gepflegt | Bei User-Korrektur sofort feedback_*.md + context-Update |
| False-Positive-Trigger | "ohne Fragen" zu generisch | Trigger-Set verfeinern in learnings.md |
| Halluzination unklarer Werte | Skill war aktiv, hat aber User-Wert nicht in Memory gefunden | Stop-Punkt = Frage stellen, nicht raten |

## Spezial: Sub-Agent-Spawn-Pattern

Wenn ich (Architekt) einen Sub-Agent spawne via `Agent`-Tool, beginnt der Prompt IMMER mit:

```
Aktiviere Skill thinkLikeUser sofort am Anfang.
Du arbeitest in `C:\Users\YourUser\.YourWorkspace\`.

Deine Aufgabe: <konkret>

Stop-Punkte (User fragen): <falls bekannt>
Architekt-Default falls Trade-Off: <falls bekannt>
```

Nur so erbt der Sub-Agent die Persona. Sonst arbeitet er "neutral" und das ist nicht was der User will.
