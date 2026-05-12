# Runbook: User-Anleitungen erstellen
> Klassifikation: L2
> Stand: 2026-05-12

> **Trigger:** "User-Anleitung schreiben", "Anleitung fuer Owner", "Action-Datei erstellen", "Manual-Step dokumentieren"

## Wozu

User-Anleitungen sind kurze Dateien, die genau eine User-Action dokumentieren — so dass der User sie sofort ausfuehren kann ohne Architekt-Rueckfragen. Sie sind temporaer: nach Abarbeitung loescht oder archiviert der Architekt sie.

## Wo gehoeren sie hin? (Klassifikation — Stand 2026-05-12)

| Scope | Pfad |
|-------|------|
| **Cross-projekt / System** (GitHub, Server-Hygiene, AgentOS-Infra, Workspace-weit) | `_schriftbuero/User-Anleitungen/` (Workspace-Root). Master-Liste: `MASTER-ACTIONS-YYYY-MM-DD.md` dort. |
| **Action betrifft genau eine Marke** | `Projekte/MultiBrandShops/Shops/<Marke>/_schriftbuero/User-Anleitungen/` (anlegen wenn nicht da — Pattern: PA) |
| **Action betrifft ein Nicht-Shop-Projekt** | `Projekte/<Projekt>/_schriftbuero/User-Anleitungen/` |
| **Action betrifft den Finanz-Bereich von ProjectTheta** | `Projekte/ProjectTheta/ProjectEta/_schriftbuero/User-Anleitungen/` |
| **Action betrifft AgentOS (v2/v3/OS)** | `_system/AgentOS/_schriftbuero/User-Anleitungen/` |

**Daumenregel:** Eine User-Anleitung gehoert dort hin, wo der User danach hin-springen wuerde wenn etwas nicht klappt. Im Zweifel **spezifischer als globaler** — nicht alles ins globale L1-Verzeichnis kippen (das hatte es bis 2026-05-12 unuebersichtlich gemacht).

**Konvention (seit 2026-05-12):** Jedes Projekt mit >1 offener User-Action hat eine **rolling konsolidierte Liste** `<PROJEKT>-OFFENE-TASKS.md` in seinem `_schriftbuero/User-Anleitungen/` (Pattern: `PA-OFFENE-TASKS.md`, `ProjectZeta-OFFENE-TASKS.md`, `MENTOR-OFFENE-TASKS.md`, …). Einzelne `ACT-*.md`-Detail-Anleitungen liegen daneben und werden von der `OFFENE-TASKS`-Liste verlinkt. Der globale `MASTER-ACTIONS-YYYY-MM-DD.md` haelt nur noch cross-projekt + System-Tasks + die Strategie-Entscheidungen + eine Tabelle "wo stehen die Tasks pro Projekt".

## Datei-Format (eine Action = eine Datei)

```markdown
---
typ: user-anleitung
action-id: ACT-2026-05-06-001
created: 2026-05-06
zielgruppe: Owner (User direkt)
status: offen | in-arbeit | erledigt | on-hold
aufwand: 5min | 30min | 1h | 1 Woche
cost: 0 EUR | 5 USD | 100-200 EUR
blockiert: nichts | ACT-2026-05-06-002
---

# Action: <Kurzer Titel — was MUSS Owner tun?>

## Warum
1-3 Saetze. Welcher Bug oder welche Wartung?

## Was du tust
1. Schritt 1 (mit URL/Pfad konkret)
2. Schritt 2
3. Schritt 3

## Architekt-Verifikation (intern)
- Wie pruefe ICH dass es geklappt hat? (Bash, curl, etc.)

## Falls Probleme
- Symptom 1 → Loesung
- Symptom 2 → Architekt fragen
```

## Naming-Konvention

`ACT-YYYY-MM-DD-NNN.md` mit fortlaufender Nummer pro Tag. Beispiele:
- `ACT-2026-05-06-001-resend-key-rotieren.md`
- `ACT-2026-05-06-002-supabase-redirect-urls.md`
- `ACT-2026-05-06-003-notion-webhook-secret.md`

**Vorteile:**
- Sortierung chronologisch im File-Browser
- Eindeutige Referenzen in Architekt-Berichten
- Nach Abarbeitung loeschbar ohne Konflikte

## Konsolidierte Listen (Pflicht ab 2 offenen Actions pro Projekt)

**Pro Projekt:** `<PROJEKT>-OFFENE-TASKS.md` im jeweiligen `_schriftbuero/User-Anleitungen/` — rolling (= dieselbe Datei wird ueberschrieben, nicht jede Welle eine neue). Aufbau:
- YAML-Frontmatter (`typ`, `last_updated`, `projekt`, `zielgruppe`, `quelle`)
- Prio-Bloecke (P0 → P5): pro Punkt 1-2 Saetze (warum / was du tust / wie verifizieren) + Verweis auf die Detail-`ACT-*.md` falls vorhanden
- Klare Trennung "User-Aktion" vs. "Architekt-Arbeit (zur Info)"
- Changelog-Tabelle unten
- Pattern-Goldstandard: `Projekte/MultiBrandShops/Shops/PA/_schriftbuero/User-Anleitungen/PA-OFFENE-TASKS.md`

**Cross-projekt / System:** `MASTER-ACTIONS-YYYY-MM-DD.md` im globalen `_schriftbuero/User-Anleitungen/` — neue Welle = neues File, alte ins `_archive/`. Aufbau:
- Tabelle "Wo stehen die Tasks pro Projekt" (Link zu jeder `<PROJEKT>-OFFENE-TASKS.md`)
- Nur die cross-projekt + System-Tasks selbst (GitHub, Server-Hygiene, AgentOS-Infra, …)
- Strategie-Entscheidungen-Tabelle (ID | Frage | Architekt-Default | Du)
- "Was sich seit der letzten Welle geaendert hat"-Tabelle

**Einzelne `ACT-*.md`:** weiterhin pro konkretem zeitgebundenem Stop-Punkt — liegen neben der `OFFENE-TASKS`-Liste ihres Projekts (cross-projekt: global), werden von dort verlinkt.

## Was nach Abarbeitung passiert

1. User meldet "ACT-2026-05-06-001 durch"
2. Architekt verifiziert (Bash, curl, Live-Check)
3. Bei PASS: Datei loeschen ODER nach `_archive/erledigt/` verschieben (wenn historisch wertvoll)
4. `MASTER-ACTIONS-...md` aktualisieren (`[x]` haken setzen)
5. Bei FAIL: User-Anleitung anpassen + zurueck zu User

## Was NICHT passiert

- **Keine Sammeldateien mit 50+ Items** — User scrollt nicht durch lange Listen. Lieber Master-Plan + viele kleine Files.
- **Keine Credentials in der Anleitung** — auch nicht "neu anlegen und hier eintragen". User nutzt Telegram/AgentOS fuer Geheimnisse.
- **Keine Architekt-Spekulationen** — User-Anleitungen sind Action-orientiert, nicht Diskussion.
- **Keine Anleitungen fuer Architekt-Aufgaben** — fuer interne Workflows nutze `_runbooks/`.

## Lifecycle

```
[Architekt schreibt] → [User arbeitet ab] → [User meldet erledigt]
                                         ↓
                    [Architekt verifiziert] → [PASS: Datei loeschen]
                                         ↓
                                    [FAIL: anpassen]
```

## Beispiele

### Gut: ACT-2026-05-06-001-resend-key-rotieren.md (5 Min, 1 Schritt-Block)

### Schlecht: NXT-USER-ACTIONS-2026-05-06.md (10 Actions in einer Datei, scroll-heavy)

> **Migration:** NXT-USER-ACTIONS-2026-05-06.md ist nach diesem Pattern eine Anti-Pattern-Datei. Ab 2026-05-07 nutzen wir das neue Pattern.

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent der dieses Runbook nutzt ergaenzt EINE Zeile — neueste oben, max 8 (aelteste raus). Outcome-Codes: `PASS` (lief glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt). Doktrin: `CLAUDE.md` "Navigations-Doktrin", `_runbooks/struktur-navigieren.md` Sektion 6.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | ## Run-Log nachgeruestet (Mitlern-Standard). |

## Learnings

### 2026-05-06 — Pattern eingefuehrt
Bei 30+ offenen Actions ueber 8 Projekte hat sich gezeigt: Eine Sammeldatei (NXT-USER-ACTIONS) wird unleserlich. User braucht klar abgrenzbare Files, die er einzeln durcharbeiten + abhaken kann. Master-Plan-Datei behaelt aber Ueberblick.

### Lehre: Master-Plan + Einzeldateien ist die Loesung
- Master-Plan = Tabelle ueber alle Actions, sortiert nach Block
- Einzeldateien = pro Action 1 File mit Schritten

### Lehre: Naming-Konvention ACT-YYYY-MM-DD-NNN
Datums-Nummer-Pattern erlaubt automatische Sortierung + eindeutige Referenz.

### 2026-05-12 — User-Anleitungen pro Projekt sortiert
Bis 2026-05-12 lagen ALLE aktiven User-Anleitungen (PA, ProjectEta, ProjectZeta, ProjectTheta, AgentOS, Onboarding, …) im globalen `_schriftbuero/User-Anleitungen/` — der User fand nichts mehr. Reorganisation: (1) projekt-spezifische `ACT-*.md` in `Projekte/<Projekt>/_schriftbuero/User-Anleitungen/` einsortiert (ProjectEta → `ProjectTheta/ProjectEta/`, ProjectZeta → `ProjectZeta/`, ProjectTheta-Bootstrap → `ProjectTheta/`, PA war schon dort, Onboarding → `OnboardingProject/`); (2) pro Projekt eine rolling `<PROJEKT>-OFFENE-TASKS.md` angelegt (ProjectZeta, ProjectEpsilon, your-app, ProjectGamma, ProjectTheta, AgentOS — PA hatte schon `PA-OFFENE-TASKS.md`); (3) globaler `MASTER-ACTIONS` auf cross-projekt+System reduziert + Verweis-Tabelle auf die per-Projekt-Listen; (4) STATUS.md von ProjectZeta/ProjectEta/ProjectTheta an die neuen Pfade nachgezogen; (5) globaler INDEX neu. **Lesson:** projekt-spezifisches gehoert ins Projekt-Schriftbuero, der globale Master ist nur noch der cross-projekt-Layer + Index.

### 2026-05-12 — Schriftbuero-Subfolder ohne Voll-Scaffolding ist ok
Nicht jedes Projekt braucht das volle `_schriftbuero/`-Skelett (Templates/Inbox/Briefings/…). Wenn nur User-Anleitungen anfallen, reicht `_schriftbuero/User-Anleitungen/` (+ `_archive/`). Der Rest wird nachgeruestet wenn er gebraucht wird (siehe `_runbooks/schriftbuero-erstellen.md`).
