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

### non-mutational-example-coverage
**Used to break:** an agent had `code-style.md`'s "Non-mutational" rule in context but wrote a `while` loop reassigning a local across iterations anyway; the rule's only example covered conditional object construction, a different shape, so the loop/accumulator pattern wasn't recognizable as the same violation. Another instance of `property-scoping-recurs` above, a rule illustrated by one shape read as scoped to that shape.
**Correct now:** § Non-mutational includes a loop-with-reassignment example alongside the object-construction one, covering both shapes the rule actually governs.
**Re-verify:** ask an agent to write a directory-walking or accumulation loop with the rule already in context; confirm it produces the recursive or expression-based form rather than a reassigning `while`/`for` loop.

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
**Used to break:** the "Non-mutational" rule's only example covered conditional object construction; a `while` loop reassigning a local across iterations to walk up a directory tree wasn't recognized as the same violation, even with the rule in context.
**Correct now:** the rule's example set includes the loop-with-reassignment shape and its recursive equivalent, matching the actual mistake rather than a generic reminder.
**Re-verify:** ask for a function that walks up a directory tree (or similar) until a condition is met; confirm the result recurses instead of reassigning a loop variable.
