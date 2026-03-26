#!/bin/bash
# =============================================================================
# setup.sh — One-time setup for claude-orchestrator
#
# Run this once after cloning:
#   bash setup.sh
#
# What it does:
#   1. Asks for your name and timezone (writes to settings.json)
#   2. Verifies claude CLI is installed
#   3. Creates projects/ and reports/ directories
#   4. Deploys morning-report.sh to any existing projects
#   5. Registers all cron jobs
# =============================================================================

set -e

ORCHESTRATOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$ORCHESTRATOR_DIR/scripts"
SETTINGS_FILE="$ORCHESTRATOR_DIR/settings.json"
SETTINGS_EXAMPLE="$ORCHESTRATOR_DIR/settings.example.json"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║       Claude Orchestrator — Setup            ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# =============================================================================
# Step 1 — Personalisation
# =============================================================================

echo "Let's get you set up. A few quick questions:"
echo ""

# Name
read -r -p "  Your name (used in reports and digests): " USER_NAME
USER_NAME="${USER_NAME:-Operator}"

# Timezone
echo ""
echo "  Your timezone offset from UTC (for scheduling cron jobs)."
echo "  Examples: UTC+4 (Muscat/Dubai), UTC+0 (London), UTC-5 (New York), UTC+8 (Singapore)"
read -r -p "  Timezone (e.g. Asia/Muscat, Europe/London, America/New_York): " USER_TZ
USER_TZ="${USER_TZ:-UTC}"

# UTC offset for cron (we'll ask directly)
echo ""
echo "  What's your UTC offset? (e.g. +4 for Muscat, 0 for London, -5 for New York)"
read -r -p "  UTC offset (integer, e.g. 4): " UTC_OFFSET
UTC_OFFSET="${UTC_OFFSET:-0}"

echo ""
echo "  ✓ Name: $USER_NAME"
echo "  ✓ Timezone: $USER_TZ (UTC${UTC_OFFSET:0:1}${UTC_OFFSET})"
echo ""

# =============================================================================
# Step 2 — Write settings.json
# =============================================================================

if [ ! -f "$SETTINGS_EXAMPLE" ]; then
  echo "ERROR: settings.example.json not found. Is this a fresh clone?"
  exit 1
fi

python3 - <<PYEOF
import json, sys

with open('$SETTINGS_EXAMPLE') as f:
    d = json.load(f)

d['orchestrator']['owner'] = '$USER_NAME'
d['orchestrator']['timezone'] = '$USER_TZ'

with open('$SETTINGS_FILE', 'w') as f:
    json.dump(d, f, indent=2)

print("  ✓ settings.json written")
PYEOF

# =============================================================================
# Step 3 — Check claude CLI
# =============================================================================

echo ""
CLAUDE=$(command -v claude 2>/dev/null || echo "")
if [ -z "$CLAUDE" ]; then
  echo "ERROR: 'claude' not found in PATH."
  echo "Install Claude Code CLI from: https://claude.ai/code"
  echo "Then re-run this script."
  exit 1
fi
echo "  ✓ Claude CLI found: $CLAUDE"

# =============================================================================
# Step 4 — Create directories
# =============================================================================

mkdir -p "$ORCHESTRATOR_DIR/projects"
mkdir -p "$ORCHESTRATOR_DIR/reports/daily"
echo "  ✓ Directories ready (projects/, reports/)"

# =============================================================================
# Step 5 — Deploy morning report scripts to existing projects
# =============================================================================

PROJECT_COUNT=$(find "$ORCHESTRATOR_DIR/projects" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$PROJECT_COUNT" -gt 0 ]; then
  echo ""
  echo "  Found $PROJECT_COUNT project(s) — deploying morning report scripts..."
  bash "$SCRIPTS_DIR/setup-morning-crons.sh"
else
  echo "  ✓ No projects yet — morning scripts will deploy when you create your first project"
fi

# =============================================================================
# Step 6 — Register cron jobs (adjusted for user's timezone)
# =============================================================================

echo ""
echo "  Registering cron jobs..."

# Convert local times to UTC using the offset
# Nightly sync: 2am local
NIGHTLY_UTC=$(( (2 - UTC_OFFSET + 24) % 24 ))
# EOD digest: 7pm local
EOD_UTC=$(( (19 - UTC_OFFSET + 24) % 24 ))
# Morning digest: 9am local
MORNING_DIGEST_UTC=$(( (9 - UTC_OFFSET + 24) % 24 ))
# Morning reports: 8:45am local
MORNING_REPORT_UTC=$(( (8 - UTC_OFFSET + 24) % 24 ))
# Weekly entity scan: Sunday 10pm local
ENTITY_UTC=$(( (22 - UTC_OFFSET + 24) % 24 ))

EXISTING_CRON=$(crontab -l 2>/dev/null | grep -v "daily-sync\|morning-digest\|eod-digest\|weekly-entity" || echo "")

NEW_CRON="${EXISTING_CRON}
${MORNING_REPORT_UTC} 45 8 * * * # handled by setup-morning-crons.sh"

# Build crontab additions
CRON_ADDITIONS="
# Claude Orchestrator — added by setup.sh
${MORNING_DIGEST_UTC} 9 * * * bash $SCRIPTS_DIR/morning-digest.sh
${NIGHTLY_UTC} 2 * * * bash $SCRIPTS_DIR/daily-sync.sh
${EOD_UTC} 15 * * * bash $SCRIPTS_DIR/eod-digest.sh
${ENTITY_UTC} 18 * * 0 bash $SCRIPTS_DIR/weekly-entity-scan.sh"

# Actually: just use straightforward cron with computed UTC hours
CLEAN_ADDITIONS="
# Claude Orchestrator — added by setup.sh (${UTC_OFFSET:+UTC+}${UTC_OFFSET})
45 ${MORNING_REPORT_UTC} * * * bash $SCRIPTS_DIR/setup-morning-crons.sh
0 ${MORNING_DIGEST_UTC} * * * bash $SCRIPTS_DIR/morning-digest.sh
0 ${NIGHTLY_UTC} * * * bash $SCRIPTS_DIR/daily-sync.sh
0 ${EOD_UTC} * * * bash $SCRIPTS_DIR/eod-digest.sh
0 ${ENTITY_UTC} * * 0 bash $SCRIPTS_DIR/weekly-entity-scan.sh"

FINAL_CRON="${EXISTING_CRON}${CLEAN_ADDITIONS}"
echo "$FINAL_CRON" | crontab -

echo "  ✓ Cron jobs registered (times converted to UTC from your UTC+${UTC_OFFSET} timezone)"
echo ""
echo "  Schedule (your local time → UTC in crontab):"
echo "    08:45 daily  — per-project morning reports"
echo "    09:00 daily  — orchestrator morning digest"
echo "    19:00 daily  — EOD wrap-up digest"
echo "    02:00 daily  — nightly maintenance"
echo "    22:00 Sunday — weekly entity scan"

# =============================================================================
# Done
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║           Setup complete! ✓                  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  What's next:"
echo ""
echo "  1. Open Claude Code in this directory:"
echo "        claude"
echo ""
echo "  2. Create your first project:"
echo "        /project-scaffolder"
echo ""
echo "  3. Optional — richer morning digests (Gmail + Google Calendar):"
echo "        Connect your Google account at claude.ai/settings/connectors"
echo "        The MCP config is already at: scripts/mcp-morning.json"
echo ""
echo "  4. After adding new projects, re-run the cron deployer:"
echo "        bash scripts/setup-morning-crons.sh"
echo ""
echo "  Logs will appear in:  reports/cron-run.log"
echo "  Daily digests in:     reports/daily/{date}/"
echo ""
