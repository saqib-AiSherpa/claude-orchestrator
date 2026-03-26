---
name: ask
description: Cross-project natural language query. Ask anything about the portfolio — project status, outstanding items, who's working on what, entity lookups, or open tasks across all projects. Use /ask followed by your question.
---

# /ask — Cross-Project Query

The operator has asked a question about the portfolio. Answer it by reading across all relevant project files.

## Your Question

The operator asked: **{{args}}**

---

## How to Answer

1. **Parse the intent.** What type of question is this?
   - *Status query* (e.g. "what's happening with X project?") → read that project's CLAUDE.md, CHANGELOG, TASKS.md
   - *Portfolio overview* (e.g. "what are all projects working on?") → skim all projects' CLAUDE.md and recent CHANGELOG entries
   - *Entity lookup* (e.g. "who is Ahmad?", "what is Salesforce used for?") → read ENTITIES.md first, then check relevant project files
   - *Task/outstanding items* (e.g. "what's blocking us?", "what's not done?") → read orchestrator TASKS.md and per-project TASKS.md files
   - *Digest query* (e.g. "what happened today?") → read today's DAILY-DIGEST.md and/or EOD-DIGEST.md
   - *Cross-project* (e.g. "are any projects behind?") → scan all projects for relevant signals

2. **Read the right files.** Don't read everything — be targeted. For project status, CLAUDE.md + last 3 CHANGELOG entries is usually enough. For entities, ENTITIES.md first.

3. **Answer directly.** Lead with the answer, then supporting detail. No preamble. Format with markdown if the response is long.

4. **Flag gaps.** If the answer isn't in the files (e.g. the information doesn't exist yet), say so clearly and suggest how to get it.

---

## File Reference

- Orchestrator TASKS.md: `TASKS.md`
- Entity map: `ENTITIES.md`
- Today's digest: `reports/daily/{today}/DAILY-DIGEST.md`
- Today's EOD: `reports/daily/{today}/EOD-DIGEST.md`
- Per-project status: `projects/{name}/CLAUDE.md`
- Per-project tasks: `projects/{name}/TASKS.md`
- Per-project changelog: `projects/{name}/CHANGELOG.md`
- All projects list: `projects/` directory
