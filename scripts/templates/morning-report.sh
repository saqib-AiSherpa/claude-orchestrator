#!/bin/bash
# =============================================================================
# morning-report.sh — Generic per-project morning intelligence report
# Deployed to: {project}/scripts/morning-report.sh
# Runs at 8:45 AM Muscat time via crontab
#
# Scalability design: this script is IDENTICAL across all projects.
# It adapts intelligently by reading the project's own settings.json and
# exploring the directory. No project-specific hardcoding.
# =============================================================================

# Resolve paths relative to this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ORCHESTRATOR_DIR="$(cd "$PROJECT_DIR/../.." && pwd)"

CLAUDE="${CLAUDE_CMD:-$(command -v claude 2>/dev/null || echo 'claude')}"
MCP_CONFIG="$ORCHESTRATOR_DIR/scripts/mcp-morning.json"
TODAY="$(date '+%Y-%m-%d')"
REPORT_DIR="$ORCHESTRATOR_DIR/reports/daily/$TODAY"
LOG_DIR="$ORCHESTRATOR_DIR/reports"

# Read project name from settings.json (fallback to directory name)
if command -v python3 &>/dev/null && [ -f "$PROJECT_DIR/settings.json" ]; then
  PROJECT_NAME=$(python3 -c "import json,sys; d=json.load(open('$PROJECT_DIR/settings.json')); print(d.get('project',{}).get('name',''))" 2>/dev/null)
fi
PROJECT_NAME="${PROJECT_NAME:-$(basename "$PROJECT_DIR")}"

REPORT_FILE="$REPORT_DIR/${PROJECT_NAME}.md"

mkdir -p "$REPORT_DIR"
mkdir -p "$LOG_DIR"

echo "[$(date '+%H:%M:%S')] Morning report starting: $PROJECT_NAME" >> "$LOG_DIR/cron-run.log"

"$CLAUDE" --print \
  --mcp-config "$MCP_CONFIG" \
  --allowedTools "Read,Write,Glob,Grep,Bash,mcp__Gmail__gmail_search_messages,mcp__Gmail__gmail_read_thread,mcp__Gmail__gmail_read_message,mcp__Google_Calendar__gcal_list_events,mcp__Google_Calendar__gcal_get_event" \
  --permission-mode bypassPermissions \
  --max-turns 40 \
  "You are generating a morning intelligence report for a project in a Claude Code orchestrator system.

TODAY: $(date '+%Y-%m-%d, %A')
TIME: $(date '+%H:%M') Muscat time (UTC+4)
PROJECT DIRECTORY: $PROJECT_DIR

---

## Your Task

Generate a morning report for this project. The report will be collected by an orchestrator agent at 9:00 AM and synthesised into a daily digest for the operator.

**Important:** You must adapt to whatever you find. Do not assume a fixed structure. Explore the project first, understand what it is and what data sources it has, then decide what is relevant to report.

---

## Step 1: Understand the Project

Read the following in order:
1. \`settings.json\` — get the project name, type, and description
2. \`CLAUDE.md\` — understand what this project does and its current state
3. \`CHANGELOG.md\` — check for any recent entries (last 7 days)
4. \`AGENTS.md\` — understand who is working on what

---

## Step 2: Gather Intelligence

Based on what you found in Step 1, decide which of the following apply and execute them:

**For any project:**
- Scan for TODO items, known issues, or open items mentioned in CLAUDE.md or other markdown files
- Check CHANGELOG for activity since yesterday

**If this is a dev project** (type: dev):
- Look for open issues or bugs mentioned in CLAUDE.md or README
- Check if there are any failing build indicators or error screenshots

**If this is a business or consulting project** (type: business):
- Look for upcoming milestones or deadlines mentioned in any project files
- Check for pending decisions or blockers

**If this project contains communication data** (email logs, WhatsApp exports, filing logs, JSON logs of any kind):
- Read the most recent log file(s) to understand what came in recently
- Flag any items that need attention

**Use Gmail MCP** if:
- The project's CLAUDE.md or settings indicate it involves email processing, correspondence management, or entity/document management
- Search for emails from the last 24 hours relevant to this project's domain (use context from CLAUDE.md to form the right search query)

**Use Google Calendar MCP** if:
- The project mentions any stakeholders, meetings, or scheduled events
- Search for calendar events today and tomorrow that may be relevant to this project

---

## Step 3: Write the Report

Write the following report to the file: $REPORT_FILE

Use EXACTLY this format. Only include sections that have content — omit empty sections entirely.

\`\`\`markdown
## Morning Report — $PROJECT_NAME — $(date '+%Y-%m-%d')
**Generated:** $(date '+%H:%M') Muscat time
**Project type:** {type from settings.json}
**Source signals:** {brief list of what you read/queried to generate this}

### 🔴 Urgent / Blockers
<!-- Items needing same-day attention. Omit section if none. -->

### 📅 Agenda Items
<!-- Priority-ranked action items. Format: [HIGH/MED/LOW] description -->
<!-- Omit section if none. -->

### 📆 Calendar
<!-- Meetings, deadlines, events relevant to this project today/tomorrow -->
<!-- Omit section if none. -->

### 📋 Project Updates
<!-- What changed or progressed since yesterday -->
<!-- Omit section if none. -->

### 🔁 Follow-ups
<!-- Items waiting on a person, decision, or external event -->
<!-- Omit section if none. -->

### 📥 New / Unexpected
<!-- Anything found that doesn't fit the above — the orchestrator will categorise this -->
<!-- Omit section if none. -->

### ✅ No Action Needed
<!-- FYI items only — things to be aware of but that require no response -->
<!-- Omit section if none. -->
\`\`\`

After writing the file, print one line to stdout: \"[DONE] {project_name}: {N} items found\"
" 2>&1 | tee -a "$LOG_DIR/cron-run.log"

echo "[$(date '+%H:%M:%S')] Morning report finished: $PROJECT_NAME" >> "$LOG_DIR/cron-run.log"
