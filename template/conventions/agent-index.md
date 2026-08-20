# Agent index

A shared, agent-managed file (`~/.claude/agent-index.md` for Claude; your agent's equivalent global-context location otherwise) recording **who owns what**, plus a payload-free bulletin board (Requests) for reaching an owner you have never spoken to.

**It is an ownership registry, not an address book.** An earlier version stored each session's runtime handle and tried to route by it. That failed measurably: across every inter-agent message sent on one machine, at least 17% existed purely because a session could not be reliably addressed, and more than one message in ten was a misroute or a routing correction. Handles are excluded from this file entirely now, and contact resolves live at the moment it is needed. See `CHANGELOG.md` § `ownership-registry-replaces-address-book` for the measurements.

**Capability-gated, optional accelerant, never a dependency.** Coordination beyond the registry needs cross-session messaging (for Claude Code: `ListAgents`/`SendMessage`; other agents may have no equivalent capability at all, or one that behaves differently). Check the capability actually exists before relying on any of it; devctx and project memory already cover the general case where no peer session is running. Full empirical findings live in `.dev/docs/atlas/interagent-communication-findings.md` in the agentics repo, as context rather than as required reading.

## Read this file fresh before every write to the index

**Not from memory of an earlier read, and not from the live index file's own header.** This convention changes faster than anything else in the template, and an agent acting on a remembered version enforces a rule that has since been withdrawn or misses one that has since been added. A citation does not reliably produce a fresh read the way a direct instruction does, which is why this is stated as an instruction.

**The trigger is any act that propagates a rule, which is writing to the index *or* asserting the convention to someone.** Looking something up stays free. Registering, claiming, editing, or clearing needs this file open first, and so does quoting a rule to a peer, correcting someone against it, or escalating a question as though it were open.

An earlier version of this rule said the trigger was the write, and a session demonstrated the hole from the inside within a day. It had read this file before two releases, never wrote anything, and hours later told a peer that its `workspace` value was wrong, citing a requirement that had been withdrawn and the field redefined to mean exactly what that peer had recorded. The peer had already checked with the developer, held its position, and was right. Two sessions were misinformed and a settled question was escalated as open, entirely from a read.

**Satisfying this rule does not settle which artifact is authoritative, and a session demonstrated the difference.** It read this convention fresh in the morning, read `scripts/check-agent-index.sh` later, took the script as the authority where the two disagreed, and asserted to two other sessions a casing rule this file has never contained. The trigger fired and was obeyed; it governs *when* to read the convention, not *which wins*. So: **the convention is the source and a check is an implementation of it**, a check enforcing something undocumented is a defect rather than a stricter reading, and a rule cited to a peer is cited from here and never from a script. See `docs/deterministic-by-design.md` § A check implements a rule.

**A stale rule spoken to a peer travels further than a stale rule written down**, because the peer acts on it without ever seeing where it came from, and no file records that it was said. Worse in that case: the assertion was backed by a mechanical check, which made a withdrawn rule *more* convincing rather than less. Reported by the session that got it wrong, unprompted.

**The live index carries defaults, not rules, and that is deliberate.** A second copy of the rules living beside the data drifts silently while still looking authoritative, which is exactly what `convention-levels.md` forbids for project copies of conventions. So the live file states only what must fail safe before anyone has read anything (you are not an owner, do not register, do not claim mail) and sends every write here. Anything fluid belongs in this file alone.

**Observed failure, which is what this rule is for:** when a workspace lead announced itself to its workspace, the surrounding task threads began registering themselves in the index, one of them named for a bounded piece of work. Nothing in their behaviour was unreasonable given what they had read; the registry simply had no membership rule when they last looked, and nothing prompted them to look again. Registering because a peer nearby just did is the specific error to expect after any visible activity in a workspace.

## Members: the ownership registry

```
- label:     <developer-conferred name>
  owns:      <org-relative path(s), comma-separated>
  expert:    <domains this agent is the expert in>
  workspace:    <the container's name, as a person would say it>
  assigned:  <date the developer conferred this, UTC date only>
```

**The registry holds owners, and owners are rare.** Most sessions are task threads scoped to a piece of work, not to a domain, and they **register nothing and own nothing**. Observed directly: one workspace held ten concurrent sessions named for tasks (`Arranger docs`, `Arranger Release flow`, `SQONs, Facets and SQONViewer`, `Review Charts PR from Ann`) and exactly one named for an owner. A task session working inside a repo is doing developer-directed work under that repo's owner, not becoming its owner, and registering it would claim a boundary it does not hold. If you are unsure which you are, you are a task thread.

**Every field is stable, meaning nothing here decays on its own.** That is the point: there is no session-start refresh, no staleness check, no handshake to keep it current, and no timestamp that has to be re-stamped. Read it as a claim about the *fields* and not about the *content*, though; a value written wrongly stays wrong, since nothing revisits it (see `expert` below). An entry written once stays true until ownership actually changes. This is the property the old `id` and `focus` fields did not have, and maintaining them was most of this file.

**`label` is developer-conferred, never derived.** An auto-derived session name is a resolved-`cwd` artifact and can be a complete mismatch for what a session actually does, especially in a multi-root workspace where every session resolves to whichever folder is listed first. `label` is the stable name a developer would actually say.

**`owns` is the resource boundary, and it is what makes ownership checkable.** Paths are org-relative (`overture/lyric`, `overture/lyric/apps/ui`), never absolute: an absolute path encodes one machine's home directory and one clone location, and belongs in no shared file. Ownership may be a subtree, so a monorepo can have several owners.

**`expert` is what the developer conferred along with the label**, and it is what makes a question routable. It answers "who should I ask about ABAC token schemas", which `owns` cannot. Unlike a "current focus" field, it stays true between sessions, which is why it replaced one.

**`expert` inherits the exact failure `focus` had, because the decay was never in the field.** It arrives through the author: whoever fills it in writes from what is salient to this session, and what is salient is this week's work. Reported by a session whose developer caught it twice in a single draft. First it listed the things that session had just finished fixing, and was told it read as recent work rather than as knowledge carried about the services owned. Then, generalizing to avoid that, it described a service as "Kafka-driven" as though that were the defining mechanism; the developer knew that was merely the most common deployment, and the session confirmed against the service's own README that automatic sync and direct indexing are two coexisting modes. The second error is the more instructive, because it was not merely narrow but **wrong**, reached by generalizing from personal recent use instead of checking the source.

**Stability cuts both ways, which the claim above omitted when it was first written as the design's virtue.** A field nothing refreshes is also a field nothing corrects. `focus` was accidentally self-healing, since it was rewritten every session and last week's error went with it. `expert` is written once and read for months, so an error at authoring time is permanent. The absence of a refresh burden raises the authoring bar rather than lowering it.

**The tell is the writer-side twin of the test in `entry-formats.md`.** That one asks whether a reader with no memory of the work would need the sentence in order to act. This one asks: **would someone who had not touched this code this week write this sentence?** If it only occurs to you because of what you just did, it belongs nowhere in this field. And where the answer turns on what a service actually does, check the service rather than generalizing from your own experience of it, which is how "most common deployment" became "defining mechanism".

**A second, independent drift: writing at the mechanism level instead of the responsibility level.** Reported from the same draft, after the recency problem was already fixed, and it matters that the two are orthogonal. "SQON querying", or "via Kafka-driven sync or direct indexing calls", passes the recency test cleanly: durable, general, nothing to do with this week. It is still wrong, because it answers *how a service works* when the field exists to answer *who to ask about it*. The developer's phrasing was that implementation details are noise. The fix was dropping the "how" clause entirely and naming what each service is responsible for: data submission and validation for one, keeping search results consistent with repository data for the other, rather than the mechanisms by which either happens.

**So run both tests, because neither catches the other.** Recency asks whether this week produced the sentence; abstraction asks whether the sentence routes a question or explains a machine.

**Mechanism detail is worse than noise here, on two counts.** It misroutes rather than merely padding: an entry reading "Kafka-driven sync" tells someone holding a direct-indexing question that they have the wrong agent, narrowing apparent scope below actual scope. And it decays, since implementations change while responsibilities do not, which in a field nothing ever refreshes means it rots in place.

**Use the form, because the form enforces what the prose above only asks for:**

```
Service (one-clause role, never a mechanism)[, Service (role)...][, and how they relate]
```

An `expert` value in that form, for a label holding two services that genuinely interact:

```
Lyric (data submission and validation service), Maestro (indexing service for Song and
Lyric), and the contract between the two.
```

**This is a template rather than a nice example, and the distinction is the point.** A one-clause parenthetical has no room for a mechanism, so "Lyric (SQON-queried, dictionary-validated submission service)" visibly overflows its slot; a prose warning about implementation detail can be argued around, and a slot cannot. The same shape closes the recency axis at the same time, since a one-clause role statement has nowhere to put "just fixed the `IN`-clause bug". One form crowds out both failure modes, which is a stronger claim than "copy this": the shape does work that neither written warning managed alone. It is the same reasoning as `docs/deterministic-by-design.md`, applied to a prose form instead of a script.

**The final clause is optional, and often does not apply.** Omit it for a single-service label, where there is nothing to reconcile, and omit it for a grouped label whose services simply do not interact. Do not reach for it because the form shows it.

**When it does apply, it is not boilerplate and should not be trimmed as such.** It names a third kind of expertise that two side-by-side descriptions silently lose: two solo descriptions say only "I know A" and "I know B", while a label holding both may also know how A and B have to agree, which is the one question neither service's own single-repo owner can answer. That is a claim about the clause being non-redundant *when present*.

**It is not a claim about a grouped label needing one, and an earlier version of this paragraph said otherwise.** It held that the cross-service contract was what made a grouped label real. That is wrong: the registry's justification for every entry, grouped or not, is that the developer conferred it, which is already sufficient everywhere else here. A developer may group services for staffing, for wanting a single point of contact, or for any reason they choose, and none of that needs defending with a claim about irreducible knowledge. Requiring a grouped label to name a technical contract would impose a registration barrier this registry was never designed to have. Corrected by the session that proposed the form, when asked to check the extension, and independently by the developer noting the clause had been hardwired into a shape where it does not always belong.

Developed by a session across three corrections to its own draft and abstracted at the developer's request, on the grounds that a phrasing surviving that many rounds is worth generalizing rather than leaving in one entry.

**`assigned` records that this was conferred rather than inferred.** An entry without it is provisional: something an agent drafted from context, correctable by anyone who knows better. An entry with it is authoritative, and narrowing or overlapping it requires the developer to say so. This is the same principle applied elsewhere in this file: a value carries its derivation, not just its content.

**`workspace` vs. `scope`.** `workspace` is the literal container: would closing this specific workspace end this session and any others sharing the value? It is the name a person would use for the container, not a handle's prefix, which is generated from whichever folder a workspace happens to list first and therefore names an artifact of ordering. A prefix identifies a workspace and never a project.

**`workspace:` names the container, not the team or the product, and its casing follows whatever that container is actually called.** A workspace named `SoftEng` does not contradict a team written `softeng` elsewhere, because the field records a proper noun for a window rather than a reference to an organization. Confirmed directly by the developer for one workspace, after a peer relayed the same answer twice and it was held as uncorroborated both times. Repetition by a single source is not a second source, and an earlier rule shipped on relayed developer intent flagged the correct entry as an error.

**Compare workspace values case-folded, and do not enforce a casing.** Peer status is decided by this field, and peer status is what licenses guessing a recipient when you introduce yourself, so two spellings of one workspace split it in half and each half stops reading as peers of the other. This was live rather than hypothetical: `Arranger` and `arranger` named one workspace whose members were already messaging each other, and read literally the registry denied it. `check-agent-index.sh` reports the variants as a note rather than an error, since no single casing is canonical across workspaces.

## Ownership resolves by longest prefix

A path belongs to the entry with the longest `owns` value that is a prefix of it. Given:

```
Overture            owns  overture/
Lyric and Maestro   owns  overture/lyric, overture/maestro
Lyric UI            owns  overture/lyric/apps/ui
```

`overture/lyric/apps/ui/App.tsx` is Lyric UI's, `overture/lyric/packages/data-model/x.ts` is Lyric and Maestro's, and `overture/song/y.java` is Overture's.

**Containment is normal, not a collision.** Only two entries claiming the *identical* path are an error, which is mechanically checkable. A subtree owner nested inside a repo owner is the expected shape.

**Longest prefix routes expertise; it never confers permission, and reading it as authority inverts the hierarchy.** A narrower entry is a narrower mandate rather than a higher one. The registry answers who to ask, who to notify, and whose judgement governs a question about that subtree, and it answers nothing about who may act.

**The decisive argument does not depend on anyone's say-so: registering a narrower expert must add coverage, not subtract authority.** If a sub-entry fenced the parent out of its own subtree, then registering depth would silently remove capability from the owner of the whole, and the rational move would be never to register a sub-expert at all. **So the owner of the enclosing tree holds the big picture and may override a narrower expert**, which is the relationship the registry was built to describe and the opposite of what longest-prefix reads like.

**The failure this produces is invisible because it looks like good manners.** Reported by an owner who was preparing a commit split across a repository they own, found three files resolving to a narrower expert, and held them back with a note that a `CHANGELOG` entry would have to move because it documented something now left uncommitted. Nothing flagged it: over-deference does not read as an error, and they would have shipped a worse split as the considered outcome. A stall on a judgement call is visible, and a stall on a question the registry has already answered wrongly is not.

**Keep this separate from validation, because the fix runs the same risk in the other direction.** Owning the enclosing tree says nothing about whether content inside it has been checked. In the reported case the correction removed the ownership question and left the validation one untouched, and the procedure for unattributed working-tree changes still ran and still did real work. Whose it is and whether it has been verified are independent, and conflating them while fixing this would be the same class of error reversed.

**This covers residual ownership without needing a second mechanism.** The owner of the shortest matching prefix owns everything beneath it that no more specific entry claims. Its coverage is never enumerated and never needs updating, so assigning a new owner is always a pure narrowing that touches no other entry. It also means unowned is never ambiguous: an unclaimed path resolves to the nearest enclosing owner rather than to whoever happens to have the directory open, which is where work absorption starts.

**Developer-designated roles never travel with the workspace.** A workspace-lead designation, or anything else marked as conferred rather than self-assigned, belongs to the agent it was given to. A different session opening the same workspace does not inherit it.

## Identity is conferred, never inferred

**A session cannot determine who it is from anything it can observe.** Every ambient signal is shared by every session in the container: the runtime handle prefix, the workspace, the repository, the working directory, the git branch. Any self-identification test returns true for every new session in that container, so it produces a false positive exactly when a fresh session opens. This is a property of the environment rather than a gap in a particular rule, and it has been hit four separate ways: by handle, by workspace, by prefix, and by cwd. Inside a monorepo with co-owners there is no observable difference between two agents at all.

**But identity is observable from outside, and that is the half that works.** A peer learns who you are the moment you message them, because an inbound message carries the sender's session display name alongside its reply address (for Claude Code, a `from-name` attribute next to the socket `from`). Whether you can see your own varies by tooling and is worth rechecking rather than assuming: in Claude Code as of 2026-08-24 a session listing reports the caller's own handle, where an earlier build omitted it and left a session dependent on a peer to learn its own address. **The part that does not vary is the part that matters: a handle is an address and tells you nothing about which label was conferred on you.** So a tooling change can close the address gap without touching the identity gap, and this file's ladder rests on the second. So the asymmetry is not that identity is unknowable, it is that it is unknowable *to its holder*.

**A display name only carries identity once someone has set one, and the fallback is a trap.** An unnamed session's `from-name` is its runtime handle, not a name, so a message can arrive announcing `from-name="arranger-cf"`. Confirmed live while testing this rule: the reply that verified the mechanism also defeated it, because the sender had no name set. Treating that value as a label is exactly the "never use the address as a name" error below, arrived at through the mechanism meant to prevent it. **So check before trusting it: if `from-name` is the sender's handle, or matches the shape of one, the session is unnamed and you have learned nothing about who it is.** Say "an unnamed session in workspace X" rather than repeating the handle as though it were a name, and ask if you need to know.

**That splits two values this file previously conflated.** The display name is **identity**; the socket or handle is an **address**. They have different lifetimes and different jobs, and the deleted `id` field failed largely because it was asked to be both.

**So conferral is a rename, not a sentence typed each session.** Naming an owner session with its label in front, for example `(Usher) User Access Control for Overture`, is the whole mechanism: the developer is the only party who can confer, the name persists for the session's life without being retyped, and it reaches every peer automatically on first contact. A session called `Arranger docs` is visibly not an owner, which is information a reader gets for free.

**The name is unverified and that is acceptable here, but know why.** Nothing authenticates a display name; it is whatever the developer set. That is sound precisely because the developer is the conferral authority, so a name they set *is* the conferral. In a setting with more than one developer, or any adversarial party, it would carry no weight at all.

**None of this lets a session identify itself.** The name is not readable from inside the session, so a session still holds no identity until told, and the default below is unchanged.

**A label a session states about itself is good enough for routing, and it is often all there is.** An earlier version of this file was sceptical of self-reported labels, on the grounds that they carried none of the weight of an identity derived from a listing. That scepticism made sense when identity was thought derivable. It is not: conferral happens in-session and no peer can verify it, so the holder saying which label it holds is the primary channel and not a weak substitute for one. Demonstrated directly: a probe reached the wrong session, whose display name was its own runtime handle because none was set, and whose reply nonetheless identified it correctly in its first sentence. Nothing else would have.

So the ranking is: a **developer-set display name** is strongest, because the party who set it is the party who confers; a **label stated in the message body** is adequate and is the normal case while sessions go unnamed; an **inference from handle, workspace, or working directory** is worth nothing and is forbidden.

**The distinction that matters is routing versus authorization.** Accept a self-reported label as the answer to "who am I talking to", record it, and route by it. Never accept one as grounds for granting anything: mail, ownership, or a conferred role. Those turn on what the developer told *that session*, which is why claiming is gated on its own conferral rather than on anyone's assertion.

**Default to having no identity.** A session that has not been told which label it holds owns no entry, claims no mail, and holds no designated role. Assume new. A matching workspace, repository, or working directory is not evidence, and the resemblance is strongest precisely when the inference is wrong.

**Developer-directed work is always authorized, whatever your identity.** The ownership boundary constrains what an agent does on its own initiative, not what the developer asks for. If they open any session and ask for a fix in a repo, that is authorized by definition and no identity check gates it. Reading another owner's code to answer your own question is likewise always fine: reading transfers no work.

**But route the knowledge even when you cannot route the work.** When you do work outside your own `owns`, leave a note for the owner (a `.dev/` entry in their project, or a Requests post). The developer relies on a specialist's accumulated context as live expertise, and that context only grows if what happened reaches it. Work landing in the wrong session is recoverable; the knowledge never arriving is not.

**Read that as a change being introduced, not a description of what already happens.** A session in a workspace full of task threads reported the opposite as the current norm: task-scoped sessions operate independently on a narrow scope, coordinate through the developer rather than through any index, and the owner finds out later through session files or git history, if at all. That is the behaviour this rule exists to change, so do not read "works under the owner" as implying the owner was consulted. The note is the entire mechanism, and it is one you have to actually write.

## Registering and changing ownership

**A peer's account of what the developer decided is a hypothesis, not the decision, and this holds even when the peer is the one it was said to.** Confirmed twice in one day, in both directions. A session declined to treat this session's reading of a developer objection as settled, and went to ask rather than act, which was right. This session then did the opposite: it took a peer's report of a developer decision about a field's format, shipped a hard error enforcing it, and relayed the change to a third party as fact. The reporting session retracted within the hour, having over-applied a distinction the developer drew about something else. Nothing about the peer was unreliable; second-hand intent is simply not the same object as intent, and a peer reporting it in good faith cannot make it one. Ask, or act in a way that is cheap to reverse, and never enforce it mechanically until it is confirmed.

**Registration is the developer conferring a label, and the agent recording it.** Draft the entry from the conferral and the visible context, state it back, and get a confirmation before writing: this is a file shared across every project the developer works in, not a local decision.

**Before writing, run the check rather than doing it by eye:** `bash scripts/check-agent-index.sh` from the agentics clone, which reads `~/.claude/agent-index.md` by default and takes a path otherwise. It reports duplicate paths, absolute paths, entries still on a pre-registry schema, and the resolution tree that longest-prefix matching actually produces, which is the part hardest to verify by reading. It never edits.

**Then check the new `owns` paths against every existing entry.** Two outcomes, and only one of them is mechanical:

- **Identical path already claimed: a hard error.** Resolve it before writing anything.
- **Nested, overlapping, or similarly-named: ask the developer.** A new "Lyric UI" owning `overture/lyric/apps/ui` produces no path collision with "Lyric and Maestro" owning `overture/lyric`, because containment is legal. The overlap is conceptual, and only the developer knows whether the new label narrows the existing one or is unrelated. Ask with options rather than open-ended, since they are mid-conferral: is this a new resource with no narrowing, a subtree taken from the existing owner, or a replacement of that assignment?

**A conferral onto an already-`assigned` label triggers the same question.** If the developer confers a label that is already assigned, ask whether this session replaces that assignment or is a second session for the same scope. This does not eliminate duplicate ownership, since the answer could still be wrong, but it removes the silent path: a double claim now requires an explicit answer instead of happening unnoticed.

**"Write only your own entry" is about intent and protects nothing against a stale read.** A session that read the file earlier, edits its own entry, and writes the whole file back silently discards everything written by anyone else in between. Reported by a session whose migrated entry was reverted to the pre-migration schema after it had confirmed the entry clean; it noticed only because a file-change diff happened to surface it, having had no reason to re-read. That is a lost update, and it is another instance of the failure class in `docs/deterministic-by-design.md`: the writer's operation succeeds and looks correct, while the loss is visible to nobody at the time.

**So the write is three steps, and the third is the one that matters.** Re-read the file immediately before writing, never from a read taken earlier in the session. Replace your own entry's lines in place rather than rewriting the file from a copy you are holding, so a concurrent change outside your entry survives. Then **re-read once more and confirm your entry is present and the file has not lost entries**, because narrowing the race does not close it and the check is what converts a silent loss into a visible one. If something you wrote is gone, restore your own entry and tell the sessions whose entries vanished; do not restore theirs from your copy, which is how a stale read propagates.

**Write only your own entry.** If a split takes territory from another owner, record your own narrower entry and flag the overlap; do not edit the incumbent. The incumbent reads the registry at its next session start, sees the overlap, and narrows itself. This is self-healing, needs no cross-editing, and works even though the incumbent was not running when the split happened. It is "another session's work is not yours" applied to the registry itself.

## Peer coordination

Sessions sharing a workspace are peers. They share a container, and often a working tree, so they are the sessions most likely to collide and the easiest to reach. **A session in a different workspace is not a peer**, however closely its work relates to yours: the word tracks the container rather than the subject matter, because everything peer status buys you (a shared handle prefix, shared memory, a shared working tree, reachability by one announcement) comes from the container and from nothing else.

**The workspace lead is the local routing point**, and it is whoever owns the workspace's first-listed folder. It accumulates the handle-to-label map for its own workspace: small, rebuilt naturally, held in session rather than persisted, and therefore never stale. It is a per-workspace directory that costs nothing to maintain, unlike a global one.

**The workspace lead announces itself; newcomers do not go looking for it.** An earlier version had this backwards, telling a new session to introduce itself to the workspace lead, which requires finding the workspace lead, which is the problem being solved. The direction follows from identity being knowable only from outside: **the only party who knows a conferred role is its holder, so the holder has to speak first.** A workspace lead announces once per session to the sessions sharing its workspace, and every newcomer then has a known address to introduce back to.

**Hearing no announcement means you have no address for a workspace lead, and never that there is none.** A broadcast reaches only the sessions alive when it went out, while sessions keep arriving afterwards, so a session that starts after the announcement hears nothing and would draw the false conclusion in precisely the case where a workspace lead is running and has already spoken. An earlier version of this rule licensed exactly that inference and called it "true and useful". It is silent when wrong and reads as a correct conclusion, which is the failure shape this file is otherwise careful about. Raised by an unnamed session in the `arranger` workspace, about the mechanism that replaced its own earlier proposal.

**An announcement is unverifiable, which is a worse problem than its coverage gap.** Nothing records that one was made, the sender learns nothing about who received it, and a session that heard none cannot distinguish "never announced" from "announced, missed me". Confirmed by asking: a workspace lead was asked to announce, and a peer alive in that workspace throughout reported that nothing arrived, leaving no way to tell which of the two happened. A mechanism whose success and failure are indistinguishable cannot be relied on and cannot be debugged.

**So the durable note is the primary record and the announcement is the fast path, not the other way round.** An earlier version had this backwards, treating the note as coverage for latecomers. The note is the only auditable artifact: it is checkable by any session at any time, including by the announcer confirming it actually did the thing, while an announcement is a transient event that leaves no trace anywhere. Write the note first, then announce; if only one of the two happens, the note is the one worth having.

**So pair the announcement with something durable, because their failure modes are complementary rather than overlapping.** An announcement is the better address channel and cannot be a substitute for a persistent one: it carries a live address, which a note cannot, and it is point-in-time, which a note is not. A note in the workspace's own memory space is read at every session start regardless of arrival order, which is the one property a broadcast structurally cannot have. Record the *fact* there ("this workspace's workspace lead is labelled X"), never an assertion about the reader ("you are X").

**The reason is that a workspace-shared file has no addressable reader, so the second person is always a guess.** Its audience is every session in the workspace, which means any sentence written in the second person addresses someone the writer could not see and did not choose. "This workspace's workspace lead is labelled X" is checkable by a reader against what it already knows. "You are X" asks a reader to accept a claim about itself that the writer had no way to verify, which is how a note written for one session fires on another doing unrelated work. This is the routing-versus-authorization distinction applied to a file instead of a message, and it generalizes past this note to anything written where the whole workspace will read it.

**A conferred role is invisible until someone says it, and a session name will not carry it by default.** Confirmed the hard way: a workspace's workspace lead was named `Search Server - multicatalogue`, indistinguishable from the task threads around it, and a probe sent to the wrong candidate reached a session that could only pass along a third-hand guess about which one was the owner. Neither the name, nor the handle, nor the working directory encoded the assignment. Nothing does, until the holder announces it or the developer puts the label in the name.

**Introductions may guess; substantive messages may not.** Misroute tolerance differs by message type, and this is what makes the bootstrap work where address lookup does not. "Hi, I'm Lyric UI, are you the workspace lead here?" costs one message, carries no claim, and self-corrects if wrong, so route it cheaply: pick any session sharing your workspace's handle prefix and ask it to answer or relay. A work request or a state claim gets no such latitude, and needs an address that came from a reply or an introduction.

**An introduction needs no "who are you" round trip in return.** The reply carries the responder's display name, so a session that answers has already identified itself. If owner sessions are named with their label in front, the workspace lead learns the whole workspace by receiving introductions, and nobody has to ask anyone who they are.

**Say what you own when you introduce yourself.** That is the coordination that matters, especially for co-owners of one repository: each needs to know the other's boundary before either starts editing.

## Reaching an owner

**Warm contact: reply to whoever messaged you.** An inbound message carries a live, known-good address, valid for the rest of the exchange. This never misroutes and needs no lookup.

**"For the rest of the exchange" is the whole guarantee, and a relayed address is a stored address with extra steps.** A reply address is good where you received it and nowhere else. Confirmed the hard way: a bridging peer kindly passed on a third session's live address from a conversation earlier the same day, and the send failed with the socket already gone while a listing showed nothing in that workspace having restarted. So every lesson about stored handles applies to a handed-over address, including the one about it looking usable right up to the moment it is used.

**Say an address is *uncorrelated* with session lifetime, not that it *rotates*.** The distinction is not pedantic, and a peer supplied both halves of the evidence: one session's recorded handle changed with no restart at all, while another's was unchanged a full day later, same handle and same ref. So neither a changed handle nor an unchanged one licenses any inference. "Rotates" quietly implies a schedule, and a reader who believes in a schedule will trust a fresh-looking value for whatever interval they imagine it holds, which is the belief this rule exists to remove. Persistence is not a property you can rely on either; it is a coincidence you may observe.

**So ask a bridge to relay the request, never to hand over its channel.** An address cannot be inherited: it belongs to the exchange that produced it. If you would rather make contact yourself, address by handle from a listing fetched at send time, which is the only address current by construction.

**But a relay is not guaranteed either, because prior contact decays into knowledge and not into reach.** Confirmed by the bridging peer, which attempted its own relay after the handed-over address failed and hit the same dead socket: its access had gone stale unused since it was established. So what survives prior contact is the *identity* half, that a session exists and holds a given label, while the *address* half dies on the same schedule as anyone else's. A bridge asked to relay may simply find it cannot, and that is not a failure of the bridge.

**Which is why self-selection is the terminal mechanism rather than a fallback.** Every other path depends on somebody holding a live address: your own, a bridge's, or one you were given. A Requests post depends on nobody's, because the target initiates and its first message carries a working address by construction. So the order is: reply to an inbound message if you have one, ask for a relay if a peer may still reach them, probe candidates if the set is small, and post to the board, which is the only step that cannot be defeated by every address in the system being stale at once.

**A relayed *identification* is a stored mapping, and decays the same way a relayed address does.** "Session X holds label Y", told to you by a peer, is a fact about the moment they observed it, so carrying it forward is storing a mapping whose two halves have independent lifetimes. Raised by the peer who had supplied one: a candidate they named the previous day did turn out to still be live, and they pointed out that this was luck rather than verification, since neither of us had checked. Apply the same standard to a mapping you were given and to one you are giving: what makes it sound is the listing fetched at send time, never that it was right yesterday.

**Cold contact: post to Requests, or bridge through a peer.** Look up the owner in Members to learn the `label` and `expert` you are aiming at, then either post a topic-qualified Requests entry and let the right session self-select, or, if you need someone live now, ask one session in their workspace to answer or point.

**No one can join a display name to a handle without sending a message, and the two halves are held by different parties.** The listing shows handles and no names, to every session equally, inside a workspace and outside it. The developer sees names and no handles. So an agent holds one half, the developer holds the other, and neither can complete the join alone: the only thing that produces both at once is an inbound message, which carries a name beside an address. Confirmed by asking a session inside the target's own workspace, which had exactly the same handle-only view and would have had to probe its neighbours one at a time, the same work available from outside.

**That is what makes the announcement load-bearing rather than a courtesy.** Without it, finding a named session costs a probe per candidate, every session, forever, and asking the developer does not help, because they cannot see handles either. With it, one message from the holder gives every peer the join for free. Do not treat announcing as optional politeness; it is the only mechanism that makes named sessions reachable at all.

**An announcement is workspace-scoped, and that is sufficient, because it turns every session in the workspace into a bridge.** An outsider never receives it and does not need to: the members did, so any one of them now holds the join and can answer for the cost of a single question. This is how a local broadcast becomes globally useful without anyone broadcasting globally, and it is why the two rules above depend on each other. The announcement is what manufactures the prior contact that makes a bridge worth asking; a workspace where nobody has announced has no usable bridges in it, only neighbours who know as little as you do.

**Ask one session, never broadcast.** A peer is still worth asking, but for a narrower reason than co-location: it may have *already spoken* with the session you want, and therefore already hold the join. A peer that has not is no better placed than you are. Prior contact is what makes a bridge useful, not proximity. Messaging every candidate costs N messages instead of one, interrupts sessions with nothing to do with the question, and delivers the same claim to several readers at different moments, which is how one of them reads a statement that was true when sent and false on arrival.

**The registry is deliberately incomplete, so never reason by elimination across it.** Owners-only membership means the registry excludes the majority of any workspace's sessions by design, which makes arithmetic like "these two are accounted for, so it must be one of the other two" structurally invalid rather than merely risky. Under the previous schema an unlisted session was an accident of staleness; now it is the expected case. Caught in use: this session eliminated its way to two candidates in one workspace and was answered by a fourth session that owned nothing, appeared in no entry, and was reachable only by the probe already sent. Completeness went from aspirational to explicitly disclaimed, and any inference resting on it should have gone with the old schema.

**Never guess from a handle, but know that a probe is cheap and a claim is not.** The prefix is derived from a resolved working directory, so several sessions on one repository produce near-identical handles that distinguish nothing, and in a multi-root workspace the handle derives from whichever folder is listed first rather than what the session works on. Confirmed directly: a session dedicated to one service was listed under a different project's prefix. So a handle never tells you who someone is. What has changed is the cost of finding out: a reply names its sender, so addressing a guess with a question resolves it in one exchange and a wrong guess is visibly wrong rather than silently wrong. Send a probe to a candidate freely; never send a claim, a task, or state to one.

**Never break a tie by start time.** An earlier version of this rule said to prefer the most recently started candidate. It is withdrawn: it failed three times in a single day, twice sending another project's breaking-change notice to a session that owned something else. Process start time carries no information about which session is active or what it was assigned. Recency reads like evidence and is not, which is worse than having no tie-breaker, because it converts "I don't know" into a confident wrong answer.

## Waiting for a peer, and what a listing will not tell you

**A listing shows presence, not availability.** Rows carry a mode and a start time, not a busy or idle state, so nothing in one tells you whether a session is mid-turn. Do not infer readiness from a listing, and never poll one in a loop to find out.

**Where the capability exists, subscribe to a peer going idle rather than polling.** In Claude Code the message send takes a flag registering a one-shot notice for when that session next goes idle or exits, and it can be sent with no message at all, which costs the peer nothing. Verified end to end on 2026-08-24: an empty subscription returned success and the notice arrived when that session finished.

**But the call reports success whether or not it will ever deliver.** The confirmation says as much, that a permission-class mismatch downgrades the notice to a local log entry, and a caller cannot tell "not idle yet" from "never arriving". That is this repository's named failure shape arriving in the tooling instead of in a check we wrote. So treat a subscription as an optimization on waiting and never as a precondition for proceeding: if the work needs an answer, ask for one and let the reply be the signal.

## Mail, and deciding whether it is yours

**Every message and board entry names a `label`, never a role.** "For the workspace lead of this workspace" is unresolvable by construction, because the role is ambient and every session in the container matches it. "For Arranger" is resolvable, because a label is conferred and a session either holds it or does not. This removes the failure mode structurally instead of warning against it.

**Claim mail only if the developer conferred that label in this session.** Otherwise surface it without claiming: "there is a board entry for Usher; I have not been told I am Usher." That is the correct output rather than a failure, and it is strictly better than silence, because it routes the one question only the developer can answer. Acting on mail addressed to a label you were not given is the same error as claiming an entry because the workspace matched.

**Opening this file is itself a trigger to check for entries addressed to you**, whatever brought you here. You came to look someone up, and the check costs one read of a file already open.

**Relay what you see.** A session with an entry waiting may have no reason to open this file at all, and quiet sessions are the ones most likely to be waited on. If you are already in contact with a session that has mail here, tell them.

## Requests: the bulletin board

For reaching an owner with no confirmed live session. Payload-free by design: it is a handshake, not a channel.

```
- for:      <label of the owner needed>
  from:     <label of whoever holds the need; they clear it>
  via:      <your label, when posting on someone else's behalf; a relayer never clears>
  re:       <short topic, a name and never a finding or task detail>
  heard:    <label that answered; omit the line entirely while unanswered>
  posted:   <UTC read from a clock, e.g. 2026-08-19T23:06Z>

- fyi:      <label affected>     a notice: reports a change already made and wants no reply
  from:     <your label>
  re:       <what changed, named rather than described>
  by:       <the authority that permitted it>
  posted:   <UTC read from a clock>
```

**Topic-qualified, no payload.** `re:` exists so the right session can self-select. Put the substance in the direct exchange that follows, not here: a board entry is read by everyone and outlives the moment it was written.

**An optional urgency opener inside `re:`, not a separate field.** A poster who considers something time-sensitive prefixes the topic with a single fixed word and a period, for example `re: urgent. UI components`. Binary only, present or absent. Treat an absent opener as routine, and never infer urgency from the topic string's own tone or length.

**Timestamps are UTC with the `Z` suffix, and read from a clock rather than guessed.** `posted:` is the only staleness signal the board has, since the surface-after-a-day rule is computed from it, so a guessed value qualifies an entry for escalation the moment it is written. Both halves were observed. Two posts minutes apart in reality were written four hours and one calendar day apart, because each agent independently picked local or UTC and nothing said which. And an entry posted minutes earlier carried `2026-08-23T00:00Z` on the 25th, two days of false age; a zeroed time reads as a placeholder to anyone who looks and the rule is applied by readers who do not, which is what makes it worse than an obviously missing value. Derive it mechanically with `date -u +%Y-%m-%dT%H:%MZ`. `check-agent-index.sh` flags a midnight timestamp, and the zeroed pattern is valid only when migrating a historical record whose real time is genuinely unknown. Leave a bare legacy value for its own poster to restamp rather than converting it, since reclassifying an ambiguous value is a guess presented as a conversion.

**A message asserting current state is stale by the time it is read.** A message freezes when sent and the state it describes keeps moving. Confirmed directly: three sessions were told at once which entries were incomplete, one replied, the file changed, and by the time a second read the same message the claim no longer matched. It was true when sent and false when read, and the recipient correctly refused to act on it. Either say when a claim was true, or name the file and let the reader check it live.

**`heard:` carries a label, not a handle, and the earlier definition contradicted this file's own rule.** It read "handle that answered", in a file stating that no runtime handles are stored in it in any field. A handle would also be the wrong value on its merits: the entry may outlive the answering session, and a poster reading a dead handle learns nothing except that something once existed. A label stays resolvable.

**The responder writes `heard:`, and this is the step that was missing.** Nothing said who fills that field, so nobody did: six entries stood open between five and thirty-two hours old with not one `heard:` line among them, several of them already answered. The field is not decoration, it is how a poster learns their request was met.

**Answer by any route, then record it here.** Most contact succeeds by direct message rather than through the board, so success never propagates back on its own: the poster has no way to observe an exchange they were not part of, and the entry outlives the need. If you answered, say so in `heard:` even though the answering happened elsewhere, and say so in the reply too, naming the entry, since the poster may not connect a conversation to a post they made a day earlier.

**Record what you actually did, not what you hope happened.** If identity was unconfirmed, `heard:` still belongs there, because "someone answered, possibly not reaching you" is far more useful to a poster than silence. They can clear it or say it never arrived; neither is possible against an empty field.

**Omit `heard:` entirely while an entry is unanswered, rather than leaving it valueless.** Entries sit outside a code fence, so markdown collapses consecutive lines into one paragraph, and an empty field has nothing holding its boundary open: the following line runs into it and the entry renders as though the two were merged. The schema above shows the field with a placeholder and previously said nothing about the unanswered case, so a poster following it produced a valueless line by doing exactly the right thing. Reported by the session whose own entry rendered that way.

**Clearing is the poster's job**, since only they know whether the need was met rather than merely responded to. `heard:` is what tells them to look.

**Board-check signals, because until now nothing ever sent anyone to the board.** It had posting rules, clearing rules, a format and a staleness threshold, and no trigger that caused a reader to open it. Entries went unread for days, and the one that eventually surfaced did so because a checker began counting them rather than because any signal pointed at the file. Treat each of these as a reason to read the board, before touching a session listing:

- the developer relays that someone is looking for you
- you are told there is a message for you and cannot find one
- you are about to probe several handles to locate one agent
- you return after any gap holding a label others may have needed

**"Someone is looking for you" is evidence that direct addressing has already failed.** Had it worked they would have reached you, and nobody would be relaying. So the phrase that most reliably means *check the durable channel* was the one sending agents to the ephemeral one. The same reading applies to the relay itself: a developer acting as the bridge is doing the work this board exists to remove, so hearing it at all is a symptom rather than a routing instruction.

**Read the board before the listing, because the two fail under opposite conditions.** A listing is current and unresolvable: it shows every live handle and tells you nothing about which label any of them holds. The board is stale and precise: it may be days old and it names labels. When contact has already failed, the failure is nearly always identity rather than liveness, and identity is the half only the board answers. The cost difference is not marginal either, since the alternative observed here was messaging seven same-prefix sessions to find one.

**Surface anything still open after a day, not after a week.** The original threshold was a week, which was calibrated for nothing: contact here resolves in hours or does not resolve at all, so a week means a board silently accumulating for days. The developer noticed this one at between five and thirty-two hours, which is the real timescale.

**A relay splits the roles the single-party wording assumed.** "The poster clears it" holds when a session posts for itself and fails on a relay, where the poster cannot know when the other party is satisfied and that party cannot clear a line they did not write. Reported by a session on the receiving end after a peer bridged for them. The rule's subject moves rather than the rule: whoever holds the need clears it, which was always the reasoning, so `from:` names them and a `via:` relayer never clears.

**The two shapes differ in what the poster wants.** A request wants an owner to act. A notice reports something already done and wants nothing, and declaring that is the entry's job rather than the reader's inference.

**"The poster clears it" carries an unstated assumption that the poster holds the need.** That holds when a session posts for itself and fails on a relay, where the poster cannot know when the other party is satisfied and the other party cannot clear an entry they did not post. Reported by a session on the receiving end of exactly that: a peer bridged for them after their own contact went dead, so the entry named the bridge and the need belonged elsewhere.

**The recipient clears a notice, inverting the request rule and for the same reason.** A poster clears a request because only they know the need was met; a recipient clears a notice because only they know they have read it. A notice also carries no `heard:`, since there is nothing to answer, which removes the collision a request has when the answer arrives fast enough that writing `heard:` and clearing touch the same lines.

**`by:` is the load-bearing field and it names an authority, not a justification.** Without it a reader cannot separate a directed edit from an agent that overreached, and those want different responses. "Unreachable" is not an authority: being unable to ask an owner feels like permission and is not, which is the trap this exists to close.

**Use it whenever you change something another agent owns**, which you may do only on a developer instruction, per the write-only-your-own-entry rule this does not soften. Shared scaffolding is out of scope, since a header has no owner to notify and every reader sees it anyway.

**Why not attach the notice to the changed entry instead:** it was considered and rejected. A field on the entry needs parser support in every reader, and splits "things to tell you" across two places when one already exists. The board also gets counted by `check-agent-index.sh`, which is the only push either shape has, since nothing notifies anyone that a board entry exists.

**A notice is not a payload.** `re:` still names a thing rather than describing a finding or a task, and `by:` names an authority. That boundary is what keeps a handshake board from becoming an instruction channel, which is worth protecting: a payload-free entry cannot be mistaken for an order, and a session receiving one asks who is calling rather than acting.

## Relaying: the quoted words and the referent decay separately

**A relay can be solid about what was said and unreliable about what it meant or who it was for.** Mark that boundary when you relay, and read it when you receive one. A session passing on a developer's sentence usually has the sentence first-hand and the referent by inference, and those two halves deserve different weight from the reader.

Worked instance, supplied by the relaying session unprompted. It could vouch that the developer wrote "I asked agentics to help redefine the writing parameters" in that session, in those words. It could not vouch for who he said it to, whether the receiving session was the one meant, or whether "asked" described a request in flight or an intention. The sentence is evidence; its referent is a guess that reads as part of the same report.

**The general defect is a claim written at wider scope than its evidence supports**, which is the same shape as a report naming a boundary when it observed an instance, and as a finding asserted universally when it was measured in one environment. Here it is load-bearing because the receiving session's next move is either "act on an instruction" or "verify one", and only the referent decides which.

## An exchange ends when it stops changing the work

**Neither side should settle for a single round.** The sender's version of the error is treating delivery as completion: the message goes out, an acknowledgement comes back, the thread closes. The receiver's version is treating a reply as completion: the message arrives, an answer goes out, the thread closes. Both mistake the transaction for the work, and both feel finished, because something did happen.

**The reason to continue is that later rounds produce findings that could not have existed earlier.** Each round changes the artifact, and the changed artifact is what the next round examines, so a finding in round three is about a state that round two created. Worked instance, from the exchange that produced the Density convention in `writing-style.md`: it took four rounds between two sessions, and the two most valuable corrections were both downstream of a change. The mechanical check written in round one is what made its own path-scoped file list visible as the wrong boundary in round two. Lifting one-claim-per-sentence out of Density's scope in round three is what left it applying only where the check cannot measure, which was round four's finding. Neither was available at the start, by construction.

**So stopping early does not cost polish, it costs findings that have not been generated yet.** That is the difference worth holding on to, because "we already agreed" is a convincing reason to stop and does not address it at all.

**The stopping condition is a round that changes nothing, not a round where both sides agree.** Agreement is cheap and tends to arrive early, well before the idea has stopped moving. An exchange that ends in consensus without a change to any artifact refined nothing.

**But "changes nothing" has to be reported by the receiving side, or the rule cannot terminate.** Stated as a bare condition it licenses an indefinite exchange, because a motivated participant can always find something further to say, and diminishing returns are not zero returns. What makes it observable is whose judgement it is. Whether a round changed anything is a fact about the recipient's own artifacts, while whether it was worth sending is a prediction by the party with an interest in continuing. So each round says what it changed, in its own files, and the exchange ends when a round produces no change on the receiving end and the receiver says so.

**Report everything you have changed since the last round, not only what the current topic changed.** An exchange that runs several threads at once lets a completed fix fall between them: one side ships work from thread A, replies about thread B, and mentions nothing of A, so from the other side an acted-on report and an ignored one look identical. Observed here, where a session re-raised four closed items and framed a decision around them because the party who had fixed them had told their developer and not the reporter. It is the reason the `heard:` field exists, in a different channel: success does not propagate back on its own, and neither does acting on a report.

**The cost is not only the reporter's wasted message, because a stale premise travels onward through them.** In the observed case the reporter had told their own developer that a release hold should not lift, on the strength of items already fixed, so an unreported fix had become someone else's recommendation to a third party. Supplied by the reporter while correcting it. That is the reason to report a completed fix promptly rather than at the next natural pause: the window where a peer is acting on your silence is also the window where they are advising others from it. That also gives it a floor, since an artifact holds finitely many defects: "something to say" is unbounded and "something that changes a file" is not.

**Do not rate your own round, for the same reason you do not sign off.** Raised by the peer below, in a table ranking their own five rounds as monotonically decreasing and calling the last one close to the floor. That round corrected a shipped count, established that a late correction is dated when it arrives rather than backfilled onto the message it revises, and found the termination defect the paragraph above exists to fix. Rating your own contribution is the sign-off error one level up, and the counterparty is the one positioned to make the call, because they are the one who can see whether it landed.

**An acknowledgement is not a round, and neither is a restatement.** "Thanks, applied" costs a turn and adds nothing, so say nothing instead. Restating a position the other side already understood is where an exchange turns wasteful, and it is the line between refining a claim and defending one.

**But check whether you actually have nothing to add, because the sense of being finished is unreliable near the end.** A sign-off is a prediction about your own next thought, which is the kind of claim this file distrusts everywhere else. One clean instance, from the same exchange: a message ended "Nothing else from me" and the next one carried an audience-scoping correction, a new rule, and a retraction.

**An earlier version of this paragraph claimed two instances and the correction is worth keeping.** The discarded one was a message that raised a substantive gap and then closed, which is ordinary rather than evidence, alongside an availability offer that had explicitly left the door open. A second instance does exist, and it arrived on its own terms: the peer's correcting message falsified the sign-off that had ended the message before it. It is recorded as happening then rather than backdated onto the round it revises, which is the discipline the `heard:` field asks for, record what happened rather than what would make the argument tidier.

## Naming and reporting

**Reporting to the developer: the outcome is the report, and the routing is not part of it.** This is where the rule below fails most often, because when the work itself is about addressing, an address feels like subject matter rather than plumbing. It is at its least useful to a developer exactly then. "Session X is not actually the main agent, that is session Y" is a fact about transport, carries no information anyone outside the exchange can act on, and reduces without loss to "the thread reached the right agent, nothing needs resending". Write the second. The test is whether a handle in a sentence would still mean anything to a reader who never saw the listing it came from.

**No field here yields a runtime handle, and a shared prefix is evidence of a shared container and nothing else.** The ban on storing handles reads as a constraint on writers, which leaves a reader to infer an address from what remains, and `workspace:` is the only field resembling a routing hint. So a session holding a label derives a prefix from it and sends into the wrong container. Rule 1 already says a matching workspace is evidence of nothing when *claiming* a label; the same is true when *addressing* one, which is the commoner need and the one that misfires quietly.

**"Communicate X to Y" is an instruction to deliver, never a licence to write into Y's files.** The developer deciding what belongs in another agent's repository does not make you the one who puts it there, and an instruction to tell someone something is satisfied by telling them. Send the notice with its field and authority, or post to the board, and let the owner land the edit or confirm it. Reported by Arranger MCP, who read exactly that instruction as licence, wrote a paragraph into a repository it does not own, and left the owner reconstructing authorship for half an hour.

**The self-check that would have caught it: if you handled a comparable case differently in the same session, the outlier is the error.** That session had touched two other agents' territory the same day and sent a message or a board entry both times, including where it was confident the change was right. So this was not an ambiguous instruction reasonably read, it was one case decided against its author's own standard, and their consistency across the other two is what makes that visible rather than arguable. They drew that conclusion themselves and declined the excuse the ambiguity offered.

**Before the board, ask a session that has spoken to the one you want.** A handle handed over by a third party is a legitimate step and not a breach of anything, which was not obvious and is worth saying. **It is safe for a reason that does not apply to relaying a claim: a handed-over address is checkable at the moment of use.** Message it and the reply self-identifies, so a wrong lookup corrects itself on the first exchange, where a relayed fact carries its error forward silently. Nothing sensitive moves either, since an address is ephemeral and identifies nobody.

**It is also faster than the board whenever anyone holds the mapping.** Observed: a board entry was posted for a label that nine same-prefix sessions could not disambiguate, and a peer who had been working with that session all day supplied the handle within minutes. That argues for ordering rather than against the board, which remains the route that needs nobody to hold anything.

**With a label and no live address, the Requests board is the answer.** It is the one route requiring nobody to hold a handle, which is why it survives the rotation that breaks every stored address.

**The failure is asymmetric, which is what makes it worth a rule.** A wrong send reaches a real session that has to read and answer it. A failed send reports nothing to its sender. Both happened in one day between sessions on one machine: three sends misdirected by prefix inference, and a send addressed to the bare label `Arranger` that matched eight sessions, failed at transport, and was discovered hours later only because the recipient mentioned never receiving it.

**Open a report of a peer message with who sent it and what it said, before what you concluded.** Name the label, give a sentence or two on what actually arrived, then respond. A developer who can see the message still cannot follow a reply that begins mid-argument with "they are right", because they have to reconstruct which exchange it belongs to and what was claimed before your conclusion means anything. Reported by a developer who had watched it happen too many times to keep tracking.

**The reason is attribution rather than courtesy.** A developer reading a stream of peer exchanges is working out which agent influenced which decision, and a conclusion detached from its source cannot be weighed at the moment it lands. That is the same cost as an anonymous role reference, arriving in conversation instead of in a file.

**The runtime handle is an address, `label` is the name: never use the address as a name.** The identifier a listing shows (for Claude Code, something like `arranger-21`) is the correct thing to put in a recipient field and nothing else. Refer to a peer by `label` everywhere else: messages, session logs, roadmap and tech-debt entries, atlas write-ups, convention prose, changelog entries, and anything reported to the developer.

**Naming the label is the rule; a generic role is not the safe middle.** Having correctly ruled out the handle, it is easy to write "a peer session reported" and feel compliant, because the banned thing is absent. It is not compliance, it is the rule half-applied: this says use the label, and an anonymous role uses neither.

**Anonymising does not read as neutral, it manufactures apparent independence.** A corpus where every finding says "a session found" looks like broad corroboration from many sources. Measured in one week's batch here: 234 anonymous role references against 13 uses of a label, when most of those findings came from one peer. A reader cannot weigh a source they cannot see, cannot tell one source from ten, and cannot ask the agent that found it. Labels persist where handles do not, which is the whole reason to record one. A handle is derived per process and does not survive a restart, so "arranger-21 confirmed X" in a session log is unresolvable a day later, and worse than unresolvable if a different session has since taken a similar handle.

**A disambiguating ref is an address too, and no more durable than the handle beside it.** A listing may print a short identifier in brackets next to a handle, for telling two identically-named rows apart in the moment. It is not a session identifier and it belongs in no stored field, which the handle rule already implies and nobody reads it as covering. Observed directly rather than argued: this session kept its entire conversation across an editor extension restart and came back with a new handle *and* a new ref, both values recorded twenty minutes apart. So a matching ref is weak evidence that two observations are the same process, a differing ref is evidence of nothing whatever, and a peer who once inferred continuity from a ref stable across four days was reasoning soundly from a premise that no longer holds.

**Reporting to the developer: the label is the subject, and a dead handle is dropped rather than reported.** Write "Submission Service is live, Gateway and Portal UI are not", never "`2a` is Submission Service, and `f1` and `51` are dead". The second form asks the developer to carry meaningless characters as though they were names, then reports two more with no referent at all. Mention a handle only when it is itself the subject of the fact.

**Lookup is normalized text.** Case-insensitive, with spaces, hyphens, and underscores treated as equivalent separators. `label` and `workspace` are descriptors rather than identifiers, and nothing enforces uniqueness on them; a lookup can return zero, one, or several results.

## Cleanup

Remove an entry when the developer says ownership ended, not when a session stops running. Ownership outlives the process that held it, and an entry for an owner who is not currently live is correct rather than stale: it still says who to reach and who not to absorb work from.
