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

## Artifact Cleanup and Retention

Apply this policy when build, implementation, verification, review, or commit work creates
or uses disposable resources: classify them before setup, finalize at their lifecycle
boundary, and reconcile the result before each handoff, including failed or interrupted
work. Follow repository-specific ownership, retention, and deletion-authorization rules.
This policy grants no authority to remove existing storage or unrelated state.

| Category | Disposition |
|---|---|
| Per-run scratch | Remove only resources proven to have been created and owned by this invocation, after dependencies stop and required evidence is preserved |
| Review evidence | Retain in a deliberate destination outside disposable scratch; preserve existing outputs and verify the retained result opens or plays independently |
| Reusable cache | Preserve by default; identify its owner, retention purpose, and supported clear operation if known, without executing an unselected clear |
| Application or user state | Preserve, including resources needed for an authorized interactive handoff; report retained running services and their stop instructions |
| Uncertain ownership or active use | Preserve and name the exact path and missing ownership, dependency, disposition, or access evidence |

1. **Lifetime:** Use the creator's existing context/finally/trap mechanism where available.
   Account for setup failure, run failure, and supported interruption. Stop and await owned
   dependents before disposal; do not stop another owner's process. Do not delete through a
   symlink into external state. Keep necessary live handoff resources deliberately retained.
   Never claim guaranteed cleanup after uncatchable termination or host shutdown.
2. **Evidence:** Select what review requires and preserve it before disposal. Use a distinct
   output destination when existing output files would be overwritten. Verify it remains
   usable without the scratch toolchain, browser profile, or temporary server. Failed export
   retains recovery resources; partial output is not complete evidence.
3. **Measurement:** Verify disposition on the filesystem after finalization. Report the
   measured remaining paths and bytes, distinguishing owned disposable residue from
   deliberately retained outputs, caches, and state, with their retention reasons. Name the
   measured roots and metric (for example, file-content bytes versus allocated disk usage).
   An absent owned scratch path establishes zero residue only for that path; do not scan
   unrelated storage or claim a machine-wide zero. Unavailable measurements stay unverified.
4. **Verdict:** Unknown ownership, active disposable dependencies, failed export, denied
   deletion, or cleanup failure is a named blocker or explicit exception, never a hidden
   pass. Preserve the original run failure alongside any finalization failure. State retained
   paths, measured residue or the measurement blocker, and the specific next action needed.
   Ask only for missing evidence, disposition, or permission; never retry unchanged denial.
5. **Reuse:** Apply Evidence Reuse to cleanup measurements too. Reuse results only when the
   same resource identities, contents, dependency state, and disposition remain applicable;
   remeasure affected resources after changes. A command transition or commit reconciliation
   creates no need to regenerate evidence, repeat valid checks, or clear caches. Other
   completion gates still apply. When no disposable resources were created or used, say so
   instead of manufacturing a cleanup operation.

### Reusable Caches

Record known caches in the consuming project's existing evidence or development guidance,
not an invented machine inventory. Package-manager caches retain reusable downloads/builds;
browser-tool caches retain installed browsers. These belong to their toolchain owner and
are not per-run scratch. For uv, `uv cache dir` identifies the configured cache and
`uv cache clean --cache-dir <resolved-cache-path> [package]` is a supported explicit clear;
run it only for a separately authorized selection after checking active dependencies.
For other tools, consult their installed CLI or project guidance; report unsupported or
unknown clearing rather than inventing a recursive deletion command.

Classification, invocation of finalizers, evidence review, and handoff reporting are agent
norms. Creator code may enforce cleanup on its known paths; this prose guarantees neither
arbitrary agent cleanup nor a complete audit trail. Keep observations in ordinary work
evidence, never present a freehand action log as an authoritative audit record.

## Manual Verification

Verify directly where possible. Do not ask again about a criterion supported by applicable
evidence or explicit user verification. For a remaining item that requires the user, ask one
focused question naming the precise criterion and missing observation. Record only what the
reply establishes; a broad yes cannot verify unspecified checks. Missing evidence keeps the
criterion pending and blocks a completion claim, not an explicitly authorized WIP commit.

These are agent workflow norms. Checkboxes and status labels are work product to review,
not an independently enforced audit trail.
