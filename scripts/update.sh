#!/usr/bin/env bash
# Claude Architect Pack — Linux/macOS-Updater
#
# Aufruf: ./scripts/update.sh
# Oder via Skill: /update-architect-pack in Claude Code

set -e

echo ""
echo "=================================="
echo "  Claude Architect Pack Updater    "
echo "=================================="
echo ""

PACK_DIR="$HOME/claude-architect-pack"
CONFIG_FILE="$PACK_DIR/.install-config.json"

if [ ! -d "$PACK_DIR" ]; then
    echo "FEHLER: $PACK_DIR existiert nicht. Erst installieren: scripts/install.sh"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "FEHLER: .install-config.json fehlt. Re-Install noetig."
    exit 1
fi

# Parse Config (rudimentaer ohne jq-Pflicht)
get_config() {
    grep "\"$1\"" "$CONFIG_FILE" | sed 's/.*: *"\(.*\)".*/\1/'
}
WORKSPACE_PATH="$(get_config workspace_path)"
SKILLS_DIR="$(get_config skills_dir)"

echo "Workspace: $WORKSPACE_PATH"
echo "Skills:    $SKILLS_DIR"
echo ""

# --- Pre-Update-Check ---
cd "$PACK_DIR"
LOCAL_BEFORE=$(git rev-parse HEAD)
git fetch origin
REMOTE_HEAD=$(git rev-parse origin/main)

if [ "$LOCAL_BEFORE" = "$REMOTE_HEAD" ]; then
    echo "Pack ist bereits aktuell ($LOCAL_BEFORE)."
    exit 0
fi

echo "Update verfuegbar:"
echo "  Vorher:  $LOCAL_BEFORE"
echo "  Nachher: $REMOTE_HEAD"
echo ""
echo "Aenderungen:"
git log --oneline "$LOCAL_BEFORE..$REMOTE_HEAD" --no-merges | head -10
echo ""

read -r -p "Update durchfuehren? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ "$CONFIRM" =~ ^[Nn] ]]; then
    echo "Abgebrochen."
    exit 0
fi

# --- Pack-Repo updaten ---
echo ""
echo "Schritt 1: Pack-Repo updaten..."
git pull origin main

# --- Workspace-Files updaten ---
echo ""
echo "Schritt 2: Workspace-Template-Files updaten..."

TEMPLATE_DIR="$PACK_DIR/workspace-template"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
UPDATED_COUNT=0
SKIPPED_COUNT=0

cd "$TEMPLATE_DIR"
while IFS= read -r -d '' f; do
    REL="${f#./}"
    DEST="$WORKSPACE_PATH/$REL"

    # user_owned skip
    if [[ "$REL" =~ ^(CLAUDE\.user\.md|_user-overrides/|Projekte/|projects/|_runbooks/custom-|_runbooks/local-|_control/credentials-map\.md|_control/server-config\.md|_control/projects/) ]]; then
        ((SKIPPED_COUNT++)) || true
        continue
    fi

    if [ -f "$DEST" ]; then
        cp "$DEST" "$DEST.bak.$TIMESTAMP"
    else
        mkdir -p "$(dirname "$DEST")"
    fi

    cp "$f" "$DEST"
    ((UPDATED_COUNT++)) || true
done < <(find . -type f -print0)
cd - >/dev/null

echo "  Updated:  $UPDATED_COUNT"
echo "  Skipped:  $SKIPPED_COUNT (user_owned)"

# --- Skills updaten ---
echo ""
echo "Schritt 3: Skills updaten..."

for skill_dir in "$PACK_DIR/.claude/skills"/*/; do
    skill_name="$(basename "$skill_dir")"
    skill_dest="$SKILLS_DIR/$skill_name"
    if [ -f "$skill_dest/SKILL.md" ]; then
        cp "$skill_dest/SKILL.md" "$skill_dest/SKILL.md.bak.$TIMESTAMP"
    fi
    mkdir -p "$skill_dest"
    cp -r "$skill_dir"* "$skill_dest/"
    echo "  - $skill_name"
done

# --- Config aktualisieren ---
sed -i.bak "s/\"pack_version\".*/\"pack_version\":   \"$REMOTE_HEAD\"/" "$CONFIG_FILE"
rm -f "$CONFIG_FILE.bak"

# --- Abschluss ---
echo ""
echo "=================================="
echo "  Update abgeschlossen!           "
echo "=================================="
echo ""
echo "Vorher:  $LOCAL_BEFORE"
echo "Nachher: $REMOTE_HEAD"
echo "Files updated: $UPDATED_COUNT"
echo "User-Overrides geschuetzt: $SKIPPED_COUNT"
echo ""
echo "Backups in: $WORKSPACE_PATH/**/*.bak.$TIMESTAMP"
echo "Rollback bei Problem: cp <file>.bak.$TIMESTAMP <file>"
echo ""
