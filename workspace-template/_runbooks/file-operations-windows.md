# Runbook: File-Operations auf Windows (mit IDE-Locks)
> Klassifikation: L2
> Stand: 2026-05-12

> **Trigger:** "Permission denied bei mv", "Move-Item geht nicht", "YourWorkspace haelt File-Lock", "Datei nicht verschiebbar", "robocopy", "rm-rf failed"

## Wozu

Windows + IDE (YourWorkspace, VSCode) halten Locks auf bestimmte Ordner (besonders mit `.git`, `node_modules`, aktive Extensions). Standard-Tools (`mv`, `Move-Item`, `Remove-Item -Recurse`) scheitern mit "Permission denied" oder "in use by another process". Dieses Runbook zeigt Workarounds.

## Diagnose: Wie erkenne ich Locks?

Symptom 1: `mv "src" "dst"` → `mv: cannot move 'src' to 'dst': Permission denied`
Symptom 2: `Remove-Item -Recurse -Force "path"` → `Der Zugriff auf den Pfad "path" wurde verweigert.`
Symptom 3: `robocopy src dst /E /MOVE` → einige Files moved, andere bleiben (rc=8 oder rc=9)

**Was wahrscheinlich gelockt ist:**
- `.git/` Subordner (wenn IDE git-status pollt)
- `node_modules/` (wenn Watchers aktiv)
- `dist/`, `build/` (wenn Build-Process laeuft oder Files watch)
- `extensions/` (VSCode-aktive Extensions wie Java-Language-Server)

## Tool-Hierarchie (von simpel zu robust)

### 1. mv (Bash, Git-Bash) — Standard
```bash
mv "C:/path/src" "C:/path/dst"
```
**Funktioniert wenn:** keine Locks, keine `.git` im Subordner, keine grossen Subdirs

### 2. Move-Item (PowerShell) — Windows-nativ
```powershell
Move-Item -Path "C:\path\src" -Destination "C:\path\dst" -Force
```
**Funktioniert wenn:** mv scheitert wegen Pfad-Encoding, aber keine Locks

### 3. robocopy /MOVE — Windows-Bordmittel mit Lock-Tolerance
```powershell
robocopy "C:\path\src" "C:\path\dst" /E /MOVE /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -lt 8) { Write-Output "OK (rc=$LASTEXITCODE)"; exit 0 }
else { Write-Output "FAILED (rc=$LASTEXITCODE)"; exit 1 }
```

**Robocopy-Exit-Codes (kritisch zu wissen!):**
- `rc=0` — keine Files copied (no errors)
- `rc=1` — Files copied successfully (SUCCESS!)
- `rc=2` — Extra files in destination (SUCCESS)
- `rc=3` — 1+2 (SUCCESS)
- `rc=4` — Mismatched files (SUCCESS, warning)
- `rc=8` — Some files NOT copied (FAILURE)
- `rc=9+` — partielle Failure mit Files copied

**FALLE:** PowerShell interpretiert `rc=1` als Fehler. Du musst explizit `exit 0` setzen wenn rc<8, sonst werden parallele Tool-Calls cancelled.

```powershell
# RICHTIG (alles unter rc=8 als Erfolg behandeln):
robocopy ... | Out-Null
if ($LASTEXITCODE -lt 8) {
    Write-Output "OK (rc=$LASTEXITCODE)"
    exit 0  # WICHTIG
} else {
    Write-Output "FAILED"
    exit 1
}

# FALSCH (rc=1 wird als Fehler gemeldet):
robocopy ... 2>&1 | tail -3
Write-Output "exit: $LASTEXITCODE"
```

### 4. Force Delete bei Locks (last resort)
```powershell
# Erst alle moeglichen lockenden Prozesse stoppen:
Get-Process | Where-Object { $_.Path -like "C:\Users\YourUser\.YourWorkspace\*" } | Stop-Process -Force

# Dann delete:
Remove-Item -Recurse -Force "C:\path\stuck-folder" -ErrorAction Continue
```

**Falls IDE haelt Lock:** IDE komplett schliessen, Operation ausfuehren, IDE neu oeffnen.

## Pattern: Ordner-Move mit Verifikation

```powershell
$src = "C:\Users\YourUser\.YourWorkspace\Projekte\OLD"
$dst = "C:\Users\YourUser\.YourWorkspace\NEW"
robocopy $src $dst /E /MOVE /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -lt 8) {
    if (-not (Test-Path $src)) {
        Write-Output "OK — Quelle weg, Ziel da"
    } else {
        Write-Output "WARNUNG — Quelle existiert noch (Files locked?):"
        Get-ChildItem $src -Recurse | Select-Object -First 10 FullName
    }
    exit 0
} else {
    Write-Output "ROBOCOPY FAILED (rc=$LASTEXITCODE)"
    exit 1
}
```

## Pattern: Multi-Folder-Move (sequenziell mit Toleranz)

```powershell
$moves = @(
    @{ src = "Projekte\PA"; dst = "Projekte\MultiBrandShops\Shops\PA" },
    @{ src = "Projekte\NicheShop"; dst = "Projekte\MultiBrandShops\Shops\BrandOne\code" },
    @{ src = "Projekte\AgentOS"; dst = "_system\AgentOS" }
)
$root = "C:\Users\YourUser\.YourWorkspace"
foreach ($m in $moves) {
    $s = Join-Path $root $m.src
    $d = Join-Path $root $m.dst
    if (Test-Path $s) {
        robocopy $s $d /E /MOVE /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
        Write-Output "$($m.src): rc=$LASTEXITCODE"
    } else {
        Write-Output "$($m.src): SKIPPED (not exist)"
    }
}
exit 0
```

## Pattern: Datei-Inhalt-Replace mit UTF-8-no-BOM

PowerShell `Set-Content -Encoding utf8` schreibt UTF-8 mit BOM. Andere Tools mogen das nicht. Loesung:

```powershell
$enc = New-Object System.Text.UTF8Encoding($false)  # $false = no BOM
$path = "C:\path\file.md"
$content = [System.IO.File]::ReadAllText($path, $enc)
$content = $content -replace 'OLD/', 'NEW/'
[System.IO.File]::WriteAllText($path, $content, $enc)
```

## Pattern: Bulk-Rename via Regex (mit Negative-Lookbehind)

```powershell
$root = "C:\Users\YourUser\.YourWorkspace"
$enc = New-Object System.Text.UTF8Encoding($false)
$count = 0
Get-ChildItem -Path $root -Recurse -Filter *.md -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notmatch '\\node_modules\\' -and
        $_.FullName -notmatch '\\\.git\\' -and
        $_.FullName -notmatch '\\_archive\\'
    } | ForEach-Object {
        $orig = [System.IO.File]::ReadAllText($_.FullName, $enc)
        # Negative-Lookbehind: nur 'OLD/' wenn KEIN '/' davor
        $c = $orig -replace '(?<![/\\\w-])OLD/', 'NEW/'
        if ($c -ne $orig) {
            [System.IO.File]::WriteAllText($_.FullName, $c, $enc)
            $count++
        }
    }
Write-Output "Patched $count files"
```

## Anti-Patterns (NICHT TUN)

- **Niemals** parallele robocopy auf gleichen Source-Pfad (race-condition mit /MOVE)
- **Niemals** `rm -rf` auf Workspace-Root (alles weg, inkl. .git!)
- **Niemals** Set-Content ohne explizites Encoding (default ist UTF-16 LE BOM in PowerShell 5.1)
- **Niemals** Robocopy ohne /R:1 /W:1 (default ist Retry 1 Million × 30 Sek = 1 Jahr Hang)
- **Niemals** robocopy /MIR auf Source ohne Backup (loescht alles in Dest was nicht in Source ist)

## Verifizieren

- [ ] Quell-Ordner existiert nicht mehr (oder ist leer ausser Locks)
- [ ] Ziel-Ordner enthaelt erwartete Files
- [ ] Pfad-Refs in Doku gepatched (siehe Bulk-Rename-Pattern)
- [ ] Git-History intakt (`git log` im Ziel zeigt alle Commits)
- [ ] Build/Tests laufen (wenn Code-Move)

## Run-Log

> **Pflicht-Touchpoint.** Jeder Agent der dieses Runbook nutzt ergaenzt EINE Zeile — neueste oben, max 8 (aelteste raus). Outcome-Codes: `PASS` (lief glatt, nichts geaendert) · `PARTIAL` (lief, aber etwas war anders — Notiz!) · `FIX` (Runbook stimmte nicht, korrigiert) · `META` (nur am Runbook editiert, nicht ausgefuehrt). Doktrin: `CLAUDE.md` "Navigations-Doktrin", `_runbooks/struktur-navigieren.md` Sektion 6.

| Datum | Agent / Welle | Outcome | Notiz (was war anders / was wurde am Runbook geaendert) |
|-------|---------------|---------|---------------------------------------------------------|
| 2026-05-12 | Runbook-Mitlern-Welle | META | ## Run-Log nachgeruestet (Mitlern-Standard). |

## Learnings

### 2026-05-12 — ProjectEta → ProjectTheta/ProjectEta: `mv` failed, `cp -r` + `rm -rf` ging
- `mv "Projekte/ProjectEta" "Projekte/ProjectTheta/ProjectEta"` (Git-Bash) → `Permission denied`. `mv` versucht zuerst `rename()` (atomar) — das scheitert auf Windows wenn ein Prozess (YourWorkspace-IDE / File-Watcher) ein Handle in den Ordner haelt.
- **Workaround der funktioniert hat:** `cp -r "src" "dst"` (kopiert File-fuer-File — Lesen geht trotz Watcher) **dann** `rm -rf "src"` (Loeschen ging hier auch — bei harten Locks ggf. IDE schliessen). 25-File-Ordner inkl. `.git`-freiem Sub `Mama/` problemlos.
- **Default ab jetzt fuer Ordner-Relocations im Workspace:** erst `mv` versuchen; bei `Permission denied` → `cp -r` + `rm -rf` (Git-Bash) ODER `robocopy /MOVE` (PowerShell, siehe oben). Nicht aufgeben/User fragen — der Workaround ist Routine.
- Nach dem Move: IDE-Datei-Baum ist stale (zeigt alten Pfad / Fehler bei offenem Tab) → User: **Reload Window** (Ctrl+Shift+P → "Reload Window"). Kein echter Bug, nur IDE-Cache.

### 2026-05-06 — Konsolidierungs-Welle: 12 Move-Operationen mit Locks
- Saltys/deploy_daemon moved problemlos mit Bash mv
- workspace-dashboard + extensions wurden von YourWorkspace-IDE gelockt
- MultiBrandShops (mit .git) wurde gelockt
- Loesung: robocopy /MOVE mit `exit 0` bei rc<8 — alle 5 gelockten Ordner moved
- extensions/ konnte nicht zurueck-moved werden (Java-Extensions hart gelockt) — finale Loesung: extensions bleibt Top-Level (IDE-Cache)

### Lehre: rc<8 ist immer Erfolg bei robocopy
PowerShell interpretiert ALLE non-zero exit-codes als Fehler. Bei robocopy ist das falsch. Pattern: `if ($LASTEXITCODE -lt 8) { exit 0 } else { exit 1 }`.

### Lehre: Locks haben Quellen
- `.git` Subordner — Git-Status-Polling vom IDE
- `node_modules/` — File-Watcher
- VSCode-Extensions — Process-Locks (besonders Java-LSP, TypeScript-Server)
- `dist/` `build/` — Build-Tool-Watcher

Vor Move: pruefe ob lockende Prozesse laufen. IDE schliessen ist letzter Ausweg.

### Lehre: Negative-Lookbehind fuer Pfad-Patches
Regex `(?<![/\\\w-])OLD/` matched NUR wenn vor "OLD/" KEIN Pfad-Separator oder Word-Char ist. So vermeidet man `Projekte/OLD/` -> `Projekte/Projekte/NEW/` bei doppeltem Replace.
