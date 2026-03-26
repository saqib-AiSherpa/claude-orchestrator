# {PROJECT_NAME}

> {PROJECT_DESCRIPTION}

## Project Overview

- **Type**: {PROJECT_TYPE}
- **Goal**: {PROJECT_GOAL}
- **Status**: Active
- **Created**: {CREATED_DATE}
- **Parent**: `claude-orchestrator/`

## Team

This project is managed by a **Team Lead** agent who coordinates all work. The Team Lead receives tasks from the operator or the parent Orchestrator and deploys the following agents as needed:

{AGENT_LIST}

### Coordination Model
- **Team Lead** is the single point of contact for this project
- Agents are deployed as **subagents** (independent tasks) or **agent teams** (collaborative work)
- Max 5 agents active per task (target: 3)
- All agents use Opus or Sonnet as defined in their agent templates

## Available Skills

{SKILLS_LIST}

## Project-Specific Context

{PROJECT_CONTEXT}

## Working Agreements

- Follow all rules in `RULES.md` (inherits parent guardrails + project-specific additions)
- Log significant decisions and progress in `CHANGELOG.md`
- New agents or skills created here must be synced to the parent orchestrator
- Ask clarifying questions — never assume when there's ambiguity

## Key Files

```
.claude/agents/    → Agent definitions for this project
.claude/skills/    → Skill definitions for this project
AGENTS.md          → Project agent registry
SKILLS.md          → Project skills registry  
RULES.md           → Project rules (inherits parent + local additions)
CHANGELOG.md       → Decision and progress log
settings.json      → Project configuration
```
