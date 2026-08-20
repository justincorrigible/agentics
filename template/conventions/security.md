# Security conventions

## OWASP Top 10 awareness

All work should be aware of the current OWASP Top 10 for web applications. Before naming or applying a specific edition or year, fetch https://owasp.org/www-project-top-ten/ and compare it against whatever edition you'd otherwise assume from training data; use whichever is actually current, don't assume the list hasn't moved since. See `code-style.md` § Verifying dated or versioned external facts for why this needs to be a check triggered at the moment of use, not a standing reminder.

Apply security awareness in three ways:

1. **During implementation**: don't introduce vulnerabilities
2. **When reviewing adjacent code**: flag issues even if out of scope; log them in `.dev/tech-debt.md`
3. **During design decisions**: surface security implications when the task touches authentication, access control, input handling, session management, or dependency management

## Detailed guidelines

If a security-guidelines file already exists in your agent's global context (for Claude: `~/.claude/security-guidelines.md`), read it for security-relevant work: it maps each OWASP category to concrete patterns, design guidance, and code review triggers. If none exists, copy agentics' `template/global-context/security-guidelines.md` into your agent's global context directory to create your own (a synced copy of this repo's `conventions/security-guidelines.md`; see that file's header).

## Credentials and secrets

No credentials, secrets, API keys, tokens, or private URLs in any file committed to version control: ever. This includes comments, test fixtures, and example configurations. Use environment variables or a secrets manager; document the variable names but never their values.

## Node.js / pnpm: supply chain (A03)

pnpm v10+ blocks package install scripts by default. This is a deliberate A03 control: a compromised package cannot run arbitrary code during `pnpm install` unless explicitly approved.

**Always configure these for any pnpm project:**

In `.npmrc`:
```ini
scarf-js-opt-out=true   # opt out of @scarf/scarf telemetry; it phones home on install
```

In Dockerfiles, set `ENV CI=true` in the prod-deps stage before `pnpm install --prod` to suppress the interactive modules-purge prompt. The server stage should inherit from `base`, not `prod-deps`, so this does not leak into the final image:
```dockerfile
FROM build AS prod-deps
ENV CI=true
RUN pnpm install --prod --frozen-lockfile
```

**For packages that legitimately need install scripts** (native binaries, code generators), use `pnpm-workspace.yaml`:

```yaml
allowBuilds:
  esbuild: true
  '@scarf/scarf': false   # always false: block even if it appears as a transitive dep
```

Only approve packages you have reviewed. Treat a new entry in `allowBuilds` the same way you would a new dependency: confirm what the script does before allowing it.

**A vulnerability report names an instance, not a boundary.** Before treating a reported vulnerability as fixed, sweep for other instances of the same pattern, and expect the unreported one to be worse, since reports arrive from wherever attention fell rather than in severity order. The rule is general to pattern-shaped defects rather than specific to security, so it lives in `definition-of-done.md` § A report names an instance; it is pointed at from here because a vulnerability fix is where the cost of skipping it is highest.

## An undisclosed vulnerability never goes in devctx

**`.dev/` is committed, and in many projects pushed to a public remote, so writing a live vulnerability there discloses it.** `session-discipline.md` asks you to log meaningful work in `.dev/sessions/` and open issues in `.dev/tech-debt.md`, and neither carves out security findings, so following both rules literally publishes the hole. That is the whole gap: the instruction to record and the instruction to protect point in opposite directions, and only one of them was written down.

**A finding is undisclosed until its owner discloses it, whoever found it.** This covers a vulnerability you found in review, one that reached you in a peer message, and one you hit by accident in someone else's project. Being told about it does not make it yours to publish, and a private repository is not a safe assumption either, since remotes change and forks outlive the decision.

**Split the writing by direction rather than by topic: prescriptive is safe, diagnostic is the disclosure.** "Compose the filter at this boundary so every read path inherits it" carries the entire design intent and protects a reader. "These three read paths do not compose it" is a map. The content is the same and only one direction of it is exploitable, so a design record stays writable at full strength. This matters because the earlier phrasing of this rule made it unwritable rather than thinner: you cannot justify where an enforcement seam belongs without describing how the current one fails, so the failure is the design input. A worked rewrite from the session that found this, on a table enumerating which empty encodings fail open: "a filter must carry at least one leaf clause; an empty combination is not a restriction" keeps the protective value and drops the lookup table.

**The split resolves the design record completely and does not resolve a stopgap at all.** Where a hole is still open and an operator can protect themselves today by forcing a flag, "set this flag" is not actionable without "because the default does not restrict", so the protective value and the disclosure are the same sentence and no wording separates them. **The answer to an unpublishable stopgap is to close the hole faster, not to find better wording.** That is a second reason for the priority order below, beyond a fixed hole making its description harmless: an unfixed hole can generate guidance that cannot be safely written anywhere. If it outlives the ability to warn, the only channel left is direct contact with affected operators, which is never an agent's decision. Reported as two different questions wearing the same shape, which is worth watching for whenever one distinction appears to resolve a conflict cleanly.

**So record that the work happened, not what the weakness is.** A session entry can say a security issue was found in a named component and routed to its owner. It must not carry the mechanism, the reproduction, the vulnerable path, or the payload. The detail goes to the owner directly, or wherever that project actually tracks security issues, which is a channel the developer chooses rather than one you improvise.

## Once it is already published, the only moves are forward ones

**This rule was preventive only, which left nothing for the situation an adopter reading it late is actually in.** The asymmetry above, that history survives the edit removing it, is exactly why remediation needs naming: since you cannot undo it, every remaining action is forward, and none of them were written down.

**Read the material and count it before choosing a response, because a proxy count changes what is proportionate.** A session that had pushed an access-control audit to a public repository first reported 128 mechanism-bearing lines from a keyword grep, then read them and found 11 payload literals of which about four were genuinely disclosive, the rest being prose such as a table header. The first number justifies drastic action and the second does not. Counting by grep and acting on the count is the same proxy failure this repository has now recorded three times in a week.

**Do not rewrite public history, and expect this to be the instinct hardest to resist.** A force-push does not reach forks, existing clones, local caches, or dangling commits that stay fetchable through the hosting API. It does reliably signal that something in that range was worth hiding, which narrows the search for anyone who cares. And an inventory that was wrong leaves the map in place after paying the full cost, which is a control whose failure looks like success.

**The order is: close the hole, tell the developer, stop, then tidy the description.** A fixed hole makes its description harmless, which is why it comes first and why scrubbing comes last despite feeling most urgent. Stopping is a real step: whether known downstream deployments get notified involves people, timing, and possibly obligations an agent cannot see, so it goes to the developer as a question and never as a plan. Most of the artifact usually survives in place once rewritten prescriptively, so relocating the whole thing is normally over-scoping.

## Where the residue goes, and why its address is not writable

**Two things get conflated here and they need different homes.** A live unfixed vulnerability and design substance that cannot be public are not the same artifact, and one storage choice cannot serve both.

**A live unfixed vulnerability belongs in a security advisory on the affected repository, because an advisory has a publish step and a repository does not.** An advisory drafts privately, can carry a private fork for the fix, and publishes deliberately when the fix ships, producing the operator-facing notice as an output of the process. A private repository produces nothing at the end. **So a repository used for a live vulnerability is a drawer, and a drawer is how something stays undisclosed for years by default rather than by decision.** Raised by a session weighing exactly this, against a candidate private repository that had been dormant for eighteen months.

**Design substance that cannot be public is the genuine gap, and a private organization repository fills it.** That is the residue left after rewriting everything that can be rewritten prescriptively, which is normally most of it.

**"Private" is a smaller claim than it sounds, so count the collaborators before relying on it.** The candidate above had twenty-three. That is private from the internet rather than need-to-know: fine for design substance, wide for an unfixed hole. An adopter reading "put it in your private repository" pictures a number, and it is rarely the real one.

**Prescriptive phrasing still applies inside a private atlas.** A private remote is not a safe assumption either, since remotes change and forks outlive the decision, so writing freely there moves the map behind a login rather than not drawing it.

**An atlas nobody is required to read goes stale like any other document nobody is required to read.** `.dev/` works partly because the files sit beside the code and a session-start step reads them, and a remote atlas has neither property.

**So `.dev/` records that the atlas exists, and your global context records where it is.** These are two different facts and only the first is safe to commit. A committed pointer naming the location would defeat the guard below, while a committed pointer naming only the existence solves the staleness problem, because a session-start read finds it and then asks the developer or the global context for the address.

**The guard, which is what decides whether any of this is recommendable at all.** If a convention says to record non-public detail in your organization's private atlas, adopters will name theirs in a committed `AGENTS.md`, and the aggregate across adopters is a public map of where organizations keep their unfixed vulnerabilities. Each adopter does something locally reasonable and the class outcome is bad, which is why the rule has to carry both halves: have one, and keep its location out of every committed file.

**This is the committed-paths constraint rotated onto a different axis, and the rotation is the part that needs saying.** That rule forbids a machine- or user-specific path because a resolved path will not work for anyone else. This forbids a resolvable location because it should not work for anyone else. Same prohibition, opposite reason, and an adopter following the existing wording literally would not catch it, since an organization repository URL is neither machine-specific nor user-specific.

**If local sessions share the atlas as a write surface, it inherits everything the agent index needed.** Several sessions edit concurrently, no two observe the same state, and a count quoted from it is a fact about one read rather than about the file. See `agent-index.md` for the three-step write.

## A memory entry's description is a broadcast, not a label

**Anything indexed into an always-loaded memory index reaches every session sharing that path, whatever they are working on.** So the description line is the part most certain to be read, not the least. It is subject to everything above, and more strictly than the body it summarizes.

Confirmed rather than predicted: a session found a memory file in its own workspace whose `description` stated a fail-open mechanism outright, indexed into the file every session there loads. Rewriting a description prescriptively costs nothing and keeps it useful, so the fix is cheap; noticing that the field was a publication surface at all is the part that had not happened.

**More generally, moving something out of version control is not a security control.** A global agent-context file has no access control beyond the filesystem, keeps no history, and is loaded into the context of every session on the machine including ones in unrelated projects. Its read exposure is therefore broader than a private repository rather than narrower, which is the opposite of how "off git" reads.

**If you are unsure whether something qualifies, treat it as undisclosed and ask.** The asymmetry is severe: a detail withheld for one exchange costs a round trip, and a detail committed to a public remote cannot be withdrawn, because history survives the edit that removes it.

Reported by a session that hit this rather than reasoning about it: an undisclosed vulnerability arrived by peer message, the convention told it to log meaningful work, and nothing told it not to. It reasoned the right answer out of Critical constraints by analogy, which is a thin thing to rely on twice.

## Quick threat model (A06: Insecure Design)

Before implementing a feature with security implications, answer three questions and record the result: see `security-guidelines.md` § Quick threat model for the full version (the questions, a worked "what could go wrong" checklist, and the rationale).
