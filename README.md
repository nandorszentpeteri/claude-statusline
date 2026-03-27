# claude-statusline

A custom status line for [Claude Code](https://claude.ai/code) that shows model info, context usage, cost, working directory, and git branch.

## Preview

<p align="center">
  <img src="preview.svg" alt="Status line preview showing green, orange, and red context usage bars" width="720">
</p>

The progress bar changes color based on context window usage: **green** (<50%), **orange** (50–80%), **red** (>80%).

## Features

- Model name
- Context window usage with color-coded progress bar (green/orange/red)
- Session cost
- Shortened working directory
- Current git branch

## Requirements

- `jq` — install via `brew install jq` (macOS) or `apt install jq` (Linux)

## Install

```bash
git clone https://gitlab.eng.roku.com/nszentpeteri/claude-statusline.git
cd claude-statusline
bash install.sh
```

The install script will:

- **Back up** your existing `~/.claude/settings.json` (timestamped, e.g. `settings.json.backup.20260327120000`)
- Copy `statusline.sh` to `~/.claude/`
- Add the `statusLine` config to `settings.json`
- **Prompt before overriding** if a `statusLine` config already exists

Restart Claude Code to see the status line.

### Restore from backup

If something goes wrong, restore your previous settings:

```bash
# List backups
ls ~/.claude/settings.json.backup.*

# Restore the most recent one
cp "$(ls -t ~/.claude/settings.json.backup.* | head -1)" ~/.claude/settings.json
```

### Uninstall

```bash
rm ~/.claude/statusline.sh
```

Then remove the `"statusLine"` block from `~/.claude/settings.json`, or restore from a backup.

## Manual install

1. Copy `statusline.sh` to `~/.claude/statusline.sh`
2. Make it executable: `chmod +x ~/.claude/statusline.sh`
3. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```
