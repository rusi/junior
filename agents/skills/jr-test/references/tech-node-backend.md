# Node.js Backend Test Guidance

## Preferred Tooling (Modern Defaults)

- Test runner: `vitest` (or `jest` when project is already standardized on it)
- Coverage: built-in coverage tooling or project-standard coverage integration
- API testing: `supertest` for HTTP boundary tests
- Contract validation: schema assertions and contract tests where applicable
- Microbenchmarks (when needed): lightweight benchmark tooling compatible with project runtime

## Framework Guidance

- Express/Fastify/NestJS:
  - Test routing, validation, auth/authorization, and error contracts at HTTP layer.
  - Keep service-level unit tests focused on behavior, not framework wiring.

## Required Quality Checks

- Unit tests for business logic and policy decisions.
- Integration tests for DB, queues, cache, and other infrastructure boundaries.
- End-to-end/system tests for multi-endpoint workflows and failure recovery.

## Anti-Patterns to Reject

- Mocking the entire app container for tests that claim to be integration.
- Snapshot-heavy tests without behavioral assertions.
- Tests that pass only due to mocked internals instead of observable outcomes.
