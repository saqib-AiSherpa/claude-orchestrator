#!/bin/bash
# =============================================================================
# morning-digest.sh — Orchestrator daily digest
# Runs at 9:00 AM Muscat time via crontab
#
# Auto-discovers all project reports written to reports/daily/{date}/
# No hardcoded project names — works with any number of projects.
# =============================================================================

ORCHESTRATOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE="${CLAUDE_CMD:-$(command -v claude 2>/dev/null || echo 'claude')}"
MCP_CONFIG="$ORCHESTRATOR_DIR/scripts/mcp-morning.json"
TODAY="$(date '+%Y-%m-%d')"
REPORT_DIR="$ORCHESTRATOR_DIR/reports/daily/$TODAY"
DIGEST_FILE="$REPORT_DIR/DAILY-DIGEST.md"
LOG_FILE="$ORCHESTRATOR_DIR/reports/cron-run.log"
WORKFLOW_LOG="$ORCHESTRATOR_DIR/reports/workflow-log.md"

mkdir -p "$REPORT_DIR"

echo "" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "Morning digest started: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# Collect all project reports written this morning (exclude the digest itself)
REPORT_FILES=$(find "$REPORT_DIR" -name "*.md" ! -name "DAILY-DIGEST.md" 2>/dev/null | sort)
REPORT_COUNT=$(echo "$REPORT_FILES" | grep -c ".md" 2>/dev/null || echo "0")

if [ -z "$REPORT_FILES" ] || [ "$REPORT_COUNT" -eq 0 ]; then
  echo "[$(date '+%H:%M:%S')] No project reports found in $REPORT_DIR — digest skipped." >> "$LOG_FILE"
  exit 0
fi

# Build a concatenated block of all reports for the prompt
REPORTS_CONTENT=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  REPORTS_CONTENT="${REPORTS_CONTENT}

=== $(basename "$f" .md) ===
$(cat "$f")
"
done <<< "$REPORT_FILES"

echo "[$(date '+%H:%M:%S')] Found $REPORT_COUNT project report(s). Synthesising digest..." >> "$LOG_FILE"

"$CLAUDE" --print \
  --mcp-config "$MCP_CONFIG" \
  --allowedTools "Read,Write,Glob,Grep,mcp__Gmail__gmail_search_messages,mcp__Gmail__gmail_read_thread,mcp__Google_Calendar__gcal_list_events,mcp__Google_Calendar__gcal_find_my_free_time" \
  --permission-mode bypassPermissions \
  --max-turns 30 \
  "You are the Orchestrator agent producing the daily morning digest for the operator.

TODAY: $(date '+%Y-%m-%d, %A')
TIME: $(date '+%H:%M') Muscat time (UTC+4)

---

## Input: Project Reports

The following reports were submitted by ${REPORT_COUNT} project(s) this morning:

${REPORTS_CONTENT}

---

## Your Task

Synthesise these reports into a single, coherent daily digest. Follow these rules:

**1. Categorise intelligently.**
Each project report uses a standard schema, but may also contain a '📥 New / Unexpected' section with items that didn't fit neatly. You must categorise those items into the most appropriate section of the final digest. If you genuinely can't categorise something, put it in 'Uncategorised' at the bottom.

**2. Merge and deduplicate.**
If multiple projects mention the same person, event, or issue — merge them into one item. Note which projects it spans.

**3. Check Google Calendar.**
Call \`gcal_list_events\` for today and tomorrow. Add any relevant meetings or deadlines to the Calendar section. If a calendar event is clearly related to a project in the reports, link them together.

**4. Rank everything.**
Within each section, order items by urgency/importance. Urgent blockers first, then high, then medium, then low.

**5. Be concise but complete.**
The operator reads this first thing in the morning. Lead with what needs action. Don't pad. Don't repeat project names unnecessarily.

---

## Output Format

Write the digest to: $DIGEST_FILE

\`\`\`markdown
# Daily Digest — $(date '+%Y-%m-%d, %A')
**Generated:** $(date '+%H:%M') Muscat time | **Projects:** {N} reports received

---

## 🔴 Urgent — Action Today
<!-- Cross-project urgent items, ranked. If none, omit section. -->

## 📅 Today's Agenda
<!-- Priority-ranked action items across all projects -->
<!-- Format: [PROJECT] [HIGH/MED/LOW] Description -->

## 📆 Calendar
<!-- Today's and tomorrow's meetings/deadlines. Source: Google Calendar + project reports. -->

## 📋 Project Updates
<!-- One brief paragraph or bullet list per project that had updates -->

## 🔁 Follow-ups Pending
<!-- Items waiting on someone or something, across all projects -->

## 📥 Newly Surfaced Items
<!-- Items from '📥 New / Unexpected' sections — categorised by you here -->
<!-- If you can categorise them above, do so and omit this section -->

## ✅ FYI Only
<!-- No-action items worth being aware of -->

## ❓ Uncategorised
<!-- Only use if you genuinely cannot categorise something -->

---
*Projects in this digest: {comma-separated list}*
*Full project reports: reports/daily/$(date '+%Y-%m-%d')/*
\`\`\`

After writing the digest, also append a summary entry to: $WORKFLOW_LOG

The entry should follow the same format as the nightly maintenance report, using this header:
\`## Morning Digest — $(date '+%Y-%m-%d')\`

Finally, print a one-line summary to stdout for the cron log.
" 2>&1 | tee -a "$LOG_FILE"

echo "Morning digest finished: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
