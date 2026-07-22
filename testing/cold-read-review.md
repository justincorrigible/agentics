# Cold-read review

The ambiguity behind `regression-checklist.md` § `global-guideline-material-never-in-project` was invisible to the agent who wrote the dispatch table, and immediately obvious to a different agent reading it cold in a different repo. That's the general pattern this practice makes deliberate instead of accidental: the author of a convention has context (the design conversation, the intent) a first-time reader never gets, and that gap is exactly where ambiguity hides.

## When to use it

Before shipping a nontrivial convention or procedure change you're not fully confident reads unambiguously to someone without the conversation that produced it, particularly anything that will be copied verbatim into another project's files.

## How to run one

1. Spawn a subagent (or open a genuinely fresh context) with **no memory of the design discussion**, only the changed file(s) as they'd exist to a real reader.
2. Give it a concrete, realistic task, not "review this file" but the actual thing an adopting agent would be doing: "you're adopting agentics into this project for the first time, walk through what you'd do," or "run the upgrade procedure against this project's current files."
3. Watch what it actually does, not what it says it would do. `AGENTS.md`'s dispatch table read fine on a plain review pass; it only produced the wrong local copies when an agent actually acted on it.
4. Any action it takes that surprises you is the ambiguity. Fix the wording, not the subagent's interpretation, it read it reasonably; the words allowed the wrong reading.
