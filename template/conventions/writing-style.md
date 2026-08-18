# Writing style conventions

Conventions for producing any written output, code or not: a doc update, a ticket, a commit message, a PR comment, a config file. Distinct from `code-style.md`, which covers implementation-specific conventions (comments, TypeScript patterns, module design) that only apply when writing code. Everyone reads this file; only developers additionally need `code-style.md`.

## Language and typos

Flag typos and language issues when spotted: in code, comments, and documentation. Don't fix silently; call them out so the user can decide.

## Addressing the user

When your agent's global context records the user's name (or preferred name), use it in conversational replies and visible reasoning ("thinking out loud") rather than the generic third-person "the user": a name is more natural than a label for someone actually present in the conversation. When no name is known, prefer direct second-person address ("you") over "the user"; "the user" is the last-resort fallback, not a neutral default, since it reads as clinical distance when addressing someone directly rather than describing them to a third party.

This applies to live, ephemeral output only: replies and visible reasoning. It does not apply to persisted, checked-in content: `session-discipline.md` § "Name code, not people" already requires the opposite there (attribute to features and systems, not individuals), regardless of how well the person's name is known in conversation. The two don't conflict: a live reply can use a name directly, while that same work's session-file entry still describes what changed, not who asked.

## Dashes

Never use em dashes, en dashes, double hyphens as dash substitutes, or space-hyphen-space as sentence connectors in any output: documentation, code comments, persisted files, or conversational messages. This applies to all text content without exception. Acceptable uses are structural items that are not part of the prose itself: bullet markers (`-`), horizontal dividers (`---`) and markdown table separator rows (`|---|---|`), compound-word hyphens (`well-designed`), and numeric ranges (`1-2 entries`).

Do not use in text:
- Em dashes (`—`, U+2014)
- En dashes (`–`, U+2013)
- Double hyphens (`--`) as a dash substitute
- Space-hyphen-space (` - `) as a sentence connector

For mid-sentence connectors, use a semicolon or rephrase. For inline annotations in bullets (`.dev/sessions/` entries, `roadmap.md`, etc.), use `: ` as the separator: `` `path/to/file`: what changed ``. In titles and headings, use a colon rather than a dash separator: "OWASP Top 10: Quick Reference", not "OWASP Top 10 — Quick Reference".

When correcting existing em dashes across a file, use `sed -i '' 's/ — /: /g'` and verify with `grep -c '—'`.

**Before any output leaves your control, run a mechanical check against the exact final text and confirm zero matches: `grep -c '—\|–'`.** Do this as a discrete action right before the send, post, or commit, not as background awareness carried from having read this section earlier in the session. This recurred in practice even after being added as a personal refinement in one contributor's own global context: it survived a single output but not a multi-step task (drafting several PR comments in a row), since the rule was read once, early, and the check itself was never re-invoked partway through. A rule stated as absolute needs a mechanical, testable action tied to it, not a description trusted to stay salient on its own.

## Spelling and language convention

[Team placeholder: configure your preferred spelling convention here. Example: Canadian English uses `-our` suffixes (colour, behaviour), `-re` suffixes (centre, fibre), `-ize` (not `-ise`), and `-yze` (analyze, paralyze; unlike the -ise/-ize split, Canadian does not diverge from American here).]

## Property ordering

Alphabetize properties within objects and mappings in config files (YAML, JSON, etc.) at all nesting levels: scalars and block properties interleaved together, not split by type. This prevents silent duplicate key overwrites and makes additions easier to place consistently.

**This applies to code, not only config files.** Alphabetize the properties of an object literal, the fields of a `type`/`interface`, and the names in a destructured parameter (`{ a, b, c }: Params`), the same way and at every nesting level. A plain positional argument list is unaffected: its order comes from the function signature, not from sorting. This rule is about named fields, not every list.

**Exception: key order that's semantically meaningful.** Doesn't apply where the order itself is part of the meaning: a reducer's accumulator, an enum-like object whose entries represent an intentional sequence (pipeline steps, ordered states). Alphabetizing there would destroy something deliberate, not leave an arbitrary order unsorted. This is about named fields with no inherent order of their own, not every object.

**And to markdown reference documents with named per-item sections**, not just code or config: a project map's `### project-name` headings, a glossary's terms, anything enumerating discrete named entries. Same reasoning as config keys: scanning for whether an entry already exists, and knowing where a new one belongs, both get harder without it. A prose document that isn't enumerating named items (a narrative walkthrough, an ordered set of steps) isn't affected: this is about named-entry lists, not every heading in existence.

Apply when writing new content, config or code. When editing existing files, fix ordering within the sections being touched. When inserting a new key, resource block, or field into an existing structure, place it at its alphabetical position: not at the current edit point, not at the end.

**Watch for drift across a multi-step task.** Alphabetization is easy to get right in isolation and easy to lose when a field gets bolted onto an existing object mid-task (new key appended at the end instead of inserted in place) or when the same shape gets copy-pasted across several call sites (one gets fixed, the copies don't). Before treating a multi-file change as done, sweep back over every object literal, type, and destructured parameter it touched, not just the one you were looking at when you added the field.

**Conditional spreads are a higher-risk spot for exactly this drift.** A shape built with `...(condition ? { key } : {})` mixed with plain keys is harder to eyeball for correct position than a flat literal, since checking order means mentally stripping the spread syntax first. This matters most for output an external reader or system actually scans (an API response body, a persisted structure), not just a maintainer's own read: nothing catches a misplaced key there beyond someone noticing the output looks wrong.

**Optional automated enforcement:** [`eslint-plugin-perfectionist`](https://npmjs.com/package/eslint-plugin-perfectionist) has autofixable rules for exactly this (`sort-objects`, `sort-interfaces`, `sort-object-types`, among others) and can catch what manual review misses. Surfacing it here as an option per `code-style.md` § Library awareness, not a requirement: check its current version against the registry before adopting, and confirm which of its rules cover destructured parameters versus plain object literals before relying on it as the sole enforcement mechanism.
