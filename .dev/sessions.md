# Sessions

## 2026-07-07

Codified a portability rule after finding a downstream project (Usher) had a machine-resolved Claude memory path committed into its `CLAUDE.md`; would not resolve for another developer or machine.

- `template/CLAUDE.md`, `template/AGENTS.md`: added "No machine- or user-specific absolute paths in committed files" to Critical constraints
- `CHANGELOG.md`: no-machine-specific-paths entry logged

---

## 2026-06-30

Added agent security threat documentation; agents now check config files at session start as a tamper signal.

- `docs/agent-security.md`: new document covering 7 attack vectors (CBSE/hook injection, indirect prompt injection, Comment and Control, MCP poisoning, supply chain attacks via npm/pip, Morris II-style worms, memory/RAG poisoning); includes session-start integrity check guidance, what agents cannot catch automatically, and threat intelligence sources
- `template/conventions/session-discipline.md`: extended git log check in "Starting a session" step 1 to include `.claude/settings.json`; added unexpected-change response guidance and pointer to the new security doc
- `CHANGELOG.md`: agent-security-docs entry logged

---

## 2026-06-28

Extended code style guidance and session-discipline guidance; convention texts elevated from a practical refactor in the Arranger codebase.

- `template/conventions/code-style.md`: new section guiding agents to write code where the happy path is immediately visible, values are produced by expressions rather than mutated in place, and reusable logic is isolated in named functions with defined inputs and outputs; each principle is independently useful but together they make intent readable without decoding implementation detail
- `template/conventions/session-discipline.md`: added "write about effects, not style" rule: session bullets should describe what the code now does for operators, users, or callers - not the style or structure in which it was written
- `CHANGELOG.md`: functional-style and effects-not-style entries added

---

## 2026-06-26

Scaffolded Lyric devctx; identified that conventions/ and CLAUDE.roles/ are over-scaffolded (global context covers them); improved template guidance on what is bootstrapping vs. permanent; added fix-in-place convention and global-settings hook note.

- `template/conventions/code-style.md`: added fix-in-place vs. log-as-tech-debt distinction to Scope discipline section
- `template/AGENTS.md`: updated Scope bullet to match
- `template/CLAUDE.md`: dispatch table note added: trim to project-specific entries if global context covers universal conventions; init block questions now conditional on global context
- `template/README.md`: How-to-adopt rewritten: conventions/ and CLAUDE.roles/ marked as optional bootstrapping artifacts
- `README.md`: file manifest split into required and optional bootstrapping (CLAUDE.roles/, CLAUDE.softeng.md, conventions/, .claude/settings.json); global-settings hook note added
- `CHANGELOG.md`: optional-bootstrapping-files, fix-small-things-immediately, global-settings-note entries logged
- `template/conventions/code-style.md`: TSDoc for exported symbols section added after Comments
- `CHANGELOG.md`: tsdoc-for-exports entry added

## 2026-06-25

Filled in naming conventions and tooling TODOs in CLAUDE.softeng.md; strengthened pushback convention in CLAUDE.md; content promoted from overture/infra/CLAUDE.softeng.md before that file was deleted.

- `template/CLAUDE.md`: pushback interaction parameter sharpened: lead with the objection, not a neutral trade-off list; added "no ego" framing; added `.dev/docs/<service>/` to "When to read what"
- `template/CLAUDE.softeng.md`: filled "Naming conventions" section (psql-db, mongo-db, -vso companion, Helm/TF naming alignment); added CI/deployment and operator table to "Tooling preferences"
- `template/DEVELOPMENT.md`: added `.dev/docs/` to "Working documents" section: per-service subdirectory, root index.md, read before deploying or debugging
- `CHANGELOG.md`: logged direct-opposition, naming-conventions, tooling-ci-registry, and dev-docs-structure entries under Unreleased

## 2026-06-23

Extended property-ordering convention to cover Terraform resource block ordering; added stateful service deployment guide to CLAUDE.softeng.md covering Jenkins CRD access and credential bootstrap direction by operator type.

- `template/conventions/code-style.md`: added TF resource ordering rule to property-ordering section
- `template/CLAUDE.softeng.md`: new "Deploying stateful services" section: Jenkins CRD access (RBAC aggregation check, config-jenkins-instances pattern), credential bootstrap direction (CNPG auto-generates then copy to Vault; MongoDB pre-seed Vault then operator reads), deployment order
- `CHANGELOG.md`: logged tf-resource-ordering and stateful-deploy-guide entries

## 2026-06-22

Added two session-discipline conventions: sessions.md immutability (append-only; prior entries are historical record) and staleness pass at session start (mark done items done, close resolved PINNEDs, remove addressed tech-debt).

- `template/conventions/session-discipline.md`: added staleness pass paragraph to "Keeping .dev/ current"; added sessions.md append-only rule after entry format guidance
- `CHANGELOG.md`: added two unreleased entries (sessions-immutability, dev-docs-staleness-pass)

---

Format per entry: **date**: **Done** / **Decisions** / **Open threads**

---

**2026-06-19**
- **Done:** propagated global convention additions (structured logging, property ordering, Canadian English) into template AGENTS.md and conventions/code-style.md; applied lean project AGENTS.md pattern to Arranger: removed duplicated sections (Keeping .dev/, Workflow, BDD example, Language and typos, Instruction file governance), replaced with 1-2 line summaries and pointers to agentics template; result: Arranger AGENTS.md reduced from 121 to ~90 lines with no Arranger-specific content lost; added CLAUDE.roles/ with dev.md, general.md, bio.md, ai-eng.md; updated init blocks in CLAUDE.md and AGENTS.md with role question (step 2) and propagation opt-in question (step 5); added propagation opt-in behavior to convention-levels.md; added CONTRIBUTING.md with role creation guide and general-as-foundation pattern
- **Decisions:** `sed`/bulk-replacement rule stays in global CLAUDE.md only (Claude-specific tool behaviour, not a project convention); lean project AGENTS.md pattern = project-specific content inline + universal conventions as pointers; template AGENTS.md stays comprehensive (standalone reference for teams without agentics access); `general.md` is the foundation for all non-developer specialist profiles (admin, ops, clinical, etc.); propagation opt-in is a fifth init question recorded in memory, described in convention-levels.md (not a separate file); CONTRIBUTING.md covers template governance and role creation
- **Done (follow-up):** README rewritten as install wizard (bootstrap prompt up front, init question list, file manifest); Arranger CLAUDE.md "Keeping .dev/ current" section compressed from 9 lines to 2; added session-start signal detection and context refresh to session-discipline.md, template/AGENTS.md, and global ~/.claude/CLAUDE.md; added agentics_contributor flag: set in project memory to enable always-on propagation with agentics as explicit candidate; documented in CONTRIBUTING.md, convention-levels.md, and root CLAUDE.md/AGENTS.md init blocks; Andy's profile added to global ~/.claude/CLAUDE.md and agentics project memory (role + softeng skip, propagation always on)
- **Open threads:** softeng org layer (CLAUDE.softeng.md) still a placeholder: Phase 2

---

**2026-06-05**
- **Done:** improved and stored OWASP Top 10:2025 security guidelines (items 1-7 from team review, 8-10 from OWASP directly) as `~/.claude/security-guidelines.md` and `template/conventions/security-guidelines.md`; added `template/global-context/` (renamed from `personal-context/` for agent-neutrality) with README, projects.md template, and security-guidelines.md template; rewrote all template files (CLAUDE.md, AGENTS.md, conventions/, README) to remove all agent-specific path references: template is now fully agent-neutral; applied security-guidelines reference to Arranger AGENTS.md; updated global CLAUDE.md OWASP section to dispatch to security-guidelines.md
- **Decisions:** security guidelines live in `conventions/security-guidelines.md` (project-local, any agent) and optionally in the agent's global context directory (location varies by agent); `~/.claude/` references belong only in the user's own Claude-specific files, never in the agentics template; `global-context/` replaces `personal-context/`: term is agent-neutral
- **Open threads:** remaining OWASP items 8-10 to validate against team review once completed (logged as tech-debt); softeng-specific tooling documented in roadmap Phase 2 softeng layer item

---

**2026-06-03**
- **Done (follow-up):** identified root cause of cross-project sync pain: behavioral conventions at wrong level (template/project instead of global); added session discipline, instruction governance, search-before-writing to global CLAUDE.md; added convention-levels.md to template (three-level model + propagation question); wired into CLAUDE.md dispatch and AGENTS.md inline; global CLAUDE.md now covers all universal behavioral conventions: no per-project sync needed for those; added personal-context/projects.md template for cross-project awareness; wired project map into initialization block and propagation flow; updated user's projects.md (stale agentics entry)

---

- **Done:** reviewed freelens/AGENTS.md for reusable patterns; added `template/.claude/settings.json` PreToolUse hook (blocks .env, *.pem, *.key, SSH keys, cloud credentials at tool level); added "Searching before writing" to conventions/code-style.md; personal context portability added as Phase 3 with design sketch; reviewed Arranger CLAUDE.md/AGENTS.md: extracted instruction governance, session discipline, tech-debt format as template additions; created conventions/session-discipline.md; added instruction-governance constraint to template CLAUDE.md; redesigned AGENTS.md as comprehensive inline reference (no longer parity copy of CLAUDE.md); applied instruction governance to Arranger CLAUDE.md; added design questions 4 (integrity check) and 5 (context sync ownership model) to roadmap
- **Decisions:** AGENTS.md is now the comprehensive reference for non-Claude agents; CLAUDE.md remains lean and dispatches to conventions/; parity-copy approach retired; "trunk/biome" validation commands deferred: too tooling-specific; version bumps deferred until prior version is committed to remote (use CHANGELOG only while in-progress)
- **Open threads:** Phase 3 design (private context repo, bootstrap prompt, sync discipline); startup integrity check (design question 4); context sync ownership model (design question 5)

---

**2026-06-02**
- **Done:** initial repo scaffold: CLAUDE.md (dispatch), AGENTS.md, CHANGELOG.md, README.md, template/ (CLAUDE.md, AGENTS.md, CLAUDE.softeng.md, conventions/, DEVELOPMENT.md, README.md), .dev/; added merge-with-existing guidance to template/README.md and initialization block
- **Decisions:** dispatch-file pattern (CLAUDE.md ~30 lines; conventions loaded on demand); "first read" softeng team question anchored to project memory initialization; CLAUDE.softeng.md ships as placeholder (renamed from CLAUDE.oicr.md: team name is "softeng" internally); initialization block asks two questions (softeng membership + existing conventions); softeng conventions are supplementary when user has pre-existing setup; CHANGELOG.md structured from day one for Phase 2 update propagation
- **Done (follow-up):** renamed CLAUDE.oicr.md → CLAUDE.softeng.md and swept all agent-facing "OICR" references to "softeng"; expanded initialization block to also ask about pre-existing agent conventions (softeng applies as supplement on conflicts); added merge-don't-replace guidance to template/README.md; added design-question items to roadmap (existing setup integration, non-softeng users, dev vs. non-dev distinction); fixed stale CLAUDE.oicr.md reference in roadmap
- **Open threads:** softeng layer content (Phase 2); update propagation design (Phase 2); existing setup integration design; non-softeng user framing; dev vs. non-dev convention paths
