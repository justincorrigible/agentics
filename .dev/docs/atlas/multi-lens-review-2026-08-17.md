# Multi-lens review: 2026-08-17

A second review pass on the same day as `whole-repo-review-2026-08-17.md`, run with a different method and finding a materially different, larger set of problems. That difference is itself the first finding, recorded in § Method, below.

Six independent lenses were run concurrently over the repo, each told to read whole files rather than excerpts, to ground every claim in a quote plus `path:line`, and to explicitly not re-report anything the morning pass already resolved: internal coherence and contradiction; a literal cold-read of the adoption flow; enforceability and failure modes; coverage gaps; scale and structural sustainability; security and trust boundaries. Findings below were re-verified directly before being written down, not accepted on a lens's report; where verification changed or sharpened a claim, the verified version is what appears here.

Severity language: **defect** means the current behaviour is wrong and the fix is not a judgement call. **Design question** means a real problem with more than one defensible answer, needing a decision rather than an implementation.

## Method: why a second pass on the same day found more than the first

The morning pass read every file in the repo start to end, deliberately and not incident-driven, and found four items. This pass found substantially more, in the same files, hours later, with nothing having changed in between except the method.

The difference is that a single linear read optimizes for "is each file correct on its own terms," which is the question a reader naturally asks while reading. It does not ask "does this file contradict that one," "would this instruction execute," "what fires this rule," or "what does this let an attacker do," because holding several such questions at once across a whole repo is not what sequential reading does. Each of those is a different search, and each surfaces a class the others structurally cannot.

Two concrete illustrations from this pass. The credential-hook defect (§ 1) was invisible to a reading pass because the file reads correctly: the regex list is right, the structure is right, and only executing it against a real payload reveals that it never runs. And the morning pass explicitly checked `CONTRIBUTING.md` for stale `CLAUDE.md` references, cleared it, and moved on; two stale references survived in sections it did not happen to be looking at, because it had already satisfied the question for that file.

`review-conduct.md` currently covers review *stance* (skeptical rather than confirming), disposition per finding, ground truth over claims, and the structural-pattern sweep added earlier today. It says nothing about review *depth or method*, so nothing distinguishes "I read it all" from "I searched it several ways." That gap is what this section exists to close, and it belongs in that file as a convention, not only here as an observation.

## Part 1: Defects

### 1. The credential blocklist has never fired, in the template or in any adopting installation

`template/.claude/settings.json`'s `PreToolUse` hook extracts the target path as:

```
path = params.get('filePath', params.get('path', ''))
```

Claude Code's `Read`, `Edit`, and `Write` tools all pass `file_path` (snake case); `NotebookEdit` passes `notebook_path`. Neither key the hook looks for is ever present, so `path` is always the empty string, no pattern in the list can match, and the hook returns `allow` for every file it is meant to block. Verified by executing the shipped hook command against real payload shapes:

| payload | decision |
|---|---|
| `file_path` on `.env` | allow |
| `file_path` on `.ssh/id_rsa` | allow |
| `file_path` on `terraform.tfstate` | allow |
| `filePath` on `.env` (the key it reads) | deny |
| `command: cat .env` (Bash) | allow |
| `file_path` on `README.md` (control) | allow |

This is not confined to the template. The same defect is present in the live global installation this repo's own maintainer runs, so the blocklist has been inert in every project, not just in newly adopted ones.

Three properties make this worse than an ordinary bug. It is the only fully mechanical security control the template ships, so its failure removes the entire enforcement tier rather than one check. Its failure mode is silent and indistinguishable from correct operation: a hook returning `allow` produces no log line, no error, and no observable difference from having no hook installed. And `docs/agent-security.md` tells the developer that a correctly configured installation "should contain exactly one hook: the `PreToolUse` credential file blocklist," which converts the absence of evidence into positive reassurance.

The relevant lesson is in how it survived. The morning pass added seven new patterns to this same file, tested them, and reported them "functionally tested against sample paths." That test fed paths to the pattern list directly and confirmed the regexes were correct. They were correct. The test exercised the half that already worked and never touched the payload contract, so it passed against a hook that could not fire. A test that constructs its own input in the shape the code expects cannot discover that the real caller uses a different shape.

**Fix:** read `file_path` first, then `filePath`, `notebook_path`, and `path` as fallbacks; additionally scan `params.get('command', '')` so a Bash `cat`, `less`, or `cp` of a blocked path is also denied. Then add a check to `testing/scripts/check-consistency.sh` that pipes canonical payloads through the hook command extracted from the JSON and asserts deny, deny, allow, so the payload contract is gated rather than assumed. Even fixed, `Grep` and `Glob` still pass a directory rather than a file and remain outside its reach; that limitation should be stated rather than left to be discovered.

### 2. An adopting project's dispatch table points at paths that cannot resolve

`template/AGENTS.md` states that "Every path below is a live pointer into agentics or your own global context, never a local copy to create in this project," and then writes those pointers as bare relative paths: `conventions/session-discipline.md`. Agentics' own root `AGENTS.md` writes the same pointers correctly as `template/conventions/session-discipline.md`, because from the repo root that is where the files are. The prefix is dropped precisely in the copy that leaves the repo.

For an adopting project there is no local `conventions/` directory, correctly, since the convention forbids creating one. So the path resolves to nothing locally, and nothing in the adoption flow records where agentics itself lives, so there is no base to resolve it against either. The best available inference also fails: the only agentics location an adopter has is the "Adapted from" GitHub URL in `template/AGENTS.md`, which points at the repository root, and resolving `conventions/session-discipline.md` against it produces a 404, because the real file needs a `template/` path segment that is invisible from the adopting project's side.

`convention-levels.md` § How much to keep locally, which the table cites for the full rule, governs *whether* a file should be copied. It never states what a bare path resolves against. Its "Local clone or remote URL, same rule either way" paragraph addresses where content is fetched from, not how the path is constructed.

The history matters here. `CHANGELOG.md` § `global-guideline-material-never-in-project` diagnosed this exact ambiguity, "the dispatch table's bare relative paths were ambiguous once copied verbatim," and fixed the symptom by forbidding local copies. Forbidding the copy without making the path resolvable leaves the reference dangling rather than wrong, which is a quieter failure, not a fixed one.

**Fix:** make the paths resolvable in the copied artifact, either by stating the base explicitly once at the top of the table or by writing each pointer against a recorded agentics location, and add "record agentics' path or URL in your global context" as an adoption step so a base exists to resolve against.

### 3. Root `AGENTS.md` cites paths that do not exist, in the sentence claiming they do

There is no `conventions/` directory at the repo root; the files are at `template/conventions/`. Root `AGENTS.md` uses the correct `template/conventions/...` form in its dispatch rows, but uses bare `conventions/...` in two prose references, and its table preamble asserts: "Every `conventions/*.md` path below is this repo's own local copy, since this file governs agentics itself." That sentence is inaccurate twice over, since no root-level copies exist and no path below is written in the bare form it describes.

Related, in the same file: the dispatch row for the repo's single most common activity, "Reviewing or editing template files," sends the agent to `template/CLAUDE.md` "first to understand what we are maintaining." That file is a seven-line stub whose entire body says it is not the canonical source and to read `AGENTS.md` instead. The row was correct before the single-dispatch-table refactor moved the content, and was not updated when it did.

### 4. `security.md` files supply chain under the wrong OWASP category, in the file read first

`security.md` heads its pnpm section "Node.js / pnpm: supply chain (A08)" and calls it "a deliberate A08 control." The canonical map in the same repo, `security-guidelines.md`, assigns A03 to Software Supply Chain Failures and A08 to Software and Data Integrity Failures. A08 covered supply chain in the 2021 edition; the 2025 edition, which this repo has verified as current, moved it to A03.

The dispatch order makes it worse rather than self-correcting: `template/AGENTS.md` sends security work to `security.md` first and `security-guidelines.md` second, so an agent reads the wrong category before reaching the file that would correct it, and will carry "A08" into review comments, threat models, and tech-debt entries.

### 5. Private global configuration has leaked into the shipped template, twice, through an unguarded direction of propagation

Two shipped convention files carry content that belongs to the maintainer's own private global configuration rather than to the universal tier:

- `session-discipline.md` cites a section named "Bulk text replacements" as the authority for a `grep -c` backstop. That section does not exist anywhere in this repo. It exists only in the maintainer's personal global instructions file. The repo's own history records how: a session log from 2026-07-30 documents promoting that insight *into* the private global file. An adopter cannot resolve the reference at all, and the content it wants does exist in the template already, in `writing-style.md`.
- `writing-style.md` carries a Terraform rule that alphabetizes named resource blocks and states that "VSO companion blocks follow their primary resource," naming three live softeng resource names. That file's own opening declares "Everyone reads this file," and VSO is defined only in `AGENTS.softeng.md`, behind a confirmed-team-membership gate. This text is verbatim a local refinement from the same private global file.

These are one defect, not two. Agentics has a well-developed discipline for propagation *outward*, from a project up to the template, in `CONTRIBUTING.md` and `convention-levels.md`'s three-tier placement model. Nothing checks the *inward* direction, from a maintainer's private global configuration into the shared template. That direction carries a specific risk the outward direction does not: personal and org-tier content arrives already phrased as a general rule, having been written for an audience of one who shares all the missing context, so it reads as universal on arrival and passes the placement question without ever being asked.

### 6. `CONTRIBUTING.md` describes an architecture that no longer exists

Its lead design principle reads "Dispatch over inline: `CLAUDE.md` stays lean (~30 lines); convention detail lives in separate files loaded on demand." Root `CLAUDE.md` is seven lines and holds no dispatch table at all; two bullets later the same file correctly states that `CLAUDE.md` "holds nothing but a pointer to `AGENTS.md`." Separately, it tells contributors their agent will ask the initialization questions from the "initialization block in `CLAUDE.md`"; that block is in `AGENTS.md`. Root `README.md` carries the same stale framing in two places.

Low blast radius on its own, but these are the first paragraphs a new contributor reads, and they name the wrong file as the centre of the architecture. Notably, the morning pass checked `CONTRIBUTING.md` for exactly this class of staleness and cleared it, on the strength of a different section that happened to be correct.

### 7. `convention-levels.md`, the canonical placement authority, still describes the pre-refactor model

It states that project-specific conventions live "in the project's `CLAUDE.md` or `.dev/`," that "a dispatch line in `CLAUDE.md` is enough," and that `AGENTS.md` "dispatches to `conventions/*.md` the same way `CLAUDE.md` does." All three contradict the current model as stated in `CONTRIBUTING.md`, `template/CLAUDE.md`, and `template/README.md`.

This one is worse than § 6 because the file is authoritative and actively dispatched: `upgrading-adoption.md` defers to it by name during an upgrade. An agent following it writes project content into `CLAUDE.md`, which `upgrading-adoption.md` then flags as a defect to repair. Two conventions collide inside a single procedure.

### 8. Smaller confirmed defects

- **Stray `sed` artifacts.** Three cells in `CONTRIBUTING.md`'s role table read `|: |`. The repo's own mandated em-dash cleanup fired on table cells where the dash meant "not applicable" rather than prose. `writing-style.md` exempts table separator rows but not empty-cell placeholders, so the rule has a known failure mode worth stating.
- **`AGENTS.overture.md` is missing from the never-copy exemption list** in `upgrading-adoption.md`, which names the other three. An upgrade diagnosis on an Overture project would therefore see it as a legitimate gap to create, which is the exact class of write the exemption exists to prevent, on the one file the list forgot.
- **A CHANGELOG slug is cited as living in `CONTRIBUTING.md`** in `session-discipline.md`; the slug is in `CHANGELOG.md`, and the repo's own citation format is `see CHANGELOG.md § <slug>`.
- **`security-guidelines.md` declares its two copies "expected to be identical"** while they already differ in two places, one of which is the paragraph making the claim. The bootstrap copy is the weaker one: it loses a pointer that another file depends on to trigger a check.
- **`testing.md`'s restatement of the full-suite rule is narrower than the canonical version** in `session-discipline.md`, dropping the clause covering two of the three checkpoints. An agent dispatched to `testing.md` alone concludes the full suite is a semiregular-checkpoint obligation only.
- **Two deferred sub-items from the morning pass were never carried anywhere trackable.** Both proposed extensions to `check-consistency.sh` live only inside a document whose four headline items are all marked Resolved, so they are effectively lost.
- **`CHANGELOG.md` has two incompatible entry formats.** 215 of 225 entries use the canonical five-field form; the ten oldest use a four-field form predating the `bump` field. Nothing documents this, so anything parsing the changelog mechanically breaks on the tail.

## Part 2: Enforcement gaps

`docs/deterministic-by-design.md` claims the mechanically-enforceable bucket is "fully converted" in this repo. Four of that bucket's rules are unconverted, converted more narrowly than the rule they enforce, converted with a timing flaw, or converted into noise. That sentence is the highest-value single correction available here, because it is the claim that stops anyone from looking.

- **The dashes check is narrower than the dashes rule.** The rule bans four things: em dashes, en dashes, double hyphens as a dash substitute, and space-hyphen-space as a sentence connector. The mandated check, `grep -c '—\|–'`, tests two. Live violations of the untested half exist in shipped convention files, including in the file about making rules mechanically enforceable. Nothing in `check-consistency.sh` checks dashes at all, despite the CHANGELOG identifying this as the repo's most-recurring failure.
- **The AI-attribution check cannot see the commit it gates.** It runs from a pre-commit hook and greps `git log`, so the commit message being written does not exist yet. The rule it enforces is explicitly one that agents violate by default, making this the high-frequency case rather than the edge case. It belongs in `commit-msg`, which receives the pending message. Two of its three patterns are also vendor-specific, in a rule stated as applying "regardless of which agent is doing the work," and nothing anywhere inspects a PR body, which the rule also covers.
- **The agent-neutrality check is pure noise.** It prints eighteen lines on every run, all pre-existing and all correctly framed, and never fails. It runs from a blocking pre-commit hook, so contributors see an eighteen-line wall on every commit under the heading "All checks passed." The nineteenth line, a genuinely new unframed hit, is the one that matters and the one that gets scrolled past. This is alarm fatigue as a design property.
- **Plan-first and tests-first have no trigger that can fire before implementation.** `testing.md` says planning and tests precede implementation, but its only dispatch trigger is "Writing or reviewing tests," and `code-style.md`, dispatched by "Writing code," never points at it. An agent complying perfectly with the dispatch table writes the implementation, then reads the file saying tests come first. The loss is invisible afterward: the tests exist, they pass, and nothing downstream distinguishes test-first from test-after.
- **`agent-index.md` cites a registration trigger that does not exist**, claiming registration folds into `upgrading-adoption.md`'s numbered flow; that file contains no such step. Its own session-start rules are unreachable by construction, since its only dispatch trigger is "Reaching another session directly," so the file is opened only when already doing the thing its session-start rules were meant to have prepared for.
- **Team placeholders sit in files adopters are forbidden to copy or edit.** `writing-style.md` and `session-discipline.md` each carry a "[Team placeholder: ...]" that an adopter is told never to copy locally and cannot edit upstream. No initialization question asks for the value. The spelling convention in particular is therefore permanently inert for every adopter, and unfalsifiable in the strict sense: it never states a rule, so no observation can show it was violated.
- **Push-target and staging rules have no backstop** although they are the same class of default-conflict as the AI-attribution rule that did get one. A `pre-push` hook can enforce the branch target while preserving the narrow release exception; the staging-consent half genuinely cannot be mechanized, and the asymmetry should be stated rather than left implicit.
- **"Draft, never post" has zero mechanical enforcement** despite being the highest-stakes default conflict in the repo: a posted PR comment is externally visible and effectively irreversible, and the repo's own history records it failing twice into real systems. A `PreToolUse` matcher on `gh pr comment`, `gh pr review`, and similar would force the draft path structurally.
- **"Security-relevant work" is a self-classifying trigger.** Nothing defines it, so the agent that most needs the security guidance is the one that did not recognize its work as security-relevant. `code-style.md` already solves this exact problem concretely for structured logging by naming the surfaces (auth, access control, data export, boundary errors); the same treatment applies here.

## Part 3: Trust boundaries

### The peer-message channel has an identity model and no authority model

`agent-index.md`, shipped yesterday, is thoughtfully built and its identity discipline is genuinely strong: validate plausibility, share no substance until confirmed, never put a payload on the bulletin board. All of that answers "is this who I think it is."

It does not answer "what does a verified peer's message entitle me to do." The file contains no occurrence of consent, approval, authorization, trust, untrusted, or injection, and no cross-reference to `AGENTS.md`, `review-conduct.md`, or `agent-security.md`. The nearest relevant rule lives in `template/AGENTS.md` and is scoped to a peer's *proposals* with a hard-to-reverse footprint. It does not cover a peer asserting a *fact*: that the developer already approved something, that a check already ran, that a review already passed. `review-conduct.md` § Ground truth over claims would cover exactly that, and is never dispatched from the agent-index path.

The failure this leaves open is not identity spoofing, which the design handles. It is a correctly identified peer whose content is hostile or simply wrong, which the design does not address at all. `interagent-communication-findings.md` already records the benign version happening: a peer's own description of what happened treated as ground truth when it was a claim.

### The exception granting PR comments instruction authority points at a documented attack

`review-conduct.md` says that a PR comment, review, or issue authored under the developer's recognized identity is treated "with the same authority as an instruction given directly in the current conversation." `docs/agent-security.md` documents that same channel, "specially crafted content in GitHub PR titles, issue bodies, or comments hijacks coding agents," as demonstrated against Claude Code and others in 2026.

Neither file references the other, and the PR-review dispatch row does not include `agent-security.md`, so the caution is never in context when the exception is applied. The distinction that makes the exception safe is available but unstated: the platform's structured author field on a directly fetched comment is not attacker-controlled, while attribution appearing *inside* a PR or issue body is.

### Everything always-loaded sits outside every integrity check

The session-start integrity check covers three project-local files. The global-context directory, loaded into every project, is covered by nothing: it is not version controlled, not diffable, and now includes `agent-index.md`, which the convention explicitly declares machine-written and "not a file a developer is expected to browse or maintain by hand." That combination, always loaded, cross-project, machine-writable, and exempt from human review by design, is the highest-amplification write target available, and a modification to it produces no signal anywhere.

The same amplification applies to the agentics clone itself. The freshness procedure verifies which remote a clone points at and how far behind it is, but never whether its working tree is dirty. An uncommitted edit to a convention file in the local clone is read as authoritative by every project on the machine that points at it, at the next matching trigger, and passes every check the procedure runs.

### Non-Claude adopters have no mechanical credential enforcement, and the docs imply otherwise

The Claude-specificity of the hook is acknowledged as a setup footnote. The security consequence is not stated anywhere, and `convention-levels.md` lists "the credential file hook" as a shareable structural pattern with no agent caveat, while `agent-security.md` asserts its presence as a baseline. For a Cursor, Copilot, Aider, or Codex adopter the entire credentials policy is prose with no backstop. Given § 1, this is currently true of Claude adopters too, but it will stop being true for them once the hook is fixed and will remain true for everyone else.

## Part 4: Scale, measured

The repo is growing faster than any mechanism bounds it, and nothing measures aggregate size at all.

**Session start now costs about 111,000 bytes of template text**, roughly 28,000 tokens, before any project files or any work: `template/AGENTS.md` (11,059), `session-discipline.md` (52,104), `writing-style.md` (7,661), the role file, `AGENTS.softeng.md` (10,173), plus `convention-levels.md`'s upstream-check section and `upgrading-adoption.md` §§ 0 to 3, which that section mandates. Adding agentics' own `.dev/` reads brings a session here to roughly 169,000 bytes, about 42,000 tokens. `session-discipline.md` itself warns that spend concentrates in sessions above 150,000 tokens of context; the session-start read alone is now a meaningful fraction of that.

**Growth rate:** `session-discipline.md` went from 23,342 bytes at 0.10.0 to 52,104 now, an increase of 123% across five releases. The conventions set and `CHANGELOG.md` each roughly doubled in 27 days. At the recent rate, ten more releases puts the session-start read near 45,000 tokens.

The mechanism driving it is a loop: a rule fails to fire because it competes for attention against a large rule set, and the fix is a reinforcing paragraph added to the file whose size caused the miss. Roughly one in ten CHANGELOG entries describes a rule that existed and did not fire.

**Other measured findings:**

- `CHANGELOG.md` is 190,294 bytes, of which only about 5% is reachable by design: eleven distinct slugs are cited from outside it, and all eleven resolve. The remainder is archive that the adopter upstream-diff still traverses. That diff scales with elapsed releases, not file size: one release behind is about 11,000 bytes, four behind is about 72,000, and a quarterly-syncing adopter faces roughly 230,000. Nothing degrades gracefully; the procedure reads everything or nothing.
- `.dev/roadmap.md` is 40,236 bytes and 91.5% of it is a single undifferentiated "Design questions" section holding 29 items with no priority, status, or age signal. It is read at every session start. Agentics defined `roadmap_split: yes` for exactly this problem, built the atlas machinery it depends on, and explicitly exempted itself.
- `testing/regression-checklist.md` is 89,584 bytes and 88 scenarios, the second-largest file in the repo, with no index. `CONTRIBUTING.md` instructs contributors to "run the matching scenario," which is itself a search problem across 88 candidates with nothing mapping scenarios to the convention they cover.
- The dispatch table has 15 rows reaching 20 destinations, with several overlaps: editing a convention file fires two rows totalling 39,062 bytes and neither acknowledges the other; "Writing code" is a strict subset of "Reviewing a PR or change"; and "Finishing a task" fires on nearly every task, making a 9,236-byte read effectively unconditional while labelled otherwise.
- Root `AGENTS.md` has 7 dispatch rows against the template's 15. Some absences are correct and stated; two are not obviously deliberate, since the rows for improving a convention and for writing documentation are absent from the one repo where both are the primary activity.
- `.dev/sessions/` is 178,894 bytes across 33 files with an immutability rule and no retirement rule. The session-start read is correctly bounded at one or two files and should stay that way; what is unbounded is the archive, which no process revisits, and which the personal-info check never re-examines because it greps changed files only.
- Agentics' entire five-day working state, 19 CHANGELOG entries including a `breaking: yes` rename, is uncommitted, so an adopter running the upstream check today gets a confidently wrong answer: the remote-read fallback returns an older release's entries while reporting success.

## Part 5: Coverage gaps

Each of these was confirmed absent by grep and checked against `.dev/roadmap.md` so it is not a restatement of something already open. Marked EVIDENCED where the repo's own history shows the gap biting, and SPECULATIVE otherwise, per this repo's own "prove it before templating it" bar.

### The destructive-action gate is dispatched to the one role least able to act destructively

Verified: the word "irreversible" appears exactly once in the entire template, in `AGENTS.roles/general.md`, the file for non-technical users, covering "sending an email, deleting a file, submitting a form." `AGENTS.roles/dev.md` is five lines and states that it "adds nothing." Critical constraints cover credentials, environment reads, instruction files, paths, and names, and say nothing about destructive commands. `AGENTS.md`'s "check in before non-trivial decisions" reaches a hard-to-reverse footprint on the developer's own machine, which is machine state, not a cluster or a database. The one real infrastructure guard, in `AGENTS.softeng.md`, is that cluster operations go through Jenkins rather than a local `tf apply`, which covers Terraform only.

Nothing anywhere covers `kubectl delete`, `helm uninstall`, a migration against a shared dev database, dropping an OpenSearch index, `git push --force`, or `git reset --hard`. These are daily-available commands in this team's infrastructure and genomics-platform repos, and the role holding a kubeconfig is precisely the one whose role file adds nothing. EVIDENCED as a placement defect, SPECULATIVE as to any specific incident, since none appears in the record. Belongs in Critical constraints as a universal rule, with the softeng-specific instances staying where they are.

### Debugging is a first-class activity with no dispatch entry

The only debugging line in the dispatch table is "Deploying or debugging a service, read `.dev/docs/<service>/` if it exists," a conditional pointer at a project document. There is no `conventions/debugging.md`.

Three real debugging lessons already exist, each filed in a file a debugging session never loads: check live runtime configuration before theorizing about code paths, and reproduce the suspect state rather than reconstructing it from a diff or a reflog (both in `review-conduct.md`, dispatched by PR review), and look for a working sibling instance elsewhere in the same system before diagnosing from first principles (in `code-style.md`, dispatched by writing code). A session whose entire task is "this is broken, fix it" is reviewing no PR and writing no new code, so by this repo's own two-tier logic it loads neither. The repo's own principle that a reference has to be an instruction rather than a citation fails at exactly the moment these three would pay off. EVIDENCED: the CHANGELOG describes the sibling-instance rule as "generalized into a standing debugging heuristic" and then files it under code writing, and both `review-conduct.md` entries are marked as confirmed directly. The three sections already written are most of a `debugging.md`.

### "Say it is unknown" has been fixed three times narrowly and never stated generally

Zero files in the repo contain the words hallucination or fabrication. Three narrow fixes exist for the same underlying stance: an agent padding a timestamp with zeros rather than fetching the time, and a second agent then "correcting" it by renaming to a different fabricated time, which the CHANGELOG itself calls "the same guessing anti-pattern in a new disguise"; `agent-index.md`'s rule not to fall back on whichever name looks plausible; and `review-conduct.md`'s rule to state what was checked versus assumed, scoped to review reporting only. `AGENTS.roles/ai-eng.md` says to surface ambiguity rather than guess, but that governs the AI systems a developer builds, not the agent reading the file.

This is exactly the shape the repo's own `property-scoping-recurs` lesson exists to catch, a rule written around one instance rather than the property it depends on, and the generalization never happened. EVIDENCED, three instances, two named by the repo itself as the same pattern. Belongs in Interaction parameters, since it is a stance rather than a task.

### Nothing addresses the human, so every lesson has an agent-side fix and no developer-side counterpart

`template/AGENTS.md` states the position directly: it is instructions an agent follows, not documentation for people. `template/README.md` is adoption mechanics and `template/DEVELOPMENT.md` is project setup. Nothing tells a teammate joining an agentic project what a good instruction looks like, how to correct a wrong assumption so it actually holds, or which agent outputs to distrust by default.

The last of those is the sharp edge. `session-discipline.md` tells the *agent* that a compaction summary can report unexecuted work as done, and the maintainer's own global configuration independently carries a rule to verify a claimed cleanup with grep before building on it. No adopting project's documentation tells a *human* that a claimed cleanup is a class of output worth checking. The same asymmetry holds for the staging incident recorded in the CHANGELOG: the agent got a rule, the human got nothing. EVIDENCED indirectly, through the pattern across several shipped fixes rather than one incident.

### No convention for backing out of a mess the agent made

Nothing covers a half-applied multi-file edit, a file left syntactically broken, a bad commit already made, or a session that needs unwinding. The only recovery-shaped content, `session-discipline.md` § Unattributed working-tree changes, is about *another* session's changes and explicitly leaves keep-or-revert to the developer. The roadmap's checkpointing item is about preventing interruption damage, not recovering from it. EVIDENCED: the morning pass records a hand-edit breaking a file's JSON validity with recovery improvised, and a session log records an agent hand-running a migration against the point of the exercise, with the developer reverting it afterward. Belongs in `session-discipline.md`, which already owns git.

### No general stopping or escalation rule

Two narrow local stops exist: `code-review.md`'s purpose gate, and `agent-index.md`'s ambiguous-match case. Nothing covers three approaches tried and each failed, going in circles, the task not being worth doing, or the request resting on a false premise about the system. `review-conduct.md` records a real instance, several rounds of successive wrong theories that ended only when the developer asked directly for a test to be run, and the fix shipped as a debugging heuristic rather than as a rule about noticing the loop. EVIDENCED weakly, one clear instance.

### Two smaller gaps

**Dependency upgrades.** `code-style.md` covers *introducing* a dependency thoroughly and stops there. Nothing covers bumping an existing one: reading the target's changelog for breaking changes first, one at a time versus batched, what to do when a transitive bump breaks the build, or how to handle a Dependabot PR handed to an agent. This team runs Dependabot across roughly twenty repos. A naming collision will mislead anyone searching: `conventions/upgrading-adoption.md` is about upgrading agentics' own version, not dependencies. SPECULATIVE, no incident in the record.

**Safe removal.** Only hygiene bullets exist (remove unused endpoints and dependencies) plus scope discipline, which governs additions. Nothing covers finding consumers before deleting an exported symbol, whether to deprecate first and for how long, or what to do when the last caller lives in another repo. That matters concretely here, since Overture packages are consumed across repo boundaries with no local signal: the roadmap already records Stage still calling a deprecated Arranger query the migration guide says to replace, but files it as an instance of cross-pollination rather than as a removal-convention gap. EVIDENCED through that stale cross-repo consumer.
