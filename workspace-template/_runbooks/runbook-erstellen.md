# Runbook: Wie schreibe ich ein Runbook?
> Klassifikation: L2
> Stand: 2026-05-12

> **Trigger:** "neues Runbook", "Runbook schreiben", "Aufgabe wiederholt sich", "wieder das gleiche Problem", "Runbook updaten", "Runbook pflegen"

> **Vorlage:** `_control/templates/runbook-template.md` — copy-paste-Skelett mit allen Pflicht-Sektionen inkl. Run-Log + Learnings. Immer von dort starten.
> **Einordnung:** Wie Runbooks ins Gesamtsystem passen (Runbook vs. Skill vs. CLAUDE.md vs. Memory) steht in `struktur-navigieren.md`.

## Wo gehoert das Runbook hin? (Klassifikations-Pflicht)

**Bevor du EINE Zeile schreibst, beantworte diese Frage** (Details: `CLAUDE.md` Sektion "Klassifikations-Hierarchie", `VISION.md` Sektion 3):

| Trifft das Runbook auf ... zu? | Speicherort | Beispiel |
|--------------------------------|-------------|----------|
| ALLE Projekttypen (Shops, Apps, Webseiten, Server, Auto) | `_runbooks/` (L2) | `agent-initialisierung.md`, `agentos-deploy.md`, `mcp-status.md` |
| Nur Shop-Projekte (alle Marken in MultiBrandShops) | `Projekte/MultiBrandShops/_runbooks/` (L5) | `grv-bugs-workflow.md`, `cross-promo-voice.md`, `webdev-shopdev.md` |
| Nur EINE konkrete Marke / EIN Projekt | `Projekte/MultiBrandShops/Shops/<Marke>/_runbooks/` oder `Projekte/<Projekt>/_runbooks/` (L6/L7) | `Shops/BrandFive/_runbooks/walk-import.md`, `ProjectDelta/_runbooks/caddy-basicauth.md` |

**Daumenregel:** Im Zweifel SPEZIFISCHER, nicht globaler. Ein verirrtes Shop-Runbook in `_runbooks/` wuerde der ProjectDelta-Agent lesen und Shop-Konzepte halluzinieren.

## Wann brauche ich ein neues Runbook?

Schreib eins, sobald **eine Aufgabe zum zweiten Mal auftaucht**, oder wenn:
- Du eine nicht-triviale Sequenz von Befehlen ausfuehrst, die jemand anders (oder du in 4 Wochen) wiederholen muss
- Es eine bekannte Falle gibt, in die jeder reinrennt
- Eine Loesung erst nach mehreren Sackgassen klar wurde

Schreib **kein** neues Runbook fuer:
- One-Shot-Aufgaben ("delete this commit, push, done")
- Triviales (lass das CLAUDE.md / VISION.md / STATUS.md erledigen)
- Themen die schon in einem bestehenden Runbook stehen — dann **erweitere das bestehende**, nicht neu erstellen

## Der Aufbau (Pflicht-Sektionen)

Jedes Runbook hat diese Sektionen, in dieser Reihenfolge. Vollstaendiges Skelett: `_control/templates/runbook-template.md` — von dort kopieren, nicht aus dem Kopf nachbauen.

```markdown
# Runbook: [Titel]
> Klassifikation: [L2/L4/L5/L6/L7]
> Stand: [YYYY-MM-DD]

> **Trigger:** "Stichwort 1", "Stichwort 2", "konkreter Userspruch"

## Kontext (optional, max 5 Zeilen)
## Voraussetzungen (optional)
## Schritte
### 1. [Schrittname]   <- konkrete copy-paste-ready Befehle, Fallen direkt im Schritt
### 2. [Schrittname]
## Verifizieren
- [ ] Pruefbares Ergebnis 1 (mit Befehl)
## Rollback (optional)

## Run-Log          <- PFLICHT. Pflicht-Touchpoint bei jeder Nutzung. Tabelle, max 8 Zeilen, neueste oben.
## Learnings        <- PFLICHT. Date-stamped Erkenntnisse aus realen Faellen.
## Related (optional)
```

**Run-Log + Learnings sind nicht optional und nicht "nice to have"** — sie sind der Mechanismus, mit dem Runbooks ueber Zeit besser werden (siehe "Mitlern-Pflicht" unten). Ein Runbook ohne Run-Log gilt im `heartbeatWorkspace`-Scan als Drift.

## Schreib-Regeln

### Ausfuehrbar, nicht beschreibend
- Schlecht: "Du musst die Datenbank starten."
- Gut: `ssh YOUR_SERVER "systemctl start postgres-your-app"`

Code-Blocks sind copy-paste-ready. Keine Pseudo-Befehle, keine Platzhalter ohne Hinweis was reinkommt.

### Trigger-Woerter sind echte Userspruche
Nicht abstrakte Kategorien, sondern Saetze die der User wirklich sagt:
- Schlecht: "Database management"
- Gut: "Tabelle erstellen", "Migration anwenden", "warum ist die DB leer"

### Schritte sind nummeriert + atomic
Ein Schritt = eine Aktion mit pruefbarem Ergebnis. Wenn ein Schritt selbst aus 5 Sub-Steps besteht: split.

### Falsch-positive Wege erwaehnen
Wenn es eine Falle gibt (zB "git push direkt auf main schlaegt fehl, nutze stattdessen deploy remote") — schreib das in den Schritt rein, nicht erst in Learnings.

### Keine Credentials, nur Pfade
- Schlecht: `Authorization: Bearer ntn_abc123...`
- Gut: `Token in /opt/mcp-gateway/your-notion.json` oder `Token in .env: NOTION_TOKEN`

### Echte Umlaute (oe -> ö, ae -> ä, ue -> ü, ss -> ß)
Gilt fuer ALLE deutschen Texte in Runbooks, Code-Kommentaren und UI. Niemals oe/ae/ue/ss in produktivem Output.

## Wo lege ich es ab?

Pfad: `_runbooks/<kebab-case-name>.md`. Name entspricht dem Trigger:
- `mcp-register-server.md` (nicht `register-mcp-server.md`)
- `agentos-deploy.md` (nicht `deploy-agentos.md`)
- `webdev-shopdev.md` (kombiniertes Thema, kompakter Name)

## INDEX.md eintragen — Pflicht!

Nach jedem neuen Runbook in `_runbooks/INDEX.md` einen Eintrag in der passenden Sektion:

```markdown
| AgentOS Deploy | [agentos-deploy.md](agentos-deploy.md) | "AgentOS deployen", "agentos-v2 restart", "AgentOS Feature live bringen" |
```

Sektionen sind gruppiert: Server & Infrastruktur, Web & Shop, Projekt-Verwaltung, Datenbank. Falls keine passt: neue Sektion einfuegen.

## Mitlern-Pflicht — so werden Runbooks ueber Zeit besser

> Dies ist das Runbook-Pendant zu den Skill-Lern-Files (`learnings.md` / `last-output.md`). Skills haben separate Files; Runbooks tragen ihre Lern-Schicht *im Runbook selbst* — `## Run-Log` + `## Learnings`. Der Grund warum "Runbooks lernen schon mit, funktioniert aber nicht" bisher zutraf: es gab keinen erzwungenen Touchpoint. Den gibt es jetzt.

### Regel 1 — Run-Log-Zeile ist PFLICHT bei jeder Nutzung
Hast du ein Runbook ausgefuehrt, geprueft, oder beim Arbeiten gemerkt dass es ueberholt ist? -> **Bevor die Session endet:** EINE Zeile ins `## Run-Log` (neueste oben, max 8 Zeilen, aelteste raus).

```markdown
| Datum | Agent / Welle | Outcome | Notiz |
|-------|---------------|---------|-------|
| 2026-05-12 | PA-Hotfix Welle | PASS | Lief glatt, keine Aenderung. |
| 2026-05-10 | Architekt-Init | FIX | Schritt 3 Pfad war alt (`/opt/agentos/` -> `/opt/agentos/`), korrigiert. |
```

Outcome-Codes: `PASS` (glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt).

Kostet 10 Sekunden. Macht stale Runbooks im Heartbeat sichtbar (Run-Log-Top-Eintrag > 30 Tage bei aktivem Bereich = Drift-Flag). Zeigt dem naechsten Agenten ob er dem Runbook trauen kann.

### Regel 2 — Verbesserung gefunden? SOFORT updaten, nicht "spaeter"
Schnellerer Weg, besserer Befehl, undokumentierte Falle, geaenderter Pfad/Tool/API -> Schritt direkt korrigieren **und** `## Learnings`-Eintrag (`### YYYY-MM — Kurztitel` + Problem + Fix). "Spaeter" heisst nie. Der naechste Agent verlaesst sich auf den jetzigen Stand.

### Regel 3 — Learnings konkret halten
```markdown
### 2026-04 — Caddy reload statt restart
Caddy `restart` killt aktive WebSocket-Verbindungen. Nutze
`docker exec caddy caddy reload --config /etc/caddy/Caddyfile` — keine Downtime.
```
Eine praezise Zeile schlaegt einen Absatz Prosa. Bei vielen Eintraegen optional gruppieren nach **Was funktioniert** / **Anti-Patterns** / **Optimierungs-Hypothesen**.

### Regel 4 — Besser hinterlassen als vorgefunden
Jeder Agent der ein Runbook *liest oder benutzt* hat die Pflicht, es zu verbessern wenn ihm etwas auffaellt. Stimmt der Trigger nicht mehr? Fehlt ein Verifizieren-Schritt? Ist die L-Klasse falsch? -> fixen, dann erst die eigentliche Aufgabe weitermachen.

### Regel 5 — Sub-Agenten erben die Pflicht
Spawnst du Worker, die ein Runbook nutzen sollen: gib im Sub-Prompt mit "Wenn du Runbook X nutzt, ergaenze danach Run-Log + Learnings" — sonst geht die Lern-Schicht beim Delegieren verloren.

## Runbook-Qualitaets-Rubrik (Eval-Logik fuer Runbooks)

> Pendant zur `eval.json` der Skills, aber als geteilte Rubrik (28 separate eval-Files waeren Overkill). Wer ein Runbook schreibt oder reviewt, prueft gegen diese Kriterien. Heartbeat/Workspace-Audit nutzt sie als Stichprobe.

| Kriterium | Gewicht | Was "gut" heisst |
|-----------|---------|------------------|
| **Ausfuehrbarkeit** | 0.30 | Befehle copy-paste-ready, keine Platzhalter ohne Hinweis, keine Pseudo-Befehle. Ein fremder Agent kann es ohne Ruckfrage durchziehen. |
| **Aktualitaet** | 0.25 | Pfade/Tools/APIs stimmen mit dem Live-Stand. Run-Log-Top-Eintrag ist nicht uralt bei aktivem Bereich. `> Stand:` gepflegt. |
| **Verifizierbarkeit** | 0.15 | `## Verifizieren` enthaelt echte Pruef-Befehle (curl/test/git), keine Placebo-Checks. |
| **Trigger-Treffsicherheit** | 0.15 | Trigger-Woerter sind echte Userspruche, decken die gaengigen Formulierungen ab, kollidieren nicht mit anderen Runbooks. Eintrag in INDEX.md vorhanden. |
| **Lern-Pflege** | 0.15 | `## Run-Log` + `## Learnings` existieren und werden genutzt. Erkenntnisse aus Vor-Einsaetzen sind eingeflossen. |

Schwellen: **PASS >= 0.85** · **WARN >= 0.70** · darunter: Runbook ueberarbeiten oder loeschen. Summe der Gewichte = 1.0.

## Verifizieren (nach Erstellung)

- [ ] Datei in `_runbooks/<name>.md` (bzw. `Projekte/<...>/_runbooks/`) existiert
- [ ] `> Klassifikation:` + `> Stand:` Header gesetzt
- [ ] Pflicht-Sektionen vorhanden: Trigger, Schritte, Verifizieren, **Run-Log**, **Learnings**
- [ ] Run-Log hat mindestens die Erstellungs-Zeile (`| YYYY-MM-DD | (Erstellung) | META | Runbook angelegt. |`)
- [ ] Code-Blocks sind copy-paste-ready (kein Pseudo-Code)
- [ ] Eintrag in `_runbooks/INDEX.md` in passender Sektion (oder als Pointer, falls L6/L7)
- [ ] Trigger-Woerter klingen wie echte Userspruche
- [ ] Keine Credentials hardcoded, nur Pfade
- [ ] Gegen Runbook-Qualitaets-Rubrik gegengecheckt (>= 0.85)

## Run-Log

| Datum | Agent / Welle | Outcome | Notiz |
|-------|---------------|---------|-------|
| 2026-05-12 | Runbook-Mitlern-Welle | FIX | Run-Log-Pflicht + Qualitaets-Rubrik + Template-Verweis ergaenzt. Pflicht-Sektionen erweitert (Run-Log). |
| 2026-04 | (Erstellung) | META | Runbook angelegt. |

## Learnings

### 2026-05 — Runbooks brauchen einen erzwungenen Lern-Touchpoint
"Runbooks lernen schon mit" stimmte in der Theorie, nicht in der Praxis: Agents schlossen Sessions, ohne irgendwas zu hinterlassen. Fix: `## Run-Log` als Pflicht-Sektion mit 1-Zeilen-Eintrag bei jeder Nutzung — billig genug dass es passiert, sichtbar genug dass Heartbeat Drift erkennt. Skill-Aequivalent: `learnings.md`/`last-output.md`. Lehre: Eine Lern-Schicht ohne erzwungenen Schreib-Moment ist tot.

### 2026-04 — User-Anstoss zur Meta-Doku
Der User hat in der "NXT - Arbeitsweisen" Notiz explizit nach diesem Runbook gefragt
weil sich Arbeitsweisen doppelten und Agents teils Sessions ohne Runbook-Lookup starteten.
Lehre: Sobald ein Pattern dreimal auftaucht, gehoert es in ein Runbook — nicht in den
Workflow eines einzelnen Agents.

### 2026-04 — INDEX.md ist der einzige Einstiegspunkt
Agents finden Runbooks NUR ueber `_runbooks/INDEX.md`. Ein Runbook das nicht im INDEX steht,
existiert effektiv nicht. Eintrag NIE vergessen.

## Related
- Vorlage: `_control/templates/runbook-template.md`
- System-Einordnung: `_runbooks/struktur-navigieren.md` (Runbook vs. Skill vs. CLAUDE.md vs. Memory)
- INDEX: `_runbooks/INDEX.md`
- Heartbeat-Drift-Scan (prueft Run-Log-Frische): `~/.claude/skills/heartbeatWorkspace/SKILL.md` + `_runbooks/heartbeat-workspace.md`
