# Upgrading a project's agentics adoption

A deliberate, on-demand procedure for bringing a project's agentics integration current. Two ways in:

- **A developer asks directly:** "upgrade this project's agentics integration" (or similar). Run this procedure now.
- **The automatic session-start check finds something stale or missing** (see `convention-levels.md` § Checking for upstream updates) and offers to run it, with the developer's go-ahead.

Nothing in this procedure auto-commits. Prepare the diff, let the developer review it, they commit and push themselves.

## 0. Confirm this project is actually meant to track agentics

Detection, in order:
1. `AGENTS.md` or `CLAUDE.md` carries an `agentics-template-version` tag, in any form.
2. Failing that, either file mentions "agentics" at all (a bare `grep -qi agentics AGENTS.md CLAUDE.md`), e.g. the "Adapted from softeng/agentics" line the template ships with.
3. Neither is present. Don't assume either way: ask the developer directly. Some projects converge on the same conventions independently without ever referencing agentics (this has happened — a project written well after agentics existed reimplemented an almost identical session-start checklist from scratch, with zero textual link to trace it back). If the developer confirms this project should be tracked, ask where that fact should live:
   - **In this project's own files:** add a tag or a short mention to `CLAUDE.md`/`AGENTS.md`, same as a formal adoption. Straightforward, but it's one more file the developer has to remember exists.
   - **In the developer's `~/.claude/projects.md`** (or equivalent global registry), as an explicit "track this project against agentics" marker, without touching the project's own files at all. Lower friction if the developer manages many such projects, since it's one registry instead of N repos to remember.
   
   Don't default to one silently: this determines what step 1 below checks against, and it's the kind of thing that's ugly to walk back if guessed wrong.

## 1. Diagnose gaps against the current template

Locate the current agentics template: prefer a local clone (`Repo URL`/`Path` lookup in the developer's global context) over fetching GitHub, since local is more likely current. Check each of the following, current vs. desired, and report the diagnosis **before changing anything** — a short list of what's stale, so the developer isn't surprised by the size of the change:

- **Version tag:** present? Has a `synced:` value? If both are present, run the diff in `convention-levels.md` § Checking for upstream updates instead of this step. If absent (no tag, or a tag with no `synced`), there's no baseline to diff from, so don't attempt one. Instead, read agentics' `CHANGELOG.md` and surface everything currently under `## Unreleased` as a bounded, one-time catch-up — this is deliberately not a full historical walk back to this project's original adoption date (mostly agentics' own internal iteration, not necessarily relevant here), but it's also not nothing: silently baselining to `HEAD` without showing anything would swallow whatever's genuinely pending right now. Lead with any `breaking: yes` entries, same per-entry consent as the normal flow. Once reviewed, set `synced` to agentics' current `HEAD`.
- **Does `CLAUDE.md` itself have a complete, self-contained "Starting a session" (or equivalent) checklist that predates agentics?** If so, check whether its own dispatch-to-global line (often under a "Workflow" heading) names specific topics deferred to global context. If "session discipline" isn't on that list, the project's session behavior isn't deferring to agentics at all, however well the global context is set up elsewhere — a well-tuned global dispatch cannot override a project's own explicit, narrower instructions, and shouldn't try to. This is the most likely reason an automatic upstream-update check never fires on an old project: not a bug in the check, a genuinely un-migrated file. This case needs the same treatment as thin/absent `AGENTS.md` content below, applied to `CLAUDE.md` too.
- **Session files:** `.dev/sessions.md` (single shared file) vs `.dev/sessions/` (one file per contributor per day)? The old model needs the migration in step 2.
- **AGENTS.md completeness:** does it inline the current session-discipline checklist (session-start signals, the `.dev/` sequence, session file identity, the upstream-update check), or does it only point at agentics or at the developer's global context? `AGENTS.md` exists specifically to be self-sufficient for agents without a global context (see `CONTRIBUTING.md`'s design principles) — a thin pointer here silently fails for any contributor who doesn't share whoever-wrote-it's personal setup. This isn't hypothetical either: it's exactly why an update can look "done" to one contributor and be invisible to a teammate reading the same repo. Prefer inlining current content over pointing at it.
- **Agent-neutrality:** does anything copied in reference `~/.claude/...` or "Claude Code" unconditionally, with no `(for Claude: X; for other agents: Y)` framing? Run the same `grep -rn '~/\.claude\|Claude Code'` check `CONTRIBUTING.md` uses on the template itself.
- **Do `CLAUDE.md` and `AGENTS.md` actually agree with each other?** They're meant to cover the same ground, but drift independently since each gets edited on its own schedule — a project can end up with, say, a six-step "Starting a session" checklist in one and a four-step version in the other. Diff the two files' checklists directly rather than only comparing each one to the template; a project can look "upgraded" from one file's perspective and be behind from the other's.
- **Other agent-specific instruction files:** does this project also have a `.github/copilot-instructions.md`, a Cursor rules file, or similar? If the project's own documentation says to keep them in sync with `CLAUDE.md`/`AGENTS.md` (check `DEVELOPMENT.md` or an equivalent contributor guide), give it the same treatment — at minimum the session-file mechanics, since those are agent-neutral and apply regardless of which file a given tool actually reads.

## 2. Apply, with consent per change

- **Migrating `.dev/sessions.md`:** split by date. For multi-contributor history, split by date only — don't try to retroactively attribute old entries to individuals; past conflicts are already resolved. The `(day, contributor)` filename scheme (`YYYY-MM-DDTHHMMSS.md`, no slug) only needs to apply going forward. See `session-discipline.md` § Session file identity for the exact rules.
- **Adding or repairing the tag:** `<!-- agentics-template-version: X.Y.Z | synced: <HEAD sha> -->`, using agentics' current version and commit.
- **Inlining `CLAUDE.md`/`AGENTS.md` content:** whichever file(s) diagnosis flagged as thin or non-deferring, copy the current text from the relevant `conventions/*.md` files verbatim, don't paraphrase — paraphrasing during a copy is exactly how the two versions start drifting apart again. Keep both files' checklists identical in substance once done, per the § 1 cross-file check.
- Every change here is a change to an instruction file (or the equivalent for session logs): same consent standard as any other edit to `CLAUDE.md`/`AGENTS.md`. No bulk apply-everything-then-ask.

## 3. Record it

Log the upgrade in this project's own session file (create `.dev/sessions/` now if this run is what introduces it) and remind the developer to commit and push, so other contributors pick up the change on their next pull — not automatically, and not until then.
