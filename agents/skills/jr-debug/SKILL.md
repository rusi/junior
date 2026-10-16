---
name: jr-debug
description: Run `/jr-debug` to investigate unexplained failures and verify their root cause.
---

# Debug

## Purpose

Systematic debugging workflow that transforms vague "something's broken" into structured investigation plans with clear hypotheses, evidence-based testing, and documented resolutions.

## Type

Contract-style for a new investigation; continuation reuses the approved objective and existing evidence.

## When to Use

- Encountering an issue you can't immediately explain
- Need systematic investigation approach
- Want to document debugging process for future reference
- Issue is complex enough that guessing won't work

## Entry Check

Before creating an investigation plan or contract, read any supplied finding or resolution and apply the workflow selection in `00-junior.md`, **Suggest ONE next step**. State the unresolved causal question that warrants investigation. If the evidence instead directs implementation, hand the existing finding or resolution to `/jr-implement`; do not manufacture hypotheses or create another investigation package.

Apply `00-junior.md`, **Authorized Continuation**, at every workflow transition. An existing
approved investigation does not need another contract approval merely because a diagnostic
step needs implementation or an implementation attempt needs diagnosis.

## Execution Pattern

**Simple investigations** (execute immediately):
- Read logs, check configs, grep patterns
- Run diagnostic commands
- Compare known-good vs broken states
- Example: "Why is service crashing?" → Check logs, verify config, test

**Complex investigations** (use `/jr-implement` for execution):
- Build test applications
- Hardware/embedded testing (flash firmware, collect data)
- Try alternative frameworks/stacks
- Multi-step experiments requiring code changes
- Example: "Embedded device notifications not working" → Build minimal test app, flash, compare with working implementation

**When the entry check establishes a need for investigation, this command:**
1. Creates an investigation plan (hypotheses, steps, expected evidence)
2. Executes immediately if simple (Steps 1-8)
3. Routes complex execution to `/jr-implement` under Authorized Continuation; a planning-only request ends with the plan

## 🔴 CRITICAL: Evidence-Based Investigation

**This command enforces rigorous evidence-based debugging:**

- **NO assumptions** — Every conclusion must cite specific evidence
- **NO jumping to conclusions** — Test hypotheses systematically, don't skip steps
- **Document negative results** — "Ruled out because [specific evidence]"
- **Uncertainty is acceptable** — "Inconclusive, need more data" is valid
- **Challenge premature conclusions** — If user suggests cause without evidence, push back
- **One hypothesis at a time** — Don't conflate multiple theories

**If you (the LLM) catch yourself making assumptions, STOP and gather evidence first.**

## Process

### Step 1: Verify Git State

```bash
git status --short
```

If not clean, identify the changed paths and their ownership. Preserve unrelated work;
continue changes belonging to this investigation under `00-junior.md`, **Authorized
Continuation**. Ask only when conflicting edits or unclear ownership prevent safe execution.
A commit recommendation is not a prerequisite for continuing the approved investigation.

### Step 2: Initialize Tracking

```json
{
  "todos": [
    {"id": "scan", "content": "Scan context and existing debug sessions", "status": "in_progress"},
    {"id": "clarify", "content": "Clarify symptoms and context", "status": "pending"},
    {"id": "hypotheses", "content": "Form and rank hypotheses", "status": "pending"},
    {"id": "contract", "content": "Present debug contract", "status": "pending"},
    {"id": "generate", "content": "Generate investigation plan", "status": "pending"},
    {"id": "investigate", "content": "Execute investigation steps", "status": "pending"}
  ]
}
```

### Step 3: Context Scan

- `list_dir` or `functions.shell_command` `.junior/debugging/` for existing debug sessions
- `codebase_search` or `functions.shell_command` for related code and error patterns
- Load project context if available
- Identify next debug number (dbg-1, dbg-2, etc.)

**Output:** Brief context summary (no files yet)

### Step 4: Symptom Clarification Loop

**Mission:**
> Transform vague problem description into clear, reproducible symptoms. Build 95% confidence before forming hypotheses.

**Internal gap analysis (don't show user):**

Silently identify missing details, then ask ONE focused question at a time:

- **What's happening vs expected?**
  - Example: "What behavior are you seeing? What should happen instead?"
- **When did it start?**
  - Example: "When did you first notice this? What changed around that time?"
- **Reproduction steps?**
  - Example: "Can you reproduce it? What exact steps trigger the issue?"
- **Environment/context?**
  - Example: "What environment is this in? (device, OS, config, etc.)"
- **Error messages/logs?**
  - Example: "Are there any error messages, stack traces, or relevant logs?"
- **What have you tried?**
  - Example: "What debugging have you already attempted?"
- **Frequency/consistency?**
  - Example: "Does it happen every time, or intermittently?"

**Process:**
- Target highest-impact unknowns first
- After each answer, scan codebase for additional context if relevant
- Never declare "final question" - let conversation flow naturally
- User signals when ready by responding to contract proposal

**Critical analysis responsibility:**

Junior must push back when:
- Symptoms are too vague to investigate
- User jumps to conclusions without evidence
- Multiple issues are conflated
- Root cause is assumed rather than investigated

**Pushback phrasing:**
- "Before we assume [X] is the cause, let's verify with evidence. What makes you think it's [X]?"
- "This could be multiple separate issues. Let's focus on [most specific symptom] first."
- "I need more concrete reproduction steps to form useful hypotheses."

### Step 5: Hypothesis Formation

**After symptoms are clear, form hypotheses:**

**🔴 CRITICAL: Evidence-Based Hypothesis Ranking**

Rank hypotheses by:
1. **Evidence strength** — What symptoms support this theory?
2. **Likelihood** — Given the evidence, how probable is this cause?
3. **Testability** — How easy is it to confirm or rule out?

**Each hypothesis MUST include:**
- What it explains (which symptoms)
- What it doesn't explain (gaps)
- How to test it (specific steps)
- Expected evidence if true vs false

**Present hypotheses to user for validation before contract.**

### Step 6: Present Debug Contract

```
## Debug Contract

**Issue:** [One sentence summary of the problem]
**Symptoms:** [Key observable behaviors]
**Reproducible:** [Yes/No/Intermittent]

**Hypotheses (ranked by likelihood):**

1. **[Hypothesis 1]** (High likelihood)
   - Explains: [symptoms it accounts for]
   - Test: [how to verify]

2. **[Hypothesis 2]** (Medium likelihood)
   - Explains: [symptoms it accounts for]
   - Test: [how to verify]

3. **[Hypothesis 3]** (Low likelihood)
   - Explains: [symptoms it accounts for]
   - Test: [how to verify]

**Investigation Approach:**
- Start with highest likelihood, easiest to test
- Document findings for each step
- Adjust hypotheses based on evidence

**⚠️ Unknowns:**
- [Things we can't explain yet]
- [Areas needing more investigation]

---
Options: yes | edit: [changes] | add-hypothesis
```

For a new contract, obtain approval for unresolved scope or design decisions before dependent execution. Reuse approval already present in the session; do not ask again for an unchanged objective. Complex implementation uses the routing in Step 7.5.

### Output Spec

Applies to every document this skill writes, in Step 7 and Step 9. The templates below fix the
sections; this fixes what belongs in them.

**What each artifact is for:**

- **`dbg-N-overview.md`** — read by anyone picking up the investigation. Answers *what is broken and
  under what conditions.*
- **`dbg-N-steps.md`** — read to decide what to test next. Answers *what we believe and in what
  order we are testing it.*
- **`dbg-N-step-M-*.md`** — read to see whether a hypothesis held. Answers *what was tested, what
  the evidence showed, and what it rules in or out.*
- **`dbg-N-resolution.md`** — read by whoever hits this again, possibly years later. Answers *what
  the cause was, what fixed it, and how to stop it recurring.*

**Never goes in any of them:**

- Which files were read or searched to form a hypothesis, where the hypothesis stands on its own
- Hypotheses that were never tested and are no longer live
- A disproved hypothesis kept as a struck-through line with its history — a disproved hypothesis is
  a **finding** (it rules something out), so state it as one in the step's Conclusion, or drop it
- Speculation retained beside the evidence that replaced it
- Which run recorded a finding, or when it was captured
- The skill's own steps, by name or number

Baseline: `../_shared/references/artifact-output-spec.md`.

**Register:** headings are noun labels — never sentences, questions or conversational phrases. Prose
states facts. No editorial lead, no anthropomorphising, no dramatic adjective. Evidence is quoted
or cited, never characterised.

### Step 7: Generate Debug Package

#### 7.1: Create Directory Structure

```
.junior/debugging/dbg-{N}-{name}/
├── dbg-{N}-overview.md              # Problem, symptoms, context
├── investigation/
│   ├── dbg-{N}-steps.md             # Hypotheses + investigation plan + progress
│   ├── dbg-{N}-step-1-{name}.md     # Individual step: hypothesis + test + findings
│   └── dbg-{N}-step-M-{name}.md
└── dbg-{N}-resolution.md            # Root cause + fix approach (created after investigation)
```

#### 7.2: Generate dbg-N-overview.md

```markdown
# Debug: [Issue Name]

> Created: [Date from 02-current-date rule]
> Status: Investigating
> Reproducible: [Yes/No/Intermittent]

## Problem Summary

[One paragraph description of the issue]

## Symptoms

- [Observable behavior 1]
- [Observable behavior 2]
- [Error messages if any]

## Reproduction Steps

1. [Step 1]
2. [Step 2]
3. [Expected vs actual result]

## Environment

- **System:** [OS, device, etc.]
- **Version:** [App/library versions]
- **Configuration:** [Relevant config]

## Context

- **When started:** [Date/event]
- **What changed:** [Recent changes that might be related]
- **Previous attempts:** [What debugging was already tried]

## Investigation

See [investigation/dbg-{N}-steps.md](./investigation/dbg-{N}-steps.md) for hypotheses and plan.
```

#### 7.3: Generate dbg-N-steps.md

````markdown
# Investigation Plan

> **Issue:** [Issue Name]
> **Status:** In Progress
> **Current Step:** 1

## Hypotheses (Ranked)

| # | Hypothesis | Likelihood | Evidence For | Status |
|---|------------|------------|--------------|--------|
| 1 | [Hypothesis 1] | High | [symptoms it explains] | Testing |
| 2 | [Hypothesis 2] | Medium | [symptoms it explains] | Pending |
| 3 | [Hypothesis 3] | Low | [symptoms it explains] | Pending |

## Investigation Strategy

- Start with highest likelihood hypotheses
- Document ALL findings (positive and negative)
- Adjust hypotheses based on evidence
- Stop when root cause is confirmed with evidence

## Steps Summary

| Step | Hypothesis | Status | Conclusion |
|------|------------|--------|------------|
| 1 | [Hypothesis being tested] | 🔵 In Progress | - |
| 2 | [Next hypothesis] | ⚪ Pending | - |

## Decision Tree

[Optional: Add decision tree if multi-step investigation with fallbacks]

```
Step 1: [First test]
    ✅ Works → [What this means]
    ❌ Fails → Step 2

Step 2: [Fallback test]
    ✅ Works → [What this means]
    ❌ Fails → Step 3
```

## Quick Links

- [Step 1: {name}](./dbg-{N}-step-1-{name}.md) ⭐ START HERE
- [Step 2: {name}](./dbg-{N}-step-2-{name}.md) (if Step 1 fails)
- [Step 3: {name}](./dbg-{N}-step-3-{name}.md) (if Step 1 & 2 fail)
````

#### 7.4: Generate Individual Step Files

**🔴 CRITICAL: Create skeleton files for ALL planned steps upfront**

- **Step 1:** Detailed file with complete test procedure (actively being worked on)
- **Steps 2-N:** Skeleton files with template (ready to fill when needed)

**Why:** Complete investigation plan from the start, not "figure it out later"

**dbg-{N}-step-{M}-{name}.md template:**

````markdown
# Step {M}: [Hypothesis Name]

> **Status:** Not Started
> **Hypothesis:** [Specific theory being tested]

## What We're Testing

**Hypothesis:** [Clear statement of what we think might be wrong]

**This would explain:**
- [Symptom 1 this accounts for]
- [Symptom 2 this accounts for]

**This would NOT explain:**
- [Any symptoms this doesn't cover]

## Test Procedure

### Steps to Test

1. [ ] [Specific action - command, check, inspection]
2. [ ] [Next action]
3. [ ] [Final verification]

### Expected Evidence

**If hypothesis is TRUE:**
- [What we would observe]
- [Specific values, errors, behaviors]

**If hypothesis is FALSE:**
- [What we would observe instead]
- [Evidence that rules this out]

## Findings

> **🔴 CRITICAL: Document actual observations, not interpretations**

### Observations

[Fill in during investigation - what did you actually see?]

### Evidence Collected

```
[Paste actual output, logs, values here]
```

### Analysis

[What does this evidence tell us? Be specific.]

## Conclusion

> **Status:** [Confirmed / Ruled Out / Inconclusive]

**Evidence-based conclusion:**

[State conclusion with specific evidence citations]

- [ ] Hypothesis confirmed — proceed to resolution
- [ ] Hypothesis ruled out — [specific evidence]
- [ ] Inconclusive — need [additional investigation]

## Next Steps

**If this step succeeds/fails:**
- [Action A]
- [Action B]

**If inconclusive:**
- [What additional data needed]
- [Alternative approaches]
````

**🔴 For Step 2+ (skeleton files):**

Create skeleton with same template structure but mark sections clearly:

- **Test Procedure:** Brief description or "To be determined based on Step 1 results"
- **Steps to Test:** High-level outline (can be refined when reached)
- **Expected Evidence:** General expectations
- **Findings:** Empty (will fill when executing this step)
- **Conclusion:** Not Started

**Example skeleton for Step 2:**

```markdown
# Step 2: Test Alternative Device

> **Status:** Not Started (Fallback if Step 1 fails)
> **Hypothesis:** [Brief hypothesis]

## What We're Testing

**Hypothesis:** [One sentence theory]

**This would explain:**
- [Key symptom]

**This would NOT explain:**
- [Gap]

## Test Procedure

### Steps to Test

1. [ ] [High-level step 1 - details to be determined]
2. [ ] [High-level step 2]
3. [ ] [High-level step 3]

### Expected Evidence

**If hypothesis is TRUE:**
- [General expectation]

**If hypothesis is FALSE:**
- [General expectation]

## Findings

[To be filled when executing this step]

## Conclusion

> **Status:** Not Started

[To be filled when executing this step]

## Next Steps

[To be filled based on results]
```


### Step 7.5: Decide Execution Strategy

**After generating debug package, assess complexity:**

**Simple Investigation (execute immediately):**
- ✅ Checking configuration values
- ✅ Reading log files
- ✅ Grepping for patterns
- ✅ Running diagnostic commands
- ✅ Comparing file contents
- ✅ Verifying environment variables

**Complex Investigation (route execution through `/jr-implement`):**
- ❌ Building test applications
- ❌ Writing new code/components
- ❌ Flashing hardware
- ❌ Testing across multiple devices
- ❌ Trying alternative frameworks/stacks
- ❌ Multi-hour investigations

**Decision:** Apply Authorized Continuation to the actual next action. For authorized complex
execution, load `/jr-implement` with the existing step, execute its gates, and return findings
to this investigation. For simple diagnostics, continue to Step 8. Stop at the plan when the
user requested planning only; request a decision only when the next action crosses an
unapproved boundary. Complexity alone does not require the user to invoke another command.

### Step 8: Investigation Execution

**⚠️ Only proceed if investigation is simple (no implementation required)**

**For each step, Junior must:**

1. **Read the step file** — Understand what's being tested
2. **Execute test procedure** — Run commands, check logs, inspect code
3. **Document observations** — Record exactly what was seen (not interpretations)
4. **Analyze evidence** — What does this tell us?
5. **Draw conclusion** — Confirmed, ruled out, or inconclusive (with evidence)
6. **Update step status** — Mark complete with conclusion
7. **Update dbg-N-steps.md** — Update progress table

**🔴 CRITICAL: After each step completion:**

```
📊 Investigation Progress

Issue: [Issue name]
Current Step: Step {M} complete

Hypotheses:
✅ H1: [Ruled out - evidence: X]
🔵 H2: [Testing now]
⚪ H3: [Pending]

Findings so far:
- [Key finding 1]
- [Key finding 2]

Next: [What we'll test next and why]
```

**Symbols:**
- ✅ = Confirmed or Ruled Out (with evidence)
- 🔵 = Currently Testing
- ⚪ = Pending
- ⚠️ = Inconclusive (needs more data)

### Step 9: Resolution Documentation

Keep investigation evidence in working material. Any separately requested product documentation uses [product isolation](../_shared/references/product-isolation.md), including complete-tree checks before handoff.

**When root cause is identified (with evidence):**

Create `dbg-{N}-resolution.md`:

```markdown
# Resolution: [Issue Name]

> **Status:** Root Cause Identified
> **Date:** [Date]
> **Investigation:** [Link to dbg-N-overview.md]

## Root Cause

**Confirmed cause:** [Clear statement of what's wrong]

**Evidence:**
- [Specific evidence 1]
- [Specific evidence 2]
- [How we confirmed this was the cause]

## Why This Happened

[Brief explanation of how this issue came to be]

## Fix Approach

### Recommended Fix

[Description of how to fix the issue]

### Implementation Notes

- [Key consideration 1]
- [Key consideration 2]
- [Potential side effects to watch for]

### Testing the Fix

- [ ] [How to verify the fix works]
- [ ] [Regression tests needed]

## Prevention

**How to prevent this in the future:**
- [Process change, if any]
- [Code pattern to avoid]
- [Monitoring to add]

## Next Steps

- [ ] Implement the verified correction with `/jr-implement`, using this resolution
- [ ] Verify the original reproduction and applicable regression checks

---

**Related:** `/jr-implement` accepts this resolution as the implementation work item.
```

**Update dbg-N-overview.md to the same evidence-supported status:**

```markdown
> Status: Root Cause Identified
```

Cause identification completes diagnosis, not the fix. Keep implementation and verification
items pending until performed. After implementation, use `Fix Implemented — Verification
Pending` in both documents while checks remain. Set both to `Resolved` only when the fix is
implemented, the original reproduction passes, and applicable regression and acceptance
checks have supporting evidence. Record that evidence beside the completed checks. A
resolution filename alone never establishes completion.

**Continuation and handoff:** Apply Authorized Continuation to the verified correction.
When implementation is already authorized, announce the evidence-supported correction and
load `/jr-implement` with the resolution in this session. When the requested diagnosis or
plan is the complete deliverable, report it and recommend one continuation. If a decision
or permission is missing, identify the actual boundary rather than asking the user to
repeat a skill invocation.

## Tool Integration

**Primary tools:**
- `todo_write` or `functions.update_plan` - Progress tracking
- `list_dir` or `functions.shell_command` - Scan debugging sessions
- `codebase_search` or `functions.shell_command` - Find related code, error patterns
- `grep` (via `functions.shell_command`) - Search for error messages, patterns
- `read_file` or `functions.shell_command` - Load files, logs, configs
- `run_terminal_cmd` or `functions.shell_command` - Execute diagnostic commands, check logs
- `write` or `functions.apply_patch` - Create investigation files
- `search_replace` or `functions.apply_patch` - Update step status and findings

## Quality Standards

**Evidence-Based Debugging:**
- Every conclusion must cite specific evidence
- Document negative results (what was ruled out)
- No assumptions — only verified facts
- Uncertainty is valid — "inconclusive" is acceptable

**Documentation:**
- Clear separation of observations vs interpretations
- Actual command output and logs preserved
- Progress tracked at each step

## Error Handling

**Issue too vague:**
```
❌ Cannot form hypotheses

The issue description is too vague to investigate systematically.

I need:
- Specific symptoms (what's happening?)
- Reproduction steps (how to trigger it?)
- Expected vs actual behavior

Please provide more details.
```

**No hypotheses confirmed:**

Apply Authorized Continuation: use new evidence to form a testable hypothesis within the
approved scope. If no supported next investigation remains, record what is missing and ask
for that specific input or a scope decision. Do not ask the user to choose a command.

**Multiple root causes:**

Document each confirmed cause and its evidence, then recommend a correction order. Continue
to resolution documentation without a separate approval prompt; apply Authorized Continuation
before executing corrections and clarify only material scope or design choices.

---

## Using /jr-implement with Debug Steps

Pass the existing step file to `/jr-implement` using the routing in Step 7.5. Keep its scope,
acceptance evidence and findings in that work item. After execution, resume the investigation
from the observed result; do not recreate the investigation or ask the user to restate it.
Planning, implementation and verification remain distinct workflows within the same authorized
objective. User-requested pauses and the authorization boundaries in the core rule still apply.

---

**"Debug systematically. Conclude with evidence. Fix with confidence."**
