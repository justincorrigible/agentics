# Contributing to softeng/agentics

This repo distributes the devctx collaboration template. Changes here propagate to teams and users who adopt it: design with care.

## Design principles

- **Dispatch over inline**: `CLAUDE.md` stays lean (~30 lines); convention detail lives in separate files loaded on demand
- **Agent-neutral**: template files must not reference Claude-specific paths (`~/.claude/`); use "your agent's global context directory" with a parenthetical for Claude users where needed
- **`AGENTS.md` is the single source; other agent-specific files are stubs, not copies:** `CLAUDE.md` (root and `template/`) holds nothing but a pointer to `AGENTS.md`, because Claude Code loads it automatically and something has to exist for that purpose. If this repo ever adds another agent-specific file (a Cursor rules file, `.github/copilot-instructions.md`), give it the same treatment: a stub pointing at `AGENTS.md`, never a second copy of content. This wasn't the original design: `AGENTS.md` used to inline everything on a false premise (see `CHANGELOG.md`'s `agents-md-single-dispatch-table` entry), and before that, both files carried independent copies that drifted repeatedly — a missing section, a missing bullet, a version-tag rule naming only one file's tag. If you're ever tempted to add real content to `CLAUDE.md` beyond a pointer, that's the regression to watch for
- **No credentials**: no secrets, private URLs, or internal endpoints anywhere in this repo: ever
- **No personal identifying details**: no local usernames, real names of individual contributors, machine-specific absolute paths, or personal account handles (e.g. a personal fork under your own GitHub username) anywhere in this repo. It's read by people with no context for who you are or what machine you use, this session's history included: a personal GitHub username and a contributor's first name both made it into committed docs before being caught. Use generic placeholders instead: "the developer," "the repo's lead developer" (see "Name code, not people" in `session-discipline.md`), "a local clone," "your global context"
- **Additive, not prescriptive**: role and org files add or modify the base; they do not replace it
- **Lean project files**: downstream project `AGENTS.md` should be lean: project-specific content inline, universal conventions as pointers to this template. `CLAUDE.md` stays a minimal stub pointing at `AGENTS.md`; it exists only because Claude Code loads it automatically, not as a second place to hold content
- **Explicit audience**: don't rely on filename or folder structure alone to signal that a file is agent instructions rather than human documentation — a person unfamiliar with the convention won't necessarily infer it. `CLAUDE.md`/`AGENTS.md` (both root and template) say so explicitly in their opening lines; a file that's genuinely dual-audience (e.g. `docs/agent-security.md`) says that instead. Apply the same to any new agent-facing file whose purpose isn't obvious from context
- **Adopt agentics, not pieces of it**: write about adoption at the level of "adopted agentics" (fully or partially), not "adopted a convention from agentics." The latter frames agentics as a menu to pick items from rather than a system to bring in; whether a given convention ends up copied locally or left as a live pointer is an implementation detail underneath that, not the framing itself
- **Convention entries: rule and edge-case reasoning inline, incident narrative in `CHANGELOG.md` only**: a convention file entry should read as the rule, then just enough reasoning to let an agent judge a case the rule doesn't explicitly enumerate, the same "why lets you judge edge cases" principle behind this repo's own memory-entry format. It should not re-narrate the specific incident that produced it: which adopter, what they typed, what broke, exact quotes. That story already exists exactly once, in the corresponding `CHANGELOG.md` entry; a convention file re-telling it is a second copy that can drift from the first. Cross-reference by slug (`see CHANGELOG.md § <slug>`) instead of duplicating it. This keeps convention files terse for the audience that reads them every session or on demand, without losing the story anywhere. Caution: some reasoning currently embedded in a convention *is* the instruction, not decoration (e.g. `session-discipline.md`'s "Verifying conformance, not just structure" explains a non-obvious *why now*, not just *why*), don't sever those mechanically; judge each case

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
5. If you added a new `conventions/*.md` file, it needs to be reachable from two places, not just created: a dispatch line in `template/AGENTS.md`'s "When to read what" table (the single canonical dispatch list; `template/CLAUDE.md` points at it rather than keeping its own copy), and a row in `template/README.md`'s file table. A file that's real and useful but missing from either is invisible to whoever needed it: this happened more than once (`security.md`'s pnpm guidance, `documentation.md`, `upgrading-adoption.md`) before it was caught
6. See § Versioning below for the `bump` field and the CHANGELOG-as-source-of-truth rule; never bump the version tags yourself outside of an actual release
7. Mark `breaking: yes` in the CHANGELOG if downstream copies need a manual update

## Versioning

Semver, with major reserved: agentics stays at `0.y.z` until productization is explicitly authorized; major only moves once that's decided.

**`CHANGELOG.md` is the only place a version number lives.** Under `## Released`, each dated entry (`### 0.2.0 - 2026-07-15`) is a past version; the first one is the current one. Nothing else stamps a copy of this number: `AGENTS.md`'s own tag is a pointer (`<!-- agentics-version: see CHANGELOG.md § Released (latest entry) -->`), not a value, and `CLAUDE.md` carries no tag at all, since it's already a stub pointing at `AGENTS.md` for everything. `template/AGENTS.md` carries the same kind of pointer while it sits inside this repo (`agentics-template-version: see CHANGELOG.md § Released (latest entry)`); it only becomes an actual stamped number at the moment a project adopts it, since a copied file can no longer dynamically reference this repo's `CHANGELOG.md` once it's living somewhere else. See `template/README.md` § How to adopt for that step, and `template/conventions/convention-levels.md` § Checking for upstream updates for how an adopter's stamped tag gets compared against this file afterward.

**Every CHANGELOG entry carries a `bump` field**: `date | category | bump | breaking? | description`.
- `bump: patch`: fixes, clarifies, backfills, or propagates something already intended elsewhere in agentics. Nothing new is introduced.
- `bump: minor`: introduces a rule, file, procedure, or section that didn't exist in any form before.
- If a change feels major-sized (a true incompatible restructuring, not just "adopters need to re-sync"), flag it explicitly when logging it rather than silently tagging it `minor` and let the developer decide how it's recorded.

`breaking: yes/no` stays a separate, orthogonal signal (does an adopter need to take action), not the semver driver. This field applies going forward only; existing entries aren't retroactively tagged.

**Bootstrap note (resolved):** when this field was introduced, `## Unreleased` held 79 entries accumulated since scaffolding with no `bump` value. These were classified in one pass immediately afterward (same session, while the reasoning for each was still available) rather than left unresolved, and released as `0.2.0`. This was a one-time cost: every entry from here on gets its `bump` assigned at logging time, same discipline as `breaking` already gets, so there's no batch-classification project waiting at the next release.

**Rollup**: the next version, when you actually want to know it, is `## Released`'s current top entry bumped by the *highest* `bump` level found across everything currently under `## Unreleased changes`. Multiple `minor` entries since the last release still only bump minor once, not once per entry. This is computed on demand, not maintained as a running value anywhere: `CHANGELOG.md` already holds everything needed to derive it, so there's nothing to keep in sync by carrying a second copy of the answer.

**Release is a manual action**: move the `## Unreleased changes` entries under a new dated `### X.Y.Z - <date>` heading inside `## Released`. Nothing else needs touching: `AGENTS.md`'s pointer already resolves to whatever's now on top.

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

2. Add the role name to the initialization question in `template/AGENTS.md`'s initialization block, step 2 (the only copy; `template/CLAUDE.md` is a stub pointing at it)

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
