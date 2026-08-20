# Testing conventions

## Test file placement

Co-locate test files with the source they test: `validation.test.ts` in the same folder as `validation.ts`, not in a sibling `__tests__/` directory. A centralised `__tests__/` folder drifts further from the code it covers as the project grows.

When writing new tests, always place them next to the source file. When touching existing tests in `__tests__/` directories, note the inconsistency and log it as tech-debt.

## Plan-first workflow

For any feature or non-trivial change, follow this order:

1. **Plan**: present the approach and agree on it before writing anything
2. **Define behaviour**: write or describe the tests before implementation; tests are the specification
3. **Implement**: write code to make the tests pass

Designing tests first forces the interface to be thought through from the caller's perspective, surfacing architectural and API issues before they are baked into code.

**Pragmatic exceptions:** Skip for pure structural/wiring work (type propagation, config plumbing, renaming) where a test would only verify "does this compile." BDD pays off most on logic with clear inputs and outputs: validation, transformations, business rules, utilities.

## BDD test style

Use `suite()` and `test()` with descriptive plain-language names. Structure test bodies as setup → action → assertion (Given / When / Then). The specific testing framework is your team's choice; the naming and structure pattern applies regardless.

Example using Node's built-in `node:test` and `assert`:

```ts
import { suite, test } from 'node:test';
import assert from 'node:assert/strict';

suite('getNetworkPassthroughHeaders', () => {
  test('returns an empty array when no headers are configured', () => {
    const result = getNetworkPassthroughHeaders({ passthroughHeaders: [] });
    assert.deepEqual(result, []);
  });

  test('excludes empty string entries', () => {
    const result = getNetworkPassthroughHeaders({ passthroughHeaders: ['', 'Authorization'] });
    assert.deepEqual(result, ['Authorization']);
  });
});
```

- New tests: BDD style from the start
- Existing tests: rename and restructure when touching them in scope; large-scale rewrites belong in tech-debt

## Rebuild `file:`-linked workspace dependencies before testing across a package boundary

A package referenced via `"file:../other-package"` resolves through that package's built output (`dist/`, per its `package.json`'s `main`/`exports`), not its live source. Editing that dependency's source and testing a consumer without rebuilding it first silently exercises stale compiled output. No error, no warning, just wrong behaviour.

Unit tests that import from a package's own source, via internal path aliases, within the same package, never cross this boundary and cannot catch it. Only a test that imports the dependency the way a real consumer does, by package name, through its resolved entry point, will.

**Before trusting a "changed the dependency, tests still pass" result:** rebuild the dependency first, or write at least one test that exercises the real cross-package resolution path rather than importing from source.

## Prefer bare test-runner invocation over a shell-glob pattern in `test` scripts

`"test": "tsx --test ./src/**/*.test.ts"` (or the `node --test` equivalent) depends on the invoking shell expanding `**` recursively. `npm run <script>` executes through a non-interactive `sh`, which does not support globstar the way an interactive bash/zsh session does.

Under plain `sh`, `**` behaves like a single `*` for one path segment: it silently matches only files at that exact depth, skipping everything shallower or deeper. No error, no warning. The only symptom is a lower-than-expected test or suite count, easy to miss unless someone happens to be watching for it.

**Fix:** use a bare `"test": "tsx --test"` (or `"node --test"`) with no path argument. The test runner's own recursive discovery isn't subject to the shell's globbing behaviour and finds every test file regardless of nesting depth.

## A test that builds its own input cannot discover the input it was never given

**The author of a test and the author of the code hold the same assumption about what the input looks like, so a test that constructs its input proves the code handles the shape it already expected.** The contract that matters is the one a real caller supplies, and it is exactly the one that never appears in the fixture. This is not a coverage problem: a line-coverage report can read as complete while the interesting case has never been constructed at all.

Two independent instances surfaced in one week, in repositories sharing no code, reported by the sessions that found them:

- A suite exercising string handling where **no input contained a quote character**, so the escaping contract was never exercised at all. Escaping is the reason that code path exists.
- A suite exercising access control where **every test passed a null filter**, so nothing ever exercised a filter that filters. Every assertion passed and the feature under test was absent from all of them.
- A query builder whose `IN` clause construction was **never tested against a multi-element array**, so the one case the clause exists for was the one case never constructed. The same fix also reimplemented an `inArray()` helper the codebase already provided, which is the same assumption going unchallenged in two directions at once.

**The failure is not a security-testing failure, and filing it as one is how it survives.** Two of the instances above look like security dimensions and the third is ordinary correctness, which is the point: a reader who files this under injection or access control will not apply it to a query builder. The mechanism is indifferent to the dimension, because it comes from the author's assumption about input shape rather than from anything about what the code does. Reported by a session noting the same failure hit one file twice in a single day, once on an injection dimension and once on an ordinary one.

**The check is one question per test double or fixture: what value would a real caller supply that I have not written here?** Then write that one. The high-yield answers are consistent across both cases above and worth walking deliberately: the value that needs escaping, the non-empty version of a filter, the absent field rather than the present one, the input that is already encoded, and the case that another component produces rather than the one you would type.

**A "passing" suite is evidence about the inputs it contains and nothing else.** When a test is meant to prove a transformation happens, assert the transformation, since a fixture needing no transformation makes an identity function pass the same test.

## When to actually run the suite, not just write it

A `session-discipline.md` § "Refinement passes" concern, not a separate mechanism: the full suite gets run at the semiregular in-session checkpoint specifically, not just the tests for what was just written, since that's the checkpoint an involuntary session end (a usage or context limit, a crash) can still reach even when the final "before ending a session" one can't. "Before committing" and "before ending a session" still get a full run too; the point is that neither can be the only line of defence.
