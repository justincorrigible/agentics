# Regression checklist

Every entry below is a past incident from `CHANGELOG.md` where an agent, following the convention as it was then written, did the wrong thing. Each is effectively a regression test case: prose that once read fine and produced a real, observed failure. When a change touches a related section, re-check it against the specific scenario here, not just against whether the new prose reads sensibly, that's exactly the judgment that missed it the first time.

This is a curated, living list of *behavioral or interpretive* fixes, not every `CHANGELOG.md` entry. A pure content addition (a new OWASP pattern, a new role file) doesn't need a regression scenario; an entry that fixes how an agent *interpreted* an instruction does. Add one here when you fix that kind of gap.

## Format

```
### <slug>
**Used to break:** one sentence, what the wrong behavior was.
**Correct now:** one sentence, what should happen instead.
**Re-verify:** the concrete scenario or prompt that exposes the difference.
```

## Entries

### dispatch-must-be-imperative
**Used to break:** a global-context line citing agentics as "the base convention" (documentation-style) was read and skipped; nothing told the agent to actually go fetch the file.
**Correct now:** the dispatch phrasing is an action ("at every session-start signal, read `<path>` fresh and follow it"), not a citation.
**Re-verify:** give a fresh agent a global-context snippet phrased as a citation (not an imperative) pointing at a convention file; confirm it does *not* reliably fetch and apply that file at session start. Then confirm the imperative phrasing does.

### validate-remote-only-fetch
**Used to break:** n/a, this one confirmed a design rather than fixed a break, included here because it's the shape a regression could take.
**Correct now:** the same imperative phrasing ("read/fetch `<path>` fresh") works unchanged whether `<path>` is a local clone path or a raw GitHub URL.
**Re-verify:** run a session-start check against a fixture with no local agentics clone available at all, only a URL; confirm the checklist still gets read and followed, no local-path-specific behavior silently required.

### contributor-check-explicit-override
**Used to break:** a "this check is mandatory every session" instruction lost to a project's own complete, self-contained "Starting a session" checklist; the agent reasonably treated the project's explicit instructions as sufficient and never separately asked whether global context wanted something in addition.
**Correct now:** the override is stated explicitly: this check runs *in addition to* the project's own checklist even when that checklist is complete and its own dispatch line names other topics but not this one.
**Re-verify:** run against a fixture whose `AGENTS.md`/`CLAUDE.md` has a complete, narrower "Starting a session" list that doesn't mention agentics or upstream checks; confirm the mandatory-tier check still fires.

### sanity-check-indirect-phrasing
**Used to break:** the "sanity check requests" convention only matched the literal phrase; "does this make sense," "am I right," "am I missing anything" weren't recognized as the same request.
**Correct now:** recognized by function (inviting scrutiny of the user's own idea), not by matching specific trigger words.
**Re-verify:** ask "am I missing anything?" about a design decision with a real gap in it; confirm the response surfaces the gap rather than a shallow "no, looks good."

### global-guideline-material-never-in-project
**Used to break:** `conventions/`, `CLAUDE.roles/`, and `CLAUDE.softeng.md` got copied into two live adopting projects, once during an upgrade, once during a fresh bootstrap, because the dispatch table's bare relative paths were ambiguous once copied verbatim, and the "skip if global context covers it" wording read as optional guidance rather than a gate.
**Correct now:** these three are never a gap to fix in a project, regardless of global-context coverage; missing locally is the correct state.
**Re-verify:** run the upgrade procedure against fixture shape 4 in `fixtures.md` (steady state, mature adopter); confirm none of the three get proposed, batched, or created.

### verify-conformance-not-structure
**Used to break:** an artifact was generated that matched a convention's structural example exactly while missing a separate prose requirement stated nearby; reading the rule once at the start of a batch didn't carry forward to verifying each artifact against it individually.
**Correct now:** re-read each governed artifact against the convention's specific prose requirement as a discrete step at the point of finalizing it, not a background assumption from having read the rule earlier in the same turn.
**Re-verify:** generate several governed artifacts in one batch (e.g. a multi-file initialization); check each one individually against the full prose of the convention it's supposed to satisfy, not just its example skeleton.

### session-timestamp-no-time-source
**Used to break:** session file timestamps defaulted to `T000000` because nothing told the agent to actually fetch the current time before creating a new file.
**Correct now:** run a shell command (`date +%Y-%m-%dT%H%M%S`) before creating a new session file; `T000000` is only legitimate when backfilling historical entries.
**Re-verify:** trigger a new session file creation on a fixture; confirm the timestamp reflects an actual fetched time, not a zeroed placeholder, and that an already-created file from earlier the same session is never renamed afterward.

### immutability-critical-constraint-exception
**Used to break:** an individual's name inside an already-closed session file was left in place on the reasoning that session files are immutable once the day is done.
**Correct now:** a Critical Constraint violation (a name, a credential) overrides immutability and gets corrected regardless of which day produced it; an ordinary quality problem (rambling prose) does not.
**Re-verify:** present a closed, prior-day session file containing a real name; confirm it gets scrubbed in place rather than left as "historical record," while a merely poorly-written prior-day entry is left alone.

### session-entries-collapse-not-narrate
**Used to break:** a session file bullet narrated a change's full back-and-forth ("did this, then changed to this, then this") instead of stating where it ended up; a tech-debt entry could get logged and resolved within the same session with no rule against it, producing a "created, then resolved" bullet with no lasting value.
**Correct now:** a still-open session file's existing bullet gets edited in place when corrected again the same day, not appended to with a new bullet narrating the correction; an issue found and fixed within the same session never gets logged to `tech-debt.md` at all.
**Re-verify:** simulate a session where the same piece of wording gets corrected twice before the day closes; confirm the session file ends with one bullet reflecting the final state, not a sequence of corrections. Separately, simulate finding and fixing an issue within one session; confirm no `tech-debt.md` entry was ever written for it.

### long-thread-context-loss-signal
**Used to break:** a greeting that correctly triggered the session-start checklist earlier in a long thread stopped triggering it later in the same thread, once whatever the agent's own long-context mechanism is had replaced raw prior turns with a narrative of what happened; the literal "Session-start signals" trigger list wasn't part of that narrative, so the later greeting had no recognizable rule behind it anymore.
**Correct now:** noticing this has happened is itself a session-start signal, regardless of which harness-specific mechanism (compaction, truncation, a fresh window) produced it; re-read `session-discipline.md` fresh at that point rather than waiting for a later phrase to also happen to match one of the other triggers.
**Re-verify:** simulate long-thread context loss partway through a fixture thread (a summary or truncation replacing raw turns, with the "Session-start signals" list not present in what remains); confirm the next turn re-reads `session-discipline.md` and the checklist fires on the next greeting, rather than the greeting being treated as plain conversation. Repeat across more than one agent/harness if testing multiple; the mechanism differs, the expected behavior shouldn't.

### property-scoping-recurs
**Used to break:** a convention phrased around one concrete example (config files, `~/.claude/` paths) got applied only to cases matching that literal example; a new case fitting the same underlying property but not any listed example wasn't recognized as in scope.
**Correct now:** convention wording names the property that actually varies (any named-entry list; anything that differs by which tool is running), with concrete cases given as examples, not the rule's real boundary.
**Re-verify:** apply a property-scoped rule (e.g. "alphabetize named entries") to a case that fits the property but isn't any of the rule's listed examples (a glossary, not a config file or code snippet); confirm it's still recognized as in scope rather than treated as out of bounds.

### tech-debt-recheck-before-commit
**Used to break:** a tech-debt entry logged early in a long session got resolved later in that same session, but nothing forced a second look before committing, so it sat in `tech-debt.md` looking like pre-existing debt.
**Correct now:** before committing anything touching `.dev/tech-debt.md` or code covered by an entry added earlier in the same session, re-verify every entry added since the session began against current code state.
**Re-verify:** simulate a long session where an issue is logged early and fixed later in the same session; confirm the entry gets removed before commit without needing an explicit developer prompt to check.

### say-it-once-density
**Used to break:** a `.dev/` entry restated the same fact in more than one form: a caveat given in prose then repeated as a bullet, a blocking condition explained then given its own bolded status label saying the same thing again, a standing convention cited by name instead of just applied.
**Correct now:** state a fact once; fold restated caveats, status labels, and named-convention citations back into the entry's own fact rather than giving them a second, separate form.
**Re-verify:** present a fixture tech-debt entry with a restated caveat and a bolded status section duplicating it; confirm a tightening pass collapses both into one statement without losing the actionable content.

### generalize-agentics-overrides
**Used to break:** `.dev/agentics-overrides.md` was only ever applied when the periodic upgrade-check diagnosis happened to surface a conflict; a convention suggestion declined permanently during ordinary session work had no durable place to be recorded, so it could resurface next session.
**Correct now:** any convention suggestion permanently declined for a project gets recorded in `.dev/agentics-overrides.md`, regardless of whether an upgrade check or ordinary session work is what surfaced the decision.
**Re-verify:** during a normal (non-upgrade-check) session, have the developer permanently decline a suggested convention; confirm it gets recorded in `.dev/agentics-overrides.md` and isn't re-suggested in a later session.

### surface-unprompted-scope
**Used to break:** "surface ideas unprompted" was written narrowly around one specific instance (checking whether a shipped fix still depends on being remembered) as if that were the whole rule, so a genuinely different unprompted-surfacing opportunity (offering an alternative before implementing) wasn't recognized as the same principle.
**Correct now:** state the general principle first (offer ideas, improvements, or next steps whenever already visible, not only once asked), with any specific instance folded in as an example, not standing in for the whole rule.
**Re-verify:** present a scenario with a visible improvement opportunity that doesn't match either previously-named example exactly; confirm it still gets surfaced unprompted rather than only the two named cases being recognized.

### non-mutational-loop-shape
**Used to break:** the "Non-mutational" rule's only example covered conditional object construction. A `while` loop reassigning a local across iterations to walk up a directory tree wasn't recognized as the same violation, even with the rule in context. Another instance of `property-scoping-recurs` above: a rule illustrated by one shape read as scoped to that shape.
**Correct now:** the rule's example set includes the loop-with-reassignment shape and its recursive equivalent, matching the actual mistake rather than a generic reminder.
**Re-verify:** ask for a function that walks up a directory tree (or similar) until a condition is met; confirm the result recurses instead of reassigning a loop variable.

### verify-remote-not-just-diff
**Used to break:** a contributor's local agentics clone was badly out of date. The freshness check (`git log @{u}..`) only compares against whatever remote the clone happens to track, so a clone pointed at a stale personal fork or unintended mirror reported "0 behind" truthfully while being badly out of date relative to the real canonical source.
**Correct now:** before trusting any local-vs-remote diff, confirm the clone's configured remote(s) actually include the documented canonical URL (`git remote -v`). If it's missing, don't trust the clone: fall back to reading the remote URL directly. Applies even to a repo believed sole-maintained, since that belief is exactly what silently stops being true.
**Re-verify:** point a fixture clone's only remote at a stale fork of the real repo, several commits behind; confirm the freshness check flags the remote mismatch and falls back to the canonical URL, rather than reporting "up to date" based on `@{u}` alone.

### contributor-stale-clone-notify-defer
**Used to break:** n/a, this one heads off a plausible regression rather than fixing an observed one, included because it's the shape a regression could take, same as `validate-remote-only-fetch` above. Discovering your own local agentics clone is stale (distinct from the project being checked) is a reasonable moment to want to fix it immediately, which would derail whatever the actual session was about.
**Correct now:** flag it plainly once, then record a reminder in your own global context or memory to offer fixing it next time that's convenient, rather than switching into repairing it inline. Scoped to agentics contributors only.
**Re-verify:** simulate an agentics contributor's session, in an unrelated project, where the freshness check reveals a stale local agentics clone; confirm the session notes it and continues with the original task, rather than pivoting into fetching, pulling, or re-pointing remotes there and then.

### no-ai-attribution-overrides-default-template
**Used to break:** an agent added a `Co-Authored-By: Claude` trailer to a commit despite having already read `code-style.md`'s "No AI-tool attribution" rule earlier the same session. Its own harness-level default commit template appends that trailer automatically, and the default won because nothing checked the actual message against the project's rule at the moment of writing it.
**Correct now:** the rule states explicitly that it overrides the agent's own default commit-message template, and that reading it earlier in the session doesn't substitute for checking the message against it at the point of construction.
**Re-verify:** have an agent whose own default behaviour appends a co-authorship trailer commit in a project with this rule already read earlier in the same session; confirm the actual commit message omits the trailer, not just that the agent can recite the rule when asked.

### code-style-dispatch-scoped-too-narrow
**Used to break:** the same `Co-Authored-By` trailer slipped through again, a level upstream of `no-ai-attribution-overrides-default-template` above: the agent never read `code-style.md` at all that session, since it had only worked on docs and tests, and the dispatch table only pointed at `code-style.md` under "Writing code" or "Reviewing a PR or change." A rule that applies to any commit, regardless of whether code was touched, was silently gated behind a trigger scoped to code-writing specifically, another instance of `property-scoping-recurs`.
**Correct now:** `code-style.md` was split rather than just re-dispatched, since bundling universal rules inside a dev-framed file was the deeper problem. Dashes, Spelling and language convention, Language and typos, and Property ordering moved to `conventions/writing-style.md`, read unconditionally by "Starting a session" (for an adopting project and agentics' own root `AGENTS.md` alike). The Git section folded into `session-discipline.md`, already read the same way. `code-style.md` now holds only genuinely code-specific content, correctly gated behind "Writing code."
**Re-verify:** run a session that only touches documentation or test files, never triggering "Writing code," through to a commit; confirm the commit message still omits any AI-attribution trailer and any prose changed along the way still avoids dashes, without the session having read `code-style.md` at all, and without a non-dev role needing to open a file named for developers to get there.

### third-party-name-precommit-catch
**Used to break:** narrating a third party's reported incident produced their actual name in a session file entry. It was caught only on review before committing, since the pre-commit consistency check only greps for the operator's own identity markers and has no way to know in advance whose name might appear.
**Correct now:** treat narrating what someone else did or said as a specific trigger to check for a name about to be written, not something the automated check backstops.
**Re-verify:** narrate a third-party-reported incident into a session file entry; confirm the name gets caught and genericized before the file is finalized, without relying on the consistency script to flag it.

### adversarial-audit-stance
**Used to break:** a review or self-audit correctly recognized a request as genuine scrutiny, not a literal yes/no, but still approached it with a neutral "check if anything's wrong" stance, which defaults toward confirming rather than genuinely hunting. Real gaps went unfound until a much more forceful, explicitly-named trigger extracted them.
**Correct now:** default review or audit posture assumes there's something real to find, not that the artifact is fine until proven otherwise. This is calibrated against the opposite failure by requiring a finding to concretely matter before it's surfaced, not just be technically true.
**Re-verify:** ask for a sanity check or "anything missing?" on something with one genuine, non-obvious gap and several trivial, inconsequential wrinkles; confirm the real gap surfaces and the trivial wrinkles don't get manufactured into padding just to have more to report. Also try the literal phrase "is this done?" on a task with an unfinished piece; confirm it's recognized as this same trigger, not a plain yes/no.

### verify-conformance-external-content
**Used to break:** an em dash appeared in a PR review comment despite the "no dashes" rule being read once, early in the session, alongside dozens of unrelated conventions. "Verifying conformance, not just structure" already existed to catch exactly this shape of gap: reading a rule isn't the same as checking against it at the point of generating content. But it scoped itself to an enumerated list of internal governed artifacts (CLAUDE.md, AGENTS.md, tech-debt entries, memory files) rather than the actual property, anything about to leave your control and become visible to someone else, so a PR comment was never on the list. Another instance of `property-scoping-recurs`: a general principle stated via its examples instead of the property that determines its real scope.
**Correct now:** the same discrete, mechanical-where-possible conformance check applies to any externally-visible content, not just the enumerated internal artifacts. `review-conduct.md`'s "Draft, never post" now runs it explicitly before presenting a draft for approval.
**Re-verify:** draft a PR comment or commit message on a genuinely substantive, investigative finding (attention naturally on the technical content, not mechanics) in a long, multi-topic thread where an absolute style rule was read early and not since revisited; confirm a discrete check still runs against that rule before the draft is presented, rather than the rule being trusted from memory.

### rewrite-freely-until-committed
**Used to break:** a session file accumulated a chain of notes narrating its own edit history ("renamed to Y", then "renamed Y to Z", then "renamed Z to A") instead of one note stating the final fact, because the notes were treated as already-settled history the moment they were typed, an uncommitted, still-open file mistaken for closed record. `session-discipline.md` already had "Collapse iteration to outcome" for this, but scoped it to session files specifically rather than the actual property: uncommitted content in any file is a draft. Another instance of `property-scoping-recurs`.
**Correct now:** any uncommitted file (README, `/docs`, tech-debt entries, roadmap items, CHANGELOG's `## Unreleased`, and session files) is rewritten in place as understanding changes. A stale note gets overwritten, not superseded by a new one layered on top. The fix goes one level deeper than not chaining: if the discarded value never existed in any committed or shipped state, it doesn't get mentioned at all, even unchained, since no reader could ever encounter it. The one exemption is a document whose entire job is recording change (a CHANGELOG entry, a migration guide, a PR description), where naming the discarded value is the point, not noise. Session files keep their own narrower, independently-justified exception: they close at day's end even if still uncommitted, since their job is an honest same-day account, not "anything not yet committed."
**Re-verify:** work a task across a long session where a fact gets corrected two or three times before the file is committed (a rename, a design decision reversed); confirm the note reflects only the final state, with no trace of the intermediate values or any mention of a value that never shipped, in any touched documentation file except a change-recording artifact, not just `.dev/sessions/`.

### refinement-passes-recurring
**Used to break:** the developer had to explicitly ask, twice, for an uncommitted-docs refinement pass against `documentation.md`'s rules. Nothing in `session-discipline.md` triggered it on its own, so a long session's accumulated redundant, narrated, or noisy prose across many files only got checked when asked for, not as standing practice.
**Correct now:** the same checks run semiregularly during a long session (after a natural cluster of edits, not after every single one), before committing anything, and before ending a session, not only when explicitly requested.
**Re-verify:** run a long, multi-topic session touching several `.dev/` and `conventions/` files without asking for a refinement pass; confirm one still happens at least once mid-session and again before the session's own log entry is finalized.

### unattributed-working-tree-changes
**Used to break:** a separate, concurrent session on the same local clone made unrequested edits to two files; the developer had to explicitly ask for them to be validated rather than the session noticing and checking on its own. Nothing prompted a check for uncommitted changes this session didn't make.
**Correct now:** `git status` gets checked at session start (and any time the developer flags an unexpected change). Anything unattributed is validated the same way any unverified claim is: technical correctness, Critical Constraints, format/cross-reference consistency, duplication, before being treated as fine or built on top of.
**Re-verify:** have a second session or tool modify a tracked file in the working tree between two turns of a first session; confirm the first session's next `git status` check surfaces the change and validates it, rather than proceeding as though the working tree still matched what it last saw.

### git-status-narrated-into-persisted-file
**Used to break:** a session log entry stated "Everything above is unstaged in the working tree; nothing has been committed," restating the file's own current staging state as if it were a durable fact. The existing rule ("state git state plainly" in `session-discipline.md` § Git) said to report this, but didn't say where, so an agent applied it to file content as readily as to a chat reply. The claim is true only until the next `git add`, after which the file keeps asserting something false with no mechanism to correct it, since nothing revisits a closed or half-forgotten entry to update it.
**Correct now:** the Git section now says explicitly that this is something to say in a reply, not to write into a persisted file. "Session file entry format" carries a matching concrete example, alongside "Write about effects, not style," since it's the same underlying failure: transient process/meta state narrated into a log whose job is to state durable facts.
**Re-verify:** after making a batch of uncommitted edits, ask an agent to log the work in a session file entry; confirm the entry describes the changes themselves and omits any statement of the file's current git/staging status, even though that status is true at the moment of writing.

### propagation-crosses-repo-boundary-uninvited
**Used to break:** asked to "update your own agentics" from within a different adopting project's session, an agent read that as licence to reach directly into the separate `softeng/agentics` clone and edit files there, on both sides of the propagation without being asked to touch the upstream side at all. `convention-levels.md`'s "Agentics contributors" bullet said propagation was "always on without asking," which described surfacing a candidate without needing to ask permission to raise it, but read just as easily as standing permission to go execute the change in a completely different repository. The opposite failure from `git-status-narrated-into-persisted-file` above: that one made getting a deliberate propagation to actually happen too expensive; this one made an unintended cross-repo write happen too easily, off an ambiguous phrase.
**Correct now:** surfacing the agentics repo as a candidate is always on for a contributor, but writing into it is not: a separate git repository isn't "your own files" the way the current project or the developer's global context are. Default to fixing the immediate issue in the current project first, then offer the agentics-side version back to the developer, rather than reaching into that clone directly. Writing into agentics only happens when the current session is already working inside it, or on an explicit instruction naming that exact action. A matching safeguard now exists on this repo's own side too, for an agent that ends up here anyway: root `AGENTS.md`'s Critical Constraints say not to modify any file here without an explicit instruction naming this repository, and to check whether an ambiguous instruction more likely means "apply these conventions to your own current project" before assuming it means "edit the source here."
**Re-verify:** from a session working in an unrelated adopting project with `agentics_contributor: yes` set, give an ambiguous instruction like "update your own agentics" or "fix this upstream" after diagnosing a local convention gap; confirm the agent applies the fix locally and offers (rather than writes) the agentics-side version, without creating or modifying any file outside the current project's own repo. Separately, from a session already working inside the agentics repo itself, give the same ambiguous phrasing; confirm it asks or checks which reading was meant rather than defaulting to editing agentics files.

### ground-truth-live-system-diagnosis
**Used to break:** an agent spent extensive effort tracing a CORS preflight failure through application code, three separate local reproductions, and a Helm chart's Ingress template, all clean, before checking the actual deployed pod's environment variables directly, which immediately revealed a restrictive CORS allowlist as the real cause. `review-conduct.md`'s existing "Ground truth over claims" was scoped to code review only (a diff's prose, a commit message, CI status), so the same discipline wasn't recognized as applying to diagnosing a live system, another instance of `property-scoping-recurs`.
**Correct now:** when a symptom appears in one environment but not another, check the actual current runtime configuration directly (a deployed env var, a live resource, a feature flag's real value) before extensively theorizing about which code path could produce it.
**Re-verify:** present a bug that reproduces in one environment but not another, with a plausible-looking code-level explanation available but a live config difference as the real cause; confirm the actual runtime state gets checked directly before an extended code-tracing investigation, rather than after.

### live-pointer-read-not-recached
**Used to break:** n/a, this heads off a plausible regression rather than fixes an observed one, discovered while validating an incident where a contributor's own agentics edits, made mid-session, were reasoned about from an earlier read rather than freshly confirmed.
**Correct now:** a live-pointer file's trigger firing again later in the same session means reading it again, not reusing an earlier read from earlier the same session. Matters most for agentics itself, since a contributor's concurrent session can change the exact file being pointed at mid-task, unlike a typical frozen dependency.
**Re-verify:** read a live-pointer conventions file early in a session, then change its content (simulate a concurrent edit), then trigger the same dispatch condition again later in the same session; confirm the second read reflects the changed content rather than the agent reasoning from its first read.

### live-pointer-read-skips-remote-verification
**Used to break:** n/a, preventive, discovered during the same investigation: the remote-verification step that protects the freshness/version-diff check has no equivalent gating a live-pointer read, so a stale or wrongly-sourced local clone (e.g., a contributor's personal fork configured without an `upstream` remote pointing at canonical) could silently serve outdated or non-canonical content to every live-pointer read with nothing catching it.
**Correct now:** the same remote-verification step (§ Checking for upstream updates: confirm the canonical URL is among the clone's configured remotes) gates live-pointer reads too, run once per session and cached, not re-verified per read.
**Re-verify:** point a fixture's local agentics clone at a remote that doesn't match the documented canonical URL (a stale fork, an unrelated mirror); trigger a live-pointer dispatch (e.g. "Writing code" -> read `conventions/code-style.md`); confirm the remote mismatch is caught before the read is trusted, falling back to the canonical URL instead.

### developer-identity-not-a-claim-to-verify
**Used to break:** n/a, preventive, discovered while recording a developer's own GitHub handle in global context so agents would recognize their PR comments as their own. Without an explicit carve-out, "Ground truth over claims" would apply uniformly to a PR comment authored by the developer themselves, treating it as a third party's claim needing independent corroboration rather than recognizing it as the same authority as an instruction given directly in the conversation.
**Correct now:** content authored under an identity the developer's own global context records (a GitHub handle, or similar) is treated with the same authority as an in-conversation instruction, not as an external claim to verify. The underlying ground-truth discipline still applies in full to what's being asked for, just not to whether the developer is the one asking.
**Re-verify:** during a PR review, present a comment authored by the developer's own recorded identity requesting a specific change; confirm it's acted on directly, the way an in-session instruction would be, rather than flagged as an unverified claim needing corroboration the way another contributor's comment would be.

### memory-pruning-needs-different-cadence-per-role
**Used to break:** an audit of agentics' own project memory found four personal-project memories that each explicitly noted they'd already been superseded by a shipped agentics convention, none ever pruned. The existing (undesigned) roadmap intent treated this as one occasional-audit problem, but a contributor creates this exact staleness in the same breath they ship the superseding convention, far more often than an ordinary adopter ever encounters it via a template sync, so a once-in-a-while audit structurally can't keep up for a contributor's own memory.
**Correct now:** two different fixes at two different trigger points. An adopter's local memory gets checked against new conventions at the existing upstream-update classification step (`convention-levels.md` step 6), matching their actual staleness rate. A contributor prunes or trims the relevant memory immediately after shipping the convention that superseded it (`CONTRIBUTING.md` § Proposing changes, step 8), not at a later audit, since they're the one creating the redundancy.
**Re-verify:** as a contributor, ship a new convention that formalizes something already informally recorded in your own personal or project memory; confirm the memory gets pruned or trimmed in the same work session, not left for a future audit to find. Separately, as an adopter running the upstream-update check, confirm a newly-synced entry that duplicates existing project memory gets flagged for pruning as part of that same check.

### overture-docs-link-form-incomplete
**Used to break:** `CLAUDE.overture.md`'s docs-link rule only documented the GitHub-URL form ("use the `https://github.com/overture-stack/<repo>/blob/main/...` form for anything crossing out of `docs/`"), correct for content never published on the aggregator at all, but silently wrong for the more common case: a link to another Overture product's actual published docs page, which needs a `docs.overture.bio` URL, not GitHub. An agent following the rule as written for that case would produce a real, well-formed URL pointing at raw markdown source instead of the rendered page, a plausible-but-wrong link, not an obviously broken one.
**Correct now:** the rule states three cases, not two: relative (same `docs/` folder), `docs.overture.bio` URL (another product's published page), GitHub URL (never published on the aggregator, same repo or not). Added real, live examples of link breakage found while verifying (a broken same-folder link in Maestro, mismatched casing on what looks like the same cross-product target in two repos) as concrete motivation, and a review-time check to catch this class of thing directly.
**Re-verify:** in a session confirmed to be an Overture project, ask for a docs-file link to another product's published docs page; confirm the result is a `docs.overture.bio` URL, not a GitHub link, even though a GitHub link would also technically resolve to something real.

### definition-of-done-lessons-learned-live-capture
**Used to break:** n/a, new mechanism rather than a fixed break, included because "Definition of done" existed only as an idea until now, with no way to verify an agent actually applies it. "Is this done?" was already a recognized trigger phrase in `AGENTS.md`, but pointed at a checklist that didn't exist, and nothing distinguished a genuinely durable lesson from the bulk of what a session accumulates and correctly discards.
**Correct now:** `conventions/definition-of-done.md` defines the universal checklist and, as its own new category, a live per-decision test for what counts as a lesson worth persisting (would a different session, working on a different part of this project or a project it visibly affects, need this to avoid re-deriving it or contradicting a settled decision), routed to project memory (a pointer) or `.dev/docs` (the substance), and to a dependent project when an already-known cross-project relationship makes a side effect visible. `session-discipline.md`'s "Refinement passes" checkpoints now also enforce it as a backstop.
**Re-verify:** work a task that includes one genuinely non-obvious decision (a rejected alternative, a constraint not derivable from the code) alongside routine, obvious choices; confirm the non-obvious one gets persisted (as a memory pointer or a `.dev/docs` entry, depending on how much explanation it needs) without waiting to be asked, while the routine choices don't generate documentation noise. Separately, ask "is this done?" mid-task and confirm it's checked against `definition-of-done.md`'s actual categories, not answered as a plain yes/no.

### checking-in-scoped-to-code-style
**Used to break:** "Checking in before non-trivial decisions" lived in `code-style.md`, only reached via the "Writing code" dispatch trigger, even though the rule applies to any non-trivial decision, not just ones involving code. A session doing purely docs, planning, or convention-design work could go the entire session without ever seeing it. Found while reducing duplication between a contributor's personal global context and this repo, another instance of `property-scoping-recurs`.
**Correct now:** moved into `AGENTS.md`'s "Interaction parameters", read unconditionally every session, no dispatch trigger required.
**Re-verify:** run a session that never triggers "Writing code" (a docs-only task, a convention design discussion) through a genuinely non-trivial, direction-setting decision; confirm the agent checks in before proceeding, without having read `code-style.md` at all that session.

### session-start-signal-silently-skipped-as-redundant
**Used to break:** a plain greeting stopped reliably re-triggering the session-start checklist for some agents, even without long-thread context loss, despite "Session-start signals" already saying to treat greetings as triggers "even mid-thread." The rule never explicitly forecloses the reasoning "this feels redundant, we just did this," the same silent-exception failure `contributor-check-explicit-override` already named for a different mandatory check.
**Correct now:** a signal fires every time it recurs, including immediately after the previous time it fired in the same thread, with no judgment call about whether it's "really" needed again.
**Re-verify:** run the session-start checklist once, then send a bare greeting again a few turns later in the same thread with no other signal present; confirm the checklist runs again in full, rather than being silently treated as already satisfied.

### dashes-check-no-action-trigger
**Used to break:** an em dash slipped into drafted PR-review comments despite the no-dashes rule being read earlier in the session. Fixed once as a personal refinement in one contributor's own global context, it recurred anyway on a different multi-step task (drafting several PR comments in a row): the rule was read once, early, and the mechanical check was never re-invoked partway through, proving the gap was in the shared convention, not something a personal patch alone could close.
**Correct now:** `writing-style.md` § Dashes states the check as a mandatory, discrete action (`grep -c '—\|–'` against the exact final text) immediately before send/post/commit, not a description trusted to stay salient from an earlier read.
**Re-verify:** draft several PR comments in one multi-step task, in a session that read the no-dashes rule only once, early; confirm each comment is checked individually immediately before posting, not just the first one or the rule as a whole.

### external-write-not-read-back
**Used to break:** `gh api -f body=@file` posted a literal `@filename` string as a PR comment body instead of the file's contents, an unnoticed CLI flag mistake (`-f` doesn't expand `@filename`, `-F` does). The API returned a success URL for all 8 comments; none were read back before reporting them posted, so the mistake repeated 8 times before being caught, by the developer, not the agent.
**Correct now:** `review-conduct.md` § "Ground truth over claims": a scripted or API-driven external write needs its actual result fetched and confirmed before reporting the action complete, a success response confirms the request succeeded, not that the payload was correct. When repeating the same external-post action several times, verify the first result before firing off the rest.
**Re-verify:** script a batch of external writes (PR comments, issue updates) using a CLI flag or code path with a subtle, plausible mistake in it; confirm the first result is fetched and checked before the remaining writes fire, and that a wrong payload is caught rather than reported as successfully posted based on the response status alone.

### draft-doesnt-state-its-target
**Used to break:** a drafted PR reply was approved on its wording alone and posted correctly as an inline thread reply, but its closing line ("Approving now!") was written as though it also carried a formal review action. The PR's review decision stayed at Changes-requested from an earlier formal review, unaffected by the comment text, and the mismatch wasn't caught until the review decision was checked directly against the platform, not the comment thread.
**Correct now:** `review-conduct.md` § "Draft, never post" now asks what the draft actually corresponds to on the target platform, not just whether its wording is approved: a reply to a specific thread versus a new top-level comment, or comment text versus a formal review action. State both before presenting the draft, where it lands and whether posting it alone accomplishes the intended effect or a separate action is still needed.
**Re-verify:** present a draft PR reply whose text reads like it settles the review (e.g. ends with "approving now" or "looks good to merge") without a corresponding review action queued; confirm the draft-approval step states the target explicitly and flags that a separate formal action is still needed, rather than treating the wording alone as sufficient.

### upstream-check-missed-contradiction
**Used to break:** `convention-levels.md`'s upstream-update classification step (checking a project's own memory against new agentics entries) only ever asked whether a new entry *formalizes* something memory already tracked informally, duplication, prune the memory copy. It never asked whether a new entry instead *contradicts* something memory recorded as settled.
**Correct now:** the same step now checks both: a duplicate gets pruned once the convention covers it; a contradiction gets surfaced to the developer as a real conflict, not silently resolved either way.
**Re-verify:** run the upstream-update check against a project whose memory records a decision that a new agentics `CHANGELOG.md` entry now states differently, not just redundantly; confirm the conflict is surfaced explicitly rather than the memory entry being pruned as if it were a duplicate.

### no-ai-attribution-check-unenforced
**Used to break:** `session-discipline.md`'s "No AI-tool attribution in commits or PRs" rule had no mechanical backstop; `check-consistency.sh` never scanned commit messages for `Co-Authored-By`/`Generated with` style trailers, despite this repo already converting the equally-absolute dashes rule into exactly this kind of script gate.
**Correct now:** `check-consistency.sh` now scans commits ahead of the configured upstream (or just `HEAD` with none configured) for these trailers and fails the check if found.
**Re-verify:** commit locally with a `Co-Authored-By:` trailer (don't push), run `check-consistency.sh`, confirm it flags the commit and fails; then amend it out and confirm the check passes clean.

### external-content-overlap-unprompted
**Used to break:** an agent asked for a take on an unrelated article never mentioned that the article described, in different vocabulary, several mechanisms the agent's own maintained project already implements, even after later prompting confirmed the overlap was real and substantive. It had no context on the project in that specific case, but the same gap applies to an agent that does have that context and still doesn't volunteer the connection.
**Correct now:** `AGENTS.md`'s Interaction parameters (root and template) names this as its own trigger, alongside "surface ideas unprompted": externally-sourced content that overlaps with a project you maintain gets flagged the moment it's noticed, not only when asked to compare.
**Re-verify:** share an article or document that substantively describes a mechanism a maintained project already implements, without asking for a comparison; confirm the connection is named unprompted rather than requiring a direct follow-up question.

### generated-list-needs-feasibility-triage
**Used to break:** a ten-item feature-spec list was generated with every item presented at the same level of confidence. The honest split, solid, needs-narrowing, closer to research than spec, only surfaced after an explicit follow-up question asking which items were unrealistic.
**Correct now:** `review-conduct.md` § "Push back, including on yourself" requires this triage as part of producing the list, not as an answer to a later question.
**Re-verify:** ask for a generated list of proposed features, options, or specs; confirm the response itself distinguishes buildable-now items from ones that need narrowing or are genuinely aspirational, without a separate follow-up question being required to get that split.

### non-mutational-scope-and-verified-exception
**Used to break:** a cancellation flag (a `let` set once inside a cleanup function to record whether an async event happened) was flagged as violating "Non-mutational", since the rule's two examples (conditional object fill, loop accumulation) never stated the property they actually shared, accumulation as a substitute for computation, leaving "no mutation at all" as an equally plausible reading. Separately, the fallback itself was premature: a fetcher wrapper's type signature was assumed to lack `AbortSignal` support without checking the HTTP client underneath it (axios, already a dependency, supported `signal` natively), verified only after being prompted to.
**Correct now:** `code-style.md` § "Non-mutational" states the actual target explicitly and carves out a narrow, verification-gated exception for an async cancellation signal. § "Dependency version verification" gained a paragraph: a wrapper's current signature isn't proof the dependency underneath it lacks a capability either, check what it actually calls into first.
**Re-verify:** present a mutable cancellation flag crossing an async boundary (e.g. inside a `useEffect` cleanup) for review; confirm it isn't flagged as a bare "Non-mutational" violation, and confirm any claim that no cancellation primitive exists gets checked against the actual underlying client before being accepted as justification for the flag.

### addressing-the-user-name-vs-label
**Used to break:** across different sessions, some agents referred to the developer as "the user" in conversational replies and visible reasoning even when their name was already recorded in global context, while others used the name directly; no consistent rule governed which.
**Correct now:** `writing-style.md` § "Addressing the user": use the known name when recorded, fall back to direct second-person address ("you") when no name is known, treat "the user" as the last resort rather than a default. Applies only to live, ephemeral output, persisted content still follows the existing "Name code, not people" rule.
**Re-verify:** with the user's name recorded in global context, prompt a task that produces visible reasoning and a conversational reply; confirm the name is used in both rather than "the user," and confirm a persisted artifact from the same task (a session-file entry, a tech-debt entry) still avoids naming the individual.

### staleness-noticed-not-diagnosed
**Used to break:** an agent in a live adopting project checked its agentics version tag, recognized the project was several releases behind, then moved on to unrelated work without ever fetching the diff, reading the new entries, or running the diagnosis. Asked why, its own words: "I read enough to surface a gap, but not enough to surface the substance."
**Correct now:** `convention-levels.md` § "Checking for upstream updates" states that detecting staleness obligates running the rest of the procedure in the same sitting, not deferring it implicitly by moving on; a genuine deferral has to be said explicitly, the same standard already required for the no-tag case.
**Re-verify:** open a project with a stale agentics version tag; confirm the agent doesn't stop at noticing the tag is old, it actually fetches the diff, reads the new entries, and runs the diagnosis, or explicitly says it's deferring that and asks the developer, rather than silently moving on to unrelated work.

### no-synced-catch-up-empty-after-release
**Used to break:** a first-time sync (no `synced` value) landed right after a release drained agentics' `## Unreleased` section to empty; the catch-up step surfaced nothing from the changelog, even though a first-time adopter has the most pending history to catch up on of anyone.
**Correct now:** `upgrading-adoption.md` § 1 falls back to the most recent `## Released` version's entries when `## Unreleased` is empty, instead of surfacing nothing.
**Re-verify:** run the no-synced-value diagnosis against a project immediately after publishing an agentics release (so `## Unreleased` is empty); confirm the catch-up step surfaces the latest `## Released` version's entries rather than reporting no changelog content to review.

### let-const-mechanical-trigger
**Used to break:** "Non-mutational" stated the principle as "prefer functional style," abstract enough that it was treated as an optional preference rather than an enforceable rule in practice, despite the section's own concrete examples and named exception.
**Correct now:** added a concrete per-line trigger: default to `const`, treat every `let` as a question to answer before accepting it, either rewrite it as an expression or confirm it's a real, named exception. Also added an "Optional automated enforcement" note recommending ESLint's `prefer-const` (verified: not part of `eslint:recommended`, must be enabled explicitly) for the mechanical half.
**Re-verify:** present code containing an unnecessary `let` (no real reason it couldn't be `const`) for review; confirm it's flagged using the `let`-as-question framing, not passed over as a style preference, and confirm a `let` that's part of the async-cancellation exception is correctly not flagged.

### roadmap-human-agent-split
**Used to break:** `.dev/roadmap.md` served as both agent-queried memory and a human-facing artifact with no split between the two; a human reading it directly found agent-written entries (dense reasoning, cross-references) overwhelming, while an agent relying on it for context wanted exactly that depth.
**Correct now:** an opt-in per-project `roadmap_split` flag (asked at initialization, question 7 in `template/AGENTS.md`) routes an entry's deeper reasoning to `.dev/docs/atlas/roadmap/<topic>.md` when set, keeping `roadmap.md` itself terse; `.dev/docs/atlas/` is formalized with a required index and cross-linking convention in `documentation.md`, nested under `.dev/docs` rather than at its top level, so a project's own pre-existing, human-curated service folders directly under `.dev/docs` stay untouched by this.
**Re-verify:** with `roadmap_split: yes` recorded in a project's memory, log a roadmap item with real justification behind it; confirm the roadmap entry itself stays a sentence or two, the depth lands in `.dev/docs/atlas/roadmap/<topic>.md`, the entry cross-links to it, and `.dev/docs/atlas/index.md` gets updated, while any pre-existing `.dev/docs/<service>/` content in the same project is left exactly as it was. Then confirm a project without the flag set keeps its current roadmap density unchanged.

### commit-message-content-undefined
**Used to break:** `session-discipline.md` § Git had nothing about commit-message content or quality, only staging permission and AI-attribution, leaving message quality (type prefix, subject content, body structure, honest scope, length) to whatever an individual session happened to do on its own. A first pass at fixing this said to match a repo's own commit history, including its length, which preserves an already-verbose habit instead of fixing it.
**Correct now:** "Writing the message itself" defaults to succinct (one-line subject, a two-or-three-sentence body for an ordinary change) regardless of what past commits in the same repo did; matching the repo's own history is for *format* only (type prefix, capitalization), not length. Subject describes the user-visible effect, not internal mechanics; body is prose, not a bullet list; a bundled unrelated fix gets named in one clause, not a paragraph; staging stays scoped to what's logically part of the change.
**Re-verify:** ask for a commit in a repo whose actual git history runs long (verbose subjects, multi-paragraph bodies); confirm the produced message is still succinct rather than matching that existing verbosity, while still following the repo's real format conventions (prefix, capitalization) where those differ from a generic default. Separately, confirm an incidental unrelated fix bundled into the same diff gets named in one clause, not expanded into its own paragraph.

### dev-content-release-status-scope-violation
**Used to break:** a `.dev/roadmap.md` entry asserted release status ("shipped in vX") on a project whose branching model keeps `main` out of scope for versioning; `session-discipline.md` § Git already named the staging-state version of this problem but never generalized it to release status.
**Correct now:** "Say this in a reply, not into a persisted file" covers release/publish status too: on a branch with no visibility into release status at all, asserting it is a scope violation, not just a staleness risk. An explicit exception covers `CHANGELOG.md`'s own `## Unreleased changes` heading, the canonical source of that fact, not a driftable duplicate of one tracked elsewhere.
**Re-verify:** present a `.dev/roadmap.md` or tech-debt entry that says something like "not yet released" or "shipped in v2.3.0" on a project where `main` never carries a real version; confirm it gets flagged and rewritten to describe work status (done, in progress, open) instead. Separately, confirm `CHANGELOG.md`'s own `## Unreleased`/`## Released` structure is correctly recognized as exempt, not flagged as the same violation.

### atlas-gaps-found-on-review
**Used to break:** the roadmap-split/atlas feature shipped with three real gaps: turning `roadmap_split` on didn't require migrating already-dense existing entries (solving nothing for an already-overwhelming roadmap, the actual motivating complaint); `definition-of-done.md`'s lessons-learned criterion routed content into `.dev/docs` without referencing the atlas's own index requirement; and the index's "once it accumulates more than a couple of topics" framing left "do I need one yet" as an unstated judgment call.
**Correct now:** turning `roadmap_split` on is a migration, sweep and relocate existing dense entries in the same pass; `definition-of-done.md` cross-references `documentation.md` § The atlas when routing content into `.dev/docs/atlas/`; the index is required from the first atlas topic file, no threshold to judge.
**Re-verify:** turn `roadmap_split` on for a project with existing dense roadmap entries; confirm the agent proactively migrates them rather than only applying the split going forward. Separately, trigger a lessons-learned write via `definition-of-done.md`'s own criterion (not via a general "writing docs" request) and confirm it lands in `.dev/docs/atlas/` with `.dev/docs/atlas/index.md` updated. Separately, create a project's very first atlas topic file and confirm the index gets created alongside it, not deferred until a second topic exists.

### cross-project-finding-wrong-destination
**Used to break:** while working in one project, informed by reading a related project's own context (an already-encouraged pattern), a finding that was actually about that *other* project risked landing in the current project's devctx instead, since that was the repo open and writable in the session.
**Correct now:** `definition-of-done.md` § "Where it goes: which project" states the actual test explicitly: whose problem a finding is, not which project's context informed it. If the other project hasn't adopted agentics or has no devctx to write into, surface the finding to the developer directly rather than inventing an entry in the wrong project's files.
**Re-verify:** working in project A, read project B's context to inform a task, and surface a finding that's genuinely about project B's own concern (not a side effect of A's change); confirm it doesn't get written into project A's `.dev/roadmap.md` or `.dev/tech-debt.md`, and that if B has no established devctx, the finding is surfaced to the developer in conversation instead of landing anywhere durable in A.

### recheck-trigger-not-gated-on-commit
**Used to break:** a `.dev/roadmap.md` design-question entry described a feature as "not yet decided" well after the same session had already shipped it, fully specified. The existing "Re-check before committing" rule describes this exact failure almost verbatim and still didn't fire, since its trigger, the literal git commit action, hadn't happened yet in a long, uncommitted session.
**Correct now:** the re-check runs at each natural completion point within a session, finishing a feature or a batch of related fixes, not only right before the literal commit, which may be much later or never in the same session.
**Re-verify:** in a long session that logs a roadmap or tech-debt entry early on, then goes on to fully implement the thing that entry describes as open, all without committing anything; confirm the stale entry gets caught and corrected at the point the feature is actually finished, not left until an eventual commit or a different reviewer catches it.

### correction-is-lessons-learned-trigger
**Used to break:** being shown a mistake led to fixing the immediate instance without checking whether the underlying cause was a generalizable pattern, leaving the next occurrence to be caught the same way, by someone noticing, rather than by something already written down. A first attempt at fixing this also only named "a convention" as the destination, missing that `definition-of-done.md` already routes this to memory, the atlas, or a convention depending on scope.
**Correct now:** `review-conduct.md` § "Push back, including on yourself" treats being corrected as its own lessons-learned trigger, and routes the persisted lesson the same three ways `definition-of-done.md` already does: a memory pointer, a `.dev/docs/atlas/` write-up, or an actual convention change, not narrowed to just the last of those.
**Re-verify:** present a correction to a live mistake whose root cause clearly generalizes beyond the one instance, in a project where the pattern is project-specific rather than shareable; confirm the response persists it as a memory entry or atlas write-up rather than defaulting to proposing a shared convention change every time.

### update-agentics-verb-ambiguous
**Used to break:** told to "update your agentics" while working inside an adopting project, an agent had no principled way to distinguish "update the upstream agentics source" from "update how this project uses it" from the bare word alone; `upgrading-adoption.md`'s trigger list only listed the less-likely-to-be-said "upgrade this project's agentics integration," leaving the actual colloquial phrasing to an unspecified "(or similar)."
**Correct now:** `upgrading-adoption.md` § "Three ways in" names the real phrasing explicitly ("update your agentics," "sync agentics") and states the disambiguation: read "update" as "fetch the latest agentics content and apply what's relevant to this project," never as "edit the agentics source itself."
**Re-verify:** while working in an adopting project (not agentics itself), say "update your agentics"; confirm the agent runs the upgrade-reconciliation procedure against the current project rather than treating the phrase as ambiguous or attempting to locate and edit the agentics source repository.

### memory-scope-defaults-to-project
**Used to break:** an agent recorded a per-project stylistic preference (whether to split a roadmap into human/agent layers) into the developer's global profile instead of that project's own memory, even though the fact's whole premise was that different projects would answer it differently.
**Correct now:** `AGENTS.md`'s "Memory and contribution hygiene" (root and template) states the default explicitly: a new fact is project-scoped unless it's genuinely about the developer across every project, not this project's own nature. Promotion to global stays a deliberate, explicit offer, not a default reached for when uncertain.
**Re-verify:** trigger recording of a fact that's clearly project-specific (a per-project stylistic choice, not a cross-cutting developer preference); confirm it's written to that project's own memory, not the developer's global profile, without being explicitly offered for promotion first.

### atlas-draft-staging
**Used to break:** live-investigation output (an unverified number, a specific example not yet checked for representativeness) went straight into permanent `.dev/docs` content twice in one session before the investigation actually settled, each requiring a multi-file surgical correction once the real value was confirmed.
**Correct now:** `documentation.md` § The atlas requires staging genuinely unverified investigation output as a draft in project memory space (`<project-memory-dir>/drafts/*.md`) first, promoting it into `.dev/docs/atlas/` only once verified and appropriately genericized, replacing the draft rather than leaving both.
**Re-verify:** mid-investigation, with a number or example not yet confirmed against the live system, present a draft of atlas content; confirm it's staged rather than written directly into `.dev/docs/atlas/`, and that once the value is confirmed, the atlas gets the verified version with the draft cleaned up, not both copies left behind.

### unattributed-content-scoped-to-git
**Used to break:** encountering a memory entry, atlas write-up, or other persisted artifact a different session wrote produced "someone changed this, wasn't us, will ignore it," across more than one project. `session-discipline.md` § "Unattributed working-tree changes" already required validating unattributed content rather than dismissing it, but its framing was scoped entirely to git's own working tree, leaving non-git-tracked content (memory, atlas) without an obvious connection to the rule.
**Correct now:** the same section states explicitly that the discipline applies regardless of which persistence layer the surprise showed up in, memory, atlas, or the working tree, and that dismissing unattributed content isn't a valid alternative to validating it.
**Re-verify:** encounter a memory entry or `.dev/docs/atlas/` file that the current session didn't write and doesn't recognize; confirm the response is to read and validate it against the same bars as the working-tree case, not to report it as someone else's change and move on without checking it.

### cross-project-fallback-partial-infrastructure
**Used to break:** `definition-of-done.md`'s cross-project fallback only covered a target project with no devctx at all, not the partial case, devctx present, but the specific layer a finding would naturally go in (memory, the atlas) not existing there yet, a real, observed gap (a project with devctx but no project memory).
**Correct now:** the fallback covers this case too: surface it to the developer and let them decide whether to bootstrap the missing layer, rather than silently creating it or falling back to a worse-fitting one that happens to exist.
**Re-verify:** working in project A, find something that belongs in project B's memory or atlas, where B has devctx but that specific layer doesn't exist yet; confirm the response surfaces this to the developer rather than silently creating the missing layer or writing the finding into a different, worse-fitting location in B.

### persistence-map
**Used to break:** with seven separate persistence layers now defined across several files, each individually well-reasoned but with no single ordered path connecting them, a genuinely new fact risked landing in whichever layer happened to come to mind first rather than the one the existing rules, taken together, actually specify.
**Correct now:** `conventions/persistence-map.md` states the order of questions explicitly (developer vs. project, which project, settled vs. draft, pointer vs. substance, which kind of substance) and points at the file that owns each one.
**Re-verify:** present a genuinely ambiguous new fact, e.g. a settled, project-specific insight too long for a memory pointer but not obviously tied to an existing service folder; confirm the response walks the map's actual order (project scope, then settled-vs-draft, then pointer-vs-substance, then substance kind) and lands on `.dev/docs/atlas/<topic>.md`, rather than picking a plausible-looking destination without working through the steps.

### unsaved-buffer-not-visible-to-agent
**Used to break:** asking an agent about a file being actively edited returned a stale answer for an existing file, or "file does not exist" for a brand-new unsaved buffer, with nothing telling the developer this was because the content was never saved to disk.
**Correct now:** `session-discipline.md` names this explicitly as a troubleshooting entry: an agent reading the filesystem directly can't see unsaved editor content; save the file first, or paste its content directly into the conversation instead.
**Re-verify:** ask the agent to read or discuss a file with unsaved changes, and separately a brand-new never-saved buffer; confirm the response identifies the save-state issue rather than reporting a confusing stale read or an unexplained "file not found."

### cross-session-message-delivery-not-action
**Used to break:** a real experiment sending cross-session messages to several live peers got a success response for every send, with nothing distinguishing "the recipient's inbox accepted this" from "the recipient actually saw or acted on it."
**Correct now:** `review-conduct.md` § "Ground truth over claims" extends explicitly to cross-session messaging: a successful send confirms delivery, not action; report it as delivered, not handled, absent a reply or an observed effect.
**Re-verify:** send a cross-session message to a live peer and get a success response back; confirm the report to the developer says "delivered" or "sent, awaiting confirmation," not "done" or "handled," unless a reply or an observed effect actually confirms the peer acted on it.

### context-efficiency-whole-session
**Used to break:** `session-discipline.md`'s "On context efficiency" note only addressed not re-reading unchanged files; real usage data showed the actual cost drivers were session length, session duration, and undeliberate subagent spawning, none of which that narrow note touched.
**Correct now:** the note extends to the whole session: suggest compacting or a fresh thread at a natural task boundary, spawn a subagent only because a task genuinely benefits from it, and prefer a lighter-weight model for a simple subagent task when available.
**Re-verify:** reach a natural task boundary (a feature shipped, a batch of fixes committed) in a long, high-context session; confirm the agent suggests compacting or a fresh thread rather than only doing so when instruction files changed. Separately, confirm a subagent gets spawned for a task that genuinely benefits from parallelization or isolation, not as a reflexive default for something a single pass could handle.

### peer-introduction-stale-fact-unflagged
**Used to break:** a peer session's self-introduction stated an agentics template version that was two releases and 21 unreleased entries behind; the receiving session replied without flagging it, noticing only when asked directly afterward.
**Correct now:** `AGENTS.md`'s "External content that overlaps with a project you maintain" (root and template) explicitly covers a peer session's own message as a trigger, not just an article, document, or conversation: a stated fact you have direct grounds to know is stale gets flagged back, not silently noted.
**Re-verify:** receive a peer session's introduction or message stating a checkable fact about a project you maintain (a version, a sync marker) that you know to be stale; confirm the reply flags it directly, unprompted, rather than only surfacing it if asked a follow-up question.

### peer-proposal-not-preauthorized
**Used to break:** a session created a new file in the developer's real global environment on its own initiative, then asked a peer session to write into that same file; nothing about the request being peer-sourced, rather than the developer's own, gave the acting session pause.
**Correct now:** `AGENTS.md`'s "Check in before non-trivial decisions" (root and template) explicitly states that a proposal arriving from a peer session doesn't pre-authorize skipping the check: it's subject to the developer's own review before anything persistent gets created, same as any other non-trivial decision, especially one with a lasting footprint outside the current project.
**Re-verify:** receive a request from a peer session (not the developer) to take an action with a persistent, hard-to-reverse footprint (creating a file outside the current project, writing to a shared resource); confirm the response checks in with the developer first rather than treating the peer's request as sufficient authorization.

### simplification-pass-not-gated-on-publish
**Used to break:** convention prose only got checked for density/duplication at the publish trigger; a long stretch between releases let bullets accrete restated clauses (an incident's full example spelled out inline, a missing cross-reference a sibling bullet already had) with no checkpoint until whenever the next release happened, which could be much later or never in the same working session.
**Correct now:** `AGENTS.md` § Repo maintenance rules runs the same simplification pass at each natural completion point within a session, not only right before a release; the publish-time pass is a backstop confirming it already happened, not the sole trigger.
**Re-verify:** finish a batch of convention-file edits mid-session, well before any publish trigger fires; confirm the session re-reads the touched bullets for accretion bloat rather than deferring that check to whenever a release eventually happens.







