# Mode Selection

## Goal

Infer `/jr-test` execution mode from evidence with minimal user interruption.

## Modes

- `audit`: post-implementation test review and hardening
- `spec-first`: pre-implementation failing test authoring

## Decision Order

1. Explicit user instruction wins.
2. Story-state evidence decides when instruction is absent.
3. Ask one focused question only when confidence is low.

## Evidence Signals

Audit signals:
- Recent code changes exist for story-related implementation paths.
- Story notes/checklist claim implementation progress.
- Existing tests already target story behavior and need review/hardening.

Spec-first signals:
- Implementation files for story behavior are absent or intentionally deferred.
- User asks to write tests first or requests implementation handoff after tests.
- Story is newly started with acceptance criteria defined but no implementation body.

## Confidence Rule

- High confidence:
  - 2+ strong signals for one mode and 0 contradicting strong signals.
  - Proceed without asking.
- Medium confidence:
  - Mixed or weak signals.
  - Ask one question: "Run audit mode or spec-first mode for this story?"

## Default Policy

When unclear but implementation evidence exists, default to `audit`.

## Output Requirement

Before executing, state inferred mode and top evidence in one short block:
- Mode selected
- Key evidence items
- Whether user override was applied
