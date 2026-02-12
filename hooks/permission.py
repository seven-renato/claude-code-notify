#!/usr/bin/env python3
"""Play a notification sound when Claude Code needs permission or input."""
import subprocess
import sys

SOUND = "/System/Library/Sounds/Funk.aiff"

try:
    subprocess.run(["afplay", SOUND], check=True, timeout=10)
except Exception as e:
    print(f"Could not play sound: {e}", file=sys.stderr)
