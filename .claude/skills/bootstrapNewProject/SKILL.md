---
name: bootstrapNewProject
description: Interview-basiertes Bootstrap fuer neue Projekte. Aktivieren bei "neues Projekt bootstrappen", "Projekt von Null aufsetzen", "Bootstrap-Interview", "/silver-platter". Generiert 5 Pflicht-Files + Brand-Context-Folder + erste Runbooks + data_map.html aus User-Antworten.
---

# Skill: bootstrapNewProject — Interview-basiertes Projekt-Bootstrapping

## Wann aktivieren
- "neues Projekt bootstrappen"
- "Projekt von Null aufsetzen"
- "/silver-platter" oder "silver platter"
- "Bootstrap-Interview starten"
- Wenn User ein neues Projekt erwaehnt aber kein Ordner existiert

## Worin ich mich vom alten `project-setup` unterscheide
- `project-setup` legt nur 5 leere Pflicht-Files an
- `bootstrapNewProject` interviewt strukturiert + generiert mit echtem Inhalt + Brand-Context + erste Runbooks + Daten-Map

## Step-by-Step

### Schritt 1: Klassifikations-Frage
Frage User: "L5-Shop (MultiBrandShops-Marke) oder L7 (eigenstaendiges Projekt)?"

### Schritt 2: 8-Frage-Interview
Frage strukturiert ab und sammle Antworten:
1. **Was ist das Projekt in 1 Satz?**
2. **Welche Tools/APIs/Plattformen?** (Auflistung)
3. **Wer sind die Stakeholder?** (Owner, User-Typen, externe Partner)
4. **Welche Daten fliessen rein?** (Pantry — Roh-Daten)
5. **Was wird damit gemacht?** (Prep — Verarbeitung)
6. **Welcher Output entsteht?** (Plate — was an User/Endnutzer geht)
7. **Was ist der Erfolg in 30 Tagen?** (messbares Ziel)
8. **Welche Stop-Punkte erwartet ihr?** (Credentials, Genehmigungen)

### Schritt 3: Generiere Projekt-Struktur
Aus Antworten:
- Ordner anlegen
- 5 Pflicht-Files erstellen (CLAUDE.md, VISION.md, STATUS.md, PROJECT.md, SETUP.md) MIT INHALT aus Interview
- **In generierter CLAUDE.md eine Sektion "Persona-Aktivierung (PFLICHT)"** ergaenzen — wenn das Projekt eine spezifische Persona hat (z.B. ProjectEta mit Famous-Coach-Persona), Pattern aus `Projekte/ProjectEta/CLAUDE.md` uebernehmen. Wenn nicht: Standard-Block `Sub-Agents in diesem Projekt aktivieren Skill thinkLikeUser sofort (Pfad: ~/.claude/skills/thinkLikeUser/).`
- `context/`-Ordner: voice.md, positioning.md, icp.md, samples.md (initial mit "TODO: User klaeren" wenn Antworten unklar)
- `data_map.html` generieren (Pantry/Prep/Plate-Visualisierung)
- Erstes Runbook in `_runbooks/` (Pfad je nach L-Klasse)

### Schritt 4: Root-CLAUDE.md updaten
Neuen Projekt-Eintrag in Master-Tabelle einfuegen.

### Schritt 5: Memory-Eintrag
`project_<name>.md` in Memory anlegen + MEMORY.md-Index updaten.

### Schritt 6: Status-Antwort
Zusammenfassung was erstellt wurde + naechste Schritte.

## Ablage von Skill-Output
- L5: `Projekte/MultiBrandShops/Shops/<Marke>/`
- L7: `Projekte/<Projekt>/`
- Brand-Context: `_control/projects/<name>/context/`
- Datamap: `_control/projects/<name>/data_map.html`
- Erstes Runbook: passend zu L-Klasse

## Doktrin
- Echte Umlaute in 5-Pflicht-Files (User-facing)
- ASCII in Memory + Runbook (interne Agent-Doku)
- Bei unklaren Antworten: "TODO: User klaeren — <Frage>" einfuegen, nicht raten
- Live-Verifikation am Ende: 5-Pflicht-Files lesbar, Daten-Map oeffnet im Browser

## Boundaries
- Niemals bestehende Projekte ueberschreiben (immer pruefen ob Ordner existiert)
- Niemals Code generieren (nur Doku-Struktur)
- Niemals Server-Resources allozieren (nur lokal)
- Niemals git init/push (das macht User wenn Doku stabil ist)

## Voraussetzungen
- Working Directory ist `C:\Users\YourUser\.YourWorkspace\`
- TaskCreate-Tool fuer Fortschritt
- Read/Write/Edit-Tools
- Skill `generateProjectDataMap` verfuegbar (fuer Schritt 3 data_map.html)
