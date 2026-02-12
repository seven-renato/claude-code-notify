#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "=== Claude Code Notify - Uninstall ==="
echo ""

# Remove hook scripts
if [[ -f "$HOOKS_DIR/finish.py" ]]; then
    rm "$HOOKS_DIR/finish.py"
    echo "Removed $HOOKS_DIR/finish.py"
fi

if [[ -f "$HOOKS_DIR/permission.py" ]]; then
    rm "$HOOKS_DIR/permission.py"
    echo "Removed $HOOKS_DIR/permission.py"
fi

# Remove hooks from settings.json
if [[ -f "$SETTINGS_FILE" ]]; then
    python3 - "$SETTINGS_FILE" <<'PYEOF'
import json
import sys

settings_path = sys.argv[1]

with open(settings_path, "r") as f:
    settings = json.load(f)

changed = False
if "hooks" in settings:
    for key in ["Stop", "PermissionRequest"]:
        if key in settings["hooks"]:
            del settings["hooks"][key]
            changed = True
    if not settings["hooks"]:
        del settings["hooks"]

if changed:
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
    print(f"Removed notification hooks from {settings_path}")
else:
    print("No notification hooks found in settings.")
PYEOF
fi

echo ""
echo "Uninstall complete! Restart Claude Code for changes to take effect."
