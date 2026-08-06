# Review conduct

Behavioral conventions for conducting a review: a ticket or design investigation before code exists, a live pull request, or verifying that prior feedback actually got addressed. Distinct from `code-review.md`, which covers the specific pre-review judgment call of whether a change belongs at all (purpose, layer, necessity); this file covers how to conduct yourself once you're actually doing review work, in any of those shapes. Most of what follows isn't phase-specific: apply whichever sections are relevant to what you're doing.

## Check existing coverage before contributing

Look for prior threads, comments, roadmap entries, or tech-debt items covering the same ground before forming an opinion or proposing something new. They often already contain the answer to "why was it done this way," or mean you're about to duplicate or contradict a question someone already asked. On a live PR, this means the actual current thread state (a resolved/outdated flag from the platform's own structured data, not just reading comment tone or a flat comment list), not just what's visible in the diff view.

## Ground truth over claims

Verify against actual code, state, or test output before trusting a diff's prose, a commit message, or a reply claiming something is fixed. A PR, ticket, or thread is live: re-anchor to its current state every time you re-enter it, a new session, "look again," rather than carrying forward what you read last time. A green CI status is a signal, not a finish line: rebuilding and retesting the touched packages yourself catches what the pipeline wasn't configured to check.

This applies to your own prior work in the same review, not just someone else's claim: a "fixed" reply is a claim, not evidence, confirm it in the actual diff before treating the item as closed.

**Exception: content from the developer's own recognized identity isn't a claim to verify.** If your global context records the developer's own account on an external platform (a GitHub handle, or similar), treat a PR comment, review, or issue authored under that identity with the same authority as an instruction given directly in the current conversation, not as a third party's claim to weigh neutrally or corroborate independently. This is about recognizing who's speaking, not lowering the bar for verifying code or system state itself: the discipline above still applies in full to whatever they're asking for, just not to whether they're the one asking.

The same discipline applies outside code review, diagnosing a live system: when a symptom appears in one environment but not another, check the actual current runtime configuration directly (a deployed env var, a live resource, a feature flag's real value) before extensively theorizing about which code path could produce it. A root cause resolvable by one direct check can otherwise cost hours of code-level and infrastructure-level investigation when the live state was checkable from the start.

**A scripted or API-driven write to an external system needs its actual result read back, not just its response code.** A PR or issue comment, a Slack message, a wiki edit, can return a success response (a 2xx status, a created-resource URL) while writing the wrong content: a shell quoting or CLI flag mistake can silently post something other than what was intended, with no error anywhere in the chain. Confirmed directly: `gh api -f body=@file` posted the literal string `@/tmp/pr181/c1.md` as a PR comment's body instead of the file's contents, since `-f` is the raw-field flag and does not expand `@filename`, only `-F`, the typed-field flag, does; the API returned a success URL for all 8 comments, and none were read back before reporting them posted. Fetch the created resource and confirm its actual content matches what was intended before reporting the action complete: a success response confirms the request succeeded, not that the payload was correct. When repeating the same external-post action several times in a row, verify the first result before firing off the rest: all 8 comments above were posted broken before any single one was checked, checking after the first would have caught it immediately.

## Ask only at real forks

Reserve questions for genuine forks, a decision with more than one defensible answer, and bring a recommendation, not a bare open question. Don't ask something the code, the ticket, or one more file read would already answer; look first.

## Push back, including on yourself

Surface blind spots, edge cases, and premise problems unprompted, don't wait to be asked. The same scrutiny applies to your own earlier position in the same review: when shown you were wrong (a design assumption, a fix's placement, a severity call), say so and revise, rather than defending the original stance because it came first.

**A generated list of options, features, or specs needs its own feasibility triage, not just a uniform presentation.** A list produced from a brainstorm reads the same whether an item is buildable today or genuinely aspirational, unless something forces a harder second pass. Confirmed directly: a ten-item feature-spec list was produced with every item stated at the same level of confidence; only an explicit follow-up question ("which of these are idealistic?") produced the honest split between solid, needs-narrowing, and closer-to-research-than-spec. Do that triage before presenting the list, not only when asked which items are unrealistic: the same "push back, including on yourself" instinct above, applied to your own freshly-generated ideas, not just a previously-stated position.

## Every finding gets a disposition

A review produces a set of findings; each one needs an explicit disposition before the review is done: fixed, tracked separately (tech-debt or roadmap, not left in the review thread to vanish once it resolves), needs a reply, or still open and blocking. A flat list of "here's what I found" with no disposition per item is unfinished work, not a completed review. Order by what's actually blocking someone (an unanswered question, an unresolved correctness bug) over what's merely present (a style nit, a housekeeping note).

## Disclose what wasn't verified

State plainly what was actually checked versus assumed. "Ran the test suite, N passing" and "could not verify X, no access to it" are both more honest than a summary that implies everything was confirmed. An unverified claim folded into a clean-sounding summary reads as confirmed when it wasn't; naming the gap is part of the finding, not an admission of failure.

## Draft, never post

Anything visible to someone else, a PR comment, an issue reply, a review submission, is prepared as a draft and explicitly approved before it reaches the real system. This holds every time, not just the first time in a thread: a later reply in the same conversation gets the same treatment as the first.

Before presenting the draft for approval, run the discrete style-conformance check that `session-discipline.md` § Verifying conformance, not just structure calls for, on anything about to leave your control: absolute, universal rules (no dashes is the recurring case) are exactly the ones a human reviewer is least likely to be scanning for, since their attention is on the substance of the comment, the same investigative work that produced it, not its mechanics.

**State the target alongside the text, not just the content.** A draft's wording can be complete while what it will produce on the platform is still ambiguous: a reply to a specific existing thread versus a new top-level comment, or comment text versus a formal review action. On GitHub specifically, a comment's text, even one that says "approving now," never changes a PR's Approve/Request-changes/Comment status; only a review submitted with that action does. State both before presenting the draft: where it lands, and whether posting it alone accomplishes the intended effect or a separate action is still needed.

Confirmed directly: a draft reply answering an open reviewer question was posted correctly as an inline thread reply, and its closing line read "Approving now!" The PR's review decision stayed at Changes-requested from an earlier formal review, unaffected by the comment text, and the mismatch wasn't caught until the review decision was checked directly against the platform, not the comment thread.

## Respect the human's stated scope and signals

When told to ignore boilerplate or a template checklist, actually ignore it rather than commenting on it anyway. When someone else (a teammate, a prior reviewer) already assigned a severity or closed an item as not-actionable, don't relitigate it or silently upgrade its priority. When the human is clearly context-switched and asks for the deliverable directly, produce it without re-opening reasoning already settled earlier in the same thread.
