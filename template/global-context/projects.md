# Project Map

Global index of known projects, memory locations, and key cross-project relationships.
Place this file in your agent's global context directory (for Claude: `~/.claude/projects.md`; for other agents: consult your agent's docs). Update it when a new project is set up or when paths change.

**Repo URL vs local Path:** when a task references a project's GitHub URL (a doc link, a PR target, "check the latest conventions"), prefer reading the local `Path` over fetching the URL: it's faster and may be ahead of origin (uncommitted or unpushed work). Verify freshness first, and verify the right thing: confirm the local clone's configured remote(s) actually include the canonical URL recorded above (`git remote -v`) before trusting `git log @{u}..` in that directory. `@{u}` only reports how far local is behind whatever it happens to track, not whether that's the right remote at all. A clone pointed at a stale personal fork or an unintended mirror can report "0 behind" while still being badly out of date relative to the canonical source. Don't skip this check for a repo you believe you're the sole maintainer of: that belief can silently stop being true the moment a new contributor joins, and the check itself costs only one cheap `git fetch`.

---

## Agentic projects

Projects known to have adopted agentics (a project that adopts it becomes "agentic"): list them by name only, e.g. `org/project-a`, `org/project-b`.

Update this list only when a project adopts or drops agentics entirely, not on every version sync: the version each one is currently synced to already lives canonically in that project's own `AGENTS.md` tag, restating it here would just go stale the next time any one of them syncs.

---

## Ownership

Give every entry an `Owner:` field, and state your default owner once here rather than repeating it per project. This exists because "who owns this?" is a question an agent will otherwise try to infer from a repo URL, a GitHub org, or a service's name, and those infer wrongly: a component your own team built can read as a third-party dependency awaiting someone else's commitment. Confirmed in practice, twice on the same component before the field existed.

State plainly that a project marked with your own team's name is built and maintained in-house, and is never to be described as external, unknown, or pending another team. Keep two things out of the field, since they are separate facts with their own homes: which GitHub organization a repo happens to sit in belongs in `Repo URL`, because owned work can live in a partner org; and a third-party component you have adopted and now maintain belongs in `What` or `Note`, because that nuance is about provenance rather than current ownership.

If your agent's global context holds a profile of you and your team, point at it from here rather than copying it. A second copy drifts from the first, which is the duplication the field is meant to remove.

---

## Projects

### [project-name]
- **Path:** `/path/to/project`
- **Repo URL:** `https://github.com/org/repo`
- **Memory:** (if your agent has a persistent memory system) for Claude: `~/.claude/projects/[encoded-path]/memory/`; for other agents: your agent's equivalent
- **What:** one-line description
- **Owner:** which team builds and maintains it of what this project is and does
- **Owner:** which team builds and maintains it, e.g. your own team's short name
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
