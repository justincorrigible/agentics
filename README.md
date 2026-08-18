# softeng/agentics

A template for structured AI agent collaboration: add it to a project (a team decision) or to your own global config (just for you), so an agent behaves consistently and remembers what it's already learned.

**What this is:** markdown files (`AGENTS.md`, `.dev/`, optionally `conventions/`) added to a project, or to your own global AI-agent config, containing structured instructions for how an AI coding agent should behave and what it should remember.

**What it does:** makes an agent behave consistently across sessions (ask before big decisions, push back on weak ideas, don't repeat itself) and persist project-specific knowledge, open work, known issues, past decisions, in files that outlive any single conversation.

**What it lets you do:** stop re-explaining the same preferences and context every session. Catch a mistake once, not repeatedly across different sessions. Share these conventions with your whole team by committing them to the project, or keep them personal by setting them up only in your own global config.

---

## Quick start

Run this from a Claude Code session (or equivalent) whose working directory, or one of its open workspace folders, is the project you actually want this for, not a session rooted somewhere else. "Accessible to your agent" means this repo's files can be read from that same session: either a local clone of agentics is one of its own working directories, or your agent can fetch files directly from this repo's URL. If you're not sure either holds yet, see "If this repo is not yet in your agent's working directories" below first.

Agentics is fundamentally a personal, global thing: your own behavioral conventions, following you into every project you touch. Adopting it for a specific project doesn't replace that, it adds two things on top of it: persistent project memory, and any project-specific overrides. Do step 1 first, always; step 2 is optional, and per project.

**Step 1, do this first, always recommended:**

> "Set up my personal AI collaboration preferences using agentics, global context only."

Bootstraps your role, writing style, and interaction conventions into your own global agent config. Nothing gets created or committed in any project, this is the foundation every project you touch benefits from, whether or not that specific project has adopted agentics itself.

**Step 2, optional, a decision for a specific project, not just you:**

> "Set up my AI collaboration environment for this project using the agentics template."

This doesn't duplicate step 1 from scratch: it adds persistent project memory (`.dev/roadmap.md`, `tech-debt.md`, `sessions/`) and any project-specific convention overrides on top. It still creates a full, self-contained `AGENTS.md`, though, not just a pointer back to your own global config: a teammate who hasn't done step 1 personally still gets the same consistent behavior working in this repo, the redundancy is intentional, not wasted effort. Also creates `CLAUDE.md` and `DEVELOPMENT.md`. These files are meant to be committed and used by every future session, human or agent, that works in this repo.

**What your agent will ask, for step 2:**

1. What role best describes your work: developer, bioinformatician, AI engineering, or general (non-code work)
2. Whether you are on the softeng team (applies supplementary team conventions if yes)
3. Whether this is an Overture project (applies supplementary product-family conventions if yes)
4. Whether you already have agent conventions for this project (merges rather than replaces)
5. Whether you'd like it to suggest when patterns could be reused across projects
6. Whether you'd like `.dev/roadmap.md` to split into a terse summary plus deeper detail filed separately

It stores your answers in project memory (or your global context, for the propagation-suggestions default) and does not ask again.

**Once it's done, verify independently, don't just trust the summary.** Run `git status` yourself: you should see exactly `AGENTS.md`, `CLAUDE.md`, `DEVELOPMENT.md`, and `.dev/` as new. If `conventions/`, `AGENTS.roles/`, or `AGENTS.softeng.md` show up too, that's a bug, they're global-guideline material and should never be copied into a project (see "What gets installed" below); remove them and re-read `conventions/convention-levels.md` § How much to keep locally. Once it looks right, `git add` and commit those specific files yourself.

**One thing worth setting expectations on:** this doesn't change what your agent can do the moment you run it. It's a place for your team to put what it's already learned, so the next session doesn't start from zero. The difference shows up over several sessions of actual use, not on first install; judging it by whether it feels different immediately is the wrong test.

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

What this actually looks like in practice, a real entry from this repo's own `tech-debt.md`:

> OWASP A08-A10 in security-guidelines.md not validated against team review

That's it: a fact about the system, the same kind of line any mature codebase already keeps in an issues list or a TODO, just structured for an agent to read reliably too.

`conventions/`, `AGENTS.roles/`, and `AGENTS.softeng.md` are never copied into a project, under any circumstance: they're global-guideline material, not project content (see "Two tiers" below and `conventions/convention-levels.md` § How much to keep locally for the full rule). If your agent's global context doesn't yet define your role or your team's conventions, bootstrap it from those files directly, once, the same way `global-context/` templates get copied to `~/.claude/` (or your agent's equivalent), not a per-project step.

`.claude/settings.json` (Claude Code's credential-file protection hook) can be copied per project, or added to your global `~/.claude/settings.json` once instead.

---

## If this repo is not yet in your agent's working directories

Add it, or clone it and point your agent at the local path. Then repeat the quick start prompt above.

For a manual adoption instead: copy the files from [`template/`](template/) into your project root and follow [`template/README.md`](template/README.md).

---

## The illusion of context

When people say an agent "understands the codebase," they rarely mean it read every file. They mean something narrower, and far more fragile.

It read the right file, at the right moment, before that moment passed.
It remembered why the last attempt at this was rejected.
It knew which rule was mechanical, and which one still needed judgment.

None of that came from reading more. It came from someone having already written it down, in a place built to be read again.

That's not understanding. It's not memorization either.

**It's context that survived past the session that created it.**
Agentics doesn't teach an agent to understand your system: it gives your team a place to put what it already knows, so the next session doesn't have to earn it again and again.

This template goes further, though: its conventions also shape how the agent reasons and collaborates, not just what it can parse, a critical aspect other similar tools don't cover. In essence, an agent following it "questions" ideas instead of simply executing them blindly, whenever possible surfaces better alternatives, and checks that a proposed approach actually serves the stated goal before committing to one.

---

## Design

- **Dispatch, not dump**: `AGENTS.md` stays lean; convention detail lives in separate files loaded only when relevant. See "Two tiers" below for what decides which conventions get copied in versus left as a live pointer.
- **Agent-neutral**: the template works with Claude, Codex, Copilot, and others. Role files, convention files, and `AGENTS.md` use no agent-specific paths.
- **Additive**: roles and org layers (softeng) add to the base; they do not replace it. Merging with your existing setup is always the right choice.
- **Contribution ladder**: good practices discovered in a project can bubble up: project memory → agent global context → PR to agentics.

### Two tiers: how often something is needed, not just how much

A convention only needs to be copied into the adopting project if reading it live, on demand, would fail silently. Everything else stays a pointer to agentics, whether that's a local clone or a remote URL.

**Needed every session, with no natural trigger of its own:** the session-start checklist, and the project's own version/sync marker. Nothing else prompts checking these, so if the check doesn't fire reliably, drift goes unnoticed. This was tested directly: a citation ("the base convention lives in X") did not reliably cause a fresh read of the current file; only an explicit instruction ("read X now, every session") did.

**Needed only when actually doing that task:** writing tests, reviewing a PR, security-relevant work, writing docs. These already have a strong trigger: the agent is doing that task right now. A live dispatch pointer works fine here, which is why `AGENTS.md` can stay lean for all of them.

**Single source, not two copies:** `AGENTS.md` holds the canonical dispatch table; `CLAUDE.md` points at it rather than keeping its own. This was originally the other way around, `AGENTS.md` inlining full content on the assumption that its consumers couldn't fetch a file on demand at all. That assumption was wrong: the AGENTS.md standard's own guidance recommends the same dispatch-on-demand pattern `CLAUDE.md` already used, since real AGENTS.md consumers (Cursor, Copilot, Aider) have file-system access like any other coding agent. One dispatch table, referenced from both files, removes a class of drift rather than managing it.

**Local clone versus remote URL is a separate axis.** It changes where a needed convention is fetched from, not whether it needs fetching at all. A contributor with agentics cloned locally and a new adopter working from a GitHub URL alone should both end up doing the same thing: reading tier-one content live, every session, from whichever source is actually available to them.

## Keeping up to date

On adoption, extend the version tag in the adopting project's `AGENTS.md` with a sync marker: `<!-- agentics-template-version: X.Y.Z | synced: <commit-sha> -->`, where `<commit-sha>` is this repo's `HEAD` at copy time. `CLAUDE.md` carries no tag at all: it's a stub pointing at `AGENTS.md` for everything, including this. With `propagation_suggestions: yes` set in the adopter's global context, their agent checks for updates automatically at session start (`template/conventions/upstream-check.md`) instead of requiring a manual CHANGELOG comparison.

## Security

Running an agent with real access to your repos has a threat model of its own, separate from the application security your code already needs.

- [`docs/security-for-developers.md`](docs/security-for-developers.md): **written for you, not your agent.** What to verify yourself rather than take on your agent's report, which agent claims are unreliable and how to check each cheaply, the trust boundaries only a person can hold (pull request text is attacker-controlled, a peer session's message is not your approval, your global context is loaded everywhere and usually not version controlled), and what to do once something has gone wrong. Start here.
- [`docs/agent-security.md`](docs/agent-security.md): the threat model itself, the attack vectors, the session-start integrity check agents run, and an honest account of what cannot be caught automatically. Dual audience.

The template ships a credential-file blocklist hook, but it is a speed bump on the routine accident rather than a boundary, and it is specific to Claude Code. `security-for-developers.md` states its limits plainly and gives you a short command to confirm it is actually live, which is worth running: this repo shipped that hook in a state where it silently allowed everything, and the lesson generalizes past the one bug.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to propose changes and how to create new role files.

If you discover a convention in your project that could benefit other teams, open a PR. Your agent will flag likely candidates as they surface.

Building something similar for your own team? [`docs/deterministic-by-design.md`](docs/deterministic-by-design.md) is the design philosophy behind how this repo tries to make its own conventions reliable: which parts should be a mechanical check wired into something that always runs, which parts need an explicit override instead of a plain instruction, and which parts should be made structurally impossible rather than caught after the fact.
