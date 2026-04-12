#!/bin/bash
# Bootstrap script called by launchd on login.
# Starts the shepherd tmux session if not already running.
# __SHEPHERD_DIR__ is replaced by install.sh with the actual repo path.

SESSION="shepherd"
SHEPHERD_DIR="__SHEPHERD_DIR__"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Shepherd session already running."
  exit 0
fi

# Create session with window named "shepherd" in the shepherd project dir
tmux new-session -d -s "$SESSION" -n "$SESSION" -c "$SHEPHERD_DIR"

# Launch Claude Code as the shepherd
tmux send-keys -t "$SESSION:$SESSION" "claude --dangerously-skip-permissions" Enter

echo "Shepherd started."
