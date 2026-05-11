# MASTER AUDIT: [ID] — [Titel]

> Agent: Claude Code (im [ordner]/ Ordner oeffnen)
> Suffix: [name].audit.md
> Erstellt: YYYY-MM-DD
> Erstellt-von: [Architekt | Orchestrator | <agent-name>]

## [MISSION OBJECTIVE]

> Was am Ende existieren / funktionieren MUSS. Konkret, messbar.

- Konkretes Ergebnis 1 (z.B. "Route `/api/widgets` antwortet 200 mit gueltigem JSON")
- Konkretes Ergebnis 2
- Konkretes Ergebnis 3

## [PHASEN-EXEKUTION]

### Phase 1: <Name>

**Was:** <Kurz-Beschreibung>

**Schritte:**
1. <Schritt mit copy-paste-Befehl oder Datei-Pfad>
2. <Schritt>
3. <Schritt>

**Erfolgskriterium Phase 1:**
- [ ] <Pruefbares Ergebnis>

### Phase 2: <Name>
...

## [THE ARCHITECT'S PRIDE]

> Qualitaetsansprueche. Was NICHT akzeptabel ist.

- **NICHT akzeptabel:** <Anti-Muster 1>
- **NICHT akzeptabel:** <Anti-Muster 2>
- **Best Practice:** <Konvention die einzuhalten ist>
- **Performance:** <Schwellen die nicht ueberschritten werden duerfen>

## [THE CRUCIBLE]

> Bash / curl / Test-Skripte die PASS / FAIL anzeigen. Copy-paste-ready.

```bash
# Test 1: Build erfolgreich
<build-command>
# erwartet: exit 0, keine Errors

# Test 2: Route 200
curl -sL -o /dev/null -w 'HTTP %{http_code}\n' <url>
# erwartet: HTTP 200

# Test 3: ...
```

**Alle Tests muessen PASS sein vor Commit.**

## [DEPLOYMENT & HANDOFF]

### Git Commit

```bash
git add <SPEZIFISCHE-FILES>   # nicht "git add -A"
git commit -m "<feat|fix|refactor>: <kurz-summary>

<optional body>
"
```

### STATUS.md ueberschreiben

```
<projekt>/STATUS.md
```

Template: `_control/templates/status-template.md`. Pflicht-Sektionen:
- Stand
- Letzte Welle
- Live-URLs / Endpoints
- Offene P0/P1
- Naechster Schritt
- History

### Audit-File loeschen

```bash
rm <projekt>/<id>.audit.md
```

### Optional: Externe Quelle aktualisieren

Wenn aus Notion/Linear/Issue gekommen, **NUR nach Reviewer-PASS**:
- Status auf "Erledigt"
- Inline-Outcome-Kommentar mit Commit-Hash + Live-URL

---

> Audit-File loeschen ist Pflicht. Git-Log ist das Archiv.
