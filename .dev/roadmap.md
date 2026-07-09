# Roadmap

Items are open unless marked `[in progress]`. Completed items are removed.

## Phase 2: implementation

- softeng layer: fill in `template/CLAUDE.softeng.md` with actual team conventions. Known content to include:
  - **Security tooling:** Dependabot (npm) + Trivy (infra/Docker) for vulnerability scanning; Vault/ESO (External Secret Operator) for secrets management; Keycloak security settings (rate limiting, account lockout, MFA); `#oicr-security-alerts` Slack channel as team vulnerability feed
  - **npm security defaults:** `.npmrc` with `ignore-scripts=true`, `audit=false`, `save-exact=true`, `fund=false`; run `npm audit` as a CI gate, not on install
  - **SBOM generation:** npm for JS projects, Maven for Java projects: already in practice, needs documenting as a convention
  - **Structured logging standards:** prerequisite for log monitoring; format and field conventions TBD with DevOps
  - **Environment/config validation:** apps should error out if default or missing credentials are detected at startup
  - **System credential rotation:** interval for rotating DB and service connection passwords: align with DevOps/TRA recommendations
  - **Tooling preferences, workflow practices, naming conventions, project relationships** (other non-security softeng conventions)
- DEVELOPMENT.md: fill in the template with real setup and onboarding guidance
- AGENTS.md per-agent tuning: AGENTS.md is now comprehensive rather than a parity copy; review whether specific agents (Codex, Copilot, Gemini) benefit from different framing of sections already present

## Phase 3: personal context portability

Goal: a user can maintain a private GitHub repo mirroring their `~/.claude/` global setup (CLAUDE.md customizations + global memories), so that switching to a new Claude account doesn't erase accumulated rapport and preferences.

Design sketch:
- User creates a private repo (e.g. `<user>/claude-context`) following a structure agentics defines
- Suggested structure: `CLAUDE.md` (global instructions snapshot), `memory/MEMORY.md` + memory files, optionally `projects/<project>/memory/` for project-specific memories
- agentics provides: template for the private repo structure, a standard bootstrap prompt the user gives a fresh agent to reconstitute context from the private repo, guidance on what belongs there (preferences, feedback patterns, working style) and what does not (credentials, project-specific ephemera, anything derivable from code)
- Sync discipline: end-of-session or on-demand; the user commits manually: no automated push

Open questions:
- Should agentics include a `template/personal-context/` scaffold, or document the pattern only in prose?
- How does the bootstrap prompt discover which projects to also load memories for?
- Where does the private repo live relative to agentics in the contribution/update-propagation model?

## Design questions: needs more thinking

- **Startup instruction-file integrity check:** at session start, run `git log --oneline -- CLAUDE.md AGENTS.md` and flag unexpected changes not made by the repo's lead developer; useful tamper signal but adds a mechanical step: decide whether this is a hard rule, optional guidance, or a softeng-specific convention
- **Context sync across projects:** the upstream-update check (`convention-levels.md` § Checking for upstream updates) now surfaces drift automatically for opted-in projects, but the "source of truth" ownership model is still informal: which conventions are global, which are template, which are project-specific, and how to reason about overlap when a project has genuinely diverged on purpose

- **Integration with existing agent setups:** the current approach (initialization question + "supplementary" flag) is minimal; deeper questions remain: should the agent offer to review existing conventions for conflicts? How prescriptive should softeng conventions be when a rich setup is already in place? Is "supplement on conflict" even the right default, or should users choose a merge strategy?
- **Non-softeng users:** the general layer already serves anyone, but the template flow and README still implicitly frame softeng as the "extra" and everyone else as the base case; explore whether the initialization flow, framing, and contribution model should be more explicitly welcoming to teams outside softeng adopting the pattern wholesale
- **Dev vs. non-dev users:** the template currently assumes a developer audience (code reviews, test conventions, OWASP); consider a third initialization question: "Do you work primarily in code, or in planning/documentation/research?": and distinct dispatch paths or convention sets for each; non-dev users may benefit from lighter session discipline and different convention files (e.g. writing style, doc structure) rather than testing and code-style
- **Response verbosity/tone calibration per role:** distinct from the item above, which is about which conventions load. This is about how the agent talks once it's using them. A session working through the upstream-update-check design was appropriately thorough for a dev/AI-eng/contributor audience (file diffs, precedence mechanics, why something changed) — the same level of detail would read as noise to a general (non-dev) user, who likely wants outcomes and next steps with detail available on request, not by default. `CLAUDE.roles/*.md` currently shape *what* applies per role, not *how verbose or technical* the agent's own responses should be for that role; needs its own dispatch, probably as a short section per role file rather than a new mechanism
