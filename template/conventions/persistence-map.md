# Persistence map: where a new fact, finding, or piece of content actually goes

A quick-reference index across every persistence layer agentics currently defines, project memory, global memory, `.dev/roadmap.md`, `.dev/tech-debt.md`, `.dev/docs/<service>/`, `.dev/docs/atlas/`, and atlas drafts. Each step below states the test and points at the file that actually defines it in full: this map orders and connects those rules, it doesn't redefine any of them. First written as a live, usable draft (2026-08-08): treat it as a working v1, expect it to need revision once more real cases test it, the same "prove it before templating it" caution this repo applies to any new mechanism.

## The order of questions

1. **Is this genuinely about the developer, true across every project they work in, or about a specific project's own nature?**
   See `AGENTS.md` § Memory and contribution hygiene. Default to project-scoped. Promote to global memory only when it clearly applies everywhere, not by default when uncertain which one fits.

2. **If project-specific: which project?**
   See `definition-of-done.md` § "Where it goes: which project." The test is whose problem this is, not which project's context informed it. If the target project has no devctx, or the specific layer this fact needs doesn't exist there yet (devctx present but no project memory, for instance), surface it to the developer rather than inventing the missing piece or writing it into a worse-fitting layer.

3. **Is this settled, or still being actively verified, a live investigation still in progress?**
   See `documentation.md` § The atlas. Not yet settled: stage it as a draft in project memory space (`<project-memory-dir>/drafts/*.md`), never indexed in `MEMORY.md`. Promote it, verified and appropriately genericized, once the investigation actually settles.

4. **Once settled: is this a short fact, or does it need real substance?**
   See `definition-of-done.md` § "Where it goes: pointer vs. substance." A preference or one-line project detail stays a short pointer in project memory. Anything that needs more than a few sentences (an algorithm, a pattern write-up, a terminology mapping) needs an actual document, not a longer memory entry.

5. **If it needs substance, what kind?**
   - An open work item, feature, or design question: `.dev/roadmap.md`. Terse status only, with depth relocated to `.dev/docs/atlas/roadmap/<topic>.md`, if this project has `roadmap_split: yes` recorded (see `session-discipline.md` § Keeping `.dev/` current); otherwise the roadmap entry itself carries the depth, as normal.
   - A known issue, bug, or deferred problem: `.dev/tech-debt.md` (see `entry-formats.md` § Tech-debt entry format).
   - Reference material clearly specific to an already-established, human-curated service folder: write there, matching its own existing organization; no atlas index or cross-linking requirement applies to that pre-existing content.
   - Anything else durable and agent-generated with no obvious existing home: `.dev/docs/atlas/<topic>.md` (see `documentation.md` § The atlas), updating `.dev/docs/atlas/index.md` in the same pass.

## What this map does not decide

- **Whether to persist anything at all.** Each step's own bar still applies; in particular, `definition-of-done.md`'s lessons-learned criterion ("would a different session need this") gates whether something gets written down in the first place, this map only orders where it goes once that bar is cleared.
- **What to do with content someone else already wrote in any of these layers.** See `session-discipline.md` § "Unattributed working-tree changes": validate it, don't dismiss it, regardless of which layer it showed up in.
