# Runbook: Memory-Pflege
> Klassifikation: L2

> **Trigger:** "Memory aufraeumen", "Stale Memory loeschen", "Memory pflegen", "MEMORY.md syncen", "Memory-Drift fixen"

## Was ist Memory?

Persistente Notizen ueber den User, Projekte, Feedback und externe Referenzen,
die ueber Sessions hinweg ueberleben. Liegen in:

```
~/.claude/projects/<workspace-encoded>/memory/
  MEMORY.md                # Index aller Memory-Files
  user_*.md                # Wer ist der User, Rolle, Praeferenzen
  feedback_*.md            # Was hat der User korrigiert oder bestaetigt
  project_*.md             # Projekt-State (wer-wo-was)
  reference_*.md           # Pointer auf externe Systeme (Notion-DB, Grafana)
```

## Wann pflegen?

- Nach jeder grossen Welle (`cleanup-after-welle` triggert)
- Wenn `MEMORY.md` Count != Filesystem-Count
- Wenn ein Memory-File offensichtlich stale ist (Projekt geschlossen, Tech gewechselt)
- Wenn der User explizit "Memory pflegen" sagt

## Schritt-fuer-Schritt

### 1. Filesystem-Stand erfassen

```bash
MEM="<memory-pfad>"  # typischerweise ~/.claude/projects/.../memory
ls -la "$MEM"/*.md | wc -l
```

### 2. MEMORY.md-Stand erfassen

```bash
grep -c "^- \[" "$MEM/MEMORY.md"
```

Wenn die Counts nicht passen -> Drift, syncen.

### 3. Stale-Markierung pro File

Pro `*.md` File pruefen:
- Hat es ein `> Stand: <datum>` im Header?
- Datum > 60 Tage alt und betroffenes Projekt aktiv? -> Stale-Check.
- Inhalt noch korrekt (z.B. Pfade existieren, Service laeuft)?

Stale aber noch relevant: Marker am File-Anfang
```markdown
> Stand: <datum> — VERALTET (todo: refresh nach <konkretem-event>)
```

Stale und obsolet: ins `_archive/` verschieben.

### 4. Archiv-Struktur

```bash
ARCHIVE="$MEM/_archive/$(date +%Y-%m-%d)"
mkdir -p "$ARCHIVE"
# pro obsoletes File:
mv "$MEM/<file>.md" "$ARCHIVE/"
```

### 5. MEMORY.md neu schreiben

Format: Index, eine Zeile pro File, unter 150 Zeichen pro Zeile.

```markdown
- **<Doktrin-Hauptpointer>:** <kurz>
- [Titel](datei.md) — <Hook in einem Satz>
- [...]
```

Sektioniert wenn nuetzlich, aber nicht zu granular. Pointer-Liste, keine Memory.

### 6. Duplikat-Check

Pro Topic (z.B. "git push" oder "Notion-Workflow"): nur EIN Memory-File.
Wenn 2 vorhanden -> merge:
1. Inhalte konsolidieren in das aelter benannte
2. Neueres ins `_archive/` verschieben
3. MEMORY.md-Eintrag fuer das Archivierte streichen

### 7. Neue Memory pro Welle (falls Drift entdeckt)

Wenn die Welle neue dauerhafte Erkenntnisse brachte:
- Pro Erkenntnis: 1 neues `feedback_*.md` oder `project_*.md`
- Eintrag in MEMORY.md
- Frontmatter: `name`, `description`, `type`

Format:
```markdown
---
name: <kurzname>
description: <ein Satz, wann ist das relevant?>
type: feedback | project | reference | user
---

<Inhalt: lead mit Rule/Fact, dann **Why:** und **How to apply:**>
```

### 8. Git-Commit (falls Memory unter git)

Memory liegt typischerweise NICHT unter git (User-spezifisch).
Falls doch:

```bash
cd "$MEM/.."
git add memory/
git commit -m "memory: pflege $(date +%Y-%m-%d) — <kurze-zusammenfassung>"
```

### 9. Kurz-Bericht im Chat

```
Memory-Pflege abgeschlossen:
- Files vor: <N_alt>, nach: <N_neu>
- Archiviert: <N>
- Stale-markiert: <N>
- Neue: <N>
- MEMORY.md syncgepruft: PASS / FAIL
- Duplikate konsolidiert: <N>
```

## Boundaries

- Niemals Memory-Files committen die echte Secrets enthalten (API-Keys etc.)
- Pflege ist non-destruktiv (alles ins `_archive/`, keine Hard-Deletes)
- L6/L7-Memory bleibt projekt-spezifisch — kein Cross-Projekt-Merge

## Verifizieren

- [ ] `MEMORY.md` Count = Filesystem-Count
- [ ] Keine Phantom-Pointer in MEMORY.md (jede Datei existiert)
- [ ] Keine Files ohne MEMORY.md-Eintrag (ausser explizit standalone-Notizen)
- [ ] Stale Files markiert oder archiviert
- [ ] Kurz-Bericht gepostet

## Learnings

### MEMORY.md ist nicht Memory, sondern Index
Die `MEMORY.md`-Datei lebt im Hauptkontext und ist limited (~200 Zeilen). Schreibe nie Memory-Inhalt rein — nur einzeilige Pointer.

### Stale ist nicht obsolet
Memory das alt aber noch korrekt ist (z.B. "Tech-Stack ist Next.js 14") darf bleiben. Memory das falsch ist (z.B. "Port 8501 fuer Service X" — Service laeuft jetzt auf 8505) muss aktualisiert oder archiviert werden.

### Duplikate sind Doku-Drift
Wenn 2 Files das gleiche Thema abdecken: einer ist falsch oder veraltet, der andere richtig. Merge zwingt Klaerung.
