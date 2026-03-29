# Python Backend Test Guidance

## Preferred Tooling (Modern Defaults)

- Test runner: `pytest`
- Async support: `pytest-asyncio` (or project-equivalent async plugin)
- Coverage: `pytest-cov`
- Performance microbenchmarks: `pytest-benchmark`
- Property-based testing for critical logic: `hypothesis`

## Framework Guidance

- FastAPI/Starlette:
  - Use request-level tests with framework-compatible clients.
  - Cover auth, validation, error responses, and dependency boundaries.
- Django/Flask:
  - Use framework-native fixtures plus `pytest` integration.
  - Validate ORM/data behavior with realistic test DB boundaries.

## Required Quality Checks

- Unit tests for core logic, policy decisions, validators, and transformations.
- Integration tests for DB and service boundaries.
- API contract tests for status codes, payload shape, and error schema.
- Benchmark checks for known hot paths when performance is a requirement.

## Anti-Patterns to Reject

- Heavy monkeypatching that replaces core business logic.
- Tests asserting only mocked call counts without behavior assertions.
- Broad fixture reuse that hides state coupling or test order dependence.
