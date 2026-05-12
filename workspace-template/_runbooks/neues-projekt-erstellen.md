# Runbook: Neues Projekt erstellen
> Klassifikation: L2
> Stand: 2026-05-12

> **Trigger:** "neues Projekt", "Projekt anlegen", "bootstrappen", "wir machen ein neues Ding", "leg <X> als Projekt an"

## Kontext

Im YourWorkspace bekommt jedes neue Projekt eine standardisierte Struktur
mit 5 Kern-Dateien (CLAUDE.md, VISION.md, STATUS.md, PROJECT.md, SETUP.md), wird
in der Root-`CLAUDE.md`-Tabelle eingetragen und (optional) in der Memory verewigt.
Dieses Runbook beschreibt die Schritte fuer Architekt + Worker.

## Schritte

### 1. Klassifikation festlegen (Anti-Halluzinations-Pflicht)

Bevor du eine Zeile schreibst, beantworte:

| Wo? | Wann? | Pfad |
|-----|-------|------|
| **L5 — Shop-Framework** | Es ist ein Shop in MultiBrandShops | `Projekte/MultiBrandShops/Shops/<Marke>/` |
| **L7 — Nicht-Shop** | Es ist ein eigenstaendiges Projekt (App, Roboter, Server, Webseite, ProjectDelta-Domaene) | `Projekte/<Projekt>/` oder als Sub-Projekt unter einem L7-Eltern (`Projekte/ProjectZeta/ProjectEpsilon/`) |

Im Zweifel **spezifischer**, nicht globaler. Details: Workspace-Root `CLAUDE.md`
Klassifikations-Hierarchie und `VISION.md` Sektion 3.

### 2. Verzeichnis anlegen

```powershell
# Windows / PowerShell
$base = "C:\Users\YourUser\.YourWorkspace\Projekte\<Projekt-Pfad>"
New-Item -ItemType Directory -Force -Path $base | Out-Null
```

```bash
# Unix
mkdir -p "Projekte/<Projekt-Pfad>"
```

### 3. Pflicht-Files schreiben

Alle 5 Files sind Pflicht. Nutze die Vorlagen aus dem
`project-setup`-Skill (`~/.claude/skills/project-setup/SKILL.md`) oder schreibe
sie nach folgendem Minimal-Aufbau:

#### CLAUDE.md (Briefing fuer alle Agenten in diesem Projekt)

```markdown
# <Projekt-Name>

> **L<N>-Boundary (siehe Workspace-Root `CLAUDE.md`):** Dieses Projekt liest
> NUR <welche Verzeichnisse>. Es fasst <welche fremden Verzeichnisse> NICHT an.

<1-3 Saetze: Was ist das Projekt?>

## Docs lesen
- `PROJECT.md` — Was ist das, Stakeholder, Hardware/Stack
- `VISION.md` — Wo wollen wir hin (V1 / V2 / V3)
- `STATUS.md` — Aktueller Stand
- `SETUP.md` — Erstinbetriebnahme

## Zugang
<SSH, App-Logins, Credentials-Pfade — KEINE Klartext-Werte>

## Modus 1: Worker — `<suffix>.audit.md` finden, abarbeiten, STATUS.md ueberschreiben, Audit loeschen
## Modus 2: Architekt — VISION.md + STATUS.md lesen, naechstes Audit schreiben
```

#### VISION.md
- Langfrist-Ziel (1-2 Saetze)
- V1 / V2 / V3 in der Detailtiefe nach Bedarf
- Subprojekte-Tabelle (Feature, Status, Prio)
- Klassifikations-Tabelle (welcher Aspekt wo gehoert)
- Boundaries (was die Vision **nicht** regelt)

#### STATUS.md
- Stand-Datum
- Was bisher geschehen ist
- Was funktioniert
- Was NICHT funktioniert / blockiert ist
- Naechste Schritte
- Risiko-Watchlist
- Letzte Aenderung
- Update-Pflicht (immer ueberschreiben, nicht anhaengen)

> **STATUS-Pflicht (global):** Nach jeder Welle MUSS `STATUS.md` ueberschrieben
> werden — kein Append, kein HANDOFF.md, kein SESSION-*. Template:
> `_control/templates/status-template.md` (Pflicht-Sektionen: Letzte Welle /
> Live-URLs / Offene Bugs / Naechster Schritt). Git Log ist das Archiv.

#### PROJECT.md
- Was ist das Projekt
- Stakeholder-Tabelle
- Hardware/Stack-Tabelle
- Erfolgskriterien V1
- Erfolgskriterien V2
- Risiken
- Was es **nicht** ist
- Beziehung zu anderen Projekten

#### SETUP.md
- Voraussetzungen (Hard- + Software, Netzwerk)
- Erst-Inbetriebnahme (Schritte, ggf. TBD bis Hardware da)
- Geplante Verzeichnisstruktur
- Credentials-Tabelle (nur Pfade!)
- Sicherheits-Hinweise
- Naechste Update-Trigger

### 4. Optional: Schriftbuero anlegen

Wenn das Projekt **lange laufen wird** und **viel User-Input + Uploads** braucht
(z.B. Persona-Specs, PDFs, Server-Logs, Foto-Material), lege ein eigenes
Schriftbuero an. Nutze dafuer:

```
_runbooks/schriftbuero-erstellen.md
```

Bei kurzen oder sehr technischen Projekten reicht der Chat — kein Schriftbuero
noetig.

### 5. Optional: GitHub-Repo anlegen

Falls Code involviert: GitHub-Repo unter Account `YOUR_GITHUB_USER` erstellen.
Schritte: `gh repo create YOUR_GITHUB_USER/<repo-name> --public|--private --source=. --remote=origin --push`.

Bei Server-Deploy-Hooks: zusaetzlich Bare-Repo auf YOUR_SERVER anlegen
(`/root/git/<name>.git`) und Deploy-Hook in `.git/hooks/post-receive`. Pattern
siehe `Projekte/ProjectZeta/ProjectEpsilon/CLAUDE.md` und `Projekte/ProjectDelta/CLAUDE.md`.

### 6. Workspace-Root-CLAUDE.md updaten

In der Projekt-Tabelle eintragen:

```markdown
| <Projekt-Name> | <Pfad> | <1-Satz-Beschreibung> | AKTIV \| INAKTIV \| BLOCKIERT |
```

### 7. Optional: Memory-Eintrag schreiben

Wenn das Projekt eine **infrastrukturelle Eigenheit** hat, die der naechste
Agent kennen muss (z.B. besondere Server-Pfade, ungewoehnliche Tooling-Wahl),
lege eine Reference-Memory an:

```
~/.claude/projects/<workspace-id>/memory/reference_<projekt>_infra.md
```

Eintrag in `MEMORY.md` ergaenzen. Siehe Memory-System-Doku in der
Workspace-Root `CLAUDE.md`.

### 8. Optional: Cloud Scheduled Task

Wenn das Projekt regelmaessig autonom etwas tun soll (Tagging, Healthchecks,
Reports): Skill `schedule` oder `/loop` nutzen. Max. 5x Plan: 3 Tasks/Tag, 1h Minimum.
Verwaltung: https://claude.ai/code/scheduled.

## Verifizieren

- [ ] Projekt-Verzeichnis existiert
- [ ] Alle 5 Pflicht-Files sind da (`CLAUDE.md`, `VISION.md`, `STATUS.md`, `PROJECT.md`, `SETUP.md`)
- [ ] CLAUDE.md hat L-Boundary-Hinweis korrekt fuer die Klassifikations-Ebene
- [ ] STATUS.md hat Update-Pflicht-Hinweis und ist nicht chronologisch
- [ ] Workspace-Root-CLAUDE.md hat den neuen Eintrag in der Projekt-Tabelle
- [ ] Wenn Schriftbuero noetig: angelegt und in CLAUDE.md des Projekts erwaehnt
- [ ] Wenn Code: GitHub-Repo + ggf. Bare-Repo + Deploy-Hook bestehen
- [ ] Wenn Server-Pfade besonders: Memory-Eintrag in MEMORY.md verlinkt
- [ ] Keine Klartext-Credentials in irgendeinem File

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent der dieses Runbook nutzt ergaenzt EINE Zeile — neueste oben, max 8 (aelteste raus). Outcome-Codes: `PASS` (lief glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt). Doktrin: `CLAUDE.md` "Navigations-Doktrin", `_runbooks/struktur-navigieren.md` Sektion 6.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | ## Run-Log nachgeruestet (Mitlern-Standard). |

## Learnings

### Mai 2026 — ProjectEpsilon Erst-Anwendung
- Sub-Projekte (ProjectEpsilon unter Projekte/ProjectZeta/) sind L7 wie ihre Eltern, aber haben
  eigene CLAUDE.md mit explizitem Verweis auf Eltern-Verzeichnis als read-only-Quelle.
- Schriftbuero ist NICHT Standard — nur bei "viel User-Input + Uploads" sinnvoll.
  Bei Kurz-Projekten lass es weg.
- 5 Files sind das Minimum. Ein VISION.md ohne Subprojekte-Tabelle ist okay
  fuer kleine Projekte; ein VISION.md ohne V1-Erfolgskriterien ist NICHT okay.
- Wenn das Projekt ein Sub-Projekt ist: explizit klaeren ob das Eltern-Projekt
  einen eigenen `_runbooks/`-Ordner braucht oder ob globale L2-Runbooks reichen.
