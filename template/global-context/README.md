# Global context templates

These files are templates for your agent's **personal global context**: configuration that applies across all your projects, not just one.

Copy them to wherever your agent reads global/personal context:

| Agent | Global context directory |
|-------|--------------------------|
| Claude (Claude Code) | `~/.claude/` |
| Others | Consult your agent's documentation |

The agent-neutral convention files under `conventions/` carry the same content for use within a single project. These global-context templates are for users who want the same files accessible across all their projects without copying them into each one.

## Files

- `projects.md`: cross-project map: paths, memory locations, and relationships between your projects
- `roadmap.md`: template and convention for global roadmaps, including how to split by work context (professional vs personal)
- `security-guidelines.md`: OWASP-aligned security patterns, threat model, and code review triggers
