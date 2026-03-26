---
name: archive-project
description: Archive a completed or inactive project. Generates a completion report, moves the project to projects/archived/, removes its crontab entries, and updates all registries. Use /archive-project followed by the project name.
---

# /archive-project — Project Archiving Workflow

The operator wants to archive a project. This is a non-destructive operation — the project is moved to `projects/archived/`, not deleted.

## Project to Archive

**Project name:** {{args}}

---

## Step 0 — Confirm Project Exists

Read `projects/{{args}}/settings.json` and `projects/{{args}}/CLAUDE.md` to confirm the project exists and understand what it is.

If the project doesn't exist, stop and tell the operator.

---

## Step 1 — Generate Completion Report

Read the following and synthesise a completion report:
- `projects/{{args}}/CLAUDE.md` — what the project was
- `projects/{{args}}/CHANGELOG.md` — what was accomplished
- `projects/{{args}}/TASKS.md` — any outstanding tasks
- `projects/{{args}}/settings.json` — project metadata

Write the report to: `projects/{{args}}/COMPLETION-REPORT.md`

Format:
```markdown
# Completion Report — {project-name}
**Archived:** {today's date}
**Project type:** {type}
**Description:** {description}

## What Was This Project?
{2-3 sentences summarising the project's purpose and scope}

## What Was Accomplished?
{Bullet list of key deliverables and outcomes, drawn from CHANGELOG}

## Outstanding Items at Archive Time
{Any unfinished tasks or open items. "None" if all clear.}

## Why Archived
{State the reason if known from context, or leave as "Marked complete by operator"}

## Key Files
{List any important output files or deliverables worth noting for future reference}
```

---

## Step 2 — Update Project Status

In `projects/{{args}}/settings.json`, update `project.status` to `"archived"` and add `"archived_date": "{today}"`.

---

## Step 3 — Move to Archived Directory

```bash
mkdir -p projects/archived
mv projects/{{args}} projects/archived/{{args}}
```

---

## Step 4 — Remove from Crontab

Read the current crontab with `crontab -l`. Remove any lines referencing `projects/{{args}}/scripts/morning-report.sh`. Write the updated crontab back with `crontab -`.

Show the operator which crontab lines were removed.

---

## Step 5 — Update Registries

1. In the master `AGENTS.md`: find any agents listed as belonging exclusively to `{{args}}`. Add a note `(archived: {{args}})` next to them, or remove them if they were project-specific and not reusable.

2. In the master `SKILLS.md`: same treatment for project-specific skills.

3. In `TASKS.md` (orchestrator level): mark any open tasks tagged `[{{args}}]` as archived. Move them to the `## 📦 Archived` section with a note `(project archived {today})`.

4. In `ENTITIES.md` (if it exists): update the Projects column for any entities that listed `{{args}}` — replace it with `{{args}} (archived)`.

---

## Step 6 — Confirm

Output a summary:
```
✅ Project archived: {{args}}

  Completion report: projects/archived/{{args}}/COMPLETION-REPORT.md
  Crontab entries removed: {N}
  Tasks archived: {N}
  Status: projects/archived/{{args}}/settings.json → "archived"

The project directory has been moved to projects/archived/.
All registries have been updated.
```

---

## Safety Notes

- **Never delete files.** Only move them.
- If the project directory is a symlink to somewhere outside the orchestrator, stop and warn the operator before moving.
- If `projects/archived/{{args}}` already exists, stop and ask the operator whether to overwrite.
