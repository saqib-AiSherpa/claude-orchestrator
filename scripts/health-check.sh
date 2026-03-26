#!/usr/bin/env bash
# health-check.sh — Scan all projects and report their status
#
# Usage: ./scripts/health-check.sh
#
# Generates a health report for all active projects.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECTS_DIR="$ROOT_DIR/projects"
REPORTS_DIR="$ROOT_DIR/reports"
TODAY=$(date -u +"%Y-%m-%d")
REPORT_FILE="$REPORTS_DIR/weekly-health-${TODAY}.md"

mkdir -p "$REPORTS_DIR"

echo "# Weekly Health Check — $TODAY" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

PROJECT_COUNT=0
ACTIVE_COUNT=0
STALE_COUNT=0

for PROJECT_DIR in "$PROJECTS_DIR"/*/; do
  if [[ ! -d "$PROJECT_DIR" ]]; then continue; fi
  
  PROJECT_NAME=$(basename "$PROJECT_DIR")
  PROJECT_COUNT=$((PROJECT_COUNT + 1))
  
  echo "## $PROJECT_NAME" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  
  # Read project settings
  if [[ -f "$PROJECT_DIR/settings.json" ]]; then
    STATUS=$(python3 -c "import json; print(json.load(open('$PROJECT_DIR/settings.json')).get('project',{}).get('status','unknown'))" 2>/dev/null || echo "unknown")
    TYPE=$(python3 -c "import json; print(json.load(open('$PROJECT_DIR/settings.json')).get('project',{}).get('type','unknown'))" 2>/dev/null || echo "unknown")
    echo "- **Status**: $STATUS" >> "$REPORT_FILE"
    echo "- **Type**: $TYPE" >> "$REPORT_FILE"
    
    if [[ "$STATUS" == "active" ]]; then
      ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
    fi
  fi
  
  # Check for recent file activity
  LAST_MODIFIED=$(find "$PROJECT_DIR" -name "*.md" -o -name "*.json" -o -name "*.py" -o -name "*.js" -o -name "*.ts" | head -20 | xargs ls -t 2>/dev/null | head -1)
  if [[ -n "$LAST_MODIFIED" ]]; then
    MOD_DATE=$(stat -c %Y "$LAST_MODIFIED" 2>/dev/null || stat -f %m "$LAST_MODIFIED" 2>/dev/null || echo "0")
    NOW=$(date +%s)
    DAYS_AGO=$(( (NOW - MOD_DATE) / 86400 ))
    
    if [[ $DAYS_AGO -gt 7 ]]; then
      echo "- **Activity**: ⚠ Stale — no changes in ${DAYS_AGO} days" >> "$REPORT_FILE"
      STALE_COUNT=$((STALE_COUNT + 1))
    else
      echo "- **Activity**: ✓ Active — last change ${DAYS_AGO} day(s) ago" >> "$REPORT_FILE"
    fi
  else
    echo "- **Activity**: ⚠ No tracked files found" >> "$REPORT_FILE"
  fi
  
  # Count agents and skills
  AGENT_COUNT=$(find "$PROJECT_DIR/.claude/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  SKILL_COUNT=$(find "$PROJECT_DIR/.claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  echo "- **Agents**: $AGENT_COUNT" >> "$REPORT_FILE"
  echo "- **Skills**: $SKILL_COUNT" >> "$REPORT_FILE"
  
  # Show latest changelog entry
  if [[ -f "$PROJECT_DIR/CHANGELOG.md" ]]; then
    LATEST=$(grep "^## " "$PROJECT_DIR/CHANGELOG.md" | head -1)
    echo "- **Latest changelog**: $LATEST" >> "$REPORT_FILE"
  fi
  
  echo "" >> "$REPORT_FILE"
done

# Summary
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- **Total projects**: $PROJECT_COUNT" >> "$REPORT_FILE"
echo "- **Active**: $ACTIVE_COUNT" >> "$REPORT_FILE"
echo "- **Stale (7+ days)**: $STALE_COUNT" >> "$REPORT_FILE"

echo "Health check complete. Report: $REPORT_FILE"
cat "$REPORT_FILE"
