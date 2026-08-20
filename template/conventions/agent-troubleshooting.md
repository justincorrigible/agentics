# Troubleshooting your agent's own environment

Symptoms where the agent's tooling, not the project, is the problem: a file it cannot see, memory that does not follow a project. Read this when one of these symptoms actually appears.

Distinct from debugging the software you are building, and distinct from `session-discipline.md`, which is about running a session rather than repairing one.

## Troubleshooting: agent doesn't see a file you're actively editing

An agent that reads the filesystem directly, true of virtually every coding agent, only sees what's actually on disk. A file open in your editor with unsaved changes exists only in the editor's own memory until saved; a brand-new, never-saved buffer (an "Untitled" file with no disk path at all) has nothing to read at all.

**Symptom:** asking the agent about a file you're actively editing gets a stale answer (an older version of an existing file) or an outright "file does not exist" (a new, unsaved buffer).

**Fix:** save the file first, or paste its content directly into the conversation instead, which reaches the agent immediately regardless of save state. Worth keeping in mind specifically when troubleshooting an interaction that seems to be ignoring something you just typed.

**Name this directly in your reply when it happens, don't just quietly work around it.** A file read returning stale content or "does not exist" when the developer is clearly mid-edit is exactly this symptom: say so explicitly (unsaved changes, or an unsaved buffer with no disk path) rather than only reporting the read failure and leaving the cause for the developer to guess.

## Troubleshooting: agent won't load, or its memory doesn't follow a project, after a rename or multi-root adoption

Reorganizing project folders, a rename, a move, or combining several repos under a shared parent, can trigger two genuinely different failures. Check which one you actually have before assuming a fix for one resolves the other.

### Failure mode 1: the editor fails to load at all (blank screen, no error)

Confirmed as the actual blocker in a real incident: a multi-root workspace configuration still references a folder's old path. If your editor's workspace configuration (for VSCode: a `.code-workspace` file, or its own remembered folder list) includes a folder that's since been renamed or moved, the editor can fail to resolve the whole workspace, not just that one folder, silently rather than with a clear error. That takes down any extension running inside it, an agent extension included, along with it. **Fix:** re-add the moved folder at its new path in the workspace configuration.

### Failure mode 2: the editor loads fine, but an agent's memory doesn't follow the repo you expect

**The read half of this has no symptom and therefore no place here: it is a session-start step.** Nothing looks wrong when your own project's memory never loads, so a file dispatched by symptom cannot reach it. `session-discipline.md` § Starting a session now has deriving and reading your project's memory path as an unconditional step, for that reason.

**A consequence worth stating separately: the memory you resolve to may not be yours to write into.** The failure above is usually framed as reading the wrong context, but the same mis-resolution writes too. A session designated for one service, rooted in a directory belonging to another, resolves to that other project's memory and can file facts about *itself* there, in a space that belongs to whichever agent actually works from that project. The owning agent then finds assertions about its own role that it did not write and does not recognize. Confirmed directly: a session designated for a submission service, rooted in a portal repo, recorded its own scope boundary in the portal's memory; the portal's own agent later corrected the file to describe its actual role, which was legitimate and developer-instructed.

Before writing a fact about *which session you are* or *what you own* into project memory, check that the memory you resolved to belongs to the project you are actually working on, not merely the directory you happen to be rooted in. Where those differ, the fact belongs in your own conversation or with the developer, not in a shared space keyed to someone else's project. This is the memory-side form of the ownership rule in `AGENTS.md` § Interaction parameters: a directory does not confer ownership any more than proximity to another session's work does.

The underlying property, not specific to any one incident: if your agent keys session or memory identity to a single resolved absolute directory path (for Claude Code: under `~/.claude/projects/`, in a directory named after the path with every slash replaced by a hyphen) rather than to "the repo" as a concept, that identity can end up wrong in two different ways depending on how the project is opened:

- **Single-folder window:** resolves directly from the opened folder's path. A rename that collapses a hyphenated name into a nested path, or the reverse, can collide byte-for-byte with a different project's old encoded key: a hyphen in a name and a slash between folders turn into the same character once encoded.

  ```
  sajter/ohcrn-infra  ->  -Users-...-sajter-ohcrn-infra
  sajter/ohcrn/infra  ->  -Users-...-sajter-ohcrn-infra
  ```

  Reopening the project at its new location then silently resolves to the old project's memory instead of creating a fresh one.
- **Multi-root `.code-workspace` window: does not resolve per active tab or per member repo.** It resolves to whichever single folder is listed *first* in the workspace file's `folders` array, for the whole window, no matter which file you actually have open. Verified empirically: switching the active tab to a file in a different member repo doesn't change which project resolves. Starting a new chat creates a new, empty project directory keyed to the first-listed folder specifically. Every other member repo's own accumulated history is invisibly disconnected the moment the multi-root workspace is created, not merged, not visible, not even referenced: opening several repos as one multi-root workspace is a fresh, separate project scoped to one folder, not a superset view of each repo's own history.

**Diagnostic (for Claude Code):** check whether `~/.claude/projects/` has a directory matching the path you expect (current project's path, or the workspace's first-listed folder, with `/` replaced by `-`), and whether its content actually corresponds to what you expect or reads like a different, unrelated project. For other agents: consult your own tool's documentation for whether it keys persistent state by file path at all, and how it resolves that path in a multi-root context specifically.

**Fix for a same-shape collision (single-folder case):** rename, don't delete, the stale colliding directory to a backup name, freeing the key for a genuinely fresh one.

**No supported fix for the multi-root case.** There's no built-in way to merge or migrate a single-folder project's history into a multi-root workspace's own project key. The only available workaround is manually locating and copying the raw transcript file into the target project's directory. This is a filesystem-level hack, not a supported operation: worth knowing about, but not something to rely on routinely.

**Prevention:**
- Before renaming or moving a folder that's part of a multi-root workspace, update the workspace file's folder list in the same action, don't treat it as a follow-up step.
- Adopting a multi-root workspace for repos with existing, valuable single-folder history isn't free: every member folder except whichever is listed first starts a fresh, disconnected history the moment the workspace is created. If continuity matters more than viewing everything in one window, keep single-repo windows for that work instead, or go in accepting the multi-root window as a genuinely separate project context, not a combined view of its members.
