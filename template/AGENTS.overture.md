<!-- agentics-template-version: see CHANGELOG.md § Released (latest entry) -->
# Overture project conventions

This file is an addendum to `AGENTS.md`/`CLAUDE.md`, applied when project memory confirms this is an Overture project (`https://github.com/overture-stack`). Do not include credentials, private cluster endpoints, or secrets here: ever.

## How this file is used

The initialization block in `AGENTS.md` records Overture-project status in project memory on the first session. Subsequent sessions read the flag and load this file at session start.

---

## Links in `docs/`: match the link's form to where its target actually lives

`docs.overture.bio` symlinks in only each repo's `docs/` subtree, not the rest of the repo. Three cases, not two:

- **Same-repo, inside `docs/`:** a relative path. Resolves whether the file is read standalone (GitHub, a local clone, an IDE) or through the aggregated site, since Docusaurus resolves relative markdown links against the file's own location too.
- **Another Overture product's published docs page:** a full `https://docs.overture.bio/docs/...` URL. A relative path can't reach across repos at all; a GitHub URL here is the wrong target even though it's a real URL, it shows raw markdown source instead of the rendered page.
- **Anything never published on the aggregator at all** (a module README outside `docs/`, `.dev/docs` content, anything outside the symlinked subtree, same repo or not): the `https://github.com/overture-stack/<repo>/blob/main/...` form.

Links *into* `docs/` from outside it can stay relative regardless of which case above the target is: the file doing the linking isn't published on the aggregator either way, so only its GitHub/local rendering matters, and that always resolves the whole repo tree.

**Diagnostic:** for any internal-looking link, would it resolve if this exact file were opened with zero other context, just this repo, on GitHub? A same-`docs/` relative link passes trivially. Anything reaching `docs.overture.bio` or GitHub needs the full URL, verified against the aggregator's actual routing (`docusaurus.config.ts`, the symlink script) rather than assumed from memory or convention: routing and content can drift independently. Confirmed directly (2026-07-30): `overture/docs`'s own symlink script no longer matches what's actually checked out, and its Docusaurus config has broken-link checking set to warn, not fail, so this class of break isn't caught by CI at all.

**Check for these specifically when reviewing `docs/` content in an Overture repo**, real instances have already shipped: a same-`docs/` link missing its file extension or otherwise broken (`[Code & Archeticture](tech)` in Maestro's `docs/index.md`, also a typo in the link text itself); inconsistent casing on what looks like the same target across repos (Arranger links `.../quickstart`, Stage links `.../Quickstart`), worth confirming both actually resolve rather than assuming one is simply a style choice.

## Cross-project map: expected, not just offered

Overture is inherently multi-repo (SONG, Lyric, Maestro, Arranger, `stage`, `conductor`, `usher`, `docs`, plus infra/helm-charts repos all interrelate); working in one without visibility into the others is the common case, not the exception `AGENTS.md` § Initialization's generic "if the user works across multiple projects" framing assumes. If no cross-project map exists yet in your global context, offer to set one up now (see `global-context/projects.md` in the agentics template) rather than waiting for that generic signal. If one already exists, check that this project and other Overture repos you're aware of on this device are actually listed in it, not just present somewhere in principle.
