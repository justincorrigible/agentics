# Atlas index

- [Interagent communication: findings so far](interagent-communication-findings.md): empirical findings from live-testing Claude Code's cross-session messaging (`ListAgents`/`SendMessage`), gathered as prep material for a future agentics convention, not yet a design
- [Agent index: cross-project session directory and bulletin board](agent-index-design.md): full design spec for a global, agent-managed directory (exact-match lookup) and bulletin board (fuzzy-match handshake), superseding the earlier family-registry prototype; shipped as `conventions/agent-index.md`
- [Whole-repo review: 2026-08-17](whole-repo-review-2026-08-17.md): a full read of every file in the repo, corrections, gaps, and a naming question needing a deliberate decision, written up in enough detail to implement later without re-deriving the reasoning
- [Multi-lens review: 2026-08-17](multi-lens-review-2026-08-17.md): a second pass the same day, six concurrent lenses instead of one linear read, finding a materially larger set including an inert security control; the method difference is itself the first finding
- [Family heads: a per-family triage role](family-heads-design.md): developer-originated design for one session per family acting as routing point for unclaimed components; resolved and open questions, plus the finding that the family unit is the product family rather than the window
