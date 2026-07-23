# Project Map

Global index of known projects, memory locations, and key cross-project relationships.
Place this file in your agent's global context directory (for Claude: `~/.claude/projects.md`; for other agents: consult your agent's docs). Update it when a new project is set up or when paths change.

**Repo URL vs local Path:** when a task references a project's GitHub URL (a doc link, a PR target, "check the latest conventions"), prefer reading the local `Path` over fetching the URL: it's faster and may be ahead of origin (uncommitted or unpushed work). Verify freshness first with `git log @{u}..` in that directory, since local can also be behind origin if someone else pushed. If you're the sole maintainer of a given repo, note that as an exception and skip the freshness check for it.

---

## Agentic projects

Projects known to have adopted agentics (a project that adopts it becomes "agentic"): list them by name only, e.g. `org/project-a`, `org/project-b`.

Update this list only when a project adopts or drops agentics entirely, not on every version sync: the version each one is currently synced to already lives canonically in that project's own `AGENTS.md` tag, restating it here would just go stale the next time any one of them syncs.

---

## Projects

### [project-name]
- **Path:** `/path/to/project`
- **Repo URL:** `https://github.com/org/repo`
- **Memory:** (if your agent has a persistent memory system) for Claude: `~/.claude/projects/[encoded-path]/memory/`; for other agents: your agent's equivalent
- **What:** one-line description of what this project is and does
- **Cross-project:** [what it depends on or what depends on it: omit if standalone]

### [another-project]
- **Path:** `/path/to/project`
- **Repo URL:** `https://github.com/org/repo`
- **Memory:** (if your agent has a persistent memory system) for Claude: `~/.claude/projects/[encoded-path]/memory/`; for other agents: your agent's equivalent
- **What:** one-line description

---

## Key cross-project relationships

- **[Project A] → [Project B]**: brief description of the dependency or effect; coordinate before making breaking changes
- **[Project C] → [Project A, B]**: e.g. a shared chart server or auth layer that affects multiple downstream projects

---

## Notes

[Anything shared across projects: team context, deployment environment, shared auth, monorepo roots, etc.]
