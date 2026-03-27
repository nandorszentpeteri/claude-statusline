#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
DEST="$CLAUDE_DIR/statusline.sh"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/statusline.sh"

# Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"

# Copy statusline script
cp "$SOURCE" "$DEST"
chmod +x "$DEST"
echo "Installed statusline.sh to $DEST"

# Add statusLine config to settings.json
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Check if statusLine is already configured
if jq -e '.statusLine' "$SETTINGS" > /dev/null 2>&1; then
  echo "statusLine already configured in $SETTINGS — skipping"
else
  tmp=$(mktemp)
  jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$SETTINGS" > "$tmp"
  mv "$tmp" "$SETTINGS"
  echo "Added statusLine config to $SETTINGS"
fi

echo "Done! Restart Claude Code to see the status line."
