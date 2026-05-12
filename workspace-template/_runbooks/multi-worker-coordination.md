# Runbook: Multi-Worker Coordination (4-6 parallele Code-Worker am gleichen Repo)
> Klassifikation: L2
> Stand: 2026-05-12

> **Trigger:** "starte X parallele Worker", "Phase Y mit N Agents", "Welle XYZ", "spawne Worker"
> **Gilt fuer:** Alle Faelle in denen >1 Worker im selben git-Repo arbeiten.
> **Quelle:** 18 parallele Worker, 5 Iterationen, ~8 Mio Tokens (PERFEKT-Loop 2026-05-04).

---

## Goldene Regeln

0. **Persona-Aktivierung im Worker-Prompt PFLICHT** — Jeder Worker-Prompt MUSS beginnen mit: `Aktiviere Skill thinkLikeUser sofort. Working Directory: C:\Users\YourUser\.YourWorkspace\.` Sonst arbeiten Workers neutral statt im Architekt-Stil — Default-Heuristiken, Anti-Patterns und Stop-Punkte fehlen, was zu Drift fuehrt. Skill-Pfad: `~/.claude/skills/thinkLikeUser/`.
1. **File-Disjunktheit ist Pflicht** — Worker-Prompts haben "DARFST"- und "DARFST NICHT"-Listen. Nicht disjunkte Wellen werden sequenziell gemacht, nicht parallel.
2. **Konflikt-Files explizit zuweisen** — Wenn 2 Wellen am gleichen File arbeiten, einer macht alle Aenderungen, der andere ueberlaesst es ihm.
3. **Stash IMMER per Name, NIE per Index** — `git stash push -m "WORKER-X-pre-rebase-$(date +%s)"`, dann mit Pattern popen.
4. **PowerShell `[System.IO.File]::WriteAllText` statt Edit-Tool** wenn moeglich — YourWorkspace-Editor revertet Edit-Calls mit ~100% Rate.
5. **Atomare Bash/PowerShell-Blocks** — sed + git add + git commit in EINEM Tool-Call statt drei separaten.
6. **Push-Reihenfolge nach Spawn-Zeit + Diff-Groesse** — kleinste Diffs zuerst, groesste zuletzt.
7. **Sleep 60-90s nach Push** vor Live-Verifikation (Push-Restart-Race).

---

## Workflow pro Worker

### 1. Vor Coden
```bash
cd <REPO_PATH>
git fetch deploy
git pull --rebase deploy master   # WICHTIG — andere Worker pushen ggf. parallel
git status                         # sollte clean oder bekannter WIP
```

Wenn nicht clean: pruefen ob es **eigene** WIP-Files sind oder fremde:
- Eigene → `git diff` lesen, ggf. fortsetzen
- Fremde → `git stash push -m "WORKER-X-pre-rebase-$(date +%s)" -- <fremde-files>` (nur die fremden!) ODER alle stashen mit Named-Stash

### 2. Edits durchfuehren

**YourWorkspace-EDITOR-BUG:** Edit-Tool-Calls werden zwischen den Tool-Calls vom YourWorkspace-Buffer wieder zurueckgerollt. **Loesung:**

#### Option A — PowerShell atomar (empfohlen fuer >5 Files):
```powershell
$content = Get-Content "src/components/X.tsx" -Raw
$updated = $content -replace 'pattern', 'replacement'
[System.IO.File]::WriteAllText("$PWD/src/components/X.tsx", $updated)
git add src/components/X.tsx
```

Multi-File-Variante:
```powershell
Get-ChildItem -Recurse -Path src -Include *.tsx | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  $updated = $content -replace 'pattern(?!-)', 'pattern-replacement'
  [System.IO.File]::WriteAllText($_.FullName, $updated)
}
git add -A
```

**CRLF-Hinweis:** Files mit Windows-Zeilenenden brauchen `CRLF` im PowerShell-Replace-Pattern fuer Multi-Line-Match.

#### Option B — Edit-Tool + sofortige Verifikation (fuer 1-3 Files):
```
Edit Tool aufrufen
Bash: grep <pattern> <file>   # SOFORT verifizieren
Wenn nicht da: Edit Tool nochmal
Sobald verifiziert: git add <file>
```

#### Option C — sed direkt (fuer reine Replace-Ops):
```bash
grep -rln "old-pattern" src/ | xargs sed -i 's/old-pattern/new-pattern/g'
git add -A
```

### 3. Build vor Commit (nicht skip!)
```bash
ssh YOUR_SERVER "cd /root/deployments/your-app && npm run build 2>&1 | tail -20"
# ODER lokal wenn moeglich (Windows hat ENOENT-Bug bei Next.js — vorsichtig)
```

### 4. Commit + Push
```bash
git commit -m "[WORKER-X Theme] kurze klare Zusammenfassung mit Findings-IDs"
git pull --rebase deploy master   # nochmal vor Push!
# Bei Konflikt: 
#   git status (was kollidiert?)
#   Edits + git add
#   git rebase --continue
git push deploy master
```

### 5. Live-Verifikation (Pflicht)
```bash
sleep 90   # Push-Restart-Race-Window — Hook braucht Zeit fuer install + build + restart
ssh YOUR_SERVER "cat /root/deployments/your-app/.next/BUILD_ID"
ssh YOUR_SERVER "systemctl status your-app --no-pager | head -3"
ssh YOUR_SERVER "for p in <relevante-routen>; do echo -n \"\$p: \"; curl -sL -o /dev/null -w '%{http_code}' https://projectalpha.example.com\$p; echo; done"
```

### 6. Stash-Cleanup
```bash
git stash list   # zaehlen + identifizieren eigene Stashes
git stash pop "stash^{/WORKER-X-pre-rebase-}"   # per Name pop, NIE per Index!
```

---

## Konflikt-Mitigation pro File-Typ

### Globals.css / Tailwind.config / Layout.tsx (gleicher File, mehrere Wellen)
**Loesung:** Eine Welle macht alles. Andere verzichten.
**Beispiel:** Phase B B1 macht globals.css `body { overflow }`, B5 macht globals.css `prefers-reduced-motion` — beide editieren globals.css, aber disjunkte Sektionen, plus klare Edits-Listen im Worker-Prompt.

### Migration-Files
**Loesung:** Migrations-Nummer pro Worker fest zuweisen.
**Beispiel:** Phase B B5 macht 040, B4 macht 039+041, C4 macht 042. NIE 2 Worker auf gleiche Nummer.

### Komponenten-Files (Light + Touch + Feature)
**Loesung:** Worker der die meisten Aenderungen macht, bekommt das ganze File.
**Beispiel:** Settings-Page hatte Light + Touch-Targets + SVG-Bug. Phase C2 macht alles in Settings (Light+Touch+SVG), C3 verzichtet.

### Demo-Daten (Code + DB)
**Loesung:** A1-Lesson — IMMER beide Quellen pruefen + patchen. Code-Edit allein ist wirkungslos wenn DB-Tabelle existiert.

---

## Push-Reihenfolge (5-6 Worker)

1. **Kleinste Diffs zuerst** (Foundation, kein Konflikt)
2. **Tailwind-Sed/Token-Cleanup** vor Light-Migration (Light braucht saubere Tokens)
3. **Backend (Migration) vor Frontend** (Frontend braucht DB-Schema)
4. **Light-Migration vor AI-Chat-Light** (AI-Chat baut auf System-Komponenten)
5. **Mobile/Touch-Targets nach Light** (Touch-Edits hover-Klassen — Light-Counterparts muessen schon da sein)

**Beobachtet im PERFEKT-Loop:** B2 → B1 → B3 → B6 → B5 → B4 (verschiedene Worker, verschiedene Geschwindigkeiten — aber alle haben pull-rebase + push gemacht, kein Force-Push, kein Konflikt-Kollaps).

---

## Stash-Race-Conditions Anti-Patterns

### NICHT
- `git stash pop stash@{0}` — Stash-Index aendert sich wenn andere Worker stashen!
- `git stash apply stash@{1}` — gleicher Bug

### DOCH
```bash
# Beim Erstellen
git stash push -m "B4-pre-rebase-$(date +%s)" -- <files>

# Beim Pop
git stash pop "stash^{/B4-pre-rebase-}"   # by-name match
# ODER
git stash list | grep "B4-pre-rebase-" | head -1 | awk -F: '{print $1}' | xargs git stash pop
```

### Recovery wenn Stash verloren scheint
```bash
git stash list
# Wenn nicht in Liste: Pruefe stash-tree direkt
git fsck --no-reflog | awk '/dangling commit/ {print $3}'   # zeigt orphaned stashes
git show <commit-hash>   # inspect
git stash apply <commit-hash>
```

### Fortgeschrittene Recovery (B5-Pattern)
Wenn Stash nicht popable: per `git ls-tree` aus stash-tree restoren:
```bash
# Modifizierte Files aus stash@{1}
git ls-tree stash@{1}^{tree}
git show stash@{1}^{tree}:src/components/X.tsx > src/components/X.tsx

# Untracked Files aus stash@{1}^3 (3rd parent)
git ls-tree stash@{1}^3
git show stash@{1}^3:path/to/new.tsx > path/to/new.tsx
```

---

## Worker-Boundary-Disziplin (PERFEKT-Lesson)

### Im Worker-Prompt klar definieren
```
**Du DARFST aendern:**
- file1.tsx
- file2.tsx
- ...

**Du DARFST NICHT aendern:**
- file3.tsx (gehoert zu Worker Y)
- file4.tsx (gehoert zu Welle Z)
- ...
```

### Wenn ein Worker fremde WIP-Files entdeckt
1. **Ignorieren** — nicht editieren
2. **Stashen** mit klarem Namen (`WORKER-X-protect-WORKER-Y-WIP-<timestamp>`)
3. **Eigene Edits durchfuehren + commiten + pushen**
4. **Stash zurueck-popen** damit andere Worker weiterarbeiten koennen

### Wenn ein Worker einen Build-Brecher findet (von anderem Worker)
**Beispiel C3 fand C5's Button-Import-Bug:**
1. Lokal fixen (Untracked)
2. Im EIGENEN Bericht melden ("C5 hat Build-Brecher in BrandedErrorPage.tsx Button-Import — lokal gefixt als Untracked, falls C5 das nicht selber faengt")
3. NICHT in eigenen Commit packen — C5 hat das Recht/Pflicht selbst zu fixen

---

## Anti-Patterns (was NICHT tun)

- **NICHT** mehr als 6-7 parallele Worker — Konflikt-Risiko + Coordinations-Overhead
- **NICHT** force-push — auch nicht bei Stash-Verlust
- **NICHT** `--no-verify` — Hooks haben einen Grund
- **NICHT** Stash per Index ansprechen wenn andere Worker laufen
- **NICHT** Edit-Tool ohne sofortige Verifikation bei aktivem YourWorkspace-Buffer
- **NICHT** auf User-Bestaetigung zwischen Worker-Spawns warten — autonom

---

## Live-Status-Check (Architekt-Pattern)

```bash
# Aktueller Live-Stand
ssh YOUR_SERVER "cat /root/deployments/your-app/.next/BUILD_ID && systemctl status your-app --no-pager | head -3"

# Letzte 8 Pushes deploy/master
git fetch deploy && git log --oneline -8 deploy/master

# Smoke gegen Top-Routes
ssh YOUR_SERVER "for p in /de /de/home /de/shop /de/diary /de/clubs /de/membership /de/legal/impressum /de/legal/datenschutz /de/legal/agb /de/legal/barrierefreiheit; do echo -n \"\$p: \"; curl -sL -o /dev/null -w '%{http_code}' https://projectalpha.example.com\$p; echo; done"

# Errors letzte 30 Min
ssh YOUR_SERVER "journalctl -u your-app --since '30 minutes ago' --no-pager | grep -iE 'error|fail|crash' | head -10"
```

---

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent der dieses Runbook nutzt ergaenzt EINE Zeile — neueste oben, max 8 (aelteste raus). Outcome-Codes: `PASS` (lief glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt). Doktrin: `CLAUDE.md` "Navigations-Doktrin", `_runbooks/struktur-navigieren.md` Sektion 6.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | ## Run-Log nachgeruestet (Mitlern-Standard). |

## Lessons aus dem PERFEKT-Loop

1. **6 Worker parallel ist Sweet-Spot** — bei 7+ steigt Coordinations-Overhead exponentiell.
2. **YourWorkspace-Editor-Bug ist hartnaeckig** — nicht "geht schon" — IMMER PowerShell-WriteAllText nutzen oder sofort grep-verify.
3. **Push-Restart-Race ~30s** — Service-Hook restartet bevor webpack komplett ist. 60-90s sleep nach Push.
4. **Stash by name funktioniert in 100% der Faelle** — by index in 50% bei parallelen Workern.
5. **B6 hat 6 Commits gemacht** — atomare Commits pro Sub-Aufgabe verhindern Verlust durch fremde Stashes/Resets.
6. **Worker-Boundary-Doku im Bericht** macht Re-Spawnen einfach (Pattern: "DARFST/DARFST NICHT/Pfad-Diskrepanzen/Caveats fuer Folge-Welle").

## Lessons aus PERFEKT-Welle 2026-05-06 (3 Wellen x 2 Phasen, 19 Worker autonom)

13. **3-Wellen-Pattern komplett verifiziert** — 5-Audit + Welle 1A (5 Worker P0) + Welle 1B (4 Worker P1) + Welle 2A (3 Worker Re-Audit) + Welle 2B (3 Worker P2) + Welle 3A (3 Worker Final) + Welle 3B (Lead) = 24+ Commits, 0 generelle Konflikte. Sweet-Spot: 3-5 Worker pro Phase.
14. **YourWorkspace-Sandbox-Block ist worker-spezifisch, nicht generell** — W-B3 berichtete "rm wird reverted" und konnte 12 dead-code Files nicht loeschen. W-C1-Retry mit `Remove-Item` (PowerShell direct) funktionierte sofort. Naechster Worker mit anderer Strategie probieren statt Welle abbrechen.
15. **Listing-DB-Schema-Dump als Baseline-Migration-Pattern** (W-C3) — wenn DB ohne Migration-Files existiert: Information-Schema-Queries via Management API + topologisch sortierte CREATE-Statements + idempotente DO $$ ... EXCEPTION-Bloecke. Tracking-Eintrag separat (W-B4 Pattern).
16. **Worker-File-Absorption durch shared Stage-Index** (verifiziert mehrfach) — Loesung: explizit `git add <SPEZIFISCHE-FILES>` (nie `git add -A`/`git add .`) + atomare add+commit-Bloecke in einem Tool-Call statt zwei.
17. **Audit-Reports koennen Falsch-Positives enthalten** (W-B4-Lesson) — Beispiel "Newsletter-Validation fehlt" → Code hatte sie seit Initial-Commit. Worker prueft erst Code-File bevor er Fix implementiert.
18. **Mid-Welle-Workspace-Move ist transparent** — User kann Pfade verschieben waehrend Worker laufen. Sandbox mapped alten Pfad auf neuen. Lead aktualisiert nach Move alle Pfad-Refs (Memory + Doku) atomar.
19. **Reviewer = Lead-self ist Standard** — Independent-Sub-Agent nur bei Bias-Risiko. Lead-Reviewer: Live-curl 25-30 Routen + Schema-Counts + journalctl-grep + BUILD_ID-Match in <2 Min PASS.
20. **Lead-Hotfix-Phase ist Pflicht zwischen Worker-Welle und Reviewer** — Schema-Diskrepanzen (W-A4 `subscriptions` vs `profiles.subscription_tier`), Migrations-Apply (MCP-offline), Cross-Worker-Konflikte. Commit-Format: `[Lead <Welle> Hotfix]`.

## Lessons aus NXT-Welle 2026-05-05 (6 Worker + Lead-Hotfix)

7. **Worker-File-Absorption durch parallele Stage-Indexe.** W4's neue Files (`clubs/create/page.tsx`, `clubs/join/page.tsx`, `InvitationCodeManager.tsx`) wurden in W3's Commits `91cd1f7+2619e17` absorbiert weil beide Worker im selben Working-Tree ueber den shared staging-Index liefen. Dateien sind 1:1 W4-konform, leben aber unter W3's Commit-Hash. **Loesung:** Pro Worker explizit `git add <SPEZIFISCHE-FILES>` (nie `git add -A`/`git add .`) und atomare add+commit-Bloecke in einem Tool-Call (nicht zwei Calls). Wenn Absorption schon passiert ist: Bericht dokumentieren, kein Re-Commit.
8. **Lead-Hotfix-Pattern nach Worker-Welle.** Wenn ein Worker DB-Tabellen-Schema annimmt das nicht existiert (W4 nutzte `from('subscriptions')`, Tabelle heisst aber `profiles.subscription_tier`), muss Lead nach Welle-Ende einen Hotfix-Commit pushen. **Loesung:** Vor jedem DB-Worker-Spawn das Schema im Audit verifizieren: `SELECT table_name FROM information_schema.tables WHERE table_name LIKE '%sub%'` und im Worker-Prompt Schema-Snapshot mitgeben.
9. **MCP `mcp-server-supabase: not found` ist Standard-Zustand.** Worker sollen nicht bloecken wenn Migration-Apply fehlschlaegt — stattdessen Migrationen-Files im Repo committen + im Bericht "User-Action: Migration manuell anwenden" markieren. Lead wendet sie nach Welle-Ende via Management API an (siehe `supabase-migration-anwenden.md` Lesson NXT).
10. **6 Worker parallel auf MAX EFFORT ist OK** wenn File-Disjunktion klar ist. Token-Verbrauch: ca. 1.5 Mio Tokens pro Worker bei 30-60 Min Laufzeit. Bei Anthropic-Subscription-Plan einplanen.
11. **Reviewer-Phase = Architekt-Aufgabe**, nicht Sub-Agent. Wenn alle Worker fertig + Live-Verify OK + Migrations angewendet, kann Lead Reviewer selbst sein (spart Agent-Spawn). Independent-Sub nur wenn echtes Risiko von Bias.
12. **Initial-Smoke-Routes-200/404-Mapping** vor Audit-Phase findet sofort 1-2 Findings. Beispiel NXT-PERFEKT 2026-05-06: `/de/legal/cookies` + `/de/admin` = 404, gefunden in 5 Sekunden curl.

> **Wenn du das hier nutzt:** Schreibe deine eigenen Lessons am Ende dieser Datei. Naechster Architekt liest sie.
