# Agent collaboration template

This directory contains template files for setting up AI agent collaboration. `AGENTS.md` and `CLAUDE.md` are meant to be copied into your project root and adapted; everything else here, `conventions/`, `AGENTS.roles/`, `AGENTS.softeng.md`, `AGENTS.overture.md`, `global-context/`, is global-guideline material, read live from agentics or used once to bootstrap your agent's own global context, and never belongs copied into a project (see "How to adopt" below).

## Files

| File                                 | Purpose                                                                                                                                                                      |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AGENTS.md`                          | Canonical source, agent-neutral: conventions, dispatch table, project-specific content all live here                                                                         |
| `CLAUDE.md`                          | Minimal stub: exists only because Claude Code loads it automatically, points at `AGENTS.md`                                                                                  |
| `AGENTS.softeng.md`                  | softeng team addendum: applied conditionally on first session                                                                                                                |
| `AGENTS.overture.md`                 | Overture product-family addendum: applied conditionally on first session                                                                                                     |
| `conventions/convention-levels.md`   | Three-level placement model (project / global / shareable) and propagation questions                                                                                         |
| `conventions/upstream-check.md`      | Whether this project is behind agentics: gating, tag format, and the comparison and classification steps                                                                     |
| `conventions/context-economy.md`     | Deciding what instruction text costs too much and what to do about it: measure, classify by trigger, relocate                                                                |
| `conventions/entry-formats.md`       | Formats for a session-file entry and a tech-debt entry: what each must and must not contain                                                                                  |
| `conventions/agent-troubleshooting.md`| Symptoms where the agent's own environment is the problem: a file it can't see, memory that doesn't follow a project                                                        |
| `conventions/upgrading-adoption.md`  | On-demand procedure for bringing an already-adopted project's agentics integration current                                                                                   |
| `conventions/session-discipline.md`  | Session start checklist, `.dev/` write-back rules, tech-debt entry format, git/commit rules                                                                                  |
| `conventions/initialization.md`      | The setup questions and their defaults; read once when adopting, never again                                                                                                 |
| `conventions/git.md`                 | Branching, staging, commit messages, pushing, and unattributed working-tree changes                                                                                          |
| `conventions/testing.md`             | Test co-location, plan-first workflow, BDD style                                                                                                                             |
| `conventions/code-style.md`          | Comments, scope discipline, library awareness: developer role only                                                                                                            |
| `conventions/writing-style.md`       | Dashes, spelling, typos, property ordering: applies to any output, dev or not                                                                                                |
| `conventions/code-review.md`         | Pre-review gate: problem, layer, necessity, before examining implementation                                                                                                  |
| `conventions/review-conduct.md`      | Behavioral conventions for conducting a review: ground truth over claims, disposition per finding, draft-never-post                                                          |
| `conventions/definition-of-done.md`  | Completion checklist tying together tests, docs, `.dev/` upkeep, lessons learned, CHANGELOG, and a final refinement pass                                                     |
| `conventions/documentation.md`       | Two-tier docs model, cross-linking, writing for a cold reader                                                                                                                |
| `conventions/persistence-map.md`     | Index across every persistence layer (memory, roadmap, tech-debt, atlas): where a new fact or finding actually goes, in order                                               |
| `conventions/agent-index.md`         | Opt-in, capability-gated: a shared directory and bulletin board for sessions to reach each other directly across projects                                                   |
| `conventions/security.md`            | OWASP awareness, credentials policy, quick threat model                                                                                                                      |
| `conventions/security-guidelines.md` | Full OWASP-aligned patterns, failure state docs, and code review triggers                                                                                                    |
| `DEVELOPMENT.md`                     | Human developer setup and onboarding guide (placeholder)                                                                                                                     |
| `.claude/settings.json`              | Claude Code hook: blocks agent access to credential files at the tool level                                                                                                  |
| `global-context/`                    | Templates for your agent's global context directory (cross-project map, security guidelines). For Claude: copy to `~/.claude/`; for other agents: consult your agent's docs. |

## How to adopt

1. Copy `AGENTS.md` to your project root; also copy `CLAUDE.md` if you use Claude Code (it auto-loads that file specifically, but stays a stub pointing at `AGENTS.md`)
2. Copy `DEVELOPMENT.md` and fill in your project-specific setup steps
3. Create a `.dev/` directory with `roadmap.md`, `tech-debt.md`, and a `sessions/` directory. A fourth file, `agentics-overrides.md`, is created on demand the first time the developer permanently declines a convention's recommendation for this project (see `conventions/convention-levels.md` § Recording a permanent override): don't create it empty upfront
4. Add `.claude/memory/` and `.claude/settings.local.json` to this project's `.gitignore`. Neither should ever exist, `AGENTS.md` § Memory and contribution hygiene says why, but an older adoption or another agent may have created one, and untracked is not the same as ignored: `git add -A` commits it. This is containment, separate from the rule that prevents it.
5. Copy `.claude/settings.json` to enforce the credential file blocklist (Claude Code only; skip if you have the hook in your global `~/.claude/settings.json`)
6. If your agent's global context doesn't yet define your role, your team's conventions (e.g. softeng), or your product family's (e.g. Overture), bootstrap it once from `AGENTS.roles/<role>.md`, `AGENTS.softeng.md`, and/or `AGENTS.overture.md`, the same way `global-context/` templates get copied to `~/.claude/` (or your agent's equivalent). This is a one-time action on your global context, not a per-project step

**`conventions/`, `AGENTS.roles/`, `AGENTS.softeng.md`, and `AGENTS.overture.md` are global-guideline material: they never belong copied into a project, under any circumstance.** See `conventions/convention-levels.md` § How much to keep locally for the full rule and why. The project `AGENTS.md` should contain only project-specific content: constraints, extension points, and repo structure notes.

## Keeping up to date

Your freshly-copied `AGENTS.md` carries a pointer, not a number (`<!-- agentics-template-version: see CHANGELOG.md § Released (latest entry) -->`), since inside agentics itself that's all it needs to be. Once copied into your project, that pointer no longer resolves to anything (your repo doesn't have agentics' `CHANGELOG.md`), so replace it on adoption with an actual snapshot: `<!-- agentics-template-version: X.Y.Z | synced: <commit-sha> -->`, reading `X.Y.Z` from the latest entry under agentics' `CHANGELOG.md` § Released, where `<commit-sha>` is agentics' current `HEAD` at copy time. `CLAUDE.md` carries no tag at all, copied or not: it's a stub pointing at `AGENTS.md`, including for this. If your global context has `propagation_suggestions: yes`, your agent checks this automatically at session start (see `conventions/upstream-check.md`) and surfaces what's changed since, no manual CHANGELOG comparison needed. Without that opt-in, compare the tag against the [agentics CHANGELOG](../CHANGELOG.md) yourself.

## Already have an existing setup?

If you already have a `CLAUDE.md`, `AGENTS.md`, or other agent instruction file, don't replace it: merge instead. Add the dispatch table and initialization block to your existing agent-neutral file (or create `AGENTS.md` if you don't have one); its `conventions/*.md` dispatch lines point at agentics itself, not a local copy, regardless of what your existing setup already covers. Softeng conventions are designed to supplement existing practices, not override them, and belong in your global context, not this project, same as any other adoption.

## Security

Agentics ships agent-facing security conventions, but part of the posture is yours and cannot be automated. Read [`docs/security-for-developers.md`](https://github.com/oicr-softeng/agentics/blob/main/docs/security-for-developers.md) in the agentics repo yourself, once: it covers what to verify yourself, which of your agent's claims about its own work are unreliable, and the trust boundaries only a person can hold. If you copied `.claude/settings.json`, it also gives you a short command to confirm the credential blocklist is actually live rather than silently allowing everything.

## Contributing back

If you establish a convention or improve a practice in your project that could benefit other teams, consider opening a PR to [softeng/agentics](https://github.com/oicr-softeng/agentics). Your agent can help identify candidates: the dispatch table in `AGENTS.md` includes a reminder to check when adding to project memory.
