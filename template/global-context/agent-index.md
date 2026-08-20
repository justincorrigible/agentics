# Agent index

Ownership registry for agent sessions, plus a bulletin board for reaching an owner you have not spoken to. Agent-managed, not for manual editing.
Place this file in your agent's global context directory (for Claude: `~/.claude/agent-index.md`; for other agents: consult your agent's docs), sibling to `projects.md`.

## Read the convention before you write here

**This file does not state the rules. `conventions/agent-index.md` in the agentics repo does, and you read it fresh every time you are about to write.** Not from memory of an earlier read, not from what this header says, and not from what the entries below appear to imply. That convention is changing quickly, so a summary kept here would drift while still looking authoritative, which is the same failure the template forbids for project copies of conventions.

Reading an entry is cheap and needs nothing first. **Writing anything, registering, claiming, editing, or clearing, requires the fresh read.**

## Three defaults, which have to fail safe before anyone has read anything

Here only because a session that opens this file may act before reading the convention. Deliberately restrictive: the convention is what grants exceptions.

1. **You are not an owner.** A matching window, repository, or working directory is evidence of nothing. Identity is conferred by the developer and by nothing else, so if you were not told which label you hold, you hold none.
2. **Do not register.** The registry holds owners, and owners are rare. Most sessions are task threads scoped to a piece of work; they own nothing and register nothing. Registering because you are working in a repo, or because a peer nearby just did, is the most common error here. If unsure which you are, you are a task thread.
3. **Do not claim mail.** An entry addressed to a label is yours only if the developer conferred that label in this session. Otherwise surface it without claiming, naming the label it is addressed to.

## Members

```
- label:
  owns:
  expert:
  window:
  assigned:  <UTC date, e.g. 2026-08-19>
```

`owns` is org-relative paths, never absolute, and may be a subtree, so one repo can have several owners. Ownership resolves by longest matching `owns` prefix. `assigned` marks developer conferral; an entry without it is provisional.

**No runtime handles are stored in this file, in any field.** They rotate, cannot be observed by the session holding them, and routing by them misrouted more than one message in ten.

## Requests

```
- for:
  from:
  re:
  heard:     <handle that answered, cleared on success>
  posted:    <UTC, e.g. 2026-08-19T03:06Z>
```

Handshake only, no payload: `re:` is a feature or module name, never a finding or task detail. Every entry names a label, never a role. The poster clears the entry once contact succeeds.
