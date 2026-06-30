<!-- agentics-template-version: 0.1.0 -->
# Agent collaboration conventions

Adapted from [softeng/agentics](https://github.com/oicr-softeng/agentics). To get updates, compare this file's version tag against the agentics CHANGELOG.

## Interaction parameters
- Ask clarifying questions before making large assumptions about intent
- Surface better alternatives as options; let the user decide
- Push back on bad ideas and identify blind spots before they are baked into code: lead with the objection, not a neutral trade-off list; don't wait to be asked
- Flag scope-adjacent issues verbally, then document them in `.dev/tech-debt.md`

## Critical constraints
- No credentials, secrets, or private URLs in any file: ever
- Library/module code must not read from the environment; configuration belongs at the application boundary, passed in as typed parameters
- Do not modify instruction files without explicit developer instruction: surface suggestions, do not self-edit

## When to read what

**If your agent's global context defines universal conventions (testing, code style, security, session discipline), trim this section to project-specific entries only. The full dispatch below is a starting point for agents without a comprehensive global context.**

- Starting a session              -> read `conventions/session-discipline.md`, then the `.dev/` files it specifies
- Working in a specific role      -> read `CLAUDE.roles/<role>.md` (set during initialization; skip if role is already defined in global context)
- Writing or reviewing tests      -> read `conventions/testing.md`
- Writing code or doing reviews   -> read `conventions/code-style.md`
- Security-relevant work          -> read `conventions/security-guidelines.md`
- softeng team member             -> read `CLAUDE.softeng.md` at session start
- Adding or improving a convention -> read `conventions/convention-levels.md`
- Deploying or debugging a service -> read `.dev/docs/<service>/` if it exists

## Memory and contribution hygiene
When writing to project memory: keep entries concise; store no content derivable from code or files. If an insight could apply to all your projects, offer to promote it to your agent's global context. If a convention could benefit other teams, flag it as a potential PR to the agentics repo.

## Initialization
If no project memory exists for you in this project yet:
1. Check whether you have access to a cross-project map in your agent's global context. If yes, read it for cross-project relationships. If no and the user works across multiple projects, offer to set one up (see `global-context/projects.md` in the agentics template for the recommended format).
2. Ask: "What best describes your primary work on this project?": developer / bioinformatician / AI engineering / general (or describe it). If the answer is already in your global context, skip this question. Otherwise read the matching file in `CLAUDE.roles/`.
3. Ask: "Are you part of the softeng team?": if yes, apply conventions from `CLAUDE.softeng.md` on top of your role conventions. Skip if already known from global context.
4. Ask: "Do you already have agent conventions for this project?": if yes, treat these conventions as supplementary; defer to your existing setup on conflicts.
5. Ask: "Would you like me to suggest when conventions could be useful beyond this project?": record as `propagation_suggestions: yes | no`. Skip if already known from global context.
Record all answers in project memory. Do not ask again.
