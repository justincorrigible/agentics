# Definition of done

A completion checklist, not a new set of rules: each item below already has its own convention elsewhere, this file is the single gate that ties them together, so a change doesn't get called done while one of them quietly lagged behind unnoticed. Universal, applies to any agentics adopter, not a narrower level than the template itself.

Invoked by being asked ("is this done?", "does this look okay," or any phrasing `AGENTS.md`'s "Default review or audit posture" already recognizes), and, per `AGENTS.md`'s own dispatch table, by finishing a task: presenting work as complete or as covering what was asked is itself the trigger, not something that waits for the user to ask. Confirmed as a real gap, not hypothetical: a session presented a design-doc edit as complete, covering the open questions it was asked to resolve, with the checklist never firing, since nothing recognized that self-framing as an invocation.

## Universal checklist

Every item below has to actually be checked, not assumed clean because it was probably fine:

1. **Tests**, per `testing.md`
2. **In-code documentation**, comments and TSDoc where the WHY is non-obvious, per `code-style.md`
3. **External docs**, `/docs` or equivalent, if the project has them, per `documentation.md`'s two-tier model
4. **`.dev/` upkeep**: roadmap and tech-debt entries reflect current reality, per `session-discipline.md`'s "Keeping `.dev/` current"
5. **Lessons learned persisted where they belong**: see below, defined here rather than pointed elsewhere, since it's new
6. **`CHANGELOG.md`'s `## Unreleased` discipline**, if the project keeps one
7. **A final refinement pass** over both the docs and the changes themselves, per `session-discipline.md`'s "Refinement passes: not just once at the end." This is the last gate, not a separate check bolted on afterward: it's what actually catches whether 1 through 6 were done well, not just done
8. **Reproducibility**: nothing required to make this work exists only on this machine, invisibly. If reaching "it works" needed an environment-specific accommodation, a symlink, an installed package, a local config value, it's not done until that's either generalized into the fix itself (detect the runtime, read a config value, see `code-style.md`'s "Platform portability") or captured somewhere a teammate could reproduce it (a setup script, a README line, a Makefile target). Cross-platform divergence is a common instance of this, not a separate case: a fix that only works because the machine it was written on happens to differ from a teammate's (a different OS's default paths, for one concrete example) is the same gap as any other undocumented local accommodation

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

**What doesn't clear the bar isn't discarded, it stays ordinary project memory, promoted later if it accumulates into something actionable.** Nothing changes about how those facts get recorded day to day, project memory's own rules already cover that. The one addition: at the same "Refinement passes" checkpoints enforcing the live check below, also ask whether several already-recorded memory entries, none individually clearing the bar, now describe the same recurring decision or constraint together. A preference noted three separate times, a workaround mentioned in passing across several sessions, a pattern several small entries independently gesture at, clears the bar in aggregate even though no single entry did. Promote it the same way a live-cleared lesson would be (a pointer plus substance in `.dev/docs`, per "Where it goes" below), and trim or consolidate the memory entries that fed it, rather than leaving redundant, near-duplicate notes sitting alongside the new writeup.

**Where it goes: pointer vs. substance, not a competing choice.** Project memory stays a short pointer or fact, matching the existing "prefer pointers over embedded content" rule. If the real explanation runs longer than a few sentences (an algorithm, a full pattern write-up, a terminology mapping), that substance belongs in `.dev/docs`, with memory, if it needs an entry at all, just pointing at it. A fact with no real substance behind it (a preference, a one-line project detail) just stays in memory, no doc file needed. If the lesson is clearly specific to one already-established service folder, write it there; otherwise, default to `.dev/docs/atlas/<topic>.md` (see `documentation.md` § The atlas) and update `.dev/docs/atlas/index.md` in the same pass, don't leave it for whoever notices it's missing later.

**Where it goes: which project.** Usually this one. If the current project has an already-known relationship to a dependent one (your global context's cross-project map, e.g. `~/.claude/projects.md`'s "Cross-project" field for Claude; no new relationship-tracking needed), and the lesson has a visible side effect there, write to that project too, not just this one.

**The test is whose problem this is, not which project's context you happened to read.** Consulting another project to inform the current one's work is normal, not a signal to write findings back into that other project, or the reverse: a finding that's really about that other project's own concern (its bug, its integration issue, its environment) belongs in *its* devctx, not the current project's, even though the current project is what's open and writable right now. Write it here only if this project's own developers are the ones who'd act on it, or its own dev, test, or operational experience is what's actually affected. If the other project hasn't adopted agentics, has no established devctx to write into, or the specific layer this fact would naturally go in doesn't exist there yet (devctx present but no project memory, for instance, a real, observed gap, not a hypothetical one), don't invent one silently or fall back to whatever layer happens to be available instead: surface it to the developer directly (see "Surface ideas... unprompted" in Interaction parameters) and let them decide whether to bootstrap the missing layer or handle it another way, the same way reaching into a different repo to write, uninvited, is already out of bounds elsewhere in this repo's own conventions.

**Enforcement:** this is checked live, but "Refinement passes" is the backstop, not a duplicate mechanism: each of its three checkpoints also asks whether anything recognized as a lesson since the last pass has actually been persisted yet, and whether several smaller, already-recorded memory entries now accumulate into something worth promoting, catching both what the live check missed in the moment and what no single entry alone would have triggered.
