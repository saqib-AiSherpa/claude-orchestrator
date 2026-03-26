#!/bin/bash
# =============================================================================
# setup-morning-crons.sh — Wire up morning report crons for all projects
#
# SCALABLE: Run this whenever you add a new project.
# It scans projects/, deploys the morning-report.sh template to any project
# that doesn't have one, then updates crontab.
#
# Safe to re-run — never duplicates crontab entries.
# =============================================================================

ORCHESTRATOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECTS_DIR="$ORCHESTRATOR_DIR/projects"
TEMPLATE="$ORCHESTRATOR_DIR/scripts/templates/morning-report.sh"
DIGEST_SCRIPT="$ORCHESTRATOR_DIR/scripts/morning-digest.sh"

if [ ! -f "$TEMPLATE" ]; then
  echo "ERROR: Template not found at $TEMPLATE"
  exit 1
fi

echo ""
echo "=== Morning Cron Setup ==="
echo "Scanning: $PROJECTS_DIR"
echo ""

DEPLOYED=0
SKIPPED=0
CRON_LINES_ADDED=0

# Load existing crontab
EXISTING_CRONTAB=$(crontab -l 2>/dev/null || echo "")

# Start building the new crontab (without any morning-report lines, we'll re-add fresh)
NEW_CRONTAB=$(echo "$EXISTING_CRONTAB" | grep -v "morning-report.sh" | grep -v "morning-digest.sh")

# Add orchestrator digest line (always present)
NEW_CRONTAB="${NEW_CRONTAB}
0 9 * * * bash $DIGEST_SCRIPT"
CRON_LINES_ADDED=$((CRON_LINES_ADDED + 1))

# Process each project
for project_dir in "$PROJECTS_DIR"/*/; do
  [ -d "$project_dir" ] || continue

  project_name=$(basename "$project_dir")
  scripts_dir="$project_dir/scripts"
  report_script="$scripts_dir/morning-report.sh"

  # Create scripts/ dir if missing
  mkdir -p "$scripts_dir"

  # Deploy template if not already present
  if [ ! -f "$report_script" ]; then
    cp "$TEMPLATE" "$report_script"
    chmod +x "$report_script"
    echo "  ✓ Deployed morning-report.sh → $project_name"
    DEPLOYED=$((DEPLOYED + 1))
  else
    echo "  · Already exists → $project_name"
    SKIPPED=$((SKIPPED + 1))
  fi

  # Add crontab entry for this project
  NEW_CRONTAB="${NEW_CRONTAB}
45 8 * * * bash $report_script"
  CRON_LINES_ADDED=$((CRON_LINES_ADDED + 1))
done

# Write the new crontab
echo "$NEW_CRONTAB" | crontab -

echo ""
echo "=== Summary ==="
echo "  Scripts deployed:    $DEPLOYED"
echo "  Scripts already set: $SKIPPED"
echo "  Crontab entries:     $CRON_LINES_ADDED ($(( CRON_LINES_ADDED - 1 )) projects + 1 digest)"
echo ""
echo "Schedule:"
echo "  08:45 — All project morning reports run in parallel"
echo "  09:00 — Orchestrator digest collects & synthesises"
echo ""
echo "To add a new project: scaffold/ingest it, then re-run this script."
echo "To view crontab: crontab -l"
