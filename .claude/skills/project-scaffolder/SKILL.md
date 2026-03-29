---
name: scaffold-project
description: >
  Interactive project creation and ingestion wizard. Use when the operator asks to create,
  spawn, scaffold, or start a new project — OR to onboard an existing project (any type:
  code, financial, business, research, etc.) into the orchestrator format. Supports bulk
  ingestion of multiple existing projects at once, with a tmux tab per project. Asks one
  question at a time with numbered choices.
---

# Project Scaffolder

## Overview

This skill manages three flows:
- **New Project** — Collects requirements through a one-question-at-a-time Q&A, then generates the full project directory structure.
- **Existing Project Ingestion** — Analyzes a single existing directory, infers its configuration, and layers in the orchestrator format without breaking anything.
- **Bulk Ingestion** — Ingests multiple existing projects in one pass, then opens a dedicated tmux tab per project, each running its own Claude Code instance.

**Interaction rules:**
- Ask **exactly one question at a time**. Never bundle multiple questions.
- For any question with a fixed set of options, display them as a **numbered list** so the operator can respond with just a number.
- Wait for the answer before asking the next question.
- Track all answers internally and use them to build the final configuration.

---

## Step 0 — New or Existing?

**Ask first, before anything else:**

```
What would you like to do?

  1  New project — set it up from scratch
  2  Existing project — analyse one project and layer in the orchestrator format
  3  Bulk ingestion — bring multiple existing projects in at once
```

- If **1** → proceed to [New Project Flow](#new-project-flow)
- If **2** → proceed to [Existing Project Ingestion Flow](#existing-project-ingestion-flow)
- If **3** → proceed to [Bulk Ingestion Flow](#bulk-ingestion-flow)

---

## New Project Flow

Ask each question one at a time, in order. Display options as a numbered list wherever applicable.

### Q1 — Project Name
```
What should the project be called?
(This becomes the directory name in kebab-case, e.g. "market-analysis-q2")
```

### Q2 — One-Line Description
```
Give me one sentence describing what this project is about.
```

### Q3 — Project Type
```
What type of project is this?

  1  Dev — Software development / coding
  2  Financial — Financial modelling / accounting / budgeting
  3  Business — Strategy / consulting / planning
  4  Research — Research / analysis / intelligence
  5  Marketing — Brand, campaigns, content, and creative production
  6  Misc — Doesn't fit the above
```

### Q4 — Primary Goal
```
What's the main deliverable or outcome you want from this project?
(e.g. "A working REST API", "A feasibility report", "A 3-year financial model")
```

### Q5 — Agent Selection

Based on Q3, suggest the default agent set for that project type (see Agent Defaults below). Display the recommended set, then ask:

```
Here are the agents I'd recommend for a [type] project:

  • Team Lead (always included)
  • [Agent A]
  • [Agent B]
  • [Agent C]

  1  Looks good — use these
  2  Add an agent
  3  Remove an agent
  4  Replace an agent
  5  Start from scratch — let me pick manually
```

If they choose 2, 3, 4, or 5 — handle those sub-edits one step at a time before moving on.

#### Agent Defaults by Project Type

| Type       | Default Agents                                                                                          |
|------------|---------------------------------------------------------------------------------------------------------|
| dev        | Team Lead, Frontend Dev, Backend Dev, QA                                                                |
| financial  | Team Lead, Analyst, Financial Specialist, Writer                                                        |
| business   | Team Lead, Solutions Architect, Analyst, Writer, Marketing Strategist, Social Media Manager            |
| research   | Team Lead, Research Agent, Analyst, Writer                                                              |
| marketing  | Team Lead, Marketing Strategist, Social Media Manager, Senior Graphic Designer, Writer                  |
| misc       | Team Lead, Analyst, Writer                                                                              |

### Q6 — Skills & Tools
```
Here are the default skills for a [type] project:

  [List applicable skills from the registry]

  1  These are fine
  2  Add a skill or tool
  3  Remove a skill
  4  Also connect an MCP server (e.g. GitHub, Slack, Google Drive)
```

Handle additions/removals one at a time if requested.

#### Default Skills by Project Type

| Type      | Default Skills |
|-----------|----------------|
| dev       | frontend-design, api-design-principles, git-commit-messages, playwright-testing, mcp-builder, vercel-react-best-practices, planning-with-files |
| financial | spreadsheet-ops, pdf-ops, data-analysis, document-creation, markitdown |
| business  | document-creation, presentation-builder, spreadsheet-ops, internal-comms, seo-audit, copywriting, agent-browser |
| research  | document-creation, pdf-ops, data-analysis, presentation-builder, agent-browser, markitdown |
| marketing | document-creation, presentation-builder, copywriting, seo-audit, md-anything, pixelpanda-mcp, agent-browser |
| misc      | document-creation, pdf-ops, markitdown |

### Q7 — Claude Account
```
Should this project use a different Claude account from the orchestrator default?

  1  No — use the default account (most projects)
  2  Yes — I'll specify a different account
```

If they choose 2, ask:
```
What is the Claude account profile name to use for this project?
(This is the profile name configured in your Claude Code settings, e.g. "work", "client-acme")
```

Store the account as `claudeAccount` in the project's `settings.json`. When a non-default account is set, the post-creation instructions will remind the operator to open Claude Code with `claude --profile {account}` in the project directory.

### Q8 — Project-Specific Rules
```
Are there any rules or constraints specific to this project?
(e.g. "Python 3.11+ only", "No external API calls without approval", "All outputs in Arabic and English")

  1  No special rules — inherit the shared defaults
  2  Yes — I'll describe them
```

### Q9 — Seed Context
```
Any existing documents, files, or context I should seed this project with?
(Reference materials, briefs, data sources, prior research)

  1  No — start fresh
  2  Yes — I'll describe or list them
```

### Q10 — Confirmation

Display the complete configuration summary:

```
Here's the full project configuration:

  Name:        {name}
  Type:        {type}
  Description: {description}
  Goal:        {goal}
  Account:     {default / profile name}
  Agents:      {agent list}
  Skills:      {skill list}
  Rules:       {rules summary}
  Seed files:  {seed summary}

  1  Looks good — create the project
  2  Change something
```

If they choose 2, ask which part they want to change and loop back to the relevant question.

---

## Existing Project Ingestion Flow

This flow non-destructively analyses an existing project directory — which could be a codebase, a folder of financial models, a research archive, business documents, or any mix — and layers in the orchestrator structure without modifying or removing existing files.

### I1 — Project Location
```
What's the path to the existing project directory?
(Absolute path or relative to the orchestrator root, e.g. "projects/old-project" or "/Users/you/work/my-project")
```

### I2 — Analysis Phase (automated — no question needed)

Silently read the project directory. Do not ask questions yet. Gather:

**File inventory:**
- List all files and directories (top 2 levels)
- Note file types present: `.py`, `.js`, `.ts`, `.xlsx`, `.csv`, `.pdf`, `.md`, `.json`, `.yaml`, source files, data files, doc files, etc.

**Type inference rules:**

| Signals                                                                 | Inferred Type  |
|-------------------------------------------------------------------------|----------------|
| Source code files (`.py`, `.js`, `.ts`, `.go`, `.rs`, `.java`, etc.)   | dev            |
| `.xlsx`, `.csv`, financial statements, budget/model/forecast filenames  | financial      |
| Strategy docs, pitch decks, consulting deliverables, business plans     | business       |
| Research papers, reports, analysis docs, literature, data notebooks     | research       |
| Mixed or unclear                                                        | misc           |

**Content signals to look for:**
- `package.json`, `Cargo.toml`, `go.mod`, `requirements.txt` → dev
- Files named: `model`, `budget`, `forecast`, `p&l`, `cashflow`, `balance-sheet` → financial
- Files named: `strategy`, `proposal`, `roadmap`, `brief`, `pitch`, `deck` → business
- Files named: `report`, `analysis`, `research`, `findings`, `literature`, `data` → research
- Existing `CLAUDE.md`, `AGENTS.md`, `RULES.md` → already partially set up (note this)
- Existing `.claude/` directory → already has some orchestrator config (note which files)

**Agent inference:**
Based on the inferred type plus actual file content/structure, suggest an appropriate agent set.

**Existing orchestrator files:**
If any of `CLAUDE.md`, `AGENTS.md`, `SKILLS.md`, `RULES.md`, `settings.json`, or `.claude/` already exist, flag them — these will be updated carefully, not overwritten blindly.

### I3 — Present Findings
```
Here's what I found in "{directory}":

  Type detected:   {inferred type} — {brief reason}
  Files found:     {count} files across {N} directories
  Key signals:     {2-3 bullet points explaining the inference}
  Existing config: {None / partial — list any orchestrator files already present}

Does this look right?

  1  Yes, that's the right type
  2  No — the type is wrong, let me correct it
```

If they choose 2, ask which type and update accordingly.

### I4 — Proposed Name
```
What should this project be called in the orchestrator?
(Default: "{inferred name from directory}" — press Enter to accept, or type a new name)
```

If they just confirm, use the directory name converted to kebab-case.

### I5 — One-Line Description
```
Give me one sentence describing what this project is about.
(Or press Enter to use my suggested description: "{inferred description}")
```

### I6 — Primary Goal
```
What's the main goal or deliverable for this project?
(Or press Enter to use: "{inferred goal based on content}")
```

### I7 — Agent Proposal

Using the inferred type and content signals, propose a specific agent set:

```
Based on what I found, I'd suggest these agents:

  • Team Lead (always included)
  • [Inferred Agent A — reason]
  • [Inferred Agent B — reason]

  1  Use these agents
  2  Adjust the agent list
```

### I8 — Conflict Review (if existing orchestrator files detected)

If any orchestrator files already exist in the project:

```
I found existing orchestrator files in this project:

  • CLAUDE.md — will be updated to match the new configuration
  • AGENTS.md — will be replaced with the inferred agent list
  • [etc.]

I will NOT delete or modify any of your actual project files (code, docs, data, models, etc.)
Only orchestrator config files will be created or updated.

  1  Understood — proceed
  2  Show me exactly what will change before I decide
```

If they choose 2, display a diff-style summary of every file that will be created or modified, then re-confirm.

### I9 — Claude Account
```
Should this project use a different Claude account from the orchestrator default?

  1  No — use the default account
  2  Yes — I'll specify a different account
```

If they choose 2, ask for the profile name. Store as `claudeAccount` in `settings.json` and include the `claude --profile {account}` reminder in post-ingestion output.

### I10 — Rules
```
Any specific rules or constraints for this project beyond the shared defaults?

  1  No — inherit shared defaults
  2  Yes — I'll describe them
```

### I11 — Final Confirmation

```
Here's the ingestion plan for "{project-name}":

  Type:         {type}
  Description:  {description}
  Goal:         {goal}
  Account:      {default / profile name}
  Agents:       {agent list}
  Skills:       {skill list}
  Rules:        {rules}

  Files to CREATE:   {list new orchestrator files}
  Files to UPDATE:   {list existing orchestrator files being modified, if any}
  Files untouched:   All existing project content preserved

  1  Confirm — run the ingestion
  2  Change something
```

---

## Bulk Ingestion Flow

This flow ingests multiple existing projects in a single pass. Each project goes through the same analysis and config generation as the single ingestion flow, but confirmation is batched and post-ingestion launches a dedicated tmux tab per project.

### B1 — Project Paths
```
Paste the paths to all projects you'd like to ingest, one per line.
(Absolute paths or relative to the orchestrator root)
```

Accept a multi-line response. Parse into a list of paths.

### B2 — Silent Analysis (automated)

For each path, silently run the full I2 analysis (file inventory, type inference, orchestrator file detection). Do not ask questions yet. Build a proposed configuration for each project.

### B3 — Batch Review

Present a summary table of all detected projects, one row per project:

```
Here's what I found:

  #   Directory              Type        Name (proposed)   Existing config
  ──────────────────────────────────────────────────────────────────────────
  1   my-app/                dev         my-app            None
  2   financial-model-q2/    financial   financial-q2      Partial (CLAUDE.md)
  3   research-brief/        research    research-brief    None

  1  Looks right — proceed with all
  2  Edit a specific project's config before ingesting
  3  Remove a project from this batch
```

Handle option 2 or 3 one project at a time, then re-display the table. Repeat until the operator confirms with option 1.

### B4 — Batch Confirm

```
Ready to ingest {N} projects into projects/:

  {list of project names}

  This will CREATE orchestrator config files for each project.
  Existing project content will not be touched.

  1  Confirm — run all ingestions
  2  Cancel
```

### B5 — Batch Generation

Run the full Generation Phase for each project sequentially. Display progress:

```
Ingesting project 1/3: my-app...        ✓ done
Ingesting project 2/3: financial-q2...  ✓ done
Ingesting project 3/3: research-brief...✓ done

All projects ingested.
```

### B6 — Launch tmux Sessions

After all ingestions are complete, open one tmux window (tab) per project, each running `claude` in that project's directory.

Run the following for each ingested project:

```bash
tmux new-window -n "{project-name}" "cd '{project-path}' && claude"
```

If no tmux session is currently active, create one first:

```bash
tmux new-session -d -s orchestrator
```

Then open a window per project. After all windows are created, attach to the session:

```bash
tmux attach-session -t orchestrator
```

Display a summary before launching:

```
Opening tmux tabs:

  • my-app           → projects/my-app/
  • financial-q2     → projects/financial-q2/
  • research-brief   → projects/research-brief/

Each tab will open Claude Code in that project's directory.
The Team Lead agent will be available immediately.

  1  Launch tmux tabs now
  2  Skip — I'll open them manually
```

Only run the tmux commands if the operator confirms with option 1.

---

## Generation Phase (both flows)

After confirmation, generate or update the following structure inside the project directory:

```
{project-dir}/
├── .claude/
│   ├── agents/
│   │   ├── team-lead.md          ← Always created
│   │   └── {selected-agents}.md  ← Based on Q&A
│   ├── skills/
│   │   └── {selected-skills}/    ← Based on Q&A
│   └── settings.json             ← Project-level Claude Code settings
├── CLAUDE.md                      ← Created or updated (never destructive)
├── AGENTS.md                      ← Project agent registry
├── SKILLS.md                      ← Project skills registry
├── RULES.md                       ← Inherits parent + project additions
├── CHANGELOG.md                   ← Created if missing; untouched if exists
└── settings.json                  ← Project metadata
```

**For ingestion**: existing project files (source code, data, documents, models, etc.) are never touched. Only the orchestrator config layer is written.

### File Content Rules

**CLAUDE.md**: Use `templates/project/CLAUDE.md` as the base. Populate all `{PLACEHOLDERS}` with the gathered configuration. For ingested projects, add a section: `## Ingested Project Notes` summarising what was found and any observations about the existing structure.

**AGENTS.md**: Include only the selected agents with descriptions.

**SKILLS.md**: Include only the selected skills.

**RULES.md**: Begin with `> Inherits all rules from parent RULES.md` then list any project-specific additions.

**Agent .md files**: Copy from `templates/agents/` for each selected agent.

**settings.json**:
```json
{
  "project": {
    "name": "{project-name}",
    "type": "{type}",
    "description": "{description}",
    "goal": "{goal}",
    "created": "{ISO date}",
    "status": "active",
    "ingested": true,
    "claudeAccount": "{profile name or null}"
  },
  "agents": ["{list of active agents}"],
  "skills": ["{list of active skills}"]
}
```
(Set `"ingested": false` for new projects. Set `"claudeAccount": null` when the default account is used.)

**.claude/settings.json**: Copy from parent's `.claude/settings.json` with agent teams enabled.

---

## Post-Creation / Post-Ingestion

1. Confirm completion and display the final directory tree (orchestrator files only for ingested projects).
2. For **new projects**: "To start working on this project, open Claude Code in `projects/{project-name}/`."
3. For **ingested projects**: "Your existing project content is untouched. The orchestrator layer is now in place — open Claude Code in `{project-path}/` to start working with agents."
4. If a non-default `claudeAccount` was configured, display this reminder:
   ```
   Account note: This project is configured for Claude account "{profile}".
   Open it with: claude --profile {profile}
   (from the project directory: projects/{project-name}/)
   ```
5. Ask: "Would you like to define any initial tasks for the Team Lead?"

---

## Notes

- Team Lead is ALWAYS included regardless of project type or flow
- Opus for reasoning-heavy agents (Team Lead, Solutions Architect, Research, Analyst, UX Designer); Sonnet for execution agents (Frontend Dev, Backend Dev, QA, Writer, Ops)
- Everything is editable after creation — nothing is locked
- For ingested projects: when in doubt about what to infer, ask rather than guess
- If an existing project is already partially configured (some orchestrator files present), merge carefully — preserve any custom content already in those files
