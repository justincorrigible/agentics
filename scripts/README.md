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

## Conventions for scripts here

- Take the target as an argument, with a sensible default, so the script is testable against a fixture rather than only against real state
- Exit non-zero on a hard error, zero on informational output, so a caller can branch on it
- Print what was checked even when nothing is wrong: silence is indistinguishable from not having run
- Never write to the file being checked. These report; the agent and the developer decide
