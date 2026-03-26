# Cross-Project Task Board
**Last updated:** 2026-03-26 | **Maintained by:** Orchestrator nightly job

> This is the master task board. Per-project task boards live in `projects/{name}/TASKS.md`.
> The nightly maintenance job (`scripts/daily-sync.sh`) syncs open tasks from all projects into this file.
> Tasks completed across all projects are archived here weekly.

---

## 🔴 Urgent

<!-- Tasks needing same-day or immediate attention -->
<!-- Format: - [ ] [PROJECT] Description @owner #due-date -->

---

## 📌 In Progress

<!-- Tasks actively being worked on -->

---

## 📋 Backlog

<!-- Planned but not started -->

---

## ✅ Completed This Week

<!-- Tasks completed in the last 7 days — cleared weekly by nightly job -->

---

## 📦 Archived

<!-- See reports/task-archive/ for historical completed tasks -->

---

*Task format:*
```
- [ ] [PROJECT] Task description @agent-or-owner #YYYY-MM-DD
- [x] [PROJECT] Completed task ✓ YYYY-MM-DD
```
