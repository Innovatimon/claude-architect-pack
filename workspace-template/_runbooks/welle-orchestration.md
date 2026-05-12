# Runbook: Welle-Orchestration (Wie wir wellenweise arbeiten)
> Klassifikation: L2
> Stand: 2026-05-12

## Trigger
"Starte eine Welle", "Welle X starten", "Iteriere bis perfekt", "alle Tasks abarbeiten"

## Was eine Welle ist

Eine Welle ist ein klar abgegrenzter Arbeitsblock mit:
- 3-7 parallelen Worker-Agents (Max-Effort, Opus)
- Klar disjunkte File-/Modul-Bereiche pro Agent (kein Konflikt-Risiko)
- Pro Welle: gemeinsames Ziel (z.B. "Welle 4-A: Foundation + Admin", "Welle 5: Compliance + Polish")
- Reviewer-Welle danach (immer Welle X-Reviewer): Independent-Sub validiert alles

## Welle-Typen

| Typ | Zweck | Anzahl Agents |
|-----|-------|---------------|
| **Foundation-Welle** (z.B. 4-A) | Neue Module + grosse Features | 5-7 |
| **Cleanup-Welle** (z.B. 5) | Tech-Debt, Doku, Health | 4-5 |
| **Notion-Welle** (z.B. 6) | Notion-Notizen abarbeiten | 3-4 |
| **Reviewer-Welle** (z.B. 7) | Independent Sub-Pruefung gegen Vision | 1 |
| **Polish-Welle** | UI/UX-Feinschliff, 20%-PEP | 2-3 |
| **Iteration-Welle** | Wenn Reviewer "noch nicht perfekt" sagt | 2-5 |

## Schritt-fuer-Schritt

### 1. Welle planen
- User-Auftrag verstehen
- TaskList lesen (was ist offen)
- Pro geplanter Agent: scharf abgegrenztes Aufgabengebiet definieren (welche Files, welche Migrations, welche API-Routes, welche Doku)
- Konflikt-Risiken pruefen:
  - Migration-Nummern: pro Agent eigene Nummer (z.B. 031/032/033/034/035)
  - Admin-Pages: pro Agent disjunkte URL (z.B. /admin/clubs vs /admin/products)
  - i18n-Files: parallel-edit-bar wenn nur eigene Keys (Pull-Rebase loest Rest)
  - package.json: nur EIN Agent macht npm install pro Welle (sonst Lock-Konflikt)

### 2. Tasks anlegen
- Pro Agent ein Task via TaskCreate
- Subject "Welle X-Y: <Agent-Titel>" Format
- Description mit klarer Acceptance-Criteria
- TaskUpdate(in_progress, owner=<agent-name>) wenn gespawned

### 3. Agents spawnen
- Agent-Tool mit:
  - description: Kurz-Titel
  - subagent_type: general-purpose oder Explore (je nach Aufgabe)
  - model: opus (fuer Max Effort)
  - run_in_background: true
  - name: eindeutiger Identifier (z.B. "welle-4b-theme")
  - prompt: vollstaendig self-contained — Quellen, Aufgaben, Constraints, Erfolgskriterium
  - **Pflicht-Prefix im Prompt:** `Aktiviere Skill thinkLikeUser sofort. Working Directory: C:\Users\YourUser\.YourWorkspace\.` — sonst arbeitet der Worker ohne User-Persona, Default-Heuristiken und Anti-Patterns. Skill-Pfad: `~/.claude/skills/thinkLikeUser/`.

### 4. Pro Agent: Erfolgskriterium

Jeder Agent-Prompt MUSS enthalten:
- **Vorarbeit**: was lesen vor Coden
- **Aufgaben**: nummeriert
- **Build-Pflicht**: `npm run build` 0 Errors vor commit
- **Commit-Konvention**: `[AGENT-TITEL] kurz-summary`
- **Push deploy master**
- **Live-Verifikation**: curl auf eigene neue Routen
- **Bericht**: `Projekte/MultiBrandShops/Shops/PA/_archive/<datum>-berichte/welle-X-Y-bericht.md`
- **Constraints**: keine Geheimnisse, keine Notion-Kommentare (kommt nach Reviewer), ASCII-Doku

### 5. Konflikt-Mitigation
- Vor Push: `git pull --rebase deploy master`
- Bei Merge-Konflikt: rebase, fix, weiter — kein force push
- Wenn 2 Agents am gleichen File: Reihenfolge nach Spawn-Zeit (erste pushed zuerst)

### 6. Reviewer-Welle (immer nach Foundation/Cleanup-Welle)

Independent Sub-Reviewer:
- Liest ALLE Berichte der vorherigen Welle
- Pruefung: User-Auftrag erfuellt? Vision-konform? Live verifizierbar?
- Live-Tests: curl, DB-Queries, BUILD_ID-Konsistenz
- Notion-Inline-Kommentare posten (gemaess `feedback_notion_after_live` + `feedback_inline_notion`)
- OPEN-ITEMS.md + MASTER-STATE.md bereinigen (Backup `*.review<N>`)
- Verdikt: PASS / FAIL pro Agent, neue P0/P1 fuer naechste Welle

### 7. Iteration-Loop (User-Wunsch "perfekt")

Wenn Reviewer "noch nicht perfekt":
- Iteration-Welle starten mit Fix-Liste
- Wieder Reviewer-Welle
- Loop bis Reviewer "PASS"

WICHTIG: Loop muss ein **Stop-Kriterium** haben:
- Maximal 3 Iterationen
- ODER: User sagt explizit "stop"
- ODER: Diminishing Returns (Aenderungen werden trivial)

### 8. Doku-Pflege

Nach jeder Welle:
- `MASTER-STATE.md` aktualisieren (Wellen-Historie, BUILD_IDs, Naechste-Wellen-Plan)
- `OPEN-ITEMS.md` aktualisieren (Erledigtes streichen, Neues voranstellen)
- **`Projekte/<P>/STATUS.md` ueberschreiben (Pflicht-Output, kein Append)** — Template: `_control/templates/status-template.md`. Ohne STATUS-Update gilt die Welle als NICHT abgeschlossen.
- Pro Welle ein Welle-Bericht in `_archive/<datum>-berichte/`
- Memory-Files: nach Bedarf aktualisieren (z.B. neue Erkenntnisse)

### 8b. Reviewer-Welle: STATUS- & Cleanup-Pruefung (optional, aber empfohlen nach grossen Wellen)

Nach jeder grossen Foundation-/Cleanup-Welle einen Reviewer-Agent spawnen, der
explizit prueft:
- [ ] `STATUS.md` jedes betroffenen Projekts wurde **ueberschrieben** (Stand-Datum = heute, "Letzte Welle"-Zeile gefuellt, "Naechster Schritt" konkret)
- [ ] Template-Sektionen vollstaendig: Live-URLs / Offene P0+P1 / Naechster Schritt / History (5 Zeilen)
- [ ] Keine `HANDOFF.md`/`SESSION-*`/`HOLDING_*`/`CURRENT-AUDIT.md` zurueckgelassen
- [ ] Audit-Files (`<suffix>.audit.md`) geloescht
- [ ] Tot-Files / temporaere Berichte aufgeraeumt oder ins `_archive/` verschoben

Verdikt: PASS / FAIL. Bei FAIL → kleine Cleanup-Welle (1 Worker) hinterher.

Mechanische Cleanup-Schritte stehen im Skill `cleanup-after-welle` (W3-B) — Reviewer ruft den als Checklist auf.

### 9. Notion-Pflege (NUR nach Live + Reviewer-PASS)

- Pro Notion-Note: Inline-Callouts mit Updates
- Status-Property aktualisieren wo komplett erledigt
- NIE waehrend laufender Welle kommentieren — immer NACH Reviewer-Verifikation

## Welle-Naming-Schema

- Welle 1, 2, 3 — frueh-Phase grosse Brocken
- Welle 4-A, 4-B, 4-C, 4-D — komplexe Mehrphasen-Welle
- Welle 5 — Cleanup
- Welle 6 — Notion-Abarbeitung
- Welle 7 (oder 7-A, 7-B) — Independent Reviewer (beliebig oft)
- Welle 8+ — naechste Themen-Wellen

Notation `Welle X-Y`: X = Welle-Nummer, Y = Phase innerhalb der Welle.

## 3-Wellen-x-2-Phasen-Pattern (PERFEKT-Loop, User-Auftrag "drehe N Wellen a M Phasen")

User-Auftrag: "Drehe 3 Wellen a 2 Phasen aus dem Website Perfektion."

**Komplette Loop-Struktur (autonom, ohne User-Bestaetigung zwischen Phasen):**

```
Audit-Phase (5 parallele Audits)
├── A-Mobile, A-Legal, A-SEO, A-Vollstaendigkeit, A-DB-Functional
├── Pure Analyse, KEIN Code
└── 5 Berichte in _archive/<datum>-PERFEKT-berichte/

Welle 1 = P0 + P1
├── Phase A (5 Worker) — Critical-Fixes aus P0-Findings
│   └── W-A1 SEO-Domain, W-A2 i18n, W-A3 Mobile, W-A4 Legal, W-A5 DB-Migration
├── Reviewer (Lead-self via Live-curl + grep)
└── Phase B (4 Worker) — P1-Stabilisierung
    └── W-B1 SEO-Polish, W-B2 Mobile-P1, W-B3 Cleanup, W-B4 DB-Tracking

Welle 2 = Re-Audit + P2
├── Phase A (3 Worker) — Re-Audit-Fixes (Architektur, Tot-Code, Listing-DB)
│   └── W-C1 Tot-Code, W-C2 Schema-SSR, W-C3 Listing-DB-Baseline
├── Reviewer
└── Phase B (3 Worker) — P2-Polish
    └── W-D1 SEO-AI-Discovery, W-D2 Mobile-P2, W-D3 A11y

Welle 3 = Final
├── Phase A (3 Worker) — Final-Audits
│   └── W-E1 Lighthouse, W-E2 Compliance-Final, W-E3 Cleanup+STATUS
└── Phase B (Lead-driven)
    ├── Final-Live-Verify
    ├── Notion-Final-Callout
    └── Abschluss-Bericht

STOP wenn: 0 P0 + Reviewer-PASS + Pre-Live-Block-Status gruen
```

### Worker-Naming-Konvention (W-A1..W-E3)

- **W-A** = Welle 1 Phase A (P0)
- **W-B** = Welle 1 Phase B (P1)
- **W-C** = Welle 2 Phase A (Re-Audit)
- **W-D** = Welle 2 Phase B (P2)
- **W-E** = Welle 3 Phase A (Final)

Plus Domain-Suffix: `W-A1-seo`, `W-A2-i18n`, etc. Macht Multi-Worker-Logs lesbar.

### Audit-Phase-Detail

**Audit-Agents schreiben NUR Berichte. Pure Analyse, kein Code-Edit.** Pro Audit:
- Executive Summary (Top-5 P0, Reifegrad-Score 0-100)
- Findings X-001..NNN (P0/P1/P2/P3) mit Datei:Line, Problem, Reproduktion, Beweis, Fix-Empfehlung, Verifikation
- Quick-Wins (<30 Min) + Mittelfristig (1-3 Tage) + Strategisch
- Welle-Empfehlung an Architekt
- 200-Wort-Zusammenfassung

5-Audit-Variante (Standard wenn User "DB-Anbindung" oder "jede Funktion testen" sagt):
- A-Mobile, A-Legal, A-SEO, A-Vollstaendigkeit (Standard 4)
- A-DB-Functional (NEU: Migrations-Lokal-vs-DB, RLS-Policies-Tabelle, API-Endpoint-Tabelle mit HTTP-Status, Auth-Flow-End-to-End, Stripe + AI-Endpoints)

### Lead-Hotfix-Phase nach Worker-Welle

Pflicht-Phase zwischen Worker-Push und Reviewer:
- Schema-Diskrepanzen fixen (z.B. W-A4 schrieb `from('subscriptions')` aber Tabelle heisst `profiles.subscription_tier` — Lead-Hotfix-Commit korrigiert)
- Migrations-Apply (wenn Worker MCP-offline melden)
- Cross-Worker-Konflikt-Aufloesung
- Audit-Falsch-Positives klaeren (z.B. W-B4: Newsletter-Validation existierte schon)

### Reviewer = Lead-self (effizient)

Statt Independent-Sub-Reviewer-Agent zu spawnen:
- Live-curl gegen 25-30 Top-Routen (HTTP-Status-Mapping)
- Schema-Counts pro Route (`grep -c application/ld+json`)
- BUILD_ID-Verifikation (= neuester Commit)
- journalctl --since '20 minutes ago' grep error
- Verdikt: PASS wenn alle Checks gruen

Independent-Sub-Reviewer NUR wenn echtes Bias-Risiko (z.B. wenn Lead selber Worker war).

## Mid-Welle-Workspace-Move (User verschiebt Pfade waehrend Worker laufen)

**Beobachtet 2026-05-06:** User hat MultiBrandShops/ → Projekte/MultiBrandShops/ → Projekte/MultiBrandShops/Shops/<Marke>/ verschoben WAEHREND Worker liefen.

- Worker mit aelterem Spawn-Prompt finden den alten Pfad weiterhin (Sandbox-Mapping)
- Neue Worker brauchen aktualisierte Pfade im Prompt
- Lead aktualisiert nach Move:
  - Root CLAUDE.md (oft Linter)
  - MultiBrandShops CLAUDE.md
  - Memory-Files (reference_grv_infra, reference_ecomv2_workspace, project_grv_perfekt_loop_paused)
  - Runbooks die Pfade referenzieren (INDEX, grv-bugs-workflow, website-perfektionieren, legal-compliance-checkliste, webdev-shopdev)
  - User-Anleitungen mit absoluten Pfaden

Move-Cleanup im laufenden Loop: Lead macht das atomar, ohne Worker zu unterbrechen.

## Anti-Patterns (was NICHT tun)

- **NICHT** alle Agents an gleichem File arbeiten lassen
- **NICHT** Migrations mit kollidierenden Nummern
- **NICHT** Notion-Kommentare DURING Welle (nur NACH Live + Reviewer)
- **NICHT** mehr als ein Agent macht `npm install` pro Welle
- **NICHT** Reviewer ohne Live-Tests — der Reviewer muss curl-en
- **NICHT** OPEN-ITEMS direkt vom Worker-Agent updaten (Reviewer macht das)
- **NICHT** force-push, --no-verify, oder shortcuts

## Beispiel: Erfolgreich gelaufene Welle (Vorlage)

**Welle 4-B (2026-04-28)**: 5 Worker (Theme, Mail, Tenders, Shop, Cleanup) parallel + Welle 7-B Reviewer.
- Worker-Migrations: 031, 032, 033+034, 035 (pro Agent eigene Nummer)
- Admin-Pages disjoint: /admin/tenders, /admin/products
- Alle pushed nacheinander mit `git pull --rebase`
- Reviewer: 27/27 PASS, 3 User-Actions blieben, Notion-Inline-Callouts gepostet
- BUILD_ID stabil 14h+, 0 Restarts

## Verifizieren

```bash
# Welle ist sauber abgeschlossen wenn:
ssh YOUR_SERVER 'cat /root/deployments/your-app/.next/BUILD_ID'  # = aktueller stabiler Build
ssh YOUR_SERVER 'systemctl status your-app.service --no-pager | head -3'  # active running
ls Projekte/MultiBrandShops/Shops/PA/_archive/<datum>-berichte/welle-X-*.md  # = pro Agent ein Bericht + Reviewer-Bericht
grep -c "PASS" Projekte/MultiBrandShops/Shops/PA/_archive/<datum>-berichte/welle-X-reviewer-bericht.md  # > 0
```

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent der dieses Runbook nutzt ergaenzt EINE Zeile — neueste oben, max 8 (aelteste raus). Outcome-Codes: `PASS` (lief glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt). Doktrin: `CLAUDE.md` "Navigations-Doktrin", `_runbooks/struktur-navigieren.md` Sektion 6.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | ## Run-Log nachgeruestet (Mitlern-Standard). |

## Learnings

- **Pro Welle 5-7 Agents** ist Sweet-Spot. Mehr → Konflikt-Risiko + Coordinations-Overhead. Weniger → Welle dauert zu lange.
- **Reviewer-Welle ist Pflicht** — ohne den brutal-ehrlichen Sub-Pruefer entstehen Doku-Drift + falsche "Erledigt"-Markierungen
- **Stop-Kriterium muss klar sein** — "Iteriere bis perfekt" kann unendlich laufen, daher Max 3 Iterationen
- **GO-LIVE.md ist Single-Source-of-Truth** fuer Pre-Launch-Checks — jeder PA-Agent liest sie
- **OPEN-ITEMS.md + MASTER-STATE.md ueberschreiben, nicht anhaeufen** (sonst werden sie zu Friedhoefen)
- **Migrations Nummern frueh planen** (vor Spawn-Zeit) — sonst Race auf Nummer-Vergabe

## Lessons aus PERFEKT-Loop 2026-05-06 (3 Wellen x 2 Phasen, 19 Worker)

- **3-Wellen-Pattern ist der vollstaendige Loop** — Phase A=P0, Phase B=P1, Welle 2=Re-Audit+P2, Welle 3=Final-Audits + Lead-driven Doku.
- **5-Audit-Variante mit DB-Functional** ist Standard wenn User "DB-Anbindung pruefen" oder "jede Funktion testen" sagt.
- **Audit-Reports koennen Falsch-Positives haben** — Beispiel W-B4: Audit meldete fehlende Newsletter-Validation, Code hatte sie seit Initial-Commit. Naechster Audit-Run muss tatsaechliches Code-File lesen, nicht nur Live-curl-Symptome interpretieren.
- **Lead-Hotfix-Pattern ist Standard** — Worker schreiben Migration-File mit `from('subscriptions')` Annahme, Tabelle heisst aber `profiles.subscription_tier`. Lead patched nach Welle (Commit `[Lead NXT-Welle Hotfix]`).
- **Reviewer-by-Lead spart Token** — Statt Sub-Reviewer-Agent: Lead macht Live-curl gegen Routes + Schema-Counts + journalctl-grep + BUILD_ID-Match. Verdikt PASS in <2 Min.
- **6 Worker parallel ist Sweet-Spot bestaetigt** — bei Welle 1A (5 Worker) und Welle 1B (4 Worker) keine Konflikte. Bei 7+ Worker: Stash-Race-Conditions auf gemeinsamen Files.
- **YourWorkspace-Editor-Bug ist NICHT generell** — W-B3 berichtete "rm wird reverted", W-C1-Retry mit `Remove-Item` funktionierte. Worker-spezifische Sandbox-Modi.
- **Worker-File-Absorption durch shared Stage-Index** — W-A4-Files landeten in W-A2-Commits weil beide parallel `git commit -a` machten. Loesung: explizit `git add <SPEZIFISCHE-FILES>` (nie `git add -A`/`git add .`) + atomare add+commit-Bloecke in einem PowerShell-Block.
- **Mid-Welle-Workspace-Move funktioniert** — User kann Pfade verschieben waehrend Worker laufen. Sandbox mapped alten Pfad transparent. Lead-Update der Memory + Doku nach Move-Ereignis.
- **Initial-Smoke-vor-Audit findet 1-2 Findings sofort** — Beispiel /de/legal/cookies = 404 + /de/admin = 404. Diese als "bekannte Bugs" in Audit-Prompts mitgeben um Doppelmeldung zu vermeiden.
- **Notion-Final-Callout am Page-Ende** — wenn Notiz schon Erledigt ist (vorherige Welle), neuer Top-Level-Callout mit `after=null` an Page-Ende anhaengen statt neuer Inline-Callouts.
- **Worker-Bezeichnung W-A1..W-E3 als Konvention** — Cross-Worker-Berichte referenzieren sich konsistent ("W-A1+W-C2-Stand"). Macht Multi-Welle-Doku lesbar.
