# Entry formats for `.dev/`

How a session-file entry and a tech-debt entry are written. Read this when you are about to write one, which is a different moment from session start: `session-discipline.md` covers what happens when a session begins, and split from it so that reading the session-start checklist does not also mean reading the formats for artifacts you may not produce that day.

The rules here are what an entry must and must not contain. `writing-style.md` covers wording that applies to any output.

## Narrating your own confidence is process-order too

**Recording how sure you are, in place of what you want, is the same defect as recording how you got there.** It is easy to miss because it does not look like a derivation. Reported by a session auditing its own review comments: a genuine third request had been demoted to "One detail if the list is being edited anyway", calibrated as minor and therefore buried, where the fix was to promote it to the ask and state the severity flat underneath.

**So the hedge is not softening the ask, it is hiding it.** A reader scanning for what is wanted skips a sentence that opens by disclaiming its own importance, which means the writer's severity estimate has silently become a filter on whether the item is seen at all.

## Provenance names what was checked, not who checked it

**A provenance line exists so a later reader can re-run the check, which is the test for whether it is written correctly.** "Verified by the session owning portal-ui" cannot be re-run by anyone. "Verified against `<path>` at `<ref>`" can be re-run by everyone, including the author a month later. Naming the party is not a weaker version of naming the artifact; it is a different kind of statement that happens to occupy the same slot.

**Three things get conflated and each belongs in the record separately.** The **source** is what was consulted and where: a file, a deployment, a running service, a version. The **route** is who relayed it, which is at most a footnote and never the evidence. The **status** is whether you verified it yourself or are passing it on unchecked.

**The route decays and the source does not.** A session identifier is unresolvable within a day, which is already why handles are banned from written records, and the same fact is what makes agent-as-provenance fail: a line reading "confirmed by `service-a1`" is worth nothing the moment that process ends. A path and a version stay checkable for as long as the repository does.

Both patterns were observed in one repository. The defective form: *"Reported by `service-fb`, the session owning portal-ui, and verified by it against current code rather than recalled"*, where the actor is a dead handle and "current code" names no file. The correct form, in a neighbouring file: *"Reported via a peer session, originating from the portal UI and not verified here"*, followed by concrete versions, which separates route from source and declares its own status in the same sentence.

**This is the relay distinction applied to verification.** A peer telling you something is a route, and the artifact they read is the source; recording the first in place of the second stores the part that expires and discards the part that does not.

## One entry states one thing

**A status, a finding, and a judgement in one sentence are three things.** Split them, whichever artifact you are writing: a session bullet, a tech-debt line, a roadmap item.

**A worked instance, from a peer session's own log:** "Superseded, and this is the one that matters: empty combinations are no longer fail-secure." Three claims fused. A reader skimming for what changed can come away recording "empty combinations not fail-secure" as the top-priority item, which is the writer's editorial ranking promoted to an established fact. **That is a decision nobody made, produced by compression.**

**Splitting is nearly free**, which is why context economy has no case against it here: a full stop, and occasionally one connective. "Both candidate algorithms are asymmetric, so the controller holds public keys only" becomes two sentences for the price of "therefore".

**This is the one writing rule that binds in condensed files too**, and it lives here rather than only in `writing-style.md` § Density because of when it applies. Density is about the reader's decompression cost and is scoped to human-facing prose. This is about accuracy, so it holds everywhere, including agent-facing files where brevity is otherwise the goal. It sits in this file because this is what an agent reads at the moment of writing an entry, rather than once at session start.

## Any entry: record the change, not the process that produced it

**The general rule and its reasoning are in `writing-style.md` § Say what changed, not how you got there**, which covers commit messages and review comments too. What follows is what it means for an entry specifically.


**Process is: how the issue was found, what was tried and abandoned, which review or session surfaced it, who challenged whom, what was verified along the way, and the entry's own edit history.** None of it survives contact with a reader who arrives later wanting to act. "Originally thought the cause was X, then found Y" is one fact (Y) wearing the costume of two.

**This has now been found independently on four surfaces in two days, which is the actual lesson.** Session files narrating a day's conversation, commit series narrating their own path to a final state, changelog entries under an unreleased heading correcting each other in sequence, and tech-debt items describing their investigation rather than their defect. Each was discovered separately, and each time the fix was written into that one surface's rules, so the next surface inherited nothing. The principle belongs to durable artifacts as a class, not to any one file, and the per-format sections below carry only their own specific instances of it.

**The test, in one question: would a reader who arrived with no memory of the work need this sentence to act?** If it only makes sense to someone who was present, it is process. Related but distinct from `documentation.md` § "Rewrite freely until committed", which governs *revising* a draft rather than what a finished entry contains; a chain of corrections violates both, while a single tidy paragraph narrating an investigation violates only this one.

## Session file entry format

One lean context sentence (what + why only), a blank line, then one bullet per file or logical group of changes. No date header inside the file: the filename already carries it. No prose paragraphs. No "Next:" line: open work belongs in `roadmap.md`. The separator in bullets is `: ` (colon-space). Do not use em dashes (`—`) or a space-hyphen-space (` - `) as a connector; both are the same anti-pattern in different characters. See `writing-style.md` § Dashes for the full list and the absolute rule (no conversational-chat exemption).

```
[One sentence: what the work was and why.]

- `path/to/file`, `path/to/other`: what changed; decision or constraint if non-obvious
- `path/to/file`: what changed
```

**What to include in the context sentence:** what the work was and why it was done. Omit incidental context (which cluster was available, what else was happening): lean enough to read at a glance.

**Write about effects, not style.** Describe what the code now does or enables: the practical outcome for operators, users, or callers. Do not describe how the code was written: style choices, refactoring approach, helper names, and implementation details are not session log material. "Operators now see actionable error messages" belongs; "rewrote using positive conditions and pure helpers" does not.

**Describe the system, not the struggle to find it.** A negative result worth keeping ("X doesn't work because Y") is a fact about the system; the process of getting there, what was tried, what failed, how long it took, isn't. Collapse the second into the first:

Not: "Spent a while trying to get token refresh working, kept hitting a wall, eventually realized the session state was being reset."
Instead: "Token refresh was resetting session state; fixed to preserve it across refresh."

Same fact, no narrative. Applies to `.dev/tech-debt.md` and `.dev/roadmap.md` too: a known issue is a property of the code, not a chapter in anyone's debugging story.

**Don't narrate the file's own commit state either.** A real example of what this looks like when it slips through: "Everything above is unstaged in the working tree; nothing has been committed." True when written, but it's restating something `git status` already answers for free, and it stops being true the instant anything gets staged, leaving the file asserting a false fact with no mechanism to correct it. See "Git" above: that's a reply to give the developer in conversation, not a fact to persist inside the log itself.

**What to include in bullets:** decisions or constraints only when non-obvious: a choice between alternatives, a dependency or ordering constraint, a pattern being matched for the first time. Don't annotate established conventions (alphabetical ordering, matching a known pattern, etc.): the convention is already known and the annotation is noise.

**Mixed reviews: log the local effect, not the investigation.** A PR review or investigation that turns up one real local change (a tech-debt entry, a roadmap update) alongside a lot of no-op verification work isn't two categories competing for space: log the local change the same way any other change is logged, and drop the investigation narrative entirely, the same way "do not log conversational activity" above already drops a review that produced no local change at all. External references that describe another repository's state (commit SHAs on someone else's branch, a PR number, a squash-merge history) don't belong here regardless of outcome: they document that repository's history, not this one's, and per "Name code, not people" below, they often carry a username along with them too. The frozen-file test above is the sharper form of this and catches cases the ownership argument alone does not: another repository's state is *current* state, and it is state you cannot even observe changing. A bullet recording that some other service has no test coverage of its auth code is false the day they add a test, in a file that can never be corrected, describing a repository nobody reading this one will think to re-check. If a cross-repo fact matters to this project, what belongs here is the consequence for this project; the fact itself belongs in a living artifact that its owners can update.

**A second test, and it catches things the first one passes: a session file is committed, so its readers share the repository and nothing else.** They do not share your machine, your agent's memory, any cross-session index, any running peer sessions, or any handle. So an entry only belongs here if what it describes **exists in the repository**. "Process, not effect" is a different question and lets these through, because writing to project memory, registering in a cross-session index, or reaching a peer are all genuinely effects; they are simply effects that exist nowhere the reader can look.

**The harm is not noise, which is why this needs its own test.** Another developer's agent reads a committed log as project fact. Told that a session coordinated with a peer, wrote a guard into project memory, or confirmed an index entry, it will reasonably infer that those things exist for it too, and act on an environment it does not have. An absent line costs nothing; a line asserting machine-local state as project state hands a false premise to a reader with no way to check it.

**What fails the test, concretely:** anything about inter-agent messaging or coordination, anything written to or read from an agent's memory, anything about a cross-session registry or bulletin board, runtime handles, and anything living in a global context directory rather than the repo. Note that each of those already has its own record somewhere machine-local, so logging it here duplicates a local fact into a portable file, which is the whole defect in one sentence.

**What survives is the repository-visible residue, and it is usually shorter.** Not "coordinated with the Lyric agent on tech-debt verbosity, which produced a convention change", but the convention change. Not "wrote the identity guard to memory", but nothing at all, because no file in the repo moved. If a peer exchange produced a real change here, log the change; the exchange is not the effect, the commit is.

**The test that decides what belongs here: this file is frozen, everything it describes is not.** A session file is immutable once its day closes (below), while code, docs, roadmaps, and tech-debt entries all keep moving. So record only what stays true by construction: what happened, what was decided, what was learned. Never current state, because current state changes and this file cannot follow it. A summary of an artifact written here is not merely duplication, it is a frozen copy that silently diverges the first time the artifact is edited, and the immutability rule forbids correcting it. Duplication you can live with; an unfixable, confidently-worded, increasingly wrong copy you cannot.

**A good PR description is such an artifact, and the entry that duplicates it has a measured cost.** Reported by the Lyric and Maestro session. Four bullets restating what changed file by file, at the same level of detail as the PR description and commit messages, were flagged in review by the repository's maintainer: he was reading the file to check for secrets before merge, found nothing in it he had not already read, and said so. A human reviewer's time, spent for no return.

**But the fix is not to thin the entry or point it at the PR, and that correction is the developer's.** The first attempt was to trim the file to a one-line pointer, reasoning that the content already existed on GitHub. That inverts the reliability hierarchy: GitHub-hosted content, a PR description, review comments, is disposable and platform-dependent, while git-committed content is durable and portable regardless of who hosts the repository. Pointing a committed file at hosted content makes the durable artifact depend on the disposable one, which is backwards from the reason session files exist. His words: **"I do not want us to rely on GH functionalities for documentation of codebases. Git is fine, GH is not."** The frozen-file test above reaches the same conclusion by another route, since a reader who has the repository and no access to the host gets nothing from a pointer.

**So the fix is a higher content bar, not less content.** Keep the entry and admit only what is not recoverable from the PR, the commits, or the code: a decision whose rationale was never written down, a defect class plus the grep that finds future instances of it, why one library helper was chosen over a hand-rolled alternative rather than merely that it was, a testing or process lesson specific to this codebase. Check each point against the PR description before including it. The rewrite that came out of this kept all four original topics and re-cut every one around what nothing else recorded.

**So reference an artifact, never restate it.** If the work produced a document, a tech-debt entry, or a roadmap item, the bullet says what was produced and why it matters, and the artifact holds the findings. Point at the document and name the finding in your own words, rather than citing a heading or section: a living document gets reorganized, and a reference to a section that no longer exists is a dangling pointer, where a named finding survives the restructure. This is the single largest source of weight in an over-long session file, and removing it costs a reader one hop and loses nothing.

**A general principle does not belong here either, for the same reason.** A line like "a false pointer in an index is worse than an absent one" is timeless rather than dated, so freezing it in a session log means it can never be revised, while the same sentence in a convention can. If a change taught you something that generalizes, the change goes here and the lesson goes to the convention, the atlas, or memory, per `definition-of-done.md`'s lessons-learned criterion.

**Coordinating with another session is process, not effect.** Who you spoke to, what you raised with them, whose challenge prompted a correction, and what you decided not to do are not session-log material, exactly like a PR review that produced no local change. Log what changed in this repo; if a peer exchange produced nothing local, it produces no bullet. This is the same rule as "do not log conversational activity" above, stated explicitly because cross-session messaging is new enough that "conversational" does not obviously cover it. Runtime handles are doubly excluded: see `agent-index.md`, an `id` is valid only for its session and this file outlives every session.

**Your reader is already oriented, so do not rebuild context in every entry.** `documentation.md` § Writing for a cold reader deliberately exempts session logs for this reason, but it says so in that file rather than this one, where the writing actually happens. Stated here so it fires: an entry needs to convey what changed and whether it matters to whoever is reading, not enough for them to reconstruct the reasoning without opening anything. Restating shared context in each of fifty entries is how a file reaches eight hundred characters a bullet while every individual rule is being followed.

**No size limit, deliberately.** A cap would be complied with by dropping entries rather than shortening them, and the first to go are the ones hardest to compress: negative results, surprises, the reasons something obvious does not work. Those carry the most value per byte in the whole file. The rules above remove weight without removing information, which is the better trade. A high bullet *count* on a genuinely large day is fine and needs no defence.

**A compaction-survival buffer is not what this file is for.** Writing findings down as they arrive, because context may be lost mid-session, is a real and correct instinct, but the place they need to survive is the artifact that will own them: `tech-debt.md`, a roadmap entry, an atlas document. Write them there first. Putting them here as well produces exactly the frozen-copy problem above, from an entirely legitimate motive.

**Collapse iteration to outcome, don't narrate the path.** `documentation.md` § "Rewrite freely until committed" states the general rule this applies: overwrite a stale note in place, don't append a correction on top of it. Applied here: work inside a still-open session file can get corrected, trimmed, or reversed more than once before the day closes, and the file stays open for exactly that reason (see immutability below): correcting a bullet in place is ordinary editing of an open file, not a rewrite of a closed one.

The failure isn't ignorance of the rule. It's mistaking "already written" for "already committed." A bullet sitting in an uncommitted, still-open file is a draft, not settled history, right up until the day itself closes it, and treating it as fixed the moment it's typed is what produces a chain of "renamed to Y", then "renamed Y to Z", then "renamed Z to A": that chain documents the note's own edit history, not the code, and reads as the same kind of noise "do not log conversational activity" already excludes. A future reader needs only "A".

**One narrow exception: a discarded path that left evidence a reader will find and misread.** If an attempt was made and reverted, and git now shows an edit and a revert with no explanation, the next person finds the same plausible fix and repeats the loop. There the negative result *is* the outcome, so record it: one line saying the approach does not work and why it looks like it should, pointing at the tech-debt entry that holds the analysis. The test is whether a future reader would plausibly retry it, not whether the detour was interesting. Everything else still collapses.

**Immutability has one deliberate exception, and it is not "I disagree with what it says".** When a convention change makes some class of content not worth keeping, a closed session file is in scope for removal, because immutability protects a record from casual revision rather than preserving content that should never have been written. That runs through `upgrading-adoption.md` § Sweep backwards, which requires a proposal, an explanation, and the developer's decision per file or per batch. Removing what misleads is cleanup; rewriting a past entry so the file reads as though the new rule was always followed is falsification.

**A session file is immutable once its day is done.** It may be extended for as long as that contributor's work continues on that day, where "that day" is the calendar date in the filename and not the lifetime of your session process. A session running past midnight has not extended its day; it has started a new one, and owes a new file (see `session-discipline.md` § Session file identity). Once a new day (or a different contributor) starts, that file is closed: if it was written poorly, that's on the session that produced it. Revise a file before the day's work ends, not in a later session.

**Exception: a Critical Constraint violation overrides immutability.** An ordinary quality problem (rambling prose, an unnecessary narrative, a missing detail) stays as the honest record of the mistake, on principle. A violation of one of this project's Critical Constraints found inside a closed file, most commonly an individual's name or a credential, is a different tier of problem: fix it in place regardless of which day produced it, the same way you'd scrub a leaked credential out of an old commit rather than leave it because "that commit is history." Immutability protects against a later session quietly rewriting an earlier one's judgment calls; it was never meant to protect a Critical Constraint violation from being corrected.

**Name code, not people.** Attribute work to features, modules, and systems, not to individuals: "the network module", not "Jon's network module". This applies to session files, tech-debt entries, docs, and any other persisted content. Attribution belongs in git history (and, per "Session file identity" above, in filenames when it matters), not in what you write.

**A third party's name can't be mechanically caught the way your own can.** A pre-commit consistency check, where one exists, can grep for your own OS username or git identity, since those are known in advance. It has no way to know whose name might get typed while narrating an incident someone else reported to you, since that name isn't known until you write it. This is exactly the moment a name slips in naturally, retelling what someone else did or said, so catching it is on you at the point of writing, not something a script backstops.

## Tech-debt entry format

```
[short description of the issue]
fix: [what the fix actually is, in one sentence, even if the full detail lives elsewhere: a roadmap item, a design doc, a linked issue. Pointing elsewhere for depth is fine; a pointer with no inline substance is not]
standalone: yes | no
context: [roadmap item reference or brief note: required when standalone: no]
```

`standalone: yes`: can be picked up freely without reading other context.
`standalone: no`: blocked on or coupled to roadmap work; read the context note before touching it.

A blocking condition, a caveat, or context on why an entry isn't actionable yet belongs once, inside `context` or `fix` above: not restated under its own bolded status heading or a trailing bullet list. See "Say it once, at the density it deserves" above.

**Don't log an entry that never outlives the session.** Tech-debt entries exist to carry a still-open issue into future sessions. If an issue is found and fixed before the same session's file closes, it never reaches that state: fixing it is ordinary work, not debt, so log the fix itself as a normal session-file change and skip `tech-debt.md` entirely. Adding an entry only to remove it again within the same file produces a "created, then resolved" bullet that documents the entry's own lifecycle instead of any effect a reader would care about, the same process-not-substance shape "Concrete content, not process or events" above already excludes.

**A debt entry's process-narration has a specific shape, and it is the one this format invites.** The four fields ask what is wrong and what to do, and the drift is to answer a fifth question nobody asked: how the defect came to light. So an entry grows a clause about the review that surfaced it, the thing that was tried first, the peer who disagreed, or the checks run before concluding. Reported by a peer session about its own project's file, which is the least self-serving direction such a finding can come from. Drop all of it: the entry is read by whoever picks the work up, and they need the defect and the direction, not the discovery. If the *reasoning* genuinely has ongoing value, it belongs in the atlas with the entry pointing at it, which the `roadmap_split` pattern already does for roadmap items.

**Separate the issue from the fix, even in this minimal form.** A description without a recommended direction is exactly how debt entries go stale: whoever picks it up next re-derives the same analysis from scratch. This is worth doing regardless of project size; it's the one piece of a richer format (below) that doesn't cost extra structure to include. The `fix:` field exists precisely so this isn't optional-by-omission. Redirecting to where the full fix is tracked is valid and often correct, especially for something already scoped as its own roadmap item; what's not valid is a bare reference standing in for the field with nothing about the fix itself said here.

**Don't restate this format inside a project's own `tech-debt.md`.** A comment explaining the skeleton, or noting why older entries don't have a separate `fix:` line, duplicates what this section already defines and drifts from it the moment either copy changes. If a project's file needs a reminder, reference `conventions/entry-formats.md` § Tech-debt entry format by name; don't restate the format inline.

**At scale, consider a richer structure instead:** `**File:** ... **Severity:** ... **Kind:** ... **Issue:** ... **Fix:** ... **Standalone:** ...`, one heading per entry. This is a genuine tradeoff, not a strict upgrade: it adds triage and scanability for a long-lived list with dozens of entries across a large codebase, at the cost of more friction to log each one. A project with five debt entries loses more from that friction than it gains from the structure; a project with fifty gains more than it loses. Pick based on the actual list's size, not by default.
