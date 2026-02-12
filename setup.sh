#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "=== Claude Code Notify - Setup ==="
echo ""

# Check macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script only works on macOS."
    exit 1
fi

# Check python3
if ! command -v python3 &>/dev/null; then
    echo "Error: python3 is required but not found."
    exit 1
fi

# Check system sounds exist
if [[ ! -d "/System/Library/Sounds" ]]; then
    echo "Error: macOS system sounds not found."
    exit 1
fi

# Backup existing settings.json
if [[ -f "$SETTINGS_FILE" ]]; then
    BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo "Backup saved to $BACKUP_FILE"
fi

# Create hooks directory
mkdir -p "$HOOKS_DIR"

# Copy hook scripts
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/hooks/finish.py" "$HOOKS_DIR/finish.py"
cp "$SCRIPT_DIR/hooks/permission.py" "$HOOKS_DIR/permission.py"
chmod +x "$HOOKS_DIR/finish.py" "$HOOKS_DIR/permission.py"

echo "Copied hook scripts to $HOOKS_DIR"

# Merge hooks into settings.json using Python (safe JSON manipulation)
python3 - "$SETTINGS_FILE" <<'PYEOF'
import json
import sys
import os

settings_path = sys.argv[1]

# Load existing settings or start fresh
if os.path.exists(settings_path):
    with open(settings_path, "r") as f:
        try:
            settings = json.load(f)
        except json.JSONDecodeError:
            print(f"Warning: {settings_path} has invalid JSON. Creating backup and starting fresh.")
            os.rename(settings_path, settings_path + ".bak")
            settings = {}
else:
    settings = {}

hooks_dir = os.path.expanduser("~/.claude/hooks")

new_hooks = {
    "Stop": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": f"python3 {hooks_dir}/finish.py",
                    "timeout": 15
                }
            ]
        }
    ],
    "PermissionRequest": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": f"python3 {hooks_dir}/permission.py",
                    "timeout": 10
                }
            ]
        }
    ]
}

# Merge: preserve existing hooks, add/overwrite ours
if "hooks" not in settings:
    settings["hooks"] = {}

settings["hooks"]["Stop"] = new_hooks["Stop"]
settings["hooks"]["PermissionRequest"] = new_hooks["PermissionRequest"]

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print(f"Updated {settings_path} with notification hooks.")
PYEOF

# Test sounds
echo ""
echo "Testing sounds..."
echo -n "  Task finished (Glass): "
python3 "$HOOKS_DIR/finish.py" && echo "OK"

sleep 0.5

echo -n "  Permission needed (Funk): "
python3 "$HOOKS_DIR/permission.py" && echo "OK"

echo ""
echo "Setup complete! Restart Claude Code for hooks to take effect."
echo ""
echo "Sounds can be customized by editing:"
echo "  $HOOKS_DIR/finish.py"
echo "  $HOOKS_DIR/permission.py"
echo ""
echo "Available macOS sounds:"
ls /System/Library/Sounds/ | sed 's/.aiff//' | sed 's/^/  - /'
