# Agent index: cross-project session directory and bulletin board

Design spec from a real, live design conversation (2026-08-08 through 2026-08-16), now shipped as `template/conventions/agent-index.md` (see Status below). Supersedes the earlier family-registry prototype described in `interagent-communication-findings.md`: workspace becomes a field on one global index instead of a second, workspace-scoped file.

**Same gating as the rest of this investigation.** Built entirely on Claude Code's cross-session messaging (`ListAgents`/`SendMessage`). Any eventual convention must check the capability exists rather than assume it, and stay an optional accelerant, never a dependency: devctx/memory already cover the general case where no peer session is running. See `interagent-communication-findings.md`'s caveat block for the full statement.

## Motivating scenario

A real, live case that shaped this design: `search-server` (an Arranger-workspace session) needs to reach a Stage session directly to coordinate UI-component changes, replacing a manual workflow (write to a shared doc, tell each side by hand to check it). The scenario also surfaced two real findings that directly justify design decisions below: a session working on an entirely unrelated project (`helm-charts`) had registered under agentics' own resolved `cwd`, the second confirmed instance of this mismatch (the first was a Lyric/Maestro session earlier), and a `ListAgents`/`SendMessage` send was accepted but the receiving session showed no sign of acting on it, the already-documented delivery-is-not-action gap, reconfirmed live.

## Purpose

Avoid two wasteful patterns: "ripples in a pond" (an agent messaging every peer to ask "are you the one I want?"), and manual doc-relay (the developer telling each side by hand to go check a shared file). One targeted lookup replaces the first; a single, minimal handshake post replaces the second.

## Location

A single global file, `~/.claude/agent-index.md`, sibling to `projects.md`. Not per-project, not per-workspace: the whole point is reachability across projects and workspaces, which a workspace-scoped file (the family-registry prototype) cannot provide.

**Entirely agent-managed, by definition.** Registration, lookup, validation, and staleness handling are all done by agents themselves. Not a file a developer is expected to browse or maintain by hand; a human is only pulled in when an agent explicitly decides something needs a decision (see "Staleness" below).

## Members: the directory (exact match)

One entry per currently-registered session, self-written and kept updated by that session.

```
- label: <developer-assigned, stable, e.g. "search-server">
  name: <current ListAgents-derived name/ref, last seen>
  project: <what this session is actually working on>
  window: <developer-assigned, the literal container this process shares with others>
  scope: <the broader project-family or program area, independent of window; see open question below>
  focus: <one line, substantive current work only, not who you're coordinating with>
  updated: <timestamp>
```

**`label` is developer-assigned, not derived.** It's the thing a developer would actually say ("search-server"), decoupled from the auto-derived `ListAgents` name, which is a resolved-`cwd` artifact that can be a complete mismatch for what a session is actually doing (both confirming incidents above).

**`focus` is substantive current work, not relationship status.** A real instance caught live: an entry read "...coordinating with Stage" alongside its actual work. That clause doesn't help anyone matching on subject matter, and it goes stale the moment the coordination ends, an entry nobody's specifically watching for. Keep `focus` to what the session is actually working on or investigating; who it happens to be talking to right now doesn't belong in it.

**`workspace` conflates two different questions, caught live telling a second real session to register.** Asked plainly, "workspace" invites either "which literal window is this" (the original intent, needed for the `cwd`-mismatch problem, since two sessions sharing one window can misregister into each other's identity) or "what broader program of work does this belong to" (equally natural to answer, but a completely different fact). Two sessions can share the second while being in entirely different physical windows for the first, exactly what happened: an Arranger session and a Stage session both reasonably said "softeng and overture" despite almost certainly running in separate windows. Split into two fields:
- **`window`**: the literal container. Definition is a litmus test, not a description: would closing this specific window end this session and any others sharing this value? If yes, same `window`.
- **`scope`**: the broader project-family or program area this session's work belongs to, independent of which window it's in. Open question, not yet settled: freely typed (same collision/drift risk as any other descriptor here), or derived automatically from `project`'s own path (`overture/stage` and `overture/arranger` both yield `overture`), with a manual override only when the auto-derived grouping doesn't match how the developer actually thinks about it. Leaning toward deriving by default, one less field to keep consistent across every registration, but untested against enough real registrations to settle it.

**`workspace` is asked once, never derived.** `cwd` cannot be trusted for this (same two incidents), and there is no agent-neutral way to read a workspace's real name (e.g. a `.code-workspace` title is Claude-Code/VSCode-specific). Ask during initialization, record in that project's own memory (a fact about this project's context, not the developer, per `memory-scope-defaults-to-project`), default to the project name if the developer says it isn't shared with anything else.

**`label` and `workspace` are descriptors, not identifiers.** Nothing enforces uniqueness at registration time, and nothing should: forcing uniqueness would mean treating a human-chosen, memorable tag as if it were a database key. Two sessions can legitimately end up with the same or a colliding label (two different projects both informally called "search-server," say). A lookup therefore matches on normalized text, case-insensitive, treating runs of spaces, hyphens, and underscores as equivalent separators, so "search server", "search-server", and "Search_Server" all match the same entries, and can return zero, one, or several results.

**Zero matches:** report "not found in the index" back to the developer and stop. Do not fall back to scanning `ListAgents` and picking whichever name looks plausible, that is exactly the guesswork this mechanism exists to remove.

**Several matches:** don't silently pick one. First, check whether the other descriptor fields (`project`, `workspace`, `focus`) already disambiguate. If they don't, a topic-qualified Requests post is often the better resolution before escalating to the developer, not a separate case: two sessions can share a label while having different specialties (two Arranger sessions, different areas), and `re:` is exactly what lets the right one self-select, the same reason it exists at all in the fuzzy no-Member-entry case. Only surface to the developer and ask directly if that still doesn't settle it.

## Registering: check for a collision first

Before writing itself in, an agent checks the index for an existing entry matching its candidate label (same normalization as lookup). If one exists, message that session directly (standard `SendMessage`, no index needed for this step, its `name` is right there in the entry) and agree on disambiguation, a qualifier for one or both, or who keeps the plain label, before either commits an entry. This is proactive prevention on top of the reactive handling below, not a replacement for it: a race (both registering at once) or an unreachable other party at that moment still needs the reactive path.

## No durable cross-session address exists; validation is the actual safeguard, not a courtesy

Verified directly, not assumed: the bound socket is named by PID (`/tmp/cc-socks/<pid>.sock`), tied to one running process, not durable across restarts. The registration file carries a real stable `sessionId` (a UUID), but `SendMessage`'s own `to` parameter doesn't accept one, only a name, and a sub-agent's `agentId`, so it exists but isn't addressable. The printed `[ref]` is stable in value (confirmed empirically: identical refs for the same peers across two `ListAgents` calls roughly two hours apart) but the protocol still requires it be freshly observed in the current conversation before it resolves; a value read from a file doesn't work directly. None of this matters much in practice: sending the bare name and letting a rejection hand back a live ref is the actual working mechanism, so the index never needs to store or trust a `ref`.

**The real risk is silent reassignment, not staleness.** Per the tool's own documented behavior, a reused name resolves to whichever session claimed it most recently, "latest wins." A Members entry's `name` can therefore point at a completely different, newer session with no error at all, not just an offline one. This is exactly why validating a callback (`from`, stated `project`/`focus`) is not a nice-to-have precaution, it is the only defense against this specific failure mode.

## Keeping a registration current across restarts

A restart (or anything else that changes a session's derived name) leaves two separate problems, not one: does the session know it's already registered at all, and does it know its recorded `name` is now wrong.

**Knowing it's already registered:** record the session's own `label` in that project's own memory, not only in the global index. Project memory survives a restart (keyed to the project, not the volatile pid), so "check my own registration" becomes a normal line in the existing session-start checklist, the same checkpoint already used for the `.dev/roadmap.md`/`tech-debt.md` staleness pass.

**Knowing its current name is genuinely harder, worth stating honestly rather than assuming a clean mechanism exists.** There is no direct way to ask "what is my own current `ListAgents` name", it excludes self by design, confirmed repeatedly during this investigation. The working technique, used successfully twice already (this session and Stage, independently): filter `~/.claude/sessions/*.json` for entries matching this project's own `cwd`, exclude anything already visible in your own `ListAgents` peer list (since that can't be you), and the most recently-started remaining match is you. Indirect, not a documented API, but reliable so far.

**Don't try to detect staleness, refresh unconditionally instead.** Since self-detection is inherently a bit fuzzy, at every session start, if `agent_index: yes` and project memory has a label, re-derive the current name via the technique above and rewrite `name`/`updated` regardless of whether it looks different from last time. Cheap, idempotent, self-healing either way, the same "just run the check every time instead of cleverly detecting when it's needed" shape already used elsewhere in this repo's own conventions.

## Requests: the bulletin board (fuzzy match, handshake only)

Used when there's no confirmed live Member to address directly, including the case where several sessions could exist for one project and only one is actually relevant.

```
- from: <requester's own label>
  looking_for: <target project or label>
  re: <short topic, a feature/module name only>
  posted: <timestamp>
```

**Never a payload.** `re:` is a coarse topic ("UI components", "auth flow"), enough for a reader to self-select, never a specific finding, task detail, or content. This is a global file; any session with filesystem access to `~/.claude/` could in principle read it, a materially larger exposure surface than one project's own memory. Substance is exchanged only after a validated callback, never posted here.

**Fuzzy match is the point, not a limitation.** A request can target a project name with no exact Member to aim at; the topic does the narrowing, and whichever session reading the board judges itself a genuine match (right project, right area) is the one that responds.

## Validating a callback

Two different strengths, matching the two lookup kinds:

- **Exact (a Members-addressed request):** the reply's `from` identity (stamped by the messaging system, not writable by the sender) must match the specific session the label resolved to.
- **Fuzzy (a Requests-addressed one):** no single expected identity exists in advance. Validate plausibility instead, does the responder's own stated project and focus genuinely match what was asked for.

Either way: no substance shared until the relevant check passes.

## Cleanup

The **requester** owns clearing its own Requests entry, and only once it has confirmed correct contact, which may take a few exchanges, not on first response. No forced expiry.

**Staleness is surfaced by the requesting agent, not maintained by the developer.** At session start (the same checkpoint `session-discipline.md` already uses for the `.dev/roadmap.md`/`tech-debt.md` pass, extended to this global file), a session checks its own pending Requests entries. Anything pending longer than about a week gets surfaced directly ("still waiting on Stage for the UI-components thing, posted 9 days ago, want me to do anything about it"), never silently dropped, never silently left. The developer only gets involved when an agent has already decided it's worth a decision.

## Registration trigger

Opt-in: a new setting, `agent_index: yes | no`, asked once during initialization, same pattern as `propagation_suggestions`. Registration is a step folded directly into the upgrade procedure itself (`upgrading-adoption.md`'s existing numbered flow), not a second, separate action the developer has to additionally request once the upgrade is otherwise done. Running the upgrade to the version that ships this feature (0.14.0+) with `agent_index: yes` set (asking it fresh, once, if not yet known) is sufficient on its own: the session registers itself as part of applying that update, no further prompting needed. Not triggered on every ordinary session start regardless of version, only by the upgrade itself.

## Noticing a pending Requests entry without being reminded

Design draft, not yet tested against the exact gap a live test surfaced: a Requests entry addressed to this project's session sat unnoticed for an entire multi-hour session, no restart in between, no trigger anywhere to check it.

**Urgency: an optional opener inside `re:`, not a new field.** Rather than a separate `urgency:` key, a poster who considers something time-sensitive prefixes the existing topic string with a single fixed word and a period, e.g. `re: urgent. UI components`, versus the routine default, `re: UI components`, no opener at all. Binary only, present or absent, deliberately not a graded scale: a scale would reintroduce the same complexity a dedicated field would have, for nothing `re:`'s existing loose text can't already carry. A reading agent treats an absent opener as routine; never infer urgency from the topic string's tone or length.

**Check trigger: two tiers, since not every runtime offers the same capability.**
- If the runtime this agent is running under offers some background or idle-triggered mechanism (a scheduled wake, a hook, anything that runs without an active user turn), check the bulletin board there, at whatever cadence fits that mechanism. Capability-gated like the rest of this design: check whether it exists, never assume it, and treat it as an accelerant, not a dependency.
- Regardless of that capability, check at task-boundary checkpoints already implicit in how work is tracked in-session: session start (already established, see Staleness above), and immediately before beginning a new discrete unit of work within an already-running session (a new user instruction, a new tracked task), never mid-task. This is the universal floor: it needs no special capability, and it directly closes the gap the live test exposed, a message posted mid-session with no restart and no idle mechanism available would otherwise have no trigger to be noticed at all until the next one of these boundaries.

**Busy-with-active-work: acknowledge, don't switch, always tell the developer.** Finding a pending entry mid-task is never a reason to interrupt already-in-progress work. If the channel supports a reply, send a minimal acknowledgment, currently occupied, will follow up, before returning to the active task. Whether or not a reply was possible, always surface the finding to the developer at the next natural point in the conversation, never only to the other agent and never silently deferred: who's asking, the topic (including the urgency opener if present), and how long it's been posted. The developer decides whether the digression happens now or waits; this design does not make that call on the agent's behalf.

**A received message's actual content must be surfaced, not just its existence, every time, not at the agent's discretion.** Confirmed directly (see `interagent-communication-findings.md`): the delivery mechanism itself shows an incoming cross-session message to the receiving agent only, never to the developer, so a conclusion drawn from one, with no visible trace of where it came from, is indistinguishable from the agent's own unprompted inference. This applies beyond the notice-without-reminding case above, to any incoming message received during an already-active, flowing conversation: quote or clearly summarize the sender and the actual content in the same turn it's processed, every time, not only when the receiving agent happens to judge it worth narrating. The developer has no other way to see it.

## Status

Shipped 2026-08-16 as `template/conventions/agent-index.md`, after the full loop (register, exact lookup, fuzzy request, validated callback, cleanup, staleness surfacing, the notice-without-reminding trigger above) was live-tested against real sessions across several projects. This file stays as the design history and reasoning; the convention itself is the current source of truth for behavior, not this document. Two refinements made during the shipped version that aren't reflected above: cleanup ownership shifted from the requester to the responding agent (the one already engaging with the mechanism at the moment contact is confirmed), with the requester's own staleness check as a fallback rather than the primary path; and the Members `name`/ref field described throughout this document was removed entirely, not just handled more carefully, after it failed in every real contact attempt tested against it. Reaching a Member now resolves live (filter `ListAgents` by `project`/`window`/`scope`, default to the most recently started candidate) rather than via any stored identifier.
