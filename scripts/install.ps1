# Claude Architect Pack — Windows-Installer (PowerShell)
#
# Aufruf:
#   iwr -useb https://raw.githubusercontent.com/Innovatimon/claude-architect-pack/main/scripts/install.ps1 | iex
#
# oder lokal:
#   .\scripts\install.ps1

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Claude Architect Pack Installer  " -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# --- Konfiguration ---
$RepoUrl     = "https://github.com/Innovatimon/claude-architect-pack.git"
$PackDir     = Join-Path $HOME "claude-architect-pack"
$ClaudeDir   = Join-Path $HOME ".claude"
$SkillsDir   = Join-Path $ClaudeDir "skills"

# --- Voraussetzungen ---
Write-Host "Pruefe Voraussetzungen..." -ForegroundColor Yellow

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "FEHLER: git nicht installiert. Bitte installiere git: https://git-scm.com/" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] git verfuegbar"

# --- User-Fragen ---
Write-Host ""
Write-Host "Konfiguration:" -ForegroundColor Yellow

$DefaultWorkspace = Join-Path $HOME "my-workspace"
$WorkspacePath = Read-Host "Workspace-Pfad [$DefaultWorkspace]"
if ([string]::IsNullOrWhiteSpace($WorkspacePath)) { $WorkspacePath = $DefaultWorkspace }

$DefaultName = Split-Path $WorkspacePath -Leaf
$WorkspaceName = Read-Host "Workspace-Name [$DefaultName]"
if ([string]::IsNullOrWhiteSpace($WorkspaceName)) { $WorkspaceName = $DefaultName }

$GlobalSkills = Read-Host "Skills global installieren (~/.claude/skills/)? [Y/n]"
if ([string]::IsNullOrWhiteSpace($GlobalSkills)) { $GlobalSkills = "Y" }
$IsGlobal = $GlobalSkills -match "^[Yy]"

$TargetSkillsDir = if ($IsGlobal) { $SkillsDir } else { Join-Path $WorkspacePath ".claude\skills" }

Write-Host ""
Write-Host "Geplante Installation:" -ForegroundColor Yellow
Write-Host "  Repo:           $PackDir"
Write-Host "  Workspace:      $WorkspacePath"
Write-Host "  Workspace-Name: $WorkspaceName"
Write-Host "  Skills-Pfad:    $TargetSkillsDir"
Write-Host ""

$Confirm = Read-Host "Fortfahren? [Y/n]"
if ($Confirm -match "^[Nn]") {
    Write-Host "Abgebrochen." -ForegroundColor Yellow
    exit 0
}

# --- Repo klonen / updaten ---
Write-Host ""
Write-Host "Schritt 1: Repo holen..." -ForegroundColor Yellow

if (Test-Path $PackDir) {
    Write-Host "  $PackDir existiert, pulle Updates..."
    Push-Location $PackDir
    git fetch origin
    git pull origin main
    Pop-Location
} else {
    Write-Host "  Klone $RepoUrl ..."
    git clone $RepoUrl $PackDir
}

# --- Workspace anlegen ---
Write-Host ""
Write-Host "Schritt 2: Workspace anlegen..." -ForegroundColor Yellow

if (-not (Test-Path $WorkspacePath)) {
    New-Item -ItemType Directory -Path $WorkspacePath -Force | Out-Null
    Write-Host "  Workspace-Pfad erstellt: $WorkspacePath"
} else {
    Write-Host "  Workspace existiert bereits: $WorkspacePath"
}

# --- Workspace-Template kopieren ---
Write-Host ""
Write-Host "Schritt 3: Workspace-Template kopieren..." -ForegroundColor Yellow

$TemplateDir = Join-Path $PackDir "workspace-template"
Get-ChildItem $TemplateDir -Recurse -Force | ForEach-Object {
    $rel = $_.FullName.Substring($TemplateDir.Length + 1)
    $dest = Join-Path $WorkspacePath $rel

    if ($_.PSIsContainer) {
        if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
    } else {
        # Skip if user_owned and already exists (siehe MANIFEST.yml)
        $isUserOwned = $rel -match "^(CLAUDE\.user\.md|_user-overrides[/\\]|Projekte[/\\]|projects[/\\])"
        if ($isUserOwned -and (Test-Path $dest)) {
            Write-Host "  [skip user_owned] $rel" -ForegroundColor DarkGray
            return
        }
        $destDir = Split-Path $dest -Parent
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Copy-Item -Path $_.FullName -Destination $dest -Force
    }
}

# --- CLAUDE.user.md anlegen falls fehlt ---
$ClaudeUserMd = Join-Path $WorkspacePath "CLAUDE.user.md"
$ClaudeUserExample = Join-Path $WorkspacePath "CLAUDE.user.md.example"
if (-not (Test-Path $ClaudeUserMd) -and (Test-Path $ClaudeUserExample)) {
    Copy-Item $ClaudeUserExample $ClaudeUserMd
    Write-Host "  CLAUDE.user.md aus Example erstellt" -ForegroundColor Green
}

# --- Skills installieren ---
Write-Host ""
Write-Host "Schritt 4: Skills installieren..." -ForegroundColor Yellow

if (-not (Test-Path $TargetSkillsDir)) {
    New-Item -ItemType Directory -Path $TargetSkillsDir -Force | Out-Null
}

$SkillsSrc = Join-Path $PackDir ".claude\skills"
Copy-Item -Path (Join-Path $SkillsSrc "*") -Destination $TargetSkillsDir -Recurse -Force

$InstalledSkills = Get-ChildItem $TargetSkillsDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } | Select-Object -ExpandProperty Name
Write-Host "  Skills installiert: $($InstalledSkills.Count)"
$InstalledSkills | ForEach-Object { Write-Host "    - $_" -ForegroundColor DarkGray }

# --- Install-Config schreiben ---
Write-Host ""
Write-Host "Schritt 5: Install-Config speichern..." -ForegroundColor Yellow

$config = @{
    workspace_path = $WorkspacePath
    workspace_name = $WorkspaceName
    skills_dir     = $TargetSkillsDir
    installed_at   = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    pack_version   = (git -C $PackDir rev-parse HEAD)
} | ConvertTo-Json
$config | Out-File (Join-Path $PackDir ".install-config.json") -Encoding utf8

# --- Optional: Workspace als git-Repo ---
Write-Host ""
$InitGit = Read-Host "Workspace als git-Repo initialisieren? [y/N]"
if ($InitGit -match "^[Yy]") {
    Push-Location $WorkspacePath
    if (-not (Test-Path ".git")) {
        git init
        git add .
        git commit -m "init: Architect Pack installation"
        Write-Host "  Git-Repo initialisiert" -ForegroundColor Green
    } else {
        Write-Host "  Git-Repo existiert bereits" -ForegroundColor DarkGray
    }
    Pop-Location
}

# --- Abschluss ---
Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "  Installation abgeschlossen!     " -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""
Write-Host "Naechste Schritte:" -ForegroundColor Yellow
Write-Host "  1. cd `"$WorkspacePath`""
Write-Host "  2. claude"
Write-Host "  3. Im Prompt: `"Initiiere dich`""
Write-Host ""
Write-Host "User-Overrides bearbeiten:"
Write-Host "  $ClaudeUserMd"
Write-Host ""
Write-Host "Updates spaeter holen:"
Write-Host "  In Claude: /update-architect-pack"
Write-Host "  Oder: $PackDir\scripts\update.ps1"
Write-Host ""
