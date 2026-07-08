# Code review conventions

## Start with purpose, not implementation

Before examining how a PR is written, establish whether the proposed change is the right response to the problem. Work through these in order - if any answer is "no" or "unclear", raise it and stop:

1. **What problem does this solve?** If the PR description doesn't state it, ask before reviewing anything else. Reviewing changes without knowing the goal produces feedback on the wrong thing.

2. **Does the solution belong at this layer?** Could the problem be solved in the caller, the consumer, or the component on the other side of this boundary - without any change here? If yes, say so before reviewing the implementation.

3. **Is any code change needed at all?** Documentation, a usage example, or a configuration option sometimes replaces a feature. The smallest sufficient change is the right change.

4. **Only then:** review the implementation.

This is not about blocking PRs. A comment that redirects work to the right layer - "this doesn't belong here; here's why and here's the alternative" - is often the most useful review a PR can receive. It saves an implementation cycle and clarifies ownership.
