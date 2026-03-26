# Rules & Guardrails — {PROJECT_NAME}

> This project inherits all rules from the parent orchestrator's `RULES.md`. The rules below are additions or tightened constraints specific to this project.

## Inherited Rules (from parent)

All rules in the parent `RULES.md` apply here. Key inherited rules:
- All agents use **Sonnet** model
- **Ask clarifying questions** — never assume
- **Max 5 agents per task** (target 3)
- Structured outputs, decision logging, fail gracefully
- No hardcoded secrets, meaningful commits, test critical paths

---

## Project-Specific Rules

{PROJECT_RULES}

---

## Rule Precedence

When a conflict exists between parent and project rules, the **stricter rule wins**. Project rules can:
- ✅ Add new rules
- ✅ Tighten parent rules (e.g., "max 3 agents" instead of 5)
- ❌ Cannot loosen core guardrails
