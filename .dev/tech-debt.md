# Tech debt

Format: severity (low/med/high) | kind (design/type/test/docs/style) | standalone? | description

---

OWASP A08-A10 in security-guidelines.md not validated against team review
standalone: no
context: security-guidelines.md was written with A01-A07 grounded in the team's OWASP review session; A08 (Software and Data Integrity), A09 (Logging and Alerting), and A10 (Exceptional Conditions) were sourced from OWASP directly and have not been cross-checked against team notes. Once the team completes items 8-10 in their review, update security-guidelines.md with any corrections or additions.

low | design | yes | CHANGELOG.md has two incompatible entry formats
standalone: yes
context: 215 of 225 entries use the canonical five-field form; the ten oldest (2026-06-02 to 06-05) use a four-field form predating the `bump` field. Undocumented, so anything parsing the changelog mechanically breaks on the tail. Either backfill the missing field or state the format change where a parser would look.

high | design | yes | The always-read tier has no budget of its own
standalone: yes
context: The growth gate holds one 60,000-character budget over `template/` and `docs/` together, and reports the always-read share beside it without constraining it. That share grew 17,691 characters in the current batch, more than a quarter of the whole budget, while the batch passed comfortably. A character in a file every session loads costs more than one behind a trigger, and nothing enforces the difference. Deliberately unfixed so far because no honest weighting exists: the 60,000 came from four releases of history and any multiplier for the always-read tier would be invented. What is missing is not the number but a decision about whether the tier gets a separate budget derived the same way.

med | design | yes | The accretion ratio cannot see revision inside an unreleased batch
standalone: yes
context: `check-prune-ratio.sh` compares the working tree against the last release, so a line added in the current batch and then revised in the same batch still reads as one added line. Correcting a contradiction in `writing-style.md` changed three passages and moved the ratio not at all. The metric is honest about accretion across releases and blind to revision within one, which matters because a review pass does most of its work inside an unreleased batch and gets no credit from the measurement that motivated it. Fixing it would require storing the batch's own prior state.

med | design | yes | Roughly 69 convention sections are unassessed against the tell criterion
standalone: yes
context: A crude proxy counts 63 convention sections as carrying something checkable and 69 as not. Reading a sample of five found two whose tells were hidden inside them, one section that was navigation rather than a rule, and no trim candidate, so the figure overstates the work and its composition is unknown. Each needs reading to sort into reframe, add-a-check, file, or not-a-rule. This is a backlog rather than a defect: the corpus is not known to be wrong, it is known to be unaudited.

med | docs | yes | writing-style.md carries thirteen sections with overlapping territory
standalone: yes
context: Seven of the thirteen govern what to include and in what order, and they arrived one report at a time over a week, each written without the others fully in view. One contradiction has already been found and fixed there, between a section shipped on 2026-09-10 and one that had been present for weeks. A title-level reading produced a wrong merge candidate; the real redundancy was inside the largest section's own bullet list. Consolidation needs a full read rather than a skim, and the file is in the always-read tier, so the cost of leaving it is paid by every session.

low | design | yes | The dash check reports ok over a scope narrower than the rule
standalone: yes
context: `check-consistency.sh` scans `template/**/*.md` and `docs/*.md` for the four banned dash forms, and the section prints "Dash rule" without naming that scope, so a clean run reads as a clean corpus. Outside it, `CHANGELOG.md` carries 17 genuine instances, every one predating the rule's arrival in 0.16.0, including the entry that introduced "Name code, not people". A first count said 59 and was wrong: 21 were release headings in this repo's own `### 0.20.0 - 2026-09-01` format and 10 were list markers, which is the bare-count failure the corpus already documents, committed while measuring something else. Two decisions are open and they are separable. Whether the section should name its own scope in its heading is a cheap yes. Whether released changelog entries should be edited at all is not, since they are the record of what shipped, and rewriting prose in them to satisfy a rule that arrived later is a different act from fixing a defect. Left alone pending that call rather than swept.

high | design | yes | Two always-read rules give opposite instructions on naming peers in persisted files
standalone: yes
context: `AGENTS.md` § Critical constraints ("name code, not agents either", added this batch) says a persisted document never records which agent confirmed something, and treats an anonymous "a session that had read this file" as correct. `agent-index.md` § on labels says to refer to a peer by label in session logs, tech-debt, atlas write-ups, convention prose and changelog entries, and calls the anonymous form non-compliance. They also disagree on a fact: one says a label decays because it is conferred per session, the other that labels persist where handles do not, and the second is what happened when a registered owner returned under a new handle with the same label. **The older rule carries an argument the newer one does not answer**: anonymising manufactures apparent independence, so five findings from one source read as five sources, which is the instance-inflation failure relay marking exists to prevent. Found by a fresh-context review of the always-read tier. Not resolved during the release because either direction is a design decision, and the plausible reconciliation (no runtime handles or session identities in persisted files, labels permitted as provenance where instance counting depends on them) rewrites both.

med | design | yes | The upgrade procedure gives four different instructions for what `synced` stamps
standalone: yes
context: `upgrading-adoption.md` says to stamp the last released and pushed commit in one place and agentics' current `HEAD` in four others, `global-context/README.md` gives a SHA form and a version-only form in the same file, and the root README says the version is the half `upstream-check.md` compares while `upstream-check.md` says the SHA is what is tracked. Three independent test runners hit this separately. Two related gaps: an orphaned synced SHA with a valid version gets an Unreleased-only catch-up window from one instruction and a window from the tagged version from another, silently dropping whole releases; and nothing covers an agentics source with no git history, such as a downloaded archive, where every remedy the procedure offers requires git.

med | design | yes | Session-start mechanics disagree with themselves in three places
standalone: yes
context: `session-discipline.md` says both to run only what a gap could have invalidated and to run the whole checklist on every signal "with no judgment call". The board and sync-notice signals are listed only inside `agent-index.md`, which a session opens only to reach a peer, so neither the session-start sequence nor the pre-commit re-check ever reads the board; this is how an entry addressed to this repository sat unread for four days. Memory fallback has three answers across `AGENTS.md`, `session-discipline.md` and `agent-index.md`, and a flag written to the `.dev/` fallback is never read back. Unverified: `AGENTS.md` describes the memory path encoding as replacing every `/` with `-`, and a reviewer suspected every non-alphanumeric character is replaced; no directory on the machine that checked this derives from a path with a dot or underscore, so it could not be settled.

med | design | yes | A rule for writing an identity guard at registration was dropped and three files still point at it
standalone: yes
context: `AGENTS.md`, `session-discipline.md` and `agent-index.md` all refer to "the guard" written at registration; `agent-index.md` § Registering and changing ownership no longer contains a step that writes one, and `regression-checklist.md` still expects it. Either the guard was superseded by the session-identity section now carried in global context, in which case the pointers and the regression entry are stale, or it was lost, in which case registering sessions no longer protect their workspace. Needs a decision about which.

low | design | yes | Minor findings from the pre-release deep check, held rather than fixed
standalone: yes
context: `writing-style.md` says to configure spelling "here" in a file that is never copied, so the instruction can only be followed by doing something forbidden. A project-level `propagation_suggestions` override is not honoured by the session-start step that reads the flag. `check-agent-index.sh` recognizes a family head only when its space ends in the current directory's name. The softeng addendum can be loaded both as a global copy and as a live read, and the adoption flow does both. Six convention paragraphs narrate their own revision history ("an earlier version of this paragraph said otherwise"), which fixing would shrink, each needing a judgement about whether the correction is load-bearing.
