---
name: jr-ui-prototype
description: Run `/jr-ui-prototype` to build, show, and refine interactive interface prototypes with the user before finalizing designs.
---

# UI Prototype

## Purpose

Explore interface decisions through an editable prototype the user can operate and
revise before production implementation. This is an iterative design workflow.

## Type

Contract-style: scope → initial prototype → show → feedback → revise and show again
→ user acceptance → final verification and specification.

## When to Use

- The operator invokes `/jr-ui-prototype` for interface design work.
- A parent planning skill explicitly loads this workflow for its approved UI scope.
- Use `/jr-demo` for evidence of implemented application behavior; a prototype proves
  only its own interactions, never production functionality.

## Process

### 1. Context and Scope

Track context, initial prototype, user review, revisions, and finalization with the
available plan tool or an explicit checklist. Mark user review pending until answered.

Read the real application's layout, navigation, components, styles, and relevant
behavior before designing. Inspect the running interface when available; distinguish
observed behavior from source-only understanding. If no interface exists, establish
the intended visual and interaction constraints with the user.

For a parent invocation, reuse its requirements, application findings, approved scope,
specification destination, existing artifacts, and unresolved design questions. Read
only missing context. The parent's approval covers the agreed prototype work; do not
repeat its discovery or ask for the same scope approval again.

For standalone use, clarify missing requirements one question at a time and agree a
short contract: design question, affected surface, interactions, fidelity, and artifact
location. Use the relevant existing specification. Without one, create a scoped
experiment under `.junior/experiments/`, following `01-structure.md`.

Choose proportional fidelity. A minor visual adjustment can use a focused preview in
the existing layout. Behavior or layout decisions need an interactive prototype.
Neither path skips showing the draft and receiving the user's response. If the parent
has no interface design work, return without creating an artifact.

### 2. Initial Prototype

Use available rendering tools and the project's conventions; prescribe no framework.
Reuse the actual application's visual language and place the change in its surrounding
layout. Build the smallest runnable draft that answers the agreed design question,
including the meaningful states needed to evaluate it. Avoid unrelated screens or
polish before the user has seen this draft.

Write directly beside the specification in `specs/mockups/`, adapting to its existing
structure. Prefer one editable, runnable source where practical. If rendering requires
a build, retain its source, assets, and exact launch/build instructions alongside the
runnable output. Do not let a temporary preview URL be the only deliverable.

Label synthetic fixtures visibly. Explain simulated behavior and unsupported controls;
do not invent real results, usage, measurements, persistence, or verification. Keep
fixtures isolated from live writes and outbound integrations. Production changes need
their own implementation scope.

Apply the **Output Spec** below when writing the draft and its specification.

### 3. Show and Receive Feedback

Check only that the draft opens and the main interaction can be tried. Fix anything
that prevents review, then show it immediately using the runtime's preview facility
and provide a direct artifact link with launch instructions. Capture the state needed
to orient the user; do not delay the first showing for a screenshot set, a test suite,
edge-case analysis, accessibility audits, responsive sweeps, or visual polish. Name
what the user can try and the main unresolved design question.

Ask one focused feedback question and wait for the answer before choosing the next
design revision or finalizing. Presenting screenshots alone is insufficient when the
user needs to explore interactions. A file left on disk without a usable opening path
has not been shown.

Do not treat silence, passing checks, an instruction to continue exploring, or approval
of the scope as acceptance of the design. If feedback is pending, retain the draft and
report that review is pending. Do not return an accepted design to the parent.

### 4. Revision Loop

Interpret the user's feedback against the design question and revise the same artifact.
Keep its specification, runnable output, and displayed screenshots synchronized.
Rebuild from source where needed; recapture affected states instead of keeping stale images.

Check only the changed flow needed to demonstrate the revision, then **show the revised
prototype again and ask for feedback**. Defer broad verification and missed-detail
analysis to finalization. Repeat this loop until
the user explicitly accepts the current design. Do not batch speculative redesigns
between review points or describe agent-only refinement as user iteration.

Resolve material scope changes with the parent or user before extending the prototype.
Minor refinements within the agreed scope do not require a new contract. If the user
has signaled held feedback, receive it before the next revision.

### 5. Finalization

Only after the user accepts the current design, review it for missed details and
relevant edge cases, including empty, loading, error, and long-content states where
applicable. Run the broader browser checks on the retained runnable artifact: agreed
user flows and state transitions, keyboard operation and focus, and representative
viewport sizes. Capture the meaningful state set, inspect screenshots visually, and
verify specification links and launch/build instructions from the retained source.
Report unavailable checks accurately; never substitute intended behavior for a run.

Fix verification failures. If a fix changes the accepted appearance or interaction,
return to the revision loop and show the result for acceptance. A technical repair
that preserves the accepted design still requires re-verification and fresh captures.

Finalize the UI specification around the accepted behavior and its fixture limitations.
Keep production implementation tasks and acceptance criteria unchecked. Prototype
design acceptance and prototype browser verification are separate from production DoD.

For parent use, return artifact paths, accepted design decisions, fixture limitations,
actual verification and any unresolved requirements. The parent reconciles its final
specification and owns its review and the commit offer; do not nest a commit offer.
For standalone use, follow the [planning completion handoff](../_shared/references/planning-completion.md)
for the reviewed prototype and its related specification. Design acceptance alone
does not authorize a commit.

## Output Spec

Baseline: [artifact output spec](../_shared/references/artifact-output-spec.md).
Apply these contents at each write and update, including drafts.

### UI Specification

- **For:** the user evaluating the design and the developer implementing it; answers
  what the interface does and how to open and inspect its prototype.
- **Goes in:** interface and layout; user flows and meaningful states; keyboard and
  responsive behavior; relative links to editable source and runnable output; exact
  launch/build instructions; embedded screenshots with factual state captions;
  fixtures and unsupported behavior; observed prototype verification and remaining
  checks clearly separated from production requirements. Identify pending review
  without an approval-history narrative.
- **Never goes in:** discovery narration, rule-compliance paperwork, source-scan counts,
  provenance stamps, abandoned drafts, feedback transcripts, invented measurements,
  or claims that prototype checks prove production behavior.

### Prototype and Screenshots

- **For:** the user exploring the proposal; answers how the design looks and responds
  to the interactions being considered.
- **Goes in:** editable source and necessary assets, reproducible runnable output,
  realistic fixtures explicitly identified as such, working scoped controls, explicit
  unsupported behavior, and browser-captured images of the matching source's states.
- **Never goes in:** live mutations, undisclosed simulation, real private data copied
  into fixtures, stale screenshots, agent reasoning or verification tooling presented
  as product UI, or unrequested screens and features.

### Review Response

- **For:** the user deciding what to try, change, or accept next.
- **Goes in:** the opening link, brief interaction guidance, what changed in a revision,
  the relevant screenshots, actual verification limits, and one feedback question.
  On completion, provide artifact paths and the appropriate parent return or commit offer.
- **Never goes in:** invented feedback, assumed acceptance, a claim of completion while
  review is pending, a chronological activity report, or a nested commit offer.

**Register:** headings are noun labels — never sentences, questions or conversational
phrases. Prose states facts. No editorial lead, no anthropomorphising, no dramatic adjective.

## Tool Integration

Use repository search and file tools for context and retained artifacts; available
rendering tools for the prototype; browser tools for interaction, viewport, keyboard,
and screenshot checks; and the runtime's preview facility to show the result.
Follow [tool selection](../_shared/references/tool-selection.md). Missing rendering or
browser access is a stated limitation to resolve, never evidence of verification.

## Examples

- `/jr-ui-prototype` to explore navigation within an existing application layout.
- A planning skill passes an approved form change and its specification destination;
  this workflow returns the design only after the user has reviewed and accepted it.
