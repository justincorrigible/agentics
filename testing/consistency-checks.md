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
3. **Personal-info leaks in the diff**: your OS username, git identity, or a personal fork remote name appearing in currently-staged or -modified files.
4. **Root/template `AGENTS.md` drift**: a rough heads-up, not a semantic diff, flags if the two files' "Interaction parameters" or "Critical constraints" sections have a different bullet count, since that's exactly the shape past drift has taken (a missing bullet in one copy). A flag here means read both sections side by side; it doesn't mean the bullets themselves are wrong.
5. **Dispatch-table disambiguation safeguard**: confirms `template/AGENTS.md`'s "When to read what" still states its `conventions/*.md` paths are live pointers, not local copies, the sentence that closed `global-guideline-material-never-in-project`. Narrow on purpose: it only catches that specific sentence going missing, not bare relative paths generally (too fuzzy to check mechanically without a lot of false positives).

What it does *not* check: whether a convention is unambiguous, whether a dispatch table entry is correct once copied into a different project, or anything requiring actual judgment. That's what `fixtures.md` and `cold-read-review.md` are for.
