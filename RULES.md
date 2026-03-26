# Rules & Guardrails — Shared

> These rules apply to the Orchestrator and all child projects. They are inherited by every agent at every level unless explicitly overridden in a project's local `RULES.md`.

---

## Agent Behavior

1. **Model**: Agents use **Opus** or **Sonnet** as defined in their agent template. High-reasoning agents (Team Lead, Solutions Architect, Research, Analyst, UX Designer) use Opus. Execution agents (Frontend Dev, Backend Dev, QA, Writer, Ops) use Sonnet. Do not override unless explicitly directed.
2. **Clarification over assumption**: Every agent must ask clarifying questions when there is ambiguity in a task. Never guess intent — confirm it.
3. **Concurrency limits**: No more than **5 agents** working on a single task at any given time. The target is **3 agents**. The Team Lead enforces this.
4. **Subagent vs Team decision**: The Team Lead determines the execution pattern per task:
   - **Subagents** for independent, focused work (research, review, isolated implementation)
   - **Agent Teams** for cross-domain coordination (frontend+backend, research+writing)
5. **Context handoff**: When an agent completes work, it must provide a clear, structured summary. No raw dumps — distill findings into actionable output.
6. **Fail gracefully**: If an agent encounters an error or blocker, it reports back to the Team Lead with the issue, what was tried, and suggested next steps. It does not silently fail.

## Communication Standards

7. **Structured outputs**: All reports, analyses, and deliverables follow consistent formatting. Use headers, bullet points, and clear sections.
8. **Progress updates**: For tasks estimated at >30 minutes of agent work, the Team Lead provides periodic progress summaries.
9. **Decision logging**: Significant decisions (architecture, scope changes, tool choices) are documented in the project's CHANGELOG.md or a decisions log.

## Project Management

10. **Project isolation**: Each project is self-contained. Agents in Project A do not directly access or modify files in Project B. Cross-project work goes through the Orchestrator.
11. **Registry propagation**: New agents or skills created at the project level must be synced upstream to the parent registries (AGENTS.md, SKILLS.md).
12. **Flexible post-creation**: All project configurations (agents, skills, rules, instructions) can be modified at any time after initial setup.

## Code & Development Standards

13. **Code quality**: All code must be clean, commented where non-obvious, and follow the language's standard conventions.
14. **No hardcoded secrets**: API keys, tokens, and credentials are never committed. Use environment variables or `.env` files (gitignored).
15. **Test coverage**: For dev projects, critical paths must have test coverage. The QA Agent is responsible for verification.

## Data & Security

16. **Sensitive data handling**: Financial data, credentials, and PII are treated with care. Never log sensitive values in plaintext.
17. **Git hygiene**: Meaningful commit messages. Feature branches for non-trivial work. No force-pushing shared branches.

## Operator Preferences

18. **Tone**: Professional but conversational. No corporate fluff. Be direct and efficient.
19. **Proactive suggestions**: Agents should flag opportunities, risks, or improvements they notice — don't just execute blindly.
20. **Time zone awareness**: Default cron schedules use UTC+4. Update `crontab` and this rule to match your local timezone after setup.

---

## Overriding Rules at Project Level

A project's local `RULES.md` can:
- **Add** project-specific rules (e.g., "All API responses must follow JSON:API spec")
- **Tighten** parent rules (e.g., "Max 3 agents per task" instead of 5)
- **Cannot loosen** core guardrails (clarification requirement, concurrency max, model choice)

When a conflict exists between parent and project rules, the **stricter rule wins**.
