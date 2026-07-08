# Documentation structure

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
