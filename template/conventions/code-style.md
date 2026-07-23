# Code style conventions

## Comments

Default: write no comments. Add one only when the WHY is non-obvious: a hidden constraint, a subtle invariant, a workaround for a specific bug, behaviour that would surprise a reader. If removing the comment wouldn't confuse a future reader, don't write it.

Never explain WHAT the code does; well-named identifiers already do that. Never reference the current task, fix, or callers: those belong in the PR description and rot as the codebase evolves.

## Configuration and environment isolation

Module functions should never read from the environment directly (`process.env`, config files, global singletons). Configuration belongs at a dedicated config-reading seam; everything downstream receives typed parameters.

This applies at two levels:

**Library and package code:** never reaches `process.env` under any circumstance. Configuration is always injected by the caller as a typed argument. This keeps the library testable in isolation and free of hidden deployment coupling.

**Application-layer module functions:** even within a server, individual setup or service functions (e.g. `setupKafka`, `setupAuthProvider`) should accept a typed config object rather than reading env vars inline. The env-reading belongs in a dedicated `getXConfig()` helper or a central config assembly function (e.g. `buildAppConfig()`). The setup function itself stays pure and programmable: another server importing it can construct the config object however it likes, without being forced through env vars.

Concrete pattern:

```ts
// config/kafka.ts
export type KafkaConfig = { brokers: string; clientId: string; topic: string };

export const getKafkaConfig = (): KafkaConfig | undefined => {
  const brokers = process.env.KAFKA_BROKERS;
  if (!brokers) {
    return undefined;
  }
  return { brokers, clientId: process.env.KAFKA_CLIENT_ID ?? 'app', topic: getRequiredConfig('KAFKA_TOPIC') };
};

export const setupKafka = async (config: KafkaConfig): Promise<KafkaResult> => {
  // receives config; never reads process.env
};

// server.ts
const kafkaConfig = getKafkaConfig();
const kafka = kafkaConfig ? await setupKafka(kafkaConfig) : undefined;
```

The rule of thumb: if a function is `export`ed and takes work that depends on configuration, it should accept that configuration as a parameter, not discover it at runtime.

## Matching existing configuration entry points

Before adding new functionality that needs configuration, especially inside a library or module (a new integration client, a new feature flag, a new external dependency), locate how this project *already* resolves configuration before writing a new `process.env` read or default value. Every codebase settles on its own shape for this: it might be a single `getXConfig()` helper (see "Configuration and environment isolation" above), or a fuller layered pipeline, default constants, then env vars, then optional config-file aggregation, each layer overriding the one before it, before the merged result crosses into a library boundary. Match whatever shape already exists; don't introduce a second, parallel entry point alongside it.

This is a specific case of "Searching before writing" (below) worth calling out on its own: a genuinely new feature doesn't feel like duplicating anything, so the general habit of searching for existing implementations doesn't naturally fire. The search that matters here isn't "does this feature's config already exist" (it doesn't), it's "how does this project already ingest configuration, in general" (it does, somewhere), a different question, easy to skip past when the surrounding work is a real feature addition rather than a rewrite.

Concretely: adding new functionality to a library should mean extending the host application's existing config-assembly step, wherever it already builds the object passed into the library, with the new fields, not adding a second `process.env` read inside the library's new code. The library still never reads `process.env` directly, per "Configuration and environment isolation" above; the point here is the earlier step of finding where that reading already happens before assuming a new one is needed.

## Conditional logic and functional style

**Positive conditions.** Write `if X` rather than `if !X`. Put the happy path in the positive branch; let the error case fall through or come after. A reader should not have to negate a condition mentally to understand what the main flow does.

**Non-mutational.** Prefer expressions that produce new values over statements that mutate existing containers. Use ternaries and object spread instead of initialising an object and conditionally filling it:

```ts
// avoid
const headers: Record<string, string> = {};
if (auth) headers['Authorization'] = buildBasicAuth(auth);

// prefer
const headers = auth ? { Authorization: buildBasicAuth(auth) } : {};
```

The same principle applies to loops, not just object construction. A `while`/`for` loop that reassigns a local across iterations to accumulate a result is still a mutating statement; recursion (or `reduce`/`map`/`find` where the shape fits) is the expression-producing equivalent:

```ts
// avoid
const findRoot = (dir: string): string => {
  let current = dir;
  while (!isRoot(current)) {
    current = parentOf(current);
  }
  return current;
};

// prefer
const findRoot = (dir: string): string => (isRoot(dir) ? dir : findRoot(parentOf(dir)));
```

**Pure helpers.** When a block of logic has a clear input and output (a lookup, a transformation, a format function), extract it as a named function with no side effects. This keeps orchestration code readable and the logic independently testable.

**Derive from data, don't duplicate as a flag.** When a field's value is fully determined by other configuration already present, don't add a separate explicit discriminator (`enabled`, `type`, `mode`) for it: gate behaviour on the presence or content of the data itself. A `type: gateway | ingress | none` field that could instead be "gateway if `gateway.parentRef.name` is set, ingress if `ingress.hosts` is non-empty, neither otherwise" adds a second thing to configure and keep consistent with the first. Applies to Helm values, API schemas, and configuration objects generally: when presence unambiguously implies intent, don't require intent to be stated twice.

**Always brace control-flow blocks.** Every `if`, `else`, `for`, and `while` body gets `{ }` on its own line, even for a single statement, never a brace-less one-liner (`if (x) doThing();` or `if (x) return y;` on the same line). A later change that adds a second statement to a brace-less conditional produces a diff that rewrites the line's structure along with its content; a diff against an already-braced block is purely additive, easier to review.

```ts
// avoid
if (!user) return null;

// prefer
if (!user) {
  return null;
}
```

Apply these five together: a function composed of pure helpers, positive conditions, non-mutational expressions, data-derived rather than duplicated flags, and consistently braced control flow reads as a series of declarative steps rather than a sequence of instructions.

## No non-null assertions

Never use TypeScript's non-null assertion operator (`variable!`), even in a project whose `tsconfig.json` doesn't enable `strict` or `strictNullChecks`. The operator silences the type checker without proving the value is actually non-null: it just moves discovery of a wrong assumption from compile time to an unguarded runtime crash, with no evidence beforehand that the assumption was ever unsafe. This holds independently of the project's strictness settings: removing the assertion doesn't just appease a compiler flag that may not even be on, it forces the real runtime possibility (the value being absent) to be handled somewhere.

Prefer, in order:
- Optional chaining and nullish coalescing: `value?.prop ?? fallback`
- A narrowing `if` or early return before use
- A reusable type guard function, for a check used in more than one place

```ts
// avoid
const user = users.get(id)!;
sendEmail(user.email);

// prefer
const user = users.get(id);
if (!user) {
  throw new Error(`User not found: ${id}`);
}
sendEmail(user.email);
```

Apply to new code from the start. When touching existing `!` usages in scope, replace them; otherwise log as tech-debt rather than doing a blanket rewrite out of scope.

## TSDoc for exported symbols

All functions, types, and interfaces exported from a module require a brief TSDoc comment. One or two sentences is enough: state the contract or a non-obvious behaviour, not what the name already says. For types with multiple fields, add inline `/** */` member comments on the non-obvious ones.

This is distinct from the general "no comments" rule above, which applies to inline implementation code. TSDoc is documentation for library consumers, not internal readers.

Apply when writing new exports. When touching existing exports that lack TSDoc, add it in scope if quick; otherwise log it as tech-debt.

## Scope discipline

Stick to the stated scope. For design weaknesses, type flaws, or improvement opportunities noticed along the way: surface them verbally, then document them in `.dev/tech-debt.md` (or ask where that is). "Known issues" visibility is preferred over silent omission.

If a scope-adjacent issue is small enough to fix in place without meaningful risk or scope expansion, fix it immediately rather than logging it. Tech-debt entries are for genuinely deferred work: something too large, too risky, or explicitly out of scope to address now. A one-line fix does not need a ticket.

Don't add features, refactor, or introduce abstractions beyond what the task requires. Don't design for hypothetical future requirements. Three similar lines is better than a premature abstraction.

## Library awareness

When a well-established library would do more thorough work than a hand-rolled solution, surface it as an option with a brief explanation. Let the user decide: they may learn something useful from it regardless of whether they adopt it.

## Dependency version verification

When introducing a new dependency, always check the current version against the registry before writing it into any config file. Run `npm view <package> version` (or the equivalent for your package manager) to confirm the version is current.

Do not produce version strings from training data, and do not treat "already used in this repo" as implicit endorsement of currency: the existing version may itself be stale. "Consistent with existing" and "current" are separate checks; run both.

Also check for version conflicts before writing: run `npm why <package>` (or equivalent) to see what versions of that package and its close deps are already in the tree. If the new version brings in sub-dependencies that conflict with existing ones - especially native platform packages that package managers hoist into shared locations - flag the conflict before committing the change.

**Evaluating whether a package already has a capability is the sibling case to introducing one.** `latest` is one dist-tag among several; a maintainer can ship current work under a pre-release tag (`next`, `rc`, `beta`) without promoting it. Concluding a package lacks a feature because it's absent from `latest` is the same stale-assumption pattern above, applied to capability instead of version. Run `npm view <package> dist-tags` (or equivalent) before concluding a capability doesn't exist yet, especially when evaluating a migration or a dependency swap.

## Verifying dated or versioned external facts

Training data has a cutoff, and a fact that carried an explicit version or date when you learned it may be stale by now, or may have been superseded since. This is intractable to solve in general: you cannot re-verify everything you know. It's tractable exactly when two things are both true: the fact carries an explicit, checkable version or date marker (a named standard's edition, a spec revision, a changelog), and checking it is cheap, one fetch, not a research project.

When both hold and the fact is about to be actively cited or applied, not just background context, verify it against the authoritative current source first, rather than defaulting to whatever edition or version training data implies. A standing "always verify the current edition" reminder isn't enough on its own to make this fire: it's the same failure mode a passive dispatch citation has (see `convention-levels.md` § "The reference has to be an instruction, not a citation"). Tie the check to the specific moment a versioned fact is about to be used, not to remembering a general reminder.

"Dependency version verification" above is one instance of this (npm package versions, checked against the registry); it's the same underlying rule, scoped to one kind of source.

**Concrete trigger:** naming or applying a specific OWASP Top 10 edition or year is exactly this case, see `security.md` and `security-guidelines.md`.

## Checking in

Checking in before non-trivial decisions is good practice: it gives the user a chance to catch design misalignments early. Don't over-ask on mechanical steps, but do ask on direction.

## Language and typos

Flag typos and language issues when spotted: in code, comments, and documentation. Don't fix silently; call them out so the user can decide.

## Dashes

Never use em dashes, en dashes, double hyphens as dash substitutes, or space-hyphen-space as sentence connectors in any output: documentation, code comments, persisted files, or conversational messages. This applies to all text content without exception. Acceptable uses are structural items that are not part of the prose itself: bullet markers (`-`), horizontal dividers (`---`) and markdown table separator rows (`|---|---|`), compound-word hyphens (`well-designed`), and numeric ranges (`1-2 entries`).

Do not use in text:
- Em dashes (`—`, U+2014)
- En dashes (`–`, U+2013)
- Double hyphens (`--`) as a dash substitute
- Space-hyphen-space (` - `) as a sentence connector

For mid-sentence connectors, use a semicolon or rephrase. For inline annotations in bullets (`.dev/sessions/` entries, `roadmap.md`, etc.), use `: ` as the separator: `` `path/to/file`: what changed ``. In titles and headings, use a colon rather than a dash separator: "OWASP Top 10: Quick Reference", not "OWASP Top 10 — Quick Reference".

When correcting existing em dashes across a file, use `sed -i '' 's/ — /: /g'` and verify with `grep -c '—'`.

## Spelling and language convention

[Team placeholder: configure your preferred spelling convention here. Example: Canadian English uses `-our` suffixes (colour, behaviour), `-re` suffixes (centre, fibre), `-ize` (not `-ise`), and `-yze` (analyze, paralyze; unlike the -ise/-ize split, Canadian does not diverge from American here).]

## Searching before writing

Before implementing something new, search the codebase for existing patterns first. Use `grep` or semantic search to find similar implementations: this keeps the codebase consistent and surfaces reusable utilities before they get duplicated.

For the specific case of adding new configuration-dependent functionality, see "Matching existing configuration entry points" above: the same habit, applied to finding an existing config-resolution mechanism rather than an existing utility function.

## Property ordering

Alphabetize properties within objects and mappings in config files (YAML, JSON, etc.) at all nesting levels: scalars and block properties interleaved together, not split by type. This prevents silent duplicate key overwrites and makes additions easier to place consistently.

Alphabetize named resource blocks in Terraform files by resource name (the second label, e.g. `"github-metrics"`, `"keycloak"`, `"lectern"`). VSO companion blocks follow their primary resource directly rather than being sorted independently.

**This applies to code, not only config files.** Alphabetize the properties of an object literal, the fields of a `type`/`interface`, and the names in a destructured parameter (`{ a, b, c }: Params`), the same way and at every nesting level. A plain positional argument list is unaffected: its order comes from the function signature, not from sorting. This rule is about named fields, not every list.

**And to markdown reference documents with named per-item sections**, not just code or config: a project map's `### project-name` headings, a glossary's terms, anything enumerating discrete named entries. Same reasoning as config keys: scanning for whether an entry already exists, and knowing where a new one belongs, both get harder without it. A prose document that isn't enumerating named items (a narrative walkthrough, an ordered set of steps) isn't affected: this is about named-entry lists, not every heading in existence.

Apply when writing new content, config or code. When editing existing files, fix ordering within the sections being touched. When inserting a new key, resource block, or field into an existing structure, place it at its alphabetical position: not at the current edit point, not at the end.

**Watch for drift across a multi-step task.** Alphabetization is easy to get right in isolation and easy to lose when a field gets bolted onto an existing object mid-task (new key appended at the end instead of inserted in place) or when the same shape gets copy-pasted across several call sites (one gets fixed, the copies don't). Before treating a multi-file change as done, sweep back over every object literal, type, and destructured parameter it touched, not just the one you were looking at when you added the field.

**Optional automated enforcement:** [`eslint-plugin-perfectionist`](https://npmjs.com/package/eslint-plugin-perfectionist) has autofixable rules for exactly this (`sort-objects`, `sort-interfaces`, `sort-object-types`, among others) and can catch what manual review misses. Surfacing it here as an option per "Library awareness" above, not a requirement: check its current version against the registry before adopting, and confirm which of its rules cover destructured parameters versus plain object literals before relying on it as the sole enforcement mechanism.

## Structured logging

Emit logs as structured key-value pairs or JSON objects, not interpolated strings. Include a consistent set of fields: timestamp, severity, event type, actor identity where known, resource identifier, outcome. Do not log secrets, credentials, or PII in log values.

Apply from the start of any feature involving:
- Authentication, authorization, or access control decisions
- Permission changes or administrative actions (must always be logged as auditable events)
- Data access, downloads, or exports
- Errors, failures, or unexpected states at system boundaries

Set up structured logging before writing application logic, the same way you set up a test runner before writing tests. It is not optional plumbing.

## Git

Never commit without explicit user instruction: the user handles all git work themselves.

Never stage changes (`git add`) without being explicitly asked to, either: staging is the user's call, same as committing. Making an edit does not stage it: changes sit in the working tree, unstaged, until staged deliberately. When reporting on changes made, state their actual git state plainly rather than just "the changes are there": a user who expects staging and finds none wastes real time looking for something that was never where they expected it.

**No AI-tool attribution in commits or PRs.** Do not add "Co-Authored-By," "Generated with," or similar trailers naming an AI tool or vendor to commit messages, PR descriptions, or PR comments, regardless of which agent is doing the work. Unprompted attribution reads as this project endorsing a specific commercial product; that's not something to do on any vendor's behalf, paid or not.

[Team placeholder: adjust this default if your team has a different commit or staging discipline.]
