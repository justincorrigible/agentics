# Project Map

Global index of known projects, memory locations, and key cross-project relationships.
Place this file at `~/.claude/projects.md`. Update it when a new project is set up or when paths change.

---

## Projects

### [project-name]
- **Path:** `/path/to/project`
- **Memory:** `~/.claude/projects/[encoded-path]/memory/`
- **What:** one-line description of what this project is and does
- **Cross-project:** [what it depends on or what depends on it: omit if standalone]

### [another-project]
- **Path:** `/path/to/project`
- **Memory:** `~/.claude/projects/[encoded-path]/memory/`
- **What:** one-line description

---

## Key cross-project relationships

- **[Project A] → [Project B]**: brief description of the dependency or effect; coordinate before making breaking changes
- **[Project C] → [Project A, B]**: e.g. a shared chart server or auth layer that affects multiple downstream projects

---

## Notes

[Anything shared across projects: team context, deployment environment, shared auth, monorepo roots, etc.]
