# Runbook: Multi-Worker-Coordination
> Klassifikation: L2

> **Trigger:** "parallele Worker", "Welle mit N Agents", "git-Konflikt zwischen Workern", "Stash-Race", "Editor revertet"

## Wann mehrere Worker parallel?

- Welle-Orchestration mit 3+ parallelen Agent-Spawns
- Audit-Loop mit mehreren Phasen pro Welle
- Cleanup nach grosser Welle wo Reviewer + Worker parallel arbeiten

Siehe `welle-orchestration.md` fuer die Welle-Doktrin.

## Anti-Konflikt-Regeln

### Regel 1: Disjunkte File-Bereiche

Vor Spawn: pro Worker eine Liste der Files / Module die er anfasst.
Wenn zwei Worker dieselbe Datei brauchen -> sequentiell, nicht parallel.

### Regel 2: Migration-Nummern pre-allocated

Bei DB-Migrations: Lead vergibt die Nummern VOR Spawn-Zeit.
Worker bekommt seine Nummer in Prompt mit.

```
Worker A: Migration 031
Worker B: Migration 032
Worker C: Migrations 033 + 034 (zwei Migrations geplant)
Worker D: Migration 035
```

### Regel 3: Nur EIN Worker macht `npm install` pro Welle

`package.json` und `package-lock.json` (oder yarn/pnpm Aequivalent) sind shared.
Wenn zwei Worker parallel `npm install <neues-paket>` machen, gibt es Lock-Race.

Loesung: Lead macht alle `npm install`-Operationen VOR Worker-Spawn,
oder ein Worker bekommt explizit "du bist der Dependency-Worker".

### Regel 4: Atomare add+commit-Bloecke

Bash-Block pro Worker:

```bash
cd <projekt-root>
git pull --rebase <remote> <branch>
git add <SPEZIFISCHE-FILES>   # niemals "git add -A" oder "git add ."
git commit -m "[WORKER-ID] <message>"
git push <remote> <branch>
```

Falls Conflict: Worker pullt nochmal, rebaset, fixt Konflikt, weiter.
Bei groesseren Konflikten: Worker stoppt, meldet im Bericht, Lead loest.

### Regel 5: TaskUpdate pro Worker

Vor Start: `TaskUpdate(taskId, status=in_progress, owner=<worker-name>)`
Nach Erfolg: `TaskUpdate(taskId, status=completed)`

Andere Worker pruefen via TaskList wer woran arbeitet.

## Bekannte Probleme

### Stash-Race auf gemeinsamen Files

Symptom: Worker A committet seine Aenderung, Worker B (kurz danach) pullt, rebaset, eigener Stash-Apply liefert Konflikt — Worker B sieht "fremde Aenderungen" im eigenen Stash.

Ursache: Beide Worker hatten parallel `git stash` und `git stash apply` ueber dieselben Files.

Fix:
- Niemals `git stash` als Default in parallelen Workern
- Statt dessen: Worker arbeitet auf neuem Branch, mergt am Ende
- ODER: Worker committed direkt (kein Stash)

### Antigravity-/Editor-Revert-Verhalten

Symptom: Worker schreibt File, kurz darauf "wurde gerevertet" — Aenderung weg.

Ursache: Manche Editor-Sandboxes haben Revert-Hooks oder auto-format-Hooks die `Write` rueckgaengig machen.

Fix:
- Statt `Write`: `Edit` mit explizitem `old_string`/`new_string` (atomare Aenderung)
- Falls Worker meldet "rm wird reverted": retry mit `Remove-Item` (PowerShell) oder `rm -f` (Bash)
- Bei wiederkehrendem Revert: Editor neu starten oder Worker in andere Sandbox spawnen

### Worker-File-Absorption durch shared Stage-Index

Symptom: Worker A committet, aber im Commit landen auch Files von Worker B die parallel arbeiten.

Ursache: `git add -A` oder `git add .` packt ALLE getrackten Aenderungen, nicht nur die eigenen.

Fix:
- IMMER `git add <SPEZIFISCHE-FILES>` mit Liste
- Wenn unklar welche Files dazugehoeren: `git status` vor `add` und prefix-Filter

### Mid-Welle-Workspace-Move

Symptom: User verschiebt Pfade waehrend Worker laufen. Neue Worker finden alte Pfade nicht.

Fix:
- Worker mit aelterem Spawn-Prompt finden den alten Pfad weiterhin (Sandbox-Mapping)
- Neue Worker brauchen aktualisierte Pfade im Prompt
- Lead aktualisiert nach Move alle relevanten Memory-Files + Runbooks + Doku

## Verifizieren

- [ ] Pro Worker disjunkte File-Liste im Prompt
- [ ] Migration-Nummern pre-allocated
- [ ] Nur EIN Worker macht `npm install` (oder Lead macht alle vor Spawn)
- [ ] Worker nutzen atomare add+commit-Bloecke (kein `git add -A` blind)
- [ ] TaskUpdate vor + nach jedem Worker
- [ ] Bei Conflict: rebase, fix, weiter (kein force-push)

## Learnings

### 5-7 Worker ist Sweet-Spot
Mehr -> Konflikt-Risiko + Coordinations-Overhead. Weniger -> Welle dauert zu lange.

### Lead-Hotfix-Pattern
Nach Worker-Welle gibt es oft Konsolidierungs-Arbeit die nur der Lead machen kann:
Schema-Diskrepanzen, Cross-Worker-Konflikt-Aufloesung, Audit-Falsch-Positives.
Plane eine Lead-Hotfix-Phase zwischen Worker-Push und Reviewer.

### Worker-Naming W-A1..W-E3
Cross-Worker-Berichte referenzieren sich konsistent. Macht Multi-Welle-Doku lesbar.
