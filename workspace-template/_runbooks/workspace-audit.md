# Runbook: Workspace-Audit (Multi-Agent-Discovery)
> Klassifikation: L2

> **Trigger:** "Workspace auditieren", "Architektur pruefen", "Doku-Konsistenz", "Lies dich ganz ein und auditiere", "Drift-Check", "Master-Konsolidierung starten"

## Wann ein Workspace-Audit?

- Workspace ueber mehrere Monate gewachsen, Doku driftet
- Neuer Agent uebernimmt, will Stand verstehen
- Vor groesserer Konsolidierungs-Welle
- Nach grossem Refactor / Workspace-Move
- Periodisch (z.B. quartalsweise)

## Was prueft ein Workspace-Audit?

- **Doku-Konsistenz:** CLAUDE.md, MEMORY.md, Runbook-Index — alle Pointer auf existierende Files?
- **Pfad-Drift:** Files an alten Pfaden noch referenziert?
- **Stale STATUS.md:** Projekte als "AKTIV" markiert mit STATUS.md > 30 Tage alt?
- **Memory-Drift:** Memory-Files referenzieren Projekte/Pfade die nicht mehr existieren?
- **Skill-Drift:** Skill-Files referenzieren Runbooks die nicht mehr existieren?
- **Live-vs-Doku-Drift:** Workspace-Doku sagt "Service X laeuft auf Port Y", aber Server-Reality zeigt was anderes?
- **Secret-Leaks:** API-Keys / Passwords in Doku-Files?
- **Duplikat-Files:** Zwei Files mit gleichem Topic?

## Multi-Agent-Discovery-Pattern (6 Agents)

Statt seriell durchzuarbeiten: 6 parallele Agents mit disjunkten Themen.

### Agent 1 — Doku-Konsistenz
- Liest alle `CLAUDE.md` (Workspace + Projekte)
- Liest `_runbooks/INDEX.md` + alle Runbooks
- Liest `MEMORY.md` + alle Memory-Files
- Findet: Pointer auf nicht-existente Files, Doppel-Refs, Duplikat-Topics

### Agent 2 — Status-Frische
- Liest jedes `STATUS.md` und `MASTER-STATE.md`
- Pruefst `Stand: <datum>` Header
- Stale: > 14 Tage und Projekt "AKTIV" -> Drift-Flag

### Agent 3 — Memory-Audit
- Geht alle Memory-Files durch
- Pruefst Frontmatter (name, description, type)
- Pruefst `Stand: <datum>` falls vorhanden
- Findet: Phantom-Pointer aus MEMORY.md, Files ohne Pointer, Duplikat-Topics

### Agent 4 — Live-vs-Doku
- Wenn Workspace mit Server arbeitet: SSH + Services + Container-Tags abgleichen mit Doku
- Wenn nur lokal: `git status` in allen Projekten, Build-Stand pruefen

### Agent 5 — Secret-Scan
- Grep ueber alle `.md`, `.json`, `.yaml`, `.toml`, `.env*` Files
- Patterns: `sk_live_`, `ghp_`, `pk_`, `Bearer `, `password:`, `api_key`, `secret`
- Findet: geleakte Credentials (Pflicht-Cleanup wenn gefunden!)

### Agent 6 — Skill-Audit
- Liest `~/.claude/skills/*/SKILL.md`
- Pruefst ob Trigger-Worte aktuell sind
- Pruefst ob referenzierte Pfade/Runbooks existieren
- Findet: tote Skills, Drift-Pointer

## Schritt-fuer-Schritt

### 1. Vor-Audit-Recon (Lead)

```bash
# Workspace-Groesse
find . -type f -name "*.md" | wc -l
find . -type d -name "_archive" | wc -l
git log --oneline -10
```

### 2. Tasks anlegen pro Agent

```
TaskCreate "Workspace-Audit Agent 1 — Doku-Konsistenz"
TaskCreate "Workspace-Audit Agent 2 — Status-Frische"
TaskCreate "Workspace-Audit Agent 3 — Memory-Audit"
TaskCreate "Workspace-Audit Agent 4 — Live-vs-Doku"
TaskCreate "Workspace-Audit Agent 5 — Secret-Scan"
TaskCreate "Workspace-Audit Agent 6 — Skill-Audit"
```

### 3. Agents spawnen (parallel)

`Agent` Tool, 6 Calls in einer Message:
- subagent_type: Explore (read-only) oder general-purpose
- run_in_background: true
- prompt: vollstaendig self-contained pro Agent

### 4. Berichte sammeln

Pro Agent ein Bericht in `_archive/<datum>-workspace-audit/agent-<N>-bericht.md`.

Format:
```markdown
# Agent <N> — <Thema> — <Datum>

## Findings
- Finding 1 (P0/P1/P2): <Beschreibung> + Datei:Line + Reproduktion
- ...

## Top-5 Empfehlungen
- ...

## 200-Wort-Zusammenfassung
```

### 5. Lead-Konsolidierung

Pro Bericht durchsehen, in EINE Master-Audit-Datei konsolidieren:
- `_archive/<datum>-workspace-audit/MASTER-AUDIT-FINAL.md`
- Executive Summary (Top-10 Drifts)
- P0 → P3 nach Prioritaet
- Empfohlene Konsolidierungs-Welle

### 6. Konsolidierungs-Welle planen

Aus dem Master-Audit eine konkrete Welle ableiten (siehe `welle-orchestration.md`):
- Phase A = P0-Fixes (Secret-Leaks, falsche Pfade, broken Skills)
- Phase B = P1-Fixes (Stale STATUS, Memory-Drift)
- Reviewer = Lead-self mit erneutem 6-Agent-Audit

## Verifizieren

- [ ] 6 Agent-Berichte vorhanden
- [ ] MASTER-AUDIT-FINAL.md geschrieben
- [ ] Konkrete Konsolidierungs-Welle vorgeschlagen
- [ ] Falls Secret-Leak: SOFORT ACT-File geschrieben (P0)
- [ ] Memory-Update fuer "letzter Workspace-Audit: <datum>"

## Boundaries

- Audit-Agents sind read-only — sie schreiben nur Berichte, kein Code-Edit.
- Pro Agent disjunktes Thema — keine Cross-Reads.
- Bei Funden NICHT direkt fixen — alles in den Master-Audit, dann strukturierte Welle.

## Learnings

### 6-Agent ist Sweet-Spot
Mehr Agents -> Themen-Overlap, doppelte Findings. Weniger -> Themen zu breit, oberflaechlich.

### Secret-Scan ist Pflicht
Jeder Workspace-Audit MUSS Secret-Scan enthalten. Findings = P0 mit sofortiger ACT.

### Workspace-Audit als Vor-Konsolidierungs-Schritt
Niemals direkt eine "Cleanup-Welle" starten ohne erst zu wissen WO die Drifts sind. Audit kostet 30-45 Min, sparte in der Realitaet mehrere Stunden Fehler-Suche.
