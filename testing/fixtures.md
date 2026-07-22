# Fixture dry runs

A fixture is a small, disposable, synthetic project. Never a real one: dry-running a change against a real adopter is exactly how `regression-checklist.md` § `global-guideline-material-never-in-project` happened. A fixture removes that risk entirely: create it in a scratch directory, dry-run against it, delete it.

## The four shapes

Cover these; a change to the dispatch table or upgrade mechanism should be dry-run against whichever shape its diagnosis branch actually touches, not all four reflexively.

**1. No adoption at all.** An empty project: no `AGENTS.md`, no `CLAUDE.md`, no mention of agentics anywhere. Exercises `upgrading-adoption.md` § 0's detection step; the correct outcome is "not detectably an agentics project," not a silent skip and not a false positive.

**2. Pre-dispatch-table (old comprehensive style).** An `AGENTS.md` that inlines full convention content instead of dispatching, the shape agentics itself used before `agents-md-single-dispatch-table`:

```markdown
<!-- agentics-template-version: 0.1.0 -->
# Agent collaboration conventions

## Testing
Co-locate test files with source. BDD style using node:test.

## Code style
Write no comments by default...
```

Exercises the "AGENTS.md completeness" and "does CLAUDE.md/AGENTS.md agree" diagnosis items; the correct outcome is collapsing to the current dispatch table, verbatim, with any real project-specific content (a "Project notes" section, an extension-point note) preserved, not dropped.

**3. Tag present, no `synced` value.** An `AGENTS.md` with `<!-- agentics-template-version: 0.3.0 -->` and nothing else. Exercises the bounded first-encounter catch-up branch in `convention-levels.md` § Checking for upstream updates; the correct outcome is surfacing current `## Unreleased` entries once, then baselining `synced` to `HEAD`, not a full historical walk back to 0.1.0.

**4. Steady state, mature adopter.** A current dispatch-table `AGENTS.md` with `<!-- agentics-template-version: X.Y.Z | synced: <some older sha> -->`, a stub `CLAUDE.md`, and no `conventions/`, `CLAUDE.roles/`, or `CLAUDE.softeng.md` locally (representing a contributor whose global context already covers all of it). This is the exact shape that broke: the correct outcome of a dry run here is that none of those three ever get proposed, not even as a batched "non-conflicting" fix.

## Running one

1. Create a scratch directory (this session's scratchpad, or any throwaway path), write only the files the shape above specifies.
2. Treat that directory as the project root for this exercise: run `session-discipline.md`'s session-start checklist, or `upgrading-adoption.md`'s procedure, exactly as an adopting agent would, reading and writing paths relative to the scratch directory, not this repo.
3. Compare the actual outcome against the "correct outcome" stated for that shape.
4. Delete the scratch directory. Nothing here is meant to persist.

**Prefer a fresh-context agent for this, when the change is about wording, not just mechanics.** A dry run tests behavior; a wording ambiguity can still slip through if the same context that designed the change also runs it, since your own mental model of "what should happen" can silently paper over an instruction that would mislead someone else. For a purely mechanical logic change this matters less; for anything touching phrasing an adopting agent has to interpret, combine this with `cold-read-review.md` rather than treating them as separate concerns.
