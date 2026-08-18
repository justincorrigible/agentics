# Agent index: cross-project session directory and bulletin board

A shared, agent-managed file (`~/.claude/agent-index.md` for Claude; your agent's equivalent global-context location otherwise) letting sessions in different projects, or different windows, reach each other directly: an exact-match directory of currently-registered sessions (Members), plus a payload-free bulletin board (Requests) for reaching a project with no confirmed live Member.

**Capability-gated, optional accelerant, never a dependency.** Built on cross-session messaging (for Claude Code: `ListAgents`/`SendMessage`; other agents may have no equivalent capability at all, or one that behaves differently). Check the capability actually exists before relying on any of this; devctx and project memory already cover the general case where no peer session is concurrently running. Full empirical findings behind the Claude-Code-specific mechanics live in `.dev/docs/atlas/interagent-communication-findings.md` in the agentics repo, for context, not as something every adopter needs to read.

**Entirely agent-managed.** Registration, lookup, validation, and staleness handling are all done by agents themselves; this is not a file a developer is expected to browse or maintain by hand. A human is only pulled in when an agent has already decided something needs a decision.

## Members: the directory (exact match)

One entry per currently-registered session, self-written and kept current by that session:

```
- label: <developer-assigned, stable, e.g. "search-server">
  project: <what this session is actually working on>
  window: <the literal container this process shares with others>
  scope: <the broader project-family or program area, independent of window>
  focus: <one line, substantive current work only>
  updated: <timestamp>
```

**No `name`/ref field, deliberately.** An earlier version stored one, and every real cross-session contact attempt tonight ran into it being wrong: stale after a restart, reused under "latest wins" reassignment, or simply gone. A value that has to be re-verified before every real use isn't saving the verification, it's adding a wrong-until-proven-right first guess in front of it. Contact resolves live instead, at the moment it's actually needed (below), which is also the only time it can resolve correctly.

**`label` is developer-assigned, not derived.** The auto-derived session name (a resolved-`cwd` artifact) can be a complete mismatch for what a session is actually doing, especially in a multi-root workspace, where every session sharing that workspace resolves to whichever folder is listed first regardless of which project the human is actually discussing in that thread. `label` is the stable, human-chosen handle a developer would actually say, decoupled from that.

**`window` vs. `scope`, don't conflate them.** `window` is the literal container: would closing this specific window end this session and any others sharing this value? If yes, same `window`. `scope` is the broader project-family or program area this session's work belongs to, independent of which window it's in, two sessions in entirely separate windows can share the same `scope` (e.g. two different Overture repos), while two sessions sharing one window can have different `scope`s entirely.

**`focus` is substantive current work only, not who you're coordinating with right now.** That's transient, doesn't aid matching, and goes stale the moment the coordination ends.

**Refresh `updated`/`focus` unconditionally at every session start, don't try to detect staleness.** If `agent_index: yes` and this project's own memory has a recorded `label`, refresh both every session start regardless of whether anything looks different from last time, rather than trying to detect whether a refresh is actually needed. `focus` specifically drifts fast if left to a separate habit, tying its refresh to this same checkpoint is what keeps it from going stale between updates.

**`label` and `window` are descriptors, not identifiers.** Nothing enforces uniqueness at registration, and nothing should. A lookup matches on normalized text (case-insensitive, spaces/hyphens/underscores treated as equivalent separators) and can return zero, one, or several results.

**Zero matches:** report "not found in the index" to the developer and stop. Do not fall back to scanning `ListAgents` and picking whichever name looks plausible, that is exactly the guesswork this mechanism exists to remove.

**Reaching a Member: match on `project`/`window`/`scope`, then pick from live `ListAgents` by recency.** There's no stored identifier to send to directly. Call `ListAgents`, filter to sessions whose project matches the Member entry (cross-referencing `window`/`scope` if more than one does), and default to the most recently started candidate among them. If that guess is wrong, or more than one candidate is equally plausible, a topic-qualified Requests post (below) lets the right one self-select rather than guessing further; only ask the developer directly if that still doesn't resolve it.

**Check the index before enumerating `ListAgents` blind or asking the developer, not after.** The point of a Members lookup isn't to skip `ListAgents`, contact still resolves through it, it's to know which project/scope to filter for and which entry's fields help pick the right candidate, rather than guessing from names alone. Confirmed directly, repeatedly in one evening, across three separate incidents: a session resolving which of two same-project candidates was current only through an out-of-band developer handshake; a different session hitting the identical ambiguity and asking the developer to pick, when a correct Members entry existed and would have resolved it instantly; and a session finding a Members entry's stored name matched no active session at all. Check Members first for the project/scope to filter by, always, before `ListAgents`-driven guessing or a developer prompt.

**Several matches:** don't silently pick one. Check whether `project`/`window`/`scope`/`focus` already disambiguate. If they don't, a topic-qualified Requests post (below) is usually the better resolution before escalating to the developer: two sessions can share a label while having different specialties, and `re:` lets the right one self-select. Only ask the developer directly if that still doesn't settle it.

## Registering: propose, confirm, then check for a collision

Propose the entry from visible context first: `label`, `project`, `window`, and `scope` can all be reasonably drafted from the working directory and the current conversation. This is a write to a file shared across every project the developer works in, not a purely local decision: state the proposed entry and get a quick confirmation or adjustment before committing it, the same as any other non-trivial decision.

Before writing itself in, check the index for an existing entry matching the candidate label (same normalization as lookup). If one exists, message that session directly and agree on disambiguation, a qualifier for one or both, or who keeps the plain label, before either commits an entry. This is proactive prevention on top of the reactive handling above, not a replacement for it: a race (both registering at once), or an unreachable other party at that moment, still needs the reactive path.

## Requests: the bulletin board (fuzzy match, handshake only)

Used when there's no confirmed live Member to address directly, including when several sessions could exist for one project and only one is actually relevant:

```
- from: <requester's own label>
  looking_for: <target project or label>
  re: <short topic, a feature/module name only>
  posted: <timestamp>
```

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
