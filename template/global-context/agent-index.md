# Agent index

Cross-project directory for sessions to reach each other directly. Agent-managed, not for manual editing.
Place this file in your agent's global context directory (for Claude: `~/.claude/agent-index.md`; for other agents: consult your agent's docs), sibling to `projects.md`. Full design and reasoning: `conventions/agent-index.md`. Keep entries and rules in the live file terse and operational; that reasoning belongs in the convention, not duplicated here per-entry.

## Members

Exact-match lookup, normalized (case-insensitive, spaces/hyphens/underscores equivalent). No `name`/ref field: it's too dynamic to store usefully, reach a Member by filtering `ListAgents` (or your agent's equivalent) to sessions matching `project`/`window`/`scope`, defaulting to the most recently started candidate. Zero matches: report to the developer, don't guess. Several matches, or the guess turns out wrong: disambiguate via a Requests post, before asking the developer. Check for a label collision before registering; negotiate directly with any existing holder.

```
- label:
  project:
  window:
  scope:
  focus:
  updated:
```

## Requests

Handshake only, no payload. `re:` is a feature/module name, never a finding or task detail. Validate plausibility before sharing substance either way: does the responder's stated `project`/`focus` genuinely match. The responding agent clears its own entry once contact is confirmed correct; the requester clears it as a fallback if the responder didn't. Surface anything pending over a week to the developer at the requester's own session start.

```
- from:
  looking_for:
  re:
  posted:
```
