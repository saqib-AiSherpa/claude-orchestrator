# Skills Registry — {PROJECT_NAME}

> Skills available in this project. Skills are loaded automatically when relevant, or invoked via `/skill-name`.

---

## Active Skills

{SKILL_ENTRIES}

---

## Adding Skills

If this project needs a skill not listed above:
1. Check the parent orchestrator's `SKILLS.md` for available skills
2. If the needed skill exists, copy it to `.claude/skills/`
3. If it doesn't exist, use `/skill-creator` to build one, then notify the Orchestrator for registry sync

## Skill Format

Each skill is a directory with at minimum a `SKILL.md` file:
```
skill-name/
├── SKILL.md          # Required — YAML frontmatter + instructions
├── scripts/          # Optional — executable helpers
├── templates/        # Optional — output templates
└── examples/         # Optional — reference examples
```
