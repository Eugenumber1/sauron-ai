#!/bin/bash
# Bootstrap script called by launchd on login.
# Starts the Sauron AI tmux session if not already running.
# __SAURON_DIR__ is replaced by install.sh with the actual repo path.

SESSION="sauron"
SAURON_DIR="__SAURON_DIR__"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Sauron AI session already running."
  exit 0
fi

# Create session with window named "sauron" in the sauron project dir
tmux new-session -d -s "$SESSION" -n "$SESSION" -c "$SAURON_DIR"

# Launch Claude Code as Sauron AI
tmux send-keys -t "$SESSION:$SESSION" "claude --dangerously-skip-permissions" Enter

echo "Sauron AI started."
