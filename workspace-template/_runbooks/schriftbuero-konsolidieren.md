# Runbook: Schriftbuero konsolidieren
> Klassifikation: L2

> **Trigger:** "Schriftbuero aufraeumen", "Inbox archivieren", "Stand-Snapshot erstellen", "Schriftbuero konsolidieren"

## Wann konsolidieren?

- Nach jeder grossen Welle (`cleanup-after-welle` Skill triggert das automatisch)
- Wenn `Inbox/` > 20 Files hat
- Wenn `Briefings/` > 5 Files hat (max 3 aktive)
- Vor Session-Ende (Snapshot fuer naechste Session)
- Periodisch (z.B. einmal pro Woche)

## Schritt-fuer-Schritt

### 1. Stand erfassen

```bash
SB="<schriftbuero-pfad>"
echo "=== Inbox ==="; ls -la "$SB/Inbox/" 2>/dev/null | wc -l
echo "=== Briefings ==="; ls -la "$SB/Briefings/" 2>/dev/null | wc -l
echo "=== Antworten ==="; ls -la "$SB/Antworten/" 2>/dev/null | wc -l
echo "=== User-Anleitungen ==="; ls "$SB/User-Anleitungen/" 2>/dev/null
```

### 2. Inbox archivieren (Files aelter 4 Wochen)

```bash
ARCHIVE="$SB/_archive/$(date +%Y-%m-%d)/Inbox"
mkdir -p "$ARCHIVE"
find "$SB/Inbox" -type f -mtime +28 -exec mv {} "$ARCHIVE/" \;
```

### 3. Briefings konsolidieren

- Pro Briefing: pruefen ob in einem `STATUS.md` referenziert oder weiter relevant
- Behalte max die 3 neuesten in `Briefings/`
- Aeltere in `_archive/<datum>/Briefings/`

### 4. Antworten archivieren (mit Cleanup-Pruefung)

Pro `Antworten/*.md` mit Status "verstanden":
1. **Body-Scan vor Archivierung:** Inline-Folge-Wuensche?
   - `---USER:---` Bloecke pruefen
   - Wenn neue Anweisungen drin -> NEUE Action-Datei anlegen (siehe `user-anleitungen-erstellen.md`)
   - **Erst dann archivieren.**
2. `mv "$SB/Antworten/<file>.md" "$SB/_archive/<datum>/Antworten/"`

### 5. User-Anleitungen mit Status "Erledigt"

Pro ACT-File mit Status "Erledigt":
1. **Body-Scan:** Inline-Folge-Wuensche -> neue ACT-Datei
2. Eintrag in `MASTER-ACTIONS.md` auf "Erledigt"
3. File-Body bleibt — beim naechsten Konsolidieren ins `_archive/` verschieben
4. (Optional sofort: `mv "$SB/User-Anleitungen/<file>.md" "$SB/_archive/<datum>/User-Anleitungen/"`)

### 6. INDEX-Phantom-Check

Jede Referenz in `MASTER-ACTIONS.md` und in `README.md` via Glob verifizieren:
- Referenziertes File existiert? Ja -> behalten
- Nein -> Phantom-Verweis, aus Index streichen

### 7. Kontinuitaet aktualisieren (optional)

Wenn die Konsolidierung am Session-Ende lauft:
- `Kontinuitaet/INITIATOR-<datum>.md` anlegen oder updaten
- Zusammenfassung: was wurde gemacht, was offen, naechste Schritte
- Verweis auf alle aktiven ACT-Files

### 8. Git commit

```bash
git add "$SB"
git commit -m "schriftbuero: konsolidieren $(date +%Y-%m-%d)"
```

### 9. Kurz-Bericht im Chat (max 6 Zeilen)

```
Schriftbuero konsolidiert:
- Inbox: <N_alt> -> <N_neu> (<M> archiviert)
- Briefings: <N_alt> -> <N_neu>
- Antworten archiviert: <N>
- Neue Folge-ACTs aus Inline-Wuenschen: <N>
- Phantom-Verweise gestrichen: <N>
- Git: <commit-hash>
```

## Boundaries

- Niemals Hard-Delete — alles ins `_archive/`. Git-Log macht den Rest.
- Niemals "Erledigt"-Markierungen schlucken — Body-Scan ist Pflicht.
- L6-Isolation: bei Multi-Projekt-Workspace nicht quer in andere Projekt-Schriftbueros greifen.

## Verifizieren

- [ ] `Inbox/` enthaelt keine Files > 4 Wochen
- [ ] `Briefings/` enthaelt max 3 Files
- [ ] `Antworten/` enthaelt nur unverstandene
- [ ] `MASTER-ACTIONS.md` Eintraege haben gueltige File-Pfade
- [ ] `_archive/<datum>/` enthaelt verschobene Files
- [ ] Kurz-Bericht gepostet
- [ ] git commit erfolgt

## Learnings

### Body-Scan-Pflicht
Eine "Erledigt"-Markierung kann versteckte Folge-Anweisungen enthalten. Ohne Body-Scan beim Archivieren gehen sie verloren. Bei Konsolidierung 2026-05-11 wurden 2 Wuensche gerettet die sonst geloescht worden waeren.

### 4-Wochen-Grenze fuer Inbox
Kuerzer = User-Uploads gehen frueh verloren. Laenger = Inbox-Friedhof. 4 Wochen ist Sweet-Spot.

### Phantom-Verweise sind toxisch
Wenn `MASTER-ACTIONS.md` auf Files verweist die nicht mehr existieren, glaubt der naechste Agent es gaebe Arbeit die es nicht gibt. Check ist nicht optional.
