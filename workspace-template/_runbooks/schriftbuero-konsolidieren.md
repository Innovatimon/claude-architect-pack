# Runbook: Schriftbuero konsolidieren
> Klassifikation: L2
> Stand: 2026-05-12

> **Trigger:** "Schriftbuero aufraeumen", "Inbox archivieren", "Stand-Snapshot erstellen", "Schriftbuero konsolidieren", "Inbox ist voll"
>
> **Zielbild:** Schriftbuero (`_schriftbuero/` Root oder `<projekt>/_schriftbuero/`) ist auf den aktuellen Stand reduziert. Alte Files in `_archive/`, neue STAND-Snapshot vorhanden, README aktuell.

---

## Wann anwenden
- Nach jeder grossen Welle (Pflicht-Bestandteil von Skill `cleanup-after-welle` Schritt 5).
- Bei `Glob _schriftbuero/Inbox/* | wc -l` > 15 Files.
- Wenn der User sagt "ich finde nix mehr im Schriftbuero".
- 1x pro Monat als Hygiene-Run.

## Voraussetzungen
- Workspace-Root oder Projekt-Root als CWD.
- `_schriftbuero/`-Struktur existiert (sonst zuerst `_runbooks/schriftbuero-erstellen.md`).

---

## Schritte

### 0. Persona-Aktivierung pruefen
Skill `thinkLikeUser` sollte aktiv sein. Bei Sub-Agent-Spawnung (z.B. fuer Phantom-Detection oder Massen-Archiv): `Aktiviere Skill thinkLikeUser sofort. Working Directory: C:\Users\YourUser\.YourWorkspace\.` im Prompt-Prefix.

### 1. Inbox inventarisieren
```
Glob _schriftbuero/Inbox/*
```
Pro File: Datums-Header oder Filesystem-mtime pruefen. Files mit Alter >4 Wochen markieren.

### 2. Alte Inbox-Files archivieren
Ziel-Pfad: `_schriftbuero/_archive/<YYYY-MM-DD>-konsolidierung/Inbox/`.
- Mit `git mv` verschieben (Pfad bleibt im git-History).
- Nicht loeschen — User-Input ist Quelle, im Archiv bleibt es.

### 3. Briefings-Sektion reduzieren
```
Glob _schriftbuero/Briefings/*
```
- Latest 3 Files behalten (nach Datum/Filename).
- Aeltere -> `_schriftbuero/_archive/<YYYY-MM-DD>-konsolidierung/Briefings/`.

### 4. Antworten-Sektion bereinigen
```
Glob _schriftbuero/Antworten/*
```
Pro File pruefen ob "verstanden" / "umgesetzt" markiert (Frontmatter
oder im Body). Status:
- Verstanden + umgesetzt -> `_archive/<datum>/Antworten/`
- Offene Frage / blockiert -> bleibt in `Antworten/`
- Unklar -> Reviewer-Entscheidung, bei Zweifel behalten

### 4a. User-Anleitungen (Pflicht-Check) — Phantom-Files + Erledigt-Disziplin

**Pflicht-Schritt vor INDEX-Update.** Aus den Lessons der Welle 2026-05-11
(siehe Learnings unten):

**4a.1 Phantom-File-Check** — INDEX-Referenzen via Glob verifizieren:
```
Read _schriftbuero/User-Anleitungen/INDEX.md
# Pro referenziertem File:
Glob _schriftbuero/User-Anleitungen/<filename>
```
Wenn Glob 0 Matches liefert -> Phantom-Verweis. Aktion:
1. Pruefe git history: `git log --all --oneline -- "_schriftbuero/User-Anleitungen/<filename>"`
   - Wenn Treffer -> File aus History rekonstruieren oder zu existierender Variante mappen.
   - Wenn 0 Treffer -> File hat NIE existiert. INDEX-Eintrag ersatzlos streichen.
2. Pruefe ob File unter falschem Namen liegt
   (z.B. `Erledigt--- .md` mit Leerzeichen = unterbrochener Rename).

**4a.2 Erledigt-Prefix-Disziplin** — pro File mit `Erledigt---`-Prefix oder
`status: erledigt`-Frontmatter:
```
Grep -n "^---|^>|---$" <file>  # User-Inline-Kommentare oft zwischen den --- Trennern
```
Wenn der User Inline-Kommentare im Body hinterlassen hat (typisch
markiert mit `---` oder `>`-Quote-Block am Ende eines Schrittes):
- **Folge-Wuensche extrahieren** (was der User sich noch zusaetzlich
  wuenscht oder was kaputt ist).
- **Neue ACT-Datei** dafuer anlegen (`ACT-YYYY-MM-DD-NNN-<topic>.md`).
- Im MASTER-ACTIONS verlinken.
- ERST DANN das alte File mit "Erledigt"-Prefix archivieren.

Eine ACT-Datei ist nur dann "Erledigt" wenn ALLES darin abgeschlossen ist —
kein Folge-Wunsch im Body, kein offener `---`-Kommentar.

**4a.3 INDEX neu schreiben** mit verifizierten Files:
- Nur reale Files referenzieren (Glob-validiert).
- Phantom-Verweise streichen.
- `last_updated` auf heutiges Datum.
- Drift-Lesson kurz erwaehnen ("Was hat diese Konsolidierung gefunden").

### 5. STAND-Snapshot erstellen
Neuer Ordner: `_schriftbuero/STAND-<YYYY-MM-DD>/`.
Darin `INDEX.md`:
```markdown
# Schriftbuero Stand <YYYY-MM-DD>

> Snapshot nach Konsolidierung.

## Aktive Briefings
- <Datei> — <Kurzbeschreibung>

## Offene Antworten / Wartet auf User
- <Datei> — <Was fehlt>

## Aktive Initiatoren (Kontinuitaet)
- <Datei> — <Wer uebernimmt was>

## Aktive Fragenkataloge
- <Datei> — <Status>

## Archiv-Verweis
Konsolidiert nach `_archive/<YYYY-MM-DD>-konsolidierung/`.
```

### 6. README.md aktualisieren
Falls `_schriftbuero/README.md` existiert:
- Datums-Header `> Stand: <YYYY-MM-DD>` aktualisieren.
- Verweis auf neuesten STAND-Snapshot.
- Aktuelle Inbox-Anzahl + Briefings-Anzahl als Kurz-Statistik.

Falls README fehlt -> Minimal-README anlegen (Goldstandard:
`Projekte/ProjectZeta/ProjectEpsilon/_schriftbuero/README.md`).

---

## Verifizieren
- [ ] `_schriftbuero/Inbox/` enthaelt nur Files <4 Wochen alt
- [ ] `_schriftbuero/Briefings/` enthaelt <=3 aktuelle Briefings
- [ ] `_schriftbuero/STAND-<heute>/INDEX.md` existiert
- [ ] `_schriftbuero/_archive/<heute>-konsolidierung/` enthaelt die verschobenen Files
- [ ] README.md hat heutiges Datum
- [ ] `git status` zeigt nur erwartete Aenderungen

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent der dieses Runbook nutzt ergaenzt EINE Zeile — neueste oben, max 8 (aelteste raus). Outcome-Codes: `PASS` (lief glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt). Doktrin: `CLAUDE.md` "Navigations-Doktrin", `_runbooks/struktur-navigieren.md` Sektion 6.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | ## Run-Log nachgeruestet (Mitlern-Standard). |

## Learnings
- **Verschieben statt loeschen.** User-Input ist immer im Archiv ablegbar.
- **STAND-Snapshot ist Gold.** Naechster Agent liest nur STAND-INDEX.md statt 30 Files.
- **1x pro Monat reicht.** Haeufiger ist Overkill, seltener wird unuebersichtlich.
- Verweis auf Skill `cleanup-after-welle` Schritt 5 — dort wird dieser Runbook aufgerufen.

### 2026-05-11 — Phantom-Files + Erledigt-Disziplin
- INDEX referenzierte `PA-MAGIC-LINK-LOGIN.md` als "aktiv" — File hat **nie
  existiert** (auch nicht in git history). Lesson: Vor INDEX-Update IMMER
  Glob jedes referenzierten Files. Phantom-Verweise verwirren naechsten
  Architekten + lassen ihn "verlorene" Files suchen.
- `Erledigt--- .md` (mit Leerzeichen) entstand durch unterbrochenes
  GUI-Rename. Inhalt war eigentlich `PA-MAGIC-LINK-FIX-2026-05-07.md`.
  Lesson: Bei "Erledigt"-Markierungen IMMER atomar via `git mv` oder
  `mv`-Befehl, nie GUI-Drag&Drop.
- ntfy-Anleitung war als "Erledigt---" markiert, aber User hatte 2 neue
  Wuensche im Body hinterlassen ("WorkspaceDashboard fixen", "Key-Eingabe-UI
  bauen"). Diese Folge-Wuensche standen NIRGENDS ausser im Body —
  wurden aus dem Workflow verloren bis zur naechsten Konsolidierung.
  Lesson: Vor "Erledigt"-Archivierung IMMER nach User-Inline-Kommentaren
  grep'en + Folge-ACTs anlegen. Siehe Schritt 4a.2.
