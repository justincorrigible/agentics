# Contributing to softeng/agentics

This repo distributes the devctx collaboration template. Changes here propagate to teams and users who adopt it: design with care.

## Design principles

- **Dispatch over inline**: `CLAUDE.md` stays lean (~30 lines); convention detail lives in separate files loaded on demand
- **Agent-neutral**: template files must not reference Claude-specific paths (`~/.claude/`); use "your agent's global context directory" with a parenthetical for Claude users where needed
- **No credentials**: no secrets, private URLs, or internal endpoints anywhere in this repo: ever
- **Additive, not prescriptive**: role and org files add or modify the base; they do not replace it
- **Lean project files**: downstream project `CLAUDE.md`/`AGENTS.md` should be lean: project-specific content inline, universal conventions as pointers to this template

## Agent setup for contributors

If you use an AI agent and are actively contributing to agentics, set the following in your project memory for this repo:

```
agentics_contributor: yes
```

This enables two behaviours without needing to opt in per session:
- Propagation suggestions are always on: your agent surfaces convention improvements proactively
- The agentics repo is always named as an explicit candidate, alongside the project and global levels

Your agent will ask about this on the first session in this repo (initialization block in `CLAUDE.md`). You can also set it manually in project memory at any time.

See `template/conventions/convention-levels.md` for what propagation suggestions look like in practice.

## Proposing changes

1. Identify which level the change belongs at: see `template/conventions/convention-levels.md`
2. Make the change and add a CHANGELOG entry under `## Unreleased`
3. Do not bump the version tag in `template/CLAUDE.md` until the previous version is committed to remote
4. Mark `breaking: yes` in the CHANGELOG if downstream copies need a manual update

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
