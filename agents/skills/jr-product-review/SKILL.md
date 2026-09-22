---
name: jr-product-review
description: Run `/jr-product-review` to review the whole product from the user's perspective with findings and explicit coverage.
---

# Product Review

## Purpose

Review whether the product makes sense to someone without its author's context, including
unchanged content and shipped output. This is a direct review workflow; `/jr-code-review`
handles branch changes and corrections.

## Process

### 1. Scope and Inventory

Read repository guidance and any supplied review context. State the review boundary and
track progress with the available planning tool or the review artifact. Default to the
whole project; a requested focus does not silently exclude other areas.

Inspect the repository and release/install manifests. Inventory tracked, untracked, ignored,
generated, and shipped files, including relevant assets outside the checkout. Explicitly
exclude irrelevant caches, dependencies, and repository internals with reasons; do not
exclude content merely because it is unchanged or generated. Expand package inventories
and follow shipped references. Mark unavailable surfaces as gaps.

Create or resume one `.junior/docs/product-review.md` using the Output Spec below. Inspect
existing review documents first; use a distinct descriptive filename for an unrelated
review. Record the repository revision, local changes, and package identities sufficiently
to detect stale coverage. On resume, reconcile added, removed, and changed files and
revisit affected cross-file conclusions before relying on earlier findings.

### 2. Product Examination

Adapt each area to the product and record why any area does not apply:

- **User experience:** follow installation, update, migration, everyday use, and contribution
  as a new user. Examine choices, jargon, ceremony, accessibility, and clarity of next actions.
- **Runtime behavior:** trace supported integrations through discovery, loading, precedence,
  and global/project interaction where applicable. Compare documented and actual behavior.
- **Instruction consistency:** read all rules, skills, references, templates, and commands.
  Compare their authority, scope, and instructions across files for contradictions and repetition.
- **Documentation accuracy:** compare promises with implementation. Run documented commands
  in disposable environments; check defaults, versions, destinations, and examples.
- **Privacy and packaging:** inspect everything shipped, including unchanged and generated
  content, for private context, sensitive examples, local paths, and accidental disclosures.

Read and reason about content. Searches locate evidence; passing tests and keyword scans
do not replace review. Use suitable viewers for non-text assets. Verify changing runtime
claims against official sources and actual local behavior; distinguish source claims from
observations, and record unavailable verification rather than guessing.

Run [product isolation](../_shared/references/product-isolation.md) over the complete
candidate tree and any explicitly scoped pending range. Review indirect workflow leakage
and rendered content separately; literal success never replaces the examination above.

### 3. Findings and Coverage

Update the same artifact after each coherent review segment. Prioritize findings by user
impact, with precise file evidence, the affected journey, and the smallest proposed
correction. Distinguish verified defects, design choices needing judgment, and unverified
assumptions. Cross-file findings cite both sides; a preference alone is not a defect.

Account for every inventoried file as **reviewed**, **mechanically checked**, **excluded
with a reason**, or **unreviewed**. Use explicit paths or an exact enumerated group with
the same disposition; a wildcard must not hide unchecked members. Mechanical checks state
what they establish and leave content review open where needed. Sampling cannot justify
whole-project completion. Reconcile the final inventory; missing evidence and unreviewed
content remain explicit gaps even if no defects were found.

Default to findings first. Review authorization permits the review artifact and disposable
verification, not product fixes, live installation changes, exports, tags, or publication.
Honor separately authorized actions and existing approval gates; review completion does
not satisfy a release gate. Report the outcome and one next action matching the remaining
work. Leave implementation to the normal workflow when authorized.

## Output Spec

**Artifact — the review document.** For the product owner deciding what needs correction
and the next reviewer resuming without repeating completed work.

**Goes in:**
- **Scope:** product, user journeys, applicable review areas, repository/package identities,
  local changes, and boundaries needed to interpret the evidence.
- **Findings:** stable identifiers, priority, defect/design choice/unverified classification,
  file and line or asset-location evidence, expected and observed behavior, user impact,
  smallest proposed correction, and resolution state. Include reproducible checks and
  official source links where needed to substantiate a claim.
- **Coverage:** file inventory and dispositions, reasons for exclusions, the limits of
  mechanical checks, and enough identity information to invalidate stale conclusions.
- **Remaining work:** unreviewed or unavailable surfaces, unresolved decisions, verification
  gaps, and one concrete continuation command or entry point.

**Never goes in:** secrets or copied sensitive content, private examples unnecessary to
explain a finding, speculative diagnoses presented as facts, transcripts, compliance
paperwork, analysis counts used as quality claims, superseded plans, or the story of how
facts were discovered. Cite sensitive locations without reproducing their contents.
Baseline: `../_shared/references/artifact-output-spec.md`. Scope identities, verification
evidence, and coverage are necessary review work product, not a guaranteed audit trail.

**Artifact — the completion response.** For the operator deciding what to do next.
**Goes in:** review document link, highest-impact findings, material coverage gaps, and one
next action. **Never goes in:** the full inventory, duplicated findings, secrets, process
narration, or a claim of complete review unsupported by the document.

**Register for both:** Headings are noun labels — never sentences, questions, or
conversational phrases. Prose states facts. No editorial lead, no anthropomorphising,
no dramatic adjective.

## Tool Integration

Use available file/Git tools for inventory and evidence, terminal/browser tools for
disposable verification, official documentation tools for changing claims, and file editing
tools for the review artifact. If a required tool or environment is unavailable, preserve
the gap and continue independent review work.
