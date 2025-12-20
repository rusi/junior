# Debug

## Purpose

Systematic debugging workflow that transforms vague "something's broken" into structured investigation plans with clear hypotheses, evidence-based testing, and documented resolutions.

## Type

Contract-style (clarification → contract → approval → generation)

## When to Use

- Encountering an issue you can't immediately explain
- Need systematic investigation approach
- Want to document debugging process for future reference
- Issue is complex enough that guessing won't work

## Execution Pattern

**Simple investigations** (execute immediately):
- Read logs, check configs, grep patterns
- Run diagnostic commands
- Compare known-good vs broken states
- Example: "Why is service crashing?" → Check logs, verify config, test

**Complex investigations** (use `/implement` for execution):
- Build test applications
- Hardware testing (flash, collect data)
- Try alternative frameworks/stacks
- Multi-step experiments requiring code changes
- Example: "ESP32 notifications not working" → Build minimal test app, flash, compare with working implementation

**This command:**
1. Always creates investigation plan (hypotheses, steps, expected evidence)
2. Executes immediately if simple (Steps 1-8)
3. Stops after planning if complex → User runs `/implement` to execute steps

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

If not clean:
```
⚠️ Uncommitted changes detected.

Consider committing current work before starting investigation.
Use /commit first, or proceed if changes are related to the issue.

Proceed anyway? [yes/no]
```

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

- `list_dir` `.junior/debugging/` for existing debug sessions
- `codebase_search` for related code and error patterns
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

Wait for user approval.

**Note:** If investigation requires complex implementation (building apps, hardware testing, etc.), plan will stop after generation. User will use `/implement` to execute steps.

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

```markdown
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
```

#### 7.4: Generate Individual Step Files

**🔴 CRITICAL: Create skeleton files for ALL planned steps upfront**

- **Step 1:** Detailed file with complete test procedure (actively being worked on)
- **Steps 2-N:** Skeleton files with template (ready to fill when needed)

**Why:** Complete investigation plan from the start, not "figure it out later"

**dbg-{N}-step-{M}-{name}.md template:**

```markdown
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
```

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

**Complex Investigation (STOP and use `/implement`):**
- ❌ Building test applications
- ❌ Writing new code/components
- ❌ Flashing hardware
- ❌ Testing across multiple devices
- ❌ Trying alternative frameworks/stacks
- ❌ Multi-hour investigations

**Decision:**
```
if (steps require building/flashing/complex testing):
    STOP after Step 7
    Present: "Investigation plan created. Use /implement to execute steps."
else:
    Continue to Step 8 (execute immediately)
```

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

- [ ] Create bugfix implementation (use future `/bugfix` command)
- [ ] Or implement fix directly if simple

---

**Related:** This resolution can be used with `/bugfix` command to create implementation stories.
```

**Update dbg-N-overview.md status:**

```markdown
> Status: Resolved
```

**Present completion (for simple investigations executed immediately):**

```
✅ Investigation Complete!

**Issue:** [Issue name]
**Root Cause:** [Brief description]
**Evidence:** [Key evidence that confirmed it]

📁 Resolution documented at:
   .junior/debugging/dbg-{N}-{name}/dbg-{N}-resolution.md

🎯 Next Steps:
1. Review the fix approach in resolution doc
2. Implement fix (manually or use future /bugfix command)
3. Test the fix thoroughly

What would you like to do next?
```

**Present completion (for complex investigations requiring /implement):**

```
✅ Investigation Plan Created!

**Issue:** [Issue name]
**Steps:** [Number] investigation steps planned
**Strategy:** [Brief description of approach]

📁 Investigation plan documented at:
   .junior/debugging/dbg-{N}-{name}/

🎯 Next Steps:
1. Review investigation plan: .junior/debugging/dbg-{N}-{name}/investigation/dbg-{N}-steps.md
2. Execute Step 1: Use `/implement` and reference "dbg-{N}-step-1-{name}"
3. Document findings in step file
4. Proceed based on results (decision tree in steps.md)

Ready to start? Run `/implement` to execute the first investigation step.
```

## Tool Integration

**Primary tools:**
- `todo_write` - Progress tracking
- `list_dir` - Scan debugging sessions
- `codebase_search` - Find related code, error patterns
- `grep` - Search for error messages, patterns
- `read_file` - Load files, logs, configs
- `run_terminal_cmd` - Execute diagnostic commands, check logs
- `write` - Create investigation files
- `search_replace` - Update step status and findings

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
```
⚠️ All hypotheses ruled out

We've tested all initial hypotheses without finding root cause.

Options:
1. Form new hypotheses based on what we've learned
2. Expand investigation scope
3. Document as "unresolved" for later

What would you like to do?
```

**Multiple root causes:**
```
⚠️ Multiple contributing factors identified

Evidence suggests this issue has multiple causes:
1. [Cause 1 with evidence]
2. [Cause 2 with evidence]

Recommend addressing in order of impact.
Continue to resolution? [yes/no]
```

---

## Using /implement with Debug Steps

**For complex investigations requiring implementation:**

After `/debug` creates the investigation plan, use `/implement` to execute steps:

```bash
# User runs:
/implement

# Junior asks: "What would you like to implement?"
# User responds: "Execute debug step 1 from dbg-1-esp32-ble-notifications"

# Junior:
# 1. Reads dbg-1-step-1-minimal-stelo-app.md
# 2. Generates implementation plan (build test app, flash, collect logs)
# 3. Executes systematically
# 4. Updates step file with findings
# 5. Updates dbg-1-steps.md progress
```

**Benefits:**
- Systematic execution with progress tracking
- Clear separation: `/debug` = planning, `/implement` = execution
- User controls when investigation starts
- Can pause/resume investigation work
- Full implementation tracking (same as feature development)

**Completion message for complex investigations:**

```
✅ Investigation Plan Created!

**Issue:** [Issue name]
**Steps:** [Number] investigation steps planned
**Strategy:** [Brief description]

📁 Investigation plan documented at:
   .junior/debugging/dbg-{N}-{name}/

🎯 Next Steps:
1. Review the investigation plan in dbg-{N}-steps.md
2. Use /implement to execute Step 1: [step name]
3. Document findings and proceed to next steps

Ready to start? Run `/implement` and reference this debug session.
```

---

**"Debug systematically. Conclude with evidence. Fix with confidence."**

