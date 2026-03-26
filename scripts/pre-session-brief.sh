#!/bin/bash
# =============================================================================
# pre-session-brief.sh — Per-project pre-session briefing hook
# Injected by UserPromptSubmit hook in each project's .claude/settings.json
#
# Outputs a concise context block once per calendar day per project.
# On subsequent prompts the same day, outputs nothing (avoids repetition).
#
# Output is captured by Claude Code and injected as context before the
# user's message is processed.
# =============================================================================

# Accept project dir as first argument, or detect from cwd
PROJECT_DIR="${1:-$(pwd)}"
ORCHESTRATOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TODAY="$(date '+%Y-%m-%d')"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Only brief once per calendar day per project
MARKER="/tmp/claude-brief-${PROJECT_NAME}-${TODAY}"
if [ -f "$MARKER" ]; then
  exit 0
fi
touch "$MARKER"

# Collect context pieces
DIGEST_FILE="$ORCHESTRATOR_DIR/reports/daily/$TODAY/DAILY-DIGEST.md"
CHANGELOG="$PROJECT_DIR/CHANGELOG.md"
TASKS_FILE="$PROJECT_DIR/TASKS.md"

OUTPUT=""

# --- Today's digest (condensed) ---
if [ -f "$DIGEST_FILE" ]; then
  # Extract just the Urgent + Agenda sections to keep it brief
  DIGEST_SNIPPET=$(awk '
    /^## 🔴 Urgent/ { found=1 }
    /^## 📋 Project Updates/ { found=0 }
    found { print }
  ' "$DIGEST_FILE" | head -30)

  if [ -n "$DIGEST_SNIPPET" ]; then
    OUTPUT="${OUTPUT}
## Today's Digest Highlights (${TODAY})
${DIGEST_SNIPPET}
"
  fi
fi

# --- Recent changelog entries (last 3 days) ---
if [ -f "$CHANGELOG" ]; then
  CUTOFF=$(date -v-3d '+%Y-%m-%d' 2>/dev/null || date -d '3 days ago' '+%Y-%m-%d' 2>/dev/null)
  RECENT=$(awk -v cutoff="$CUTOFF" '
    /^## / {
      # Extract date from heading if present
      match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2}/, arr)
      if (arr[0] >= cutoff) { printing=1 } else { printing=0 }
    }
    printing { print }
  ' "$CHANGELOG" | head -20)

  if [ -n "$RECENT" ]; then
    OUTPUT="${OUTPUT}
## Recent Changelog (${PROJECT_NAME})
${RECENT}
"
  fi
fi

# --- Open tasks for this project ---
if [ -f "$TASKS_FILE" ]; then
  OPEN_TASKS=$(grep -E "^- \[ \]" "$TASKS_FILE" | head -10)
  if [ -n "$OPEN_TASKS" ]; then
    OUTPUT="${OUTPUT}
## Open Tasks (${PROJECT_NAME})
${OPEN_TASKS}
"
  fi
fi

# Output block (only if there's something to say)
if [ -n "$OUTPUT" ]; then
  echo "---"
  echo "**Pre-session context for ${PROJECT_NAME} — ${TODAY}**"
  echo "$OUTPUT"
  echo "---"
fi
