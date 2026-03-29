# Claude Orchestrator

A portfolio management system for [Claude Code](https://claude.ai/code). Run multiple AI-assisted projects from a single parent directory — with shared agents, skills, automated daily reporting, and cross-project intelligence.

---

## What It Does

- **Manage multiple projects** from one place — each gets its own Team Lead agent, tailored skills, and rules
- **Daily morning digest** — per-project intelligence reports at 8:45am, synthesised into one digest at 9:00am (with Gmail + Google Calendar integration)
- **EOD wrap-up** — compares what was planned vs what got done; surfaces tomorrow's priorities
- **Nightly maintenance** — syncs agent/skill registries, runs health checks, updates the task board
- **Weekly entity scan** — builds a cross-project map of people, companies, and systems
- **Pre-session briefing** — automatically injects today's context when you open any project
- **Cross-project queries** with `/ask` — ask anything about your portfolio in plain language
- **Project archiving** with `/archive-project` — clean offboarding with completion report

---

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed and authenticated (`claude` in your PATH)
- macOS or Linux (uses `crontab` for scheduling)
- Python 3 (for setup — usually pre-installed)
- Optional: Gmail and Google Calendar connected at [claude.ai/settings/connectors](https://claude.ai/settings/connectors) for richer morning digests

---

## Quick Start

**1. Clone and run setup:**

```bash
git clone https://github.com/YOUR_USERNAME/claude-orchestrator
cd claude-orchestrator
bash setup.sh
```

Setup asks for your name and timezone, configures `settings.json`, and registers all cron jobs automatically. Takes about 60 seconds.

**2. Open Claude Code in this directory:**

```bash
claude
```

**3. Create your first project:**

```
/project-scaffolder
```

The interactive wizard handles the rest — one question at a time.

---

## How Projects Work

Each project lives in `projects/{name}/` and gets:

- A `CLAUDE.md`, `AGENTS.md`, `SKILLS.md`, `RULES.md`, `CHANGELOG.md`, `TASKS.md`
- A **Team Lead agent** as the default point of contact
- Additional agents based on project type (dev, financial, business, research, misc)
- A morning report script that runs automatically at 8:45am

The orchestrator acts as the parent layer — it can see all projects, sync registries, and run cross-project workflows.

Each project can optionally use a different Claude account — the scaffolder will ask during setup. When a non-default account is configured, open that project with `claude --profile <account>` instead of `claude`.

---

## Project Types

| Type | Default Agents | Default Skills |
|---|---|---|
| **Dev** | Team Lead, Frontend Dev, Backend Dev, UX Designer, QA, Solutions Architect, Code Review, Cybersecurity | frontend-design, api-design-principles, git-commit-messages, playwright-testing, mcp-builder, vercel-react-best-practices, planning-with-files |
| **Financial** | Team Lead, Analyst, Research, QA | spreadsheet-ops, pdf-ops, data-analysis, document-creation, markitdown |
| **Business** | Team Lead, Research, Analyst, Writer, UX Designer, Cybersecurity | document-creation, presentation-builder, spreadsheet-ops, internal-comms, seo-audit, copywriting, agent-browser |
| **Research** | Team Lead, Research, Analyst, Writer | document-creation, pdf-ops, data-analysis, presentation-builder, agent-browser, markitdown |
| **Marketing** | Team Lead, Marketing Strategist, Social Media Manager, Senior Graphic Designer, Writer | document-creation, presentation-builder, copywriting, seo-audit, md-anything, pixelpanda-mcp, agent-browser |
| **Misc** | Team Lead, Research | document-creation, pdf-ops, markitdown |

---

## Agent Roster

| Agent | Model | Role |
|---|---|---|
| Team Lead | Opus | Planning, coordination, task delegation — always included |
| Solutions Architect | Opus | System design, technical strategy |
| Research Agent | Opus | Deep research and analysis |
| Analyst | Opus | Data analysis, insights, modelling |
| Marketing Strategist | Opus | Brand positioning, campaign strategy |
| UX Designer | Opus | UX/UI, wireframes, user research |
| Financial Specialist | Opus | Financial modelling, investment analysis, scenario planning |
| Code Review Agent | Opus | PR reviews, code quality enforcement, refactor recommendations |
| Cybersecurity Agent | Opus | Threat modelling, OWASP audits, vulnerability assessment |
| Frontend Dev | Sonnet | React, CSS, UI implementation |
| Backend Dev | Sonnet | APIs, databases, infrastructure |
| QA Agent | Sonnet | Testing and verification |
| Writer | Sonnet | Documentation, copywriting, reports |
| Senior Graphic Designer | Sonnet | Visual assets, brand design, campaign graphics (works with Marketing Strategist) |
| Social Media Manager | Sonnet | Platform-native content (works with Marketing Strategist) |
| Ops | Sonnet | DevOps, deployment, monitoring |

---

## Skills

### Proprietary (Built-in)

| Skill | How to use | Description |
|---|---|---|
| `project-scaffolder` | `/project-scaffolder` | Create new projects or ingest existing ones (interactive wizard) |
| `ask` | `/ask <question>` | Query anything across all projects in plain language |
| `archive-project` | `/archive-project <name>` | Clean project offboarding — completion report, crontab cleanup, registry update |
| `registry-sync` | `/registry-sync` | Manually sync agent/skill registries from all projects |

### Official (Anthropic)

| Skill | Description |
|---|---|
| `document-creation` | Word documents with formatting, tables, headings |
| `spreadsheet-ops` | Excel spreadsheets, formulas, pivot tables |
| `presentation-builder` | PowerPoint decks, layouts, speaker notes |
| `pdf-ops` | Read, merge, split, fill, encrypt PDFs |
| `frontend-design` | Production-grade HTML/CSS/React interfaces |
| `skill-creator` | Interactive guide for creating new skills |
| `playwright-testing` | Browser automation and E2E testing |
| `mcp-builder` | Guide for creating MCP servers |
| `internal-comms` | Status reports, newsletters, stakeholder updates |

### Community (Vetted)

| Skill | Description | Best For |
|---|---|---|
| `find-skills` | Search GitHub for Claude skill packs | All projects |
| `planning-with-files` | Persistent planning via `todo.md` / `plan.md` | All projects |
| `ralph-wiggum` | Execution partner for planning-with-files | All projects |
| `markitdown` | Convert PDF/PPT/images/audio to Markdown | All projects |
| `vercel-react-best-practices` | React code quality standards for Vercel | Dev |
| `vue-best-practices` | Vue component and state management standards | Dev |
| `ui-ux-pro-max-skill` | Cross-platform design systems (Web/iOS/Android) | Dev, Business |
| `seo-audit` | Technical SEO checklists and audits | Dev, Business |
| `git-commit-messages` | Generate commit messages from git diffs | Dev |
| `api-design-principles` | RESTful API design and OpenAPI specs | Dev |
| `data-analysis` | CSV/JSON analysis and insight extraction | Financial, Research |
| `agent-browser` | Research automation via browser control | Research, Business |
| `copywriting` | Structured, conversion-focused copy | Business, Misc |
| `md-anything` (MCP) | Convert files, URLs, and media to Markdown via MCP server | All projects |
| `pixelpanda-mcp` (MCP) | 33 image tools — resize, crop, filters, AI background removal, generation | Marketing, Business, Dev |

---

## Automated Schedule

| Local time | Job | Output |
|---|---|---|
| 8:45 AM daily | Per-project morning reports | `reports/daily/{date}/{project}.md` |
| 9:00 AM daily | Morning digest | `reports/daily/{date}/DAILY-DIGEST.md` |
| 7:00 PM daily | EOD wrap-up | `reports/daily/{date}/EOD-DIGEST.md` |
| 2:00 AM daily | Nightly maintenance (registry sync, health check, task board) | `reports/workflow-log.md` |
| Sunday 10:00 PM | Weekly cross-project entity scan | `ENTITIES.md` |

Times are in your local timezone. `setup.sh` converts them to UTC automatically when registering cron jobs.

**To adjust the schedule after setup:** `crontab -e`

---

## Pre-Session Briefing

When you open Claude Code in any project for the first time each day, it automatically injects:
- Today's digest highlights (urgent items + agenda)
- Recent changelog entries (last 3 days)
- Open tasks for that project

This happens via a `UserPromptSubmit` hook in each project's `.claude/settings.json`. It fires once per calendar day — no overhead after that.

---

## MCP Integration (Gmail + Google Calendar)

The morning digest and EOD wrap-up can pull from Gmail and Google Calendar for richer context:

1. Go to [claude.ai/settings/connectors](https://claude.ai/settings/connectors)
2. Connect your Google account
3. Done — the MCP config is already at `scripts/mcp-morning.json`

Without this, digests still work — they just won't include email or calendar data.

---

## Directory Structure

```
claude-orchestrator/
├── projects/                     # Your projects (gitignored — stays local)
├── reports/                      # Digests and logs (gitignored — stays local)
├── templates/
│   ├── agents/                   # Agent definition templates
│   └── project/                  # Project scaffold template
├── scripts/
│   ├── setup-morning-crons.sh    # Deploy morning scripts to all projects + update crontab
│   ├── morning-digest.sh         # 9:00am orchestrator digest
│   ├── eod-digest.sh             # 7:00pm EOD wrap-up
│   ├── daily-sync.sh             # 2:00am nightly maintenance
│   ├── weekly-entity-scan.sh     # Sunday entity map update
│   ├── pre-session-brief.sh      # Session briefing hook (called by project hooks)
│   └── templates/
│       └── morning-report.sh     # Per-project morning report template
├── .claude/
│   ├── agents/                   # Orchestrator-level agent definition
│   └── skills/                   # project-scaffolder, ask, archive-project, registry-sync
├── AGENTS.md                     # Master agent registry
├── SKILLS.md                     # Master skills registry
├── WORKFLOWS.md                  # Scheduled workflow definitions
├── RULES.md                      # Shared guardrails (inherited by all projects)
├── TASKS.md                      # Cross-project task board
├── ENTITIES.md                   # Cross-project entity map (auto-generated weekly)
├── settings.json                 # Your personal config (gitignored — created by setup.sh)
├── settings.example.json         # Config template (committed)
└── setup.sh                      # First-time setup script
```

---

## Adding a New Project

```
/project-scaffolder
```

After scaffolding, register its morning cron:

```bash
bash scripts/setup-morning-crons.sh
```

Safe to re-run at any time — never duplicates crontab entries.

---

## Ingesting an Existing Project

The scaffolder supports ingesting existing projects of any type — code repos, financial models, research archives, business documents:

```
/project-scaffolder
> 2  (Existing project)
> /path/to/your/project
```

It analyses the directory, infers the project type, and layers in the orchestrator format non-destructively. Your existing files are untouched.

**Bulk ingestion** (option 3 in the wizard) ingests multiple projects in one pass and opens a tmux tab per project.

---

## Running Digests Manually

Any automated script can be triggered manually:

```bash
bash scripts/morning-digest.sh
bash scripts/eod-digest.sh
bash scripts/daily-sync.sh
bash scripts/weekly-entity-scan.sh
```

---

## FAQ

**Do I need to be online for cron jobs to run?**
Yes — the scripts call the `claude` CLI, which requires an active internet connection and a valid Claude Code session. Failed runs are logged to `reports/cron-run.log`.

**Where are my reports?**
`reports/daily/{YYYY-MM-DD}/` — one directory per day. `DAILY-DIGEST.md` is the morning synthesis, `EOD-DIGEST.md` is the evening wrap-up.

**How do I disable a cron job?**
```bash
crontab -e
```
Comment out or delete the relevant line.

**My project is done. How do I archive it?**
```
/archive-project my-project-name
```
Generates a completion report, moves the project to `projects/archived/`, removes its crontab entry, and updates all registries.

**Can I use this without the cron jobs?**
Yes — everything works on-demand. The scheduling is optional. Open Claude Code, use `/project-scaffolder` to create projects, and interact normally. The crons just add automated daily intelligence on top.

---

## Customising Rules

`RULES.md` defines guardrails inherited by all projects. Edit it to change global defaults. Individual projects can add a local `RULES.md` to layer in project-specific rules — the stricter rule always wins.

---

## License

MIT
