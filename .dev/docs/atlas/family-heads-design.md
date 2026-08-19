# Family heads: a per-family triage role

A design for one session per product family acting as the routing point for components that have no dedicated session of their own. Developer-originated, worked out with the `iMicroSeq Portal UI` session on 2026-08-19 and confirmed by the developer directly rather than inferred from a peer's report.

**Not shipped as a convention, deliberately.** No head has been designated and none has operated, so this fails this repo's own "prove it before templating it" bar. It is written up here in enough detail to implement without re-deriving the reasoning, once a real one has run for long enough to say whether it works.

## The gap it closes

The agent index answers "which session owns this project" when a Member entry exists. It has no answer when one does not. Today the fallback is a Requests post, which is passive: my own post for one project sat unanswered for hours, and there is no way to distinguish "nobody has read it" from "read it, not mine, said nothing."

A family head gives that case a default addressee. Someone is reachable for a component nobody has claimed, rather than the question dropping.

The design originally keyed this to `window`, on the reasoning that a window is derived from the workspace's first-listed folder and so is mechanically determinable. Testing that against the live index showed it holds for one family and breaks for another; see § The family is not the window below, which supersedes the window framing throughout this document.

## Resolved

**Designation is developer-assigned, never self-assigned.** Same treatment as `label`. A session declaring itself the head of its family would be claiming authority over peers on its own say-so, which is the shape every misroute this week started from.

**Covering means routing, not doing.** The head triages and directs; it does not become the de facto engineer for an unclaimed component. The developer's framing: it is the way a session already connects with its siblings, extended to the parts of the family nobody has claimed, hence the name. This keeps it compatible with the ownership rule shipped the same day, where another session's work is not yours to pick up. A head answering "that is unclaimed, I will take it" is fine; a head answering for a component whose own session exists is the failure.

**A head that has gone quiet is treated as absent, not as live.** Reuse the staleness handling `id` already has rather than inventing a second mechanism: an entry that has not been refreshed at a recent session start is stale, and a failed or misrouted send means stale rather than error. A stale head falls back to the Requests board, then the developer. This matters because a dead head is worse than no head: it is a routing target that looks live and silently absorbs traffic.

**Unassigned is re-evaluated, not assumed permanent.** Once a component gets its own session, the head defers immediately rather than continuing out of habit. The `iMicroSeq Portal UI` session named this as the part most likely to fail in practice rather than in principle, and asked to be told directly if it is ever seen still routing for something that has since been claimed.

## Unresolved

**A registered Member with no live session.** `Lyric and Maestro` is in this state right now: an entry exists, nothing is running, and the index cannot tell that from a session that simply has not refreshed. A head routing to it would be routing into nothing. The current answer, fall back to the board or the developer, is the same answer as for a dead head, which suggests the two cases want one mechanism rather than two.

**Unregistered sessions doing substantial work.** Two exist as of writing, one working across three repos. They are invisible to a head by construction, so a head could confidently report a component as unclaimed while a session is actively working it. Registration is the fix, but nothing makes it happen, and a head that is confidently wrong is worse than one that says it does not know.

**Whether the head is a field or an entry.** Not decided. A `head: yes` flag on an existing Member is cheapest and keeps one entry per session. A separate family-to-head mapping would survive the head's session ending, but then it points at a label rather than anything live, which is the problem above in a different place.

## Largely superseded for routing: any sibling can bridge

The developer's own follow-up collapses most of this design. A head was proposed as the session that queries its siblings on behalf of an outside caller. But every session in a window already sees every other session's handle in its own `ListAgents`, so any sibling can do that querying: it is either the one being sought, or it knows which handle is, or it can ask within the window more cheaply than an outsider can from outside. First contact serves, and no designation is needed.

That removes the two hardest problems at once. There is no dead head to route into, because there is no single point to designate; and there is nothing to re-evaluate when a component acquires its own session, because nobody was standing in for it. It also removes the authority question, since a bridge answers "who is that" rather than speaking for anyone.

What a designated head would still add, and it is much less than originally scoped: a known first place to ask for a family whose components have no sessions at all, and someone accountable for noticing that an unclaimed component needs an agent. Neither is a routing problem, so neither is urgent, and both are better judged once the bridge pattern has run for a while.

Kept rather than deleted because the resolved questions above are still the right answers if a head is ever designated, and because the family-versus-window finding below stands entirely on its own.

## The family is not the window, and the data says so

Tested against the live index rather than reasoned about, because this is the question most likely to change the design's shape.

| window | members | a family? |
|---|---|---|
| `iMicroSeq` | Gateway and Pedigree, Submission Service, Portal UI | yes, exactly |
| `arranger` | Arranger, Usher | partly, two Overture services |
| `softeng` | agentics, Stage, Lyric and Maestro, Lectern | no |

`iMicroSeq` works because that workspace was built per product family: its folder list is that family's components. `softeng` fails because `softeng.code-workspace` and `overture.code-workspace` both list `agentics` first, so two unrelated families collapse into one window holding a tool and three Overture components. A head over that set has nothing coherent to triage.

The `scope` values show what the real grouping is. Every Overture session's scope begins with the same word (`overture - stage`, `overture - lyric and maestro`, `Overture - Lectern`, `overture - arranger`, `overture - usher`), and the iMicroSeq ones likewise. The family is the product family, and it is already recorded, just as a prefix inside a free-text field rather than as its own thing.

**So a head is per family, not per window, and a family can span windows.** Overture currently spans `softeng` and `arranger`. Window is a proxy that happens to be exact for iMicroSeq and wrong for Overture, which is the worst kind of proxy: correct in the case you test first.

This connects directly to the open roadmap item on generalizing the product-family addendum beyond Overture. Both are the same underlying gap, that agentics has no first-class notion of a product family even though softeng organizes entirely around them, and both want the same fix. A family-head design that keys on `window` would ship that gap into a new mechanism rather than closing it.

Not resolved here: whether the family becomes its own field, or is derived from a normalized `scope` prefix, or the existing product-family flag recorded at initialization is reused. Worth noting the free-text hazard either way, since two sessions in the same window currently record it as `imicroseq` and `iMicroSeq`, which normalized matching handles but which shows these values are hand-written despite `window` being specified as derived.

