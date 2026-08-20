# Code style conventions

## Comments

Default: write no comments. Add one only when the WHY is non-obvious: a hidden constraint, a subtle invariant, a workaround for a specific bug, behaviour that would surprise a reader. If removing the comment wouldn't confuse a future reader, don't write it.

**Iterative work compounds this, and each comment earned its place at the time.** A note explaining a fix just made, or what a reviewer just confirmed, reads as a legitimate "why" in the moment. Across several rounds of fixes and review the accumulation is a changelog embedded in the source rather than documentation of the code as it stands, and none of it will still be true or relevant a week later. Reported by Arranger MCP from a file that went through four rounds of independent review.

**Fix it with a dedicated pass once work on the file settles, not incrementally.** Re-read every comment and ask this section's question again, per comment. That pass cut the reported file by 17%, comments only, no logic touched. It has to be separate because no per-comment judgement made during the work can see the total.

Never explain WHAT the code does; well-named identifiers already do that. Never reference the current task, fix, or callers: those belong in the PR description and rot as the codebase evolves.

## Naming conventions

**No `Type` suffix on type names, no `I` prefix on interfaces.** Name the concept, not the declaration keyword: `ThemeContext`, not `ThemeContextType`; `Logger`, not `ILogger`. A consumer never sees whether something was declared with `type` or `interface`, and the two are interchangeable enough in practice that the name shouldn't imply otherwise.

**Full-word, descriptive identifiers, never a single letter or an unexplained abbreviation.** Applies broadly: any variable, parameter, or import alias, including a package's own conventional short alias (`fc` for `fast-check`, `z` for `zod`), not just the obviously terse ones. A package-level convention being common doesn't make an abbreviation self-explanatory to someone who doesn't already know that package.

**Exception: idioms embedded in the language or framework itself, not a single package's own convention.** A loop counter (`i`, `j` in a simple bounded loop) or Express middleware's own signature (`req`, `res`, `next`) are established vocabulary shared across virtually every codebase in that language or framework, not an abbreviation anyone chose for brevity. That's a narrower exception than a package's own short alias: reach for it only when the idiom is genuinely universal to the language or framework, not merely common within one library's own docs or examples.

## Platform portability

When a fix depends on something that differs by platform, a socket path, a line ending, a case-sensitive filesystem, an installed binary's default location, default to detecting the runtime or making it configurable, not hardcoding the value observed on whichever machine wrote the fix. This applies most sharply to modifying the machine itself rather than the code: a symlink or local file created so one specific machine's environment matches what the code expects is not a fix, it's a machine-specific accommodation that breaks the moment anyone else runs the same code on a different setup. Change the code to accept what the platform actually provides instead.

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

**Non-mutational.** Default to `const`; treat every `let` as a question to answer, not a neutral second option. If a binding needs to be reassigned, find out why before accepting it: either it fits one of the two patterns below and should be rewritten as an expression, or it's a real, narrow exception, like the async cancellation signal further down, not a default reached for out of habit. Prefer expressions that produce new values over statements that mutate existing containers. Use ternaries and object spread instead of initialising an object and conditionally filling it:

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

**What this targets: accumulation as a substitute for computation, not every mutable binding.** Both examples above build a value through iteration or conditional steps that a pure expression could instead produce directly; that's the property the rule is actually about, not "no `let` ever gets reassigned." A mutable signal recording whether an event already happened across an async boundary, a cancellation flag set once inside a cleanup function or effect teardown, isn't accumulating a value at all: there's no expression that could produce "did this get cancelled before the request resolved" ahead of time. This is a real exception, not a loophole, but a narrow one: only reach for it once the underlying dependency's actual cancellation support has been checked and genuinely found absent, the same capability-verification discipline "Dependency version verification" below already requires before concluding a package lacks a feature. If a cancellation primitive exists (an `AbortSignal`, a cancellation token), use it instead of a flag.

**Optional automated enforcement:** ESLint's `prefer-const` rule catches the mechanical half of this, a `let` that's never actually reassigned, but it is not part of `eslint:recommended` and needs enabling explicitly (`"prefer-const": "error"`). It can't judge the harder half, whether a genuinely-reassigned `let` is accumulation-as-computation or a legitimate exception, that's still the judgment call this section describes. Per "Library awareness" below, surfacing it as an option, not a requirement: some projects may already run a stricter style-guide config (Airbnb and similar) that includes it.

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

## Explicit return types

Declare return types explicitly on named or declared functions. Anonymous functions passed as arguments (a callback, a `.map`/`.filter` predicate) may omit them: the surrounding context already constrains the type, and annotating every inline lambda adds noise without adding safety.

## TSDoc for exported symbols

All functions, types, and interfaces exported from a module require a brief TSDoc comment. One or two sentences is enough: state the contract or a non-obvious behaviour, not what the name already says. For types with multiple fields, add inline `/** */` member comments on the non-obvious ones.

This is distinct from the general "no comments" rule above, which applies to inline implementation code. TSDoc is documentation for library consumers, not internal readers.

Apply when writing new exports. When touching existing exports that lack TSDoc, add it in scope if quick; otherwise log it as tech-debt.

## Scope discipline

Stick to the stated scope. For design weaknesses, type flaws, or improvement opportunities noticed along the way: surface them verbally, then document them in `.dev/tech-debt.md` (or ask where that is). "Known issues" visibility is preferred over silent omission.

If a scope-adjacent issue is small enough to fix in place without meaningful risk or scope expansion, fix it immediately rather than logging it. Tech-debt entries are for genuinely deferred work: something too large, too risky, or explicitly out of scope to address now. A one-line fix does not need a ticket.

Don't add features, refactor, or introduce abstractions beyond what the task requires. Don't design for hypothetical future requirements. Three similar lines is better than a premature abstraction.

## Library awareness

When a well-established library would do more thorough work than a hand-rolled solution, surface it as an option with a brief explanation. Let the developer decide: they may learn something useful from it regardless of whether they adopt it.

## Dependency version verification

When introducing a new dependency, always check the current version against the registry before writing it into any config file. Run `npm view <package> version` (or the equivalent for your package manager) to confirm the version is current.

Do not produce version strings from training data, and do not treat "already used in this repo" as implicit endorsement of currency: the existing version may itself be stale. "Consistent with existing" and "current" are separate checks; run both.

Also check for version conflicts before writing: run `npm why <package>` (or equivalent) to see what versions of that package and its close deps are already in the tree. If the new version brings in sub-dependencies that conflict with existing ones, especially native platform packages that package managers hoist into shared locations: flag the conflict before committing the change.

**Evaluating whether a package already has a capability is the sibling case to introducing one.** `latest` is one dist-tag among several; a maintainer can ship current work under a pre-release tag (`next`, `rc`, `beta`) without promoting it. Concluding a package lacks a feature because it's absent from `latest` is the same stale-assumption pattern above, applied to capability instead of version. Run `npm view <package> dist-tags` (or equivalent) before concluding a capability doesn't exist yet, especially when evaluating a migration or a dependency swap.

**A wrapper's current type signature is not proof the underlying dependency lacks a capability either.** A first-party abstraction (a fetch wrapper, a client class) can simply not yet expose a parameter its underlying library already supports; concluding "no cancellation support" from the wrapper's own signature, without checking what the dependency it actually calls into accepts, is the same stale-assumption pattern as the dist-tag case above, one layer removed. Confirmed directly: a boolean cancellation flag was proposed as necessary because a fetcher wrapper's type signature had no `AbortSignal` parameter; the HTTP client it called into underneath (axios, already a dependency) supported `signal` natively the whole time, and widening the wrapper to pass it through removed the hand-rolled flag entirely in favour of real cancellation. Check the dependency actually being called, not just the current shape of whatever wraps it, before concluding a capability doesn't exist.

## Verifying dated or versioned external facts

Training data has a cutoff, and a fact that carried an explicit version or date when you learned it may be stale by now, or may have been superseded since. This is intractable to solve in general: you cannot re-verify everything you know. It's tractable exactly when two things are both true: the fact carries an explicit, checkable version or date marker (a named standard's edition, a spec revision, a changelog), and checking it is cheap, one fetch, not a research project.

When both hold and the fact is about to be actively cited or applied, not just background context, verify it against the authoritative current source first, rather than defaulting to whatever edition or version training data implies. A standing "always verify the current edition" reminder isn't enough on its own to make this fire: it's the same failure mode a passive dispatch citation has (see `convention-levels.md` § "The reference has to be an instruction, not a citation"). Tie the check to the specific moment a versioned fact is about to be used, not to remembering a general reminder.

"Dependency version verification" above is one instance of this (npm package versions, checked against the registry); it's the same underlying rule, scoped to one kind of source.

**Concrete trigger:** naming or applying a specific OWASP Top 10 edition or year is exactly this case, see `security.md` and `security-guidelines.md`.

**Applies to your own tooling, not just external dependencies.** A documented feature or capability of your own harness that seems unavailable in the current environment is the same kind of versioned fact: check whether the harness itself needs an update, or whether the capability is gated behind a version, before concluding it's an architectural limitation. Confirmed directly: cross-session messaging was diagnosed as unavailable in a given environment, reasoning from a plausible but unverified theory about the hosting architecture, when a pending client update was the simpler, correct explanation and hadn't been checked first.

## Searching before writing

Before implementing something new, search the codebase for existing patterns first. Use `grep` or semantic search to find similar implementations: this keeps the codebase consistent and surfaces reusable utilities before they get duplicated.

For the specific case of adding new configuration-dependent functionality, see "Matching existing configuration entry points" above: the same habit, applied to finding an existing config-resolution mechanism rather than an existing utility function.

**The same habit applies to debugging, not just writing new code.** When stuck on a problem that a system's other, similar parts may have already solved, a working sibling instance (another service in the same cluster, another module handling the same class of input, another environment with the same constraint) is ground truth, faster and more reliable than re-deriving the answer from first principles. Look for one before diagnosing in isolation.

## Structured logging

Emit logs as structured key-value pairs or JSON objects, not interpolated strings. Include a consistent set of fields: timestamp, severity, event type, actor identity where known, resource identifier, outcome. Do not log secrets, credentials, or PII in log values.

Apply from the start of any feature involving:
- Authentication, authorization, or access control decisions
- Permission changes or administrative actions (must always be logged as auditable events)
- Data access, downloads, or exports
- Errors, failures, or unexpected states at system boundaries

Set up structured logging before writing application logic, the same way you set up a test runner before writing tests. It is not optional plumbing.

**Baseline justification: OWASP A09 (Security Logging and Alerting Failures)**, see `security-guidelines.md` § A09. The value extends past security, though: structured logs are machine-queryable and are the foundation for any audit trail, not just a security control.

## Property ordering

Alphabetize properties within objects and mappings in config files (YAML, JSON, etc.) at all nesting levels: scalars and block properties interleaved together, not split by type. This prevents silent duplicate key overwrites and makes additions easier to place consistently.

**This applies to code, not only config files.** Alphabetize the properties of an object literal, the fields of a `type`/`interface`, and the names in a destructured parameter (`{ a, b, c }: Params`), the same way and at every nesting level. A plain positional argument list is unaffected: its order comes from the function signature, not from sorting. This rule is about named fields, not every list.

**Exception: key order that's semantically meaningful.** Doesn't apply where the order itself is part of the meaning: a reducer's accumulator, an enum-like object whose entries represent an intentional sequence (pipeline steps, ordered states). Alphabetizing there would destroy something deliberate, not leave an arbitrary order unsorted. This is about named fields with no inherent order of their own, not every object.

**And to markdown reference documents with named per-item sections**, not just code or config: a project map's `### project-name` headings, a glossary's terms, anything enumerating discrete named entries. Same reasoning as config keys: scanning for whether an entry already exists, and knowing where a new one belongs, both get harder without it. A prose document that isn't enumerating named items (a narrative walkthrough, an ordered set of steps) isn't affected: this is about named-entry lists, not every heading in existence.

Apply when writing new content, config or code. When editing existing files, fix ordering within the sections being touched. When inserting a new key, resource block, or field into an existing structure, place it at its alphabetical position: not at the current edit point, not at the end.

**Watch for drift across a multi-step task.** Alphabetization is easy to get right in isolation and easy to lose when a field gets bolted onto an existing object mid-task (new key appended at the end instead of inserted in place) or when the same shape gets copy-pasted across several call sites (one gets fixed, the copies don't). Before treating a multi-file change as done, sweep back over every object literal, type, and destructured parameter it touched, not just the one you were looking at when you added the field.

**The mechanism, confirmed first-hand by the session it happened to rather than inferred: you copy an adjacent line for its form and inherit its position.** You are looking at what the line *is*, and position is not a property of a line: it is a property of where it sits relative to its neighbours, which you are not looking at. So the incidental rides in unexamined, and the copy even supplies its own justification, since "matching the existing pattern" is true of the form and false of the placement. Reported by a session that said exactly that to its developer while offering the wrong thing as the reason.

**That also explains the conditional-spread correlation better than syntax noise does.** A conditional spread is fiddly enough that you copy a neighbouring one rather than writing it out, so the syntax difficulty causes the copying and the copying causes the position inheritance. The risk is not that the shape is hard to eyeball; it is that you never wrote it in the first place.

**Conditional spreads are a higher-risk spot for exactly this drift.** A shape built with `...(condition ? { key } : {})` mixed with plain keys is harder to eyeball for correct position than a flat literal, since checking order means mentally stripping the spread syntax first. This matters most for output an external reader or system actually scans (an API response body, a persisted structure), not just a maintainer's own read: nothing catches a misplaced key there beyond someone noticing the output looks wrong.

**Optional automated enforcement:** [`eslint-plugin-perfectionist`](https://npmjs.com/package/eslint-plugin-perfectionist) has autofixable rules for exactly this (`sort-objects`, `sort-interfaces`, `sort-object-types`, among others) and can catch what manual review misses. Surfacing it here as an option per `code-style.md` § Library awareness, not a requirement: check its current version against the registry before adopting, and confirm which of its rules cover destructured parameters versus plain object literals before relying on it as the sole enforcement mechanism.
