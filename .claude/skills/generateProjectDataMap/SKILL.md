---
name: generateProjectDataMap
description: Generiert eine self-contained HTML-Visualisierung des Daten-Pipeline-Flows (Pantry/Prep/Plate) fuer ein Projekt. Aktivieren bei "Datamap erstellen", "Datenfluss visualisieren", "Pantry Prep Plate", "data_map.html generieren".
---

# Skill: generateProjectDataMap — Pantry/Prep/Plate Visualisierung

## Wann aktivieren
- "Datamap fuer <Projekt>"
- "Datenfluss-Visualisierung"
- "Pantry Prep Plate"
- "data_map.html generieren"
- Aufruf via bootstrapNewProject in Schritt 3

## Was es macht
Liest Projekt-Doku (CLAUDE.md, VISION.md, optional Brand-Context) und generiert eine self-contained `data_map.html` mit:
- **Pantry** (Roh-Daten): was kommt rein? CSVs, Mails, API-Outputs, User-Submissions
- **Prep** (Verarbeitung): Cleaning, Embeddings, Schemas, AI-Calls
- **Plate** (Output): Was geht an User/Endnutzer? Dashboards, Mails, AI-Antworten

## Step-by-Step

### Schritt 1: Quellen lesen
- `<projekt>/CLAUDE.md`
- `<projekt>/VISION.md`
- `<projekt>/PROJECT.md`
- Optional: `_control/projects/<name>/context/*.md`

### Schritt 2: Pantry/Prep/Plate-Inhalte extrahieren
Suche in den Files nach:
- "Daten-Quellen", "Inputs", "kommt rein", "API von" -> Pantry
- "Verarbeitung", "Pipeline", "wandelt", "speichert", "verarbeitet" -> Prep
- "Output", "Endnutzer sieht", "Dashboard zeigt", "Mail an User" -> Plate

Wenn nicht klar extrahierbar: User-Frage vorbereiten.

### Schritt 3: HTML generieren
Self-contained mit Inline-CSS, kein JS-Build:
- 3 Spalten (Pantry / Prep / Plate)
- Pro Spalte: Liste der Items + Beschreibung
- Verbindungslinien via SVG (oder Unicode-Pfeile)
- Footer: Stand-Datum + Generierender-Skill

Template-Basis: `_control/templates/data_map_template.html` mit Platzhaltern
`{{PROJECT_NAME}}`, `{{PANTRY_ITEMS}}`, `{{PREP_ITEMS}}`, `{{PLATE_ITEMS}}`, `{{DATE}}`.

### Schritt 4: Speichern
`_control/projects/<name>/data_map.html`

### Schritt 5: Verify
- File existiert + ist HTML-valid
- Im Browser oeffnet (User-Anweisung im Bericht: "Doppelklick auf data_map.html")

## Doktrin
- Echte Umlaute (User oeffnet im Browser, sieht die Texte)
- Self-contained: alles inline, keine externen URLs (offline-funktional)
- Mobile-friendly responsive design
- Maximal 3 Spalten — wenn mehr noetig: 2 HTMLs (Phase A / Phase B)

## Boundaries
- Generiert nur HTML, kein JSON-Datenfluss-Tool
- Niemals Live-Daten zeigen (Visualisierung der Architektur, nicht der Werte)
- Keine Credentials in HTML (auch nicht Pfade zu .env)

## Voraussetzungen
- Projekt hat CLAUDE.md (von bootstrapNewProject oder project-setup)
- Schreib-Permission auf `_control/projects/<name>/`
- Template-File `_control/templates/data_map_template.html` vorhanden
