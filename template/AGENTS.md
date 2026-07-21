<!-- agentics-template-version: see CHANGELOG.md § Released (latest entry) -->
# Agent collaboration conventions

**For AI agents:** this file is instructions your agent reads and follows; it is not documentation written for people. If you're a person looking for how this project works, see this project's own README or development guide instead.

Adapted from [softeng/agentics](https://github.com/oicr-softeng/agentics). This is the canonical source for this project's conventions, agent-neutral by design. `CLAUDE.md` exists only because Claude Code loads it automatically; it points here rather than keeping its own copy of anything.

## Interaction parameters
- Ask clarifying questions before making large assumptions about intent
- Surface better alternatives before presenting an implementation, not only after being asked why one wasn't offered; let the user decide
- Push back on bad ideas and identify blind spots before they are baked into code: lead with the objection, not a neutral trade-off list; don't wait to be asked
- Sanity check requests: not just the literal phrase. A yes/no-shaped question ("does this make sense," "am I right," "am I missing anything") is still a sanity check when its actual function is inviting scrutiny of the user's own idea, reasoning, or plan, not a literal yes/no about the world. Answer the intent, not the grammar: review the whole conversation as relevant, not just the latest message, and surface gaps, blind spots, unresolved threads, and edge cases plainly; a shallow "yes" isn't an answer
- Verify purpose alignment before implementing: when a task names a goal, check whether the chosen approach achieves that goal directly, not just something adjacent to it; lead with that gap as an objection before writing anything
- Flag scope-adjacent issues verbally, then document them in `.dev/tech-debt.md`

## Critical constraints
- No credentials, secrets, or private URLs in any file: ever
- Library/module code must not read from the environment; configuration belongs at the application boundary, passed in as typed parameters
- Do not modify `CLAUDE.md`, `AGENTS.md`, or other instruction files without explicit instruction from the developer: surface suggestions, do not self-edit
- No machine- or user-specific absolute paths, usernames, or individuals' real names in committed files. If your agent's global context adds a reference to a local resource keyed by machine or clone location (e.g. a per-project memory path), use a generic placeholder, not the resolved path: it will not exist for another developer, another machine, or after the repo moves
- Name code, not people: attribute work in session files, tech-debt entries, docs, and any other persisted content to features, modules, and systems, not to individuals. Attribution belongs in git history, not in documents

## When to read what

- Starting a session              -> read `conventions/session-discipline.md`, then the `.dev/` files it specifies
- Working in a specific role      -> read `CLAUDE.roles/<role>.md` (set during initialization; skip if role is already defined in global context)
- Writing or reviewing tests      -> read `conventions/testing.md`
- Writing code                    -> read `conventions/code-style.md`
- Reviewing a PR or change        -> read `conventions/code-style.md`, `conventions/code-review.md`
- Writing or updating docs        -> read `conventions/documentation.md`
- Security-relevant work          -> read `conventions/security.md` (credentials policy, supply chain, quick threat model), then `conventions/security-guidelines.md` (full OWASP patterns and code review triggers)
- softeng team member             -> read `CLAUDE.softeng.md` at session start
- Adding or improving a convention -> read `conventions/convention-levels.md`
- Upgrading this project's agentics integration -> read `conventions/upgrading-adoption.md`
- Deploying or debugging a service -> read `.dev/docs/<service>/` if it exists

## Memory and contribution hygiene
When writing to project memory: keep entries concise; store no content derivable from code or files. If an insight could apply to all your projects, offer to promote it to your agent's global context. If a convention could benefit other teams, flag it as a potential PR to the agentics repo.

## Initialization
If no project memory exists for you in this project yet:
1. Check whether you have access to a cross-project map in your agent's global context. If yes, read it for cross-project relationships. If no and the user works across multiple projects, offer to set one up (see `global-context/projects.md` in the agentics template for the recommended format).
2. Ask: "What best describes your primary work on this project?": developer / bioinformatician / AI engineering / general (non-code work) (or describe it). If the answer is already in your global context, skip this question. Otherwise read the matching file in `CLAUDE.roles/`.
3. Ask: "Are you part of the softeng team?": if yes, apply conventions from `CLAUDE.softeng.md` on top of your role conventions. Skip if already known from global context.
4. Ask: "Do you already have agent conventions for this project?": if yes, treat these conventions as supplementary; defer to your existing setup on conflicts.
5. Ask: "Would you like me to suggest when conventions could be useful beyond this project?": record as `propagation_suggestions: yes | no`. Skip if already known from global context.
Record all answers in project memory. Do not ask again.
