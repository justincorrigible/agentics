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
