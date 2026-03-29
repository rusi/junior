---
name: jr-test
description: Execute chief test-engineering workflows that validate test credibility, close coverage gaps, and enforce multi-layer quality gates.
---

# Test Engineer Command

## Purpose

Act as chief software test engineer for a story: independently assess implementation quality through tests, remove weak test patterns, and enforce reliable unit/integration/end-to-end coverage.

## Type

Direct execution with automatic mode inference from context.

## When to Use

- Required after `/jr-implement` for coding stories
- You need independent validation of implementation quality and test credibility
- You suspect current tests are weak, over-mocked, flaky, or not tied to real behavior
- You need complete test-layer coverage (unit + integration + end-to-end/system)

## Scope and Quality Bar

- This command writes, refactors, and executes tests only.
- Product implementation changes are forbidden in `/jr-test` (no feature logic, endpoint/controller logic, domain/service logic, migrations, production config changes, or UI feature behavior changes).
- Only test-side changes are allowed: tests, fixtures, test utilities, and minimal test harness wiring needed to run tests.
- If the user asks for non-test implementation while running `/jr-test`, do not execute it directly; ask one focused confirmation question to switch to `/jr-implement` first.
- Tests must validate behavior that matters to users and acceptance criteria.
- Every test must map to a meaningful behavior, risk, or acceptance criterion.
- "Passing but meaningless" tests are failures.
- Over-mocking the system under test is forbidden.
- Flaky tests are failures until stabilized or replaced.
- Skipped/pending/disabled tests are failures; find and fix root causes so tests run.
- Redundant or duplicate tests are failures; consolidate and keep the strongest signal.
- Trivial or "stupid assert" tests are failures (for example, tautological asserts, existence-only asserts without behavior validation, or asserts detached from requirements).
- Required layers are mandatory: unit, integration, and end-to-end/system (where applicable to stack).
- Security containment gates are mandatory and higher priority than all other test completion criteria.
- Prefer modern, actively maintained testing tools and practices that fit the detected stack.
- Operate with a critical posture: assume tests are insufficient until proven rigorous.
- If tests reveal implementation defects, stop product edits, record evidence, and hand off fixes to `/jr-implement`.

### Additional Non-Negotiable Gate: Stateful Context Switching

When a story touches context selectors or context-scoped routing/data (active scope selection or equivalent), `/jr-test` must enforce a context-switch regression matrix in e2e/system tests.

Required evidence:
- At least one overview/aggregate view and one detail/edit view per affected context boundary.
- Assertions must validate:
  - data updates to the new context
  - previous-context data is no longer shown
  - URL/route coherence on nested/deep-link pages after switch
- At least one test must prove new-context network/loader activity occurred.

If this matrix is missing or weak (selector-only assertions), audit fails.

## Relationship to `/jr-implement`

- Default loop:
  1. `/jr-implement [story]`
  2. `/jr-test [story]` (automatic audit mode inference; explicit override allowed)
  3. If defects are found, return to `/jr-implement [story]` and repeat

- Optional test-first loop (only when user requests it):
  1. `/jr-test [story]` before implementation
  2. `/jr-implement [story]`
  3. `/jr-test [story]` again as final audit

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan`:

```json
{
  "todos": [
    {"id": "select-story-mode", "content": "Select story and infer mode from context", "status": "in_progress"},
    {"id": "gather-context", "content": "Load story, current implementation, and test landscape", "status": "pending"},
    {"id": "branch-stack-playbook", "content": "Select app-type playbook and required layer matrix", "status": "pending"},
    {"id": "select-tech-guidance", "content": "Select language/framework guidance and modern tooling", "status": "pending"},
    {"id": "credibility-audit", "content": "Audit tests for validity, anti-patterns, and falsifiability", "status": "pending"},
    {"id": "implement-strengthen", "content": "Add or refactor tests to close required-layer gaps", "status": "pending"},
    {"id": "execute-verify", "content": "Run suites and verify reliability, coverage, and failure signal quality", "status": "pending"},
    {"id": "handoff-loop", "content": "Hand back findings and required fixes to jr-implement if needed", "status": "pending"}
  ]
}
```

### Step 2: Select Story and Automatically Infer Mode

- Parse explicit input: `/jr-test feat-N-story-M [mode-override]`
- If story is omitted, discover next story needing test engineering.
- Apply `references/mode-selection.md` to infer mode from repository evidence and user intent.
- Infer mode by evidence (do not ask if confidence is high):
  - `audit` when there are recent implementation changes, existing product code for the story, or completion claims from `/jr-implement`.
  - `spec-first` when implementation is absent or deliberately deferred and user intent is test-first.
- If user explicitly requests `spec-first` or `audit`, honor explicit instruction.
- Ask only one focused question when inference confidence is low.
- If a request inside `/jr-test` asks for non-test implementation, pause and ask one focused confirmation to switch workflows before any product-code edits.

Allowed mode labels:
- `spec-first`: create high-signal failing tests before implementation
- `audit`: review and harden test suite after implementation

### Step 3: Gather Full Context

Load and correlate:
- Story definition and acceptance criteria
- Existing implementation touched by the story
- Existing tests and test configuration
- CI/test execution conventions
- Existing test utilities and fixtures
- Session context contract: `../_shared/references/session-artifact-log.md`

Identify risk and behavior map:
- Critical user flows
- State transitions and boundary conditions
- Error paths and failure handling
- External dependency interactions

For context-sensitive stories, explicitly capture:
- context boundaries that can change at runtime
- pages expected to refresh/rebind after context changes
- stale-data failure risks and expected negative assertions

### Step 4: Branch to App-Type Playbook (Mandatory)

Select one playbook and execute it end-to-end:

- Web applications:
  - Load `references/web-app.md`
- API/service systems:
  - Load `references/api-service.md`
- C/C++ systems:
  - Load `references/cpp.md`
- Swift/iOS systems:
  - Load `references/swift-ios.md`
- Other stacks:
  - Load `references/generic.md` and map equivalent layers explicitly

Do not proceed without an explicit layer matrix for the selected stack.

### Step 5: Apply Technology Guidance (Mandatory)

- Load `references/tech-selection.md`.
- Select all matching tech guidance files for the project.
- Use modern/default tooling from guidance unless project conventions require compatibility.
- If project already uses older but stable tooling, prefer consistency and improve within that stack.

Examples:
- FastAPI/Python backend: `references/tech-python-backend.md`
- Node.js backend: `references/tech-node-backend.md`
- TypeScript frontend: `references/tech-frontend-typescript.md`
- C/C++: `references/tech-cpp-tooling.md`
- Swift/iOS: `references/tech-swift-tooling.md`

### Step 6: Credibility Audit (Trustworthiness Gate)

Apply all checks below:

- Falsifiability:
  - Prove each critical test can fail for the intended reason.
  - Reject tests that pass when key behavior is broken.
- SUT integrity:
  - The system under test must be real.
  - Mock only external boundaries, not core feature behavior.
- Assertion quality:
  - Assert externally visible behavior and state transitions.
  - Reject assertion sets that only check internal implementation details.
- Skip and disable audit:
  - Reject skipped, xfail, pending, todo, or disabled tests unless user explicitly approves a temporary exception.
  - Default action is to remove skip markers and fix underlying test or product behavior.
- Redundancy audit:
  - Remove duplicate tests that exercise the same behavior with no additional signal.
  - Keep one high-signal test per behavior path and add distinct edge coverage only when it adds value.
- Meaningfulness audit:
  - Reject "stupid assert" patterns (assertions that would pass regardless of correctness, no-op expectations, or checks with no requirement linkage).
  - Require each assertion block to prove a requirement, risk, or regression boundary.
- Determinism:
  - Remove timing races, hidden order dependencies, and environment-coupled behavior.
- Signal quality:
  - Failure messages must identify broken requirement quickly.
- Context-switch validity (required when applicable):
  - Reject tests that only verify selector/control state.
  - Require assertions against rendered page data and route state.
  - Require stale-data rejection assertions (old-context records absent after switch).
  - Require at least one nested/deep-link switch scenario.
- Security containment gate (required):
  - Run an environment-profile matrix for relevant profiles (at minimum: local development, staging-like, production-like).
  - Verify dev-only routes/features are not exposed outside local development, or return hard deny responses (403/404) with no side effects.
  - Attempt bypass vectors (header, host, forwarding/proxy, and equivalent transport trust boundaries for the stack).
  - Validate no scope/role or privilege escalation is possible via payload tampering.
  - Block completion immediately if any staging/production reachability or successful bypass/escalation path is detected.
  - If the story includes any dev-only auth or impersonation feature, add anti-leak and anti-exploitation tests and require staging/production negative verification before pass.

### Step 7: Implement or Refactor Tests

In `spec-first` mode:
- Write failing tests that encode acceptance criteria and edge behavior.
- Ensure failures are specific and actionable for `/jr-implement`.
- Do not weaken assertions to make tests pass.

In `audit` mode:
- Replace weak or over-mocked tests with behavior-true coverage.
- Replace or repair skipped/disabled tests so they execute reliably.
- Remove redundant/useless tests and keep only meaningful high-signal coverage.
- Rewrite trivial assertion blocks into requirement-linked behavioral checks.
- Add missing unit, integration, and end-to-end/system tests.
- Extend edge-case, error-path, and regression coverage.
- Add a defect list when tests expose implementation bugs.
- Do not fix implementation bugs inside `/jr-test`; create a concrete `/jr-implement` handoff instead.

For all modes:
- Keep tests deterministic and isolated.
- Reuse fixtures/utilities; enforce DRY patterns.
- Follow language/framework conventions already used in project.
- If blocked by missing product behavior, keep test expectations strict and report implementation defects rather than weakening tests.
- Never treat user pressure ("implement this now") as authorization to bypass `/jr-test` scope; require explicit confirmation to switch to `/jr-implement`.

### Step 8: Execute and Verify

Run relevant test suites for each layer and report:
- Which layers ran
- Pass/fail status
- Coverage status by layer/module where available
- Reliability status (flaky or stable)
- Remaining risks or justified gaps

For context-sensitive stories, include:
- explicit context-switch matrix results (pass/fail by flow)
- stale-data negative assertion results
- one short exploratory charter result for context + navigation interactions

Validation outcome rules:
- `spec-first`: expected failing tests may remain; they must fail for the right reason.
- `audit`: unresolved failing tests, any skipped/disabled tests, redundant/useless tests, trivial assertion tests, missing mandatory layers, or any failed security containment gate block completion.
- `audit` (context-sensitive stories): missing context-switch matrix, missing stale-data negatives, or selector-only assertions also block completion.

### Step 9: Handoff and Story Updates

- Update story checklist status with evidence.
- Mark test tasks complete only when evidence exists.
- If defects are found, create a concrete fix handoff to `/jr-implement`.
- For coding stories, keep story status in-progress until post-implementation audit gate is complete.
- `/jr-test` completion is blocked if required behavior is missing and no `/jr-implement` defect handoff is documented.
- Append a `## Session Artifact Log` entry in the story file per `../_shared/references/session-artifact-log.md`, including all touched test files and exact verification commands/results.

## Stack Playbooks

Use one app-type playbook per run:
- `references/mode-selection.md`
- `references/web-app.md`
- `references/api-service.md`
- `references/cpp.md`
- `references/swift-ios.md`
- `references/generic.md`

## Technology Guidance

Load all relevant guidance files per project stack:
- `references/tech-selection.md`
- `references/tech-python-backend.md`
- `references/tech-node-backend.md`
- `references/tech-frontend-typescript.md`
- `references/tech-cpp-tooling.md`
- `references/tech-swift-tooling.md`

## Tool Integration

- `todo_write` or `functions.update_plan`: progress tracking
- `codebase_search` or `functions.shell_command`: locate implementation and tests
- `read_file` or `functions.shell_command`: inspect story/spec/test files
- `search_replace` or `functions.apply_patch`: add and refactor tests
- `run_terminal_cmd` or `functions.shell_command`: execute test suites and coverage commands

## Examples

```text
/jr-test feat-4-story-2
```
Automatically infers mode from context (default is audit after implementation).

```text
/jr-test feat-4-story-2 audit
```
Forces post-implementation audit mode.

```text
/jr-test feat-4-story-2 spec-first
```
Forces pre-implementation test-first mode.
