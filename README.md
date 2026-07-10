# softeng/agentics

A template for structured AI agent collaboration. Copy it into any project and your agent knows how to behave.

This is AI-native documentation applied to a whole codebase, not just a docs site: not just markdown that reads well, but instructions structured so an agent parses them correctly, fetches them reliably, and doesn't drown its own context window doing it.

This template goes further, though: its conventions also shape how the agent reasons and collaborates, not just what it can parse, a critical aspect other similar tools don't cover. In essence, an agent following it "questions" ideas instead of simply executing them blindly, whenever possible surfaces better alternatives, and checks that a proposed approach actually serves the stated goal before committing to one.

## Quick start

If this repo is accessible to your agent, say:

> "Set up my AI collaboration environment for this project using the agentics template."

Your agent will copy the template files into your project, ask you a few setup questions, and configure itself. That's it.

**What your agent will ask:**

1. What role best describes your work: developer, bioinformatician, AI engineering, or general (non-code work)
2. Whether you are on the softeng team (applies supplementary team conventions if yes)
3. Whether you already have agent conventions for this project (merges rather than replaces)
4. Whether you'd like it to suggest when patterns could be reused across projects

It stores your answers in project memory and does not ask again.

---

## What gets installed

```
CLAUDE.md                   project-specific conventions; dispatch to global context for universal rules
AGENTS.md                   comprehensive inline reference for agents without global context
CLAUDE.softeng.md           softeng team addendum: applied conditionally at session start
DEVELOPMENT.md              human developer setup and onboarding guide (fill in per project)
.dev/
  roadmap.md                planned work across features and phases
  tech-debt.md              known issues with standalone/blocked tags
  sessions/                 one file per contributor per day, dated log of decisions and open threads
```

**Optional bootstrapping files** (skip if already covered by your agent's global context):

```
CLAUDE.roles/               role-specific conventions (skip if role is defined globally)
CLAUDE.softeng.md           softeng team conventions (skip if already in global context)
conventions/                universal code style, testing, security, session discipline
                            (skip if your agent's global context defines these)
.claude/settings.json       credential file protection hook (Claude only;
                            prefer adding to ~/.claude/settings.json globally)
```

The project `CLAUDE.md` and `AGENTS.md` should contain only project-specific content once your global context is set up. `conventions/`, `CLAUDE.roles/`, and `CLAUDE.softeng.md` are for bootstrapping agents without a comprehensive global context, or for project-specific overrides of those conventions.

---

## If this repo is not yet in your agent's working directories

Add it, or clone it and point your agent at the local path. Then repeat the quick start prompt above.

For a manual adoption instead: copy the files from [`template/`](template/) into your project root and follow [`template/README.md`](template/README.md).

---

## Design

- **Dispatch, not dump**: `CLAUDE.md` stays lean; convention detail lives in separate files loaded only when relevant. See "Two tiers" below for what decides which conventions get copied in versus left as a live pointer.
- **Agent-neutral**: the template works with Claude, Codex, Copilot, and others. Role files, convention files, and `AGENTS.md` use no agent-specific paths.
- **Additive**: roles and org layers (softeng) add to the base; they do not replace it. Merging with your existing setup is always the right choice.
- **Contribution ladder**: good practices discovered in a project can bubble up: project memory → agent global context → PR to agentics.

### Two tiers: how often something is needed, not just how much

A convention only needs to be copied into the adopting project if reading it live, on demand, would fail silently. Everything else stays a pointer to agentics, whether that's a local clone or a remote URL.

**Needed every session, with no natural trigger of its own:** the session-start checklist, and the project's own version/sync marker. Nothing else prompts checking these, so if the check doesn't fire reliably, drift goes unnoticed. This was tested directly: a citation ("the base convention lives in X") did not reliably cause a fresh read of the current file; only an explicit instruction ("read X now, every session") did.

**Needed only when actually doing that task:** writing tests, reviewing a PR, security-relevant work, writing docs. These already have a strong trigger: the agent is doing that task right now. A live dispatch pointer works fine here, which is why `CLAUDE.md` can stay lean for all of them.

**The one deliberate exception:** `AGENTS.md` inlines both tiers, including the second one. It exists for agents that cannot fetch a file on demand at all: for that population nothing dispatches reliably, so the fallback pays the duplication cost instead. That's a bounded exception for a known limitation, not the default model.

**Local clone versus remote URL is a separate axis.** It changes where a needed convention is fetched from, not whether it needs fetching at all. A contributor with agentics cloned locally and a new adopter working from a GitHub URL alone should both end up doing the same thing: reading tier-one content live, every session, from whichever source is actually available to them.

## Keeping up to date

On adoption, extend the version tag in the adopting project's `CLAUDE.md` with a sync marker: `<!-- agentics-template-version: X.Y.Z | synced: <commit-sha> -->`, where `<commit-sha>` is this repo's `HEAD` at copy time. With `propagation_suggestions: yes` set in the adopter's global context, their agent checks for updates automatically at session start (`template/conventions/convention-levels.md` § Checking for upstream updates) instead of requiring a manual CHANGELOG comparison.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to propose changes and how to create new role files.

If you discover a convention in your project that could benefit other teams, open a PR. Your agent will flag likely candidates as they surface.
