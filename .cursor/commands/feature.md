# Feature

## Purpose

Create comprehensive feature specifications through contract-first clarification, transforming rough ideas into actionable specs with end-to-end user stories.

## Type

Contract-style (clarification → contract → approval → generation)

## When to Use

- Planning a new feature before implementation
- Spec out a product requirement with clarity
- Create structured implementation plan
- Follow Junior's "plan before execute" principle

## Specification Detail Level

**Feature Overview (feat-N-overview.md):**
- Contract (locked after approval)
- High-level requirements (functional, non-functional)
- User stories overview with dependencies
- Success metrics and risks

**Technical Spec (specs/01-Technical.md):**
- Architecture diagram (high-level visualization)
- Component descriptions (responsibility, interface, dependencies)
- Design decisions (context, decision, rationale, alternatives, trade-offs)
- Testing strategy (what to test, verification approach)
- **Reference 01-structure.mdc for structure definitions (DON'T repeat)**
- **ONE SENTENCE for implementations agent knows (clustering, sorting, parsing)**

**User Stories (user-stories/feat-N-story-M.md):**
- Context-gathering step (read existing files to understand before changing)
- Implementation tasks (WHAT to do, not HOW - agent figures out HOW)
- Review/refinement/testing steps after main work
- Testing scenarios (validate behavior, not detailed test code)
- Definition of Done (acceptance criteria, completeness checks)

**Key Principles:**
- **DRY:** Define structures/functions once in 01-structure.mdc, reference everywhere
- **Thorough:** Include design decisions, rationale, trade-offs
- **Concise:** Exclude pseudo-code for known patterns, avoid repetition
- **Reference:** Link to existing definitions instead of duplicating

## Process

### Step 1: Verify Git State

```bash
git status --short
```

If not clean:
```
⚠️ Uncommitted changes. Use /commit first.
Feature planning aborted.
```

Only proceed if git working directory is clean.

### Step 2: Initialize Tracking

```json
{
  "todos": [
    {"id": "scan", "content": "Scan & build context", "status": "in_progress"},
    {"id": "analyze", "content": "Analyze feature placement", "status": "pending"},
    {"id": "clarify", "content": "Clarify requirements", "status": "pending"},
    {"id": "contract", "content": "Present contract", "status": "pending"},
    {"id": "generate", "content": "Generate spec", "status": "pending"},
    {"id": "user-review", "content": "User review & refinement", "status": "pending"},
    {"id": "final-review", "content": "Final consistency review", "status": "pending"}
  ]
}
```

### Step 3: Context Scan & Feature Analysis

**3.1: Scan & build comprehensive context**

Scan all `.junior/` working memory to understand existing work:

- `list_dir` `.junior/features/` → existing features
  - `read_file` each `feat-N-overview.md` to understand feature scope and status
  - `read_file` each `feat-N-stories.md` to see current story breakdown
- `list_dir` `.junior/research/` → technical investigations
- `list_dir` `.junior/experiments/` → validation experiments
- `list_dir` `.junior/debugging/` → active debugging sessions
- `list_dir` `.junior/bugs/` → tracked bugs
- `list_dir` `.junior/enhancements/` → small improvements
- `codebase_search` for architecture patterns relevant to request
- Load project context if available
- Identify next feature/story numbers

**Build mental model:**
- What features exist and their scopes
- What's in progress vs planned vs backlog
- What research/experiments relate to this request
- Where contradictions or overlaps might exist
- How this fits into overall architecture

**3.2: Analyze request placement**

**Critical Decision:** Determine if user's request should be:

1. **New Feature (feat-N)** - Create new feature directory
   - ✅ When: Fundamentally different capability/workflow
   - ✅ When: Standalone feature with independent scope
   - ✅ When: No strong relationship to existing features
   - Example: "User authentication" is different from "Payment processing"

2. **New Story in Existing Feature (feat-X-story-Y)** - Add to existing feature
   - ✅ When: Extends or enhances existing feature scope
   - ✅ When: Logically belongs to existing feature's domain
   - ✅ When: Completes or improves existing feature
   - Example: Adding "Password reset" to existing "User authentication" feature

3. **Modification of Existing Story (use /update-feature instead)**
   - ✅ When: Changes requirements of existing story
   - ✅ When: Fixes or refines existing specifications
   - Example: "Update Story 2 to include email validation"

**Decision Process:**

If existing features found:
1. Analyze each existing feature's scope and purpose
2. Compare user request against each feature
3. Present analysis to user:

```
📊 Context Analysis

Found {N} existing features:
- feat-1: [Name] - [Brief scope description]
- feat-2: [Name] - [Brief scope description]

Your request: "[User's request]"

**Recommendation: [New Feature | Add to feat-X | Use /update-feature]**

**Reasoning:**
[1-2 sentences explaining why this placement makes sense]

**If new feature:**
- Will be created as feat-{N+1}
- Scope: [Initial understanding of scope]

**If add to existing:**
- Will add story to feat-X
- Current stories: {M} stories
- New story will be: feat-X-story-{M+1}

Does this placement make sense, or should we discuss? [yes | discuss | suggest: {alternative}]
```

Wait for user confirmation before proceeding to clarification.

**3.3: Set working mode**

Based on decision and user confirmation:
- **New Feature mode:** Full feature specification (contract + stories + specs)
- **Add Story mode:** Add story to existing feature (update existing feat-X)
- **Update Existing:** Modify existing story/feature specifications

All modes proceed to Step 4 for clarification (scope varies by mode).

**Output:** Analysis summary with recommendation and user confirmation

### Step 4: Gap Analysis & Clarification Loop

**Applies to:** All modes (new feature, add story, update existing)

**Mission:**
> Transform rough idea into crystal-clear specification. Challenge complexity, surface concerns early, check for contradictions with existing work, build 95% confidence before creating any files.

**Clarification scope varies by mode:**

- **New Feature:** Full feature understanding (purpose, scope, stories, integration, risks)
- **Add Story:** Story-specific details (capability, integration with existing stories, dependencies, deliverable)
- **Update Existing:** Changes needed (what's wrong, what should change, impact on dependent stories)

**Internal gap analysis (don't show user):**

Silently identify every missing detail, check for contradictions with existing features/stories, then ask ONE focused question at a time targeting highest-impact unknown:

- **Purpose & value** - What problem does this solve? Who for?
  - Example: "What specific user problem does this solve, and who experiences it?"
- **Target users** - Who experiences this problem?
  - Example: "Who has this problem? What's their context?"
- **Success criteria** - How do we measure if it works?
  - Example: "What does 'success' look like - how will we measure it?"
- **Technical constraints** - Performance, scale, compatibility requirements
  - Example: "Are there performance requirements (response time, throughput, scale)?"
- **Scope boundaries** - What's included vs excluded?
  - Example: "Should we focus on core functionality or full feature set first?"
- **UI/UX requirements** - Interface, interactions, accessibility
  - Example: "What UI/UX constraints exist - web only, mobile responsive, accessibility?"
- **Integration points** - How does this connect to existing systems?
  - Example: "Should this integrate with [existing system found in codebase], or remain separate?"
- **Security & compliance** - Authentication, authorization, data protection
  - Example: "What are the security requirements - authentication, authorization, data protection?"
- **Risk factors** - Technical feasibility, complexity concerns
  - Example: "What's your risk tolerance - stable/proven approaches or cutting-edge?"

**Process:**
- Target highest-impact unknowns first
- After each answer, scan codebase for additional context if relevant
- **Check for contradictions** with existing features/stories/research
- Never declare "final question" - let conversation flow naturally
- User signals when ready by responding to contract proposal

**🔴 CRITICAL: Contradiction Detection & Reconciliation**

During clarification, actively check for contradictions:

1. **Feature-level contradictions:**
   - Does this conflict with existing feature scope/goals?
   - Does this duplicate existing feature capabilities?
   - Does this violate established architecture decisions?

2. **Story-level contradictions:**
   - Does this conflict with existing story implementations?
   - Does this change break dependent stories?
   - Does this create inconsistencies in the feature?

3. **Technical contradictions:**
   - Does this conflict with codebase patterns?
   - Does this violate documented design decisions?
   - Does this create integration conflicts?

**When contradictions found:**

```
⚠️ Potential Contradiction Detected

Your request: [description]
Conflicts with: [feat-X or story or pattern]

**Issue:** [Specific contradiction]

**Options to resolve:**
1. [Modify your request to align]
2. [Update existing feature/story to accommodate]
3. [Refactor both to eliminate conflict]

**Recommendation:** [Which option and why]

How should we proceed?
```

**Don't proceed until contradictions are resolved.**

**Critical analysis responsibility:**

Junior must push back when:
- Requirements seem technically infeasible with current architecture
- Scope is too large (recommend breaking down)
- Request conflicts with existing codebase patterns or features
- Business logic doesn't align with stated user value
- Performance/security/scalability concerns exist
- **Contradictions exist with current features/stories/research**

**Pushback phrasing:**
- "I see a potential issue with [requirement] because [technical reason]. Would [simpler alternative] work better?"
- "Based on your existing codebase, [proposed approach] conflicts with [existing pattern]. How should we handle this?"
- "This sounds like 3-4 separate features. Should we focus on [core piece] first?"
- "I'm concerned [requirement] could create [specific problem]. Have you considered [alternative]?"

**Transition to contract:**

When confidence is high:
- Use phrases like "I think I have enough to create a solid contract" or "Based on our discussion, here's what I understand"
- Present contract without declaring it "final"
- Leave room for more questions if needed

**🔴 CRITICAL: Validate Vertical Slice Approach BEFORE Contract**

Before presenting contract, mentally validate story breakdown:
- **Each story MUST be end-to-end integrated (all layers working)**
- **Each story MUST produce user-visible, testable output**
- **NEVER horizontal layers (all DB, then all API, then all UI)**

**RED FLAGS indicating horizontal layering:**
- "Story 1: Database schema" → ❌ No user output
- "Story 2: API endpoints" → ❌ Still nothing visible
- "Story 3: Frontend implementation" → ❌ Only works at Story 3
- "Story 4: Integration" → ❌ Integration should be in EVERY story
- "Story 5: Testing" → ❌ Testing should be in EVERY story

**CORRECT vertical slice pattern:**
- Story 1: Minimal feature (DB + API + UI) working end-to-end with basic data
- Story 2: Enhanced feature (extend DB + API + UI) for more capability
- Story 3: Additional feature (extend DB + API + UI) for new functionality

**If you catch yourself planning horizontal stories, STOP and redesign as vertical slices.**

### Step 5: Present Contract

**Contract format varies by mode:**

**For New Feature:**

```
## Feature Contract

**Feature:** [One sentence describing what will be built]
**User Value:** [Core problem solved and who it helps]
**Hardest Constraint:** [Biggest technical/business limitation]
**Success Criteria:** [How we'll know it works correctly]

**Scope:**
- ✅ Included: [2-3 key capabilities]
- ❌ Excluded: [2-3 things we won't build]

**Integration Points:**
- [Existing system/feature this connects to]
- [New dependencies or services needed]

**⚠️ Technical Concerns (if any):**
- [Specific concern about feasibility, performance, or architecture]
- [Suggested mitigation approach]

**💡 Recommendations:**
- [Suggestions for simpler/better approach based on codebase analysis]
- [Ways to reduce risk or complexity]

**Stories Preview (MUST be vertical slices):**
- Story 1: [Minimal end-to-end feature → USER SEES WORKING OUTPUT → Example: "Button generates ONE screenshot in English"]
- Story 2: [Enhance existing feature → USER SEES MORE → Example: "Progress bar + ALL scenarios in English"]
- Story 3: [Expand scope → USER SEES COMPLETE → Example: "All 25 languages with organized output"]

**Each story = Full stack working (DB + Backend + Frontend + Tests + Docs)**
**NEVER: Story 1 = DB, Story 2 = API, Story 3 = UI ← This is WRONG**

---
Options: yes | edit: [changes] | risks | simpler
```

**For Add Story to Existing Feature:**

```
## Story Contract

**Feature:** feat-X - [Feature Name]
**New Story:** feat-X-story-{M+1} - [Story Title]

**Purpose:** [What this story adds to the feature]
**User Value:** [What user can now do after this story]
**Deliverable:** [User-visible, working, end-to-end output]

**Scope:**
- ✅ Included: [Specific capabilities this story delivers]
- ❌ Excluded: [Out of scope for this story]

**Integration with Existing Stories:**
- **Depends on:** [feat-X-story-Y] for [reason]
- **Extends:** [existing capability] with [new capability]
- **Changes:** [any modifications to existing stories, if needed]

**Vertical Slice Validation:**
- DB: [database changes, if any]
- Backend: [API/logic changes]
- Frontend: [UI changes]
- Tests: [test coverage approach]
- User sees: [specific working output]

**⚠️ Impact Analysis:**
- Affects existing stories: [list any that need updates]
- Breaks nothing: [confirmation]
- Integration points: [how this connects]

---
Options: yes | edit: [changes] | discuss
```

**For Update Existing Feature/Story:**

```
## Update Contract

**Target:** [feat-X or feat-X-story-Y]
**Current State:** [brief description of what exists]
**Requested Changes:** [what user wants to change]

**Proposed Updates:**
- Change 1: [specific modification]
- Change 2: [specific modification]

**Impact Analysis:**
- **Dependent Stories:** [which stories are affected]
- **Breaking Changes:** [what breaks, if anything]
- **Required Updates:** [other files/stories that need updates]
- **Regression Risk:** [low/medium/high with explanation]

**Contradiction Resolution:**
[If this update was needed to resolve contradictions, explain how]

**Updated Scope:**
- ✅ Still Included: [capabilities that remain]
- ✅ Now Included: [new capabilities]
- ❌ Now Excluded: [things being removed/descoped]

---
Options: yes | edit: [changes] | discuss
```

Wait for user approval.

### Step 6: Generate Spec Package

**Generation scope varies by mode:**

- **New Feature:** Full feature package (overview + stories + specs)
- **Add Story:** New story file + update feat-X-stories.md
- **Update Existing:** Modify targeted files + update dependent files

#### 6.1: Create Directory Structure

**For New Feature:**

Per `01-structure.mdc`:
```
.junior/features/feat-{N}-{name}/
├── feat-N-overview.md
├── user-stories/
│   ├── feat-{N}-stories.md
│   └── feat-{N}-story-{M}-{name}.md
└── specs/ (only if needed)
    ├── 01-Technical.md
    ├── 02-API.md
    ├── 03-Database.md
    └── 04-UI-Wireframes.md
```

**For Add Story:**

Update existing structure:
```
.junior/features/feat-{X}-{name}/
├── feat-X-overview.md (no changes)
├── user-stories/
│   ├── feat-{X}-stories.md (UPDATE: add new story to table)
│   └── feat-{X}-story-{M+1}-{name}.md (CREATE: new story)
└── specs/ (no changes unless story requires)
```

**For Update Existing:**

Modify targeted files:
```
.junior/features/feat-{X}-{name}/
├── feat-X-overview.md (UPDATE if needed)
├── user-stories/
│   ├── feat-{X}-stories.md (UPDATE if story list changes)
│   ├── feat-{X}-story-Y-{name}.md (UPDATE: modify story)
│   └── feat-{X}-story-Z-{name}.md (UPDATE: cascade changes if dependent)
└── specs/ (UPDATE if technical changes needed)
```

#### 6.2: Generate feat-N-overview.md

**For New Feature only:**

```markdown
# [Feature Name]

> Created: [Get from 02-current-date rule]
> Status: Planning
> Contract Locked: ✅

## Feature Contract

[Contract from Step 4 verbatim]

## Detailed Requirements

[Expanded from clarification responses]

### Functional Requirements
- [Specific behaviors]

### Non-Functional Requirements
- **Performance:** [Response time, throughput expectations]
  - All performance requirements MUST have benchmark tests
  - Document targets clearly in test documentation
  - Use statistical benchmark frameworks (not manual timing)
  - Compare against baseline to detect regressions
- **Security:** [Authentication, authorization, data protection]
- **Scalability:** [Expected load, growth considerations]
- **Accessibility:** [WCAG compliance, keyboard navigation, screen readers]

## User Stories

See [user-stories/feat-{N}-stories.md](./user-stories/feat-{N}-stories.md) for implementation breakdown.

## Technical Approach

See [specs/01-Technical.md](./specs/01-Technical.md) for detailed technical approach.

High-level strategy:
- [Brief architecture overview]
- [Key integration points]
- [Testing approach: TDD with unit, integration, end-to-end tests]

## Dependencies

- [External libraries or services needed]
- [Prerequisites from other features]

## Risks & Mitigations

[Known risks from contract with mitigation strategies]

## Success Metrics

[How we'll measure if this feature succeeds]

## Future Enhancements

[Out-of-scope items to consider later]
```

#### 6.3: Generate User Stories

**For New Feature:** Generate all stories
**For Add Story:** Generate one new story + update stories.md
**For Update Existing:** Modify targeted story + cascade updates

**🔴 CRITICAL: Every Story MUST Be a Vertical Slice**

**Before writing ANY story, verify it meets ALL these criteria:**

✅ **User sees working output** - Story delivers something user can see/test/validate
✅ **End-to-end integrated** - All layers working together (not just one layer)
✅ **Reduced scope, complete implementation** - Narrow feature, but fully working
✅ **Builds on previous story** - Enhances or adds to working foundation

❌ **FORBIDDEN story types:**
- "Build database schema" (no user output)
- "Implement API layer" (no user visibility)
- "Create frontend" (layers not integrated)
- "Integration story" (integration should be in EVERY story)
- "Testing story" (tests should be in EVERY story)

**Story breakdown pattern:**
1. **Story 1:** Smallest possible working feature (full stack, minimal scope)
   - Example: "Button → renders ONE test screen → saves PNG file"
2. **Story 2:** Enhance with more capability (full stack, more features)
   - Example: "Progress bar → renders ALL scenarios → English only"
3. **Story 3:** Expand to full scope (full stack, complete feature)
   - Example: "All languages → organized output → 375 screenshots"

**user-stories/feat-{N}-stories.md:**

```markdown
# User Stories Overview

> **Feature:** [Feature Name]
> **Created:** [Date]
> **Status:** Planning

## Stories Summary

| Story | Title | Status | Tasks | Progress |
|-------|-------|--------|-------|----------|
| 1 | [Title] | Not Started | 5 | 0/5 |
| 2 | [Title] | Not Started | 4 | 0/4 |
| {N+1} | Future Enhancements & Follow-up Work | Not Started | - | Backlog |

**Total:** 0/9 tasks (0%) + Future work in backlog

## Story Dependencies

- Story 2 depends on Story 1 completion
- Story 3 can run parallel to Story 2
- Story {N+1} (Future Work) depends on all previous stories

## Implementation Order

Follow stories sequentially. Each story must be:
- End-to-end integrated
- User-testable with working output
- Built using TDD (test first, implement, verify)

Story {N+1} captures out-of-scope items and future enhancements for later consideration.

## Quick Links

- [Story 1](./feat-{N}-story-1-{name}.md)
- [Story 2](./feat-{N}-story-2-{name}.md)
- [Story {N+1}: Future Work](./feat-{N}-story-{N+1}-future-enhancements.md)
```

**user-stories/feat-{N}-story-{M}-{name}.md:**

```markdown
# Story {M}: [Title]

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** [None OR Story N]
> **Deliverable:** [Fully working, integrated, user-testable feature]

## User Story

**As a** [user type]
**I want** [action]
**So that** [value]

## Scope

**In Scope:**
- [Deliverable 1 - fully integrated, working end-to-end]
- [Deliverable 2 - user can see/test working]
- [Reduced feature scope but complete implementation]

**Out of Scope:**
- [Features saved for future stories]

## Acceptance Criteria

- [ ] Given [context], when [action], then [outcome]
- [ ] Given [context], when [action], then [outcome]
- [ ] Given existing system from previous story, when [integration], then [works correctly]

## Implementation Tasks

- [ ] {M}.1 Write tests for [component] (TDD: test first)
- [ ] {M}.2 Implement [component] to pass tests
- [ ] {M}.3 [Next component - test first, implement]
- [ ] {M}.4 Integrate with existing features
- [ ] {M}.5 Verify acceptance criteria met
- [ ] {M}.6 Deploy and test end-to-end

## Technical Notes

[Implementation approach, integration points, key decisions]

See [specs/01-Technical.md](../specs/01-Technical.md) for detailed technical approach.

## Testing Strategy

**TDD Approach:**
- Write tests first (red)
- Implement to pass tests (green)
- Refactor (clean)

**Unit Tests:** [What to test at unit level]
**Integration Tests:** [What to test at integration level]
**Manual Testing:** [End-to-end scenarios user can verify]

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Feature works end-to-end (no stubs/mocks)
- [ ] All tests passing (unit + integration + end-to-end)
- [ ] No regressions in previous stories
- [ ] Code follows project conventions
- [ ] Documentation updated
- [ ] **User can see/test/validate working functionality**
- [ ] Deployed and verified
```

**Generate final story: Future Enhancements & Follow-up Work**

After generating all planned implementation stories, automatically create one final story to capture future work:

```markdown
# Story {N+1}: Future Enhancements & Follow-up Work

> **Status:** Not Started
> **Priority:** Low (Backlog)
> **Dependencies:** All previous stories completed
> **Deliverable:** Captured future work items for consideration in later iterations

## Purpose

This story captures features, enhancements, and technical considerations that were identified during feature planning but intentionally excluded from the initial scope. These items should be reviewed and potentially implemented in future iterations once the core feature is stable.

## Out-of-Scope Features

[Items from contract "❌ Excluded" section - convert to actionable tasks with context]

## Technical Debt Considerations

[Technical shortcuts or limitations that should be addressed later]
- Document any simplified implementations
- Note areas that need optimization
- List scalability concerns to revisit

## Enhancement Opportunities

[Ideas for improving the feature after initial release]
- User experience improvements
- Performance optimizations
- Additional capabilities that would add value

## Follow-up Work

[Tasks that naturally follow from the implemented feature]
- Integration opportunities with other features
- Analytics or monitoring additions
- Documentation expansions
```

**🔴 CRITICAL STORY RULES (NON-NEGOTIABLE):**

1. **VERTICAL SLICES ONLY** - Every story goes through full stack (DB + Backend + Frontend)
   - ✅ Story 1: Minimal feature working end-to-end
   - ✅ Story 2: Enhanced feature working end-to-end
   - ❌ NEVER: Story 1 = DB, Story 2 = Backend, Story 3 = Frontend

2. **USER SEES WORKING OUTPUT** - Each story delivers something user can see/test/validate
   - Must be able to demo after each story
   - No invisible infrastructure stories
   - No "it works but you can't see it yet" stories

3. **COMPLETE IMPLEMENTATION** - Reduce scope, don't skip layers
   - Narrow the feature, not the stack
   - All layers working together, just simpler functionality

4. **TDD THROUGHOUT** - Test first, implement, verify (in EVERY story)

5. **MAX 5-7 TASKS** - Split if more (keeps stories focused)

6. **FINAL FUTURE WORK STORY** - Always generate Story N+1 for backlog items

**USER MUST SEE WORKING OUTPUT AFTER EACH STORY**

Every story completion must result in something the user can:
- See working (UI/CLI output)
- Test manually
- Verify functionality
- Validate against requirements

**✅ Correct Approach (Vertical Slices):**

**Example: PR Wallboard Feature**

**Story 1: Basic Open PR Wallboard**
- **What:** TDD, basic DB schema, backend fetch basic PR data, simple UI table with manual refresh
- **Why:** Full stack working end-to-end, minimal scope
- **User sees:** Working wallboard showing basic PR list, can manually refresh to see real data
- **Deliverable:** Deployed feature - database, API, UI all working together

**Story 2: Enhanced PR Details**
- **What:** TDD, scheduled fetching (backend), fetch all PR details, add columns to UI table
- **Why:** Builds on working foundation, enhances entire stack
- **User sees:** Auto-refreshing wallboard with more PR information (status, dates, etc.)
- **Deliverable:** More useful feature, still fully working end-to-end

**Story 3: Add Reviewer Tracking**
- **What:** TDD, extend DB schema for reviewers, backend fetch reviewer data, UI shows reviewer names/status
- **Why:** New capability through entire stack
- **User sees:** PRs with reviewer information and approval status
- **Deliverable:** Additional capability, fully integrated

**Story 4-6:** Task Tracking, Importance Ranking, Reviewer Analytics, Multi-State Sync
- Each adds capability through full stack (DB + Backend + UI)
- User validates each addition before moving forward
- Can stop/pivot at any point with working feature

**Pattern:** Each story goes through entire stack (database, backend, frontend) but with narrow scope. Build thin vertical slice, then enhance, then add more slices.

**❌ Wrong Approach (Horizontal Layers):**

- Story 1: ALL database tables → No visible output
- Story 2: ALL API methods → Still nothing to see
- Story 3: ALL sync logic → Still invisible
- Story 4: ALL frontend → Finally works (but 4 stories later!)
- Story 5: Testing → Should have been throughout

Nothing works until Story 4. User can't validate requirements until the end.

**Why This Matters:**
- User validates requirements early (not after multiple stories of invisible work)
- Catches misunderstandings in Story 1, not Story 3+
- Each story has immediate, inspectable value
- Can stop/pivot after any story with working output
- Maintains motivation with visible progress
- Every story delivers working, testable functionality

**Anti-Patterns to AVOID:**

- ❌ **"Integration Story"** - Every story should already be integrated
- ❌ **"Testing Story"** - Every story includes comprehensive testing (TDD)
- ❌ **"Polish Story"** - Every story delivers polished, production-ready work
- ❌ **"Refactoring Story"** - Build it right the first time, or refactor as part of the story that needs it
- ❌ **"Documentation Story"** - Document as you build, not after

#### 6.4: Generate Technical Specs (Only If Needed)

Create numbered specs only when contract requires detailed technical documentation:

**specs/01-Technical.md:**

```markdown
# Technical Specification

## Overview

[High-level architecture description]

## Architecture

[Detailed architecture, components, data flow]

## Components

### [Component Name]
**Responsibility:** [What it does]
**Interface:** [How others interact]
**Dependencies:** [What it depends on]

## Design Decisions

### [Decision Name]
**Context:** [Why we needed to decide]
**Decision:** [What we chose]
**Rationale:** [Why this is best]
**Alternatives Considered:** [What else we looked at]

## Testing Strategy

**TDD Approach:**
- Write tests first (define expected behavior)
- Implement to pass tests
- Refactor for clarity and maintainability

**Test Levels:**
- Unit tests: [What to test]
- Integration tests: [What to test]
- End-to-end tests: [What to test]

## Cross-References

- Implements requirements from [feat-N-overview.md](../feat-N-overview.md)
- Related to Story 1: [link]
- Related to Story 2: [link]
```

**specs/02-API.md** (only if new endpoints):

Template structure:
- Section: Endpoints with method, path, purpose
- Request/Response: JSON structure with field types
- Error Codes: 400, 401, 500 with descriptions
- Authentication: Required/Optional, method
- Rate Limiting: Limits if applicable
- Testing: Unit tests (controller/route), Integration tests (end-to-end API)

**specs/03-Database.md** (only if schema changes):

Template structure:
- Schema Changes: New tables with CREATE TABLE statements, field types, constraints
- Purpose: Why table exists
- Migrations: Up (apply changes SQL), Down (rollback SQL)
- Indexes: Index names and what queries they improve
- Testing: Unit tests (model/query), Integration tests (database interactions)

**specs/04-UI-Wireframes.md** (only if UI/UX requirements):

Template structure:
- Wireframes: ASCII art, design file links, or descriptions
- User Flows: Step-by-step user action → system response sequences
- Accessibility: WCAG 2.1 Level AA, keyboard navigation, screen reader, color contrast
- Responsive Design: Desktop, tablet, mobile requirements
- Testing: Manual (user interaction scenarios), Accessibility (screen reader, keyboard)

### Step 7: User Review & Refinement Phase

Update todos:
```json
{
  "todos": [
    {"id": "user-review", "content": "User reviewing generated specification", "status": "in_progress"},
    {"id": "final-review", "content": "Final consistency review", "status": "pending"}
  ]
}
```

Present package for user review:

```
✅ Feature specification created!

📁 .junior/features/feat-{N}-{name}/
├── 📋 feat-N-overview.md
├── 👥 user-stories/
│   ├── 📊 feat-{N}-stories.md
│   └── 📝 feat-{N}-story-{M}-{name}.md
└── 📂 specs/
    └── 📄 01-Technical.md

**Stories:** {M} user stories with focused task groups
**Total Tasks:** {X} implementation tasks
**Approach:** TDD, end-to-end integrated, user-testable after each story

Please review the generated specification. Let me know if you need any changes, or say "ready" when you're ready for final review.
```

**Refinement Loop:**

User provides feedback naturally. Make requested changes, iterate as needed. Can push back if changes create complexity or don't align with contract.

When user indicates they're done reviewing (e.g., "ready", "looks good", "all good"), proceed to Step 8.

If ready for final review:
- I'll check all documents for consistency
- Verify cross-references are correct
- Ensure story dependencies make sense
- Validate technical approach aligns with requirements

### Step 8: Final Consistency Review

**Trigger:** Only when user says "ready" after Step 7 review phase.

Update todos:
```json
{
  "todos": [
    {"id": "verify-contract", "content": "Verify contract matches all docs", "status": "in_progress"},
    {"id": "check-stories", "content": "Check story consistency and dependencies", "status": "pending"},
    {"id": "validate-specs", "content": "Validate spec cross-references", "status": "pending"},
    {"id": "check-tdd", "content": "Ensure TDD approach in all stories", "status": "pending"}
  ]
}
```

**First, validate with user:**

```
Review the specification:
- Captures your vision?
- Missing requirements?
- Stories appropriately scoped?
- Need adjustments?
```

If user confirms or provides minor feedback, proceed to automated consistency checks.

**Automated consistency checklist:**

1. **Contract consistency:** feat-N-overview.md contract matches stories and specs
2. **Story dependencies:** Stories reference each other correctly
3. **Cross-references:** All links work (feat-N-overview.md ↔ stories ↔ specs)
4. **TDD approach:** All stories include test-first tasks
5. **Working output:** All stories emphasize user-testable output
6. **🔴 CRITICAL - Vertical slices:** EVERY story is end-to-end (no horizontal layering)
   - Check: Each story has UI + Backend + DB (if applicable) working together
   - Check: Each story deliverable includes "user can see/test working X"
   - Check: No "database story", "API story", "frontend story", "integration story", "testing story"
   - Check: Story 1 must have working output (not just infrastructure)
7. **Technical alignment:** specs/01-Technical.md aligns with feat-N-overview.md
8. **API consistency:** If API spec exists, matches feature requirements
9. **Database consistency:** If DB spec exists, matches data requirements
10. **UI/UX consistency:** If wireframes exist, match functional requirements

**Review all documents for consistency:**

- Read feat-N-overview.md contract
- Read all user stories
- Read all specs (if exist)
- Verify cross-references work
- Check alignment and consistency

**Present review results:**

```
🔍 Final Review Complete

- ✅ Contract consistency - All docs align with locked contract
- ✅ Story dependencies - Correct sequential order
- ✅ Cross-references - All links verified
- ✅ TDD approach - Test-first in all stories
- ✅ Working output - User-testable emphasized
- ✅ Vertical slices - No horizontal layering
- ✅ Technical specs - Align with requirements
- ✅ Document consistency - All files reviewed and aligned

[OR if issues found:]

⚠️ Issues Found:
- [Issue 1 with suggested fix]
- [Issue 2 with suggested fix]

Should I fix these issues? [yes/no]

---

Feature specification is ready for implementation!

**Next steps:**
- Start Story 1 implementation (TDD approach)
- Or request specification adjustments
```

## Tools

- `todo_write` - Progress tracking
- `list_dir` - Scan features
- `codebase_search` - Architecture analysis
- `grep` - Code patterns
- `read_file` - Context loading
- `run_terminal_cmd` - Git status, current date
- `write` - File creation

**"Simplicity is the ultimate sophistication."**
