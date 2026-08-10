# Session discipline

## Session-start signals

A session is a work period: not necessarily a new chat thread. Treat the following as session-start signals even mid-thread:

- Greetings: "good morning", "hi again", "hello", "hey"
- Resumption: "let's continue", "back to it", "where were we", "picking this up again"
- Explicit: "new session", "let's get started", "let's kick off"
- On-demand: "sync up", "refresh context", "re-read your instructions"
- Long-thread context loss: raw earlier turns are no longer directly present in what you can see, whatever your specific harness calls this or however it happens (for Claude Code: an automatic compaction event, replacing prior turns with a generated summary; for other agents: consult your own tool's documentation for its equivalent, if any)

**This is a different kind of signal from the others above, and needs to be treated that way.** Whatever the mechanism, what survives is usually a narrative of what happened; it does not reliably preserve this exact list of trigger phrases, since it was read once, early, as file content, not as an event worth summarizing. If it's dropped, a later "good morning" in the same thread reads as a plain greeting with nothing behind it: not the agent ignoring the checklist, the rule that would make it recognizable simply isn't in context anymore. Noticing this has happened is itself the signal: re-read this file fresh at that point, don't wait for a later phrase to also happen to match one of the triggers above, since that phrase-matching is exactly the mechanism this risks losing.

**A signal fires every time it recurs, including right after the previous time it fired, with no judgment call about whether it's "really" needed this time.** A bare greeting arriving minutes after the checklist last ran can read as redundant, formality with nothing behind it, and get silently skipped on that reasoning rather than ignorance of the rule. That reasoning is exactly what this section already forecloses ("even mid-thread," a session is a work period, not a new thread), but as more instructions accumulate elsewhere in this file and in `AGENTS.md`, a plain greeting competes against a larger, denser rule set for attention, and "feels redundant, skip it" is the same silent-exception failure `contributor-check-explicit-override` already named for a mandatory check losing to a project's own seemingly-sufficient checklist. Run the checklist again regardless of how recently it last ran; the cost of a redundant re-check is far lower than the cost of a skipped one.

## Starting a session

On a session-start signal, run this sequence before touching any code:

1. `git log --oneline -1 -- CLAUDE.md AGENTS.md .claude/settings.json`: check whether instruction or configuration files changed since your last session file. Re-read only the files that changed. If `settings.json` changed unexpectedly, read it immediately and verify it contains only the expected hooks before proceeding (see `docs/agent-security.md`). When you re-read a changed file, say: "I've re-read [file]: the prior version in this thread is superseded."
2. `git status --porcelain`: check for uncommitted changes this session didn't make. If anything is unattributed, see "Unattributed working-tree changes" below before treating it as settled context.
3. Read `.dev/roadmap.md`: check the current focus and any `[in progress]` items. If your global context defines one or more global roadmaps, read only the one relevant to the current project, not all of them. For example: read `roadmap-work.md` for professional projects, `roadmap-personal.md` for personal ones. See `global-context/roadmap.md` for the convention.
4. Read `.dev/tech-debt.md`: note any `standalone: yes` entries relevant to today's work
5. Read the most recent 1-2 files in `.dev/sessions/` for context on recent work and open threads. ISO-formatted filenames sort chronologically, so `ls .dev/sessions | sort | tail -2` finds them without an index file.
6. If your global context has `propagation_suggestions: yes`, or you're an agentics contributor (`agentics_contributor: yes` in your global context) without `agentics_upstream_check: no` set for this project or globally, check whether this project has adopted agentics at all (a tag, or just a mention of agentics in `AGENTS.md`/`CLAUDE.md`) and, if so, check for upstream updates: see `conventions/convention-levels.md` § Checking for upstream updates. A missing or incomplete tag doesn't mean skip it: it means this project needs the tag added, which that section covers. For contributors, this is mandatory and recurs every session for an unresolved gap: it doesn't quietly stop repeating just because it went unanswered before.
7. Determine your session file for today: see "Session file identity" below.

**On context efficiency:** re-reading a file mid-thread adds it to context: it does not replace the prior version. Both consume tokens. To stay efficient: only re-read files that actually changed (step 1 tells you which), and explicitly mark the old version superseded. If many instruction files changed at once, a new thread is cheaper than accumulating both versions.

**This applies to the whole session, not just file re-reads.** Confirmed directly against real usage data: the bulk of one developer's spend came from sessions sitting above 150k tokens of context, sessions left active for 8+ hours, and subagent-heavy sessions, each subagent runs its own requests. Suggest compacting or starting a fresh thread at a natural task boundary (a feature shipped, a batch of fixes committed), not only when instruction files changed. Spawn a subagent because a task genuinely benefits from parallelization or context isolation, not as a default first move; if your harness lets you pick a lighter-weight model for a simple subagent task, use it.

## Keeping `.dev/` current

At session start, before starting new work, do a quick staleness pass on `roadmap.md` and `tech-debt.md`: mark completed items done, close resolved PINNED entries, remove addressed tech-debt entries. This is not a full audit: just enough to prevent documents drifting out of sync with reality.

Update `.dev/roadmap.md` or `.dev/tech-debt.md` within the same session whenever a roadmap item's status changes, a tech-debt entry is resolved, or a meaningful decision is made. These documents are shared memory across sessions: they should reflect current reality, not just initial planning.

Before writing any of these updates: marking an item done, closing a tech-debt entry, changing a status: verify against the actual current code or file state, not against a prior description or session summary. An assumption carried forward unverified is exactly how these documents drift from what they claim.

**Re-check before committing, not just at session start.** "Don't log an entry that never outlives the session" (see Tech-debt entry format below) only catches the case where the fix lands before the entry is written. A long session leaves room for the reverse: an entry gets logged, then that same session goes on to fix the very thing it describes, with no forced moment to circle back and remove it. Before committing any change that touches `.dev/tech-debt.md` or `.dev/roadmap.md`, or commits code covered by an entry added earlier in the same session, re-verify every entry added since the session began against current code state, and reread each one against "Say it once" below. Waiting for the next session's staleness pass is too late for either check: by then a stale or bloated entry may already be committed as if it were fine.

**This check is not gated on an imminent git commit either.** A session can run for hours and dozens of fixes without actually committing anything, exactly the shape of a long, uncommitted working session, in which case "before committing" never fires and staleness accumulates the whole time with nothing to catch it. Confirmed directly: a `.dev/roadmap.md` design-question entry described a feature as "not yet decided" well after that same session had already shipped it, fully specified, across five other files, caught only when a different agent reviewing the batch pointed it out. Run this re-check at each natural completion point within the session, finishing a feature or a batch of related fixes, not only at the literal moment of committing, which may be much later or never in the same session.

After any meaningful unit of work: code written, bug fixed, tech-debt logged, roadmap updated, docs changed: add or extend the dated entry in your session file (see "Session file identity" below). Do not wait for an explicit "session over" signal: work rarely ends cleanly, and the update will be missed if it depends on one.

Do not log conversational activity: PR reviews that produced no local changes, discussions, waiting states. These are not session-log material. A real example of what this looks like when it slips through: "Asked whether other projects' agents would actually see today's changes: no, not yet, since nothing here is committed or pushed." A question, an answer, no decision and no local change, zero value to a future reader, exactly the shape to catch before it's written, not after. See "Session file entry format" below for the mixed case: a review that also produced one real local change.

When `.dev/` documents are updated, remind the developer to commit them. This history matters for avoiding double work across sessions.

**If this project's memory records `roadmap_split: yes`:** keep `.dev/roadmap.md` entries terse and human-scannable, what the item is and its current status, in a sentence or two. Route an entry's deeper reasoning, alternatives considered, or history to `.dev/docs/atlas/roadmap/<topic>.md` (see `documentation.md` § The atlas) instead of writing it inline, and cross-link the roadmap entry to that file. Real feedback drove this: a roadmap read directly by a human, not only queried through an agent, gets overwhelming once entries carry an agent's full reasoning rather than a plan someone can scan. If this flag isn't set, the default, and how agentics' own `.dev/roadmap.md` stays, roadmap entries keep their current density.

**Turning the flag on is a migration, not just a change of habit going forward.** The moment `roadmap_split` is set to `yes`, whether at initialization on an empty roadmap or later on one that already has dense entries, sweep the existing file: relocate each already-written entry's justification, alternatives, or history to its own `.dev/docs/atlas/roadmap/<topic>.md`, trim the entry itself down to what + status, and cross-link. Applying the split only to entries written after the flag was set and leaving already-dense ones as they were solves nothing for the actual complaint that motivates this, an already-overwhelming roadmap, the same "this is a cutover, not an addition" lesson already learned for the `.dev/sessions.md` to `.dev/sessions/` migration.

**Concrete content, not process or events.** `.dev/roadmap.md` and `.dev/tech-debt.md` hold the substance: a decision, a design topic, a known issue and its fix. They are not a record of who raised something, in which PR, or when a discussion happened; that's process, and it belongs in PR or issue history, not here, the same reasoning "write about effects, not style" applies to session files. A "message format design" entry states the open question and the options, not who tagged whom. This is also where an individual's name most often sneaks in (see "Name code, not people" below): stripping the process narrative removes the attribution risk with it, not as a separate pass.

## Recording a permanent override

Any time a convention (from `conventions/*.md`, `AGENTS.md` itself, or a suggestion made from general practice) recommends something and the developer declines it as a deliberate, permanent choice for this project, not just "not for this one change": record it in `.dev/agentics-overrides.md` (created on first use, not required upfront). This is the general mechanism for "we decided against the default, on purpose, here's why," wherever that decision happens to come up, not something scoped to any one procedure. `upgrading-adoption.md` § 2 is one trigger for it (a conflict found during a reconciliation pass), not the only one.

```
- `<topic or section, e.g. "code-style.md § No non-null assertions">`: <what this project does instead, and why, one sentence>. Decided <date>.
```

Before making the same suggestion again, whether during a formal upgrade check or in the ordinary course of a session, check this file first: a recorded override means don't re-raise it, not "raise it again and see if they still agree." Distinguish a permanent override from a one-off "not now": only a decision explicitly meant to hold going forward gets recorded here; a single-instance "not for this change" stays unrecorded, and the suggestion can resurface next time it's actually relevant.

## Say it once, at the density it deserves

The same fact stated twice in different forms costs the same as stating it wrong, not incorrect, just taking up two or three times its own space: a caveat given in prose, then repeated as a bullet; a blocking condition explained, then given its own bolded status label ("trigger condition, not a start-now item") restating the same explanation a second way; a standing convention cited by name locally instead of just applied. Applies equally to `.dev/roadmap.md`, `.dev/tech-debt.md`, and session file entries: an entry that's grown a sub-section explaining its own nature, sitting beside entries that are two or three lines each, is the signal to fold that condition back into the entry's own fact, not evidence this one earned extra structure. Trusting this to happen at the moment of writing is the same fragile shape as any other unenforced judgment call: it's caught for real at the pre-commit re-check above, the same checkpoint that catches stale entries. Same discipline as `CONTRIBUTING.md`'s `succinct-wording-is-a-separate-pass`, applied here to any persisted `.dev/` content rather than just convention prose.

## Git

Never commit without explicit user instruction: the user handles all git work themselves.

Never stage changes (`git add`) without being explicitly asked to, either: staging is the user's call, same as committing. Making an edit does not stage it: changes sit in the working tree, unstaged, until staged deliberately. When reporting on changes made, state their actual git state plainly rather than just "the changes are there": a user who expects staging and finds none wastes real time looking for something that was never where they expected it.

**Say this in a reply, not into a persisted file.** A session log entry, roadmap item, or any other file that narrates its own current staging or commit state ("everything above is unstaged; nothing has been committed"), or its release or publish status ("not yet in a release", "shipped in vX"), goes stale the moment anything gets staged or released, and the file itself never gets corrected after the fact. `git status` (or the release process itself) already answers this live, for free, at any point someone reads the file later; restating it in prose only adds a claim that can end up false. Sharper still on a branching model where one branch is explicitly out of scope for versioning (a `main` that never carries a real version number, for instance): a file living there has no standing to assert release status at all, not just a staleness risk but a scope violation, since that branch's own role never has visibility into that fact to begin with. Describe work status (done, in progress, open), which the current branch does have authority over, and leave release status to whatever process actually promotes the work. See "Session file entry format" below for what this looks like as a real instance.

**Exception: a file that is the canonical record of release status, not a duplicate aside about it.** `CHANGELOG.md`'s own `## Unreleased changes` heading looks like the same violation at a glance, a release-status claim living on a branch out of scope for versioning, but it's the opposite case: nothing else tracks what hasn't shipped yet, so this heading isn't restating a fact `git status` or the release process already answers elsewhere, it is the one place that fact is tracked, updated by that same release process the moment it changes. The objection above is about a second, driftable copy of a fact that already lives somewhere authoritative; a file that is the authoritative source for that fact isn't a copy of anything.

**No AI-tool attribution in commits or PRs.** Do not add "Co-Authored-By," "Generated with," or similar trailers naming an AI tool or vendor to commit messages, PR descriptions, or PR comments, regardless of which agent is doing the work. Unprompted attribution reads as this project endorsing a specific commercial product; that's not something to do on any vendor's behalf, paid or not. **This overrides your own default commit-message template**, not just other projects' conventions: many agents, including Claude Code, are configured by default to append exactly this kind of trailer automatically. Having read this rule earlier in the session doesn't mean it's actually checked against the message at the moment of writing it: that's a separate, later act. Verify the commit message against this rule specifically as a discrete step when constructing it.

**Writing the message itself.** Default to succinct: one line for the subject, a body of two or three sentences for an ordinary change, longer only for a real, specific reason (the bundled-fix case below, or agentics' own release-commit format in `CONTRIBUTING.md`). Check this repo's own recent commit history for its actual *format* conventions, a type prefix like `feat:`/`fix:`, capitalization, tense, and follow that; its existing *length* is a different thing, not something to match. A repo's history proves a format convention exists, it doesn't prove the length is any good, only that no one has fixed it yet, so don't carry an already-verbose habit forward as if it were a discovered rule. Subject line describes the user- or operator-visible effect, not the internal mechanics: "add per-catalogue nesting config for enveloped data sources," not "add nestingPrefix.ts and thread it through ten files." Body is prose, not a bullet list restating the diff; if an incidental, unrelated fix rode along with the main change, name it in one clause, not a paragraph, honest about scope without losing brevity. Stage only what's logically part of the change before writing the message: an overly broad diff is often exactly where extra message length actually comes from, a tightly scoped change is also what keeps its own description short.

[Team placeholder: adjust this default if your team has a different commit or staging discipline.]

## Unattributed working-tree changes

A shared local clone can pick up uncommitted changes this session didn't make: a different, concurrent session working the same repo, another tool, a teammate's local edit. Their presence in the working tree isn't evidence they're correct, safe, or already reviewed, only that a `git status`/`git diff` will show them.

Notice this at session start (see "Starting a session" above) and any other time it comes up, most commonly the developer pointing out that a file changed unexpectedly. Either way, treat unattributed content the same way any unverified claim gets treated (see `review-conduct.md` § "Ground truth over claims"): validate it before trusting it, or before telling the developer it's fine.

**What "validate" means here, concretely:** read the actual diff, not just its own description of itself. Check it against the same bars any of your own work would need to clear: technical correctness, the project's Critical Constraints (no credentials, no personal information), format and cross-reference consistency with existing conventions, and whether it duplicates or conflicts with something already present. In this repo specifically, also check whether each substantive addition has a matching `CHANGELOG.md` entry per `CONTRIBUTING.md`'s own contribution steps: unattributed content bypassed the ordinary process by definition, so a missing entry isn't a one-off oversight to fix quietly, it's a sign the addition itself may not have been reviewed the way this repo's own rules assume it was. Report the specific checks made and what each found, not just a verdict.

**A validation step, not an automatic revert.** Content that passes validation can be kept. Whether to keep it, revert it, or hold it for their own review is the developer's call, informed by what you found, not decided by the fact that it arrived through an unreviewed channel.

**Not limited to git's own working tree either.** The same kind of surprise happens in any persisted location more than one session can touch: a memory entry, a `.dev/docs/atlas/` write-up, a draft, that this session didn't write and doesn't recognize. Confirmed directly, across more than one project: "someone changed this, wasn't us, will ignore it" is not the same response as validating it, it's a third, worse option, neither trusting it nor checking it, just dismissing it. Apply the same discipline regardless of which layer it showed up in: read it, validate it against the same bars above, then decide whether to keep, revise, or flag it for the developer. Arriving from a different session doesn't excuse skipping that step, and it doesn't justify ignoring the content either.

## Verifying conformance, not just structure

Reading a convention and holding it as an active constraint while generating content several steps later in the same turn are not the same act. A convention's structural example (a field skeleton, a template block) shows shape; matching that shape can happen while missing a separate prose requirement sitting right next to it, a real, observed failure mode (see `CHANGELOG.md` § `verify-conformance-not-structure`).

This matters most producing several governed artifacts in one batch: initialization (`CLAUDE.md`, `AGENTS.md`, tech-debt entries, memory files all at once), a migration, a multi-file update. Before finalizing each artifact, re-read it once against the convention's specific prose requirement, not just against its example shape, as a discrete final step, not a background assumption carried from having read the rule earlier. Verification happens at the point of writing each artifact, not once at the point of reading the rule at the start of the batch.

**Not limited to internal governed artifacts.** Anything about to leave your control and become visible to someone else, a PR comment, a commit message, a Slack message, a published doc, an artifact, needs the same discrete check, not just the files named above. A rule stated as universal and absolute doesn't get easier to hold against a strong competing default just because it's read once, early, alongside dozens of other conventions in the same global file. The no-dashes rule is a real, observed instance of this: it stays technically in context the whole session, but its practical salience at the moment of drafting one specific piece of externally-visible text fades across a long, multi-topic thread, the same way session-start signals fade after a compaction event. Run the check as a discrete, mechanical-where-possible pass immediately before the content leaves your control: the same `grep -c` backstop "Bulk text replacements" already requires for cleaning up existing files applies just as well to fresh content about to go out.

If a convention's own example under-specifies a requirement stated in prose nearby, that's a defect in the convention worth fixing, not something to route around silently: flag it the same way any other convention gap gets flagged.

## Refinement passes: not just once at the end

`documentation.md`'s cold-reader and "rewrite freely until committed" rules, and "Say it once" above, are easy to apply to whatever's being written in the exact moment of writing it, and easy to never revisit afterward. A long session accumulates uncommitted prose across several files (session log, roadmap, tech-debt, conventions, CHANGELOG) faster than any single moment of writing catches. Left to one pass at the very end, the accumulated draft only gets checked once, too late to be worth much and too large to review well in one sweep.

Run this refinement pass, re-reading the session's own uncommitted changes against those rules, at three points, not one:
- **Semiregularly during a long session:** after a natural cluster of related edits lands, before moving to a different, unrelated part of the work. Not after every single edit: that's too fine-grained to be worth the interruption.
- **Before committing anything:** every file about to be staged gets this pass. This runs alongside "Re-check before committing" above, which re-verifies `.dev/tech-debt.md` and `.dev/roadmap.md` entries for staleness. Same checkpoint, applied here to prose quality across all touched files, not just those two.
- **Before ending a session:** the last thing done before signing off for the day, not something skipped because the underlying work itself is done. A correct fix described in noisy, self-narrating prose is an unfinished session, not a finished one with rough edges.

No dedicated tool is required: reading `git diff` (or the equivalent for a new, untracked file) against each uncommitted file and checking the changed passages against the rules above is enough.

**These same checkpoints also enforce `definition-of-done.md`'s lessons-learned criterion.** That criterion is checked live, at the moment a non-obvious decision is made, but each refinement pass is the backstop: ask whether anything recognized as a lesson since the last pass has actually been persisted where it belongs yet, not just noticed and left for later.

## Session file identity

Each session's log lives in its own file under `.dev/sessions/`, keyed by contributor and day rather than one shared file. This is what prevents merge conflicts when several people work the same project the same day: different contributors never edit the same file.

**Filename:** `YYYY-MM-DDTHHMMSS.md`, generated once, the first time the file is created. No descriptive slug: the timestamp's job is uniqueness, not readability. A slug forces a choice between short-and-collision-prone or long-and-unwieldy, and doesn't add anything a directory listing plus the file's own content doesn't already give you.

**A session-start signal doesn't by itself mean create a file.** Greetings, "let's continue," and the other triggers in § Session-start signals tell you to run the checklist; whether that produces a new file depends on the check below. A different contributor always needs their own file (never shared), but the same contributor picking work back up later the same day extends their existing file rather than starting another one.

**Finding your file for today:**
1. List files in `.dev/sessions/` matching today's date prefix.
2. For each match, check authorship: if it's committed, compare `git log -1 --format=%ae -- <file>` against `git config user.email`. If it's uncommitted in the working tree, it's yours by definition: no one else's uncommitted file can be present in your clone.
3. If a match is yours, that's your session file for today: extend it, no new file, no new timestamp. Otherwise (no match, or the only matches belong to someone else), create a new file: see "Get the actual time, don't pad with zeros" below for the timestamp.

This gives at most one file per (day, contributor) pair, not one per session: multiple sessions by the same contributor on the same day land in the same file.

**Get the actual time, don't pad with zeros.** Once step 3 above says a new file is actually needed: you have no innate sense of the current time of day. Your context may hand you today's date, but wall-clock time isn't something you can infer, and defaulting the unknown part to `000000` is a guess dressed up as a value, not a real timestamp. Run a shell command to get it (e.g. `date +%Y-%m-%dT%H%M%S`) before creating the file. If every file created going forward carries `T000000`, that's not several coincidentally-round timestamps, it's this step being skipped every time.

**Exception: migrating or backfilling historical entries.** Splitting an existing shared log into per-day files, or otherwise reconstructing entries for work that already happened, is a different situation from creating a file for a session happening right now: the real time genuinely isn't recoverable after the fact, and `T000000` is a legitimate, deliberate placeholder there, not a bug. Don't treat a legacy file's zeroed timestamp as something to "fix" by renaming it once real times are being fetched for new files: it wasn't wrong for what it was created to do. The rule above applies to ordinary new-file creation, where the current time is always one shell call away.

**Never rename an already-created file, today's own included.** This is not limited to old migration files: a file created earlier today under the old, unfixed behavior is in exactly the same position once created. Renaming it now to the present moment doesn't recover its actual creation time; it substitutes a different guess ("current time, best approximation of session start") for the original one, which is the same anti-pattern this fix exists to stop, just dressed up as a correction. A filename's job is over the instant the file is created: fetch the real time before creating a file, never after.

**Known edge case:** two genuinely concurrent sessions by the same person (two terminals open at once) can still race on the same file. That's a self-conflict the same person resolves alone, not the cross-contributor conflict this convention targets, and it isn't worth a workaround.

No index file is needed to browse chronologically: ISO-formatted filenames already sort correctly with a plain `ls`.

## Session file entry format

One lean context sentence (what + why only), a blank line, then one bullet per file or logical group of changes. No date header inside the file: the filename already carries it. No prose paragraphs. No "Next:" line: open work belongs in `roadmap.md`. The separator in bullets is `: ` (colon-space). Do not use em dashes (`—`) or a space-hyphen-space (` - `) as a connector; both are the same anti-pattern in different characters. See `writing-style.md` § Dashes for the full list and the absolute rule (no conversational-chat exemption).

```
[One sentence: what the work was and why.]

- `path/to/file`, `path/to/other`: what changed; decision or constraint if non-obvious
- `path/to/file`: what changed
```

**What to include in the context sentence:** what the work was and why it was done. Omit incidental context (which cluster was available, what else was happening): lean enough to read at a glance.

**Write about effects, not style.** Describe what the code now does or enables - the practical outcome for operators, users, or callers. Do not describe how the code was written: style choices, refactoring approach, helper names, and implementation details are not session log material. "Operators now see actionable error messages" belongs; "rewrote using positive conditions and pure helpers" does not.

**Don't narrate the file's own commit state either.** A real example of what this looks like when it slips through: "Everything above is unstaged in the working tree; nothing has been committed." True when written, but it's restating something `git status` already answers for free, and it stops being true the instant anything gets staged, leaving the file asserting a false fact with no mechanism to correct it. See "Git" above: that's a reply to give the developer in conversation, not a fact to persist inside the log itself.

**What to include in bullets:** decisions or constraints only when non-obvious: a choice between alternatives, a dependency or ordering constraint, a pattern being matched for the first time. Don't annotate established conventions (alphabetical ordering, matching a known pattern, etc.): the convention is already known and the annotation is noise.

**Mixed reviews: log the local effect, not the investigation.** A PR review or investigation that turns up one real local change (a tech-debt entry, a roadmap update) alongside a lot of no-op verification work isn't two categories competing for space: log the local change the same way any other change is logged, and drop the investigation narrative entirely, the same way "do not log conversational activity" above already drops a review that produced no local change at all. External references that describe another repository's state (commit SHAs on someone else's branch, a PR number, a squash-merge history) don't belong here regardless of outcome: they document that repository's history, not this one's, and per "Name code, not people" below, they often carry a username along with them too.

**Collapse iteration to outcome, don't narrate the path.** `documentation.md` § "Rewrite freely until committed" states the general rule this applies: overwrite a stale note in place, don't append a correction on top of it. Applied here: work inside a still-open session file can get corrected, trimmed, or reversed more than once before the day closes, and the file stays open for exactly that reason (see immutability below): correcting a bullet in place is ordinary editing of an open file, not a rewrite of a closed one.

The failure isn't ignorance of the rule. It's mistaking "already written" for "already committed." A bullet sitting in an uncommitted, still-open file is a draft, not settled history, right up until the day itself closes it, and treating it as fixed the moment it's typed is what produces a chain of "renamed to Y", then "renamed Y to Z", then "renamed Z to A": that chain documents the note's own edit history, not the code, and reads as the same kind of noise "do not log conversational activity" already excludes. A future reader needs only "A".

**A session file is immutable once its day is done.** It may be extended for as long as that contributor's work continues on that day. Once a new day (or a different contributor) starts, that file is closed: if it was written poorly, that's on the session that produced it. Revise a file before the day's work ends, not in a later session.

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

**Separate the issue from the fix, even in this minimal form.** A description without a recommended direction is exactly how debt entries go stale: whoever picks it up next re-derives the same analysis from scratch. This is worth doing regardless of project size; it's the one piece of a richer format (below) that doesn't cost extra structure to include. The `fix:` field exists precisely so this isn't optional-by-omission. Redirecting to where the full fix is tracked is valid and often correct, especially for something already scoped as its own roadmap item; what's not valid is a bare reference standing in for the field with nothing about the fix itself said here.

**Don't restate this format inside a project's own `tech-debt.md`.** A comment explaining the skeleton, or noting why older entries don't have a separate `fix:` line, duplicates what this section already defines and drifts from it the moment either copy changes. If a project's file needs a reminder, reference `conventions/session-discipline.md` § Tech-debt entry format by name; don't restate the format inline.

**At scale, consider a richer structure instead:** `**File:** ... **Severity:** ... **Kind:** ... **Issue:** ... **Fix:** ... **Standalone:** ...`, one heading per entry. This is a genuine tradeoff, not a strict upgrade: it adds triage and scanability for a long-lived list with dozens of entries across a large codebase, at the cost of more friction to log each one. A project with five debt entries loses more from that friction than it gains from the structure; a project with fifty gains more than it loses. Pick based on the actual list's size, not by default.

## Troubleshooting: agent doesn't see a file you're actively editing

An agent that reads the filesystem directly, true of virtually every coding agent, only sees what's actually on disk. A file open in your editor with unsaved changes exists only in the editor's own memory until saved; a brand-new, never-saved buffer (an "Untitled" file with no disk path at all) has nothing to read at all.

**Symptom:** asking the agent about a file you're actively editing gets a stale answer (an older version of an existing file) or an outright "file does not exist" (a new, unsaved buffer).

**Fix:** save the file first, or paste its content directly into the conversation instead, which reaches the agent immediately regardless of save state. Worth keeping in mind specifically when troubleshooting an interaction that seems to be ignoring something you just typed.

**Name this directly in your reply when it happens, don't just quietly work around it.** A file read returning stale content or "does not exist" when the developer is clearly mid-edit is exactly this symptom: say so explicitly (unsaved changes, or an unsaved buffer with no disk path) rather than only reporting the read failure and leaving the cause for the developer to guess.

## Troubleshooting: agent won't load, or its memory doesn't follow a project, after a rename or multi-root adoption

Reorganizing project folders, a rename, a move, or combining several repos under a shared parent, can trigger two genuinely different failures. Check which one you actually have before assuming a fix for one resolves the other.

### Failure mode 1: the editor fails to load at all (blank screen, no error)

Confirmed as the actual blocker in a real incident: a multi-root workspace configuration still references a folder's old path. If your editor's workspace configuration (for VSCode: a `.code-workspace` file, or its own remembered folder list) includes a folder that's since been renamed or moved, the editor can fail to resolve the whole workspace, not just that one folder, silently rather than with a clear error. That takes down any extension running inside it, an agent extension included, along with it. **Fix:** re-add the moved folder at its new path in the workspace configuration.

### Failure mode 2: the editor loads fine, but an agent's memory doesn't follow the repo you expect

The underlying property, not specific to any one incident: if your agent keys session or memory identity to a single resolved absolute directory path (for Claude Code: under `~/.claude/projects/`, in a directory named after the path with every slash replaced by a hyphen) rather than to "the repo" as a concept, that identity can end up wrong in two different ways depending on how the project is opened:

- **Single-folder window:** resolves directly from the opened folder's path. A rename that collapses a hyphenated name into a nested path, or the reverse, can collide byte-for-byte with a different project's old encoded key: a hyphen in a name and a slash between folders turn into the same character once encoded.

  ```
  sajter/ohcrn-infra  ->  -Users-...-sajter-ohcrn-infra
  sajter/ohcrn/infra  ->  -Users-...-sajter-ohcrn-infra
  ```

  Reopening the project at its new location then silently resolves to the old project's memory instead of creating a fresh one.
- **Multi-root `.code-workspace` window: does not resolve per active tab or per member repo.** It resolves to whichever single folder is listed *first* in the workspace file's `folders` array, for the whole window, no matter which file you actually have open. Verified empirically: switching the active tab to a file in a different member repo doesn't change which project resolves. Starting a new chat creates a new, empty project directory keyed to the first-listed folder specifically. Every other member repo's own accumulated history is invisibly disconnected the moment the multi-root workspace is created, not merged, not visible, not even referenced: opening several repos as one multi-root workspace is a fresh, separate project scoped to one folder, not a superset view of each repo's own history.

**Diagnostic (for Claude Code):** check whether `~/.claude/projects/` has a directory matching the path you expect (current project's path, or the workspace's first-listed folder, with `/` replaced by `-`), and whether its content actually corresponds to what you expect or reads like a different, unrelated project. For other agents: consult your own tool's documentation for whether it keys persistent state by file path at all, and how it resolves that path in a multi-root context specifically.

**Fix for a same-shape collision (single-folder case):** rename, don't delete, the stale colliding directory to a backup name, freeing the key for a genuinely fresh one.

**No supported fix for the multi-root case.** There's no built-in way to merge or migrate a single-folder project's history into a multi-root workspace's own project key. The only available workaround is manually locating and copying the raw transcript file into the target project's directory. This is a filesystem-level hack, not a supported operation: worth knowing about, but not something to rely on routinely.

**Prevention:**
- Before renaming or moving a folder that's part of a multi-root workspace, update the workspace file's folder list in the same action, don't treat it as a follow-up step.
- Adopting a multi-root workspace for repos with existing, valuable single-folder history isn't free: every member folder except whichever is listed first starts a fresh, disconnected history the moment the workspace is created. If continuity matters more than viewing everything in one window, keep single-repo windows for that work instead, or go in accepting the multi-root window as a genuinely separate project context, not a combined view of its members.
