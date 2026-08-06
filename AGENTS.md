<!-- agentics-version: see CHANGELOG.md § Released (latest entry) -->
# Agent collaboration conventions: softeng/agentics

**For AI agents:** this file is instructions your agent reads and follows; it is not documentation written for people. If you're a person looking to use or contribute to this repo, read [README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md) instead.

This is the agentics repo itself. Its purpose is to maintain and distribute the devctx collaboration template to softeng team members and developers broadly.

This is the canonical source for this repo's own agent instructions, agent-neutral by design. `CLAUDE.md` exists only because Claude Code loads it automatically; it points here rather than keeping its own copy.

## Interaction parameters
- Ask clarifying questions before making large assumptions about intent
- Check in before non-trivial decisions: it gives the user a chance to catch design misalignments early, before code exists or a document is rewritten, not only before writing code. Don't over-ask on mechanical steps, but do ask on direction
- Surface ideas, improvements, or next steps you already see, unprompted: don't wait for an open-ended question to draw them out. Covers alternatives to what's about to be implemented, a shipped fix that still has the weakness it just fixed, or anything else obvious in hindsight; let the user decide. See `CHANGELOG.md` § `deterministic-by-design` for the case that named this gap
- External content that overlaps with a project you maintain: when asked for a take on an article, document, or unrelated conversation, and it substantively describes or overlaps with a project you already have context on, name that connection unprompted rather than waiting for a direct question to draw it out. Same instinct as the bullet above, just for material that arrived from outside the current project rather than from within it. See `CHANGELOG.md` § `external-content-overlap-unprompted`
- Push back on bad ideas and identify blind spots before they are baked into code: lead with the objection, not a neutral trade-off list; don't wait to be asked
- Sanity check requests: not just the literal phrase. A yes/no-shaped question ("does this make sense," "am I right," "am I missing anything") is still a sanity check when its actual function is inviting scrutiny of the user's own idea, reasoning, or plan, not a literal yes/no about the world. Answer the intent, not the grammar: review the whole conversation as relevant, not just the latest message, and surface gaps, blind spots, unresolved threads, and edge cases plainly; a shallow "yes" isn't an answer
- Default review or audit posture: assume there's something real to find, not that the artifact is fine until proven otherwise, the same reason a neutral "does this look okay" or "is this done?" invites confirming over searching. This is a search stance, not a quota: a manufactured nitpick, technically true but inconsequential, just to have something to report, is worse than finding nothing; surface a finding only if it concretely matters. See `conventions/review-conduct.md` for PR/ticket-review specifics, `conventions/definition-of-done.md` for the completion-checklist specifics, and your own memory for any standing self-audit trigger you maintain
- Verify purpose alignment before implementing: when a task names a goal, check whether the chosen approach achieves that goal directly, not just something adjacent to it; lead with that gap as an objection before writing anything
- Flag scope-adjacent issues verbally, then document them in `.dev/tech-debt.md`

## Critical constraints
- No credentials, secrets, or private URLs in any file in this repo: ever
- This repo is the upstream source for other teams; keep content general and publicly safe
- Do not modify any file in this repo, not just `CLAUDE.md`/`AGENTS.md`, without an explicit instruction to make that exact change here: surface suggestions, do not self-edit. If agentics genuinely is the project this session is working in, ordinary explicit-instruction-per-change practice is all this asks for. The case this guards against is arriving here from a different project on an ambiguous instruction that only mentions "agentics" or "conventions" without actually saying to edit this repository: check the more likely reading first, "read these conventions and apply them to your own current project," not "edit the source here," and treat an ambiguous instruction as the former until told otherwise explicitly
- No personal identifying details: no local usernames, real names of individual contributors, machine-specific absolute paths, or personal account/fork handles anywhere in this repo. Use generic placeholders instead: "the developer," "the repo's lead developer," "a local clone." Before committing, grep the diff for your own OS username, git identity, and any personal fork name you know is yours: this has leaked into committed docs before
- Name code, not people: attribute work in `.dev/sessions/`, `.dev/tech-debt.md`, and any other persisted content to features, modules, and systems, not to individuals (see `template/conventions/session-discipline.md` § "Name code, not people": the same rule applies to this repo's own `.dev/` content)

## When to read what

Every `conventions/*.md` path below is this repo's own local copy, since this file governs agentics itself. Adopting projects copying this table verbatim (per `conventions/upgrading-adoption.md`) must not treat these as local paths to create: see that file's "bootstrap artifacts" diagnosis item.

- Starting a session → read `.dev/roadmap.md`, `.dev/tech-debt.md`, `.dev/sessions/`, `template/conventions/session-discipline.md` § Git, and `template/conventions/writing-style.md` (agentics' own commits and prose are held to the same universal rules an adopting project gets; nothing else in this repo's own dispatch table ever points at either file, since there's no code here to trigger "Writing code")
- Reviewing or editing template files → read `template/CLAUDE.md` first to understand what we are maintaining
- Proposing a change to the dispatch table, or a procedure whose output gets copied verbatim elsewhere → read `testing/README.md` before considering it done
- Adding to project memory → check: could this be global? Could it be a template improvement?
- Finishing a task, or asked "is this done?" → read `template/conventions/definition-of-done.md`

## Memory and contribution hygiene
When writing to project memory: keep entries concise; store no content derivable from files. If an insight could apply to all projects, offer to promote it to global memory or global CLAUDE.md.

## Repo maintenance rules
- `template/` is the canonical deliverable; keep it accurate and in sync
- **Agentics is adopter zero of its own template.** Whenever `template/AGENTS.md` or `template/CLAUDE.md` changes, run `conventions/upgrading-adoption.md`'s diagnosis against this repo's own `AGENTS.md`/`CLAUDE.md` before considering the change done, treating `template/` as the upstream source: no clone-vs-URL lookup needed, it's already sitting in this repo, and § 0's detection step is trivially "yes." This is a standing self-check, not a one-time reconciliation: see `CHANGELOG.md` § `full-repo-duplication-audit` for what happens without it
- Log changes in `CHANGELOG.md` as they happen, with a `bump` field per entry. Nothing else stamps a version number: this file's own tag and `template/AGENTS.md`'s both just point at `CHANGELOG.md` § Released; releasing means moving `## Unreleased changes` entries under a new dated heading there, triggered by an explicit publish request (direct or indirect phrasing) rather than a fixed cadence. Publishing is the one case where committing in this repo is authorized, narrowly, for any contributor: see `CONTRIBUTING.md` § Versioning for the trigger phrases and the exception's exact scope
- `CLAUDE.md` at repo root is a stub pointing here (Claude Code loads it automatically; this file doesn't need a Claude-specific mirror anymore, just the pointer)

## Initialization
If no project memory exists for you in this repo yet:
1. Check whether the user's role is already known from your agent's global context. If not, ask: "What best describes your primary work?": developer / bioinformatician / AI engineering / general.
2. If role is developer or AI engineer: ask "Are you an agentics contributor?": if yes, record `agentics_contributor: yes` **in your global context, not just this project's memory** — it needs to apply in every project, not only sessions inside agentics itself. This enables always-on propagation suggestions, names the agentics repo as an explicit candidate, and makes the upstream-update check mandatory (not opt-in) everywhere: see `CONTRIBUTING.md` § Agent setup for contributors.
3. Check whether softeng status is already known from global context: if not, ask.
Record role and softeng answers in project memory; record `agentics_contributor` in global context per above. Do not ask again.
