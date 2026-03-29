# Frontend TypeScript Test Guidance

## Preferred Tooling (Modern Defaults)

- Unit/component/integration runner: `vitest` (or `jest` if project-standard)
- DOM testing: Testing Library approach (behavior-first assertions)
- API boundary mocking for frontend integration: `msw` when applicable
- End-to-end: `playwright` by default for cross-browser workflow validation

## Required Quality Checks

- Component tests for rendering states and interaction behavior.
- Integration tests for state management + API interactions.
- End-to-end flows for top-priority user journeys, including failure/recovery paths.
- Accessibility-focused assertions for critical UI controls and flows.

## E2E Selection Rule

- Prefer `playwright` unless existing project constraints strongly justify alternatives.
- If a different e2e framework already exists and is stable, keep it and strengthen coverage.

## Anti-Patterns to Reject

- Shallow tests asserting implementation internals instead of user behavior.
- Mocked frontend tests that never exercise real routing/state transitions.
- E2E tests that only check page load and skip business-critical actions.
