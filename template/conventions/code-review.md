# Code review conventions

This file covers one specific judgment call: whether a change belongs at all, before looking at how it's written. For how to conduct yourself throughout a review, ground truth over claims, disposition per finding, draft-never-post, and more, see `conventions/review-conduct.md`, a sibling file, not a superset or subset of this one.

## Start with purpose, not implementation

Before examining how a PR is written, establish whether the proposed change is the right response to the problem. Work through these in order - if any answer is "no" or "unclear", raise it and stop:

1. **What problem does this solve?** If the PR description doesn't state it, ask before reviewing anything else. Reviewing changes without knowing the goal produces feedback on the wrong thing. Phrase the ask as a hypothesis to confirm, not a blank question, give the author something to react to instead of a prompt to fill in from scratch:

   > It looks like the intent here is to enforce single active sessions per user, but the description doesn't say so directly. Can you confirm that in a comment, or correct me if it's something else?

   This also surfaces your own possibly-wrong read of the intent for correction, the same self-scrutiny `review-conduct.md`'s "push back, including on yourself" calls for.

2. **Does the change actually solve that problem?** Not just something adjacent to it. A diff can be well-written and correctly placed and still address a different, related, easier, or more familiar problem than the one named. This is the same "verify purpose alignment" scrutiny in `AGENTS.md`'s Interaction parameters, applied to someone else's work instead of your own: a mismatch here is the finding, not a nitpick on the implementation.

3. **Does the solution belong at this layer?** Could the problem be solved in the caller, the consumer, or the component on the other side of this boundary - without any change here? If yes, say so before reviewing the implementation.

4. **Is any code change needed at all?** Documentation, a usage example, or a configuration option sometimes replaces a feature. The smallest sufficient change is the right change.

5. **Only then:** review the implementation.

This is not about blocking PRs. A comment that redirects work to the right layer, or points out a goal mismatch, "this solves X, but the stated problem is Y", is often the most useful review a PR can receive. It saves an implementation cycle and clarifies ownership.
