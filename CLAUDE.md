<!-- agentics-repo-version: 0.1.0 -->
# Agent collaboration conventions: softeng/agentics

**For AI agents:** this file is instructions your agent reads and follows; it is not documentation written for people. If you're a person looking to use or contribute to this repo, read [README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md) instead.

This is the agentics repo itself. Its purpose is to maintain and distribute the devctx collaboration template to softeng team members and developers broadly.

## Interaction parameters
- Ask clarifying questions before making large assumptions about intent
- Surface better alternatives as options; let the user decide
- Push back on bad ideas and identify blind spots before they are baked in
- Verify purpose alignment before implementing: when a task names a goal, check whether the chosen approach achieves that goal directly, not just something adjacent to it; lead with that gap as an objection before writing anything
- Flag scope-adjacent issues verbally, then document them in `.dev/tech-debt.md`

## Critical constraints
- No credentials, secrets, or private URLs in any file in this repo: ever
- This repo is the upstream source for other teams; keep content general and publicly safe
- No personal identifying details: no local usernames, real names of individual contributors, machine-specific absolute paths, or personal account/fork handles anywhere in this repo. Use generic placeholders instead: "the developer," "the repo's lead developer," "a local clone." Before committing, grep the diff for your own OS username, git identity, and any personal fork name you know is yours: this has leaked into committed docs before

## When to read what
- Starting a session → read `.dev/roadmap.md`, `.dev/tech-debt.md`, `.dev/sessions/`
- Reviewing or editing template files → read `template/CLAUDE.md` first to understand what we are maintaining
- Adding to project memory → check: could this be global? Could it be a template improvement?

## Memory and contribution hygiene
When writing to project memory: keep entries concise; store no content derivable from files. If an insight could apply to all projects, offer to promote it to global memory or global CLAUDE.md.

## Repo maintenance rules
- `template/` is the canonical deliverable; keep it accurate and in sync
- Update `CHANGELOG.md` and the version tag in `template/CLAUDE.md` whenever any template file changes
- AGENTS.md at repo root mirrors this file in agent-neutral framing; keep them in sync

## Initialization
If no project memory exists for you in this repo yet:
1. Check whether the user's role is already known from global context. If not, ask: "What best describes your primary work?": developer / bioinformatician / AI engineering / general.
2. If role is developer or AI engineer: ask "Are you an agentics contributor?": if yes, record `agentics_contributor: yes` **in your global context, not just this project's memory** — it needs to apply in every project, not only sessions inside agentics itself. This enables always-on propagation suggestions, names the agentics repo as an explicit candidate, and makes the upstream-update check mandatory (not opt-in) everywhere: see `CONTRIBUTING.md` § Agent setup for contributors.
3. Check whether softeng status is already known from global context: if not, ask.
Record role and softeng answers in project memory; record `agentics_contributor` in global context per above. Do not ask again.
