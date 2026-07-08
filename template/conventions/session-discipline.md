# Session discipline

## Session-start signals

A session is a work period: not necessarily a new chat thread. Treat the following as session-start signals even mid-thread:

- Greetings: "good morning", "hi again", "hello", "hey"
- Resumption: "let's continue", "back to it", "where were we", "picking this up again"
- Explicit: "new session", "let's get started", "let's kick off"
- On-demand: "sync up", "refresh context", "re-read your instructions"

## Starting a session

On a session-start signal, run this sequence before touching any code:

1. `git log --oneline -1 -- CLAUDE.md AGENTS.md .claude/settings.json`: check whether instruction or configuration files changed since the last `sessions.md` entry. Re-read only the files that changed. If `settings.json` changed unexpectedly, read it immediately and verify it contains only the expected hooks before proceeding (see `docs/agent-security.md`). When you re-read a changed file, say: "I've re-read [file]: the prior version in this thread is superseded."
2. Read `.dev/roadmap.md`: check the current focus and any `[in progress]` items. If your global context defines one or more global roadmaps, also read the one relevant to the current project - not all of them. For example: read `roadmap-work.md` for professional projects, `roadmap-personal.md` for personal ones. See `global-context/roadmap.md` for the convention.
3. Read `.dev/tech-debt.md`: note any `standalone: yes` entries relevant to today's work
4. Read `.dev/sessions.md`: last 1-2 entries give context on recent work and open threads

**On context efficiency:** re-reading a file mid-thread adds it to context: it does not replace the prior version. Both consume tokens. To stay efficient: only re-read files that actually changed (step 1 tells you which), and explicitly mark the old version superseded. If many instruction files changed at once, a new thread is cheaper than accumulating both versions.

## Keeping `.dev/` current

At session start, before starting new work, do a quick staleness pass on `roadmap.md` and `tech-debt.md`: mark completed items done, close resolved PINNED entries, remove addressed tech-debt entries. This is not a full audit: just enough to prevent documents drifting out of sync with reality.

Update `.dev/roadmap.md` or `.dev/tech-debt.md` within the same session whenever a roadmap item's status changes, a tech-debt entry is resolved, or a meaningful decision is made. These documents are shared memory across sessions: they should reflect current reality, not just initial planning.

After any meaningful unit of work: code written, bug fixed, tech-debt logged, roadmap updated, docs changed: add or extend the dated entry in `sessions.md`. Do not wait for an explicit "session over" signal: work rarely ends cleanly, and the update will be missed if it depends on one.

Do not log conversational activity: PR reviews that produced no local changes, discussions, waiting states. These are not `sessions.md` material.

When `.dev/` documents are updated, remind the developer to commit them. This history matters for avoiding double work across sessions.

## sessions.md entry format

One lean context sentence (what + why only), a blank line, then one bullet per file or logical group of changes. No prose paragraphs. No "Next:" line: open work belongs in `roadmap.md`. The separator in bullets is `: ` (colon-space). Do not use em dashes (`—`) or a space-hyphen-space (` - `) as a connector; both are the same anti-pattern in different characters. See code-style.md § Dashes for the full list and the absolute rule (no conversational-chat exemption).

```
## YYYY-MM-DD

[One sentence: what the work was and why.]

- `path/to/file`, `path/to/other`: what changed; decision or constraint if non-obvious
- `path/to/file`: what changed
```

**What to include in the context sentence:** what the work was and why it was done. Omit incidental context (which cluster was available, what else was happening): lean enough to read at a glance.

**Write about effects, not style.** Describe what the code now does or enables - the practical outcome for operators, users, or callers. Do not describe how the code was written: style choices, refactoring approach, helper names, and implementation details are not session log material. "Operators now see actionable error messages" belongs; "rewrote using positive conditions and pure helpers" does not.

**What to include in bullets:** decisions or constraints only when non-obvious: a choice between alternatives, a dependency or ordering constraint, a pattern being matched for the first time. Don't annotate established conventions (alphabetical ordering, matching a known pattern, etc.): the convention is already known and the annotation is noise.

**sessions.md is ordered newest-to-oldest:** each new dated entry goes at the top of the file. Within a dated entry, bullets are added in order at the bottom. Only today's entry is open for editing during the current session. Prior entries are immutable historical record: if a past entry was written poorly, that is on the session that produced it. Revise an entry before the session ends, not in a later one.

## Tech-debt entry format

```
[short description of the issue]
standalone: yes | no
context: [roadmap item reference or brief note: required when standalone: no]
```

`standalone: yes`: can be picked up freely without reading other context.
`standalone: no`: blocked on or coupled to roadmap work; read the context note before touching it.
