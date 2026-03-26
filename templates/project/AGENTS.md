# Agent Registry — {PROJECT_NAME}

> Agents available in this project. The Team Lead manages deployment and coordination.

---

## Active Agents

### Team Lead
- **File**: `.claude/agents/team-lead.md`
- **Role**: Project coordinator. Manages task breakdown, agent deployment, and quality control.
- **Model**: sonnet
- **Always active**: Yes — this is the default agent for this project.

{AGENT_ENTRIES}

---

## Coordination Patterns

### Subagent Pattern (Default)
Use for independent, focused tasks. Agent does its work and reports back to Team Lead.
- Research lookups, code reviews, document drafts, data analysis

### Agent Team Pattern
Use when agents need real-time coordination.
- Frontend + Backend working on shared API contracts
- Research + Writer producing a deliverable together
- Multi-perspective review sessions

### Concurrency
- Target: 3 agents per task
- Maximum: 5 agents per task
- Team Lead enforces these limits

---

## Adding Agents

If this project needs an agent type not listed above:
1. Check the parent orchestrator's `AGENTS.md` for available templates
2. If the needed agent exists, copy it to `.claude/agents/`
3. If it doesn't exist, create a new one and notify the Orchestrator for registry sync
