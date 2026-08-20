# Convention levels

Every convention lives at one of three levels. Placing it at the right level prevents drift and eliminates sync work.

## The three levels

**Project-specific**
Applies to this project only: domain vocabulary, key file paths, test commands, active project context. Lives in the project's `AGENTS.md` or `.dev/`.

**Global**
Applies to all the developer's projects: behavioural conventions (testing style, scope discipline, checking in), tooling preferences, interaction style. Belongs in your agent's global context file (for Claude: `~/.claude/CLAUDE.md`; for other agents: consult your agent's docs). Always loaded: updating it once propagates to every project automatically.

If you've adopted the agentics template as your base, global should not hold a full copy of a convention that already lives there: it should reference agentics and add only the refinements that are actually local (things agentics doesn't cover, or a deliberate override, stated as such). A duplicated convention drifts the moment either copy changes; a referenced one can't.

**The reference has to be an instruction, not a citation.** "The base convention lives in `conventions/session-discipline.md`" describes where the rule lives; it doesn't tell an agent to go read that file right now. In practice this reads as documentation and gets skipped in favor of whatever the agent already does by habit. Phrase it as an action instead: "At every session-start signal, read `<path>` fresh and follow it" (using a direct path where you can, e.g. your own machine's local clone, rather than routing through another lookup step that can itself fail silently). This isn't hypothetical: an early citation-phrased version of this exact pattern failed under test, skipping every agentics-specific step with no error (see `CHANGELOG.md` § `dispatch-must-be-imperative`).

**Shareable (template)**
Structural patterns that benefit other teams: dispatch table wiring, `.dev/` layout, initialization flow, the credential file hook. Belongs in the [agentics template](https://github.com/oicr-softeng/agentics). Adopted by copying and adapting.

## Scope a new convention to the artifact class that produced it

**Widen only on evidence, and treat a plausible adjacent case as untested rather than covered.** A rule arrives attached to the thing that went wrong. Generalizing it to everything it could plausibly touch feels like thoroughness and is how a rule ends up governing artifacts nobody checked it against, where it is sometimes actively wrong rather than merely unnecessary.

**Two instances in a single exchange, both self-reported by the session that overreached.** A density rule drafted from one over-compressed document was written to cover all prose, including agent-facing instruction files where compression is the goal and unpacking would raise every adopter's per-session cost. Separately, a claim about grouped registry labels was generalized from "this clause carries real content when present" to "this is what justifies such labels existing", which would have imposed a registration requirement nobody asked for.

**Counted on one rule: four corrections, three parties, none visible from inside.** A density rule was scoped by path by its author, rescoped by audience by the developer, generalized into session logs by the session that had proposed it, and then had that generalization pushed back. The author of the overreach warning committed an overreach in the same exchange, immediately after writing the warning. That is the strongest available evidence that this is structural rather than carelessness: knowing about the failure does not let you see your own instance of it.

**An optional proxy needs a stated promotion condition, or it stays optional through any amount of evidence.** Where a convention names an available mechanical check and leaves it as an option, it has decided that manual compliance is sufficient. That decision is rarely revisited, because nothing in the wording says what would change it, so "optional" quietly becomes permanent.

**The condition that should promote it: a failure occurring with the rule read, applicable, and specific to the case.** Only one of those three rests on self-report and it is the least load-bearing: whether someone read a file cannot be checked, while whether the rule covers their exact case can be, by opening it. Check that half before acting, since it is the half that establishes the ceiling. At that point the prose is at its ceiling and further wording buys nothing. Reported by a session that broke a property-ordering rule which had described its exact failure in four escalating degrees of specificity, in a file it had read fresh that session, and which named the autofixing linter three lines below. Their conclusion is the right one: this case does not need the moment-of-writing remedy that applies where no honest proxy exists, since an honest proxy exists and is simply switched off.

**Promotion is a project decision and never a template-wide one.** A template cannot adopt a language-specific tool on behalf of adopters who do not use that language, and doing so would invert the library-awareness rule that surfaces tools as options for the developer to choose. So the promotion condition belongs to whoever owns the project where the failure happened.

**Adopt the proxy and fix its signal in the same change, or you have shipped a control whose failure looks like success.** The same report noted that the project in question lints its build output, producing roughly 17,600 problems of which about 89% are artefacts, so a new rule would land in a backlog nobody reads: true, enforced, and invisible. A check nobody reads is indistinguishable from a check nobody wrote, and it is worse, because its existence is cited as coverage.

**A sound rule applied to an artifact it does not govern is not a misapplication, and it is harder to see.** Misapplying a rule leaves a visible mismatch that someone can point at. Reaching for a rule that is genuinely correct elsewhere produces confident, well-formed reasoning about the wrong thing, and every step of it survives inspection. Reported by a session that did it twice in one day and named the shape on itself: reaching for an existing lens rather than asking whether it fit the case at hand.

**The narrowest case is reasoning about an artifact that does not exist, and unlike the rest of this section it has a cheap check.** Sound reasoning applied to a file that was only ever a sentence survives inspection at every step, because nothing in the reasoning is wrong. Reported by the session that did it: they took a claim from a message, reported it to their developer as recorded in a convention file, offered to correct a line nobody had written, and cost the file's owner a paragraph to unwind. **The check is not better reasoning, it is asking whether the thing under discussion is a file or a sentence**, then confirming before acting; the owner's own grep settled it in one command. Same shape as a claim written at wider scope than its evidence supports, with the scope error landing on the artifact's existence rather than on its contents.

**The mirror runs the other way and is the more common of the two: asserting absence from a search whose boundaries you never established.** The same session nearly reported an entry missing after grepping one directory, when the entry was in another; the search path was wrong and the content was there. A false negative is the worse half in practice, because it sends someone to redo work already done or to re-raise something already closed, and nothing in the result distinguishes "not present" from "not looked at". **So search the whole repository before saying not there, which is the same discipline as opening the file before saying what it says.**

**The strongest instance had authorship, recency and articulation all present, and none was sufficient.** A session misrouted a message by reading a handle prefix as a label, when "prefixes encode workspaces, not labels" was written in a registry entry it had authored, and it had told another peer minutes earlier in the same session that a launch artefact is not evidence of identity. So the failure was not ignorance of the rule, absence of the rule, or the rule going unread. The rule was theirs, freshly read, and stated aloud, and it still did not fire at the moment it applied.

**The tell is that the correction arrives from the person who raised the original problem, rather than from anything inside the rule.** A rule cannot notice its own overreach; it reads as more complete the further it extends. So the check is external and it is a question about evidence: which artifacts was this actually observed on? Everything else is a candidate, and candidates get tested before they get governed.

## How much to keep locally

The three levels above answer where a convention should be authored or live. This answers a different question: once a project has adopted agentics, in full or in part, does a given convention need a local copy, or can it stay a live pointer? See the root README's "Two tiers" section for the fuller motivation; this is the operational rule.

**Copy in locally:** only what must fire every session, with no natural trigger of its own to prompt checking it: the session-start checklist itself, and the project's own `agentics-template-version | synced` marker (inherently local: it's state about this project, not agentics content, so there's no version of it that could live elsewhere). If this doesn't happen reliably, drift goes unnoticed, and a passive reference has already been shown not to work here (see "The reference has to be an instruction, not a citation" above).

**Leave as a live pointer:** everything invoked only when actually doing that task: testing, code style, security, documentation, code review, this file, upgrading adoption. Each has its own strong trigger (the agent is doing that task right now), so a dispatch line in `AGENTS.md` is enough; copying the content in gains nothing and adds a second copy that can drift from the first.

**A trigger firing again later in the same session means reading the file again, not reusing an earlier read.** The same fresh-read discipline `session-discipline.md` § Session-start signals already requires after long-thread context loss applies here too, and matters more for agentics specifically than for a typical dependency: it's an actively-edited live source, and a contributor's own concurrent session can change the exact file being pointed at mid-task. Treating an early-session read as still accurate later is the same failure whether the cause is context loss or simply not bothering to check again.

**`AGENTS.md` is not an exception to this.** It was originally built to inline everything, on the assumption that its consumers couldn't fetch a file on demand at all. That assumption was wrong: the AGENTS.md standard's own guidance recommends dispatch over inlining, since real consumers (Cursor, Copilot, Aider) have file-system access like any other coding agent. `AGENTS.md` follows the same rule as everything above: it holds the canonical dispatch table, which is why `CLAUDE.md` is a stub pointing here rather than a second copy of it, and dispatches to `conventions/*.md` on demand.

**Never a project copy, not even as a bootstrap fallback: `conventions/`, `AGENTS.roles/`, `AGENTS.softeng.md`, `AGENTS.overture.md`.** This is the canonical statement of the rule; other files (`template/README.md`, `AGENTS.md`'s dispatch table, `upgrading-adoption.md`) state it briefly and point back here rather than re-explaining it. `conventions/*.md` are always a live pointer into agentics itself, no exception, covered by "leave as a live pointer" above. `AGENTS.roles/<role>.md`, `AGENTS.softeng.md`, and `AGENTS.overture.md` are a related but distinct case: they're global-guideline material, not project content, so when they're genuinely needed (a contributor's global context doesn't yet define a role, a team's conventions, or a product family's), the fix is bootstrapping that global context once, the same way `global-context/` templates get copied to `~/.claude/` (or equivalent), never a copy placed inside whatever project happens to be open at the time. A missing local copy of any of these is always the correct state, regardless of whether the reading agent's global context currently covers the equivalent content or not; there is no condition under which copying one into a project is the right fix (see `CHANGELOG.md` § `global-guideline-material-never-in-project` for the incident that found this the hard way).

**Local clone or remote URL, same rule either way.** Whether agentics is available as a local clone or only as a GitHub URL changes where the every-session content gets fetched from, not whether it needs fetching. A brand-new adopter working from a URL alone still needs the session-start checklist read fresh, every session, the same as a contributor with a local clone, just fetched over the network instead of from disk. Tested directly against a fixture with no local agentics clone at all: the same imperative phrasing worked unchanged for a raw GitHub URL, first attempt (see `CHANGELOG.md` § `validate-remote-only-fetch`).

**A live-pointer read trusts the same clone the freshness check exists to verify, so verify it before trusting either.** § Checking for upstream updates' remote-verification step (confirm the canonical URL is actually among the clone's configured remotes before trusting it) protects the version-diff check from a stale or wrongly-sourced clone; a live-pointer read from that same clone needs the identical protection, since nothing else stands between a task-triggered read and whatever happens to be sitting at the recorded Path. Run it once per session, not once per read: cache the verdict rather than re-verifying on every dispatch trigger. Contributors specifically: a personal fork configured only as `origin`, with no `upstream` remote pointing at the canonical repo, fails this check by design, that's the fallback-to-URL case, not a bug to route around.

## The propagation question

Whenever you add or improve a convention: anywhere: ask three things:

1. **Is this at the right level?** If it's in a project but applies to all projects, it belongs in global. Moving it there means zero ongoing sync work.

2. **If it improved here, is it stale elsewhere?** Check your cross-project map (for Claude: `~/.claude/projects.md`; for other agents: your agent's global context directory) for the list of related projects and their relationships: that's where "elsewhere" is defined. Name the propagation candidates explicitly. Don't silently leave them behind.

3. **Could other teams benefit?** If yes, flag it as a potential agentics PR.

Surface these questions explicitly: the right level is rarely the place where the convention first appeared.

## Propagation suggestions (opt-in)

If the developer opted in during initialization, this lives in your global context (`propagation_suggestions: yes`) as the default for every project, not just the one where it was first asked; see `AGENTS.md` § Initialization. A specific project's own memory can locally override that default (e.g. recording `propagation_suggestions: no` there specifically); when present, the project-level record wins for that project only, otherwise the global default applies. When it resolves to yes, surface propagation suggestions at the moment of discovery: not at session end.

One sentence is enough: name the level and why. Example: "This validation pattern looks applicable across projects: worth adding to your global context?"

Let the developer decide without pressure. If they say yes, make the change in a location you already have standing access to: the current project's own files, or the developer's global context file. Both are places this session already reads and writes as a matter of course. Then record it in `.dev/sessions/`.

**Agentics contributors:** if `agentics_contributor: yes` is set in your global context (not just agentics' own project memory: see § Checking for upstream updates below for why), *surfacing* the agentics repo as an explicit propagation candidate is always on, without needing to ask permission just to raise it. That's not the same as writing into the agentics repo itself. A separate git repository isn't "your own files" the way the current project or the developer's global context are: default to fixing the immediate issue in the current project's own copy first, since that's where it actually happened, then offer the agentics-side version of the fix back to the developer rather than reaching into that clone directly. Write into the agentics repo only when the current session is already working inside it, or when given an explicit instruction naming that exact action: a general "yes, let's do that" to a suggestion raised from a different project doesn't by itself authorize crossing into another repo, any more than it would authorize editing some unrelated third project's files. See `CONTRIBUTING.md` in the agentics repo for how to set this up.

**Proactive, not just reactive: review your own already-established global context too, not only fresh discoveries.** Everything above triggers on something just learned or improved in the moment; nothing reviews a contributor's own pre-existing global context for candidates that were never surfaced, dormant local refinements added at some point without the propagation question ever being asked. For `agentics_contributor: yes`, in the same pass as the mandatory upstream-check below (§ Checking for upstream updates), also check the reverse direction: does your own global context contain a local refinement, typically labeled as such under whatever it customizes, genuinely portable past your own specific team or setup, and not yet reflected in agentics' current template? Apply the same three-question test from "The propagation question" above. Confirmed as a real, non-hypothetical gap: a full review of one contributor's own global file, prompted directly rather than found by this check firing on its own, surfaced six genuine candidates that had sat unreviewed the whole time this instruction didn't exist.

## Checking for upstream updates

Moved to `conventions/upstream-check.md`, which holds the gating, the tag format, and the numbered comparison and classification steps. It lives in its own file because it is read at session start, on a different trigger than the placement rules above.

## Recording a permanent override

Any time a convention (from `conventions/*.md`, `AGENTS.md` itself, or a suggestion made from general practice) recommends something and the developer declines it as a deliberate, permanent choice for this project, not just "not for this one change": record it in `.dev/agentics-overrides.md` (created on first use, not required upfront). This is the general mechanism for "we decided against the default, on purpose, here's why," wherever that decision happens to come up, not something scoped to any one procedure. `upgrading-adoption.md` § 2 is one trigger for it (a conflict found during a reconciliation pass), not the only one.

```
- `<topic or section, e.g. "code-style.md § No non-null assertions">`: <what this project does instead, and why, one sentence>. Decided <date>.
```

Before making the same suggestion again, whether during a formal upgrade check or in the ordinary course of a session, check this file first: a recorded override means don't re-raise it, not "raise it again and see if they still agree." Distinguish a permanent override from a one-off "not now": only a decision explicitly meant to hold going forward gets recorded here; a single-instance "not for this change" stays unrecorded, and the suggestion can resurface next time it's actually relevant.
