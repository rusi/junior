# C/C++ Tooling Guidance

## Preferred Tooling (Modern Defaults)

- Unit/integration frameworks: GoogleTest, Catch2, or project-standard equivalent
- Sanitizers:
  - AddressSanitizer (ASan)
  - LeakSanitizer (LSan)
  - UndefinedBehaviorSanitizer (UBSan)
  - ThreadSanitizer (TSan) when concurrency exists
- Bounds/memory diagnostics: compiler warnings + sanitizer evidence; Valgrind where sanitizers are unavailable
- Coverage: gcov/lcov or llvm-cov depending on toolchain

## Required Safety Checks

- Memory leak checks on representative workflows.
- Out-of-bounds and undefined behavior checks enabled in CI/local validation path.
- Concurrency safety checks for multi-threaded components.

## Required Test Layers

- Unit tests for algorithms/invariants.
- Integration tests for module boundaries and protocol/data interchange.
- System tests at executable boundary for real workflows.

## Anti-Patterns to Reject

- Treating sanitizer failures as non-blocking warnings.
- Relying only on unit tests without executable-level validation.
- Mocking core state machines while claiming correctness coverage.
