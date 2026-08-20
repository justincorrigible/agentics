# Agent index

A shared, agent-managed file (`~/.claude/agent-index.md` for Claude; your agent's equivalent global-context location otherwise) recording **who owns what**, plus a payload-free bulletin board (Requests) for reaching an owner you have never spoken to.

**It is an ownership registry, not an address book.** An earlier version stored each session's runtime handle and tried to route by it. That failed measurably: across every inter-agent message sent on one machine, at least 17% existed purely because a session could not be reliably addressed, and more than one message in ten was a misroute or a routing correction. Handles are excluded from this file entirely now, and contact resolves live at the moment it is needed. See `CHANGELOG.md` § `ownership-registry-replaces-address-book` for the measurements.

**Capability-gated, optional accelerant, never a dependency.** Coordination beyond the registry needs cross-session messaging (for Claude Code: `ListAgents`/`SendMessage`; other agents may have no equivalent capability at all, or one that behaves differently). Check the capability actually exists before relying on any of it; devctx and project memory already cover the general case where no peer session is running. Full empirical findings live in `.dev/docs/atlas/interagent-communication-findings.md` in the agentics repo, as context rather than as required reading.

## Read this file fresh before every write to the index

**Not from memory of an earlier read, and not from the live index file's own header.** This convention changes faster than anything else in the template, and an agent acting on a remembered version enforces a rule that has since been withdrawn or misses one that has since been added. A citation does not reliably produce a fresh read the way a direct instruction does, which is why this is stated as an instruction.

The trigger is the **write**, not the read. Looking up an entry is cheap and needs nothing. Registering, claiming, editing, or clearing needs this file open first.

**The live index carries defaults, not rules, and that is deliberate.** A second copy of the rules living beside the data drifts silently while still looking authoritative, which is exactly what `convention-levels.md` forbids for project copies of conventions. So the live file states only what must fail safe before anyone has read anything (you are not an owner, do not register, do not claim mail) and sends every write here. Anything fluid belongs in this file alone.

**Observed failure, which is what this rule is for:** when a main agent announced itself to its window, the surrounding task threads began registering themselves in the index, one of them named for a bounded piece of work. Nothing in their behaviour was unreasonable given what they had read; the registry simply had no membership rule when they last looked, and nothing prompted them to look again. Registering because a peer nearby just did is the specific error to expect after any visible activity in a window.

## Members: the ownership registry

```
- label:     <developer-conferred name>
  owns:      <org-relative path(s), comma-separated>
  expert:    <domains this agent is the expert in>
  window:    <the container's name, as a person would say it>
  assigned:  <date the developer conferred this, UTC date only>
```

**The registry holds owners, and owners are rare.** Most sessions are task threads scoped to a piece of work, not to a domain, and they **register nothing and own nothing**. Observed directly: one window held ten concurrent sessions named for tasks (`Arranger docs`, `Arranger Release flow`, `SQONs, Facets and SQONViewer`, `Review Charts PR from Ann`) and exactly one named for an owner. A task session working inside a repo is doing developer-directed work under that repo's owner, not becoming its owner, and registering it would claim a boundary it does not hold. If you are unsure which you are, you are a task thread.

**Every field is stable.** Nothing here decays, which is the point: there is no session-start refresh, no staleness check, no handshake to keep it current, and no timestamp that has to be re-stamped. An entry written once stays true until ownership actually changes. This is the property the old `id` and `focus` fields did not have, and maintaining them was most of this file.

**`label` is developer-conferred, never derived.** An auto-derived session name is a resolved-`cwd` artifact and can be a complete mismatch for what a session actually does, especially in a multi-root workspace where every session resolves to whichever folder is listed first. `label` is the stable name a developer would actually say.

**`owns` is the resource boundary, and it is what makes ownership checkable.** Paths are org-relative (`overture/lyric`, `overture/lyric/apps/ui`), never absolute: an absolute path encodes one machine's home directory and one clone location, and belongs in no shared file. Ownership may be a subtree, so a monorepo can have several owners.

**`expert` is what the developer conferred along with the label**, and it is what makes a question routable. It answers "who should I ask about ABAC token schemas", which `owns` cannot. Unlike a "current focus" field, it stays true between sessions, which is why it replaced one.

**`assigned` records that this was conferred rather than inferred.** An entry without it is provisional: something an agent drafted from context, correctable by anyone who knows better. An entry with it is authoritative, and narrowing or overlapping it requires the developer to say so. This is the same principle applied elsewhere in this file: a value carries its derivation, not just its content.

**`window` vs. `scope`.** `window` is the literal container: would closing this specific window end this session and any others sharing the value? It is the name a person would use for the container, not a handle's prefix, which is generated from whichever folder a workspace happens to list first and therefore names an artifact of ordering. A prefix identifies a window and never a project.

## Ownership resolves by longest prefix

A path belongs to the entry with the longest `owns` value that is a prefix of it. Given:

```
Overture            owns  overture/
Lyric and Maestro   owns  overture/lyric, overture/maestro
Lyric UI            owns  overture/lyric/apps/ui
```

`overture/lyric/apps/ui/App.tsx` is Lyric UI's, `overture/lyric/packages/data-model/x.ts` is Lyric and Maestro's, and `overture/song/y.java` is Overture's.

**Containment is normal, not a collision.** Only two entries claiming the *identical* path are an error, which is mechanically checkable. A subtree owner nested inside a repo owner is the expected shape.

**This subsumes family heads rather than adding a second mechanism.** A family head is simply the shortest prefix covering a family, and it owns everything in that family that no more specific entry claims. Its coverage is never enumerated and never needs updating, so assigning a new owner is always a pure narrowing that touches no other entry. It also means unowned is never ambiguous: an unclaimed path resolves to the family head rather than to whoever happens to have the directory open, which is where work absorption starts.

**Developer-designated roles never travel with the workspace.** A family-head designation, or anything else marked as conferred rather than self-assigned, belongs to the agent it was given to. A different session opening the same workspace does not inherit it.

## Identity is conferred, never inferred

**A session cannot determine who it is from anything it can observe.** Every ambient signal is shared by every session in the container: the runtime handle prefix, the window, the repository, the working directory, the git branch. Any self-identification test returns true for every new session in that container, so it produces a false positive exactly when a fresh session opens. This is a property of the environment rather than a gap in a particular rule, and it has been hit four separate ways: by handle, by window, by prefix, and by cwd. Inside a monorepo with co-owners there is no observable difference between two agents at all.

**But identity is observable from outside, and that is the half that works.** A peer learns who you are the moment you message them, because an inbound message carries the sender's session display name alongside its reply address (for Claude Code, a `from-name` attribute next to the socket `from`). You never see your own; every peer sees it on contact. So the asymmetry is not that identity is unknowable, it is that it is unknowable *to its holder*.

**A display name only carries identity once someone has set one, and the fallback is a trap.** An unnamed session's `from-name` is its runtime handle, not a name, so a message can arrive announcing `from-name="arranger-cf"`. Confirmed live while testing this rule: the reply that verified the mechanism also defeated it, because the sender had no name set. Treating that value as a label is exactly the "never use the address as a name" error below, arrived at through the mechanism meant to prevent it. **So check before trusting it: if `from-name` is the sender's handle, or matches the shape of one, the session is unnamed and you have learned nothing about who it is.** Say "an unnamed session in window X" rather than repeating the handle as though it were a name, and ask if you need to know.

**That splits two values this file previously conflated.** The display name is **identity**; the socket or handle is an **address**. They have different lifetimes and different jobs, and the deleted `id` field failed largely because it was asked to be both.

**So conferral is a rename, not a sentence typed each session.** Naming an owner session with its label in front, for example `(Usher) User Access Control for Overture`, is the whole mechanism: the developer is the only party who can confer, the name persists for the session's life without being retyped, and it reaches every peer automatically on first contact. A session called `Arranger docs` is visibly not an owner, which is information a reader gets for free.

**The name is unverified and that is acceptable here, but know why.** Nothing authenticates a display name; it is whatever the developer set. That is sound precisely because the developer is the conferral authority, so a name they set *is* the conferral. In a setting with more than one developer, or any adversarial party, it would carry no weight at all.

**None of this lets a session identify itself.** The name is not readable from inside the session, so a session still holds no identity until told, and the default below is unchanged.

**Default to having no identity.** A session that has not been told which label it holds owns no entry, claims no mail, and holds no designated role. Assume new. A matching workspace, repository, or working directory is not evidence, and the resemblance is strongest precisely when the inference is wrong.

**Developer-directed work is always authorized, whatever your identity.** The ownership boundary constrains what an agent does on its own initiative, not what the developer asks for. If they open any session and ask for a fix in a repo, that is authorized by definition and no identity check gates it. Reading another owner's code to answer your own question is likewise always fine: reading transfers no work.

**But route the knowledge even when you cannot route the work.** When you do work outside your own `owns`, leave a note for the owner (a `.dev/` entry in their project, or a Requests post). The developer relies on a specialist's accumulated context as live expertise, and that context only grows if what happened reaches it. Work landing in the wrong session is recoverable; the knowledge never arriving is not.

**Read that as a change being introduced, not a description of what already happens.** A session in a window full of task threads reported the opposite as the current norm: task-scoped sessions operate independently on a narrow scope, coordinate through the developer rather than through any index, and the owner finds out later through session files or git history, if at all. That is the behaviour this rule exists to change, so do not read "works under the owner" as implying the owner was consulted. The note is the entire mechanism, and it is one you have to actually write.

## Registering and changing ownership

**Registration is the developer conferring a label, and the agent recording it.** Draft the entry from the conferral and the visible context, state it back, and get a confirmation before writing: this is a file shared across every project the developer works in, not a local decision.

**Before writing, run the check rather than doing it by eye:** `bash scripts/check-agent-index.sh` from the agentics clone, which reads `~/.claude/agent-index.md` by default and takes a path otherwise. It reports duplicate paths, absolute paths, entries still on a pre-registry schema, and the resolution tree that longest-prefix matching actually produces, which is the part hardest to verify by reading. It never edits.

**Then check the new `owns` paths against every existing entry.** Two outcomes, and only one of them is mechanical:

- **Identical path already claimed: a hard error.** Resolve it before writing anything.
- **Nested, overlapping, or similarly-named: ask the developer.** A new "Lyric UI" owning `overture/lyric/apps/ui` produces no path collision with "Lyric and Maestro" owning `overture/lyric`, because containment is legal. The overlap is conceptual, and only the developer knows whether the new label narrows the existing one or is unrelated. Ask with options rather than open-ended, since they are mid-conferral: is this a new resource with no narrowing, a subtree taken from the existing owner, or a replacement of that assignment?

**A conferral onto an already-`assigned` label triggers the same question.** If the developer confers a label that is already assigned, ask whether this session replaces that assignment or is a second session for the same scope. This does not eliminate duplicate ownership, since the answer could still be wrong, but it removes the silent path: a double claim now requires an explicit answer instead of happening unnoticed.

**Write only your own entry.** If a split takes territory from another owner, record your own narrower entry and flag the overlap; do not edit the incumbent. The incumbent reads the registry at its next session start, sees the overlap, and narrows itself. This is self-healing, needs no cross-editing, and works even though the incumbent was not running when the split happened. It is "another session's work is not yours" applied to the registry itself.

## Sibling coordination

Sessions sharing a window are siblings. They share a container, and often a working tree, so they are the peers most likely to collide and the easiest to reach.

**The window's main agent is the local routing point**, and it is the one owning the window's first-listed folder. It accumulates the handle-to-label map for its own window: small, rebuilt naturally, held in session rather than persisted, and therefore never stale. It is a per-window directory that costs nothing to maintain, unlike a global one.

**The main agent announces itself; newcomers do not go looking for it.** An earlier version had this backwards, telling a new session to introduce itself to the main agent, which requires finding the main agent, which is the problem being solved. The direction follows from identity being knowable only from outside: **the only party who knows a conferred role is its holder, so the holder has to speak first.** A main agent announces once per session to the sessions sharing its window, and every newcomer then has a known address to introduce back to. A newcomer that has heard no announcement concludes the main agent is not running, which is true and useful, rather than guessing among candidates.

**A conferred role is invisible until someone says it, and a session name will not carry it by default.** Confirmed the hard way: a window's main agent was named `Search Server - multicatalogue`, indistinguishable from the task threads around it, and a probe sent to the wrong candidate reached a session that could only pass along a third-hand guess about which one was the owner. Neither the name, nor the handle, nor the working directory encoded the assignment. Nothing does, until the holder announces it or the developer puts the label in the name.

**Introductions may guess; substantive messages may not.** Misroute tolerance differs by message type, and this is what makes the bootstrap work where address lookup does not. "Hi, I'm Lyric UI, are you the main agent here?" costs one message, carries no claim, and self-corrects if wrong, so route it cheaply: pick any session sharing your window's handle prefix and ask it to answer or relay. A work request or a state claim gets no such latitude, and needs an address that came from a reply or an introduction.

**An introduction needs no "who are you" round trip in return.** The reply carries the responder's display name, so a session that answers has already identified itself. If owner sessions are named with their label in front, the main agent learns the whole window by receiving introductions, and nobody has to ask anyone who they are.

**Say what you own when you introduce yourself.** That is the coordination that matters, especially for co-owners of one repository: each needs to know the other's boundary before either starts editing.

## Reaching an owner

**Warm contact: reply to whoever messaged you.** An inbound message carries a live, known-good address, valid for the rest of the exchange. This never misroutes and needs no lookup.

**Cold contact: post to Requests, or bridge through a sibling.** Look up the owner in Members to learn the `label` and `expert` you are aiming at, then either post a topic-qualified Requests entry and let the right session self-select, or, if you need someone live now, ask one session in their window to answer or point.

**No one can join a display name to a handle without sending a message, and the two halves are held by different parties.** The listing shows handles and no names, to every session equally, inside a window and outside it. The developer sees names and no handles. So an agent holds one half, the developer holds the other, and neither can complete the join alone: the only thing that produces both at once is an inbound message, which carries a name beside an address. Confirmed by asking a session inside the target's own window, which had exactly the same handle-only view and would have had to probe its neighbours one at a time, the same work available from outside.

**That is what makes the announcement load-bearing rather than a courtesy.** Without it, finding a named session costs a probe per candidate, every session, forever, and asking the developer does not help, because they cannot see handles either. With it, one message from the holder gives every peer the join for free. Do not treat announcing as optional politeness; it is the only mechanism that makes named sessions reachable at all.

**An announcement is window-scoped, and that is sufficient, because it turns every session in the window into a bridge.** An outsider never receives it and does not need to: the members did, so any one of them now holds the join and can answer for the cost of a single question. This is how a local broadcast becomes globally useful without anyone broadcasting globally, and it is why the two rules above depend on each other. The announcement is what manufactures the prior contact that makes a bridge worth asking; a window where nobody has announced has no usable bridges in it, only neighbours who know as little as you do.

**Ask one session, never broadcast.** A sibling is still worth asking, but for a narrower reason than co-location: it may have *already spoken* with the session you want, and therefore already hold the join. A sibling that has not is no better placed than you are. Prior contact is what makes a bridge useful, not proximity. Messaging every candidate costs N messages instead of one, interrupts sessions with nothing to do with the question, and delivers the same claim to several readers at different moments, which is how one of them reads a statement that was true when sent and false on arrival.

**Never guess from a handle, but know that a probe is cheap and a claim is not.** The prefix is derived from a resolved working directory, so several sessions on one repository produce near-identical handles that distinguish nothing, and in a multi-root workspace the handle derives from whichever folder is listed first rather than what the session works on. Confirmed directly: a session dedicated to one service was listed under a different project's prefix. So a handle never tells you who someone is. What has changed is the cost of finding out: a reply names its sender, so addressing a guess with a question resolves it in one exchange and a wrong guess is visibly wrong rather than silently wrong. Send a probe to a candidate freely; never send a claim, a task, or state to one.

**Never break a tie by start time.** An earlier version of this rule said to prefer the most recently started candidate. It is withdrawn: it failed three times in a single day, twice sending another project's breaking-change notice to a session that owned something else. Process start time carries no information about which session is active or what it was assigned. Recency reads like evidence and is not, which is worse than having no tie-breaker, because it converts "I don't know" into a confident wrong answer.

## Mail, and deciding whether it is yours

**Every message and board entry names a `label`, never a role.** "For the main agent of this window" is unresolvable by construction, because the role is ambient and every session in the container matches it. "For Arranger" is resolvable, because a label is conferred and a session either holds it or does not. This removes the failure mode structurally instead of warning against it.

**Claim mail only if the developer conferred that label in this session.** Otherwise surface it without claiming: "there is a board entry for Usher; I have not been told I am Usher." That is the correct output rather than a failure, and it is strictly better than silence, because it routes the one question only the developer can answer. Acting on mail addressed to a label you were not given is the same error as claiming an entry because the workspace matched.

**Opening this file is itself a trigger to check for entries addressed to you**, whatever brought you here. You came to look someone up, and the check costs one read of a file already open.

**Relay what you see.** A session with an entry waiting may have no reason to open this file at all, and quiet sessions are the ones most likely to be waited on. If you are already in contact with a session that has mail here, tell them.

## Requests: the bulletin board

For reaching an owner with no confirmed live session. Payload-free by design: it is a handshake, not a channel.

```
- for: <label>
  from: <label>
  re: <short topic>
  heard: <handle that answered, cleared once contact succeeds>
  posted: <UTC, e.g. 2026-08-19T23:06Z>
```

**Topic-qualified, no payload.** `re:` exists so the right session can self-select. Put the substance in the direct exchange that follows, not here: a board entry is read by everyone and outlives the moment it was written.

**An optional urgency opener inside `re:`, not a separate field.** A poster who considers something time-sensitive prefixes the topic with a single fixed word and a period, for example `re: urgent. UI components`. Binary only, present or absent. Treat an absent opener as routine, and never infer urgency from the topic string's own tone or length.

**Timestamps are UTC, with the `Z` suffix.** Not because sessions span machines, since this file lives in one developer's global context, but because each agent otherwise independently picks local or UTC and nothing said which. Confirmed directly: two posts minutes apart in reality were written four hours and one calendar day apart in the file. Derive it mechanically: `date -u +%Y-%m-%dT%H:%MZ`. The `Z` is the actual fix, because it makes the value self-describing; a bare timestamp is ambiguous and sharing a machine does not resolve it. Leave a bare legacy value alone for its own poster to restamp rather than converting it, since reclassifying an ambiguous value is a guess presented as a conversion.

**A message asserting current state is stale by the time it is read.** A message freezes when sent and the state it describes keeps moving. Confirmed directly: three sessions were told at once which entries were incomplete, one replied, the file changed, and by the time a second read the same message the claim no longer matched. It was true when sent and false when read, and the recipient correctly refused to act on it. Either say when a claim was true, or name the file and let the reader check it live.

**Clearing is the poster's job.** `heard:` records that someone answered; clear the entry once contact succeeds. A `heard:` entry is legitimately slower to clear than an unanswered one, so do not sweep it as stale.

## Naming and reporting

**The runtime handle is an address, `label` is the name: never use the address as a name.** The identifier a listing shows (for Claude Code, something like `arranger-21`) is the correct thing to put in a recipient field and nothing else. Refer to a peer by `label` everywhere else: messages, session logs, roadmap and tech-debt entries, atlas write-ups, and anything reported to the developer. A handle is derived per process and does not survive a restart, so "arranger-21 confirmed X" in a session log is unresolvable a day later, and worse than unresolvable if a different session has since taken a similar handle.

**Reporting to the developer: the label is the subject, and a dead handle is dropped rather than reported.** Write "Submission Service is live, Gateway and Portal UI are not", never "`2a` is Submission Service, and `f1` and `51` are dead". The second form asks the developer to carry meaningless characters as though they were names, then reports two more with no referent at all. Mention a handle only when it is itself the subject of the fact.

**Lookup is normalized text.** Case-insensitive, with spaces, hyphens, and underscores treated as equivalent separators. `label` and `window` are descriptors rather than identifiers, and nothing enforces uniqueness on them; a lookup can return zero, one, or several results.

## Cleanup

Remove an entry when the developer says ownership ended, not when a session stops running. Ownership outlives the process that held it, and an entry for an owner who is not currently live is correct rather than stale: it still says who to reach and who not to absorb work from.
