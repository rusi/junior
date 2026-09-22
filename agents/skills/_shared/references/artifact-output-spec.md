# Artifact Output Spec (Shared Contract)

A skill that specifies how to **think** and never what to **print** makes the thinking become the
artifact. With no stated contents, a run fills the document with whatever it was holding — its own
reasoning, provenance, and superseded drafts.

Every skill that writes an artifact a human reads declares that artifact's spec **at the step that
writes it**, in the skill's own file. A spec in the skill fires; a rule elsewhere has to be recalled,
and recall loses.

## The Three Parts

First classify each destination using **Product Isolation** in `01-structure.md` (resolved
in the selected runtime's rule directory). Apply [product isolation checks](product-isolation.md)
when generating product files or messages. Working documents may point to product artifacts;
an output spec never licenses the reverse. Review copied helpers and rendered content too.

Declared per artifact, in this order.

**1. What this artifact is for.** Who reads it, and what question it answers for them. Declared first
and separately, because separating reasoning from artifact is a different question from whether the
content belongs in this artifact at all. Getting only the first produces a cleaner document that is
still about the wrong things.

**2. Goes in.** The sections, and what each holds.

**3. Never goes in.** Stated explicitly — an exclusion nobody wrote down is not a constraint.

## Exclusion Baseline

These apply to every human-read artifact. A skill states them at its write step and adds whatever
else its own artifact attracts:

- Provenance stamps — when a fact was captured, by which run, from which source scan
- How a fact was found, as distinct from the fact
- The run's own rule-compliance notes and gate paperwork
- Counts of what was analyzed, read, or checked
- Superseded plans and abandoned approaches
- A resolved question kept as a strikethrough with its answer history

**Carve-out:** `## Session Artifact Log` in a story file is exempt. It is provenance, and it stays —
`/jr-commit` parses its `Files touched` paths for staging scope, so it is machine-read and
load-bearing. See `session-artifact-log.md`. Nothing else earns this exemption by resembling it.

## Register

State this at the write step, in this form:

> Headings are noun labels — never sentences, questions, or conversational phrases. Prose states
> facts. No editorial lead, no anthropomorphising, no dramatic adjective.

This line is copied into each skill rather than linked, because a register the run must go and read
is a register that does not fire at the moment of writing.

## The Test

**This spec is the generator's half, and it is a norm.** The verification is a **reader**: `/jr-code-review` Step 5.5 reads every document the branch wrote and asks the question below of each sentence. A script cannot do it — presence of the spec is all one can check, and that is all the suite checks.

Read the finished artifact and ask of each sentence: **why is this here?** If the honest answer is
*because that is how I found out*, it is provenance and it belongs outside the artifact.
