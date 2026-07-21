# Agent collaboration template

This directory contains template files for setting up AI agent collaboration in your project. Copy the files you need into your project root and adapt them.

## Files

| File                                 | Purpose                                                                                                                                                                      |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AGENTS.md`                          | Canonical source, agent-neutral: conventions, dispatch table, project-specific content all live here                                                                         |
| `CLAUDE.md`                          | Minimal stub: exists only because Claude Code loads it automatically, points at `AGENTS.md`                                                                                  |
| `CLAUDE.softeng.md`                  | softeng team addendum: applied conditionally on first session                                                                                                                |
| `conventions/convention-levels.md`   | Three-level placement model (project / global / shareable) and propagation questions                                                                                         |
| `conventions/upgrading-adoption.md`  | On-demand procedure for bringing an already-adopted project's agentics integration current                                                                                   |
| `conventions/session-discipline.md`  | Session start checklist, `.dev/` write-back rules, tech-debt entry format                                                                                                    |
| `conventions/testing.md`             | Test co-location, plan-first workflow, BDD style                                                                                                                             |
| `conventions/code-style.md`          | Comments, scope discipline, library awareness, git                                                                                                                           |
| `conventions/code-review.md`         | Pre-review gate: problem, layer, necessity, before examining implementation                                                                                                  |
| `conventions/review-conduct.md`      | Behavioral conventions for conducting a review: ground truth over claims, disposition per finding, draft-never-post                                                          |
| `conventions/documentation.md`       | Two-tier docs model, cross-linking, writing for a cold reader                                                                                                                |
| `conventions/security.md`            | OWASP awareness, credentials policy, quick threat model                                                                                                                      |
| `conventions/security-guidelines.md` | Full OWASP-aligned patterns, failure state docs, and code review triggers                                                                                                    |
| `DEVELOPMENT.md`                     | Human developer setup and onboarding guide (placeholder)                                                                                                                     |
| `.claude/settings.json`              | Claude Code hook: blocks agent access to credential files at the tool level                                                                                                  |
| `global-context/`                    | Templates for your agent's global context directory (cross-project map, security guidelines). For Claude: copy to `~/.claude/`; for other agents: consult your agent's docs. |

## How to adopt

1. Copy `AGENTS.md` to your project root; also copy `CLAUDE.md` if you use Claude Code (it auto-loads that file specifically, but stays a stub pointing at `AGENTS.md`)
2. Copy `CLAUDE.softeng.md` if your team uses the softeng conventions
3. Copy `DEVELOPMENT.md` and fill in your project-specific setup steps
4. Create a `.dev/` directory with `roadmap.md`, `tech-debt.md`, and a `sessions/` directory. A fourth file, `agentics-overrides.md`, is created on demand the first time an upgrade check hits a conflict the developer wants to keep permanently (see `conventions/upgrading-adoption.md` § 2): don't create it empty upfront
5. Copy `.claude/settings.json` to enforce the credential file blocklist (Claude Code only; skip if you have the hook in your global `~/.claude/settings.json`)

**`conventions/`, `CLAUDE.roles/`, and `CLAUDE.softeng.md` are bootstrapping artifacts** for agents that don't yet have a comprehensive global context. If your agent's global context already defines universal conventions (testing style, code style, security, session discipline), your role, and your team's conventions, skip copying these. The project `AGENTS.md` should contain only project-specific content: constraints, extension points, and repo structure notes.

## Keeping up to date

Your freshly-copied `AGENTS.md` carries a pointer, not a number (`<!-- agentics-template-version: see CHANGELOG.md § Released (latest entry) -->`), since inside agentics itself that's all it needs to be. Once copied into your project, that pointer no longer resolves to anything (your repo doesn't have agentics' `CHANGELOG.md`), so replace it on adoption with an actual snapshot: `<!-- agentics-template-version: X.Y.Z | synced: <commit-sha> -->`, reading `X.Y.Z` from the latest entry under agentics' `CHANGELOG.md` § Released, where `<commit-sha>` is agentics' current `HEAD` at copy time. `CLAUDE.md` carries no tag at all, copied or not: it's a stub pointing at `AGENTS.md`, including for this. If your global context has `propagation_suggestions: yes`, your agent checks this automatically at session start (see `conventions/convention-levels.md` § Checking for upstream updates) and surfaces what's changed since, no manual CHANGELOG comparison needed. Without that opt-in, compare the tag against the [agentics CHANGELOG](../CHANGELOG.md) yourself.

## Already have an existing setup?

If you already have a `CLAUDE.md`, `AGENTS.md`, or other agent instruction file, don't replace it: merge instead. Add the dispatch table and initialization block to your existing agent-neutral file (or create `AGENTS.md` if you don't have one), and copy only the `conventions/` content that your project does not already cover. Softeng conventions are designed to supplement existing practices, not override them.

## Contributing back

If you establish a convention or improve a practice in your project that could benefit other teams, consider opening a PR to [softeng/agentics](https://github.com/oicr-softeng/agentics). Your agent can help identify candidates: the dispatch table in `AGENTS.md` includes a reminder to check when adding to project memory.
