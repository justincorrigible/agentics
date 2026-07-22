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

## Node.js / pnpm: supply chain (A08)

pnpm v10+ blocks package install scripts by default. This is a deliberate A08 control: a compromised package cannot run arbitrary code during `pnpm install` unless explicitly approved.

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

## Quick threat model (A06: Insecure Design)

Before implementing a feature with security implications, answer three questions and record the result: see `security-guidelines.md` § Quick threat model for the full version (the questions, a worked "what could go wrong" checklist, and the rationale).
