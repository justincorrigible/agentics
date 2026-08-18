# Whole-repo review: 2026-08-17

A full read of every file in the repo (every `template/conventions/*.md`, `template/CLAUDE.*`, `template/global-context/*`, `testing/*`, `docs/*`, `AGENTS.md`/`CLAUDE.md`/`README.md`/`CONTRIBUTING.md`/`CHANGELOG.md`, both root and template, `.dev/roadmap.md`, `.dev/tech-debt.md`), specifically to find what a normal working session wouldn't surface: cross-file drift, orphaned content, and one bigger naming question worth a deliberate decision. Distinct from the batch of live-incident fixes already tracked in today's session file and the standing todo list, this document doesn't repeat those.

Two small, self-contained gaps found here were fixed directly while reviewing (both listed below as "Fixed directly," not queued). Everything else was written up with enough detail to implement without re-deriving the reasoning; all four remaining items (the correction, both additions, and the naming question) were resolved in the same session shortly after this document was first written, each marked "Resolved" below with what actually happened.

## Corrections

### 1. Four files still say "CLAUDE.md" where "AGENTS.md" is canonical

Since the single-dispatch-table refactor (`CHANGELOG.md` § `agents-md-single-dispatch-table`), `AGENTS.md` holds the canonical dispatch table, interaction parameters, critical constraints, and initialization block; `CLAUDE.md` is only a stub pointing at it. Every file that describes how it relates to the base template should say "AGENTS.md," not "CLAUDE.md." Two files got this right; four didn't.

**Correct, for comparison** (`template/CLAUDE.overture.md`):
- "This file is an addendum to `AGENTS.md`/`CLAUDE.md`, applied when project memory confirms this is an Overture project."
- "The initialization block in `AGENTS.md` records Overture-project status in project memory on the first session."

**Wrong, needs the same fix:**
- `template/CLAUDE.softeng.md`, line 3: "This file is an addendum to `CLAUDE.md`, applied when project memory confirms the user is part of the softeng team." → should read "`AGENTS.md`/`CLAUDE.md`", matching `CLAUDE.overture.md` exactly.
- `template/CLAUDE.softeng.md`, line 7: "The initialization block in `CLAUDE.md` records team membership in project memory on the first session." → should read "`AGENTS.md`".
- `template/CLAUDE.roles/dev.md`, line 3: "You are in the default configuration. All base template conventions in `CLAUDE.md` apply as written: this file adds nothing." → should read "`AGENTS.md`".
- `template/CLAUDE.roles/bio.md`, line 3: "Builds on the base template conventions. Read this file in addition to, not instead of, `CLAUDE.md`." → should read "`AGENTS.md`".
- `template/CLAUDE.roles/ai-eng.md`, line 3: identical sentence to `bio.md`, same fix.

`template/CLAUDE.roles/general.md` doesn't make this specific claim (no fix needed there); `CONTRIBUTING.md` § "Creating a new role file" already confirms `AGENTS.md`'s initialization block is "the only copy," which is what makes this a clear-cut fix, not a judgment call.

**Why this wasn't caught mechanically:** `testing/scripts/check-consistency.sh`'s orphan/drift checks are scoped to `template/conventions/*.md` and the root/template `AGENTS.md` pair specifically; nothing in the script reads `CLAUDE.roles/*.md`, `CLAUDE.softeng.md`, or `CLAUDE.overture.md` at all. Worth a fifth check in that script at some point (grep those four files for a bare `CLAUDE.md` reference not paired with `AGENTS.md`), but that's a separate, smaller follow-up, not required to fix the five sentences above.

**Resolved 2026-08-17:** all five sentences fixed directly. (This is now moot as a live gap anyway, since the same session's naming decision below renamed these files entirely; the fix was applied before that rename, and the rename carried the corrected wording forward.)

## Additions (gaps, not yet fixed)

### 2. `docs/agent-security.md` is dispatched for its narrowest sub-case only

The file itself is a substantial, well-sourced security document: seven attack vectors (config/hook injection, indirect prompt injection via documents and tool output, PR/CI comment injection, MCP server poisoning, npm/pip supply-chain attacks, self-replicating worm patterns, agent memory poisoning), a session-start integrity check, and an honest "what agents cannot catch automatically" section.

Checked directly (not assumed): the only place anything in the repo actually tells an agent to read it is `template/conventions/session-discipline.md`'s session-start integrity check, and only for one narrow branch: "If `settings.json` changed unexpectedly, read it immediately... (see `docs/agent-security.md`)." Nothing dispatches to it for the rest of its content: indirect prompt injection, PR/CI injection, MCP poisoning, supply-chain risk, or memory poisoning have no trigger anywhere. `AGENTS.md`'s existing "Security-relevant work" dispatch line (in both root and template) currently points only at `conventions/security.md` and `conventions/security-guidelines.md`.

**Recommended fix:** add `docs/agent-security.md` to that same "Security-relevant work" dispatch line, in both root and template `AGENTS.md`:
```
- Security-relevant work → read `conventions/security.md` (...), then `conventions/security-guidelines.md` (...), and `docs/agent-security.md` (agent-specific threat model: prompt injection, supply-chain, MCP poisoning)
```
Leave the existing `session-discipline.md` reference in place too; it's a different, narrower trigger (settings.json changed) worth keeping alongside the broader one, not replacing it.

**Secondary, structural note, not required to fix the above:** `check-consistency.sh`'s orphaned-file check (see `testing/consistency-checks.md` item 2) is scoped to `template/conventions/*.md` only. It wouldn't catch this class of gap at all, since `docs/agent-security.md` lives under root `docs/`, a directory the script never scans. Worth considering whether the script's scope should extend to root `docs/*.md` too, but that's a separate decision from adding the one dispatch line above (still open, not resolved by the fix below).

**Resolved 2026-08-17:** added to `template/AGENTS.md`'s "Security-relevant work" line only. Root `AGENTS.md` was checked first and turned out to have no "Security-relevant work" dispatch line at all (agentics itself has no application code to trigger it), so the original "in both root and template" framing above was imprecise; only template needed the fix.

### 3. Credential-blocklist hook is missing patterns this team's own stack needs

`template/.claude/settings.json`'s `PreToolUse` hook blocks file access matching: `.env`/`.env.*`, `.npmrc`, `.keystore`/`.jks`/`.p12`/`.pfx`/`.pem`/`.key`, SSH private keys (`id_rsa`, `id_ed25519`, `id_ecdsa`, `id_dsa`), `.aws/credentials`, `credentials.json`, `serviceAccountKey.json`. Good coverage for generic cloud/SSH credentials, but checked against `CLAUDE.softeng.md`'s own documented stack (Kubernetes via operators, Terraform with `stateless`/`stateful` roots, VSO, Jenkins, `ghcr.io`), several stack-specific gaps stand out:

- **`.kube/config` / `kubeconfig`**: a Kubernetes credentials file, not covered by any existing pattern. Directly relevant given this team's operator-heavy K8s usage.
- **`*.tfstate` / `*.tfstate.backup`**: Terraform state files routinely contain plaintext secrets (DB passwords, API keys pulled from a provider) even when the corresponding `.tfvars` is clean, since Terraform serializes full resource attributes into state regardless of how they were provided. Not covered at all currently.
- **`.docker/config.json`**: container registry credentials, relevant given `ghcr.io` usage documented in `CLAUDE.softeng.md`.
- **`.netrc`** and **`.pgpass`**: not stack-specific, but common, well-known credential file conventions missing from the current list regardless of team.

**Recommended fix:** add regex patterns for these to the Python pattern list in `template/.claude/settings.json`, following the exact same structure as the existing entries (a `re.search` pattern per line). No structural change needed, just more entries in the existing `patterns` list.

**Resolved 2026-08-17:** all seven patterns added programmatically (via a small Python script re-serializing the JSON, after a hand-edited attempt broke the file's JSON validity on the first try) and functionally tested against sample paths for all seven new patterns plus one pre-existing pattern and one clean file, confirming deny/allow behaves as intended, not just added on faith.

## A naming question worth a deliberate decision, not an unprompted rename

`template/CLAUDE.roles/*.md`, `template/CLAUDE.softeng.md`, and `template/CLAUDE.overture.md` all carry a `CLAUDE.` prefix. Root and template `CLAUDE.md` genuinely earn that name: Claude Code auto-loads that specific filename, which is the entire reason the stub exists (`CLAUDE.md`'s own opening line says so explicitly). None of the addendum files share that property. They're reached exclusively through `AGENTS.md`'s own dispatch table and initialization block, the identical mechanism for any agent, Claude or otherwise. Nothing about Claude Code specifically looks for a file named `CLAUDE.softeng.md` or `CLAUDE.roles/dev.md`.

This directly cuts against `CONTRIBUTING.md`'s own stated design principle, "Agent-neutral: template files must not reference Claude-specific paths." A new adopter using a different tool (Cursor, Codex, Copilot), told to bootstrap `CLAUDE.softeng.md`, has a reasonable, wrong impression that this file is somehow Claude-specific or optional for them, when it's exactly as load-bearing for them as for a Claude user.

**Not recommending an immediate rename.** This touches: `AGENTS.md`'s dispatch table (both root and template), the initialization block's file references, `template/README.md`'s file table, `CONTRIBUTING.md`'s "Creating a new role file" instructions, and any already-adopted project that copied these exact filenames (a `breaking: yes` change, by this repo's own CHANGELOG convention). That's real, coordinated work, not a drive-by fix, and it's the kind of decision `AGENTS.md`'s own "Check in before non-trivial decisions" principle exists for.

**What a future implementer needs to decide, not re-derive:**
- Rename to something agent-neutral (`AGENTS.roles/`, `AGENTS.softeng.md`, `AGENTS.overture.md`), matching the file that actually dispatches to them, or
- Keep the current names but state explicitly, once, that the `CLAUDE.` prefix here is a legacy naming artifact with no special meaning to Claude specifically (a documentation-only fix, no rename, lower cost, doesn't fully resolve the misleading-to-a-new-adopter problem), or
- Leave as-is and accept the risk, if the naming has already propagated widely enough that a rename's cost outweighs the confusion it causes.

No lean stated here on purpose: this is a real tradeoff (rename cost and breaking-change scope vs. ongoing agent-neutrality friction), not a correctness question with one right answer, and the person or model implementing this later should read the current adopter count and rename cost fresh, not inherit a stale recommendation from this pass.

**Resolved 2026-08-17, by direct instruction:** renamed to the first option above. `template/CLAUDE.roles/` → `template/AGENTS.roles/`, `template/CLAUDE.softeng.md` → `template/AGENTS.softeng.md`, `template/CLAUDE.overture.md` → `template/AGENTS.overture.md`. Root and template `CLAUDE.md` were left untouched, they still genuinely earn the name. Every reference across the repo was found by grep and updated: `AGENTS.md`'s dispatch table and initialization block (root and template), `template/README.md`, root `README.md`, `CONTRIBUTING.md` (six references, including the "Creating a new role file" section), `template/conventions/upgrading-adoption.md`, `template/conventions/convention-levels.md`, `template/global-context/README.md`, the two role files' own self-references, and `testing/regression-checklist.md`/`testing/fixtures.md`'s scenario descriptions (updated to the new names, with a parenthetical noting the old name for historical incidents that happened under it). Historical, already-released `CHANGELOG.md` entries and old `.dev/sessions/` logs were deliberately left referencing the old names, they're a record of what was true at the time, not live content. `breaking: yes`, since any already-adopted project that copied these exact filenames needs a manual update, logged as such in `CHANGELOG.md`.

## Confirmed correct, no action needed

Checked directly against `https://owasp.org/www-project-top-ten/` (2026-08-17): the 2025 edition is still current. `security-guidelines.md` and `security.md`'s framing ("keyed to the 2025 edition... confirm still current before relying on it") is accurate as of this pass; no update needed right now. Recorded here so this specific check doesn't get redone unnecessarily soon, not as a standing exemption from the file's own "verify at time of use" rule.

## Fixed directly during this review (not queued)

- `template/global-context/README.md`'s own "Files" list never got `agent-index.md` added when that convention shipped earlier tonight, an orphaning gap in agentics' own newest addition, caught applying the same scrutiny to this session's own recent work. Added.
