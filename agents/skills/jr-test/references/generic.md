# Generic Playbook

## Scope

Use when stack is not covered by dedicated playbooks.
Pair this with explicit technology guidance chosen for the project stack.
Start with `tech-selection.md`.

## Required Layers (Mapped Equivalents)

- Unit-equivalent tests: isolated behavior validation
- Integration-equivalent tests: boundary and subsystem interaction validation
- End-to-end/system-equivalent tests: full user or operator workflow validation

## Workflow

### 1) Define equivalents explicitly

- Document what unit/integration/end-to-end mean for this stack.
- Do not proceed until mapping is explicit.

### 2) Build behavior and risk matrix

- Map acceptance criteria to required-layer tests.
- Include happy path, edge cases, failure paths, and recovery behavior.

### 3) Implement tests per layer

- Write high-signal tests that validate externally meaningful behavior.
- Keep deterministic setup and teardown.

### 4) Credibility gates

- No mocking of core behavior under test.
- Boundary stubs only where runtime control is impossible.
- Include falsification checks proving tests can fail correctly.

### 5) Completion criteria

- All three layers covered via mapped equivalents.
- Any remaining test gaps are explicit, justified, and prioritized.
- Defects discovered are handed to `/jr-implement` with concrete evidence.
- Technology and tool choices are documented with rationale (modernity, maintenance, project fit).
- Security containment gate passes across mapped environment profiles and trust boundaries.

### 6) Security containment gate (required)

- Define and run an environment-profile matrix equivalent to local development, staging-like, and production-like.
- Verify dev-only interfaces are not reachable outside local development, or fail closed with hard deny behavior (403/404 equivalent) and no side effects.
- Attempt trust-boundary bypass vectors relevant to the stack (header/host/forwarding/proxy or equivalent transport metadata).
- Validate payload tampering cannot escalate privilege scope (role, tenant/company, or equivalent domain boundary).
- Block completion if any staging/production-like reachability or successful bypass/escalation exists.
- For dev-only auth or impersonation features:
  - Add anti-leak and anti-exploitation suites.
  - Require negative verification evidence for staging-like and production-like environments before pass.
