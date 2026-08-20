# scripts

Mechanical checks that **agents run**, against a developer's own context or an adopting project.

Distinct from `testing/`, and the line matters:

| | `testing/` | `scripts/` |
|---|---|---|
| Audience | agentics contributors | any agent following the conventions |
| Subject | agentics' own files | the developer's global context, or an adopting project |
| Copied to adopters | never | never, run from the agentics clone |
| Runs when | pre-commit in this repo | when a convention says to |

Both are run from the agentics clone rather than copied, for the same reason `conventions/` is a live pointer: a copied checker goes stale silently, and a stale checker is worse than none because it reports "ok" about rules that have since changed.

**A script here is only worth adding if a convention tells someone to run it.** A checker nobody is instructed to invoke is a rule that depends on memory, which is the failure mode `docs/deterministic-by-design.md` exists to remove. Add the convention line in the same change as the script.

## Available

| script | checks | convention that calls it |
|---|---|---|
| `check-agent-index.sh` | ownership registry integrity: duplicate paths, absolute paths, leftover schema, and the resolution tree | `conventions/agent-index.md` § Registering and changing ownership |

### `check-prune-ratio.sh`

```
./scripts/check-prune-ratio.sh              # compares HEAD against origin/main
./scripts/check-prune-ratio.sh <base-ref>   # or any base you name
```

**Only useful if your project accumulates convention or documentation text over many small changes.** It answers one question: has anything been removed lately, or has the corpus only grown. It reports the insertion and deletion counts across `template/` and `docs/`, and exits non-zero when a batch has grown past a threshold and no pre-existing file got smaller.

It measures whether a pruning pass ran, never whether one was needed. That distinction is the whole design: deciding what to cut requires judgement no script has, while whether anything was cut is arithmetic. A newly added file is excluded from the shrink test, since having no deletions says nothing about it.

Written because this repository's own release procedure had required a simplification pass for many releases in prose alone, and it had never once been executed. Run it from a hook rather than by hand if you want it to matter; a check you have to remember is subject to the failure it exists to catch.

## Conventions for scripts here

- Take the target as an argument, with a sensible default, so the script is testable against a fixture rather than only against real state
- Exit non-zero on a hard error, zero on informational output, so a caller can branch on it
- Print what was checked even when nothing is wrong: silence is indistinguishable from not having run
- Never write to the file being checked. These report; the agent and the developer decide
