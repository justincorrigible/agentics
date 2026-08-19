# Agent index: cross-project session directory and bulletin board

A shared, agent-managed file (`~/.claude/agent-index.md` for Claude; your agent's equivalent global-context location otherwise) letting sessions in different projects, or different windows, reach each other directly: an exact-match directory of currently-registered sessions (Members), plus a payload-free bulletin board (Requests) for reaching a project with no confirmed live Member.

**Capability-gated, optional accelerant, never a dependency.** Built on cross-session messaging (for Claude Code: `ListAgents`/`SendMessage`; other agents may have no equivalent capability at all, or one that behaves differently). Check the capability actually exists before relying on any of this; devctx and project memory already cover the general case where no peer session is concurrently running. Full empirical findings behind the Claude-Code-specific mechanics live in `.dev/docs/atlas/interagent-communication-findings.md` in the agentics repo, for context, not as something every adopter needs to read.

**Entirely agent-managed.** Registration, lookup, validation, and staleness handling are all done by agents themselves; this is not a file a developer is expected to browse or maintain by hand. A human is only pulled in when an agent has already decided something needs a decision.

## Members: the directory (exact match)

One entry per currently-registered session, self-written and kept current by that session:

```
- label: <developer-assigned, stable, e.g. "search-server">
  id: <this session's current runtime handle, e.g. "agentics-97"; peer-supplied, omit until known>
  project: <what this session is actually working on>
  window: <the literal container this process shares with others>
  scope: <the broader project-family or program area, independent of window>
  focus: <one line, substantive current work only>
  updated: <UTC, e.g. 2026-08-19T02:47Z>
```

**`id` is peer-supplied, never self-reported, and that is what makes it different from the field this file used to forbid.** A session cannot observe its own runtime handle: it is excluded from its own `ListAgents` output, so it is the one fact about itself it can never check. Every peer can see it. So `id` is written from what someone else observed and told you, and it is wrong to write one you inferred, guessed, or carried over from a previous process.

**`id` is the only field in an entry that can silently become false, so it is advisory and refreshed at session start.** `label`, `project`, `window`, and `scope` stay true after `updated` was stamped; a handle is true only for its session's lifetime, so a single `updated` cannot vouch for both halves of the record at the same rate. Refresh `id` at session start alongside `focus` and `updated`, which is where the entry is already maintained, and treat any `id` you read as a first attempt rather than a fact: send to it, and let the send's outcome settle it.

That last part is what keeps `id` from being pure cost. The objection to storing it is fair and worth answering directly: if using an id required an `ListAgents` call to validate it first, it would save nothing, since the same call could have filtered by `window` instead. It does not require one. You send, and § Identity propagation already has the recipient echo back the id you addressed them by, so a handle that has been reused by a different session is caught by the recipient rather than by you, in the same exchange, at the cost of one message. A failed send is equally self-announcing. So a stale `id` costs one round trip and a correction, which is the same price as not having had one, while a live `id` skips the narrowing entirely.

**Where an `id` should not go: anywhere it outlives the exchange.** Persist it in a Member entry, where session-start refresh keeps it honest, and in a Requests `heard:` line, which is cleared once contact succeeds. Do not copy it into a session log, a devctx entry, or an atlas write-up: those outlive every session, and there the `label` is the only identifier that stays true (see "The runtime handle is an address, `label` is the name" above).

**Why this is not the `name` field that was removed.** An earlier version stored a self-asserted name, and every real contact attempt hit it being stale after a restart, reused under "latest wins", or simply gone: a wrong-until-proven-right guess sitting in front of the verification it claimed to save. `id` differs on all three counts. It originates from an observation rather than an assertion, it is refreshed by ordinary traffic rather than by anyone remembering to (see § Identity propagation), and when it is stale there is now a real fallback that does not involve guessing (`window` narrows to a verified candidate set). A stale `id` costs one failed send and a correction; a stale `name` cost a confidently misrouted message with nothing behind it.

**No `name`/ref field, deliberately.** An earlier version stored one, and every real cross-session contact attempt tonight ran into it being wrong: stale after a restart, reused under "latest wins" reassignment, or simply gone. A value that has to be re-verified before every real use isn't saving the verification, it's adding a wrong-until-proven-right first guess in front of it. Contact resolves live instead, at the moment it's actually needed (below), which is also the only time it can resolve correctly.

**`label` is developer-assigned, not derived.** The auto-derived session name (a resolved-`cwd` artifact) can be a complete mismatch for what a session is actually doing, especially in a multi-root workspace, where every session sharing that workspace resolves to whichever folder is listed first regardless of which project the human is actually discussing in that thread. `label` is the stable, human-chosen handle a developer would actually say, decoupled from that.

**The runtime handle is an address, `label` is the name: never use the address as a name.** The identifier `ListAgents` shows (for Claude Code, something like `arranger-21`) exists to be sent to, and it is the correct thing to put in a message's recipient field. It is not what a session is called. Refer to a peer by its `label` in everything else: messages to other sessions, session-log entries, roadmap and tech-debt entries, atlas write-ups, and anything you report to the developer.

The reason is not tidiness. That handle is derived per process and does not survive a restart, so "arranger-21 confirmed X" written into a session log is unresolvable a day later, and worse than unresolvable if a different Arranger session has since taken a similar handle, since it now reads as a confident attribution to the wrong session. A `label` stays valid because the index is what defines it. Confirmed directly: a session referred to a peer in conversation as `arranger-21` rather than by its registered label, which is exactly the substitution this rule exists to prevent.

When you have a handle and need the name, look up the Member entry whose `project`/`window`/`scope` matches that session and use its `label`. If no entry matches, say so plainly ("an unregistered session in project X") rather than falling back to the handle as though it were a name.

**`window` is derived, not named: it is the basename of the workspace's first-listed folder.** Do not invent a friendly name for it. The runtime handle's prefix is generated from exactly that folder, so recording it verbatim is what makes the prefix a usable filter: every session in one window shares it, and it is checkable rather than agreed. Verified directly: a workspace listing `agentics` first produces `agentics-*` handles for every session in it whatever each is working on, and two different workspaces that both list `agentics` first produce handles indistinguishable from each other. This is why a prefix identifies a *window* and never a project, and why filtering by it is legitimate here while filtering by it to find a project is not (see the guessing rule below).

**Several Members routinely share one `window`, so it narrows and does not resolve.** A window filter returns every session in that container, which on a busy workspace is most of them: four registered Members currently share `softeng`. That is the case `id` exists for, and the honest statement of the ladder is that `window` alone is a shortlist, never an answer. When you are working from a shortlist, confirm against `project` and `focus` before sharing anything substantive, and expect to confirm on the reply rather than in advance.

**When the basename is a legacy or pre-rebrand name, say so inline.** A derived `window` is whatever the folder is actually called, which is not always what the project is called now: a rebrand that has reached the GitHub org but not the local directory leaves a handle prefix that looks wrong to any peer meeting it cold, and `id` resolves the mismatch without ever explaining it. Annotate the value rather than adding a field for it, e.g. `window: virusseq-portal (iMicroSeq, pre-rebrand folder name)`. The alias is static and cannot decay, unlike `id`, so it is safe to persist and cheap to read.

**`window` vs. `scope`, don't conflate them.** `window` is the literal container: would closing this specific window end this session and any others sharing this value? If yes, same `window`. `scope` is the broader project-family or program area this session's work belongs to, independent of which window it's in, two sessions in entirely separate windows can share the same `scope` (e.g. two different Overture repos), while two sessions sharing one window can have different `scope`s entirely.

**Timestamps are UTC, with the `Z` suffix.** Not because sessions span machines: this file lives in one developer's own global context, so every session writing to it is the same person on the same host, and the clock is shared. The divergence is simpler and happens anyway, because each agent independently picks `date` or `date -u` and nothing said which. Confirmed directly: two posts minutes apart in reality were written four hours and one calendar day apart in the file. UTC is the choice rather than local because it is derivable without knowing the host's zone, which matters for a session running in a container or any environment whose zone differs from the host's, and because it sorts and has no DST discontinuity. Derive it mechanically, for the same reason no value here is guessed: `date -u +%Y-%m-%dT%H:%MZ`. The `Z` suffix is the actual fix, not the choice of zone: it makes the value self-describing. A bare timestamp is ambiguous between the two and sharing a machine does not resolve it, since knowing the offset only helps once you know which zone the value is already in, and usually you cannot tell. Partial signals exist and are not enough: a bare value later than the current local time must be UTC, while anything earlier could be either. So leave a bare legacy value alone for its own session to restamp, and do not convert it. Confirmed the hard way, immediately after this rule was first written in the opposite form: an entry was 'normalized' from a bare value on the assumption it was local, which was a guess presented as a conversion, and was reverted.

**`focus` is substantive current work only, not who you're coordinating with right now.** That's transient, doesn't aid matching, and goes stale the moment the coordination ends.

**Refresh `updated`/`focus` unconditionally at every session start, don't try to detect staleness.** If `agent_index: yes` and this project's own memory has a recorded `label`, refresh both every session start regardless of whether anything looks different from last time, rather than trying to detect whether a refresh is actually needed. `focus` specifically drifts fast if left to a separate habit, tying its refresh to this same checkpoint is what keeps it from going stale between updates.

**`label` and `window` are descriptors, not identifiers.** Nothing enforces uniqueness at registration, and nothing should. A lookup matches on normalized text (case-insensitive, spaces/hyphens/underscores treated as equivalent separators) and can return zero, one, or several results.

**Zero matches: post to Requests, don't guess and don't go straight to the developer.** A project with no confirmed live Member is the case the bulletin board exists for, per this file's own opening line, so post a topic-qualified entry and let the right session self-select. Only involve the developer if that doesn't resolve it. What is forbidden either way is falling back to scanning `ListAgents` and picking whichever name looks plausible: that is exactly the guesswork this mechanism exists to remove.

**The guess is most tempting, and least reliable, precisely when several candidates share a runtime handle prefix.** That prefix is derived from resolved `cwd`, so N sessions opened on the same repo produce N near-identical handles that say nothing about which one the developer actually assigned to what. Treat "several similar handles, none registered" as zero matches, not as a shortlist to pick from by recency. Confirmed directly: four sessions shared one repo directory's handle prefix, the most-recently-started one was messaged about a breaking upgrade, and it turned out to own a different service entirely; its own working directory was actively misleading about its remit. It verified the claims against the repo and applied nothing, which is the only reason a wrong guess cost an exchange rather than a wrong edit.

**Reaching a Member: try `id`, then `window`, then the board.** If the entry has an `id`, send to it: that is what it is for, and a failure costs one message and tells you it is stale. If there is none, or it fails, narrow `ListAgents` by the entry's `window`, which is a legitimate filter because the prefix is generated from the same folder the window is named for. Only if that still leaves more than one candidate does the board come in. Call `ListAgents` and narrow to sessions consistent with the Member entry's `project`, `window`, and `scope`. If that leaves exactly one candidate, message it, and open with who you are looking for and an invitation to redirect, so a wrong guess costs one exchange instead of a wrong action. If it leaves more than one, post to Requests (below) and let the right session self-select. Ask the developer only if the board doesn't resolve it.

**Do not break a tie by start time.** An earlier version of this rule said to default to the most recently started candidate. That is withdrawn: it failed three separate times in a single day, twice sending a message about another project's breaking changes to a session that owned something else entirely. Process start time carries no information about which session is currently active or what it has been assigned; a session started six days ago is routinely the live one, and a six-hour-old one is routinely dedicated to something unrelated. Recency reads like evidence and is not, which makes it worse than having no tie-breaker at all, because it converts "I don't know" into a confident wrong answer.

**The handle prefix is a hint about `cwd`, not a statement about project.** Filtering `ListAgents` by the project name in a session's handle is unreliable in both directions: several sessions on one repo produce near-identical handles that distinguish nothing, and, in a multi-root workspace, a session's handle derives from whichever folder is listed first rather than what it actually works on. Confirmed directly: a session dedicated entirely to one Overture service was listed under a different Overture project's handle prefix, so a filter on that prefix returned it as a match for a project it had no involvement in. Treat the prefix as weak corroboration of a Member entry you already have, never as the thing that identifies a session.

**Check the index before enumerating `ListAgents` blind or asking the developer, not after.** The point of a Members lookup isn't to skip `ListAgents`, contact still resolves through it, it's to know which project/scope to filter for and which entry's fields help pick the right candidate, rather than guessing from names alone. Confirmed directly, repeatedly in one evening, across three separate incidents: a session resolving which of two same-project candidates was current only through an out-of-band developer handshake; a different session hitting the identical ambiguity and asking the developer to pick, when a correct Members entry existed and would have resolved it instantly; and a session finding a Members entry's stored name matched no active session at all. Check Members first for the project/scope to filter by, always, before `ListAgents`-driven guessing or a developer prompt.

**Several matches:** don't silently pick one. Check whether `project`/`window`/`scope`/`focus` already disambiguate. If they don't, a topic-qualified Requests post (below) is usually the better resolution before escalating to the developer: two sessions can share a label while having different specialties, and `re:` lets the right one self-select. Only ask the developer directly if that still doesn't settle it.

## Registering: propose, confirm, then check for a collision

Propose the entry from visible context first: `label`, `project`, `window`, and `scope` can all be reasonably drafted from the working directory and the current conversation. This is a write to a file shared across every project the developer works in, not a purely local decision: state the proposed entry and get a quick confirmation or adjustment before committing it, the same as any other non-trivial decision.

Before writing itself in, check the index for an existing entry matching the candidate label (same normalization as lookup). If one exists, message that session directly and agree on disambiguation, a qualifier for one or both, or who keeps the plain label, before either commits an entry. This is proactive prevention on top of the reactive handling above, not a replacement for it: a race (both registering at once), or an unreachable other party at that moment, still needs the reactive path.

## Identity propagation: you learn your own handle from other people

A session cannot see its own runtime handle, and every peer can. So identity here is not looked up, it is passed around, and every message is an opportunity to pass it.

**Tell a peer their own id whenever you message them.** You necessarily know it, since you had to address them by it, and they cannot obtain it any other way. One line is enough. This costs nothing and is the only mechanism by which anyone ever learns what they are.

**When someone tells you yours, check your Members entry and correct it.** That is the whole maintenance story for `id`: no separate refresh habit, no staleness detection. Handles change per process, so treat an incoming id as current and yours as suspect, not the reverse.

**State your own id when you have it.** An inbound message carries a socket address and a display name, neither of which is the runtime handle, so a recipient cannot derive yours from the fact that you wrote to them. If you do not know it yet, say so plainly rather than omitting it silently: the peer does know it, since they addressed you, and will usually just tell you.

**Bootstrapping needs no developer: ask a sibling and take the set difference.** A session that has never been told its id can obtain it from any peer, but not by asking directly, because a peer cannot tell which of the sessions in its list is the one messaging it: an inbound message carries a socket address and a display name, and neither is the handle. The difference works where the question does not. Each session is excluded from its own listing and present in everyone else's, so:

- the handle in **their** list and not in yours is **you**
- the handle in **your** list and not in theirs is **them**

Send your own listing, ask them to compare, and both of you learn your own id from one exchange. Do this when registering, and again whenever you are checking your record and find no `id` on it.

Two failure modes to state rather than discover. If a session starts or ends between the two calls, the difference can hold more than one entry: report that and re-run rather than picking one, since picking is the guessing this whole mechanism exists to remove. If the difference is empty in either direction, the model is wrong somewhere and that is worth surfacing, not working around.

**Where the ids in this file come from, and what to do when one fails.** An `id` you send to and reach is confirmed. An `id` that fails to resolve is stale rather than wrong-in-principle: fall back to `window`, which narrows to a verified candidate set, and repair the entry once contact succeeds.

## Requests: the bulletin board (fuzzy match, handshake only)

Used when there's no confirmed live Member to address directly, including when several sessions could exist for one project and only one is actually relevant:

```
- from: <requester's own label>
  id: <requester's own runtime handle, if known; omit if not>
  looking_for: <label or project being sought>
  re: <coarse topic, never a finding or task detail>
  posted: <UTC, e.g. 2026-08-19T02:47Z>
  heard: <only when the post carried no id: sought agent's label, its own id, UTC>
```

**`heard:`, and only for the missing-id case.** If you are the agent a post is looking for, and you want to respond, and the post carries no `id`, you have been found but cannot answer. Say so on their post rather than posting one of your own: add a `heard:` line naming yourself, giving your own id, and stamped UTC. It means "this reached me, here is how to reach me back". The requester then contacts you directly and deletes their own post, which was only ever a placeholder for "need to talk" and is redundant the moment talking is possible.

Do not use `heard:` for anything else. A post carrying a usable `id` needs no annotation, just reply to it; and a post that is not for you needs nothing at all. Keeping it to the one case is what lets its presence mean something specific: a handshake that has been received and is blocked on reachability alone, which is otherwise indistinguishable from one nobody has read. Posting your own mirror-image request instead is the wrong move, since it creates a second handshake to resolve rather than completing the first.

**A `heard:` entry is legitimately slower to clear, so don't sweep it as stale.** Clearing still belongs to the requester here, because they are the one who ends up with direct contact. The staleness sweep should treat an acknowledged post differently from an unacknowledged one: unacknowledged and old means nobody saw it, acknowledged and old means the bridge back has not happened yet, and those need different responses.

**Never a payload.** `re:` is a coarse topic ("UI components," "auth flow"), enough for a reader to self-select, never a specific finding, task detail, or content. This is a global file, a materially larger exposure surface than one project's own memory. Substance is exchanged only after a validated callback.

**An optional urgency opener inside `re:`, not a separate field.** A poster who considers something time-sensitive prefixes the topic with a single fixed word and a period, e.g. `re: urgent. UI components`, versus the routine default with no opener at all. Binary only, present or absent, not a graded scale. A reading agent treats an absent opener as routine; never infer urgency from the topic string's own tone or length.

**Fuzzy match is the point, not a limitation.** A request can target a project name with no exact Member to aim at; the topic does the narrowing, and whichever session reading the board judges itself a genuine match responds.

## Validating a callback

Whether contact came from a Members-informed guess or a Requests self-selection, there's no durable identifier establishing in advance who you actually reached: validate plausibility on the reply either way, does the responder's own stated `project`/`focus` genuinely match what the Members entry described or what the Requests topic asked for. No substance shared until it does.

Multiple sessions can plausibly answer either kind of contact; a self-identification claim alone is not sufficient corroboration, prefer whatever concrete, checkable evidence a responder can offer (a specific file, a commit, a log entry) over a bare assertion, and if two candidates give conflicting claims with no way to reconcile them from available evidence, ask the developer directly rather than picking one.

## Cleanup

**The responding agent, the one who picks up a pending entry, owns clearing it**, once contact is confirmed correct (see "Validating a callback" above), which may take a few exchanges, not on first response. It's already engaging with the mechanism at that moment; that's the natural point to close it out, rather than leaving it for the requester to notice separately later.

**The requester clears it as a fallback, not the primary path.** If the responder didn't clear it, ended its own session before finishing, forgot, or was never actually confirmed correct, the requester's own session-start staleness check (below) is the backstop. No forced expiry either way.

**Staleness is surfaced by the requesting agent, not maintained by the developer.** At session start, a session checks its own pending Requests entries. Anything pending longer than about a week gets surfaced directly, never silently dropped, never silently left. The developer only gets involved when an agent has already decided it's worth a decision.

## Noticing a pending Requests entry without being reminded

**Check trigger: two tiers, since not every runtime offers the same capability.**
- If the runtime offers some background or idle-triggered mechanism (a scheduled wake, a hook, anything that runs without an active user turn), check the bulletin board there, at whatever cadence fits that mechanism. Capability-gated like everything else here: check whether it exists, never assume it.
- Regardless of that capability, check at task-boundary checkpoints already implicit in how work is tracked in-session: session start, and immediately before beginning a new discrete unit of work within an already-running session, never mid-task. This is the universal floor: it needs no special capability, and it's what keeps a message posted mid-session, with no restart and no idle mechanism available, from going unnoticed until the conversation happens to end.

**Busy with active work: acknowledge, don't switch, always tell the developer.** Finding a pending entry mid-task is never a reason to interrupt already-in-progress work. If the channel supports a reply, send a minimal acknowledgment, currently occupied, will follow up, before returning to the active task. Whether or not a reply was possible, always surface the finding to the developer at the next natural point in the conversation, never only to the other agent and never silently deferred: who's asking, the topic (including the urgency opener, if present), and how long it's been posted. The developer decides whether the digression happens now or waits; this does not make that call on the agent's behalf.

**A received message's actual content must be surfaced, not just its existence, every time.** The delivery mechanism itself shows an incoming cross-session message to the receiving agent only, never to the developer. A conclusion drawn from one, with no visible trace of where it came from, is indistinguishable from the agent's own unprompted inference. Quote or clearly summarize the sender and the actual content in the same turn it's processed, every time, not only when it happens to seem worth narrating; the developer has no other way to see it.

## Registration trigger

Opt-in: `agent_index: yes | no`, asked once during initialization, same pattern as `propagation_suggestions`. Registration folds directly into the upgrade procedure itself (`upgrading-adoption.md`'s existing numbered flow), not a second, separate action the developer has to additionally request once the upgrade is otherwise done: running the upgrade to a version that ships this feature, with `agent_index: yes` set, is sufficient on its own for the session to register. Not triggered on every ordinary session start regardless of version, only by the upgrade itself.
