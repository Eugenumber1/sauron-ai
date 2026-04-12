#!/bin/bash
# Usage: check-worker.sh <window-name>
# Prints last 50 lines of the worker's tmux pane
set -euo pipefail

WINDOW_NAME="$1"

if ! tmux has-session -t sauron 2>/dev/null; then
  echo "ERROR: sauron session not running" >&2
  exit 1
fi

tmux capture-pane -t "sauron:$WINDOW_NAME" -p -S -50
