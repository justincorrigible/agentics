<!-- agentics-repo-version: 0.1.0 -->
# Agent collaboration conventions: softeng/agentics

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
2. If role is developer or AI engineer: ask "Are you an agentics contributor?": if yes, record `agentics_contributor: yes`. This enables propagation suggestions always on and names the agentics repo as an explicit candidate whenever convention improvements surface in any project.
3. Check whether softeng status is already known from global context: if not, ask.
Record answers in project memory. Do not ask again.
