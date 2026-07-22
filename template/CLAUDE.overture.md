# Overture project conventions

This file is an addendum to `AGENTS.md`/`CLAUDE.md`, applied when project memory confirms this is an Overture project (`https://github.com/overture-stack`). Do not include credentials, private cluster endpoints, or secrets here: ever.

## How this file is used

The initialization block in `AGENTS.md` records Overture-project status in project memory on the first session. Subsequent sessions read the flag and load this file at session start.

---

## Links in `docs/`: absolute GitHub URLs for anything outside `docs/`

`docs.overture.bio` symlinks in only each repo's `docs/` subtree, not the rest of the repo, so a relative link from a `docs/` file to anything outside `docs/` (e.g. `../../modules/sqon/README.md`) 404s on the published site even though it resolves fine on GitHub or locally. Links between two files both inside `docs/` can stay relative. Links from outside `docs/` into `docs/` can also stay relative, since GitHub and local viewing both resolve the whole repo tree; the constraint is one-directional. Use the `https://github.com/overture-stack/<repo>/blob/main/...` form for anything crossing out of `docs/`.

## Cross-project map: expected, not just offered

Overture is inherently multi-repo (SONG, Lyric, Maestro, Arranger, `stage`, `conductor`, `usher`, `docs`, plus infra/helm-charts repos all interrelate); working in one without visibility into the others is the common case, not the exception `AGENTS.md` § Initialization's generic "if the user works across multiple projects" framing assumes. If no cross-project map exists yet in your global context, offer to set one up now (see `global-context/projects.md` in the agentics template) rather than waiting for that generic signal. If one already exists, check that this project and other Overture repos you're aware of on this device are actually listed in it, not just present somewhere in principle.
