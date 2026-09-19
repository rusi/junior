---
name: jr-add-story
description: Run `/jr-add-story` to add one story to an existing feature, scoped and duplicate-checked against the stories already there.
---

# Add Story

## Purpose

Add new user stories to existing features through intelligent feature detection, duplicate checking, scope validation, and contract-first clarification.

## Type

Contract-style (scan → analyze → clarify → contract → approval → generation → review → commit offer)

## When to Use

- Have new capability to add to existing feature
- Want to extend/enhance feature with additional story
- Feature exists but needs more implementation work
- Adding vertical slice to existing feature

## Process

### Step 1: Initialize Tracking

Create todos using `todo_write` or `functions.update_plan`:

```json
{
  "todos": [
    {"id": "scan", "content": "Scan features and analyze placement", "status": "in_progress"},
    {"id": "validate-scope", "content": "Validate story scope", "status": "pending"},
    {"id": "clarify", "content": "Clarify story requirements", "status": "pending"},
    {"id": "contract", "content": "Present story contract", "status": "pending"},
    {"id": "generate", "content": "Generate story files", "status": "pending"},
    {"id": "commit-offer", "content": "Offer to commit reviewed story planning changes", "status": "pending"}
  ]
}
```

### Step 2: Scan & Feature Detection

**Scan existing features:**

Use `list_dir` or `functions.shell_command` and `read_file` or `functions.shell_command` to understand:
- All existing features in `.junior/features/`
- All existing improvements in `.junior/improvements/`
- Current stage (Stage 1/2/3 detection per `01-structure.md`)
- Feature overviews and existing stories

**Feature identification:**

- **User specified feature ID** (e.g., "add to feat-3"): Use that feature
- **User didn't specify**: Intelligent semantic matching
  - Extract keywords from user's idea
  - Compare against all feature names and descriptions
  - Rank by semantic similarity
  - Present top match(es) for confirmation

**Duplicate detection:**

Use `grep` (via `functions.shell_command`) and `codebase_search` or `functions.shell_command` to check:
- Similar story titles in target feature
- Duplicate capabilities across all features
- Already implemented functionality in codebase

**Present findings:**

```
📊 Feature Analysis

Found matching feature:
- feat-X: [Feature Name]
  - Purpose: [Brief description]
  - Current stories: {M} stories
  - Status: [Planning | In Progress | Complete]

Your idea: "[User's request]"

**Recommendation:** Add as story to feat-X

**Existing stories in feat-X:**
- Story 1: [Title] - [Status]
- Story 2: [Title] - [Status]
- Story {M}: [Title] - [Status]

New story will be: feat-X-story-{M+1}

Does this placement make sense? [yes | suggest: feat-Y | discuss]
```

Wait for user confirmation.

### Step 3: Scope Validation

**Critical decision - Is this story-sized?**

Analyze scope to determine if idea is:

1. **Story-sized** ✅
   - Extends existing feature capability
   - Single vertical slice through the actual consumer boundary
   - User sees working output after story
   - Integrates with existing stories
   - 5-7 focused tasks

2. **Feature-sized** ⚠️
   - Fundamentally new capability/domain
   - Multiple vertical slices needed
   - Independent from existing features
   - Large scope (10+ tasks)

3. **Improvement-sized** 💡
   - Refactoring or code quality work
   - Performance optimization
   - Technical debt reduction
   - No user-facing feature changes

**If story-sized:**
- Proceed to clarification (Step 4)

**If feature-sized:**

Stop and present analysis:

```
⚠️ Scope Analysis

Your request appears too large for a story - this should be a new feature.

**Reasoning:** [Why it's too large - new domain/capability/complexity]

**Your idea involves:**
- [Multiple capabilities that are feature-level]
- [New domain areas beyond existing feature scope]
- [Estimated {X} tasks across multiple vertical slices]

**Recommendation:** Create as new feature using `/jr-feature`

**Suggested prompt for /jr-feature:**
"""
[User's original idea, refined from discussion]
"""

Should I:
- adjust: [suggest smaller story scope that fits existing feature]
- confirm: [yes, this should be a feature - use suggested prompt above]
- discuss: [let's talk about scope]
```

**If improvement-sized:**

Suggest improvement path instead:

```
💡 Scope Analysis

Your request seems like a code quality improvement, not a feature story.

**Reasoning:** [Why it's improvement work]

**Recommendation:** This belongs in `.junior/improvements/` as imp-N

Would you like to create this as an improvement instead? [yes | no | discuss]
```

Wait for user decision before proceeding.

### Step 4: Clarification Loop

**Mission:** Transform rough idea into crystal-clear story specification.

**Focus areas:**

- **Purpose:** What specific capability does this story add?
- **Deliverable:** What will user see/test after this story?
- **Vertical slice validation:** Does this touch all necessary layers?
- **Integration:** How does this connect with existing stories?
- **Dependencies:** Which existing stories must be complete first?
- **Scope boundaries:** What's included vs excluded?
- **Testing approach:** How will user validate it works?

**Process:**

- Ask ONE focused question at a time
- Target highest-impact unknowns first
- Use `codebase_search` or `functions.shell_command` to understand integration points
- Check for contradictions with existing stories
- Validate vertical slice approach throughout

**Critical validation before contract:** Apply [Vertical Slice Validation](../_shared/references/vertical-slices.md).
If it fails, identify the missing consumer outcome or required integration and resolve that
specific gap before the contract. Continue clarification until scope is clear.

### Step 5: Present Contract

**Story contract format:**

- Use `../_shared/references/story-contracts.md` -> "Add Story Contract" as the canonical template.
- Keep all sections from the template (Purpose, Scope, Vertical Slice Validation, Integration, Tasks, Impact, Testing).
- Fill with project-specific content; do not collapse sections.
- Approval covers generating and reviewing the story and related planning updates. Follow the [planning completion handoff](../_shared/references/planning-completion.md) for commit authorization.

Wait for user approval.

### Step 6: Generate Story Files

For approved interface design exploration, load and follow [UI Prototype](../jr-ui-prototype/SKILL.md),
including its parent context and return contract, before final story review.

**6.1: Generate story files from shared reference**

- Use `../_shared/references/story-file-generation.md` as the canonical generation workflow.
- Apply stage path resolution from this run (Stage 1/2/3) before creating files.
- Generate new story file, update `feat-X-stories.md`, and update component overview for Stage 2/3.
- Enforce checkbox format from the shared reference.
- Apply the **Output Spec** in that reference: it fixes what each generated document is for, what
  never goes in one, and the register they are written in.

### Step 7: Review and Commit Offer

Review the generated story and related planning updates against the approved contract; verify links, task totals, and status fields. Implementation tasks and acceptance criteria remain unchecked until implemented and verified.

Follow the [planning completion handoff](../_shared/references/planning-completion.md). Limit the commit offer to this story and related planning files changed by the run. Complete the review before offering to commit.

### Step 8: Present Results

**For:** the user deciding whether to start this story now. It answers *what was added, where it
lives, and what to do next.* Use the block below after review; if a commit was already authorized and verified, report its hash and follow the shared handoff instead of offering it again.

```
✅ Story specification complete!

📁 .junior/features/[path]/feat-X-[name]/
├── user-stories/
│   ├── 📊 feat-X-stories.md (UPDATED)
│   ├── feat-X-story-1-[name].md
│   ├── feat-X-story-{M}-[name].md
│   └── 📝 feat-X-story-{M+1}-[name].md (NEW)

**Feature:** feat-X - [Feature Name]
**New Story:** feat-X-story-{M+1} - [Story Title]
**Tasks:** {N} implementation tasks
**Approach:** TDD, end-to-end integrated, user-testable output

**Story Summary:**
- Deliverable: [What user sees working]
- Depends on: [Story Y OR None]
- Integration: [How it connects]

**Updated Documents:**
- ✅ feat-X-stories.md - Added story row, updated counts
- ✅ comp-M-overview.md - Updated story count (Stage 2+)

**Next Step:** Commit the reviewed planning changes.

Would you like me to run `/jr-commit` for this story specification?
```

**The result block is the whole report.** It states what now exists and what to do next. It does
not state how many features were scanned, which duplicates were ruled out, what the scope check
weighed, or which steps of this skill ran — that is the run showing its work to the one person who
asked for a story instead. Register: noun labels, facts, no editorial lead. Baseline:
`../_shared/references/artifact-output-spec.md`.

Mark todos complete:

```json
{
  "todos": [
    {"id": "scan", "content": "Scan features and analyze placement", "status": "completed"},
    {"id": "validate-scope", "content": "Validate story scope", "status": "completed"},
    {"id": "clarify", "content": "Clarify story requirements", "status": "completed"},
    {"id": "contract", "content": "Present story contract", "status": "completed"},
    {"id": "generate", "content": "Generate story files", "status": "completed"},
    {"id": "commit-offer", "content": "Offer to commit reviewed story planning changes", "status": "completed"}
  ]
}
```

## Critical Principles

### Vertical Slice Validation (MANDATORY)

Apply [Vertical Slice Validation](../_shared/references/vertical-slices.md) before generating any story.

### Scope Decision Framework

**Story-sized indicators:**
- Extends existing feature domain
- Single vertical slice
- 5-7 focused tasks
- Builds on existing stories

**Feature-sized indicators:**
- New capability/domain
- Multiple vertical slices needed
- 10+ tasks
- Independent scope

**When in doubt, err toward recommending new feature.**

### Duplicate Detection

Always check:
- Similar story titles in target feature
- Same capability in other features
- Already implemented in codebase
- Research or experiments covering this

### Integration Focus

New story must:
- Build on existing stories
- Not break existing functionality
- Have clear dependency chain
- Integrate seamlessly

## Tools

- `todo_write` or `functions.update_plan` - Progress tracking
- `list_dir` or `functions.shell_command` - Scan features and structure
- `read_file` or `functions.shell_command` - Read feature overviews and stories
- `codebase_search` or `functions.shell_command` - Semantic matching and duplicate detection
- `grep` (via `functions.shell_command`) - Pattern search for duplicates
- `write` or `functions.apply_patch` - Create new story file
- `search_replace` or `functions.apply_patch` - Update existing files

## Examples

**Add story to existing feature:**

```
User: /jr-add-story
Junior: What would you like to add?
User: Add password reset capability to authentication feature
Junior: [Scans features, finds feat-2-authentication]
Junior: Found feat-2-authentication with 3 existing stories. Add as story 4?
User: yes
Junior: [Clarification loop about password reset flow...]
Junior: [Presents story contract with vertical slice validation]
User: yes
Junior: [Generates and reviews planning files]
Junior: ✅ Story specification complete: feat-2-story-4-password-reset.md
Junior: Would you like me to run /jr-commit for this story specification?
User: yes
Junior: [Runs /jr-commit and verifies the resulting commit]
Junior: Committed: {hash}. Next: Run /jr-implement for the new story in feat-2-authentication.
```

**Scope too large, redirect to feature:**

```
User: /jr-add-story
Junior: What would you like to add?
User: Add payment processing with Stripe, PayPal, and subscription management
Junior: [Analyzes scope]
Junior: ⚠️ This scope is too large for a story - should be new feature
        Involves: Multiple payment providers, subscription logic, billing
        Recommendation: Use `/jr-feature` with this prompt: [...]
User: confirm
Junior: Copy the suggested prompt and run `/jr-feature` to create this properly
```

---

**"Simplicity is the ultimate sophistication."**
