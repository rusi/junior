# C/C++ Playbook

## Scope

Use for native applications, libraries, systems software, and embedded-adjacent C/C++ projects.
Pair with `tech-cpp-tooling.md`.

## Required Layers

- Unit tests
- Integration tests
- System/end-to-end tests
- Memory/thread correctness checks via available tooling

## Workflow

### 1) Build critical behavior map

- Map acceptance criteria to modules, interfaces, and execution paths.
- Identify ownership/lifetime boundaries and concurrency-sensitive regions.

### 2) Unit tests

- Cover algorithm correctness, boundary cases, and invariant enforcement.
- Verify error handling and invalid input behavior.

### 3) Integration tests

- Validate interactions across modules and adapters.
- Exercise serialization, file/process boundaries, and protocol behavior as relevant.

### 4) System/end-to-end tests

- Validate executable-level workflows and externally visible behavior.
- Include failure-mode scenarios and recovery behavior.

### 5) Reliability and correctness checks

- Run available sanitizer/tooling checks (address, leak, undefined behavior, thread, bounds) where configured.
- Validate deterministic behavior under repeated runs.

### 6) Credibility gates

- Avoid mocking core algorithms and state machines.
- Use seams for external dependencies only.
- Require falsification checks proving tests fail on intentional logic breakage.

### 7) Completion criteria

- All required layers present with meaningful assertions.
- Reliability/tooling checks integrated where available.
- Defects discovered are returned to `/jr-implement` with reproducible evidence.
- Memory-safety and bounds-check evidence is captured and reported.
