# Global roadmap template

A global roadmap tracks work items and initiatives that span multiple projects or belong to a specific work context. Place these files in your agent's global context directory (e.g. `~/.claude/` for Claude Code).

## Splitting by context

If you work across distinct contexts - professional and personal, or multiple organisations - use one roadmap file per context rather than one combined file:

```
~/.claude/roadmap-work.md      # professional projects and initiatives
~/.claude/roadmap-personal.md  # personal projects and learning goals
```

At session start, read only the roadmap relevant to the current project. Reading a personal roadmap during a professional session (or vice versa) leaks cross-context noise and wastes context window.

The convention in `session-discipline.md` covers when to read which file.

## Format

```markdown
# [Context] Roadmap

Brief description of what this roadmap covers.

---

## Active initiatives

### [Initiative name]

What it is and why it matters. One short paragraph.

- [ ] Specific next action
- [ ] Another action

### [Another initiative]

...

---

## Parked / future

### [Idea name]

Brief note on what it is and why it's parked.
```

## Notes on use

- This file is read by the agent, not executed. Keep entries short enough to be useful in a context window.
- Completed items are removed, not marked done: `.dev/sessions/` (at the project level) is the historical record.
- Items that belong to a specific project should live in that project's `.dev/roadmap.md`, not here. Global roadmaps hold cross-project work and initiatives that have no single home.
