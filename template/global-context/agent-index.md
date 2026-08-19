# Agent index

Cross-project directory for sessions to reach each other directly. Agent-managed, not for manual editing.
Place this file in your agent's global context directory (for Claude: `~/.claude/agent-index.md`; for other agents: consult your agent's docs), sibling to `projects.md`. Full design and reasoning: `conventions/agent-index.md`. Keep entries and rules in the live file terse and operational; that reasoning belongs in the convention, not duplicated here per-entry.

## Members

Exact-match lookup, normalized (case-insensitive, spaces/hyphens/underscores equivalent). `id` is this session's current runtime handle, peer-supplied: you cannot see your own, so ask a sibling to diff listings, the handle in theirs and not yours is you. True only for a session's lifetime, so check it against `ListAgents` before sending: present means current, absent means dead and cost nothing to learn. `window` is the container's name, the one a person would use for it, and never a handle's prefix, which is generated from whichever folder a workspace happens to list first and so identifies a window rather than a project. Reach a Member by checking its `id` against the listing first; if that `id` is dead, do not pick among the handles sharing its prefix, since those are the container's whole population rather than a shortlist. Never break a tie by start time: recency carries no information about which candidate is current. Zero matches: report to the developer, don't guess. Several matches, or the guess turns out wrong: disambiguate via a Requests post, before asking the developer. Check for a label collision before registering; negotiate directly with any existing holder.

```
- label:
  id:
  project:
  window:
  scope:
  focus:
  updated:   <UTC, e.g. 2026-08-19T03:06Z>
```

## Requests

Handshake only, no payload. `re:` is a feature/module name, never a finding or task detail. Validate plausibility before sharing substance either way: does the responder's stated `project`/`focus` genuinely match. The responding agent clears its own entry once contact is confirmed correct; the requester clears it as a fallback if the responder didn't. Surface anything pending over a week to the developer at the requester's own session start.

```
- from:
  id:
  looking_for:
  re:
  posted:    <UTC, e.g. 2026-08-19T03:06Z>
  heard:     <only if the post carried no id: sought agent's label, its own id, UTC>
```
