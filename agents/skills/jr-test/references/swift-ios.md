# Swift/iOS Playbook

## Scope

Use for native iOS applications and Swift-based mobile products.
Pair this with Swift/iOS technology guidance for framework and tooling choices.
Typical pairing:
- `tech-swift-tooling.md`

## Required Layers

- Unit tests (XCTest)
- Integration tests (services/persistence/view-model boundaries)
- UI end-to-end tests (XCUITest) for critical user journeys

## Workflow

### 1) Build feature behavior matrix

- Map acceptance criteria to domain logic, view-model/state logic, and UI journeys.
- Identify lifecycle-sensitive and async-sensitive interactions.

### 2) Unit tests

- Cover domain rules, formatters/parsers, validation, and decision logic.
- Include edge cases and failure-state transitions.

### 3) Integration tests

- Validate network/persistence boundaries with stable test conditions.
- Verify state propagation from service layer to presentation layer.

### 4) UI end-to-end tests

- Validate top user journeys through real UI flows.
- Cover success and failure/recovery paths.
- Assert user-visible outcomes, not implementation internals.

### 5) Credibility gates

- Do not fake core view-model/domain behavior.
- Use test doubles for external boundaries only.
- Add negative controls to prove tests fail when behavior regresses.

### 6) Completion criteria

- Required layers are present and stable.
- Async behavior is deterministic and not timing-flaky.
- Implementation defects exposed by tests are handed back to `/jr-implement`.
- Selected Swift/iOS tooling guidance is applied consistently.
