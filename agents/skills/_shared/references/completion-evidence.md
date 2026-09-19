# Completion Evidence

## Coding Verification

This is the shared completion policy for `/jr-implement`, `/jr-test`, and `/jr-commit`.
It applies to executable code, including code shipped inside documentation.

1. **Passing checks:** All applicable tests and required project checks must pass. A
   skipped, disabled, flaky, or unexecuted required check is not a pass. Keep required
   test layers and specialized gates, including context-switch and security checks.
2. **Behavioral coverage:** Map changed behavior and acceptance criteria to tests of
   observable outcomes through the real implementation. Cover success, relevant errors
   and boundaries, and regression risks. Tests must fail when the behavior they claim
   to protect is broken; executing a line or asserting a mocked result is insufficient.
   The post-implementation `/jr-test` credibility audit remains mandatory for coding work.
3. **Project thresholds:** Establish the numeric coverage agreement below before coding
   implementation and meet every applicable threshold. Preserve existing agreed requirements;
   resolve missing or conflicting ones with the owner. Do not lower thresholds or exclude
   code to obtain a pass without explicit owner approval.
4. **Measurement:** Report coverage using the agreed tool, metric, and denominator. An
   unavailable measurement cannot demonstrate that a required threshold passes: record the
   blocker and resolve the tooling or an explicit exception with the owner. Do not invent
   percentages or silently substitute a different metric, scope, or tool.
5. **Gap disposition:** Review uncovered changed paths. For each gap, identify the
   behavior/risk, why additional testing is unnecessary or unavailable, and supporting
   alternative evidence where needed. A rationale alone cannot waive missing evidence for
   required behavior. Unexplained gaps, missing required behavioral tests, unmet project
   thresholds, or incomplete required checks block completion regardless of the percentage.

Explicit owner-approved exceptions must name the omitted requirement and remaining risk;
never report them as passing checks. An authorized WIP commit may preserve incomplete work,
but committing does not satisfy the completion policy.

Report the verdict with test/check results, behavior-to-test mapping, agreed thresholds
and their source, measured coverage (or an explicit blocker/exception), gap dispositions, and the
audit result. Reuse the evidence under the rules below.

Behavioral sufficiency and gap review are agent norms. Configured test and coverage checks
are mechanically enforced only where the project's runner or CI actually executes them.

## Coverage Agreement

`/jr-init` settles this agreement as part of the technical foundation. For an existing
project without it, resolve the missing decision before coding implementation; a full
reinitialization is unnecessary. Existing evidence-backed project agreements carry forward.

For each independently tested component, agree:
- Numeric minimum and metric: line/statement and branch coverage where the tool supports
  them; do not label one metric as another.
- Scope: production source included, whether the minimum applies to the whole component,
  changed code, or both, and justified exclusions such as generated or vendored code.
- Tool, threshold configuration, local gate command, and CI gate when CI exists.
- Rationale based on stack/tool support, risk, testability, and measured baseline for an
  existing project. A baseline below the desired target needs an explicit transition
  agreement with an enforceable current floor and a defined trigger for raising it.

Propose a concrete threshold with that rationale; 90% is a starting proposal for a new
project with suitable tooling, not a universal requirement or a substitute for owner
agreement. Different components may need different metrics or floors. A stricter requirement
for critical behavior still applies even when the aggregate percentage passes.

Record the rationale and scope in `.junior/product/03-tech-stack.md` (or the project's
existing equivalent). Keep executable threshold values in the test/coverage configuration
and link to them from documentation. Put the gate command in the development guide. Where
configuration does not yet exist, the approved specification holds the values until setup
creates the gate; report this as planned, not enforced. Verify the configured gate rejects
a below-threshold result before claiming enforcement.

Documentation-only work has no code-coverage percentage. For a coding component whose stack
cannot produce a meaningful coverage metric, agree and record an explicit owner-approved
exception with alternative verification and remaining risk; missing tooling alone grants
no exemption. An unresolved agreement blocks coding implementation.

## Evidence Reuse

Reconcile acceptance criteria, implementation checklists, and Definition of Done against
specific evidence. Reuse prior recorded evidence when its scope, inputs, and results still
apply to the exact current changes; rerun affected checks when they do not. Do not repeat
verification solely because a different workflow command was entered.

Update only stale or unsupported states. An already accurate checklist needs no edit or
increase in checkmark count. In-progress work can retain justified unchecked items; only
completed work requires all applicable completion criteria to be satisfied.

## Manual Verification

Verify directly where possible. Do not ask again about a criterion supported by applicable
evidence or explicit user verification. For a remaining item that requires the user, ask one
focused question naming the precise criterion and missing observation. Record only what the
reply establishes; a broad yes cannot verify unspecified checks. Missing evidence keeps the
criterion pending and blocks a completion claim, not an explicitly authorized WIP commit.

These are agent workflow norms. Checkboxes and status labels are work product to review,
not an independently enforced audit trail.
