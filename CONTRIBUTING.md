# Contributing to softeng/agentics

This repo distributes the devctx collaboration template. Changes here propagate to teams and users who adopt it: design with care.

## Design principles

- **Dispatch over inline**: `CLAUDE.md` stays lean (~30 lines); convention detail lives in separate files loaded on demand
- **Agent-neutral**: template files must not reference Claude-specific paths (`~/.claude/`); use "your agent's global context directory" with a parenthetical for Claude users where needed
- **No credentials**: no secrets, private URLs, or internal endpoints anywhere in this repo: ever
- **No personal identifying details**: no local usernames, real names of individual contributors, machine-specific absolute paths, or personal account handles (e.g. a personal fork under your own GitHub username) anywhere in this repo. It's read by people with no context for who you are or what machine you use, this session's history included: a personal GitHub username and a contributor's first name both made it into committed docs before being caught. Use generic placeholders instead: "the developer," "the repo's lead developer" (see "Name code, not people" in `session-discipline.md`), "a local clone," "your global context"
- **Additive, not prescriptive**: role and org files add or modify the base; they do not replace it
- **Lean project files**: downstream project `CLAUDE.md`/`AGENTS.md` should be lean: project-specific content inline, universal conventions as pointers to this template
- **Explicit audience**: don't rely on filename or folder structure alone to signal that a file is agent instructions rather than human documentation — a person unfamiliar with the convention won't necessarily infer it. `CLAUDE.md`/`AGENTS.md` (both root and template) say so explicitly in their opening lines; a file that's genuinely dual-audience (e.g. `docs/agent-security.md`) says that instead. Apply the same to any new agent-facing file whose purpose isn't obvious from context

## Agent setup for contributors

If you use an AI agent and are actively contributing to agentics, set the following in your **global context** (not just this repo's project memory — it needs to apply in every project you work in, not only sessions inside agentics itself):

```
agentics_contributor: yes
```

This enables three behaviours without needing to opt in per session or per project:
- Propagation suggestions are always on: your agent surfaces convention improvements proactively
- The agentics repo is always named as an explicit candidate, alongside the project and global levels
- The upstream-update check becomes mandatory, not opt-in, in every project you work in — regardless of that project's own `propagation_suggestions` setting — and keeps recurring every session for an unresolved gap rather than surfacing it once and going quiet. This is deliberately more insistent than the standard opt-in tier: contributing to agentics implies keeping the ecosystem you're helping build actually current is part of the job. It stops only on an explicit "stop for this project" (recorded in that project's memory) or "stop for all projects" (recorded in your global context), never inferred from silence — someone who'd rather turn this off entirely than deal with it is signalling something about how invested they actually are in contributing, which is fine, but it's their call to make explicitly.

Your agent will ask about this on the first session in this repo (initialization block in `CLAUDE.md`), and should record the answer in your global context, not (only) this repo's project memory. You can also set it manually in your global context at any time.

See `template/conventions/convention-levels.md` § Checking for upstream updates for what this looks like in practice.

## Proposing changes

1. Identify which level the change belongs at: see `template/conventions/convention-levels.md`
2. Make the change and add a CHANGELOG entry under `## Unreleased`
3. Before committing, run `grep -rn '~/\.claude\|Claude Code' template/` and check every hit: it needs either a `(for Claude: X; for other agents: Y)` parenthetical or a reason it's genuinely Claude-only (e.g. `.claude/settings.json`). The "Agent-neutral" principle above has drifted back into the template more than once despite being written down; the grep catches what a read-through misses.
4. Also before committing, grep the diff for anything identifying you specifically: your OS username (`whoami`), your git identity (`git config user.name`/`user.email`), and any personal account or fork name you know is yours (e.g. `git remote -v` if you're working from a personal fork). This isn't hypothetical: it's how the check ended up written this way.
5. Do not bump the version tag in `template/CLAUDE.md` until the previous version is committed to remote
6. Mark `breaking: yes` in the CHANGELOG if downstream copies need a manual update

## Creating a new role file

Role files live in `template/CLAUDE.roles/`. Each one describes what to add, modify, or de-emphasize relative to the base template for a specific type of user.

### Steps

1. Create `template/CLAUDE.roles/<role>.md` using this structure:

   ```markdown
   # <Role name>

   [Who this is: 1-2 sentences, plain language, no jargon]

   [Optionally: Builds on: CLAUDE.roles/general.md: read that first.]

   ## [Relevant section]
   [What the base template adds or changes for this role]

   ## De-emphasize from base template
   [Conventions less relevant to this role, and why]
   ```

2. Add the role name to the initialization question in both:
   - `template/CLAUDE.md`: initialization block, step 2
   - `template/AGENTS.md`: initialization block, step 2

3. Add a CHANGELOG entry:
   ```
   date | template | no | role-<name>: add CLAUDE.roles/<name>.md: <one-line description>
   ```

### What goes in a role file

- Communication style (plain language vs. technical, jargon threshold)
- Domain-specific conventions (data pipelines for bio, prompt hygiene for ai-eng)
- Session discipline adaptations (how `.dev/` files translate for non-technical users)
- Security additions specific to the domain
- What to de-emphasize from the base

### What stays out of role files

- Credentials, secrets, private URLs: never, in any file
- Org-specific content: goes in the org layer (e.g., `CLAUDE.softeng.md`)
- Project-specific content: goes in the project's own `CLAUDE.md` / `AGENTS.md`
- Claude-specific paths (`~/.claude/`): role files are agent-neutral

### The `general` role as foundation

`general.md` is for users who may not work with files, code, or software projects at all. It is the foundation for non-developer specialist profiles. If you are creating a role for a non-developer audience: admin, ops, clinical, legal: start from it:

```
Builds on: CLAUDE.roles/general.md: read that first.
```

Then add only what is specific to that audience.

### The four existing roles

| File | Audience | Foundation for |
|---|---|---|
| `dev.md` | Software developers |: (base template is the dev default) |
| `general.md` | Any user; non-technical task assistance | Admin, ops, clinical, and similar |
| `bio.md` | Bioinformaticians |: |
| `ai-eng.md` | AI/ML engineers building AI systems |: |
