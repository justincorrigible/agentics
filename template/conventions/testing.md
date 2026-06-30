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
