# Runbook: Workspace-Audit
> Klassifikation: L2
> Stand: 2026-05-12

> **Trigger:** "Workspace auditieren", "Architektur pruefen", "Doku-Konsistenz", "Lies dich ganz ein und auditiere", "Drift-Check", "Master-Konsolidierung starten"
>
> **Zielbild:** Vollstaendiger Workspace-Snapshot nach 6-Agenten-Discovery-Pattern + Synthese + Fragenkatalog fuer den User. Outcome: belastbare Inventur + priorisierte Aktions-Liste + Strategische Fragen an den User.

---

## Wann anwenden
- Vor jeder Master-Konsolidierung.
- 1x pro Quartal als Hygiene.
- Wenn der User "alles ist drift, was geht noch" sagt.
- Vorgangs-Vorlage: Phase 1 der Master-Konsolidierung 2026-05 (siehe Initiator
  `_schriftbuero/Kontinuitaet/2026-05-11-Master-Konsolidierung-Initiator.md`).

## Voraussetzungen
- Architekt-Modus (du selbst), nicht delegieren.
- 6 parallele Sub-Agenten (`Explore`-Typ fuer Read-Only-Inventur).
- ~2-3h Zeitbudget fuer die Discovery, dann Synthese in 1h.

---

## Phase 1 — Discovery (6 parallele Sub-Agenten)

> **Pflicht-Prompt-Prefix fuer ALLE 6 Sub-Agenten:** `Aktiviere Skill thinkLikeUser sofort. Working Directory: C:\Users\YourUser\.YourWorkspace\.` Sonst arbeiten Discovery-Agenten ohne User-Persona — Audits werden neutral statt im Architekt-Stil bewertet. Skill-Pfad: `~/.claude/skills/thinkLikeUser/`.

Spawne in EINER Message 6 `Explore`-Agenten parallel. Pro Agent ein klar
abgegrenzter Scope, Read-only, Output: strukturierter Markdown-Report
(max 800 Woerter).

### Agent A — Schriftbuero-Inventar
- Scope: `_schriftbuero/`, `Projekte/MultiBrandShops/_schriftbuero/`,
  `Projekte/ProjectZeta/ProjectEpsilon/_schriftbuero/`, jedes weitere `_schriftbuero/`
- Output: Pro Schriftbuero: Struktur (Ordner), Inbox-Alter,
  Briefings-Liste, offene Antworten, Initiatoren, Templates.
- Markiere: Drift (alte Inbox-Files, fehlende Ordner, broken Templates).

### Agent B — Skills + Runbooks Audit
- Scope: `~/.claude/skills/*/SKILL.md`, `_runbooks/*.md`,
  `_runbooks/INDEX.md`, `_control/skills/` falls vorhanden.
- Output: Pro Skill/Runbook: Klassifikation (L1-L7), Frontmatter-Status,
  Trigger-Phrasen, Doppelungen, obsolete Eintraege.
- Markiere: Skill-vs-Runbook-Redundanzen, fehlende INDEX-Eintraege,
  fehlende L-Klassifikation.

### Agent C — STATUS + VISION pro Projekt
- Scope: Alle Projekte aus Root-CLAUDE.md.
- Pro Projekt Read: `STATUS.md`, `VISION.md`, `CLAUDE.md`.
- Output: Tabelle Projekt | STATUS-Datum | VISION-Datum | CLAUDE-Datum |
  Drift-Marker.
- Markiere: Fehlende Files, Files >7 Tage alt, Widersprueche zur
  Root-CLAUDE.md-Projekt-Tabelle.

### Agent D — Memory-Audit
- Scope: `~/.claude/projects/C--Users-TuT-Admin--YourWorkspace/memory/`.
- Output: Pro File: KEEP / UPDATE / MERGE / DELETE-Empfehlung mit
  Begruendung. Cross-Check MEMORY.md-Index vs Filesystem vs
  CLAUDE.md-Block.
- Markiere: Stale (>3 Monate, gestrichenes Projekt), Doppelungen,
  fehlende Index-Eintraege.

### Agent E — _control + CLAUDE.md
- Scope: `_control/`, alle `CLAUDE.md` im Workspace (Root + 19+
  Projekt-CLAUDE.md).
- Output: Pro File: Datums-Header, Konsistenz mit Realitaet, L-Klassifikation,
  doppelte Doktrin-Sektionen.
- Markiere: Tote `_control/projects/*.md` (gestrichene Projekte),
  fehlende Project-Files fuer aktive Projekte, GitHub-User-Konflikt,
  fehlende L-Klassifikation in Projekt-CLAUDE.md.

### Agent F — Meta-Architektur
- Scope: Alle aus A-E + Top-Doktrin in CLAUDE.md, Umlaut-Regel,
  Klassifikations-Hierarchie.
- Output: Wie viele Stellen definieren dieselbe Regel? Wo gibt es
  Single-Source-Verletzungen? Was kann auf Pointer reduziert werden?
- Markiere: Doktrin-Doppelungen (Top-Doktrin, Umlaut-Pflicht, L1-L7,
  Cleanup-Pflicht).

---

## Phase 2 — Synthese (Architekt selbst)

Lies alle 6 Reports. Erstelle in einer Session:

### 2.1 Inventur-Datei
Pfad: `_schriftbuero/Briefings/<YYYY-MM-DD>-workspace-audit-inventur.md`.
Inhalt:
- Executive Summary (5 Bullets)
- Pro Discovery-Agent: Highlights + Drift-Liste
- Cross-Cutting-Findings (was tauchte in mehreren Reports auf)
- Quick-Wins (sofort fixbar) vs Strategic-Items (User-Input noetig)

### 2.2 Fragenkatalog
Pfad: `_schriftbuero/Fragenkataloge/<YYYY-MM-DD>-<thema>.md`.
Vorlage / Goldstandard: `_schriftbuero/Fragenkataloge/2026-05-08-master-konsolidierung.md`.

Struktur:
- 8-12 strategische Fragen an den User.
- Pro Frage: Architekt-Empfehlung (A/B/C) + Begruendung.
- Anhang: Discovery-Reports als gekuerzte Snapshots.

### 2.3 Initiator fuer Phase 2
Pfad: `_schriftbuero/Kontinuitaet/<YYYY-MM-DD>-<thema>-Initiator.md`.
Goldstandard: `_schriftbuero/Kontinuitaet/2026-05-11-Master-Konsolidierung-Initiator.md`.
- Welle-Plan mit Sub-Agenten-Aufteilung.
- Stop-Punkte definiert.
- Verifikations-Hardtests am Ende.

---

## Phase 3 — Uebergabe

Im Chat:
```
Workspace-Audit abgeschlossen.
- 6 Discovery-Agents gelaufen, Reports in <Pfad>.
- Inventur: <Pfad>
- Fragenkatalog: <Pfad>  (X Fragen, davon Y mit Architekt-Default)
- Initiator: <Pfad>
- Empfehlung: <warten auf User-Antworten | Architekt-Defaults starten>
```

---

## Verifizieren
- [ ] 6 Discovery-Reports liegen vor (in `Tasks`-Output oder Schriftbuero)
- [ ] Inventur-Datei existiert
- [ ] Fragenkatalog existiert mit >=8 Fragen
- [ ] Initiator existiert mit Welle-Plan
- [ ] Im Chat klare Naechster-Schritt-Empfehlung

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent der dieses Runbook nutzt ergaenzt EINE Zeile — neueste oben, max 8 (aelteste raus). Outcome-Codes: `PASS` (lief glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt). Doktrin: `CLAUDE.md` "Navigations-Doktrin", `_runbooks/struktur-navigieren.md` Sektion 6.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | ## Run-Log nachgeruestet (Mitlern-Standard). |

## Learnings
- **6 Agenten parallel ist Sweet-Spot.** Weniger = Lueck​en, mehr = Redundanz.
- **Synthese ist Architekt-Pflicht.** Agenten liefern Material, nicht Entscheidungen.
- **Fragenkatalog vor Welle.** User-Input verhindert Halluzination in Phase 2.
- **Goldstandard kopieren statt frei schreiben.** Vorlage 2026-05-08 ist getestet.
- Aktivieren erfolgt typischerweise zusammen mit `_runbooks/memory-pflege.md` (Memory ist Teil von Agent D) und `_runbooks/schriftbuero-konsolidieren.md` (Cleanup nach Audit).
