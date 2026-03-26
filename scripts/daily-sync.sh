#!/bin/bash
# =============================================================================
# daily-sync.sh — Orchestrator daily maintenance job
# Runs at 2:00 AM Muscat time (UTC+4) via crontab
# Syncs registries, runs health checks, writes status report
# =============================================================================

ORCHESTRATOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE="${CLAUDE_CMD:-$(command -v claude 2>/dev/null || echo 'claude')}"
LOG_DIR="$ORCHESTRATOR_DIR/reports"
RUN_LOG="$LOG_DIR/cron-run.log"

mkdir -p "$LOG_DIR"
cd "$ORCHESTRATOR_DIR" || exit 1

echo "" >> "$RUN_LOG"
echo "========================================" >> "$RUN_LOG"
echo "Daily sync started: $(date '+%Y-%m-%d %H:%M:%S')" >> "$RUN_LOG"
echo "========================================" >> "$RUN_LOG"

"$CLAUDE" --print \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
  --max-turns 30 \
  "You are the Orchestrator running the nightly maintenance job for this Claude Code orchestrator system. The date is $(date '+%Y-%m-%d') and the time is $(date '+%H:%M') Muscat time (UTC+4).

Your job has three parts. Complete all three before finishing.

---

## Part 1: Registry Sync

Scan every project in the \`projects/\` directory.

For each project:
- Read \`.claude/agents/\` — list any agent .md files not already registered in the master \`AGENTS.md\`
- Read \`.claude/skills/\` — list any skill directories not already registered in the master \`SKILLS.md\`
- If new agents or skills are found:
  - Add them to the master \`AGENTS.md\` under the appropriate section
  - Add them to the master \`SKILLS.md\`
  - Copy the agent .md file to \`templates/agents/\` if it doesn't exist there yet

Log what was synced (or 'no changes' if everything was already up to date).

---

## Part 2: Health Check

For each project in \`projects/\`:

Check that the following files exist:
- CLAUDE.md
- AGENTS.md
- SKILLS.md
- RULES.md
- CHANGELOG.md
- settings.json
- .claude/settings.json
- .claude/agents/team-lead.md

Also check:
- Does the project have at least one agent beyond team-lead?
- Is the \`settings.json\` valid JSON with a \`project.status\` field?
- Are there any TODO items or known issues noted in CLAUDE.md that have been sitting unaddressed?

Flag any missing files or issues as warnings.

---

## Part 3: Task Board Sync

For each project in \`projects/\`, read its \`TASKS.md\` file (if it exists).

Then update the orchestrator-level \`TASKS.md\`:
- Move newly completed tasks (marked \`- [x]\`) from per-project boards into the \`## ✅ Completed This Week\` section
- Move overdue urgent tasks (with a past \`#date\` tag) into the \`## 🔴 Urgent\` section if not already there
- Append any new backlog tasks from project files that aren't already in the orchestrator board
- Archive completed tasks older than 7 days into the \`## 📦 Archived\` section with a one-line entry

Never remove tasks that exist only at the orchestrator level. Only sync from projects → orchestrator.

---

## Part 4: Status Report

Read the \`CHANGELOG.md\` from every project and the parent orchestrator (if it has one). Extract any entries from the past 7 days.

Then write a dated report and **append** it to \`reports/workflow-log.md\` (create the file if it doesn't exist — never overwrite existing content).

The report must follow this format exactly:

\`\`\`
---

## Nightly Report — $(date '+%Y-%m-%d')
**Run time:** $(date '+%H:%M') Muscat time

### Registry Sync
[Summary of what was synced or 'No changes detected']

### Health Check

| Project | Status | Issues |
|---|---|---|
| [project-name] | ✓ Healthy / ⚠ Warning / ✗ Error | [issue or 'None'] |

### Task Board Sync
[Summary of task movements — new items, completed, archived. Or 'No changes']

### Changelog Summary (Last 7 Days)
[Per-project bullet summary of recent changes, or 'No entries in the past 7 days']

### Action Items
[Any issues that need operator attention, or 'None']

---
\`\`\`

After writing the report, print a brief summary to stdout so the cron log captures it.
" 2>&1 | tee -a "$RUN_LOG"

echo "" >> "$RUN_LOG"
echo "Daily sync finished: $(date '+%Y-%m-%d %H:%M:%S')" >> "$RUN_LOG"
