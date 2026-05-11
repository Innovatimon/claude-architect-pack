#!/usr/bin/env bash
# Claude Architect Pack — Linux/macOS-Installer
#
# Aufruf:
#   curl -fsSL https://raw.githubusercontent.com/Innovatimon/claude-architect-pack/main/scripts/install.sh | bash
#
# oder lokal:
#   ./scripts/install.sh

set -e

echo ""
echo "=================================="
echo "  Claude Architect Pack Installer  "
echo "=================================="
echo ""

REPO_URL="https://github.com/Innovatimon/claude-architect-pack.git"
PACK_DIR="$HOME/claude-architect-pack"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

# --- Voraussetzungen ---
echo "Pruefe Voraussetzungen..."
command -v git >/dev/null 2>&1 || { echo "FEHLER: git nicht installiert."; exit 1; }
echo "  [OK] git verfuegbar"

# --- User-Fragen ---
echo ""
echo "Konfiguration:"
read -r -p "Workspace-Pfad [$HOME/my-workspace]: " WORKSPACE_PATH
WORKSPACE_PATH="${WORKSPACE_PATH:-$HOME/my-workspace}"

DEFAULT_NAME=$(basename "$WORKSPACE_PATH")
read -r -p "Workspace-Name [$DEFAULT_NAME]: " WORKSPACE_NAME
WORKSPACE_NAME="${WORKSPACE_NAME:-$DEFAULT_NAME}"

read -r -p "Skills global installieren (~/.claude/skills/)? [Y/n]: " GLOBAL_SKILLS
GLOBAL_SKILLS="${GLOBAL_SKILLS:-Y}"
if [[ "$GLOBAL_SKILLS" =~ ^[Yy] ]]; then
    TARGET_SKILLS_DIR="$SKILLS_DIR"
else
    TARGET_SKILLS_DIR="$WORKSPACE_PATH/.claude/skills"
fi

echo ""
echo "Geplante Installation:"
echo "  Repo:           $PACK_DIR"
echo "  Workspace:      $WORKSPACE_PATH"
echo "  Workspace-Name: $WORKSPACE_NAME"
echo "  Skills-Pfad:    $TARGET_SKILLS_DIR"
echo ""

read -r -p "Fortfahren? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ "$CONFIRM" =~ ^[Nn] ]]; then
    echo "Abgebrochen."
    exit 0
fi

# --- Repo klonen / updaten ---
echo ""
echo "Schritt 1: Repo holen..."
if [ -d "$PACK_DIR" ]; then
    echo "  $PACK_DIR existiert, pulle Updates..."
    git -C "$PACK_DIR" fetch origin
    git -C "$PACK_DIR" pull origin main
else
    echo "  Klone $REPO_URL ..."
    git clone "$REPO_URL" "$PACK_DIR"
fi

# --- Workspace anlegen ---
echo ""
echo "Schritt 2: Workspace anlegen..."
mkdir -p "$WORKSPACE_PATH"
echo "  Workspace: $WORKSPACE_PATH"

# --- Workspace-Template kopieren ---
echo ""
echo "Schritt 3: Workspace-Template kopieren..."

TEMPLATE_DIR="$PACK_DIR/workspace-template"

cd "$TEMPLATE_DIR"
find . -type f -print0 | while IFS= read -r -d '' f; do
    REL="${f#./}"
    DEST="$WORKSPACE_PATH/$REL"

    # user_owned skip
    if [[ "$REL" =~ ^(CLAUDE\.user\.md|_user-overrides/|Projekte/|projects/) ]] && [ -f "$DEST" ]; then
        echo "  [skip user_owned] $REL"
        continue
    fi

    mkdir -p "$(dirname "$DEST")"
    cp "$f" "$DEST"
done
cd - >/dev/null

# --- CLAUDE.user.md anlegen falls fehlt ---
if [ ! -f "$WORKSPACE_PATH/CLAUDE.user.md" ] && [ -f "$WORKSPACE_PATH/CLAUDE.user.md.example" ]; then
    cp "$WORKSPACE_PATH/CLAUDE.user.md.example" "$WORKSPACE_PATH/CLAUDE.user.md"
    echo "  CLAUDE.user.md aus Example erstellt"
fi

# --- Skills installieren ---
echo ""
echo "Schritt 4: Skills installieren..."
mkdir -p "$TARGET_SKILLS_DIR"
cp -r "$PACK_DIR/.claude/skills/." "$TARGET_SKILLS_DIR/"

SKILL_COUNT=$(ls -d "$TARGET_SKILLS_DIR"/*/ 2>/dev/null | wc -l)
echo "  Skills installiert: $SKILL_COUNT"
ls -d "$TARGET_SKILLS_DIR"/*/ 2>/dev/null | while read -r d; do
    echo "    - $(basename "$d")"
done

# --- Install-Config schreiben ---
echo ""
echo "Schritt 5: Install-Config speichern..."
PACK_VERSION=$(git -C "$PACK_DIR" rev-parse HEAD)
cat > "$PACK_DIR/.install-config.json" <<EOF
{
  "workspace_path": "$WORKSPACE_PATH",
  "workspace_name": "$WORKSPACE_NAME",
  "skills_dir":     "$TARGET_SKILLS_DIR",
  "installed_at":   "$(date '+%Y-%m-%d %H:%M:%S')",
  "pack_version":   "$PACK_VERSION"
}
EOF

# --- Optional: Workspace als git-Repo ---
echo ""
read -r -p "Workspace als git-Repo initialisieren? [y/N]: " INIT_GIT
INIT_GIT="${INIT_GIT:-N}"
if [[ "$INIT_GIT" =~ ^[Yy] ]]; then
    if [ ! -d "$WORKSPACE_PATH/.git" ]; then
        cd "$WORKSPACE_PATH"
        git init
        git add .
        git commit -m "init: Architect Pack installation"
        cd - >/dev/null
        echo "  Git-Repo initialisiert"
    else
        echo "  Git-Repo existiert bereits"
    fi
fi

# --- Abschluss ---
echo ""
echo "=================================="
echo "  Installation abgeschlossen!     "
echo "=================================="
echo ""
echo "Naechste Schritte:"
echo "  1. cd \"$WORKSPACE_PATH\""
echo "  2. claude"
echo "  3. Im Prompt: \"Initiiere dich\""
echo ""
echo "User-Overrides bearbeiten:"
echo "  $WORKSPACE_PATH/CLAUDE.user.md"
echo ""
echo "Updates spaeter holen:"
echo "  In Claude: /update-architect-pack"
echo "  Oder: $PACK_DIR/scripts/update.sh"
echo ""
