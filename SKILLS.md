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

### find-skills
- **Description**: Search and discover Claude skill packs on GitHub. Filter by category, stars, and recency to find the right skill for any task.
- **Source**: Community
- **Applicable To**: All project types

### planning-with-files
- **Description**: Persistent task planning that auto-maintains `todo.md` and `plan.md`. Tracks task status across sessions and prevents agents from losing context or looping infinitely on long-running tasks.
- **Source**: Community
- **Applicable To**: All project types

### ralph-wiggum
- **Description**: Execution partner for planning-with-files. Picks up planned tasks and carries them out step by step. Use together: planning-with-files plans, ralph-wiggum executes.
- **Source**: Community
- **Applicable To**: All project types

### vercel-react-best-practices
- **Description**: Enforces React development standards: readability, performance, and edge-case handling. Covers component structure, hooks patterns, and Vercel deployment conventions for stable, reviewable output.
- **Source**: Community
- **Applicable To**: Dev projects

### vue-best-practices
- **Description**: Standardizes Vue component boundaries, state management (Pinia/Vuex), and reuse strategies. Reduces long-term maintenance costs by enforcing consistent patterns.
- **Source**: Community
- **Applicable To**: Dev projects

### ui-ux-pro-max-skill
- **Description**: Cross-platform design system management for Web, iOS, and Android. Covers responsive layouts, component libraries, and design token systems.
- **Source**: Community
- **Applicable To**: Dev, Business projects

### agent-browser
- **Description**: Research automation via browser control. Automates browsing, data extraction, and table generation for repetitive research tasks. Structured output ready for analysis.
- **Source**: Community
- **Applicable To**: Research, Business projects

### copywriting
- **Description**: Structured copywriting process: defines audience, identifies selling points, and generates conversion-focused copy. Avoids generic AI prose by anchoring every piece to a specific brief.
- **Source**: Community
- **Applicable To**: Business, Misc projects

### markitdown
- **Description**: Multi-format to Markdown converter. Handles PDF, PPT, images, audio, and ZIP files — converts them to Markdown so agents can read and process the content.
- **Source**: Community
- **Applicable To**: All project types

### md-anything (MCP)
- **Description**: Converts files, URLs, and media into Markdown via an MCP server. Supports text, PDFs, videos, and audio. Exposes `convert`, `ingest`, and `doctor` tools. Useful for ingesting external content into agent-readable format.
- **Source**: Community (ojspace/md-anything)
- **Install**: `npm install -g md-anything` then `mda mcp install claude-code`
- **MCP Config**: `{ "mcpServers": { "md-anything": { "command": "md-anything-mcp" } } }`
- **Applicable To**: All project types

### pixelpanda-mcp (MCP)
- **Description**: Image processing toolkit with 33 tools across three tiers: local editing (resize, crop, filters, format conversion), free AI features (background removal, enhancement — daily limits apply), and premium AI generation tools for e-commerce. API token optional for local/free tier.
- **Source**: Community (RyanKramer/pixelpanda-mcp)
- **Install**: `pip install pixelpanda-mcp` or `uvx pixelpanda-mcp`
- **MCP Config**: `{ "mcpServers": { "pixelpanda": { "command": "uvx", "args": ["pixelpanda-mcp"], "env": { "PIXELPANDA_API_TOKEN": "pk_live_..." } } } }`
- **Note**: `PIXELPANDA_API_TOKEN` only required for premium generation features. Local and free AI tools work without it.
- **Applicable To**: Marketing, Business, Dev projects

---

## Skill Deployment by Project Type

| Project Type | Default Skills |
|---|---|
| **Dev (Coding)** | frontend-design, api-design-principles, git-commit-messages, playwright-testing, mcp-builder, vercel-react-best-practices, planning-with-files |
| **Financial** | spreadsheet-ops, pdf-ops, data-analysis, document-creation, markitdown |
| **Business** | document-creation, presentation-builder, spreadsheet-ops, internal-comms, seo-audit, copywriting, agent-browser |
| **Research** | document-creation, pdf-ops, data-analysis, presentation-builder, agent-browser, markitdown |
| **Marketing** | document-creation, presentation-builder, copywriting, seo-audit, md-anything, pixelpanda-mcp, agent-browser |
| **Misc** | document-creation, pdf-ops, markitdown |

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
