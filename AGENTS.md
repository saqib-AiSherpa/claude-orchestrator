# Agent Registry — Master

> This is the master registry of all agents available across the orchestrator and its child projects. When a new agent type is created at the project level, it must be appended here.

## Registry Format

Each agent entry includes: name, description, type (subagent vs team-capable), default tools, and applicable project types.

---

## Parent-Level Agents

### Orchestrator
- **File**: `.claude/agents/orchestrator.md`
- **Role**: Top-level coordinator. Manages project lifecycle, agent deployment, scheduled workflows, and cross-project communication.
- **Model**: sonnet
- **Scope**: Parent directory only
- **Invocation**: Default agent at the parent level

---

## Project-Level Agents

### Team Lead
- **File**: `templates/agents/team-lead.md`
- **Role**: Default project-level coordinator. Receives tasks from the Orchestrator or the human operator. Manages, deploys, and coordinates all project-level agents. Decides whether to use subagents (independent tasks) or agent teams (collaborative tasks).
- **Model**: opus
- **Scope**: Per-project (auto-created on project scaffold)
- **Max Concurrent Agents**: 5 (target 3)
- **Tools**: All (inherits parent session)
- **Applicable To**: All project types

### Research Agent
- **File**: `templates/agents/research-agent.md`
- **Role**: Deep research, information gathering, source synthesis, competitive analysis, market research. Reports findings in structured formats.
- **Model**: opus
- **Type**: Subagent (reports back to Team Lead) or Team member (when findings need cross-validation)
- **Tools**: Read, Grep, Glob, Bash, WebFetch
- **Applicable To**: All project types

### Analyst Agent
- **File**: `templates/agents/analyst-agent.md`
- **Role**: Data analysis, financial modeling, trend identification, metric tracking, report generation. Works with spreadsheets, CSVs, and structured data.
- **Model**: opus
- **Type**: Subagent or Team member
- **Tools**: Read, Grep, Glob, Bash
- **Applicable To**: Financial, Business, Research projects

### QA Agent
- **File**: `templates/agents/qa-agent.md`
- **Role**: Quality assurance, testing, validation, code review, document review. Verifies outputs against acceptance criteria and standards.
- **Model**: sonnet
- **Type**: Subagent (best for independent review) or Team member (when coordinating with devs)
- **Tools**: Read, Grep, Glob, Bash
- **Applicable To**: Dev, Business, Research projects

### Frontend Developer Agent
- **File**: `templates/agents/frontend-dev-agent.md`
- **Role**: UI/UX implementation, React/Next.js/HTML/CSS, component architecture, responsive design, accessibility. Owns all client-facing code.
- **Model**: sonnet
- **Type**: Team member (needs coordination with Backend Dev) or Subagent (isolated UI tasks)
- **Tools**: Read, Write, Grep, Glob, Bash
- **Applicable To**: Dev projects

### Senior UX Designer Agent
- **File**: `templates/agents/ux-designer-agent.md`
- **Role**: User experience strategy, information architecture, wireframing, user flow design, usability heuristics, interaction patterns, and design system governance. Bridges user needs with technical implementation.
- **Model**: opus
- **Type**: Team member (primary collaboration with Frontend Dev) or Subagent (UX audits, flow design)
- **Tools**: Read, Write, Grep, Glob, Bash
- **Applicable To**: Dev, Business projects

### Backend Developer Agent
- **File**: `templates/agents/backend-dev-agent.md`
- **Role**: API development, database design, server logic, integrations, infrastructure. Owns all server-side code and data layer.
- **Model**: sonnet
- **Type**: Team member (needs coordination with Frontend Dev) or Subagent (isolated API tasks)
- **Tools**: Read, Write, Grep, Glob, Bash
- **Applicable To**: Dev projects

### Solutions Architect Agent
- **File**: `templates/agents/solutions-architect-agent.md`
- **Role**: System design, architecture decisions, tech stack evaluation, integration planning, scalability analysis. Creates ADRs and technical specifications.
- **Model**: opus
- **Type**: Subagent (architectural review) or Team member (design sessions)
- **Tools**: Read, Grep, Glob, Bash
- **Applicable To**: Dev, Business projects

### Writer Agent
- **File**: `templates/agents/writer-agent.md`
- **Role**: Content creation, copywriting, documentation, proposals, reports, marketing materials. Adapts tone and format to audience.
- **Model**: sonnet
- **Type**: Subagent or Team member (when paired with Research Agent)
- **Tools**: Read, Write, Grep, Glob, Bash
- **Applicable To**: Business, Research, Misc projects

### Ops Agent
- **File**: `templates/agents/ops-agent.md`
- **Role**: DevOps, CI/CD, deployment automation, monitoring, infrastructure-as-code. Manages scripts, pipelines, and operational tooling.
- **Model**: sonnet
- **Type**: Subagent
- **Tools**: Read, Write, Grep, Glob, Bash
- **Applicable To**: Dev projects

### Financial Specialist Agent
- **File**: `templates/agents/financial-specialist.md`
- **Role**: Financial modeling, investment analysis, capex/opex modeling, revenue projections, break-even analysis, ROI, IRR, sensitivity analysis, and scenario modeling (Base / Optimistic / Pessimistic). Works closely with the Analyst Agent on demand inputs and reports findings to the Team Lead.
- **Model**: opus
- **Type**: Subagent (financial modeling) or Team member (when paired with Analyst for integrated analysis)
- **Tools**: Read, Grep, Glob, Bash
- **Applicable To**: Financial, Business, Research projects

### Marketing Strategist Agent
- **File**: `templates/agents/marketing-strategist.md`
- **Role**: Brand positioning, go-to-market strategy, audience definition, messaging frameworks, campaign briefs, competitive analysis. Directs the Social Media Manager on campaign execution.
- **Model**: opus
- **Type**: Team member (primary pair: Marketing Strategist + Social Media Manager) or Subagent (strategy audits, positioning work)
- **Tools**: Read, Write, Grep, Glob, WebFetch
- **Applicable To**: Business, Research, Misc projects

### Social Media Manager Agent
- **File**: `templates/agents/social-media-manager.md`
- **Role**: Platform-native content creation, social copy, content calendars, hashtag research, campaign execution across LinkedIn, Instagram, X, TikTok, and others. Executes direction from the Marketing Strategist.
- **Model**: sonnet
- **Type**: Team member (paired with Marketing Strategist) or Subagent (isolated content tasks)
- **Tools**: Read, Write, Grep, Glob, WebFetch
- **Applicable To**: Business, Misc projects

---

## Agent Deployment Patterns

### When to use Subagents
- Task is independent and doesn't need cross-agent coordination
- Quick, focused work that reports back a summary
- Research, review, or validation tasks
- Cost-sensitive situations (lower token overhead)

### When to use Agent Teams
- Tasks require cross-domain coordination (e.g., frontend + backend)
- Agents need to share findings and challenge each other
- Complex features spanning multiple concerns
- Review workflows where multiple perspectives matter

### Concurrency Rules
- **Sweet spot**: 3 agents working on a task
- **Hard max**: 5 agents per task
- Team Lead is responsible for enforcing this
- If more capacity is needed, break the task into sequential phases

---

## Adding New Agents

When a project-level Team Lead creates a new agent type:
1. The agent `.md` file is created in the project's `.claude/agents/` directory
2. A copy of the template is added to `templates/agents/` at the parent level
3. This registry (`AGENTS.md`) is updated with the new entry
4. The new agent becomes available for all future project scaffolds
