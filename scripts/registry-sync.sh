#!/usr/bin/env bash
# registry-sync.sh — Scan projects for new agents/skills not in master registries
#
# Usage: ./scripts/registry-sync.sh [--dry-run]
#
# Scans all project directories, identifies agents and skills not in the master
# registries, and reports them. In non-dry-run mode, copies new templates to
# the templates directory. Registry markdown files should be updated by the
# Orchestrator agent after reviewing the output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECTS_DIR="$ROOT_DIR/projects"
TEMPLATES_AGENTS_DIR="$ROOT_DIR/templates/agents"
TEMPLATES_SKILLS_DIR="$ROOT_DIR/templates/skills"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

echo "=== Registry Sync — $(date -u +"%Y-%m-%d %H:%M UTC") ==="
echo ""

NEW_AGENTS=()
NEW_SKILLS=()

# --- Scan for new agents ---
for PROJECT_DIR in "$PROJECTS_DIR"/*/; do
  if [[ ! -d "$PROJECT_DIR" ]]; then continue; fi
  
  PROJECT_NAME=$(basename "$PROJECT_DIR")
  AGENTS_DIR="$PROJECT_DIR/.claude/agents"
  
  if [[ -d "$AGENTS_DIR" ]]; then
    for AGENT_FILE in "$AGENTS_DIR"/*.md; do
      if [[ ! -f "$AGENT_FILE" ]]; then continue; fi
      
      AGENT_BASENAME=$(basename "$AGENT_FILE")
      
      # Check if this agent exists in templates
      if [[ ! -f "$TEMPLATES_AGENTS_DIR/$AGENT_BASENAME" ]]; then
        echo "  NEW AGENT: $AGENT_BASENAME (from $PROJECT_NAME)"
        NEW_AGENTS+=("$AGENT_FILE")
        
        if [[ "$DRY_RUN" == false ]]; then
          cp "$AGENT_FILE" "$TEMPLATES_AGENTS_DIR/"
          echo "    → Copied to templates/agents/"
        fi
      fi
    done
  fi
  
  # --- Scan for new skills ---
  SKILLS_DIR="$PROJECT_DIR/.claude/skills"
  
  if [[ -d "$SKILLS_DIR" ]]; then
    for SKILL_DIR in "$SKILLS_DIR"/*/; do
      if [[ ! -d "$SKILL_DIR" ]]; then continue; fi
      
      SKILL_NAME=$(basename "$SKILL_DIR")
      
      # Check if this skill exists in templates
      if [[ ! -d "$TEMPLATES_SKILLS_DIR/$SKILL_NAME" ]]; then
        echo "  NEW SKILL: $SKILL_NAME (from $PROJECT_NAME)"
        NEW_SKILLS+=("$SKILL_DIR")
        
        if [[ "$DRY_RUN" == false ]]; then
          cp -r "$SKILL_DIR" "$TEMPLATES_SKILLS_DIR/"
          echo "    → Copied to templates/skills/"
        fi
      fi
    done
  fi
done

echo ""
echo "=== Summary ==="
echo "  New agents found: ${#NEW_AGENTS[@]}"
echo "  New skills found: ${#NEW_SKILLS[@]}"

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "  (Dry run — no files were copied. Remove --dry-run to execute.)"
fi

if [[ ${#NEW_AGENTS[@]} -gt 0 || ${#NEW_SKILLS[@]} -gt 0 ]]; then
  echo ""
  echo "  ⚠ Remember to update AGENTS.md and/or SKILLS.md with the new entries."
  echo "  The Orchestrator agent can do this automatically."
fi
