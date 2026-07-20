# Security Guidelines: OWASP Top 10:2025

> This document is keyed to the 2025 edition. Before relying on the category numbers or names below in security-relevant work, fetch https://owasp.org/www-project-top-ten/ and confirm 2025 is still current; if a newer edition exists, treat this document as needing a re-map, not as authoritative on its own. See `code-style.md` § Verifying dated or versioned external facts.

These guidelines are derived from the team's working review of OWASP Top 10:2025 (items 1-7 reviewed; 8-10 supplemented from OWASP directly). They are a working document: update as new items are reviewed and as patterns are validated in practice.

---

## Quick threat model: A06: Insecure Design

Before implementing any feature with security implications, answer three questions. Aim for five minutes; record the result in `.dev/sessions/` under the feature name.

**1. What are we building?**
One sentence.

**2. What could go wrong?**
- User A accesses User B's data?
- Malicious input causes resource exhaustion, injection, or unexpected state?
- Stale or stolen credentials grant access?
- Restart or crash loses data or leaves state inconsistent?
- Sensitive data exposed in logs, errors, or URLs?
- New dependency introduces a supply chain risk?
- Adversarial user exploits an edge case in a flow we designed for good-faith use?

**3. What are we doing about it?**
Specific design decisions addressing each threat above.

This is the mitigation for insecure design: documenting intent surfaces blind spots before they are baked in, and creates a paper trail for security decisions. Apply "shift left": a threat caught at design time is cheaper to fix than one caught at code review, and far cheaper than one caught in production.

---

## Secure design patterns by OWASP category

### A01: Broken Access Control

- **Deny by default:** explicit allow, never implicit allow
- **Server validates all requests:** never rely on UI-level restrictions alone
- **Centralize access control:** one enforcement layer in the backend; simplifies CORS/CSRF surface
- **Test denial stories:** QA with auth enabled, all user types; verify that unauthorized access is rejected: not just that authorized access works
- **Rate-limit all endpoints:** especially auth endpoints and aggregation queries; infrastructure-level rate limiting covers anonymous users; application-level covers authenticated abuse
- **Log access failures:** include the identity (or "anonymous"), the resource requested, and the reason for denial: make repeated failures observable
- **Account lifecycle discipline:** disable accounts promptly when staff leave or roles change; build a regular expiry process; don't rely on manual cleanup

### A02: Security Misconfiguration

- **Debug, admin, and introspection endpoints off by default:** require explicit opt-in; never opt-out
- **Default feature flags to `false`:** `enableDebug`, `enableAdmin`, playground modes: all false unless explicitly set; remove flags when the feature is stable
- **Production mode must be explicit:** set `NODE_ENV=production` (or equivalent) in the runtime environment, not just assumed; apps should identify whether they are in production mode
- **Error out on default or missing credentials:** the application should refuse to start rather than run with weak defaults; never ship with known default passwords
- **No wildcard CORS outside local dev:** `allowedCorsOrigins: ['*']` is a misconfiguration in any deployed environment
- **No stack traces or internal paths in API responses:** log server-side; send generic messages to clients
- **Parity between staging and production config:** have a staging environment with the same configuration as production so config drift is detectable before it reaches prod
- **Remove unused endpoints, accounts, and config keys:** unused surface is still attack surface; review and clean up regularly

### A03: Software Supply Chain Failures

- **Human review for every new dependency:** someone other than the requester reviews and approves the addition
- **Pin exact versions:** explicit versions in `package.json`; lock files (`package-lock.json`, `pnpm-lock.yaml`) belong in version control
- **Ignore install scripts by default:** `ignore-scripts=true` in `.npmrc`; enable explicitly only where required
- **Run audits deliberately, not on every install:** `audit=false` in `.npmrc`; run `npm audit` as a CI gate so it's a signal, not noise
- **Staged deployment:** don't deploy to all environments simultaneously; a staged rollout surfaces supply chain issues before they reach production
- **Remove deprecated and unused dependencies:** stale packages accumulate unpatched vulnerabilities; periodic cleanup is part of supply chain hygiene
- **The supply chain includes developer workstations:** IDEs, extensions, and local tooling are part of the attack surface: keep them updated

### A04: Cryptographic Failures

- **TLS everywhere:** no plain HTTP for any endpoint carrying data, credentials, or tokens: including internal services
- **Never implement your own crypto:** use established libraries (`bcrypt`/`argon2` for passwords; `jose`/`crypto` module for tokens and signatures)
- **Hash passwords, never encrypt them:** if decryption is possible, the key can be stolen; use a slow hashing algorithm, not MD5 or SHA1 (both deprecated)
- **Short-lived signed tokens:** JWTs with short expiry; verify signature, expiry, and claims (`aud`, `iss`, scope) on every use
- **Unique credentials per environment:** different passwords and keys in production vs. development; never reuse keys across systems
- **Data minimization:** don't store sensitive data you don't need long-term; less stored data means less to protect and less to breach
- **Secrets belong in a secrets manager, not in code or config files:** document the variable names, never their values; rotate secrets when systems change
- **Don't transmit confidential data over email or unencrypted channels**

### A05: Injection

- **Parameterize all queries:** no string concatenation for SQL, Elasticsearch DSL, GraphQL, or shell commands: use libraries that handle parameter binding
- **Validate field names before forwarding:** user-supplied field names passed to a backend service are an injection vector; validate against a known allowlist
- **Escape and sanitize output:** user input rendered in HTML, JS, or URL contexts must be escaped for that context
- **Same-site cookies for session tokens:** prevents CSRF by limiting cookie transmission to same-site requests
- **Anchor tags need `rel="noopener noreferrer"`** when opening in a new tab; prevents the opened page from accessing `window.opener`
- **Never execute dynamically fetched scripts:** avoid `dangerouslySetInnerHTML` or equivalent; if content from an external source must be rendered, verify no unexpected scripts are present: in practice, this is rarely safe to rely on

### A07: Authentication Failures

- **Use MFA wherever possible:** it is the single most effective mitigation against credential-based attacks
- **Short-lived tokens with explicit expiry:** validate expiry on every use, not just at issuance; revoke all sessions when a password changes
- **Validate JWT claims:** check `aud`, `iss`, and scope: not just signature and expiry
- **Rate-limit failed login attempts and lock accounts on repeated failures:** covers brute force, spray attacks, and credential stuffing
- **Force password reset on suspected breach**
- **Consistent error messages on failure:** don't reveal whether an account exists
- **Log all authentication attempts:** not just login failures: log access requests to auth-protected services, including the resource requested; monitor for unusual failure rates across users, endpoints, or time windows
- **System credential rotation:** passwords for backend service connections (databases, APIs) should be rotated on a defined schedule; document and agree on the interval

### A08: Software and Data Integrity Failures

- **Lock files in version control:** ensures reproducible installs across environments
- **Validate all deserialized data:** never trust data from external stores, message queues, or third-party APIs without schema validation
- **Integrity checks on critical config:** configuration loaded at startup should be validated before use
- **CI/CD pipeline hygiene:** build outputs should not be modifiable by untrusted actors; use SBOM generation where practical for audit trails

### A09: Security Logging and Alerting Failures

- **Structured JSON logs:** parseable by log aggregators; avoid free-form strings; this is a prerequisite for effective monitoring
- **Log access failures with context:** identity, resource, and reason for each denial
- **Never log credentials:** passwords, tokens, API keys, and `Authorization` header values must not appear in output at any log level: including debug
- **Make anomalies observable:** repeated failures, unexpected admin access, and unusual query patterns should be alertable; work with your operations team on log collection and monitoring

### A10: Mishandling of Exceptional Conditions

- **Handle errors explicitly:** don't let exceptions propagate to the caller with internal state attached
- **Fail safely:** on error, reject the request cleanly: don't partially apply state changes
- **Resource cleanup on failure:** connections, file handles, and session state must be released on exception paths
- **See failure state documentation below** for the design-time complement to runtime error handling

---

## Failure state documentation

When designing security-sensitive features, document failure modes before writing code. For each scenario:

1. **What goes wrong?**
2. **What happens now?** (current behaviour)
3. **What should happen?** (safe failure: reject, log, limit, don't leak)
4. **Status:** TODO / In progress / Done

```markdown
### Failure states: [feature name]

**Server restart:**
- What goes wrong: all in-memory state lost
- What happens now: clients cannot resume sessions
- What should happen: persistent store with replay capability
- Status: TODO

**Network drop:**
- What goes wrong: transport entry persists indefinitely
- What happens now: memory leak
- What should happen: timestamp-based sweep evicts idle sessions
- Status: TODO

**Malicious input:**
- What goes wrong: oversized or deeply nested payload exhausts memory
- What happens now: unhandled exception or OOM
- What should happen: payload size limit and depth cap enforced at ingress
- Status: TODO
```

---

## Code review triggers

Flag these during any security-adjacent review: don't wait to be asked:

- String-concatenated queries (SQL, ES DSL, GraphQL, shell)
- User-supplied field names forwarded to a backend without validation
- Wildcard CORS (`*`) outside a local-dev guard
- Stack traces, file paths, or internal names in API responses
- Credentials, tokens, or secrets in any log statement
- `enableDebug`, `enableAdmin`, or playground enabled without an explicit opt-in guard
- New dependencies without a lock file update or review record
- HTTP (not HTTPS) for any non-localhost URL
- Missing or unverified `aud`/`iss`/scope claims on tokens
- `<a target="_blank">` without `rel="noopener noreferrer"`
- Default or empty credentials accepted at startup
