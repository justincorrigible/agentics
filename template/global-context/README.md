<!-- agentics-template-version: see CHANGELOG.md § Released (latest entry) -->
# Global context templates

These files are templates for your agent's **personal global context**: configuration that applies across all your projects, not just one.

Copy them to wherever your agent reads global/personal context:

| Agent | Global context directory |
|-------|--------------------------|
| Claude (Claude Code) | `~/.claude/` |
| Others | Consult your agent's documentation |

The agent-neutral convention files under `conventions/` carry the same content for use within a single project. These global-context templates are for users who want the same files accessible across all their projects without copying them into each one.

## Files

- `personal-preferences.md`: universal interaction parameters and critical constraints, agent-neutral, for a developer who wants agentics' behavioral conventions personally without adopting it into any specific project
- `projects.md`: cross-project map: paths, memory locations, and relationships between your projects
- `roadmap.md`: template and convention for global roadmaps, including how to split by work context (professional vs personal)
- `security-guidelines.md`: OWASP-aligned security patterns, threat model, and code review triggers
- `agent-index.md`: opt-in bootstrap for the cross-project agent directory and bulletin board (`conventions/agent-index.md` has the full design)

## Bootstrapping without a project

When a developer asks for personal, global-only setup (e.g. "set up my personal AI collaboration preferences using agentics, global context only"), don't run the project-level initialization flow at all, no `AGENTS.md`, no `.dev/`, nothing created or suggested for committing anywhere:

1. Ask the same role question `template/AGENTS.md`'s initialization uses (developer / bioinformatician / AI engineering / general), and whether they're on the softeng team or working on an Overture project, skipping any already known from existing global context.
2. Copy `personal-preferences.md` above into the developer's own global context file (for Claude Code: merge its sections into `~/.claude/CLAUDE.md`, creating it if none exists yet, additive, don't overwrite unrelated existing content; for other agents: consult your agent's docs for where global/personal instructions live). Replace its canonical pointer tag with an actual snapshot, `<!-- agentics-template-version: X.Y.Z | synced: <commit-sha> -->`, `X.Y.Z` from agentics' latest `CHANGELOG.md` § Released entry, `<commit-sha>` its current `HEAD` at copy time, same as project adoption already does. The SHA is advisory and is expected to stop resolving, since agentics amends its release commit until release; see the root `README.md` § Keeping up to date. The version number is what actually gets compared.

**A deployed copy here is stamped with the version only, no SHA.** "Which release is this" is the whole question for a bootstrap copy, and a version resolves to its release commit by `git log --grep '^Release X.Y.Z'` whenever a diff is actually wanted. A stored SHA would add nothing recoverable while multiplying orphan exposure across every machine the file reaches, since an unpushed commit's SHA changes on every amend. Reported by two adopting sessions who found a commit in this repo that had been rewritten twenty-seven times in a day, one of whom had already stamped it.

**Every file in this directory carries the version tag, and gets stamped on deployment.** A deployed copy in a global context has no other way to know it is stale, and unlike a project file nothing checks it on a schedule: `conventions/upstream-check.md` runs against a project's own `AGENTS.md`, and a copy sitting in `~/.claude/` is outside that entirely. Same class of drift, and until now only one file here had the mechanism.

**A stale copy of one of these does not merely lag, it teaches the practice that was removed.** Reported by an adopting session whose deployed `agent-index.md` still described the runtime-handle address book that `0.18.0` deleted after measuring the harm it caused. An agent reading that file rather than the convention is authoritatively instructed to do the thing the convention forbids, and nothing in the artifact says otherwise. The convention already tells readers not to trust a deployed file's header, which is correct and reaches only the agent that reads the convention; the version tag reaches the one that does not, by making the artifact self-describing rather than relying on the reader's discipline.

**Any addendum file you bootstrap gets the same stamp.** `AGENTS.softeng.md`, `AGENTS.overture.md`, and `AGENTS.roles/<role>.md` each carry the same canonical pointer tag, and each becomes a real snapshot the moment it is copied out, for the same reason `personal-preferences.md` does: once it lives in your global context it can no longer resolve a pointer back into agentics' own `CHANGELOG.md`. Replace the tag with `<!-- agentics-template-version: X.Y.Z | synced: <commit-sha> -->` on copy. Without it these files go stale silently, which is not hypothetical: the `0.15.0` rename of these exact filenames is undetectable in an already-bootstrapped global context that has no tag to compare.

3. Bootstrap the matching `AGENTS.roles/<role>.md`, and `AGENTS.softeng.md`/`AGENTS.overture.md` if applicable, the same way, once, per their answers.
4. Record `propagation_suggestions` per the usual default-prompting rule in `AGENTS.md` § Initialization; nothing else needs asking.
5. Stop there. No project files, no `.dev/`, nothing to commit anywhere.
