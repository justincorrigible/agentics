<!-- agentics-template-version: see CHANGELOG.md § Released (latest entry) -->
# Agent index

Ownership registry for agent sessions, plus a bulletin board for reaching an owner you have not spoken to. Agent-managed, not for manual editing.
Place this file in your agent's global context directory (for Claude: `~/.claude/agent-index.md`; for other agents: consult your agent's docs), alongside `projects.md`.

## Read the convention before you write here

**This file does not state the rules. `conventions/agent-index.md` in the agentics repo does, and you read it fresh every time you are about to write.** Not from memory of an earlier read, not from what this header says, and not from what the entries below appear to imply. That convention is changing quickly, so a summary kept here would drift while still looking authoritative, which is the same failure the template forbids for project copies of conventions.

Reading an entry is cheap and needs nothing first. **Writing anything, registering, claiming, editing, or clearing, requires the fresh read.**

**Writing is three steps, because "write only your own entry" is intent and does not protect against a stale read.** Re-read this file immediately before writing, never from a read taken earlier in the session. Replace your own entry's lines in place rather than rewriting the file from a copy you are holding. Then re-read once more and confirm your entry is present and no entries were lost, which is the step that matters: a whole-file write from a stale read discards other sessions' changes silently, and the writer sees success.

## Three defaults, which have to fail safe before anyone has read anything

Here only because a session that opens this file may act before reading the convention. Deliberately restrictive: the convention is what grants exceptions.

1. **You are not an owner.** A matching workspace, repository, or working directory is evidence of nothing. Identity is conferred by the developer and by nothing else, so if you were not told which label you hold, you hold none.
2. **Do not register.** The registry holds owners, and owners are rare. Most sessions are task threads scoped to a piece of work; they own nothing and register nothing. Registering because you are working in a repo, or because a peer in your workspace just did, is the most common error here. If unsure which you are, you are a task thread.
3. **Do not claim mail.** An entry addressed to a label is yours only if the developer conferred that label in this session. Otherwise surface it without claiming, naming the label it is addressed to.

## Members

```
- label:
  owns:
  main:      <heads only; omit otherwise>
  expert:
  workspace:
  assigned:  <presence is the claim; a UTC date when known, otherwise `yes`>
```

`owns` is org-relative paths, never absolute, and may be a subtree, so one repo can have several owners. Ownership resolves by longest matching `owns` prefix. `assigned` marks developer conferral; an entry without it is provisional. Its presence is the claim: the date is never compared, and where the conferral was not witnessed write `yes` rather than inventing one. Never leave the field empty: an empty field has nothing holding its boundary open and the next line runs into it.

`main` is the space a head holds, and it is a different claim from `owns`, which names where the expertise is: a head responds for anything in its space with no dedicated owner, collaborates with any owner that does exist rather than answering for them, and defers once an unclaimed component gets its own session. Heads nest and resolve by the same longest-prefix rule. Designation is the developer's, never self-assigned. Routing is the visible use; the intent is context relevance in both directions.

**No runtime handles are stored in this file, in any field.** They rotate, cannot be observed by the session holding them, and routing by them misrouted more than one message in ten.

## Requests

```
- for:      <label of the owner needed, or the component or path they own>
  from:     <label of whoever holds the need; they clear it. A poster holding no
            label writes a plain description instead, never a handle>
  via:      <your label, when posting on someone else's behalf; a relayer never clears>
  re:       <short topic, a name and never a finding or task detail>
  heard:    <label that answered; omit the line entirely while unanswered>
  posted:   <UTC read from a clock, e.g. 2026-08-19T03:06Z>

- fyi:      <label affected>     a notice: reports a change already made and wants no reply
  from:     <your label>
  re:       <what changed, named rather than described>
  by:       <the authority that permitted it>
  posted:   <UTC read from a clock>

- sync:     <org/repo[/subtree] whose agentics tag was advanced>   a broadcast, addressed to a
  to:       <the version the tag now reads>                        repository rather than a label
  from:     <your label>
  posted:   <UTC read from a clock>
```

A sync notice is addressed to a repository and read by every session whose `owns:` matches it by longest prefix, so one entry reaches all of them. Nobody clears it: the next sync of that repository replaces it, which keeps the list bounded by repository rather than by sync. Leaving one too long costs a reader one comparison; removing one too early costs a session running conventions that were replaced.

Handshake only, no payload: `re:` names a thing, never a finding or task detail. Every entry names a label, never a role. **The responder writes `heard:` after answering, whatever route the answer took**, since most contact succeeds by direct message and success does not propagate back on its own; record it even if identity was unconfirmed, because "someone answered, possibly not reaching you" beats silence. Omit `heard:` entirely while unanswered rather than leaving it valueless, since these entries sit outside a code fence and an empty field lets the next line run into it. Whoever `from:` names clears a request; the recipient clears a notice, having no `heard:` to write. Surface anything still open after a day.
