---
name: jr-integrate
description: Run `/jr-integrate` to acceptance-test all changes on develop since main, fixing what fails inline.
---

# Integrate Command

## Purpose

Walk the user through acceptance-testing all changes on the integration branch since the base branch, grouped by feature or maintenance concern, using agent reports and specs to provide informed testing guidance and fixing issues inline before final merge.

## Type

Direct execution — Interactive, step-by-step with user at each gate

## When to Use

- Features have been merged into an integration branch by agents
- User needs to verify and acceptance-test before promoting to the base branch
- Want informed, feature-by-feature walkthrough with fix-in-place workflow

## Process

### Step 1: Initialize Progress Tracking

Create todos:

```json
{
  "todos": [
    {"id": "preflight", "content": "Verify working tree and inventory all changes", "status": "in_progress"},
    {"id": "walk-features", "content": "Walk user through each review group", "status": "pending"},
    {"id": "summary", "content": "Present verification summary", "status": "pending"}
  ]
}
```

### Step 2: Preflight

1. **Verify clean working tree** — `git status --short` must be empty. If dirty, ask user to commit or stash first.
2. **Ensure on integration branch** — check current branch. If not on the integration branch (typically `develop`), ask user to confirm switching.
3. **Identify base branch** — typically `main`. Confirm with user if ambiguous.

### Step 3: Inventory the Complete Integration Range

Resolve and record the base and integration commit IDs. Use those fixed IDs for both
`git log --reverse --topo-order --format='%H %P %s' <base>..<integration>` and
`git diff --find-renames --ignore-submodules=none <base> <integration>`. Review the complete
diff, including deletions, renames, configuration, tooling, documentation, submodule revision
changes, and merge-resolution edits. Keep submodules visible even when local Git configuration
normally hides them.
Merge subjects and branch names are context, never the inventory boundary.

Reconcile the full commit range and final diff into a coverage map:
- Group related changes by feature or maintenance concern, regardless of merge, squash,
  fast-forward, or direct-commit history. One commit can affect several groups.
- For each group, name its commits, final changed paths/behaviors, applicable specs,
  acceptance checks, evidence, and result. Order groups by first appearance in the range.
- Account for reverted or superseded commits with their final-state disposition. Inspect
  their replacement rather than testing behavior that no longer exists.
- Keep unmatched changes as explicit review groups; absent specs do not exclude them.
  Every final diff change and every range commit needs a disposition before promotion.

Grouping and acceptance scope require agent judgment; these commands enumerate changes,
not proof of coverage. Update todos from the reconciled groups, not from merge count.

### Step 4: Feature-by-Feature Walkthrough

Run [product isolation](../_shared/references/product-isolation.md) for the complete
integration tree and the recorded range. Keep its literal findings, semantic review, and
rendered-content findings in the coverage map; repeat affected checks after inline fixes.

**For each inventory group (oldest first):**

#### 4a. Gather Context (Read Both Code AND Reports)

**Code changes:**
- Read the group's portion of the recorded base-to-integration diff and its contributing
  commits; for merge commits, inspect the first-parent diff for resolution changes.
- Identify changed behavior and files from the coverage map, including non-feature groups.

**Specs and reports** — search `.junior/` for the feature's artifacts:
- Feature overview (`feat-N-overview.md`)
- Story files and progress tracking
- QA reports (look in feature's directory and `reviews/`)
- Code review reports
- Verification results and test evidence
- Any blocked, unverified, or partially-tested items

Read these artifacts to understand:
- What agents already tested and verified (with evidence)
- What agents explicitly flagged as needing human validation
- What was marked blocked, unverified, or incomplete
- What acceptance criteria exist and their verification status

#### 4b. Show What the Feature Does

**A feature is easier to acceptance-test when you have seen it before you start clicking.**

If the feature changed anything a person can see, invoke `/jr-demo` for it, supplying:

- The **profile** — the `references/` profile in `jr-demo` matching this project's test runner.
  Step 4a has already read this feature's specs and diff, so name it rather than leaving the
  demo to infer it.
- The **scope** — feature-level, this feature. The demo composes that feature's story Demo
  Scripts in order into one storyboard; stories missing a script get one authored first.
- The **feature directory** — where the stories, and their scripts, are.

Where the group changed nothing rendered, skip this and say so in the guidance below. A
storyboard of a backend feature is eight identical screens and teaches the user to stop opening
them.

**One feature, one storyboard.** Capture the final integrated behavior once per feature,
using the commits and paths grouped in the coverage map. Reuse that artifact within the
group; commit topology does not create additional walkthroughs.

Include the storyboard path in the testing guidance, on its own line. It is the fastest way into
a feature the user did not write, and it is what makes the difference between reading a diffstat
and knowing what to try.

**If a demo assertion fails, that is a finding, not a blocked step.** The feature merged in a
state its own walkthrough cannot reach. Report it as an issue and take it into 4e, exactly as if
the user had found it by hand — which is the failure this makes cheap to catch before they do.

#### 4c. Present Informed Testing Guidance

Based on the gathered context, categorize the feature into one of two modes:

**Mode A — Experience Walkthrough:**
- Agents verified core functionality with evidence (tests pass, QA reports clean)
- User should: try the feature end-to-end, confirm UX feels right, validate the experience
- Present: feature summary, what agents verified, suggested walkthrough steps

**Mode B — Human Validation Required:**
- Agents could not fully verify some aspects (runtime behavior, UX judgment, environment-specific, manual verification items, blocked checks)
- User should: focus on specific unverified items
- Present: exactly what needs human verification and why agents couldn't verify it

**Present format:**

```
## Review Group N of M: [feature or maintenance concern]

**Commits:** [contributing commit IDs; branch name if known]
**Changes:** [diffstat summary — files changed, insertions, deletions]
**Key files:** [list most significant changed files]

### Testing Guidance

[Mode A or Mode B header]

**What agents verified:**
- [list verified items with evidence references]

**What needs your attention:**
- [specific items to test, with context on why]

### Suggested Test Steps
1. [concrete step based on the feature's acceptance criteria]
2. [...]

Ready to test? [yes / skip / details]
```

- **yes** — user will test now
- **skip** — skip this feature (record as skipped, not verified)
- **details** — show full diff, specs, or report contents

#### 4d. User Tests and Reports Back

Wait for user to test. User responds with:
- **pass** — feature verified, move to next
- **issues: [description]** — problems found

#### 4e. Fix Issues (If Any)

When user reports issues:

1. Spawn an agent (using the Agent tool) to investigate and fix the issue on the current branch
2. The agent should:
   - Read the user's issue description
   - Investigate the relevant code
   - Implement the fix
   - Run tests to verify the fix
   - Commit the fix
3. After the agent completes, present the fix summary to the user
4. Ask user to retest the specific issue
5. Repeat until user confirms pass

#### 4f. Record Result and Advance

Mark feature as verified (pass) or skipped in the todo list. Move to next feature.

### Step 5: Verification Summary

After all review groups are walked through, present:

```
## Integration Verification Summary

**Base:** [base branch] → **Integration:** [integration branch]
**Review groups:** N

| # | Review group | Result |
|---|---------|--------|
| 1 | [subject] | Verified |
| 2 | [subject] | Verified (with fixes) |
| 3 | [subject] | Skipped |

**Fixes applied:** [count] commits

### Next Steps
- If all groups verified and final reconciliation is complete: merge integration branch into base
- If any unmatched, skipped, blocked, or unverified: resolve those groups before merging
```

Before suggesting promotion, resolve both branch tips again and reconcile the coverage map
against the complete current range and diff, including inline fixes. If either tip changed,
review the delta and rerun affected acceptance checks; retain evidence only where still valid.
Report unmatched, skipped, blocked, or unverified groups explicitly. Suggest the merge command
only when none remain and every group's applicable acceptance checks pass. An empty merge
log is never evidence that the integration range has no work.

### Step 6: Output Spec

**Artifact — the verification summary.**

- **For:** the user deciding whether to merge the integration branch. It answers *what was tested,
  what passed, and what stands in the way.*
- **Goes in:** the template above, filled — branches, review-group count, the result table, fixes
  applied, next steps.
- **Never goes in:** the walkthrough transcript, or what was clicked to reach a verdict · specs and
  agent reports quoted at length where the guidance already used them · features enumerated with
  no result to report · the steps of this skill. A feature that was skipped is one row with the
  reason, not a narrative. Baseline: `../_shared/references/artifact-output-spec.md`.
- **Register:** headings are noun labels — never sentences, questions or conversational phrases.
  Prose states facts. No editorial lead, no anthropomorphising, no dramatic adjective.

## Tool Integration

**Primary tools:**
- Git commands — branch detection, merge log, diffs, diffstat
- File reads — `.junior/` specs, QA reports, review reports, story files
- Agent tool — spawn fix agents when user reports issues
- User interaction — testing guidance, pass/fail collection

**Parallel execution opportunities:**
- Read multiple `.junior/` artifacts in parallel when gathering feature context
- Diffstat and artifact reads can run concurrently

## Error Handling

**No changes found:** Report nothing to review only after inspecting both the complete
commit range and base-to-integration diff. If the range contains commits but the final diff
is empty, record why (for example, reverted changes). If only the merge log is empty,
continue the normal inventory and walkthrough.

**Dirty working tree:**
```
Working tree has uncommitted changes. Please commit or stash before running /jr-integrate.
```

**Feature artifacts not found:**
If `.junior/` artifacts cannot be found for a review group, fall back to code-only analysis — present the diffstat and changed files without spec/report context. Note the missing context to the user.

---

Verify before you ship. One feature at a time.
