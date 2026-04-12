# Sauron AI

A persistent Claude Code orchestrator that runs on your laptop 24/7. Send tasks from your iPhone, watch agents work in tmux, get updates back on your phone.

```
[iPhone]
    ↕ Claude Code remote control
[Sauron AI]  ← always-on tmux window
    ├── spawns → [Worker: personal-website]  ← tmux window
    ├── spawns → [Worker: SAM-backend]       ← tmux window
    └── spawns → [Worker: ...]               ← tmux window
```

Workers communicate proactively — no polling. When a worker finishes, has an update, or needs clarification, it sends a message back to Sauron AI, which relays it to your phone.

---

## Requirements

- macOS
- [tmux](https://github.com/tmux/tmux) — `brew install tmux`
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) — `npm install -g @anthropic-ai/claude-code`
- Claude account with Pro/Max/Team/Enterprise (for remote control)

---

## Installation

```bash
git clone https://github.com/yourname/sauron-ai
cd sauron-ai
bash install.sh
```

The install script:
- Copies scripts to `~/scripts/`
- Installs a launchd agent (`com.sauron.agent`) that auto-starts Sauron AI on login
- Creates `~/.claude/projects-registry.json` if it doesn't exist

---

## Setup

### 1. Add your projects

Edit `~/.claude/projects-registry.json` to map friendly names to absolute paths:

```json
{
  "personal-website": "/Users/you/projects/my-website",
  "backend": "/Users/you/projects/my-backend"
}
```

Sauron AI reads this file at task time — no restart needed after edits.

### 2. Start Sauron AI

```bash
launchctl start com.sauron.agent
```

Or manually:

```bash
tmux new-session -s sauron -n sauron -c /path/to/sauron-ai
claude --dangerously-skip-permissions
```

### 3. Enable remote control

Attach to the sauron tmux session:

```bash
tmux attach -t sauron
```

Inside Claude Code, run `/config` and enable **Remote Control for all sessions**.

Detach with `Ctrl+b d` — Sauron AI stays running.

### 4. Connect from iPhone

Open the **Claude Code iOS app**, tap the session picker, and select the **sauron** session (green dot = online).

---

## Usage

Send tasks from your phone in this format:

```
personal-website: add a dark mode toggle to the homepage
```

Sauron AI will:
1. Look up the project path in the registry
2. Spawn a worker Claude Code agent in a new tmux window
3. The worker reads its instructions and starts the task
4. Worker sends updates/questions back via tmux — Sauron AI relays them to your phone

### Persistent conversations

If a worker window is already open for a project, sending another message forwards it directly — the worker keeps its full conversation context:

```
personal-website: actually, use CSS variables instead of Tailwind for the theming
```

### Commands

| Command | Action |
|---------|--------|
| `project-name: task` | Spawn worker or forward to existing one |
| `status` | Summary of all active workers |
| `stop project-name` | Kill a worker window |

---

## How worker communication works

Workers report back to Sauron AI by running bash commands:

```bash
# Progress update
tmux send-keys -t sauron:sauron "[project-name] update: what I'm doing" Enter

# Task complete
tmux send-keys -t sauron:sauron "[project-name] done: summary of what was done" Enter

# Need clarification
tmux send-keys -t sauron:sauron "[project-name] question: should I use X or Y?" Enter
```

These instructions are injected automatically into each worker when it spawns — you don't need to configure individual projects.

---

## Files

```
sauron-ai/
├── CLAUDE.md                          # Sauron AI identity and behaviour
├── install.sh                         # One-command setup
├── scripts/
│   ├── spawn-worker.sh                # Spawn a worker in a new tmux window
│   ├── check-worker.sh                # Capture worker pane output
│   ├── kill-worker.sh                 # Kill a worker and clean up
│   └── start-sauron.sh                # Bootstrap script (called by launchd)
└── launchd/
    └── com.sauron.plist.template      # launchd template (paths substituted by install.sh)
```

`~/.claude/projects-registry.json` is machine-specific and not committed.

---

## Watching workers

```bash
tmux attach -t sauron
```

Use `Ctrl+b n` / `Ctrl+b p` to switch between windows. Each worker runs in its own window — you can watch them code in real time.

---

## Auto-start on login

The launchd agent (`com.sauron.agent`) starts Sauron AI automatically when you log in. To disable:

```bash
launchctl unload ~/Library/LaunchAgents/com.sauron.agent.plist
```

To re-enable:

```bash
launchctl load ~/Library/LaunchAgents/com.sauron.agent.plist
```
