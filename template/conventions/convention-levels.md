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

If the user opted in during initialization, this lives in your global context (`propagation_suggestions: yes`) as the default for every project, not just the one where it was first asked; see `AGENTS.md` § Initialization. A specific project's own memory can locally override that default (e.g. recording `propagation_suggestions: no` there specifically); when present, the project-level record wins for that project only, otherwise the global default applies. When it resolves to yes, surface propagation suggestions at the moment of discovery: not at session end.

One sentence is enough: name the level and why. Example: "This validation pattern looks applicable across projects: worth adding to your global context?"

Let the user decide without pressure. If they say yes, make the change in a location you already have standing access to: the current project's own files, or the developer's global context file. Both are places this session already reads and writes as a matter of course. Then record it in `.dev/sessions/`.

**Agentics contributors:** if `agentics_contributor: yes` is set in your global context (not just agentics' own project memory: see § Checking for upstream updates below for why), *surfacing* the agentics repo as an explicit propagation candidate is always on, without needing to ask permission just to raise it. That's not the same as writing into the agentics repo itself. A separate git repository isn't "your own files" the way the current project or the developer's global context are: default to fixing the immediate issue in the current project's own copy first, since that's where it actually happened, then offer the agentics-side version of the fix back to the developer rather than reaching into that clone directly. Write into the agentics repo only when the current session is already working inside it, or when given an explicit instruction naming that exact action: a general "yes, let's do that" to a suggestion raised from a different project doesn't by itself authorize crossing into another repo, any more than it would authorize editing some unrelated third project's files. See `CONTRIBUTING.md` in the agentics repo for how to set this up.

**Proactive, not just reactive: review your own already-established global context too, not only fresh discoveries.** Everything above triggers on something just learned or improved in the moment; nothing reviews a contributor's own pre-existing global context for candidates that were never surfaced, dormant local refinements added at some point without the propagation question ever being asked. For `agentics_contributor: yes`, in the same pass as the mandatory upstream-check below (§ Checking for upstream updates), also check the reverse direction: does your own global context contain a local refinement, typically labeled as such under whatever it customizes, genuinely portable past your own specific team or setup, and not yet reflected in agentics' current template? Apply the same three-question test from "The propagation question" above. Confirmed as a real, non-hypothetical gap: a full review of one contributor's own global file, prompted directly rather than found by this check firing on its own, surfaced six genuine candidates that had sat unreviewed the whole time this instruction didn't exist.

## Checking for upstream updates

Moved to `conventions/upstream-check.md`, which holds the gating, the tag format, and the numbered comparison and classification steps. It lives in its own file because it is read at session start, on a different trigger than the placement rules above.
