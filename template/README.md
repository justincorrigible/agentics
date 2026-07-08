# Agent collaboration template

This directory contains template files for setting up AI agent collaboration in your project. Copy the files you need into your project root and adapt them.

## Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Agent instructions for Claude: lean dispatch file, ~30 lines |
| `AGENTS.md` | Agent-neutral version of the same instructions |
| `CLAUDE.softeng.md` | softeng team addendum: applied conditionally on first session |
| `conventions/convention-levels.md` | Three-level placement model (project / global / shareable) and propagation questions |
| `conventions/session-discipline.md` | Session start checklist, `.dev/` write-back rules, tech-debt entry format |
| `conventions/testing.md` | Test co-location, plan-first workflow, BDD style |
| `conventions/code-style.md` | Comments, scope discipline, library awareness, git |
| `conventions/security.md` | OWASP awareness, credentials policy, quick threat model |
| `conventions/security-guidelines.md` | Full OWASP-aligned patterns, failure state docs, and code review triggers |
| `DEVELOPMENT.md` | Human developer setup and onboarding guide (placeholder) |
| `.claude/settings.json` | Claude Code hook: blocks agent access to credential files at the tool level |
| `global-context/` | Templates for your agent's global context directory (cross-project map, security guidelines). For Claude: copy to `~/.claude/`; for other agents: consult your agent's docs. |

## How to adopt

1. Copy `CLAUDE.md` (and optionally `AGENTS.md`) to your project root
2. Copy `CLAUDE.softeng.md` if your team uses the softeng conventions
3. Copy `DEVELOPMENT.md` and fill in your project-specific setup steps
4. Create a `.dev/` directory with `roadmap.md`, `tech-debt.md`, and a `sessions/` directory
5. Copy `.claude/settings.json` to enforce the credential file blocklist (Claude Code only; skip if you have the hook in your global `~/.claude/settings.json`)

**`conventions/`, `CLAUDE.roles/`, and `CLAUDE.softeng.md` are bootstrapping artifacts** for agents that don't yet have a comprehensive global context. If your agent's global context already defines universal conventions (testing style, code style, security, session discipline), your role, and your team's conventions, skip copying these. The project `CLAUDE.md` should contain only project-specific content: constraints, extension points, and repo structure notes.

## Keeping up to date

The version tag in `CLAUDE.md` (`<!-- agentics-template-version: X.Y.Z -->`) tracks which version of this template you adopted. Compare it against the [agentics CHANGELOG](../CHANGELOG.md) to see what has changed since your last update.

## Already have an existing setup?

If you already have a `CLAUDE.md` or other agent instruction file, don't replace it: merge instead. Add the dispatch table and initialization block to your existing file, and copy only the `conventions/` content that your project does not already cover. Softeng conventions are designed to supplement existing practices, not override them.

## Contributing back

If you establish a convention or improve a practice in your project that could benefit other teams, consider opening a PR to [softeng/agentics](https://github.com/oicr-softeng/agentics). Your agent can help identify candidates: the dispatch table in `CLAUDE.md` includes a reminder to check when adding to project memory.
