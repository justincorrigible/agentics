# Code style conventions

## Comments

Default: write no comments. Add one only when the WHY is non-obvious: a hidden constraint, a subtle invariant, a workaround for a specific bug, behaviour that would surprise a reader. If removing the comment wouldn't confuse a future reader, don't write it.

Never explain WHAT the code does; well-named identifiers already do that. Never reference the current task, fix, or callers: those belong in the PR description and rot as the codebase evolves.

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

**Pure helpers.** When a block of logic has a clear input and output (a lookup, a transformation, a format function), extract it as a named function with no side effects. This keeps orchestration code readable and the logic independently testable.

**Derive from data, don't duplicate as a flag.** When a field's value is fully determined by other configuration already present, don't add a separate explicit discriminator (`enabled`, `type`, `mode`) for it: gate behaviour on the presence or content of the data itself. A `type: gateway | ingress | none` field that could instead be "gateway if `gateway.parentRef.name` is set, ingress if `ingress.hosts` is non-empty, neither otherwise" adds a second thing to configure and keep consistent with the first. Applies to Helm values, API schemas, and configuration objects generally: when presence unambiguously implies intent, don't require intent to be stated twice.

Apply these four together: a function composed of pure helpers, positive conditions, non-mutational expressions, and data-derived rather than duplicated flags reads as a series of declarative steps rather than a sequence of instructions.

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

## Property ordering

Alphabetize properties within objects and mappings in config files (YAML, JSON, etc.) at all nesting levels: scalars and block properties interleaved together, not split by type. This prevents silent duplicate key overwrites and makes additions easier to place consistently.

Alphabetize named resource blocks in Terraform files by resource name (the second label, e.g. `"github-metrics"`, `"keycloak"`, `"lectern"`). VSO companion blocks follow their primary resource directly rather than being sorted independently.

Apply when writing new config content. When editing existing files, fix ordering within the sections being touched. When inserting a new key or resource block into an existing file, place it at its alphabetical position: not at the current edit point, not at the end of the file.

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

[Team placeholder: adjust this default if your team has a different commit or staging discipline.]
