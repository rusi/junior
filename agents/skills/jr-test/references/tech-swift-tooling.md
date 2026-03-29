# Swift/iOS Tooling Guidance

## Preferred Tooling (Modern Defaults)

- Unit/integration: XCTest and project-standard Swift test tooling
- UI end-to-end: XCUITest
- Performance checks: XCTest performance metrics for critical paths where relevant

## Required Quality Checks

- Unit coverage for domain and view-model logic.
- Integration tests for persistence/network boundaries and state propagation.
- UI journey tests for key user flows with success and failure/recovery paths.

## Stability Requirements

- Avoid timing-based flakiness by using deterministic waits and clear state synchronization.
- Ensure test fixtures isolate side effects between runs.

## Anti-Patterns to Reject

- UI tests that only launch app without feature assertions.
- Overuse of mocks that bypass real state propagation logic.
- Ignoring intermittent failures without root-cause investigation.
