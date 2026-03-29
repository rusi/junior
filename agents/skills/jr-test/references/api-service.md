# API/Service Playbook

## Scope

Use for backend-only systems, APIs, workers, and service processes without browser UI.
Pair this with a backend technology guidance file.
Typical pairing:
- `tech-python-backend.md` or `tech-node-backend.md`

## Required Layers

- Unit tests
- Integration/API contract tests
- System/end-to-end workflow tests (HTTP/CLI/job execution level)

## Workflow

### 1) Build requirement-to-endpoint matrix

- Map each acceptance criterion to endpoint/handler/service behavior.
- Include auth rules, validation rules, and error contract expectations.

### 2) Unit tests

- Validate business rules and data transformation semantics.
- Cover boundary conditions, invalid inputs, and policy rules.

### 3) Integration/API contract tests

- Exercise request/response behavior with real routing and serialization layers.
- Verify status codes, payload schemas, headers, and error contract stability.
- Validate persistence and side effects through real test infrastructure where possible.

### 4) System/end-to-end tests

- Validate full workflows involving multiple endpoints/services/jobs.
- Include retry/failure paths and idempotency where relevant.

### 5) Credibility gates

- Do not mock the service under test.
- Mock only external boundaries not controlled in test runtime.
- Add mutation-style negative checks to prove tests fail when key logic is broken.

### 6) Completion criteria

- End-to-end workflows represent real consumer behavior.
- Contract coverage exists for success and failure responses.
- Any implementation defect uncovered by tests is handed off to `/jr-implement`.
- Backend technology guidance is applied for tools and test patterns.
