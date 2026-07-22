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
AGENTS.md                   canonical source: project-specific content, dispatch table, universal conventions
CLAUDE.md                   stub: Claude Code loads it automatically, it points at AGENTS.md for everything
DEVELOPMENT.md              human developer setup and onboarding guide (fill in per project)
.dev/
  roadmap.md                planned work across features and phases
  tech-debt.md              known issues with standalone/blocked tags
  sessions/                 one file per contributor per day, dated log of decisions and open threads
```

`conventions/`, `CLAUDE.roles/`, and `CLAUDE.softeng.md` are never copied into a project, under any circumstance: they're global-guideline material, not project content (see "Two tiers" below and `conventions/convention-levels.md` § How much to keep locally for the full rule). If your agent's global context doesn't yet define your role or your team's conventions, bootstrap it from those files directly, once, the same way `global-context/` templates get copied to `~/.claude/` (or your agent's equivalent), not a per-project step.

`.claude/settings.json` (Claude Code's credential-file protection hook) can be copied per project, or added to your global `~/.claude/settings.json` once instead.

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

**Single source, not two copies:** `AGENTS.md` holds the canonical dispatch table; `CLAUDE.md` points at it rather than keeping its own. This was originally the other way around, `AGENTS.md` inlining full content on the assumption that its consumers couldn't fetch a file on demand at all. That assumption was wrong: the AGENTS.md standard's own guidance recommends the same dispatch-on-demand pattern `CLAUDE.md` already used, since real AGENTS.md consumers (Cursor, Copilot, Aider) have file-system access like any other coding agent. One dispatch table, referenced from both files, removes a class of drift rather than managing it.

**Local clone versus remote URL is a separate axis.** It changes where a needed convention is fetched from, not whether it needs fetching at all. A contributor with agentics cloned locally and a new adopter working from a GitHub URL alone should both end up doing the same thing: reading tier-one content live, every session, from whichever source is actually available to them.

## Keeping up to date

On adoption, extend the version tag in the adopting project's `AGENTS.md` with a sync marker: `<!-- agentics-template-version: X.Y.Z | synced: <commit-sha> -->`, where `<commit-sha>` is this repo's `HEAD` at copy time. `CLAUDE.md` carries no tag at all: it's a stub pointing at `AGENTS.md` for everything, including this. With `propagation_suggestions: yes` set in the adopter's global context, their agent checks for updates automatically at session start (`template/conventions/convention-levels.md` § Checking for upstream updates) instead of requiring a manual CHANGELOG comparison.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to propose changes and how to create new role files.

If you discover a convention in your project that could benefit other teams, open a PR. Your agent will flag likely candidates as they surface.

Building something similar for your own team? [`docs/deterministic-by-design.md`](docs/deterministic-by-design.md) is the design philosophy behind how this repo tries to make its own conventions reliable: which parts should be a mechanical check wired into something that always runs, which parts need an explicit override instead of a plain instruction, and which parts should be made structurally impossible rather than caught after the fact.
