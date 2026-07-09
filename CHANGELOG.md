# Agentics - Changelog

Entries in reverse-chronological order.
Format: `date | category | breaking? | description`

Categories: `template`, `conventions`, `softeng`, `repo`
Breaking: `yes` (downstream copies require manual update) / `no` (additive or clarification only)

---

## Unreleased

- `2026-07-08 | conventions | yes | sessions-per-contributor-file`: replace the single shared `.dev/sessions.md` with `.dev/sessions/`, one file per contributor per day (`YYYY-MM-DDTHHMMSS.md`, no descriptive slug): filename uniqueness is what prevents cross-contributor merge conflicts, not smaller files or a slug. Session-start checklist now reads the most recent 1-2 files by sorted filename instead of a shared entry list; authorship for "is this file mine" is determined via `git log`/`git config user.email`, never written into file content. Updates `template/conventions/session-discipline.md`, `template/AGENTS.md`, `template/README.md`, `template/DEVELOPMENT.md`, `template/CLAUDE.roles/*.md`, `template/conventions/{convention-levels,security,security-guidelines}.md`, `template/global-context/{roadmap,security-guidelines}.md`, and root `README.md`/`AGENTS.md`/`CLAUDE.md`. Downstream adopters need to migrate their own `.dev/sessions.md` (see this repo's own `.dev/sessions/` for a worked example of a retroactive split).
- `2026-07-08 | conventions | no | repo-url-local-first`: add `Repo URL` field and a local-first resolution rule to `global-context/projects.md`: prefer a project's local clone over fetching its GitHub URL, since local may be ahead of origin; verify freshness with `git log @{u}..` first unless the repo is sole-maintained
- `2026-07-08 | conventions | no | name-code-not-people-backfill`: the `2026-07-07 | name-code-not-people` entry below claimed the rule was added to `conventions/session-discipline.md` and `template/CLAUDE.md`; neither file actually had it. Added it to both now. Left the original entry as-is (immutable historical record) rather than editing it after the fact.
- `2026-07-08 | conventions | no | global-dispatch-not-duplicate`: add guidance to `conventions/convention-levels.md`: a global agent context that has adopted agentics as its base should reference the template for conventions it already covers rather than holding a full duplicate copy, keeping only genuinely local refinements or stated overrides. A duplicated convention drifts silently when one copy is updated and the other isn't.

- `2026-07-08 | conventions | no | dash-rule-absolute`: strengthen dash avoidance in code-style.md and session-discipline.md: rule is now absolute with no conversational-chat exemption; drafts and chat responses are explicitly included since they are routinely pasted or submitted; drops "persisted prose" scope qualifier

- `2026-07-08 | template | no | general-role-label`: clarify "general" role option in README.md and template/CLAUDE.md initialization block: add "(non-code work)" parenthetical so new adopters understand what the option covers without reading the role file first

- `2026-07-08 | conventions | no | code-review`: add `conventions/code-review.md`: pre-review gate requiring purpose, layer ownership, and necessity to be established before examining implementation; update `template/CLAUDE.md` dispatch to split "writing code or doing reviews" into separate writing and reviewing entries (reviewing reads both code-style and code-review); add inline "Code review" section to `template/AGENTS.md`

- `2026-07-07 | conventions | no | global-roadmap-split`: add `global-context/roadmap.md` template and convention for splitting global roadmaps by work context (e.g. `roadmap-work.md` vs `roadmap-personal.md`); extend session-start checklist in `session-discipline.md` step 2 to read only the roadmap relevant to the current project context; update `global-context/README.md` file list

- `2026-07-07 | conventions | no | documentation-structure`: add `conventions/documentation.md` defining the two-tier docs model (`/docs` for consumers, `.dev/docs` for contributors), cross-linking over duplication, and the rule that `/docs` links to `.dev/docs` files must use full GitHub URLs (relative paths break on hosted docs sites); add dispatch entry to `template/CLAUDE.md`

- `2026-07-07 | conventions | no | name-code-not-people`: add "Name code, not people" rule to `conventions/session-discipline.md` and `template/CLAUDE.md`: attribute work to features, modules, and systems - not to individuals; attribution belongs in git history, not in sessions.md, tech-debt, docs, or any other persisted content

- `2026-07-07 | template | no | no-machine-specific-paths`: add "No machine- or user-specific absolute paths in committed files" to Critical constraints in template/CLAUDE.md and template/AGENTS.md: a resolved local resource path (e.g. a per-project memory path) breaks for other developers, other machines, and after the repo moves; use a generic placeholder instead. Found via a leaked Claude project-memory path committed in a downstream project's CLAUDE.md.

- `2026-06-30 | conventions | no | dependency-version-verification`: add "Dependency version verification" to template/conventions/code-style.md after Library awareness: always run `npm view <package> version` (or equivalent) before writing a version into any config; do not use versions from training data; "already used in this repo" does not imply currency

- `2026-06-30 | template | no | purpose-alignment`: add "verify purpose alignment before implementing" to Interaction parameters in template/CLAUDE.md, CLAUDE.md, and AGENTS.md: when a task names a goal, the agent must check whether the chosen approach achieves that goal directly rather than something adjacent; lead with the gap as an objection before writing anything

- `2026-06-30 | repo | no | agent-security-docs`: add `docs/agent-security.md` covering 7 AI agent attack vectors (configuration injection/CBSE, indirect prompt injection, Comment and Control, MCP server poisoning, supply chain attacks, self-replicating worms, memory/RAG poisoning); session-start integrity check guidance; what agents cannot catch automatically; threat intelligence sources; extend session-discipline.md git log check to include `.claude/settings.json`

- `2026-06-28 | conventions | no | session-effects-not-style`: add "write about effects, not style" rule to conventions/session-discipline.md: session bullets must describe what the code now does for operators, users, or callers; style choices, refactoring approach, and helper names are noise

- `2026-06-28 | conventions | no | functional-style`: add "Conditional logic and functional style" to conventions/code-style.md: guidance to write code where the happy path is immediately visible, values come from expressions not mutation, and reusable logic is isolated in named functions; includes TypeScript before/after example

- `2026-06-28 | softeng | no | np-client-ingress`: add NetworkPolicy client ingress check to CLAUDE.softeng.md stateful-service deployment steps: operators generate NPs for their own internal traffic, not for application clients; always add a supplemental kustomize NP allowing client pods to reach the service port; common ports listed; section numbered 3 (deployment-order renumbered to 4)

- `2026-06-27 | conventions | no | pnpm-supply-chain`: add Node.js/pnpm supply chain section to conventions/security.md: pnpm v10+ blocks install scripts by default (A08 control); always set confirm-modules-purge=false and scarf-js-opt-out=true in .npmrc; use allowBuilds in pnpm-workspace.yaml to explicitly approve packages that need install scripts; @scarf/scarf always false

- `2026-06-26 | conventions | no | tsdoc-for-exports`: add TSDoc for exported symbols convention to conventions/code-style.md: all exported functions, types, and interfaces require a brief TSDoc comment; distinct from the no-comments rule (which applies to inline implementation code); inline member comments for non-obvious fields; apply to new exports, log as tech-debt if missing on existing exports

- `2026-06-26 | template | no | optional-bootstrapping-files`: clarify that conventions/, CLAUDE.roles/, and CLAUDE.softeng.md are bootstrapping artifacts, not permanent per-project files: skip them if your agent's global context already defines universal conventions, role, and team conventions; project CLAUDE.md should contain only project-specific content; updated template/CLAUDE.md dispatch table, template/README.md How-to-adopt section, and root README.md file manifest

- `2026-06-26 | conventions | no | fix-small-things-immediately`: add "fix in place vs. log as tech-debt" distinction to scope discipline: if a scope-adjacent issue can be fixed in a minute without risk, fix it; tech-debt is for genuinely deferred work, not one-liners; updated conventions/code-style.md and AGENTS.md

- `2026-06-26 | repo | no | global-settings-note`: add note to README explaining that teams with a global ~/.claude/settings.json should move the PreToolUse credential hook there instead of copying the per-project .claude/settings.json into each repo

- `2026-06-25 | template | no | dev-docs-structure`: add `.dev/docs/` pattern to DEVELOPMENT.md and CLAUDE.md: per-service subdirectory (e.g. `docs/postgres/`), root `index.md`, read the relevant guide before deploying or debugging a specific service

- `2026-06-25 | template | no | direct-opposition`: strengthen pushback convention in CLAUDE.md interaction parameters: lead with the objection rather than a neutral trade-off list; add explicit "no ego" framing; direct "this is not a good idea because X" is more useful than diplomatic hedging

- `2026-06-25 | softeng | no | naming-conventions`: fill in "Naming conventions" section of CLAUDE.softeng.md: psql-db/mongo-db/vso companion naming pattern; Helm release names match helm/ subdirectory; TF resource names match release names
- `2026-06-25 | softeng | no | tooling-ci-registry`: fill in remaining tooling TODO in CLAUDE.softeng.md: CI/Jenkins/tfDeploy.groovy, ghcr.io registry, softeng OCI chart repo, stateful operator/chart table (CNPG, MongoDB Community, opensearch-k8s-operator, Strimzi, Keycloak/keycloakx)

- `2026-06-23 | softeng | no | stateful-deploy-guide`: add "Deploying stateful services" section to CLAUDE.softeng.md: Jenkins CRD access (aggregation vs manual ClusterRole entry; config-jenkins-instances pattern), credential bootstrap direction (CNPG auto-generates and you copy to Vault; MongoDB Community requires Vault pre-seeded before operator applies), deployment order rule
- `2026-06-23 | conventions | no | tf-resource-ordering`: extend property-ordering rule to Terraform resource blocks: alphabetize by resource name; VSO companion follows its primary; insertion point anchor must not override alphabetical placement

- `2026-06-22 | conventions | no | sessions-immutability`: add sessions.md append-only rule to session-discipline.md: only today's entry is editable; prior entries are immutable historical record; revise before the session ends, not later
- `2026-06-22 | conventions | no | dev-docs-staleness-pass`: add staleness pass to session-start checklist in session-discipline.md: mark completed roadmap items done, close resolved PINNEDs, remove addressed tech-debt before starting new work
- `2026-06-22 | softeng | no | keycloak-exception`: add Keycloak exception to operator-first rule: use codecentric/keycloakx chart; Keycloak Operator is namespace-scoped by default and incompatible with shared cluster-wide DevOps installation model
- `2026-06-22 | softeng | no | operator-preferences`: replace no-Bitnami wording with positive preference (project-owned and community operators over vendor-bundled charts); remove Keycloak Operator from operator-first list; add PINNED roadmap entry format
- `2026-06-22 | softeng | no | tf-root-structure`: add Terraform root structure convention to CLAUDE.softeng.md: exactly two roots per environment (stateless/stateful); management-plane TF providers (e.g. mrparkers/keycloak) go in stateless alongside hashicorp/helm, not in a third root
- `2026-06-21 | conventions | no | sessions-entry-format`: add sessions.md entry format to session-discipline.md: one context sentence + one bullet per file/logical group; decisions and constraints inline only when non-obvious; no prose paragraphs
- `2026-06-21 | softeng | no | k8s-infra-conventions`: add Kubernetes infrastructure conventions to CLAUDE.softeng.md tooling preferences: operator-first for stateful services (CNPG, MongoDB Community Operator, opensearch-k8s-operator, Strimzi; PINNED items over standalone workarounds); VSO-everywhere for secret injection (direct Vault access and TF data sources are anti-patterns; -vso companion releases mandatory)
- `2026-06-19 | conventions | no | structured-logging`: add structured logging convention to AGENTS.md and conventions/code-style.md: emit key-value pairs or JSON, mandatory fields, mandatory for auth/access/export/error boundaries, set up before application logic
- `2026-06-19 | conventions | no | property-ordering`: add property ordering convention to AGENTS.md and conventions/code-style.md: alphabetize config properties at all nesting levels
- `2026-06-19 | conventions | no | language-spelling`: expand Language entry in AGENTS.md to mention spelling convention placeholder with Canadian English example
- `2026-06-19 | template | no | lean-project-agents`: establish lean project AGENTS.md pattern: project-specific content inline, universal conventions compressed to pointers to agentics template; demonstrated in Arranger AGENTS.md
- `2026-06-19 | template | no | role-profiles`: add CLAUDE.roles/ with dev.md, general.md, bio.md, ai-eng.md; role question added to initialization block in CLAUDE.md and AGENTS.md; general.md serves as foundation for non-developer specialist profiles
- `2026-06-19 | conventions | no | propagation-opt-in`: add propagation suggestions opt-in to initialization block and convention-levels.md: agents ask once, record preference, surface suggestions at moment of discovery when opted in
- `2026-06-19 | repo | no | contributing`: add CONTRIBUTING.md: design principles, how to propose changes, how to create new role files including the general-as-foundation pattern and role table
- `2026-06-19 | repo | no | readme-wizard`: rewrite README.md as install wizard: action-first quick start with bootstrap prompt, init question list, file manifest, design principles; manual adoption path moved below the fold
- `2026-06-19 | conventions | no | session-signals`: add session-start signal detection and context refresh to session-discipline.md and AGENTS.md: greetings and resumption phrases trigger session-start checklist including instruction file freshness check; context efficiency note (re-read is additive not replacing; new thread preferred when many files changed)
- `2026-06-19 | repo | no | agentics-contributor`: add agentics_contributor flag: set in project memory to enable always-on propagation with agentics repo as explicit candidate; documented in CONTRIBUTING.md agent setup section, convention-levels.md propagation opt-in, and initialization block in root CLAUDE.md/AGENTS.md

## 0.1.0

- `2026-06-03 | template | no | security-hook`: add `.claude/settings.json` PreToolUse hook blocking access to credential files (.env, _.pem, _.key, SSH keys, cloud credentials); enforces the no-credentials policy at the tool level
- `2026-06-03 | conventions | no | code-style`: add "Searching before writing" section to conventions/code-style.md
- `2026-06-03 | conventions | no | session-discipline`: add conventions/session-discipline.md: session start checklist, .dev/ write-back rules, tech-debt entry format with standalone/context tags
- `2026-06-03 | template | no | instruction-governance`: add "do not self-edit instruction files" to CLAUDE.md critical constraints
- `2026-06-03 | template | no | agents-comprehensive`: AGENTS.md redesigned as comprehensive inline reference for non-Claude agents; no longer a parity copy of CLAUDE.md
- `2026-06-03 | conventions | no | convention-levels`: add conventions/convention-levels.md: three-level placement model (project/global/shareable) and propagation question framework; wired into CLAUDE.md dispatch and AGENTS.md inline
- `2026-06-03 | template | no | cross-project-awareness`: add global-context/projects.md template for cross-project map; wired into initialization block and convention-levels.md propagation step (renamed from personal-context/ for agent-neutral framing)
- `2026-06-05 | conventions | no | security-guidelines`: add conventions/security-guidelines.md: full OWASP Top 10:2025 patterns, failure state docs, code review triggers; conventions/security.md updated to dispatch to it
- `2026-06-05 | template | yes | agent-neutral`: removed all ~/.claude/ path references from AGENTS.md, CLAUDE.md, conventions/, and README; all template files are now fully agent-neutral; ~/.claude/ references remain only in the user's own Claude-specific global files outside the template

- `2026-06-02 | template | no | init`: initial template structure: CLAUDE.md dispatch file, conventions/ (testing, code-style, security), CLAUDE.softeng.md placeholder, DEVELOPMENT.md placeholder
