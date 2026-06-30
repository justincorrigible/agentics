# AI engineering role

Builds on the base template conventions. Read this file in addition to, not instead of, `CLAUDE.md`.

Applies when the project involves building, evaluating, or maintaining AI systems: agentic workflows, prompt pipelines, fine-tuning, evaluation infrastructure, or agent instruction design.

## Prompt engineering hygiene

**Prompts are code.** Version-control them. Name versions explicitly. Do not silently overwrite a working prompt: treat changes as diffs, not replacements.

**Separate concerns.** System prompt, user template, and few-shot examples are distinct artifacts. Keep them in separate files or clearly delimited sections.

**Test prompts like you test functions.** Define expected behaviour for known inputs before iterating. "It looks better" is not a test.

## Evaluation discipline

Do not ship a prompt or model change without an eval. Even a small hand-labelled set is better than none. Document: what was measured, on what data, with what baseline.

Log eval runs in `.dev/sessions.md` with: model/version, dataset, metric, result. This is the audit trail for model decisions.

## Agentic and multi-agent patterns

**Agents should fail loudly.** Silent fallbacks and catch-all error handlers hide failures. Design agents to surface ambiguity rather than guess.

**Context window is a resource.** Be explicit about what is and is not loaded. Dispatch patterns (lean main instruction file, detail in separate convention files) apply to agent instructions the same as to source code.

**Agent instructions are contracts.** Changes to instruction files change agent behaviour: treat them with the same care as API contract changes. Review, version, and test them.

## Metacognitive layer

When working on agentic infrastructure itself (instruction files, memory systems, convention propagation):

- Surface design decisions in `.dev/sessions.md`, not just in conversation.
- When a pattern works, document why: not just what it does.
- Convention propagation is part of the work. The instructions are as important as the code.

## Security additions

All base security conventions apply. AI engineering adds:

- **Prompt injection:** treat user-supplied content in prompts the same as user input in SQL: never interpolate without sanitization or clear delimiters.
- **Model output trust:** do not execute or evaluate model-generated code without review; do not forward model output to privileged systems without validation.
- **Credential handling in API calls:** API keys and tokens used to call model providers must follow the same no-credentials-in-files rule as all other secrets.
