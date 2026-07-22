# Session discipline

## Session-start signals

A session is a work period: not necessarily a new chat thread. Treat the following as session-start signals even mid-thread:

- Greetings: "good morning", "hi again", "hello", "hey"
- Resumption: "let's continue", "back to it", "where were we", "picking this up again"
- Explicit: "new session", "let's get started", "let's kick off"
- On-demand: "sync up", "refresh context", "re-read your instructions"

## Starting a session

On a session-start signal, run this sequence before touching any code:

1. `git log --oneline -1 -- CLAUDE.md AGENTS.md .claude/settings.json`: check whether instruction or configuration files changed since your last session file. Re-read only the files that changed. If `settings.json` changed unexpectedly, read it immediately and verify it contains only the expected hooks before proceeding (see `docs/agent-security.md`). When you re-read a changed file, say: "I've re-read [file]: the prior version in this thread is superseded."
2. Read `.dev/roadmap.md`: check the current focus and any `[in progress]` items. If your global context defines one or more global roadmaps, also read the one relevant to the current project - not all of them. For example: read `roadmap-work.md` for professional projects, `roadmap-personal.md` for personal ones. See `global-context/roadmap.md` for the convention.
3. Read `.dev/tech-debt.md`: note any `standalone: yes` entries relevant to today's work
4. Read the most recent 1-2 files in `.dev/sessions/` for context on recent work and open threads. ISO-formatted filenames sort chronologically, so `ls .dev/sessions | sort | tail -2` finds them without an index file.
5. If your global context has `propagation_suggestions: yes`, or you're an agentics contributor (`agentics_contributor: yes` in your global context) without `agentics_upstream_check: no` set for this project or globally, check whether this project has adopted agentics at all (a tag, or just a mention of agentics in `AGENTS.md`/`CLAUDE.md`) and, if so, check for upstream updates: see `conventions/convention-levels.md` § Checking for upstream updates. A missing or incomplete tag doesn't mean skip it: it means this project needs the tag added, which that section covers. For contributors, this is mandatory and recurs every session for an unresolved gap — don't let it quietly stop repeating just because it went unanswered before.
6. Determine your session file for today: see "Session file identity" below.

**On context efficiency:** re-reading a file mid-thread adds it to context: it does not replace the prior version. Both consume tokens. To stay efficient: only re-read files that actually changed (step 1 tells you which), and explicitly mark the old version superseded. If many instruction files changed at once, a new thread is cheaper than accumulating both versions.

## Keeping `.dev/` current

At session start, before starting new work, do a quick staleness pass on `roadmap.md` and `tech-debt.md`: mark completed items done, close resolved PINNED entries, remove addressed tech-debt entries. This is not a full audit: just enough to prevent documents drifting out of sync with reality.

Update `.dev/roadmap.md` or `.dev/tech-debt.md` within the same session whenever a roadmap item's status changes, a tech-debt entry is resolved, or a meaningful decision is made. These documents are shared memory across sessions: they should reflect current reality, not just initial planning.

Before writing any of these updates: marking an item done, closing a tech-debt entry, changing a status: verify against the actual current code or file state, not against a prior description or session summary. An assumption carried forward unverified is exactly how these documents drift from what they claim.

After any meaningful unit of work: code written, bug fixed, tech-debt logged, roadmap updated, docs changed: add or extend the dated entry in your session file (see "Session file identity" below). Do not wait for an explicit "session over" signal: work rarely ends cleanly, and the update will be missed if it depends on one.

Do not log conversational activity: PR reviews that produced no local changes, discussions, waiting states. These are not session-log material. A real example of what this looks like when it slips through: "Asked whether other projects' agents would actually see today's changes: no, not yet, since nothing here is committed or pushed." A question, an answer, no decision and no local change, zero value to a future reader, exactly the shape to catch before it's written, not after. See "Session file entry format" below for the mixed case: a review that also produced one real local change.

When `.dev/` documents are updated, remind the developer to commit them. This history matters for avoiding double work across sessions.

**Concrete content, not process or events.** `.dev/roadmap.md` and `.dev/tech-debt.md` hold the substance: a decision, a design topic, a known issue and its fix. They are not a record of who raised something, in which PR, or when a discussion happened; that's process, and it belongs in PR or issue history, not here, the same reasoning "write about effects, not style" applies to session files. A "message format design" entry states the open question and the options, not who tagged whom. This is also where an individual's name most often sneaks in (see "Name code, not people" below): stripping the process narrative removes the attribution risk with it, not as a separate pass.

## Verifying conformance, not just structure

Reading a convention and holding it as an active constraint while generating content several steps later in the same turn are not the same act. A convention's structural example (a field skeleton, a template block) shows shape; matching that shape can happen while missing a separate prose requirement sitting right next to it, a real, observed failure mode (see `CHANGELOG.md` § `verify-conformance-not-structure`).

This matters most producing several governed artifacts in one batch: initialization (`CLAUDE.md`, `AGENTS.md`, tech-debt entries, memory files all at once), a migration, a multi-file update. Before finalizing each artifact, re-read it once against the convention's specific prose requirement, not just against its example shape, as a discrete final step, not a background assumption carried from having read the rule earlier. Verification happens at the point of writing each artifact, not once at the point of reading the rule at the start of the batch.

If a convention's own example under-specifies a requirement stated in prose nearby, that's a defect in the convention worth fixing, not something to route around silently: flag it the same way any other convention gap gets flagged.

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

One lean context sentence (what + why only), a blank line, then one bullet per file or logical group of changes. No date header inside the file: the filename already carries it. No prose paragraphs. No "Next:" line: open work belongs in `roadmap.md`. The separator in bullets is `: ` (colon-space). Do not use em dashes (`—`) or a space-hyphen-space (` - `) as a connector; both are the same anti-pattern in different characters. See code-style.md § Dashes for the full list and the absolute rule (no conversational-chat exemption).

```
[One sentence: what the work was and why.]

- `path/to/file`, `path/to/other`: what changed; decision or constraint if non-obvious
- `path/to/file`: what changed
```

**What to include in the context sentence:** what the work was and why it was done. Omit incidental context (which cluster was available, what else was happening): lean enough to read at a glance.

**Write about effects, not style.** Describe what the code now does or enables - the practical outcome for operators, users, or callers. Do not describe how the code was written: style choices, refactoring approach, helper names, and implementation details are not session log material. "Operators now see actionable error messages" belongs; "rewrote using positive conditions and pure helpers" does not.

**What to include in bullets:** decisions or constraints only when non-obvious: a choice between alternatives, a dependency or ordering constraint, a pattern being matched for the first time. Don't annotate established conventions (alphabetical ordering, matching a known pattern, etc.): the convention is already known and the annotation is noise.

**Mixed reviews: log the local effect, not the investigation.** A PR review or investigation that turns up one real local change (a tech-debt entry, a roadmap update) alongside a lot of no-op verification work isn't two categories competing for space: log the local change the same way any other change is logged, and drop the investigation narrative entirely, the same way "do not log conversational activity" above already drops a review that produced no local change at all. External references that describe another repository's state (commit SHAs on someone else's branch, a PR number, a squash-merge history) don't belong here regardless of outcome: they document that repository's history, not this one's, and per "Name code, not people" below, they often carry a username along with them too.

**Collapse iteration to outcome, don't narrate the path.** Work inside a still-open session file can get corrected, trimmed, or reversed more than once before the day closes; when that happens, edit the existing bullet to reflect where things ended up, don't append a new bullet describing the correction on top of the old one. A future reader needs the destination, not the sequence of wrong turns that reached it: "trimmed the wording to lead with the general principle" is true now; "reworded, found still too narrow, reworded again, found too verbose, trimmed again" is the process that produced that, and reads as the same kind of noise "do not log conversational activity" already excludes. This is exactly what the file staying open for the rest of the day is for (see immutability below): correcting a bullet in place is ordinary editing of an open file, not a rewrite of a closed one.

**A session file is immutable once its day is done.** It may be extended for as long as that contributor's work continues on that day. Once a new day (or a different contributor) starts, that file is closed: if it was written poorly, that's on the session that produced it. Revise a file before the day's work ends, not in a later session.

**Exception: a Critical Constraint violation overrides immutability.** An ordinary quality problem (rambling prose, an unnecessary narrative, a missing detail) stays as the honest record of the mistake, on principle. A violation of one of this project's Critical Constraints found inside a closed file, most commonly an individual's name or a credential, is a different tier of problem: fix it in place regardless of which day produced it, the same way you'd scrub a leaked credential out of an old commit rather than leave it because "that commit is history." Immutability protects against a later session quietly rewriting an earlier one's judgment calls; it was never meant to protect a Critical Constraint violation from being corrected.

**Name code, not people.** Attribute work to features, modules, and systems, not to individuals: "the network module", not "Jon's network module". This applies to session files, tech-debt entries, docs, and any other persisted content. Attribution belongs in git history (and, per "Session file identity" above, in filenames when it matters), not in what you write.

## Tech-debt entry format

```
[short description of the issue]
fix: [what the fix actually is, in one sentence, even if the full detail lives elsewhere: a roadmap item, a design doc, a linked issue. Pointing elsewhere for depth is fine; a pointer with no inline substance is not]
standalone: yes | no
context: [roadmap item reference or brief note: required when standalone: no]
```

`standalone: yes`: can be picked up freely without reading other context.
`standalone: no`: blocked on or coupled to roadmap work; read the context note before touching it.

**Don't log an entry that never outlives the session.** Tech-debt entries exist to carry a still-open issue into future sessions. If an issue is found and fixed before the same session's file closes, it never reaches that state: fixing it is ordinary work, not debt, so log the fix itself as a normal session-file change and skip `tech-debt.md` entirely. Adding an entry only to remove it again within the same file produces a "created, then resolved" bullet that documents the entry's own lifecycle instead of any effect a reader would care about, the same process-not-substance shape "Concrete content, not process or events" above already excludes.

**Separate the issue from the fix, even in this minimal form.** A description without a recommended direction is exactly how debt entries go stale: whoever picks it up next re-derives the same analysis from scratch. This is worth doing regardless of project size; it's the one piece of a richer format (below) that doesn't cost extra structure to include. The `fix:` field exists precisely so this isn't optional-by-omission. Redirecting to where the full fix is tracked is valid and often correct, especially for something already scoped as its own roadmap item; what's not valid is a bare reference standing in for the field with nothing about the fix itself said here.

**Don't restate this format inside a project's own `tech-debt.md`.** A comment explaining the skeleton, or noting why older entries don't have a separate `fix:` line, duplicates what this section already defines and drifts from it the moment either copy changes. If a project's file needs a reminder, reference `conventions/session-discipline.md` § Tech-debt entry format by name; don't restate the format inline.

**At scale, consider a richer structure instead:** `**File:** ... **Severity:** ... **Kind:** ... **Issue:** ... **Fix:** ... **Standalone:** ...`, one heading per entry. This is a genuine tradeoff, not a strict upgrade: it adds triage and scanability for a long-lived list with dozens of entries across a large codebase, at the cost of more friction to log each one. A project with five debt entries loses more from that friction than it gains from the structure; a project with fifty gains more than it loses. Pick based on the actual list's size, not by default.
