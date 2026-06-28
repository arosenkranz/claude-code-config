---
name: red-green-tdd
description: Execute the red/green TDD workflow: detect test command, capture baseline, write failing tests (RED), confirm failure, implement minimum code (GREEN), confirm all tests pass. Invoke with /red-green-tdd when the user wants to follow a disciplined test-driven development cycle. Do NOT auto-trigger on general test writing requests.
disable-model-invocation: true
---

# Red/Green TDD Workflow

Enforce the test-driven development ceremony: write failing tests first, verify they fail, then implement the minimum code to make them pass. The value of TDD is in the sequence; skipping RED verification defeats the purpose.

Supported ecosystems (v1): JavaScript/TypeScript (npm/yarn/pnpm/bun + Jest/Vitest) and Python (pytest/tox).

This skill handles the red/green ceremony, not test patterns. For pattern guidance (AAA structure, mocking, fixtures), follow the conventions already established in the project's existing test suite.

---

## Phase 0: Preflight

**Detect the test command.** Check in this order:

1. `package.json` scripts for `test`, `test:unit`, `test:watch`
2. `pytest.ini`, `pyproject.toml` `[tool.pytest.ini_options]`, or `setup.cfg` `[tool:pytest]`
3. `Makefile` for a `test` target
4. `tox.ini` for a `tox` configuration

If still ambiguous, ask: "What command runs your tests?" Do NOT guess.

**Run the full suite NOW and record baseline failures.** Only regressions introduced during this session are blockers. Pre-existing failures are noted and excluded from GREEN phase blocking criteria.

State: "Baseline captured. [N] tests passing, [M] failing pre-existing."

---

## Phase 1: RED

### 1.1 Clarify Scope

Before writing any tests, confirm:

* What function/module/class/behavior is being added or fixed?
* What are the expected inputs, outputs, and return types?
* What are the key edge cases? (empty input, null, boundary values, error paths)

Ask if unclear. Do not infer scope from filenames alone.

### 1.2 Write the Failing Tests

Write tests according to the scenario type:

**New module or function (does not exist yet):**
Import the symbol that will be created. This guarantees an `ImportError` (Python) or `Cannot find module` / `ReferenceError` (JS/TS), which is the correct RED state for brand-new code.

```python
# Python: import the not-yet-existing module
from mymodule import new_function  # will raise ImportError

def test_new_function_happy_path():
    assert new_function(2, 3) == 5
```

```typescript
// TypeScript: import the not-yet-existing export
import { newFunction } from './new-function'; // will fail at compile/runtime

describe('newFunction', () => {
  it('returns sum of two numbers', () => {
    expect(newFunction(2, 3)).toBe(5);
  });
});
```

**Bug fix or refactor (code already exists):**
Write an assertion against the current broken behavior or the expected correct behavior that currently fails. Do not write tests that already pass.

### 1.3 Run Tests - HARD STOP

Run the test suite and examine the output.

**Required before continuing:**

* All new tests must be failing
* The failure reason must match expectations:
  * New code: `ImportError`, `ModuleNotFoundError`, `Cannot find module`, or similar
  * Bug fix: assertion failure showing the current broken behavior
  * Refactor: assertion failure showing the pre-refactor state

**If new tests already pass:** STOP. Do not proceed. Investigate:

* Is the function already implemented elsewhere?
* Is the test asserting something trivially true?
* Is the import resolving to an unintended module?
Fix the test so it genuinely fails, re-run, and confirm RED before continuing.

**If the failure reason is wrong** (e.g., a syntax error in the test file, not the import error expected): Fix the test, re-run to confirm the correct RED state, then continue.

### 1.4 Phase Gate: RED Confirmed

After verifying RED, state explicitly:

> "RED confirmed. [N] new tests failing as expected ([describe failure reason]). Ready to begin GREEN phase. Proceeding..."

Do not skip this statement. It is the explicit phase boundary.

---

## Phase 2: GREEN

### 2.1 Implement Minimum Code

Write only the code needed to make the failing tests pass. Do not add functionality not covered by a test. Do not refactor while implementing.

Create the module/function/class at the expected import path if doing new code.

### 2.2 Run the Full Suite

Run the complete test suite (not just the new tests). Compare against the baseline:

* **New tests must all pass.** If any new test still fails, fix the implementation and re-run.
* **Pre-existing baseline failures are not blockers.** Only newly introduced regressions block GREEN.
* **If a new regression is introduced:** Fix the implementation before declaring GREEN. Do not suppress or skip the failing test.

### 2.3 Spec Correction Loop

If a test fails during GREEN because the spec was wrong (the implementation reveals the test assertion is incorrect):

1. Stop. Do not just fix the test silently.
1. Explain what the spec error is.
1. Revise the test to reflect the correct expected behavior.
1. Re-run to confirm the revised test is still RED (fails before the fix is in place).
1. Re-implement or adjust implementation.
1. Re-run full suite to confirm GREEN.

This loop preserves the TDD contract: tests define the spec, and spec changes are explicit.

### 2.4 GREEN Confirmed

When all new tests pass and no new regressions exist:

> "GREEN confirmed. [N] new tests passing. No new regressions. Implementation complete."

---

## Phase 3: REFACTOR (Optional)

Ask the user: "Would you like to refactor now that the tests are green?"

If yes:

* Make one change at a time
* Run the full test suite after each change
* If any test fails, revert the change immediately (do not pile fixes on top of a broken refactor)
* Repeat until satisfied

Refactoring does not change behavior. If a refactor causes a test to fail, the refactor changed behavior and must be reconsidered.

---

## Edge Cases

| Situation | Response |
| --------- | -------- |
| No test command found | Ask. Do not guess or invent a command. |
| New tests pass before RED | STOP. Investigate before continuing. |
| Wrong failure reason in RED | Fix test, re-run, confirm correct RED state. |
| Existing tests break during GREEN | Compare to baseline. Only new regressions block. |
| User wants to skip RED verification | Decline. Explain: "Verifying RED is what distinguishes TDD from test-after. Without it, tests may not actually be testing the implementation." |
| User wants to write tests after implementation | Explain the trade-off: tests written after may inadvertently mirror the implementation's shape rather than the spec's intent. Offer to retrofit: stub out the implementation to verify tests fail, then restore it. |
| Ambiguous test runner | Always ask. Running the wrong test command produces unreliable results. |
| Import resolves to wrong module | Check `__init__.py` (Python) or `index.ts` exports. Trace the import path before concluding. |

---

## Quick Reference

| Phase | Action | Success Condition |
| ----- | ------ | ----------------- |
| PREFLIGHT | Detect test command; run full suite; record baseline | Test command confirmed; baseline count recorded |
| RED | Clarify scope; write tests; run suite | New tests fail for expected reason |
| RED gate | State "RED confirmed" explicitly | Phase boundary acknowledged |
| GREEN | Implement minimum code; run full suite | All new tests pass; no new regressions |
| GREEN gate | State "GREEN confirmed" explicitly | Implementation complete |
| REFACTOR | One change; run tests; revert on failure | All tests still pass after each change |
