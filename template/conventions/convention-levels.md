# Convention levels

Every convention lives at one of three levels. Placing it at the right level prevents drift and eliminates sync work.

## The three levels

**Project-specific**
Applies to this project only: domain vocabulary, key file paths, test commands, active project context. Lives in the project's `CLAUDE.md` or `.dev/`.

**Global**
Applies to all the developer's projects: behavioural conventions (testing style, scope discipline, checking in), tooling preferences, interaction style. Belongs in `~/.claude/CLAUDE.md`. Always loaded: updating it once propagates to every project automatically.

If you've adopted the agentics template as your base, global should not hold a full copy of a convention that already lives there: it should reference agentics and add only the refinements that are actually local (things agentics doesn't cover, or a deliberate override, stated as such). A duplicated convention drifts the moment either copy changes; a referenced one can't.

**Shareable (template)**
Structural patterns that benefit other teams: dispatch table wiring, `.dev/` layout, initialization flow, the credential file hook. Belongs in the [agentics template](https://github.com/oicr-softeng/agentics). Adopted by copying and adapting.

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

**Agentics contributors:** if `agentics_contributor: yes` is set in project memory, propagation is always on without asking: and the agentics repo is always named as an explicit candidate alongside the other levels. See `CONTRIBUTING.md` in the agentics repo for how to set this up.
