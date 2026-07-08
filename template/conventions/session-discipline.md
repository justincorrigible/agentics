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
5. Determine your session file for today: see "Session file identity" below.

**On context efficiency:** re-reading a file mid-thread adds it to context: it does not replace the prior version. Both consume tokens. To stay efficient: only re-read files that actually changed (step 1 tells you which), and explicitly mark the old version superseded. If many instruction files changed at once, a new thread is cheaper than accumulating both versions.

## Keeping `.dev/` current

At session start, before starting new work, do a quick staleness pass on `roadmap.md` and `tech-debt.md`: mark completed items done, close resolved PINNED entries, remove addressed tech-debt entries. This is not a full audit: just enough to prevent documents drifting out of sync with reality.

Update `.dev/roadmap.md` or `.dev/tech-debt.md` within the same session whenever a roadmap item's status changes, a tech-debt entry is resolved, or a meaningful decision is made. These documents are shared memory across sessions: they should reflect current reality, not just initial planning.

After any meaningful unit of work: code written, bug fixed, tech-debt logged, roadmap updated, docs changed: add or extend the dated entry in your session file (see "Session file identity" below). Do not wait for an explicit "session over" signal: work rarely ends cleanly, and the update will be missed if it depends on one.

Do not log conversational activity: PR reviews that produced no local changes, discussions, waiting states. These are not session-log material.

When `.dev/` documents are updated, remind the developer to commit them. This history matters for avoiding double work across sessions.

## Session file identity

Each session's log lives in its own file under `.dev/sessions/`, keyed by contributor and day rather than one shared file. This is what prevents merge conflicts when several people work the same project the same day: different contributors never edit the same file.

**Filename:** `YYYY-MM-DDTHHMMSS.md`, generated once, the first time the file is created. No descriptive slug: the timestamp's job is uniqueness, not readability. A slug forces a choice between short-and-collision-prone or long-and-unwieldy, and doesn't add anything a directory listing plus the file's own content doesn't already give you.

**Finding your file for today:**
1. List files in `.dev/sessions/` matching today's date prefix.
2. For each match, check authorship: if it's committed, compare `git log -1 --format=%ae -- <file>` against `git config user.email`. If it's uncommitted in the working tree, it's yours by definition: no one else's uncommitted file can be present in your clone.
3. If a match is yours, that's your session file for today: extend it. Otherwise, create a new file with the current timestamp.

This gives at most one file per (day, contributor) pair, not one per session: picking work back up later the same day extends the same file rather than creating a new one.

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

**A session file is immutable once its day is done.** It may be extended for as long as that contributor's work continues on that day. Once a new day (or a different contributor) starts, that file is closed: if it was written poorly, that's on the session that produced it. Revise a file before the day's work ends, not in a later session.

**Name code, not people.** Attribute work to features, modules, and systems, not to individuals: "the network module", not "Jon's network module". This applies to session files, tech-debt entries, docs, and any other persisted content. Attribution belongs in git history (and, per "Session file identity" above, in filenames when it matters), not in what you write.

## Tech-debt entry format

```
[short description of the issue]
standalone: yes | no
context: [roadmap item reference or brief note: required when standalone: no]
```

`standalone: yes`: can be picked up freely without reading other context.
`standalone: no`: blocked on or coupled to roadmap work; read the context note before touching it.
