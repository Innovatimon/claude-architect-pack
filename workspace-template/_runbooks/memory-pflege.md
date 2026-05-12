# Runbook: Memory-Pflege
> Klassifikation: L2
> Stand: 2026-05-12

> **Trigger:** "Memory aufraeumen", "Stale Memory loeschen", "Memory pflegen", "MEMORY.md syncen", "Memory-Drift fixen"
>
> **Zielbild:** `~/.claude/projects/.../memory/` enthaelt nur aktuelle, eindeutige, indexierte Files. `MEMORY.md`, Filesystem, und CLAUDE.md-Memory-Block sind synchron (gleiche Anzahl, gleiche Pointer).

---

## Wann anwenden
- Pflicht-Bestandteil von Skill `cleanup-after-welle` Schritt 4 bei Drift.
- Nach jeder Master-Konsolidierung.
- Wenn `MEMORY.md`-Count != Filesystem-Count.
- 1x pro Woche als Hygiene.

## Voraussetzungen
- Schreibzugriff auf `~/.claude/projects/C--Users-TuT-Admin--YourWorkspace/memory/`.
- git zwar nicht aktiv hier, aber Workspace-Backup ueber Filesystem.

---

## Schritte

### 0. Persona-Aktivierung pruefen
Skill `thinkLikeUser` sollte aktiv sein — Memory-Drift-Kriterien (stale, Doppelung, Marken-Drift) stehen in `~/.claude/skills/thinkLikeUser/context/anti-patterns.md`. Bei Sub-Agent-Spawnung in dieser Routine: `Aktiviere Skill thinkLikeUser sofort.` im Prompt.

### 1. MEMORY.md lesen
```
Read ~/.claude/projects/C--Users-TuT-Admin--YourWorkspace/memory/MEMORY.md
```
Liste alle Eintraege mit Pointer-Pfad.

### 2. Filesystem-Inventur
```
Glob ~/.claude/projects/C--Users-TuT-Admin--YourWorkspace/memory/*.md
```
Vergleich MEMORY.md-Liste vs Filesystem-Files. Markiere:
- **Nur in Filesystem (kein Index-Eintrag)** -> Index nachtragen oder File loeschen.
- **Nur in MEMORY.md (kein File)** -> Index-Eintrag entfernen.
- **Beide vorhanden** -> Inhalt pruefen (Schritt 3).

### 3. Pro File: Verdachts-Check
Fuer jeden Eintrag prufen:
- **Datums-Marker:** Aelter als 3 Monate? -> Verdacht stale.
- **Verweise auf gestrichene Projekte:** BrandFive / BrandSix / BrandFour / ProjectGamma?
  -> Verdacht stale (siehe Memory `reference_brand_disqualifiziert.md`).
- **Doppelungen:** Zwei Memories zum gleichen Thema? -> Merge-Kandidat.
- **Veraltete Pfade:** `Projekte/AgentOS/` statt `_system/AgentOS/`? -> Update-Kandidat.
- **Code-Snippets / Secrets:** Klartext-Passwoerter? -> sofort entfernen (siehe `feedback_secrets_in_doku.md`).

### 4. Pro Verdachts-Fall: Read + Entscheidung
```
Read <pfad>
```
Entscheidung:
- **KEEP** — aktuell, eindeutig, relevant. Nichts tun.
- **UPDATE** — Inhalt aktualisieren (neue Pfade, neue Daten, Stale-Marker entfernen).
- **MERGE** — Mit anderem File zusammenfuehren, dann altes loeschen.
- **DELETE** — Komplett stale, kein Mehrwert. Loeschen.
- **ARCHIVE** — Historisch wertvoll aber nicht aktiv. `_archive/`-Unterordner ausserhalb Memory-Dir (Memory selbst hat keinen Archiv-Mechanismus -> Workspace-`_schriftbuero/_archive/memory-<datum>/`).

### 5. Edits in Memory-Files anwenden
Pro Aktion:
- UPDATE: `Edit`-Tool.
- MERGE: Inhalt manuell in Ziel-File integrieren, Quell-File loeschen.
- DELETE: File loeschen.

### 6. MEMORY.md syncen
- Geloeschte Files: Eintrag aus MEMORY.md raus.
- Neue Files: Eintrag rein (Format: `- [<Titel>](<pfad>) — <Kurzbeschreibung>`).
- Reihenfolge: thematisch gruppiert (User-Praeferenzen, Projekt-State, Referenzen).

### 7. CLAUDE.md-Memory-Block syncen (falls Memory in Root-CLAUDE.md verlinkt)
Aktuell ist der Memory-Block direkt der MEMORY.md-Inhalt (siehe System-Reminder).
Falls Root-`CLAUDE.md` einen eigenen Memory-Abschnitt fuehrt -> dieser
muss Count + Pointer == MEMORY.md haben.

Verifizieren:
```
Filesystem-Count == MEMORY.md-Eintraege-Count == CLAUDE.md-Memory-Block-Count
```

### 8. Kurz-Bericht
```
Memory-Pflege abgeschlossen
- Files vorher: <N>, nachher: <M>
- KEEP: <a>, UPDATE: <b>, MERGE: <c>, DELETE: <d>, ARCHIVE: <e>
- MEMORY.md: synced
- Drift-Findings: <Liste>
- Empfehlung: <naechster Schritt | done>
```

---

## Verifizieren
- [ ] MEMORY.md-Count = Filesystem-Count (`Glob *.md | wc -l`)
- [ ] Keine Verweise auf gestrichene Projekte (BrandFive / BrandSix / BrandFour / ProjectGamma als aktiv)
- [ ] Keine Secrets im Klartext (`Grep -i "password\|secret\|api[_-]key" --type md`)
- [ ] Pfade aktuell (`_system/AgentOS/`, `Projekte/MultiBrandShops/Shops/...`)
- [ ] Index thematisch gruppiert und lesbar

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent der dieses Runbook nutzt ergaenzt EINE Zeile — neueste oben, max 8 (aelteste raus). Outcome-Codes: `PASS` (lief glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt). Doktrin: `CLAUDE.md` "Navigations-Doktrin", `_runbooks/struktur-navigieren.md` Sektion 6.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | ## Run-Log nachgeruestet (Mitlern-Standard). |

## Learnings
- **Memory ist Cache, nicht Wahrheit.** Bei Diskrepanz zu Live-State (siehe `feedback_deploy_verify.md`): Live wins, Memory updaten.
- **MERGE ist haeufiger als DELETE.** Files enthalten meist 1 wertvolles Detail, der Rest ist redundant.
- **Stale-Marker statt Loeschung** bei historisch wertvollen Files (`reference_yuki_dashboard_deprecated.md` als Vorlage).
- **8-Files-Cleanup** war typischer Output bei der 2026-05 Master-Konsolidierung (Agent D Discovery).
- **Marken-Drift global patchen** in einer Aktion (BrandFive->BrandTwo, BrandSix->BrandThree, BrandFour->BrandFour) statt Einzel-Edit.
