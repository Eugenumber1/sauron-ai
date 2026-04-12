#!/bin/bash
# Usage: spawn-worker.sh <window-name> <project-path> "<task>"
set -euo pipefail

WINDOW_NAME="$1"
PROJECT_PATH="$2"
TASK="$3"

# Verify project path exists
if [ ! -d "$PROJECT_PATH" ]; then
  echo "ERROR: Project path does not exist: $PROJECT_PATH" >&2
  exit 1
fi

# Verify sauron session exists
if ! tmux has-session -t sauron 2>/dev/null; then
  echo "ERROR: tmux session 'sauron' is not running" >&2
  exit 1
fi

# Write worker-specific communication instructions to a file
# (avoids quoting nightmares passing multi-line text via tmux send-keys)
cat > "$HOME/.claude/worker-${WINDOW_NAME}.md" << EOF
You are a worker agent managed by Sauron AI, a multi-agent tmux orchestrator.

Your project name: ${WINDOW_NAME}

## Communicating back to Sauron AI

After completing work, sending an update, or needing clarification, run a
bash command to send a message to the Sauron AI window:

Progress update:
  tmux send-keys -t sauron:sauron "[${WINDOW_NAME}] update: what you are doing" Enter

Task or subtask complete:
  tmux send-keys -t sauron:sauron "[${WINDOW_NAME}] done: one sentence summary" Enter

Need clarification from the user:
  tmux send-keys -t sauron:sauron "[${WINDOW_NAME}] question: your question" Enter

Sauron AI will relay your messages to the user's phone and forward
replies back to you as new messages in this window. Keep messages short.
EOF

# Open new window in sauron session
tmux new-window -t sauron -n "$WINDOW_NAME" -c "$PROJECT_PATH"

# Start Claude Code
tmux send-keys -t "sauron:$WINDOW_NAME" "claude --dangerously-skip-permissions" Enter

# Wait for Claude Code to boot
sleep 5

# Send task with instructions to read the setup file first
tmux send-keys -t "sauron:$WINDOW_NAME" "Read ~/.claude/worker-${WINDOW_NAME}.md for your operating context, then do this task: ${TASK}" Enter

echo "Worker '$WINDOW_NAME' started in $PROJECT_PATH"
