# Convention levels

Every convention lives at one of three levels. Placing it at the right level prevents drift and eliminates sync work.

## The three levels

**Project-specific**
Applies to this project only: domain vocabulary, key file paths, test commands, active project context. Lives in the project's `CLAUDE.md` or `.dev/`.

**Global**
Applies to all the developer's projects: behavioural conventions (testing style, scope discipline, checking in), tooling preferences, interaction style. Belongs in your agent's global context file (for Claude: `~/.claude/CLAUDE.md`; for other agents: consult your agent's docs). Always loaded: updating it once propagates to every project automatically.

If you've adopted the agentics template as your base, global should not hold a full copy of a convention that already lives there: it should reference agentics and add only the refinements that are actually local (things agentics doesn't cover, or a deliberate override, stated as such). A duplicated convention drifts the moment either copy changes; a referenced one can't.

**The reference has to be an instruction, not a citation.** "The base convention lives in `conventions/session-discipline.md`" describes where the rule lives; it doesn't tell an agent to go read that file right now. In practice this reads as documentation and gets skipped in favor of whatever the agent already does by habit. Phrase it as an action instead: "At every session-start signal, read `<path>` fresh and follow it" (using a direct path where you can, e.g. your own machine's local clone, rather than routing through another lookup step that can itself fail silently). This isn't a hypothetical: an early version of this exact global-dispatch pattern was written as a citation and, when tested, a real session skipped every agentics-specific step without any error, because nothing in the citation told it to actually fetch the file.

**Shareable (template)**
Structural patterns that benefit other teams: dispatch table wiring, `.dev/` layout, initialization flow, the credential file hook. Belongs in the [agentics template](https://github.com/oicr-softeng/agentics). Adopted by copying and adapting.

## How much to keep locally

The three levels above answer where a convention should be authored or live. This answers a different question: once a project has adopted agentics, in full or in part, does a given convention need a local copy, or can it stay a live pointer? See the root README's "Two tiers" section for the fuller motivation; this is the operational rule.

**Copy in locally:** only what must fire every session, with no natural trigger of its own to prompt checking it — the session-start checklist itself, and the project's own `agentics-template-version | synced` marker (inherently local: it's state about this project, not agentics content, so there's no version of it that could live elsewhere). If this doesn't happen reliably, drift goes unnoticed, and a passive reference has already been shown not to work here (see "The reference has to be an instruction, not a citation" above).

**Leave as a live pointer:** everything invoked only when actually doing that task — testing, code style, security, documentation, code review, this file, upgrading adoption. Each has its own strong trigger (the agent is doing that task right now), so a dispatch line in `CLAUDE.md` is enough; copying the content in gains nothing and adds a second copy that can drift from the first.

**The `AGENTS.md` exception:** it inlines both categories, deliberately, because it's the fallback for agents that cannot fetch a file on demand at all. That's a bounded cost for a known limitation, not evidence that copying is generally the safer choice.

**Local clone or remote URL, same rule either way.** Whether agentics is available as a local clone or only as a GitHub URL changes where the every-session content gets fetched from, not whether it needs fetching. A brand-new adopter working from a URL alone still needs the session-start checklist read fresh, every session, the same as a contributor with a local clone — just fetched over the network instead of from disk. Tested directly against a fixture with no local agentics clone available at all: the same imperative phrasing that works for a local path ("read `<path>` fresh") worked unchanged for a raw GitHub URL ("fetch `<url>` fresh"), first attempt, no adjustment needed.

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
1. Locate the local agentics clone: prefer the local `Path` over the GitHub URL (see your global context's Repo URL rule).
2. `git -C <agentics-path> log --oneline <synced-sha>..HEAD -- CHANGELOG.md`. If empty, nothing changed: stop here, no further context spent.
3. If non-empty, read only the new lines: `git -C <agentics-path> diff <synced-sha> HEAD -- CHANGELOG.md`, not the whole file.
4. Surface one line per new entry. Lead with any `breaking: yes` entries and call them out explicitly: they usually mean a file this project copied (not just referenced) needs manual migration.
5. Let the user decide per entry, same as any outbound suggestion: no bulk auto-apply. A project's adopted copy may carry local deviations agentics has no way to know about.
6. Once reviewed (applied or explicitly skipped), update `synced` to agentics' current `HEAD` so the same entries don't resurface.

A semver comparison alone doesn't work here: agentics defers version bumps until a release is committed to remote, so `CHANGELOG.md` accumulates many `Unreleased` entries under one version tag for long stretches. The commit SHA is what's actually tracked; the version number is just a label for whichever plateau it's on.

**No tag, or a tag with no `synced` value:** don't run the diff above — there's no baseline to diff from, and a full historical walk back to adoption is mostly agentics' own internal iteration, not necessarily relevant to this project. Instead, offer to run the full procedure in `conventions/upgrading-adoption.md` § 1, which surfaces agentics' current `## Unreleased` entries as a bounded first-encounter catch-up and covers the tag, session-file migration, and `AGENTS.md` completeness together, rather than patching the tag in isolation.
