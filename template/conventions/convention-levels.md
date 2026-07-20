# Convention levels

Every convention lives at one of three levels. Placing it at the right level prevents drift and eliminates sync work.

## The three levels

**Project-specific**
Applies to this project only: domain vocabulary, key file paths, test commands, active project context. Lives in the project's `CLAUDE.md` or `.dev/`.

**Global**
Applies to all the developer's projects: behavioural conventions (testing style, scope discipline, checking in), tooling preferences, interaction style. Belongs in your agent's global context file (for Claude: `~/.claude/CLAUDE.md`; for other agents: consult your agent's docs). Always loaded: updating it once propagates to every project automatically.

If you've adopted the agentics template as your base, global should not hold a full copy of a convention that already lives there: it should reference agentics and add only the refinements that are actually local (things agentics doesn't cover, or a deliberate override, stated as such). A duplicated convention drifts the moment either copy changes; a referenced one can't.

**The reference has to be an instruction, not a citation.** "The base convention lives in `conventions/session-discipline.md`" describes where the rule lives; it doesn't tell an agent to go read that file right now. In practice this reads as documentation and gets skipped in favor of whatever the agent already does by habit. Phrase it as an action instead: "At every session-start signal, read `<path>` fresh and follow it" (using a direct path where you can, e.g. your own machine's local clone, rather than routing through another lookup step that can itself fail silently). This isn't hypothetical: an early citation-phrased version of this exact pattern failed under test, skipping every agentics-specific step with no error (see `CHANGELOG.md` § `dispatch-must-be-imperative`).

**Shareable (template)**
Structural patterns that benefit other teams: dispatch table wiring, `.dev/` layout, initialization flow, the credential file hook. Belongs in the [agentics template](https://github.com/oicr-softeng/agentics). Adopted by copying and adapting.

## How much to keep locally

The three levels above answer where a convention should be authored or live. This answers a different question: once a project has adopted agentics, in full or in part, does a given convention need a local copy, or can it stay a live pointer? See the root README's "Two tiers" section for the fuller motivation; this is the operational rule.

**Copy in locally:** only what must fire every session, with no natural trigger of its own to prompt checking it — the session-start checklist itself, and the project's own `agentics-template-version | synced` marker (inherently local: it's state about this project, not agentics content, so there's no version of it that could live elsewhere). If this doesn't happen reliably, drift goes unnoticed, and a passive reference has already been shown not to work here (see "The reference has to be an instruction, not a citation" above).

**Leave as a live pointer:** everything invoked only when actually doing that task — testing, code style, security, documentation, code review, this file, upgrading adoption. Each has its own strong trigger (the agent is doing that task right now), so a dispatch line in `CLAUDE.md` is enough; copying the content in gains nothing and adds a second copy that can drift from the first.

**`AGENTS.md` is not an exception to this.** It was originally built to inline everything, on the assumption that its consumers couldn't fetch a file on demand at all. That assumption was wrong: the AGENTS.md standard's own guidance recommends dispatch over inlining, since real consumers (Cursor, Copilot, Aider) have file-system access like any other coding agent. `AGENTS.md` follows the same rule as everything above: it holds the canonical dispatch table (so it isn't duplicated a second time in `CLAUDE.md`), and dispatches to `conventions/*.md` the same way `CLAUDE.md` does.

**Local clone or remote URL, same rule either way.** Whether agentics is available as a local clone or only as a GitHub URL changes where the every-session content gets fetched from, not whether it needs fetching. A brand-new adopter working from a URL alone still needs the session-start checklist read fresh, every session, the same as a contributor with a local clone — just fetched over the network instead of from disk. Tested directly against a fixture with no local agentics clone at all: the same imperative phrasing worked unchanged for a raw GitHub URL, first attempt (see `CHANGELOG.md` § `validate-remote-only-fetch`).

## The propagation question

Whenever you add or improve a convention: anywhere: ask three things:

1. **Is this at the right level?** If it's in a project but applies to all projects, it belongs in global. Moving it there means zero ongoing sync work.

2. **If it improved here, is it stale elsewhere?** Check your cross-project map (for Claude: `~/.claude/projects.md`; for other agents: your agent's global context directory) for the list of related projects and their relationships: that's where "elsewhere" is defined. Name the propagation candidates explicitly. Don't silently leave them behind.

3. **Could other teams benefit?** If yes, flag it as a potential agentics PR.

Surface these questions explicitly: the right level is rarely the place where the convention first appeared.

## Propagation suggestions (opt-in)

If the user opted in during initialization (`propagation_suggestions: yes`), surface propagation suggestions at the moment of discovery: not at session end.

One sentence is enough: name the level and why. Example: "This validation pattern looks applicable across projects: worth adding to your global context?"

Let the user decide without pressure. If they say yes, make the change and record it in `.dev/sessions/`.

**Agentics contributors:** if `agentics_contributor: yes` is set in your global context (not just agentics' own project memory — see § Checking for upstream updates below for why), propagation is always on without asking: and the agentics repo is always named as an explicit candidate alongside the other levels. See `CONTRIBUTING.md` in the agentics repo for how to set this up.

## Checking for upstream updates

Propagation isn't only outbound. A project's copied `CLAUDE.md`/`AGENTS.md`/`CLAUDE.softeng.md` can also drift *behind* agentics as the template evolves after adoption. Two separate questions decide what happens, in this order — don't merge them, they have different answers and different sources:

**First: is this project even an agentics adopter?** This is a property of the *project*, not of you. Don't gate it purely on finding a well-formed `synced` tag: that tag is itself a recent addition, so most existing adopters won't have one yet, and a project missing it entirely is exactly the case that most needs to be caught, not silently skipped. Treat a project as an agentics adopter if *either* is true: an `agentics-template-version` tag in any form, or (failing that) `AGENTS.md`/`CLAUDE.md` merely mentions agentics (`grep -qi agentics AGENTS.md CLAUDE.md 2>/dev/null`), e.g. the "Adapted from softeng/agentics" line the template ships with — prose survives trimming better than an HTML comment. If neither is present, this isn't (detectably) an agentics project: nothing to check, though see `conventions/upgrading-adoption.md` § 0 for the case where a project shares the lineage with no textual trace at all.

**Second, only if the answer above is yes: how strongly do you personally need to check?** This is a property of *you, the agent* (specifically, your global context), not of the project — a project mentioning agentics doesn't by itself make the check mandatory; your own contributor status does. Two tiers, deliberately different in strength:

- **Opt-in, for any adopter** (`propagation_suggestions: yes`): check for this at session start alongside the outbound question above, same treatment as any other project.
- **Mandatory, for agentics contributors** (`agentics_contributor: yes`): record this in your global context, not only in agentics' own project memory — it needs to apply in every project you work in, not just sessions inside agentics itself. For a contributor, this check runs every session in every project, regardless of that project's own `propagation_suggestions` setting, and keeps recurring for an unresolved gap rather than surfacing it once and going quiet if it's ignored or deferred. This is intentionally more insistent than the opt-in tier: contributing to agentics implies a higher bar of keeping the ecosystem you're helping build actually current, and a prompt that quietly stops repeating itself is easy to forget about.

**This has to be phrased as an unconditional override, not just a mandatory flag, or it silently loses to a project's own checklist.** A project with a complete, self-contained "Starting a session" list — the exact legacy pattern in `upgrading-adoption.md` § 1 — will win against a global instruction that only says "do this check every session," because the agent reasonably treats the project's own explicit, complete instructions as sufficient and never separately reasons "is there something the global context wants me to do in addition to this." Tested directly: a global instruction phrased as a plain recurring step failed against that pattern; the same instruction, rephrased to explicitly say the check runs *in addition to* the project's own checklist even when that checklist is complete and its own dispatch-to-global line names other topics but not this one, succeeded. State the override explicitly in your global context: name the failure mode (a complete local checklist, a narrower dispatch line) and say directly that neither one opts a project out — only `agentics_upstream_check: no` does.

The mandatory tier stops only on an explicit developer instruction, at one of two scopes — never inferred from silence or a deferred "not now":
- **"Stop for this project":** record `agentics_upstream_check: no` in that project's own memory. Suppresses the check there only.
- **"Stop for all projects":** record `agentics_upstream_check: no` in your global context instead. Suppresses it everywhere, without touching the other agentics-contributor behaviours (outbound propagation, named in the section above, stays always-on) — this is a separate flag, not a downgrade of `agentics_contributor` itself.

**Tag present with a `synced` value** (the normal, steady-state case):
1. Locate the local agentics clone if one exists (see your global context's Repo URL rule). Don't just prefer it by default: verify it's actually current first. `git -C <agentics-path> fetch` and compare local `HEAD` against the tracked remote branch. If local is behind, pull it; if that's unsafe (uncommitted local changes that would conflict), fall back to reading `CHANGELOG.md` from the remote URL instead and say so, rather than silently trusting a stale local copy. A verified-current local clone beats a live remote read; a stale one is worse than the URL, not better, since it can report "nothing changed" when the opposite is true.
2. `git -C <agentics-path> log --oneline <synced-sha>..HEAD -- CHANGELOG.md`. If empty, nothing changed: stop here, no further context spent.
3. If non-empty, read only the new lines: `git -C <agentics-path> diff <synced-sha> HEAD -- CHANGELOG.md`, not the whole file, to know what changed since last sync.
4. Don't stop at printing the entries. Run the diagnosis in `conventions/upgrading-adoption.md` § 1 against the current template, for real: new changelog text is a pointer to what to look for, not a substitute for actually re-deriving current file shape (is `CLAUDE.md` still a stub? does `AGENTS.md`'s dispatch table match today's `conventions/` listing?). This is what closes the gap between "the changelog mentioned it" and "the project's files actually reflect it": a structural fix described in prose is easy to read past without translating into an action, and re-running the diagnosis does that translation instead of leaving it to the developer.
5. Check `.dev/agentics-overrides.md` if it exists; suppress any gap that matches a recorded permanent decision there rather than resurfacing it.
6. Classify what's left: **non-conflicting** (a pure addition, or the local copy is just a stale, unmodified instance of an older template shape, nothing local actually contradicts the change) goes into one batched proposal, a single yes/no covers all of it. **Conflicting** (local content is a deliberate, substantive customization that diverges from the current template's handling of the same topic) gets asked about individually, one at a time, with three choices: adopt upstream, keep local this time only, or keep local permanently (recorded in `.dev/agentics-overrides.md`; see `upgrading-adoption.md` § 2 for the format). Lead with any `breaking: yes` entries in either bucket: they usually mean a file this project copied, not just referenced, needs the fix applied, not just acknowledged.
7. Once reviewed (applied, explicitly skipped, or recorded as a permanent override), update `synced` to agentics' current `HEAD` so the same entries don't resurface.

A semver comparison alone doesn't work here: agentics defers version bumps until a release is committed to remote, so `CHANGELOG.md` accumulates many `Unreleased` entries under one version tag for long stretches. The commit SHA is what's actually tracked; the version number is just a label for whichever plateau it's on.

**No tag, or a tag with no `synced` value:** don't run the diff above — there's no baseline to diff from, and a full historical walk back to adoption is mostly agentics' own internal iteration, not necessarily relevant to this project. Instead, run the full procedure in `conventions/upgrading-adoption.md` § 1 directly: it surfaces agentics' current `## Unreleased` entries as a bounded first-encounter catch-up and covers the tag, session-file migration, and `AGENTS.md` completeness together, rather than patching the tag in isolation. This isn't a soft offer the developer can wave off with no trace: a project with no tag at all is exactly the case most likely to carry real, unreconciled structural drift, since nothing has ever diagnosed it against the template. Treat it the same as a non-empty diff above — same `.dev/agentics-overrides.md` check first, same classification into a batched non-conflicting proposal and individually-asked conflicts.
