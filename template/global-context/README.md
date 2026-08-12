# Global context templates

These files are templates for your agent's **personal global context**: configuration that applies across all your projects, not just one.

Copy them to wherever your agent reads global/personal context:

| Agent | Global context directory |
|-------|--------------------------|
| Claude (Claude Code) | `~/.claude/` |
| Others | Consult your agent's documentation |

The agent-neutral convention files under `conventions/` carry the same content for use within a single project. These global-context templates are for users who want the same files accessible across all their projects without copying them into each one.

## Files

- `personal-preferences.md`: universal interaction parameters and critical constraints, agent-neutral, for a developer who wants agentics' behavioral conventions personally without adopting it into any specific project
- `projects.md`: cross-project map: paths, memory locations, and relationships between your projects
- `roadmap.md`: template and convention for global roadmaps, including how to split by work context (professional vs personal)
- `security-guidelines.md`: OWASP-aligned security patterns, threat model, and code review triggers

## Bootstrapping without a project

When a developer asks for personal, global-only setup (e.g. "set up my personal AI collaboration preferences using agentics, global context only"), don't run the project-level initialization flow at all, no `AGENTS.md`, no `.dev/`, nothing created or suggested for committing anywhere:

1. Ask the same role question `template/AGENTS.md`'s initialization uses (developer / bioinformatician / AI engineering / general), and whether they're on the softeng team or working on an Overture project, skipping any already known from existing global context.
2. Copy `personal-preferences.md` above into the developer's own global context file (for Claude Code: merge its sections into `~/.claude/CLAUDE.md`, creating it if none exists yet, additive, don't overwrite unrelated existing content; for other agents: consult your agent's docs for where global/personal instructions live). Replace its canonical pointer tag with an actual snapshot, `<!-- agentics-template-version: X.Y.Z | synced: <commit-sha> -->`, `X.Y.Z` from agentics' latest `CHANGELOG.md` § Released entry, `<commit-sha>` its current `HEAD` at copy time, same as project adoption already does.
3. Bootstrap the matching `CLAUDE.roles/<role>.md`, and `CLAUDE.softeng.md`/`CLAUDE.overture.md` if applicable, the same way, once, per their answers.
4. Record `propagation_suggestions` per the usual default-prompting rule in `AGENTS.md` § Initialization; nothing else needs asking.
5. Stop there. No project files, no `.dev/`, nothing to commit anywhere.
