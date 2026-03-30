#!/bin/bash
# spawn-team.sh — Run a Claude agent session as the claude-agent user
# Enables true parallel subagent spawning (bypasses root restriction on --dangerously-skip-permissions)
#
# Usage:
#   ./spawn-team.sh --cwd <project-dir> --prompt <prompt-text>
#   ./spawn-team.sh --cwd <project-dir> --prompt-file <path-to-prompt.txt>
#
# Examples:
#   ./spawn-team.sh --cwd "/root/Saqib Macbook Orchestration Folder/projects/business-ideas" \
#     --prompt "You are the Team Lead. Research and produce..."
#
#   ./spawn-team.sh --cwd "/root/Saqib Macbook Orchestration Folder/projects/ai-sherpa" \
#     --prompt-file /tmp/task-brief.txt

set -e

CLAUDE_USER="claude-agent"
CLAUDE_BIN="/root/.local/bin/claude"
CWD=""
PROMPT=""
PROMPT_FILE=""

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --cwd) CWD="$2"; shift 2 ;;
    --prompt) PROMPT="$2"; shift 2 ;;
    --prompt-file) PROMPT_FILE="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$CWD" ]]; then
  echo "Error: --cwd is required"
  exit 1
fi

if [[ -z "$PROMPT" && -z "$PROMPT_FILE" ]]; then
  echo "Error: --prompt or --prompt-file is required"
  exit 1
fi

if [[ -n "$PROMPT_FILE" ]]; then
  PROMPT=$(cat "$PROMPT_FILE")
fi

# Ensure claude-agent can write to the project directory
chown -R root:claude-agent "$CWD" 2>/dev/null || true
find "$CWD" -type d -exec chmod g+rwx {} \; 2>/dev/null || true
find "$CWD" -type f -exec chmod g+rw {} \; 2>/dev/null || true

# Run Claude as claude-agent with full subagent permissions
exec sudo -u "$CLAUDE_USER" -H bash -c "
  export HOME=/home/claude-agent
  export PATH='/root/.local/bin:\$PATH'
  export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
  cd $(printf '%q' "$CWD")
  '$CLAUDE_BIN' --dangerously-skip-permissions --print $(printf '%q' "$PROMPT")
"
