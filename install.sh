#!/bin/bash
set -e

# Check dependencies
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required but not installed."
  echo "  macOS:  brew install jq"
  echo "  Linux:  apt install jq"
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "Error: git is required but not installed."
  exit 1
fi

CLAUDE_DIR="$HOME/.claude"
DEST="$CLAUDE_DIR/statusline.sh"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/statusline.sh"

if [ ! -f "$SOURCE" ]; then
  echo "Error: statusline.sh not found in $SCRIPT_DIR"
  exit 1
fi

# Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"

# Back up existing settings.json before any changes
if [ -f "$SETTINGS" ]; then
  BACKUP="$SETTINGS.backup.$(date +%Y%m%d%H%M%S)"
  cp "$SETTINGS" "$BACKUP"
  echo "Backed up $SETTINGS to $BACKUP"
fi

# Copy statusline script (overwrite if exists)
if [ -f "$DEST" ]; then
  echo "Overwriting existing $DEST"
fi
cp "$SOURCE" "$DEST"
chmod +x "$DEST"
echo "Installed statusline.sh to $DEST"

# Add statusLine config to settings.json
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Check if statusLine is already configured
if jq -e '.statusLine' "$SETTINGS" > /dev/null 2>&1; then
  echo ""
  echo "statusLine is already configured in $SETTINGS:"
  jq '.statusLine' "$SETTINGS"
  echo ""
  read -r -p "Override existing statusLine config? [y/N] " answer
  case "$answer" in
    [yY]|[yY][eE][sS])
      tmp=$(mktemp)
      if ! jq '.statusLine = {"type": "command", "command": "~/.claude/statusline.sh"}' "$SETTINGS" > "$tmp"; then
        rm -f "$tmp"
        echo "Error: failed to update $SETTINGS — is the file valid JSON?"
        exit 1
      fi
      mv "$tmp" "$SETTINGS"
      echo "Overrode statusLine config in $SETTINGS"
      ;;
    *)
      echo "Kept existing statusLine config"
      ;;
  esac
else
  tmp=$(mktemp)
  if ! jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$SETTINGS" > "$tmp"; then
    rm -f "$tmp"
    echo "Error: failed to update $SETTINGS — is the file valid JSON?"
    exit 1
  fi
  mv "$tmp" "$SETTINGS"
  echo "Added statusLine config to $SETTINGS"
fi

echo "Done! Restart Claude Code to see the status line."
