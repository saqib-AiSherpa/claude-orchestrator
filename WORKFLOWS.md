# Workflows — Scheduled Jobs & Automations

> Defines recurring tasks, cron-style jobs, and automated workflows that the Orchestrator executes across the parent directory and child projects. Since the Orchestrator has visibility into all child projects, these workflows can span multiple projects.

## How Workflows Work

Workflows are defined declaratively here and executed by the Orchestrator. Each workflow has:
- **Name**: Human-readable identifier
- **Schedule**: Cron expression or frequency descriptor
- **Scope**: Parent-level, specific project(s), or cross-project
- **Action**: What the Orchestrator does when triggered
- **Status**: Active / Paused / Disabled

> **Note**: Workflows 1, 2, 3, and 4 run automatically via macOS crontab. All other workflows run on-demand when the Orchestrator is prompted.

---

## Active Workflows

### 1. Morning Intelligence Digest ⚡ Automated
- **Schedule**: Daily at 8:45 AM (project reports) → 9:00 AM (digest) Muscat time
- **Cron**: `45 8 * * *` (per-project) + `0 9 * * *` (digest)
- **Scripts**:
  - Per-project: `{project}/scripts/morning-report.sh` (identical template, adapts to each project)
  - Orchestrator: `scripts/morning-digest.sh`
  - MCP config: `scripts/mcp-morning.json` (Gmail + Google Calendar)
- **Scope**: All active projects → Orchestrator
- **Action**:
  1. **8:45 AM** — All project scripts run in parallel. Each explores its own directory, reads CLAUDE.md/CHANGELOG/logs, queries Gmail or Google Calendar where relevant, and writes a structured report to `reports/daily/{date}/{project}.md`
  2. **9:00 AM** — Orchestrator reads all project reports, checks Google Calendar for today's schedule, merges and deduplicates items, categorises anything unexpected, and writes `reports/daily/{date}/DAILY-DIGEST.md`
- **Output**: `reports/daily/{date}/DAILY-DIGEST.md` + entry in `reports/workflow-log.md`
- **Status**: Active

**Adding a new project:** After scaffolding/ingesting, run:
```bash
bash scripts/setup-morning-crons.sh
```
This deploys the template and updates crontab automatically. No other changes needed.

### 2. Nightly Maintenance ⚡ Automated
- **Schedule**: Daily at 2:00 AM Muscat time (UTC+4)
- **Cron**: `0 2 * * *` — registered in macOS crontab
- **Script**: `scripts/daily-sync.sh`
- **Scope**: All active projects + parent registries
- **Action**:
  1. **Registry Sync** — scan all projects' `.claude/agents/` and `.claude/skills/`; sync new agents/skills to master AGENTS.md, SKILLS.md, and `templates/`
  2. **Health Check** — verify each project has required orchestrator files; flag missing files, invalid settings.json, or unresolved TODOs
  3. **Task Board Sync** — merge per-project TASKS.md files into orchestrator TASKS.md; archive completed tasks older than 7 days
  4. **Status Report** — read all project CHANGELOGs (last 7 days); append a dated report to `reports/workflow-log.md`
- **Output**: `reports/workflow-log.md` (appended), `reports/cron-run.log` (raw output)
- **Status**: Active

To run manually at any time:
```bash
bash scripts/daily-sync.sh
```

To disable: `crontab -e` and remove or comment out the line.

### 3. EOD Wrap-Up Digest ⚡ Automated
- **Schedule**: Daily at 7:00 PM Muscat time (15:00 UTC)
- **Cron**: `0 15 * * *` — registered in macOS crontab
- **Script**: `scripts/eod-digest.sh`
- **Scope**: All active projects + orchestrator
- **Action**:
  1. Reads today's morning digest (planned items) and any project reports
  2. Reads current TASKS.md for outstanding items
  3. Checks Google Calendar for tomorrow's schedule
  4. Compares planned vs accomplished — surfaces what's done, what rolled over, and tomorrow's priorities
- **Output**: `reports/daily/{date}/EOD-DIGEST.md` + entry in `reports/workflow-log.md`
- **Status**: Active

### 4. Weekly Entity Scan ⚡ Automated
- **Schedule**: Weekly, Sunday at 10:00 PM Muscat time (18:00 UTC)
- **Cron**: `0 18 * * 0` — registered in macOS crontab
- **Script**: `scripts/weekly-entity-scan.sh`
- **Scope**: All active projects → orchestrator root
- **Action**:
  1. Scans all project files for recurring named entities: people, companies, systems, locations
  2. Deduplicates and categorises across projects
  3. Writes/updates `ENTITIES.md` at the orchestrator root
  4. Used by morning digest and nightly maintenance for enriched cross-project context
- **Output**: `ENTITIES.md` (updated) + entry in `reports/workflow-log.md`
- **Status**: Active

### 2. Registry Sync (On-Demand)
- **Schedule**: After every project session, or on request
- **Scope**: Cross-project → Parent
- **Action**:
  1. Scan each project's `.claude/agents/` for agents not in the master `AGENTS.md`
  2. Scan each project's `.claude/skills/` for skills not in the master `SKILLS.md`
  3. Append new entries to master registries
  4. Copy new templates to `templates/agents/` and `templates/skills/`
- **Output**: Updated AGENTS.md and SKILLS.md at parent level
- **Status**: Active (also runs as part of Workflow 1)

### 3. Project Changelog (On-Demand)
- **Schedule**: End of each work session
- **Scope**: Per-project
- **Action**:
  1. Review file changes since last changelog entry
  2. Summarize what was accomplished, decisions made, open items
  3. Append to project's `CHANGELOG.md`
- **Output**: Updated CHANGELOG.md in the project directory
- **Status**: Active

### 5. Pre-Session Briefing (Automatic — Hook-Based)
- **Schedule**: Once per calendar day, on first user message in each project
- **Trigger**: `UserPromptSubmit` hook in each project's `.claude/settings.json`
- **Script**: `scripts/pre-session-brief.sh {project-dir}`
- **Scope**: Per-project (each project has its own hook)
- **Action**:
  1. Checks a daily marker (`/tmp/claude-brief-{project}-{date}`) — only runs once per day
  2. Reads today's DAILY-DIGEST.md (if it exists) and extracts urgent/agenda highlights
  3. Reads recent CHANGELOG entries (last 3 days)
  4. Reads open tasks from the project's TASKS.md
  5. Injects a concise context block into the conversation before the first message
- **Output**: Context injected into the Claude Code session (not written to file)
- **Status**: Active

---

## Paused Workflows

### 4. Cross-Project Dependency Audit
- **Schedule**: Bi-weekly
- **Scope**: All active projects
- **Action**:
  1. Identify shared dependencies between projects
  2. Flag potential conflicts or version mismatches
  3. Recommend consolidation opportunities
- **Status**: Paused (activate when 3+ dev projects are running)

---

## Workflow Templates

### Template: Recurring Report
```yaml
name: [report-name]
schedule: [daily|weekly|monthly|on-demand]
scope: [parent|project-name|cross-project]
action:
  - Gather data from [source]
  - Analyze against [criteria]
  - Generate report at [output-path]
status: active
```

### Template: Maintenance Task
```yaml
name: [task-name]
schedule: [cron expression or frequency]
scope: [parent|project-name|cross-project]
action:
  - Check [condition]
  - If [trigger], execute [remediation]
  - Log result to [log-path]
status: active
```

---

## Adding New Workflows

To add a new workflow:
1. Define it in this file following the format above
2. Assign a unique sequential number
3. Set status to `Active`
4. The Orchestrator will pick it up on next prompt

To run a workflow manually:
- Ask the Orchestrator: "Run workflow [name]" or "Execute the [name] job"

## Execution Log

> Execution history is tracked in `reports/workflow-log.md` (auto-created on first run).
