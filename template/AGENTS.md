<!-- agentics-template-version: 0.1.0 -->
# Agent collaboration conventions

**For AI agents:** this file is instructions your agent reads and follows; it is not documentation written for people. If you're a person looking for how this project works, see this project's own README or development guide instead.

Adapted from [softeng/agentics](https://github.com/oicr-softeng/agentics). This is the comprehensive reference for agents that do not load files on demand. If you are Claude, prefer `CLAUDE.md`: it dispatches to more detailed convention files.

## Interaction parameters
- Ask clarifying questions before making large assumptions about intent
- Surface better alternatives as options; let the user decide
- Push back on bad ideas and identify blind spots before they are baked into code
- Flag scope-adjacent issues verbally, then document them in `.dev/tech-debt.md`

## Critical constraints
- No credentials, secrets, or private URLs in any file: ever
- Library/module code must not read from the environment; configuration belongs at the application boundary, passed in as typed parameters
- Do not modify `CLAUDE.md`, `AGENTS.md`, or other instruction files without explicit instruction from the developer: surface suggestions, do not self-edit
- No machine- or user-specific absolute paths, usernames, or individuals' real names in committed files. If your agent's global context adds a reference to a local resource keyed by machine or clone location (e.g. a per-project memory path), use a generic placeholder, not the resolved path: it will not exist for another developer, another machine, or after the repo moves

## Session-start signals

A session is a work period: not necessarily a new chat thread. Treat greetings ("good morning", "hi again"), resumption phrases ("let's continue", "back to it", "where were we"), and on-demand requests ("sync up", "refresh context", "re-read your instructions") as session-start signals even mid-thread.

## Starting a session

On a session-start signal, before touching any code:
1. If a cross-project map exists in your agent's global context (for Claude: `~/.claude/projects.md`), read it. If it does not exist and the user works across multiple projects, offer to create one using `global-context/projects.md` as a template.
2. Check whether instruction files changed since your last session file: `git log --oneline -1 -- CLAUDE.md AGENTS.md`. Re-read only changed files. When you do, say: "I've re-read [file]: the prior version in this thread is superseded."
3. Read `.dev/roadmap.md`: check current focus and any `[in progress]` items
4. Read `.dev/tech-debt.md`: note `standalone: yes` entries relevant to today's work
5. Read the most recent 1-2 files in `.dev/sessions/` (sort filenames; ISO timestamps sort chronologically) for context on recent work and open threads
6. If `propagation_suggestions: yes` is set, or you're an agentics contributor (`agentics_contributor: yes` in your global context) without `agentics_upstream_check: no` set for this project or globally, check whether this project has adopted agentics at all (a tag, or just a mention of agentics in `AGENTS.md`/`CLAUDE.md`) and, if so, check for upstream updates: see `conventions/convention-levels.md` § Checking for upstream updates. A missing or incomplete tag means this project needs the tag added, not that the check should be skipped. For contributors this is mandatory and recurs every session for an unresolved gap, not just once
7. softeng team member → read `CLAUDE.softeng.md`

**On context efficiency:** re-reading mid-thread adds content: it does not replace the prior version. Both consume tokens. Only re-read files that actually changed (step 2). If many instruction files changed at once, a new thread is cheaper than accumulating both versions.

## Keeping `.dev/` current

Update `.dev/roadmap.md` or `.dev/tech-debt.md` within the same session whenever a roadmap item's status changes, a tech-debt entry is resolved, or a meaningful decision is made.

Before writing any of these updates: marking an item done, closing a tech-debt entry, changing a status: verify against the actual current code or file state, not against a prior description or session summary. An assumption carried forward unverified is exactly how these documents drift from what they claim.

After any meaningful unit of work: code written, bug fixed, tech-debt logged, roadmap updated, docs changed: add or extend the dated entry in your session file. Do not wait for a "session over" signal; work rarely ends cleanly. Do not log conversational activity (discussions, PR reviews with no local changes, waiting states).

When `.dev/` documents are updated, remind the developer to commit them: this history matters for avoiding double work across sessions.

## Verifying conformance, not just structure

Reading a convention and holding it as an active constraint while generating content several steps later in the same turn are not the same act. A convention's example shows shape; matching that shape can happen while missing a prose requirement stated right next to it — observed directly, not hypothetical: a tech-debt entry matched the field skeleton exactly while skipping the "state the fix, not just a pointer" rule written two sentences above it, in the same session that had just read it.

This matters most producing several governed artifacts in one batch (initialization, a migration, a multi-file update). Before finalizing each one, re-read it once against the convention's specific prose requirement, as a discrete final step, not a background assumption carried from reading the rule earlier. If a convention's own example under-specifies a requirement stated nearby, that's a defect worth fixing, not something to route around silently.

## Session file identity

Each session's log lives in its own file under `.dev/sessions/`, named `YYYY-MM-DDTHHMMSS.md`, keyed by contributor and day rather than one shared file: this is what prevents merge conflicts when several people work the same project the same day. No descriptive slug in the filename: the timestamp's only job is uniqueness.

A session-start signal doesn't by itself mean create a file: it means run the check below. A different contributor always needs their own file; the same contributor picking work back up later the same day extends their existing file instead.

To find your file for today: list `.dev/sessions/` for today's date prefix, then check authorship of any match (`git log -1 --format=%ae -- <file>` vs `git config user.email`; an uncommitted match is yours by definition). If a match is yours, extend it, no new file or timestamp. Otherwise create a new file (see "Get the actual time" below for the timestamp). This gives at most one file per (day, contributor), not one per session. Two concurrent sessions by the same person can still race on the same file: that's a self-conflict for that person to resolve, not the cross-contributor case this targets.

**Get the actual time, don't pad with zeros.** Once the check above says a new file is actually needed: you have no innate sense of the current time of day. Your context may hand you today's date, but wall-clock time isn't something you can infer, and defaulting the unknown part to `000000` is a guess dressed up as a value, not a real timestamp. Run a shell command to get it (e.g. `date +%Y-%m-%dT%H%M%S`) before creating the file. If every file created going forward carries `T000000`, that's not several coincidentally-round timestamps, it's this step being skipped every time.

**Exception: migrating or backfilling historical entries.** Splitting an existing shared log into per-day files, or reconstructing entries for work that already happened, is different from creating a file for a session happening now: the real time genuinely isn't recoverable after the fact, and `T000000` is a legitimate placeholder there, not a bug. Don't rename a legacy file's zeroed timestamp once real times become available for new files: it wasn't wrong for what it was created to do.

**Never rename an already-created file, today's own included.** This isn't limited to old migration files: a file created earlier today under the old, unfixed behavior is in the same position once created. Renaming it now to the present moment doesn't recover its actual creation time; it substitutes a different guess ("current time, best approximation") for the original one, the same anti-pattern this fix exists to stop. Fetch the real time before creating a file, never after.

## Tech-debt entry format

```
[short description of the issue]
fix: [what the fix actually is, in one sentence, even if the full detail lives elsewhere: a roadmap item, a design doc, a linked issue. Pointing elsewhere for depth is fine; a pointer with no inline substance is not]
standalone: yes | no
context: [roadmap item reference or brief note: required when standalone: no]
```

`standalone: yes`: can be picked up freely.

Separate the issue from the fix, even in this minimal form: a description with no recommended direction means whoever picks it up next re-derives the same analysis. The `fix:` field exists so this isn't optional-by-omission. Redirecting to where the full fix is tracked is valid, especially for something already scoped as its own roadmap item; what's not valid is a bare reference with nothing about the fix itself said here. At scale (dozens of entries across a large codebase), consider a richer per-entry structure instead — File / Severity / Kind / Issue / Fix / Standalone — for triage and scanability. This is a genuine tradeoff, not a strict upgrade: it costs more friction to log each entry, which loses more than it gains for a short list. Pick based on the actual list's size.
`standalone: no`: blocked on or coupled to roadmap work; read the context note before touching it.

## Testing

Co-locate test files with the source file they test: `validation.test.ts` next to `validation.ts`, not in a sibling `__tests__/` directory.

For non-trivial work: plan first → define behaviour as tests → implement. Tests are the specification.

BDD style using `node:test` and `assert`: no additional libraries:

```ts
import { suite, test } from 'node:test';
import assert from 'node:assert/strict';

suite('getNetworkPassthroughHeaders', () => {
  test('returns an empty array when no headers are configured', () => {
    assert.deepEqual(getNetworkPassthroughHeaders({ passthroughHeaders: [] }), []);
  });
});
```

`suite()` groups related tests; `test()` states expected behaviour in plain language; body: setup → action → assertion (Given / When / Then).

## Code style

**Comments:** write none by default. Add one only when the WHY is non-obvious: a hidden constraint, subtle invariant, workaround for a specific bug. Never explain WHAT the code does; never reference the current task or callers.

**Scope:** stick to stated scope. Surface weaknesses verbally. If a scope-adjacent issue is small enough to fix in place without meaningful risk, fix it immediately: tech-debt is for genuinely deferred work, not one-line fixes. Log issues that are too large or risky to address now in `.dev/tech-debt.md`. Three similar lines is better than a premature abstraction.

**Search before writing:** before implementing something new, search the codebase for existing patterns: use grep or semantic search before writing from scratch.

**Library awareness:** when a well-established library would do more thorough work than a hand-rolled solution, surface it as an option with a brief explanation. Let the developer decide.

**Checking in:** check in before non-trivial direction changes; not on mechanical steps.

**Property ordering:** Alphabetize properties in config objects and YAML/JSON files at all nesting levels: prevents silent duplicate key overwrites and keeps additions consistent.

**Language:** flag typos and language issues when spotted: in code, comments, and docs. Don't fix silently. Use your team's preferred spelling convention consistently (example: Canadian English uses -our, -re, -ize, -yze).

## Code review

Before examining how a PR is written, establish whether the proposed change is the right response to the problem. Work through these in order - raise it and stop if any answer is "no" or "unclear":

1. **What problem does this solve?** If the PR description doesn't state it, ask before reviewing anything else.
2. **Does the solution belong at this layer?** Could the problem be solved in the caller, the consumer, or the component on the other side of this boundary without any change here? If yes, say so.
3. **Is any code change needed at all?** Documentation, a usage example, or a configuration option sometimes replaces a feature.
4. **Only then:** review the implementation against `conventions/code-style.md`.

A comment that redirects work to the right layer is often the most useful review a PR can receive.

## Documentation

Two layers, for projects that publish docs externally: `/docs` for what a consumer needs to install, configure, and use the project (published externally); `.dev/docs` for internal design rationale and implementation guides (repo-only, not published). Keep the full explanation in one location and cross-link from the other: duplication drifts. Links from `/docs` to `.dev/docs` must use the full GitHub URL, not a relative path (the published docs site has no access to `.dev/`); the reverse direction can use relative paths.

**Writing for a cold reader:** documentation written during or right after a live design discussion inherits that discussion's dense, backward-referencing register, which works for whoever was in the room and against anyone reading cold, the actual audience for most documentation. One idea per sentence. State the conclusion first. Never reference "the earlier version" or "as discussed" without restating what it said. Give worked examples their own block. Minimize forced cross-reference chains. Applies to design docs, tech-debt entries, roadmap items; does not apply to `.dev/sessions/` logs, which are correctly terse for an already-oriented reader. See `conventions/documentation.md` for the full rules and a worked before/after example.

## Structured logging

Emit logs as structured key-value pairs or JSON objects, not interpolated strings. Include a consistent set of fields: timestamp, severity, event type, actor identity where known, resource identifier, outcome. Do not log secrets, credentials, or PII in log values.

Apply from the start of any feature involving authentication or access control decisions, permission changes or administrative actions, data access or exports, or errors at system boundaries.

Set up structured logging before writing application logic: it is not optional plumbing.

## Security

Be aware of the current OWASP Top 10 (verify the current edition at https://owasp.org/www-project-top-ten/). Apply during implementation, flag when reviewing adjacent code, surface when making design decisions touching authentication, access control, input handling, session management, or dependency management.

For security-relevant work, read `conventions/security.md` (credentials/secrets policy, Node.js/pnpm supply-chain hardening, the quick threat model below) and `conventions/security-guidelines.md` (full OWASP patterns and code review triggers). Your agent may also have a global copy of the guidelines in its personal context directory (for Claude: `~/.claude/security-guidelines.md`).

**pnpm supply chain (A08):** pnpm v10+ blocks package install scripts by default; keep it that way. Set `scarf-js-opt-out=true` in `.npmrc`. Only add entries to `pnpm-workspace.yaml`'s `allowBuilds` for packages you've actually reviewed; never allow `@scarf/scarf`. See `conventions/security.md` for the full Dockerfile and config guidance.

**Quick threat model (A06):** before building anything with security implications, answer: what are we building? what could go wrong? what are we doing about it? Record in `.dev/sessions/`.

## Convention placement and propagation

Conventions live at one of three levels: always ask which level is correct:

- **Project-specific**: applies to this project only; goes in the project's `CLAUDE.md` or `.dev/tech-debt.md`
- **Global**: applies to all the developer's projects; belongs in your agent's global context directory (for Claude: `~/.claude/CLAUDE.md`)
- **Shareable**: could benefit other teams; flag as a potential PR to the agentics repo

When adding or improving a convention anywhere, ask: is this at the right level? If a convention just improved in one project, ask whether sibling projects carry the same convention and would benefit: moving it to global covers all of them at once. Check your cross-project map for the list of related projects. Surface these questions explicitly.

## Upgrading agentics adoption

If a developer asks to upgrade this project's agentics integration, or the session-start check above finds a missing/stale tag: read `conventions/upgrading-adoption.md` and follow it. It covers confirming this project is actually meant to track agentics (including the case where it shares the conventions with no textual link back to agentics at all), diagnosing what's stale against the current template, and applying fixes with per-change consent. Don't patch just the tag in isolation: session-file migration and `AGENTS.md` completeness usually need the same pass.

## Deploying or debugging a service

Read `.dev/docs/<service>/` if it exists before deploying or debugging a specific service: service-specific deployment notes and operational guides, one subdirectory per service (e.g. `.dev/docs/postgres/`, `.dev/docs/kafka/`), indexed at `.dev/docs/index.md`.

## Memory hygiene

When writing to project memory: keep entries concise; store no content derivable from code or files. If an insight could apply to all your projects, offer to promote it to your agent's global context. If a convention could benefit other teams, flag it as a potential PR to the agentics repo.

## Initialization

If no project memory exists for you in this project yet:
1. Check whether a cross-project map is accessible (see Starting a session, step 1).
2. Ask: "What best describes your primary work on this project?": developer / bioinformatician / AI engineering / general (or describe it). Read the matching file in `CLAUDE.roles/`.
3. Ask: "Are you part of the softeng team?": if yes, apply conventions from `CLAUDE.softeng.md` on top of your role conventions.
4. Ask: "Do you already have agent conventions for this project?": if yes, treat these conventions as supplementary; defer to your existing setup on conflicts.
5. Ask: "Would you like me to suggest when conventions could be useful beyond this project?": record as `propagation_suggestions: yes | no`.
Record all answers in project memory. Do not ask again.
