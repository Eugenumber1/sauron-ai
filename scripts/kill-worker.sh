#!/bin/bash
# Usage: kill-worker.sh <window-name>
set -euo pipefail

WINDOW_NAME="$1"

if tmux list-windows -t sauron -F "#{window_name}" 2>/dev/null | grep -q "^${WINDOW_NAME}$"; then
  tmux kill-window -t "sauron:$WINDOW_NAME"
  rm -f "$HOME/.claude/worker-${WINDOW_NAME}.md"
  echo "Killed worker: $WINDOW_NAME"
else
  echo "No window named '$WINDOW_NAME' in sauron session"
fi
