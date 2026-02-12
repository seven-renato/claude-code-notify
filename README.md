# Claude Code Notify

Audio notifications for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) on macOS.

Get notified with a sound when:
- **Task finishes** — so you know it's time to review the output
- **Permission is needed** — so you know Claude is waiting for your input

## Requirements

- macOS
- Python 3
- Claude Code CLI

## Install

```bash
git clone https://github.com/seven-renato/claude-code-notify
cd claude-code-notify
./setup.sh
```

Then restart Claude Code.

## Uninstall

```bash
./uninstall.sh
```

## Customize sounds

Edit the `SOUND` variable in `~/.claude/hooks/finish.py` or `~/.claude/hooks/permission.py`.

Available macOS system sounds:

| Sound | Vibe |
|-------|------|
| Basso | Low, serious |
| Blow | Soft puff |
| Bottle | Pop |
| Frog | Ribbit |
| Funk | Attention-grabbing (default: permission) |
| Glass | Clean chime (default: task finished) |
| Hero | Achievement unlocked |
| Morse | Dot-dash |
| Ping | Classic |
| Pop | Quick pop |
| Purr | Gentle vibration |
| Sosumi | Classic Mac alert |
| Submarine | Deep sonar |
| Tink | Light tap |

## How it works

Claude Code supports [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks), shell commands that run in response to events. This project configures two hooks in `~/.claude/settings.json`:

- **Stop** hook → plays a sound when Claude finishes responding
- **PermissionRequest** hook → plays a sound when Claude needs your approval
