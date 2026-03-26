#!/bin/bash
# =============================================================================
# eod-digest.sh — Orchestrator end-of-day wrap-up digest
# Runs at 7:00 PM Muscat time (15:00 UTC) via crontab
#
# Reads today's project reports and morning digest, then synthesises an
# EOD summary: what got done, what's outstanding, tomorrow's priorities.
# =============================================================================

ORCHESTRATOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE="${CLAUDE_CMD:-$(command -v claude 2>/dev/null || echo 'claude')}"
MCP_CONFIG="$ORCHESTRATOR_DIR/scripts/mcp-morning.json"
TODAY="$(date '+%Y-%m-%d')"
REPORT_DIR="$ORCHESTRATOR_DIR/reports/daily/$TODAY"
EOD_FILE="$REPORT_DIR/EOD-DIGEST.md"
LOG_FILE="$ORCHESTRATOR_DIR/reports/cron-run.log"
WORKFLOW_LOG="$ORCHESTRATOR_DIR/reports/workflow-log.md"
TASKS_FILE="$ORCHESTRATOR_DIR/TASKS.md"

mkdir -p "$REPORT_DIR"

echo "" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "EOD digest started: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# Collect today's morning digest (if it exists)
MORNING_DIGEST=""
if [ -f "$REPORT_DIR/DAILY-DIGEST.md" ]; then
  MORNING_DIGEST=$(cat "$REPORT_DIR/DAILY-DIGEST.md")
fi

# Collect all project reports written today
REPORT_FILES=$(find "$REPORT_DIR" -name "*.md" ! -name "DAILY-DIGEST.md" ! -name "EOD-DIGEST.md" 2>/dev/null | sort)
REPORT_COUNT=$(echo "$REPORT_FILES" | grep -c ".md" 2>/dev/null || echo "0")

REPORTS_CONTENT=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  REPORTS_CONTENT="${REPORTS_CONTENT}

=== $(basename "$f" .md) ===
$(cat "$f")
"
done <<< "$REPORT_FILES"

# Read task board if it exists
TASKS_CONTENT=""
if [ -f "$TASKS_FILE" ]; then
  TASKS_CONTENT=$(cat "$TASKS_FILE")
fi

echo "[$(date '+%H:%M:%S')] Synthesising EOD wrap-up..." >> "$LOG_FILE"

"$CLAUDE" --print \
  --mcp-config "$MCP_CONFIG" \
  --allowedTools "Read,Write,Glob,Grep,mcp__Google_Calendar__gcal_list_events,mcp__Google_Calendar__gcal_find_my_free_time" \
  --permission-mode bypassPermissions \
  --max-turns 20 \
  "You are the Orchestrator generating the end-of-day wrap-up digest for the operator.

TODAY: $(date '+%Y-%m-%d, %A')
TIME: $(date '+%H:%M') Muscat time (UTC+4)

---

## Morning Digest (for reference — what was planned this morning)

${MORNING_DIGEST:-No morning digest found for today.}

---

## Project Reports from Today

${REPORTS_CONTENT:-No project reports found for today.}

---

## Current Task Board

${TASKS_CONTENT:-No TASKS.md found.}

---

## Your Task

Generate an end-of-day wrap-up. Compare what was planned this morning vs what actually happened. Focus on:

**1. What got done today?**
Cross-reference morning agenda items against any changelog entries or completed tasks. Be specific — \"[PROJECT] completed X\" not vague summaries.

**2. What's outstanding?**
Items from the morning agenda that were NOT completed today. These roll over.

**3. Blockers or surprises.**
Anything unexpected that came up. Issues that need attention tomorrow.

**4. Tomorrow's priorities.**
Based on outstanding items + any calendar events — what should the operator focus on first tomorrow?

**Check Google Calendar** for any events tomorrow that should inform priorities.

---

## Output Format

Write the digest to: $EOD_FILE

\`\`\`markdown
# EOD Digest — $(date '+%Y-%m-%d, %A')
**Generated:** $(date '+%H:%M') Muscat time | **Projects covered:** {N}

---

## ✅ Completed Today
<!-- What was actually done. Per-project if relevant. Omit if nothing to report. -->

## 🔁 Outstanding — Rolls to Tomorrow
<!-- Items from morning agenda not completed. Priority-ranked. -->

## ⚠️ Blockers & Surprises
<!-- Unexpected issues. Things that need attention. Omit if none. -->

## 🌅 Tomorrow's Priorities
<!-- Top 3-5 things to tackle first. Include calendar context. -->

## 📆 Tomorrow's Calendar
<!-- Meetings and deadlines from Google Calendar. -->

---
*Full reports: reports/daily/$(date '+%Y-%m-%d')/*
\`\`\`

After writing the digest, also append a summary entry to: $WORKFLOW_LOG

Use this header: \`## EOD Digest — $(date '+%Y-%m-%d')\`

Then print a one-line summary to stdout.
" 2>&1 | tee -a "$LOG_FILE"

echo "EOD digest finished: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
