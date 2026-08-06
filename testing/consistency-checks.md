# Consistency checks

The mechanical parts of `CONTRIBUTING.md` § Proposing changes, agent-neutrality, personal-info leaks, and dispatch-table/file-table agreement, are grep-based checks already, just scattered across a manual checklist that has to be remembered and run by hand each time. `scripts/check-consistency.sh` consolidates them into one command. It is not a test suite: it doesn't understand meaning, it can't tell you a convention is well-written. It catches the same class of drift a read-through misses, the same reason the individual greps existed before this script did.

## Running it

```bash
./testing/scripts/check-consistency.sh
```

Run it before every commit, not just at release time.

## What it checks

1. **Agent-neutrality**: every `~/.claude` or "Claude Code" hit anywhere under `template/`, printed for review. This one can't be auto-cleared: whether a hit needs a `(for Claude: X; for other agents: Y)` parenthetical or already has a genuinely Claude-only reason takes judgment per line, the script surfaces candidates, it doesn't decide.
2. **Orphaned convention files**: every `template/conventions/*.md` file has both a dispatch line inside `template/AGENTS.md`'s "When to read what" *table specifically* and a row in `template/README.md`'s file table, not just a mention anywhere in either file. Catches the exact gap that made `security.md`'s pnpm guidance, `documentation.md`, and `upgrading-adoption.md` briefly unreachable after being added.
3. **Personal-info leaks in the diff**: your OS username, git identity, or a personal fork remote name appearing in currently-staged, -modified, or untracked-but-new files. A fresh session file counts: it's untracked until first staged, and is exactly where a name is most likely to leak. Scoped to *your own* identity markers, known in advance. It cannot catch a third party's name typed while narrating an incident someone else reported, since that name isn't known until it's written. See `session-discipline.md` § Name code, not people for why that stays a judgment call.
4. **Root/template `AGENTS.md` drift**: the two sections get different treatment, confirmed by running a real content diff against each. "Interaction parameters" gets a real content diff, since a bullet-count match can still hide real wording drift: that happened once, "baked in" vs "baked into code", same count, different text. The one known intentional difference there, template's "agentics' `CHANGELOG.md`" pointer, is normalized away first. "Critical constraints" keeps a looser bullet-count heads-up instead, on purpose, since its content is *meant* to diverge. Root's is repo-specific: agentics has no library code but does need "we're the upstream source, keep this public-safe." Template's is generic-adopter: it needs the environment-isolation rule a real project's library code needs. A strict diff there would just be permanent, unfixable noise.
5. **Dispatch-table disambiguation safeguard**: confirms `template/AGENTS.md`'s "When to read what" still states its `conventions/*.md` paths are live pointers, not local copies, the sentence that closed `global-guideline-material-never-in-project`. Narrow on purpose: it only catches that specific sentence going missing, not bare relative paths generally (too fuzzy to check mechanically without a lot of false positives).
6. **No AI-tool attribution in commit messages**: scans commits ahead of the configured upstream (or just `HEAD` with none configured) for `Co-Authored-By`, `Generated with`, or similar trailers, and fails the check if found, the mechanical backstop for `session-discipline.md`'s "No AI-tool attribution in commits or PRs" rule. Scoped to unpushed commits on purpose: a pushed commit is history to fix separately (an amend or a follow-up), not something a pre-commit-style check can catch usefully.
7. **Near-duplicate `regression-checklist.md` entries**: a word-overlap heuristic (not semantic) flagging two entries that likely describe the same incident, e.g. two concurrent sessions each adding their own entry for the same fix, which happened once. Heads-up only, never fails the script: it's a similarity score, not proof. False positives are expected on entries that just share domain vocabulary. Requires `python3`. Skips silently if it isn't on `PATH`.

What it does *not* check: whether a convention is unambiguous, whether a dispatch table entry is correct once copied into a different project, or anything requiring actual judgment. That's what `fixtures.md` and `cold-read-review.md` are for.
