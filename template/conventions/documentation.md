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

## Two-tier model

Projects that publish docs externally use two distinct documentation layers:

- `/docs`: What a consumer of the project needs to install, configure, and use it. Published to the project's external docs site (e.g. Docusaurus, GitHub Pages).
- `.dev/docs`: Internal design rationales, architecture decisions, and implementation guides for contributors. Lives in the repo but is not published externally.

Neither layer is optional for projects with external users. Docs that only exist in `.dev/docs` are invisible to operators and integrators; docs that belong in `.dev/docs` but land in `/docs` bloat the consumer-facing surface and dilute clarity.

## Cross-linking, not duplication

When a topic needs both a consumer-facing summary and internal depth, keep the full explanation in one location and cross-link from the other. Duplication creates drift: two descriptions of the same behaviour will disagree.

Which location is primary depends on the intended audience:

| Topic type | Primary location | Cross-link direction |
| --- | --- | --- |
| Operator-facing config, permissions, setup | `/docs` | `.dev/docs` → `/docs` |
| Startup sequence, internal call graph, implementation rationale | `.dev/docs` | `/docs` → `.dev/docs` |
| A feature with observable behaviour and non-trivial internals | Split: surface in `/docs`, depth in `.dev/docs` | both cross-link |

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
