# Skills Registry — Master

> This is the master registry of all skills available across the orchestrator and its child projects. Skills are modular capabilities that give agents domain expertise. When a new skill is created at the project level, it must be appended here.

## Registry Format

Each skill entry includes: name, description, source (proprietary/community/official), location, and applicable project types.

---

## Proprietary Skills (Custom-Built)

### project-scaffolder
- **Location**: `.claude/skills/project-scaffolder/`
- **Description**: Interactive project creation and ingestion wizard. Asks one question at a time with numbered choices. Handles new projects (full scaffold) and existing projects of any type (code, financial, business, research, etc.) — analyses existing content, infers project type, and layers in the orchestrator format non-destructively.
- **Trigger**: When the operator asks to create/spawn/scaffold a new project, or to onboard/ingest an existing project
- **Source**: Proprietary
- **Scope**: Parent level only

### registry-sync
- **Location**: `.claude/skills/registry-sync/`
- **Description**: Syncs new agents and skills created at the project level back to the parent-level registries (AGENTS.md, SKILLS.md, and template directories).
- **Trigger**: When a project reports a new agent or skill was created
- **Source**: Proprietary
- **Scope**: Parent level only

### ask
- **Location**: `.claude/skills/ask/`
- **Description**: Cross-project natural language query. Ask anything about the portfolio — project status, outstanding items, entity lookups, open tasks. Reads across all project files and ENTITIES.md to answer in natural language.
- **Trigger**: `/ask <question>` — any question about portfolio state, project status, entities, or tasks
- **Source**: Proprietary
- **Scope**: Parent level only

### archive-project
- **Location**: `.claude/skills/archive-project/`
- **Description**: Clean project offboarding. Generates a completion report, moves the project to `projects/archived/`, removes crontab entries, and updates all registries (AGENTS.md, SKILLS.md, TASKS.md, ENTITIES.md).
- **Trigger**: `/archive-project <project-name>` — when a project is complete or inactive
- **Source**: Proprietary
- **Scope**: Parent level only

---

## Official Anthropic Skills

### document-creation (docx)
- **Description**: Create, read, edit Word documents with formatting, tables of contents, headings, page numbers, letterheads.
- **Source**: Official (Anthropic)
- **Applicable To**: Business, Research, Misc projects
- **Install**: Built-in / `anthropic-agent-skills` plugin

### spreadsheet-ops (xlsx)
- **Description**: Create, read, edit Excel spreadsheets. Formulas, charting, data cleaning, pivot tables.
- **Source**: Official (Anthropic)
- **Applicable To**: Financial, Business, Research projects
- **Install**: Built-in / `anthropic-agent-skills` plugin

### presentation-builder (pptx)
- **Description**: Create, read, edit PowerPoint decks. Layouts, speaker notes, templates.
- **Source**: Official (Anthropic)
- **Applicable To**: Business, Research projects
- **Install**: Built-in / `anthropic-agent-skills` plugin

### pdf-ops
- **Description**: Read, extract, merge, split, fill, watermark, encrypt PDFs.
- **Source**: Official (Anthropic)
- **Applicable To**: All project types
- **Install**: Built-in / `anthropic-agent-skills` plugin

### frontend-design
- **Description**: Production-grade frontend interfaces. Websites, landing pages, dashboards, React components.
- **Source**: Official (Anthropic)
- **Applicable To**: Dev projects
- **Install**: Built-in / `anthropic-agent-skills` plugin

### skill-creator
- **Description**: Interactive guide for creating new skills from scratch. Used when a project needs a capability that doesn't exist yet.
- **Source**: Official (Anthropic)
- **Applicable To**: All project types
- **Install**: Built-in / `anthropic-agent-skills` plugin

---

## Community Skills (Vetted & Recommended)

### seo-audit
- **Description**: Technical SEO analysis, keyword research, content optimization, schema markup, Core Web Vitals.
- **Source**: Community (alirezarezvani/claude-skills)
- **Applicable To**: Dev, Business projects
- **Install**: `npx antigravity-awesome-skills`

### git-commit-messages
- **Description**: Generate descriptive commit messages by analyzing git diffs.
- **Source**: Community (Anthropic examples)
- **Applicable To**: Dev projects
- **Install**: `anthropic-agent-skills` plugin

### api-design-principles
- **Description**: RESTful API design patterns, OpenAPI specs, versioning, error handling standards.
- **Source**: Community (alirezarezvani/claude-skills)
- **Applicable To**: Dev projects

### data-analysis
- **Description**: CSV/JSON analysis, statistical summaries, visualization generation, insight extraction.
- **Source**: Community
- **Applicable To**: Financial, Research, Business projects

### playwright-testing
- **Description**: Browser automation, E2E testing, UI verification with Playwright.
- **Source**: Official (Anthropic)
- **Applicable To**: Dev projects

### mcp-builder
- **Description**: Guide for creating MCP servers to integrate external APIs and services.
- **Source**: Official (Anthropic)
- **Applicable To**: Dev projects

### internal-comms
- **Description**: Status reports, newsletters, FAQs, stakeholder updates.
- **Source**: Official (Anthropic)
- **Applicable To**: Business projects

---

## Skill Deployment by Project Type

| Project Type | Default Skills |
|---|---|
| **Dev (Coding)** | frontend-design, api-design-principles, git-commit-messages, playwright-testing, mcp-builder |
| **Financial** | spreadsheet-ops, pdf-ops, data-analysis, document-creation |
| **Business** | document-creation, presentation-builder, spreadsheet-ops, internal-comms, seo-audit |
| **Research** | document-creation, pdf-ops, data-analysis, presentation-builder |
| **Misc** | document-creation, pdf-ops |

---

## Adding New Skills

When a project-level agent creates a new skill:
1. The skill directory is created in the project's `.claude/skills/`
2. A copy is placed in `templates/skills/` at the parent level
3. This registry (`SKILLS.md`) is updated with the new entry
4. The new skill becomes available for all future project scaffolds

### Creating Skills from Scratch
Use the `/skill-creator` skill or manually create a directory with:
```
my-skill/
├── SKILL.md          # Required — instructions + YAML frontmatter
├── scripts/          # Optional — executable helpers
├── templates/        # Optional — output templates
└── examples/         # Optional — reference examples
```
