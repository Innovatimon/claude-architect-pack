# Runbooks — Schritt-fuer-Schritt Anleitungen fuer AI Agents

> LIES DIESEN INDEX ZUERST. Finde dein Runbook. Fuehre es aus. Fertig.
> Kein Explorieren, kein Suchen, kein "ich lese mich erstmal ein".

## Wie Runbooks funktionieren

1. User gibt Aufgabe
2. Agent liest diesen INDEX — passt ein Runbook?
3. JA → Runbook oeffnen, Schritte ausfuehren, fertig
4. NEIN → Aufgabe loesen, DANN neues Runbook schreiben (`runbook-erstellen.md`)
5. Wenn ein Runbook falsch/veraltet ist → Runbook aktualisieren (Learnings-Sektion)

## Sonderfall: Session-Initialisierung

> **Trigger "Initiiere dich" / "Session starten" / "lies dich ein" / "wo stehen wir"**
> → Pflicht-Runbook **vor jeder anderen Aktion** ist [agent-initialisierung.md](agent-initialisierung.md).

## Runbook-Format

Jedes Runbook hat:
- **Klassifikation:** Header-Marker (L2 Global / L4 System / L5 Framework / L6 Brand / L7 Projekt)
- **Trigger:** Wann wird dieses Runbook benoetigt?
- **Schritte:** Nummerierte Befehle, copy-paste-ready
- **Verifizieren:** Wie pruefe ich ob es geklappt hat?
- **Learnings:** Was haben vorherige Agents gelernt?

## L-Klassifikation

Vollstaendige Hierarchie-Definition siehe `CLAUDE.md` Sektion "Klassifikations-Hierarchie".

---

## L2 — Global (gilt fuer alle Projekttypen)

### Projekt-Verwaltung & Agent-Setup

| Runbook | Datei | Trigger-Woerter |
|---------|-------|-----------------|
| **Agent-Initialisierung** (Session-Setup) | [agent-initialisierung.md](agent-initialisierung.md) | "Initiiere dich", "Session starten", "lies dich ein", "wo stehen wir", "uebernimm die Architekten-Rolle" |
| Runbook erstellen | [runbook-erstellen.md](runbook-erstellen.md) | "neues Runbook", "Runbook schreiben", "Aufgabe wiederholt sich" |
| User-Anleitung erstellen | [user-anleitungen-erstellen.md](user-anleitungen-erstellen.md) | "User-Anleitung schreiben", "Action-Datei erstellen", "Manual-Step dokumentieren" |
| Welle-Orchestration | [welle-orchestration.md](welle-orchestration.md) | "Welle starten", "Iteriere bis perfekt", "alle Tasks abarbeiten", "Agenten-Team auf Max Effort" |
| Neues Projekt erstellen | [neues-projekt-erstellen.md](neues-projekt-erstellen.md) | "neues Projekt", "Projekt anlegen", "bootstrappen", "leg X als Projekt an" |
| Schriftbuero anlegen | [schriftbuero-erstellen.md](schriftbuero-erstellen.md) | "Schriftbuero anlegen", "User-Kommunikations-Layer", "Inbox + Briefings" |
| Schriftbuero konsolidieren | [schriftbuero-konsolidieren.md](schriftbuero-konsolidieren.md) | "Schriftbuero aufraeumen", "Inbox archivieren", "Stand-Snapshot erstellen" |
| Multi-Worker Coordination | [multi-worker-coordination.md](multi-worker-coordination.md) | "parallele Worker", "Welle mit N Agents", "git-Konflikt zwischen Workern", "Stash-Race" |
| Memory-Pflege | [memory-pflege.md](memory-pflege.md) | "Memory aufraeumen", "Stale Memory loeschen", "Memory pflegen", "MEMORY.md syncen" |
| Workspace-Audit (Multi-Agent-Discovery) | [workspace-audit.md](workspace-audit.md) | "Workspace auditieren", "Architektur pruefen", "Doku-Konsistenz", "Drift-Check" |
| Arbeitsweise externe Aufgaben-Quelle | [arbeitsweise-notion.md](arbeitsweise-notion.md) | "Notion abarbeiten", "Linear-Tickets durcharbeiten", "Inbox-Welle starten" |
| File-Operations (Windows) | [file-operations-windows.md](file-operations-windows.md) | "Permission denied bei mv", "robocopy", "Datei nicht verschiebbar", "Move-Item geht nicht" |

---

## Hinweis fuer projekt-spezifische Runbooks

Sobald du projekt-spezifische Runbooks brauchst (Server-Deploy, DB-Migration,
Marken-Workflow), lege sie in einem entsprechenden Sub-Pfad ab:

- **L4 (Eigenes System):** `_runbooks/` mit Klassifikations-Header `> L4`
- **L5 (Framework / Group):** `Projekte/<group>/_runbooks/`
- **L6 (Brand):** `Projekte/<group>/Sub/<brand>/_runbooks/`
- **L7 (Einzel-Projekt):** `Projekte/<projekt>/_runbooks/`

In dieser INDEX nur als Pointer fuehren (1 Zeile mit Link), nicht duplizieren.

---

> **Kein Runbook fuer deine Aufgabe?** Aufgabe trotzdem loesen, dann Runbook erstellen, korrekte L-Klasse setzen, und hier eintragen.

## Wo liegt was? (Schnell-Referenz fuer Agents)

| Was | Wo |
|-----|-----|
| User-Anpassungen / Persoenliches Profil | `CLAUDE.user.md` |
| Server-Zugangsdaten (nur Pfade) | `_control/credentials-map.md` (user_owned) |
| Server-Konfiguration, Domains, Docker | `_control/server-config.md` (user_owned) |
| Audit-Template | `_control/templates/audit-template.md` |
| Status-Template | `_control/templates/status-template.md` |
| Projekt-Status-Dateien | `_control/projects/<name>.md` (user_owned) |
| Skill-Definitionen | `~/.claude/skills/<name>/SKILL.md` |
