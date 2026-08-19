# Persistence map: where a new fact, finding, or piece of content actually goes

A quick-reference index across every persistence layer agentics currently defines, project memory, global memory, `.dev/roadmap.md`, `.dev/tech-debt.md`, `.dev/docs/<service>/`, `.dev/docs/atlas/`, and atlas drafts. Each step below states the test and points at the file that actually defines it in full: this map orders and connects those rules, it doesn't redefine any of them. First written as a live, usable draft (2026-08-08): treat it as a working v1, expect it to need revision once more real cases test it, the same "prove it before templating it" caution this repo applies to any new mechanism.

## Recording that something is unknown is a claim, so check before you write it

"Needs coordination with whoever owns X", "owner TBD", "pending another team's commitment": each of these asserts that a fact is unavailable. That is a claim about the state of your records, not a neutral placeholder, and it is exactly the kind of claim `review-conduct.md` already says to verify before making, since an absence returns clean whether or not you looked. Before writing an uncertainty into anything persisted, check the one place that would hold the answer. For ownership and responsibility that is your cross-project map's `Owner:` field; for a convention it is the convention set; for a project's own decisions it is `.dev/`.

Confirmed directly, and the shape of the failure is what makes it worth its own rule: the fact was already recorded globally, the agent had access to it, and it still wrote the wrong framing into a committed tech-debt entry. So the gap was never the fact being absent. It was that a global fact does not fire at the moment a project-local file is being written, because nothing about writing that file makes anyone go and look. Recording the fact in more places does not fix that and makes it worse; see the section below on why a repeatedly-wrong answer wants one named field rather than copies.

The cheap version of this rule, which is what actually makes it usable: an uncertainty you are about to persist is a question. Ask it before you write it down, rather than writing the question down as though it were an answer.

## A recurring wrong answer means a missing field, not a missing paragraph

Before running the questions below, check whether the thing you are about to write down is an answer to a question that has already been answered wrongly more than once. If it is, the fix is a named field in the one place that question gets asked, not prose added wherever the mistake happened to surface.

Confirmed directly, twice on the same component: a session described a service its own team had built as awaiting some other team's commitment, having inferred ownership from the repository's organization rather than finding it stated. Corrected once, it recurred the next day. The correcting session then wrote ownership into two separate places, a note covering the whole product family and a field on the single component where the error had appeared, leaving the other ten components of that family still unanswerable and two copies of one fact to drift apart.

The two failure modes are worth naming separately, because the second is the one that looks like diligence:

- **Patching the symptom site.** Recording the fact where the error surfaced fixes that instance and leaves every sibling case open. If the same question can be asked of twenty entries, twenty entries need the answer, which means it wants a field rather than a paragraph.
- **Answering in more than one place at once.** Belt-and-braces reads as thorough and is the duplication this whole file exists to prevent. One canonical statement, referenced from wherever it is needed, is the only version that cannot drift.

The general shape: a question an agent keeps getting wrong is a question your records do not answer. Prose describing the right answer helps once; a field that always carries it removes the question. Where the field's value would be the same for most entries, state the default once at the top and let each entry carry the short value, rather than repeating the reasoning per entry.

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
