# Runbook: Wie schreibe ich ein Runbook?
> Klassifikation: L2

> **Trigger:** "neues Runbook", "Runbook schreiben", "Aufgabe wiederholt sich", "wieder das gleiche Problem"

## Wo gehoert das Runbook hin? (Klassifikations-Pflicht)

**Bevor du EINE Zeile schreibst, beantworte diese Frage** (Details: `CLAUDE.md` Sektion "Klassifikations-Hierarchie"):

| Trifft das Runbook auf ... zu? | Speicherort | Beispiel |
|--------------------------------|-------------|----------|
| ALLE Projekttypen (Shops, Apps, Webseiten, Server) | `_runbooks/` (L2) | `agent-initialisierung.md`, `welle-orchestration.md` |
| Nur Group-Projekte (z.B. alle Marken einer Multi-Brand-Plattform) | `Projekte/<group>/_runbooks/` (L5) | brand-spezifische gemeinsame Workflows |
| Nur EINE konkrete Brand / EIN Projekt | `Projekte/<group>/Sub/<brand>/_runbooks/` oder `Projekte/<projekt>/_runbooks/` (L6/L7) | spezielle Deploy-Schritte |

**Daumenregel:** Im Zweifel SPEZIFISCHER, nicht globaler. Ein verirrtes Sub-Runbook in `_runbooks/` wuerde der falsche Agent lesen und Konzepte halluzinieren die nicht zu seinem Projekt gehoeren.

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

Jedes Runbook hat genau diese Sektionen, in dieser Reihenfolge:

```markdown
# Runbook: [Titel]
> Klassifikation: L<N>

> **Trigger:** "Stichwort 1", "Stichwort 2", "konkreter Userspruch"

## Kontext (optional, max 5 Zeilen)
Was ist dieses Ding? Warum existiert es? Nur falls nicht selbsterklaerend.

## Schritte
### 1. [Schrittname]
Konkrete Befehle (copy-paste-ready) oder ein klares "tu X".

### 2. [Schrittname]
...

## Verifizieren
- [ ] Pruefbares Ergebnis 1
- [ ] Pruefbares Ergebnis 2

## Learnings
Erkenntnisse aus realen Faellen. **Datum + Was war das Problem + Was hat geholfen.**
```

## Schreib-Regeln

### Ausfuehrbar, nicht beschreibend
- Schlecht: "Du musst die Datenbank starten."
- Gut: `ssh <host> "systemctl start postgres"`

Code-Blocks sind copy-paste-ready. Keine Pseudo-Befehle, keine Platzhalter ohne Hinweis was reinkommt.

### Trigger-Woerter sind echte Userspruche
Nicht abstrakte Kategorien, sondern Saetze die der User wirklich sagt:
- Schlecht: "Database management"
- Gut: "Tabelle erstellen", "Migration anwenden", "warum ist die DB leer"

### Schritte sind nummeriert + atomic
Ein Schritt = eine Aktion mit pruefbarem Ergebnis. Wenn ein Schritt selbst aus 5 Sub-Steps besteht: split.

### Falsch-positive Wege erwaehnen
Wenn es eine Falle gibt (z.B. "git push direkt auf main schlaegt fehl, nutze stattdessen deploy remote") — schreib das in den Schritt rein, nicht erst in Learnings.

### Keine Credentials, nur Pfade
- Schlecht: `Authorization: Bearer ntn_abc123...`
- Gut: `Token in <pfad-zu-credentials-store>` oder `Token in .env: NOTION_TOKEN`

### Echte Umlaute (oe -> ö, ae -> ä, ue -> ü, ss -> ß)
Gilt fuer ALLE deutschen Texte in UI-Strings, Mail-Templates. ASCII (oe/ae/ue/ss) ist OK in interner Agent-Doku — siehe CLAUDE.md "Umlaut-Pflicht".

## Wo lege ich es ab?

Pfad: `_runbooks/<kebab-case-name>.md` (oder Sub-Pfad gemaess L-Klassifikation). Name entspricht dem Trigger:
- `mcp-register-server.md` (nicht `register-mcp-server.md`)
- `webdev-shopdev.md` (kombiniertes Thema, kompakter Name)

## INDEX.md eintragen — Pflicht!

Nach jedem neuen Runbook in `_runbooks/INDEX.md` einen Eintrag in der passenden Sektion:

```markdown
| Caddy reload | [caddy-reload.md](caddy-reload.md) | "Caddy neu laden", "Caddyfile aenderung aktivieren" |
```

Sektionen sind gruppiert nach Themen. Falls keine passt: neue Sektion einfuegen.

## Pflege-Regeln (das macht Runbooks ueber Zeit besser)

### 1. Verbesserung gefunden? Updaten, nicht ignorieren.
Du hast einen schnelleren Weg gefunden? Einen besseren Befehl? Eine Falle die nicht dokumentiert war? → Update das Runbook DIREKT, nicht "spaeter".

### 2. Fehler im Runbook? Fixen, nicht umgehen.
Wenn ein Schritt nicht mehr stimmt (Pfad geaendert, Tool ersetzt, API umgestellt): Korrigiere ihn. Der naechste Agent verlaesst sich darauf.

### 3. Learnings-Sektion fuettern
Nach realen Einsaetzen: Datum + Problem + Fix in `## Learnings`.

### 4. Hinterlasse das Runbook besser als du es vorgefunden hast
Jeder Agent der ein Runbook liest oder benutzt, hat die Pflicht es zu verbessern wenn ihm etwas auffaellt.

## Verifizieren (nach Erstellung)

- [ ] Datei in `_runbooks/<name>.md` existiert (oder im Sub-Pfad)
- [ ] Klassifikations-Header `> L<N>` vorhanden
- [ ] Pflicht-Sektionen vorhanden: Trigger, Schritte, Verifizieren, Learnings
- [ ] Code-Blocks sind copy-paste-ready (kein Pseudo-Code)
- [ ] Eintrag in `_runbooks/INDEX.md` in passender Sektion (oder Sub-INDEX bei L5+)
- [ ] Trigger-Woerter klingen wie echte Userspruche
- [ ] Keine Credentials hardcoded, nur Pfade

## Learnings

### Sobald ein Pattern 3x auftaucht, gehoert es in ein Runbook
Lehre aus mehreren Sessions: wenn dieselbe Sequenz dreimal abgespielt wird, ohne Runbook werden Schritte vergessen, Reihenfolge variiert, Fallen wiederholt.

### INDEX.md ist der einzige Einstiegspunkt
Agents finden Runbooks NUR ueber `_runbooks/INDEX.md`. Ein Runbook das nicht im INDEX steht, existiert effektiv nicht. Eintrag NIE vergessen.
