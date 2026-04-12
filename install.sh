#!/bin/bash
# Shepherd install script — sets up the shepherd agent on a new machine.
# Run from the repo root: bash install.sh
set -euo pipefail

SHEPHERD_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$HOME/scripts"
LAUNCHD_DIR="$HOME/Library/LaunchAgents"
CLAUDE_DIR="$HOME/.claude"
PLIST_LABEL="com.shepherd.agent"

echo "Installing shepherd from: $SHEPHERD_DIR"
echo ""

# 1. Check dependencies
for cmd in tmux claude; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' is not installed or not in PATH." >&2
    echo "  tmux:   brew install tmux" >&2
    echo "  claude: npm install -g @anthropic-ai/claude-code" >&2
    exit 1
  fi
done

# 2. Create scripts directory
mkdir -p "$SCRIPTS_DIR"

# 3. Copy scripts and make executable
for script in spawn-worker check-worker kill-worker start-shepherd; do
  cp "$SHEPHERD_DIR/scripts/${script}.sh" "$SCRIPTS_DIR/"
  chmod +x "$SCRIPTS_DIR/${script}.sh"
done

# 4. Substitute the shepherd dir into start-shepherd.sh
sed -i.bak "s|__SHEPHERD_DIR__|$SHEPHERD_DIR|g" "$SCRIPTS_DIR/start-shepherd.sh"
rm -f "$SCRIPTS_DIR/start-shepherd.sh.bak"

# 5. Install launchd plist (substitute HOME and SCRIPTS_DIR)
sed \
  -e "s|__HOME__|$HOME|g" \
  -e "s|__SCRIPTS_DIR__|$SCRIPTS_DIR|g" \
  "$SHEPHERD_DIR/launchd/com.shepherd.plist.template" \
  > "$LAUNCHD_DIR/$PLIST_LABEL.plist"

# 6. Create empty projects registry if not exists
if [ ! -f "$CLAUDE_DIR/projects-registry.json" ]; then
  echo '{
  "example-project": "/path/to/your/project"
}' > "$CLAUDE_DIR/projects-registry.json"
  echo "Created projects registry at $CLAUDE_DIR/projects-registry.json"
  echo "Edit it to add your projects before starting the shepherd."
  echo ""
fi

# 7. Load launchd agent
launchctl load "$LAUNCHD_DIR/$PLIST_LABEL.plist" 2>/dev/null || true

echo "Done! Shepherd installed."
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/projects-registry.json to add your projects"
echo "  2. Start the shepherd: launchctl start $PLIST_LABEL"
echo "  3. Attach to watch it: tmux attach -t shepherd"
echo "  4. Enable remote control inside Claude Code: /config → Enable Remote Control"
