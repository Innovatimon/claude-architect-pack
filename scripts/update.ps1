# Claude Architect Pack — Windows-Updater (PowerShell)
#
# Aufruf:
#   .\scripts\update.ps1
#
# Oder via Skill: /update-architect-pack in Claude Code

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Claude Architect Pack Updater    " -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$PackDir = Join-Path $HOME "claude-architect-pack"
$ConfigFile = Join-Path $PackDir ".install-config.json"

if (-not (Test-Path $PackDir)) {
    Write-Host "FEHLER: $PackDir existiert nicht. Erst installieren: scripts\install.ps1" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $ConfigFile)) {
    Write-Host "FEHLER: .install-config.json fehlt. Re-Install noetig." -ForegroundColor Red
    exit 1
}

$config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
$WorkspacePath = $config.workspace_path
$SkillsDir = $config.skills_dir

Write-Host "Workspace: $WorkspacePath"
Write-Host "Skills:    $SkillsDir"
Write-Host ""

# --- Pre-Update-Check ---
Push-Location $PackDir
$LocalBefore = git rev-parse HEAD
git fetch origin
$RemoteHead = git rev-parse origin/main

if ($LocalBefore -eq $RemoteHead) {
    Write-Host "Pack ist bereits aktuell ($LocalBefore)." -ForegroundColor Green
    Pop-Location
    exit 0
}

Write-Host "Update verfuegbar:" -ForegroundColor Yellow
Write-Host "  Vorher:  $LocalBefore"
Write-Host "  Nachher: $RemoteHead"
Write-Host ""
Write-Host "Aenderungen:" -ForegroundColor Yellow
git log --oneline "$LocalBefore..$RemoteHead" --no-merges | Select-Object -First 10 | ForEach-Object {
    Write-Host "  $_"
}
Write-Host ""

$Confirm = Read-Host "Update durchfuehren? [Y/n]"
if ($Confirm -match "^[Nn]") {
    Write-Host "Abgebrochen." -ForegroundColor Yellow
    Pop-Location
    exit 0
}

# --- Pack-Repo updaten ---
Write-Host ""
Write-Host "Schritt 1: Pack-Repo updaten..." -ForegroundColor Yellow
git pull origin main
Pop-Location

# --- Workspace-Files updaten ---
Write-Host ""
Write-Host "Schritt 2: Workspace-Template-Files updaten..." -ForegroundColor Yellow

$TemplateDir = Join-Path $PackDir "workspace-template"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$UserOwnedRegex = "^(CLAUDE\.user\.md|_user-overrides[/\\]|Projekte[/\\]|projects[/\\]|_runbooks[/\\](custom|local)-|_control[/\\](credentials-map\.md|server-config\.md|projects[/\\]))"
$UpdatedCount = 0
$SkippedCount = 0

Get-ChildItem $TemplateDir -Recurse -Force | ForEach-Object {
    if ($_.PSIsContainer) { return }

    $rel = $_.FullName.Substring($TemplateDir.Length + 1)
    $dest = Join-Path $WorkspacePath $rel

    if ($rel -match $UserOwnedRegex) {
        $SkippedCount++
        return
    }

    if (Test-Path $dest) {
        Copy-Item $dest "$dest.bak.$Timestamp"
    } else {
        $destDir = Split-Path $dest -Parent
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    }

    Copy-Item -Path $_.FullName -Destination $dest -Force
    $UpdatedCount++
}

Write-Host "  Updated:  $UpdatedCount"
Write-Host "  Skipped:  $SkippedCount (user_owned)"

# --- Skills updaten ---
Write-Host ""
Write-Host "Schritt 3: Skills updaten..." -ForegroundColor Yellow

$SkillsSrc = Join-Path $PackDir ".claude\skills"
Get-ChildItem $SkillsSrc -Directory | ForEach-Object {
    $skill = $_.Name
    $skillDest = Join-Path $SkillsDir $skill
    if (Test-Path $skillDest) {
        $skillFileBak = Join-Path $skillDest "SKILL.md.bak.$Timestamp"
        if (Test-Path (Join-Path $skillDest "SKILL.md")) {
            Copy-Item (Join-Path $skillDest "SKILL.md") $skillFileBak
        }
    }
    Copy-Item -Path $_.FullName -Destination $SkillsDir -Recurse -Force
    Write-Host "  - $skill"
}

# --- Config aktualisieren ---
$config.pack_version = $RemoteHead
$config | ConvertTo-Json | Out-File $ConfigFile -Encoding utf8

# --- Abschluss ---
Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "  Update abgeschlossen!           " -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""
Write-Host "Vorher:  $LocalBefore"
Write-Host "Nachher: $RemoteHead"
Write-Host "Files updated: $UpdatedCount"
Write-Host "User-Overrides geschuetzt: $SkippedCount"
Write-Host ""
Write-Host "Backups in: $WorkspacePath\**\*.bak.$Timestamp"
Write-Host "Rollback bei Problem: cp <file>.bak.$Timestamp <file>"
Write-Host ""
