# Documentation

## Writing for a cold reader

Documentation written during or right after a live design discussion inherits that discussion's register: dense, backward-referencing, one sentence doing the job of a paragraph. That register works for whoever was in the room. It actively works against anyone reading the document cold, which is the actual audience most documentation is for.

This is a register problem, not an information-density problem: the same content, restructured, reads in one pass.

**Dense (backward-referencing):**
> This is a deliberate correction, twice over: an earlier draft passed the retry count as one mutable counter shared across call sites, which meant two unrelated failures could double-count against the same limit; switching to a per-call token avoids that, and also sidesteps the race condition flagged in review, which is exactly the kind of coupling this refactor exists to remove.

**Plain, same information:**
> Draft 1 passed the retry count as one shared mutable counter. Two unrelated failures could double-count against the same limit.
>
> Fix: one token per call. No shared state, nothing to race on.

The second reads in one pass because it separates what happened from why it matters, and drops throat-clearing ("a deliberate correction, twice over") that only makes sense to someone who already knows the history.

**Rules:**

- **One idea per sentence.** A sentence with a semicolon joining two independent claims, or two or more parenthetical asides, should usually be split.
- **State the conclusion first**, in a short sentence or a bold lead-in label ("Why this changed:", "The math:"). Justification and caveats come after it, not wrapped around it.
- **Never reference "the earlier version" or "as discussed" without restating what it said**, right there, in one plain sentence. A reader who was not in the room cannot resolve that reference.
- **Give worked examples their own block**: a short list or a code snippet, not inline prose math or a parenthetical.
- **Minimize forced cross-reference chains.** If understanding one paragraph requires reading two other sections first, inline the minimum context instead.

**Where this applies:** design docs, tech-debt entries, roadmap items, anything a reader outside the conversation that produced it will read cold.

**Where it does not:** `.dev/sessions/` logs, which are correctly terse by `session-discipline.md` § Session file entry format: a historical record for someone already oriented, not a first introduction to the topic. Loosening that convention would be the wrong fix for a different problem.

## Rewrite freely until committed

Uncommitted content, in any file, is a draft: rewrite it in place as understanding changes, don't layer a new note on top documenting the change from the old one. This applies to README updates, `/docs` and `.dev/docs` pages, tech-debt entries, roadmap items, and CHANGELOG's `## Unreleased` section.

The failure has two depths, not one. A chain of `X → Y`, `Y → Z`, `Z → A` notes is the shallow version: it documents the note's own edit history instead of stating `A` once. The deeper version survives even without chaining: a single, unchained note still mentioning `X` is noise if `X` never existed in any committed or shipped state, since no reader could ever encounter it. A document whose job is describing current design or a current bug (a roadmap rationale, a tech-debt issue, a convention) gains nothing from "this field used to be called `reason`" when nothing ever shipped under that name.

**The test:** would the sentence stay true and useful to someone who only ever sees the current, merged state? If not, and the earlier value never shipped, cut the reference entirely, not just the chained instances of it.

**Example:**
> Draft note: "renamed the handler to `processRequest`."
> The same still-uncommitted work renames it again, to `handleIncoming`, before anything ships.
>
> Correct: "the handler is `handleIncoming`."
> Wrong, chained: "further renamed `processRequest` to `handleIncoming`."
> Wrong, still noise even unchained: "renamed the handler from `processRequest` to `handleIncoming`." Nothing ever shipped as `processRequest`, so a reader gains nothing from being told it once existed.

Once content is committed, git history is the record of how it got there. Before that point, the file's job is to state the current fact, not preserve a draft's own revision log.

**Exception: a document whose entire job is recording change.** A CHANGELOG entry, a migration guide, a PR description: there, "renamed X to Y" is the point, not noise, since the "before" state is something a reader or their deployed instance may actually have been running against. This exception is narrow: artifacts whose stated purpose is documenting a transition for someone on the other side of it, not roadmap items, tech-debt entries, or convention prose describing current design.

**Exception: session files close earlier, at day's end, not at commit.** `session-discipline.md` § "Collapse iteration to outcome" applies this same principle to `.dev/sessions/` entries, but with a stricter boundary than "uncommitted": a session file is meant to be an honest same-day account, so it stays open only while that day's work continues, even if it happens to remain uncommitted for days afterward (nothing requires committing same-day). See that section for the full reasoning. This is a narrower exception, not a looser instance, of the rule above.

## Two-tier model

Projects that publish docs externally use two distinct documentation layers:

- `/docs`: What a consumer of the project needs to install, configure, and use it. Published to the project's external docs site (e.g. Docusaurus, GitHub Pages).
- `.dev/docs`: Internal design rationales, architecture decisions, and implementation guides for contributors. Lives in the repo but is not published externally.

Neither layer is optional for projects with external users. Docs that only exist in `.dev/docs` are invisible to operators and integrators; docs that belong in `.dev/docs` but land in `/docs` bloat the consumer-facing surface and dilute clarity.

`.dev/docs` itself is often already populated by a project before any of these conventions arrive, service folders a human contributor set up and organizes their own way. None of what follows applies to that pre-existing content, or requires reorganizing it: see "The atlas" immediately below for the one subfolder these conventions actually govern.

## The atlas: `.dev/docs/atlas/`, indexed and cross-linked

Agent-generated reference material (a lessons-learned write-up, a roadmap entry's relocated depth) accumulates unpredictably over time in a way pre-existing per-service docs don't: nothing guarantees it lands anywhere navigable on its own. Give it its own subfolder, `.dev/docs/atlas/`, rather than mixing it into whatever a project already has directly under `.dev/docs`: this keeps existing human-curated service docs completely untouched, no retroactive index or cross-linking requirement gets imposed on content that predates this and was never meant to carry it.

Maintain `.dev/docs/atlas/index.md`: one line per topic, name and a one-sentence description, the same shape `MEMORY.md` already uses for project memory. Create it the moment the first atlas topic file is added, and update it the moment any later one is, not batched for later; don't leave "do I need one yet" as a judgment call.

Within an atlas topic file, link to a genuinely related one with a normal relative markdown link (`[roadmap: nesting config](../roadmap/nesting-config.md)`), not a special syntax: unlike project memory, `.dev/docs` files live in the same repo at stable paths, so an ordinary link already works and stays clickable in the repo browser and on GitHub. Link liberally when a real relationship exists; don't force a link where there isn't one just to make the corpus look more connected than it is.

**Live-investigation output needs a draft step before it reaches the atlas, not a direct write.** A number just pulled from a live server, a specific example not yet checked for whether it's actually representative, still-unverified findings from an active investigation: writing these straight into `.dev/docs/atlas/` risks committing half-settled, over-specific material to a permanent artifact. Confirmed directly: a depth count and a schema's specific field names both went straight into permanent atlas content before being verified, each needing a multi-file surgical correction once the investigation actually settled and proved the first version wrong. Stage genuinely unverified investigation output as a draft in project memory space instead (`<project-memory-dir>/drafts/*.md`; never indexed in `MEMORY.md`, so it's never auto-loaded into context), then promote it, verified and appropriately genericized, into the atlas once the investigation is settled, replacing the draft rather than leaving both. This is for output still being actively verified, not routine writing: an already-confirmed fact goes directly into the atlas as normal, no staging needed.

**Roadmap depth lives here too, not just service docs.** `.dev/docs/roadmap/<topic>.md` is where a roadmap entry's deeper reasoning, alternatives considered, or history goes once it needs more than a sentence or two, the same pointer-versus-substance split `definition-of-done.md`'s lessons-learned criterion already applies to memory versus `.dev/docs`, now applied to `roadmap.md` itself. See `session-discipline.md` § Keeping `.dev/` current for when this split is actually in effect for a given project: it's opt-in, not a default.

## Cross-linking, not duplication

When a topic needs both a consumer-facing summary and internal depth, keep the full explanation in one location and cross-link from the other. Duplication creates drift: two descriptions of the same behaviour will disagree.

Which location is primary depends on the intended audience:

| Topic type | Primary location | Cross-link direction |
| --- | --- | --- |
| Operator-facing config, permissions, setup | `/docs` | `.dev/docs` → `/docs` |
| Startup sequence, internal call graph, implementation rationale | `.dev/docs` | `/docs` → `.dev/docs` |
| A feature with observable behaviour and non-trivial internals | Split: surface in `/docs`, depth in `.dev/docs` | both cross-link |

**The same principle, across repos:** when another repo or team asks how to migrate onto or adopt a package you maintain, point them at that package's own docs or README directly rather than writing a bespoke explanation. Its docs are the canonical source, kept in sync with the package itself; a one-off explanation given elsewhere is a second copy that goes stale the moment the package changes without a matching update to what was said.

## Linking from `/docs` to `.dev/docs`

Any link from a `/docs` page to a `.dev/docs` file must use the full GitHub repository URL, not a relative path:

```markdown
<!-- correct: works from the published docs site and the repo browser -->
[search engine integration guide](https://github.com/org/repo/blob/main/.dev/docs/search-engine-integration.md#permission-reference)

<!-- incorrect: 404s on the published docs site -->
[search engine integration guide](../.dev/docs/search-engine-integration.md#permission-reference)
```

The external docs site does not have access to the project's `.dev/` directory. A relative path will resolve correctly when browsing the repo locally or on GitHub, but will 404 on any hosted docs site. A full GitHub URL is stable across both contexts.

Use the default branch (`main` or `master`, whichever is the published branch) in the URL, not a commit SHA or feature branch.

## Linking from `.dev/docs` to `/docs`

Relative paths are fine here: `.dev/docs` files are read in the repo context only.
