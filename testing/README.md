# Testing agentics

Agentics has no compiler or test runner: it's prose, read and applied by an agent, not executed by software. These four practices are the adapted equivalent. This directory is for contributors developing agentics itself; none of it is part of the distributable template, and none of it gets copied into an adopting project, that would be the exact mistake `regression-checklist.md` § `global-guideline-material-never-in-project` describes.

Software-based options (an actual eval harness running an agent against fixtures automatically, rather than a contributor doing it by hand) are a real possibility, tracked as a research item in `.dev/roadmap.md`, not built yet. These four practices don't depend on that landing.

## When to use which

- **Changed a single convention's wording, nothing about behavior implied to change**: a normal read-through is enough; none of the below is required.
- **Changed the dispatch table, or a procedure whose output gets copied verbatim elsewhere** (`upgrading-adoption.md`, the initialization block): dry-run against a fixture first. See `fixtures.md`.
- **Touched a section already implicated in a past incident, or its neighbor**: check `regression-checklist.md` for the matching scenario and re-verify it still holds.
- **Wrote something you're not fully sure a fresh reader would apply the way you intend**: run a cold-read review. See `cold-read-review.md`.
- **About to commit or publish**: run `scripts/check-consistency.sh`. See `consistency-checks.md`.

None of these are mutually exclusive; a dispatch-table change usually wants a fixture dry run, a regression check against the incident it's fixing, and the consistency script before it ships.
