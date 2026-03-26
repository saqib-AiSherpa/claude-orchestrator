---
name: registry-sync
description: >
  Synchronizes agent and skill registries between child projects and the parent 
  orchestrator. Use when a project reports creating a new agent or skill, or 
  when running the scheduled Registry Sync workflow. Scans all active projects 
  and updates the master AGENTS.md, SKILLS.md, and template directories.
---

# Registry Sync

## Overview

This skill ensures the parent orchestrator's master registries stay up-to-date when child projects create new agents or skills. It prevents knowledge loss and makes new capabilities available to future projects.

## Sync Workflow

### Step 1: Scan Projects

For each directory in `projects/`:
1. Read `projects/{name}/.claude/agents/` — list all agent `.md` files
2. Read `projects/{name}/.claude/skills/` — list all skill directories
3. Compare against the master registries (`AGENTS.md` and `SKILLS.md`)
4. Identify any agents or skills that exist in a project but NOT in the master registry

### Step 2: Review New Items

For each new item found:
1. Read the agent `.md` file or skill `SKILL.md`
2. Extract: name, description, model, tools, applicable project types
3. Present the new item to the operator for confirmation before adding

### Step 3: Update Master Registries

For confirmed new agents:
1. Copy the agent `.md` file to `templates/agents/`
2. Append an entry to `AGENTS.md` following the existing format
3. Note which project originated it

For confirmed new skills:
1. Copy the skill directory to `templates/skills/`
2. Append an entry to `SKILLS.md` following the existing format
3. Note which project originated it

### Step 4: Report

Output a sync summary:

```markdown
## Registry Sync Report — {date}

### New Agents Added
- {agent-name} (from project: {project-name}) — {description}

### New Skills Added
- {skill-name} (from project: {project-name}) — {description}

### No Changes
- {list of projects with no new items}

### Errors
- {any issues encountered}
```

## Triggering

This skill can be triggered:
- **Manually**: "Sync registries" or "Run registry sync"
- **Scheduled**: As part of the WORKFLOWS.md Registry Sync job
- **On notification**: When a Team Lead reports creating a new agent or skill

## Safety

- Never overwrite existing registry entries — only append
- Always confirm with the operator before adding new items
- If a new agent/skill conflicts with an existing name, flag it for resolution
- Log all sync actions for auditability
