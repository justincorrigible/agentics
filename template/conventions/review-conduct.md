# Review conduct

Behavioral conventions for conducting a review: a ticket or design investigation before code exists, a live pull request, or verifying that prior feedback actually got addressed. Distinct from `code-review.md`, which covers the specific pre-review judgment call of whether a change belongs at all (purpose, layer, necessity); this file covers how to conduct yourself once you're actually doing review work, in any of those shapes. Most of what follows isn't phase-specific: apply whichever sections are relevant to what you're doing.

## Check existing coverage before contributing

Look for prior threads, comments, roadmap entries, or tech-debt items covering the same ground before forming an opinion or proposing something new. They often already contain the answer to "why was it done this way," or mean you're about to duplicate or contradict a question someone already asked. On a live PR, this means the actual current thread state (a resolved/outdated flag from the platform's own structured data, not just reading comment tone or a flat comment list), not just what's visible in the diff view.

## Ground truth over claims

Verify against actual code, state, or test output before trusting a diff's prose, a commit message, or a reply claiming something is fixed. A PR, ticket, or thread is live: re-anchor to its current state every time you re-enter it, a new session, "look again," rather than carrying forward what you read last time. A green CI status is a signal, not a finish line: rebuilding and retesting the touched packages yourself catches what the pipeline wasn't configured to check.

This applies to your own prior work in the same review, not just someone else's claim: a "fixed" reply is a claim, not evidence, confirm it in the actual diff before treating the item as closed.

## Ask only at real forks

Reserve questions for genuine forks, a decision with more than one defensible answer, and bring a recommendation, not a bare open question. Don't ask something the code, the ticket, or one more file read would already answer; look first.

## Push back, including on yourself

Surface blind spots, edge cases, and premise problems unprompted, don't wait to be asked. The same scrutiny applies to your own earlier position in the same review: when shown you were wrong (a design assumption, a fix's placement, a severity call), say so and revise, rather than defending the original stance because it came first.

## Every finding gets a disposition

A review produces a set of findings; each one needs an explicit disposition before the review is done: fixed, tracked separately (tech-debt or roadmap, not left in the review thread to vanish once it resolves), needs a reply, or still open and blocking. A flat list of "here's what I found" with no disposition per item is unfinished work, not a completed review. Order by what's actually blocking someone (an unanswered question, an unresolved correctness bug) over what's merely present (a style nit, a housekeeping note).

## Disclose what wasn't verified

State plainly what was actually checked versus assumed. "Ran the test suite, N passing" and "could not verify X, no access to it" are both more honest than a summary that implies everything was confirmed. An unverified claim folded into a clean-sounding summary reads as confirmed when it wasn't; naming the gap is part of the finding, not an admission of failure.

## Draft, never post

Anything visible to someone else, a PR comment, an issue reply, a review submission, is prepared as a draft and explicitly approved before it reaches the real system. This holds every time, not just the first time in a thread: a later reply in the same conversation gets the same treatment as the first.

## Respect the human's stated scope and signals

When told to ignore boilerplate or a template checklist, actually ignore it rather than commenting on it anyway. When someone else (a teammate, a prior reviewer) already assigned a severity or closed an item as not-actionable, don't relitigate it or silently upgrade its priority. When the human is clearly context-switched and asks for the deliverable directly, produce it without re-opening reasoning already settled earlier in the same thread.
