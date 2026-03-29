# Web App Playbook

## Scope

Use for products with frontend and backend components plus browser user journeys.
Pair this with backend and frontend technology guidance files.
Typical pairing:
- `tech-python-backend.md` or `tech-node-backend.md`
- `tech-frontend-typescript.md`

## Required Layers

- Backend unit tests
- Backend integration tests
- Frontend unit/component tests
- Frontend integration tests
- Browser end-to-end tests (Playwright)

## Workflow

### 1) Build behavior matrix from story

- Map each acceptance criterion to backend behavior, frontend behavior, and user journey impact.
- Mark critical flows: create/update/delete, auth/permissions, validation, failure recovery.

### 2) Backend tests

- Unit:
  - Cover domain rules, pure transformations, authorization decisions, and edge validation.
  - Verify negative paths and explicit error behavior.
- Integration:
  - Exercise real data layer and service boundaries with controlled test environment.
  - Validate transaction boundaries, persistence correctness, and side effects.

### 3) Frontend tests

- Unit/component:
  - Validate rendering states, interaction rules, accessibility-critical behavior.
  - Assert visible output and state transitions, not implementation internals.
- Integration:
  - Validate feature workflows across components, state management, and API contracts.
  - Verify loading, empty, error, retry, and optimistic-update behavior.

### 4) End-to-end tests (Playwright)

- Cover top-priority journeys across full stack.
- Include at least one happy path and one failure/recovery path per critical flow.
- Verify user-visible outcomes and persisted effects.

### 5) Credibility gates

- No mock of core business logic.
- Boundary mocks only (third-party APIs, external systems).
- Add at least one falsification test per critical feature path.

### 6) Completion criteria

- All required layers exist and are relevant.
- Coverage gaps and risk areas are explicitly listed.
- If defects are exposed, create clear handoff tasks for `/jr-implement`.
- Matching technology guidance is applied for backend and frontend tooling choices.
- Security containment gate passes in env matrix (local dev, staging-like, production-like).

### 7) Security containment gate (required)

- Run env-matrix tests against local dev, staging-like, and production-like profiles.
- Verify dev-only routes/features are not exposed outside local dev, or return hard 403/404 with no side effects.
- Attempt bypass vectors:
  - Header/host/forwarding/proxy trust boundary manipulation.
  - Equivalent ingress and gateway spoofing vectors used by the project.
- Validate payload tampering cannot escalate role, company/tenant scope, or authorization context.
- Block completion if any staging/production reachability exists for dev-only auth or impersonation paths.
- If a story contains dev-only auth or impersonation behavior:
  - Include anti-leak tests (route discovery, response metadata leakage, token/session leakage).
  - Include anti-exploitation tests (privilege escalation, cross-tenant/company access, bypass attempts).
  - Do not pass story without staging/production negative verification evidence.
