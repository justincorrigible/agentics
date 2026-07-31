# Definition of done

A completion checklist, not a new set of rules: each item below already has its own convention elsewhere, this file is the single gate that ties them together, so a change doesn't get called done while one of them quietly lagged behind unnoticed. Universal, applies to any agentics adopter, not a narrower level than the template itself.

Invoked by "is this done?", "does this look okay," or any of the other phrasings `AGENTS.md`'s "Default review or audit posture" already recognizes as the same adversarial-search trigger, applied here at the completion checkpoint specifically, not a separate mechanism.

## Universal checklist

Every item below has to actually be checked, not assumed clean because it was probably fine:

1. **Tests**, per `testing.md`
2. **In-code documentation**, comments and TSDoc where the WHY is non-obvious, per `code-style.md`
3. **External docs**, `/docs` or equivalent, if the project has them, per `documentation.md`'s two-tier model
4. **`.dev/` upkeep**: roadmap and tech-debt entries reflect current reality, per `session-discipline.md`'s "Keeping `.dev/` current"
5. **Lessons learned persisted where they belong**: see below, defined here rather than pointed elsewhere, since it's new
6. **`CHANGELOG.md`'s `## Unreleased` discipline**, if the project keeps one
7. **A final refinement pass** over both the docs and the changes themselves, per `session-discipline.md`'s "Refinement passes: not just once at the end." This is the last gate, not a separate check bolted on afterward: it's what actually catches whether 1 through 6 were done well, not just done

## Project-specific annexes

A project's own recurring task types often touch more than the universal list covers: in Arranger's `search-server`, adding a new environment variable should also update `.env.schema` and the README's env var table, a project-specific pattern with no universal equivalent. Agentics can only template the *pattern* for a project to document its own annex (a short, project-owned checklist keyed to a recurring task type, living in that project's own files, never synced from agentics), not the checklists themselves, since what counts as a recurring task type, and what it touches, differs entirely per project.

**Not yet solved:** how an agent recognizes it's doing a checklisted task type in the first place, the same recognition problem session-start signals and sanity-check phrasing already solve differently for their own triggers. Until a project defines its own annex, this layer is simply empty; that's a correct starting state, not a gap to fill preemptively.

## Lessons learned: the durable-knowledge criterion

A feature isn't done until the lessons learned from working on it are persisted wherever they actually belong, not left sitting only in the conversation that produced them. This is a live, per-decision check, not a session-end sweep: at the moment a genuinely non-obvious decision, pattern, or constraint gets established, the same recognition already required for a session-log bullet or a tech-debt entry (see `session-discipline.md` § Session file entry format), ask whether it clears the bar below, and if it does, write it down immediately rather than waiting to be asked.

**The test:** would a different session, working on a different part of this same project (or a project this one visibly affects), need this to avoid re-deriving it the hard way, or to avoid contradicting a decision already made? Deliberately narrow: it excludes most of what a session actually accumulates, dead ends, exact commands tried, the reasoning chain itself, the same "collapse iteration to outcome" instinct `session-discipline.md` already applies to session-log prose, generalized here to knowledge as a whole, not just how a log entry reads.

What clears it:
- A decision with a non-obvious why (chose X over Y, rejected Z and why)
- A pattern or constraint not derivable from reading the code cold
- A fact about an external dependency nothing else documents

What doesn't:
- Anything reconstructable from the current code or tests: a doc restating that just duplicates and drifts
- The investigative path itself, once the answer is known

**Where it goes: pointer vs. substance, not a competing choice.** Project memory stays a short pointer or fact, matching the existing "prefer pointers over embedded content" rule. If the real explanation runs longer than a few sentences (an algorithm, a full pattern write-up, a terminology mapping), that substance belongs in `.dev/docs`, with memory, if it needs an entry at all, just pointing at it. A fact with no real substance behind it (a preference, a one-line project detail) just stays in memory, no doc file needed.

**Where it goes: which project.** Usually this one. If the current project has an already-known relationship to a dependent one (your global context's cross-project map, e.g. `~/.claude/projects.md`'s "Cross-project" field for Claude; no new relationship-tracking needed), and the lesson has a visible side effect there, write to that project too, not just this one.

**Enforcement:** this is checked live, but "Refinement passes" is the backstop, not a duplicate mechanism: each of its three checkpoints also asks whether anything recognized as a lesson since the last pass has actually been persisted yet, catching what the live check missed in the moment.
