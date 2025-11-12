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
    {"id": "scan", "content": "Scan context", "status": "in_progress"},
    {"id": "clarify", "content": "Clarify requirements", "status": "pending"},
    {"id": "contract", "content": "Present contract", "status": "pending"},
    {"id": "generate", "content": "Generate spec", "status": "pending"},
    {"id": "review", "content": "Final consistency review", "status": "pending"}
  ]
}
```

### Step 3: Context Scan

- `list_dir` `.junior/features/` for existing features
- `codebase_search` for architecture patterns
- Load project context if available
- Identify next feature number (feat-1, feat-2, etc.)

**Output:** Brief context summary (no files yet)

### Step 4: Gap Analysis & Clarification Loop

**Mission:**
> Transform rough feature idea into crystal-clear specification. Challenge complexity, surface concerns early, build 95% confidence before creating any files.

**Internal gap analysis (don't show user):**

Silently identify every missing detail, then ask ONE focused question at a time targeting highest-impact unknown:

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
- Never declare "final question" - let conversation flow naturally
- User signals when ready by responding to contract proposal

**Critical analysis responsibility:**

Junior must push back when:
- Requirements seem technically infeasible with current architecture
- Scope is too large (recommend breaking down)
- Request conflicts with existing codebase patterns
- Business logic doesn't align with stated user value
- Performance/security/scalability concerns exist

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

### Step 5: Present Contract

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

**Stories Preview:**
- Story 1: [Core end-to-end slice with working output]
- Story 2: [Next vertical slice with working output]
- Story 3: [Additional capability with working output]

---
Options: yes | edit: [changes] | risks | simpler
```

Wait for user approval.

### Step 6: Generate Spec Package

#### 6.1: Create Directory Structure

Per `01-structure.mdc`:
```
.junior/features/feat-{N}-{name}/
├── feature.md
├── user-stories/
│   ├── README.md
│   └── feat-{N}-story-{M}-{name}.md
└── specs/ (only if needed)
    ├── 01-Technical.md
    ├── 02-API.md
    ├── 03-Database.md
    └── 04-UI-Wireframes.md
```

#### 6.2: Generate feature.md

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
- **Security:** [Authentication, authorization, data protection]
- **Scalability:** [Expected load, growth considerations]
- **Accessibility:** [WCAG compliance, keyboard navigation, screen readers]

## User Stories

See [user-stories/README.md](./user-stories/README.md) for implementation breakdown.

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

**user-stories/README.md:**

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

**Critical story rules:**
- Max 5-7 tasks per story (split if more)
- Each story is end-to-end integrated
- **User sees working output after each story**
- Vertical slices, not horizontal layers
- TDD: test first, implement, verify
- **Always generate final future work story (Story N+1)**

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

- Implements requirements from [feature.md](../feature.md)
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

### Step 7: Present Package

```
✅ Feature specification created!

📁 .junior/features/feat-{N}-{name}/
├── 📋 feature.md
├── 👥 user-stories/
│   ├── 📊 README.md
│   └── 📝 feat-{N}-story-{M}-{name}.md
└── 📂 specs/
    └── 📄 01-Technical.md

**Stories:** {M} user stories with focused task groups
**Total Tasks:** {X} implementation tasks
**Approach:** TDD, end-to-end integrated, user-testable after each story

Review the specification:
- Captures your vision?
- Missing requirements?
- Stories appropriately scoped?
- Need adjustments?

---

**Ready for final review or more feedback?**

If ready for final review:
- I'll check all documents for consistency
- Verify cross-references are correct
- Ensure story dependencies make sense
- Validate technical approach aligns with requirements

Type 'ready' for final review or provide feedback.
```

### Step 8: Final Review (After User Says Ready)

**If user says "ready" or "final review":**

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

**Review checklist:**

1. **Contract consistency:** feature.md contract matches stories and specs
2. **Story dependencies:** Stories reference each other correctly
3. **Cross-references:** All links work (feature.md ↔ stories ↔ specs)
4. **TDD approach:** All stories include test-first tasks
5. **Working output:** All stories emphasize user-testable output
6. **Vertical slices:** No horizontal layering detected
7. **Technical alignment:** specs/01-Technical.md aligns with feature.md
8. **API consistency:** If API spec exists, matches feature requirements
9. **Database consistency:** If DB spec exists, matches data requirements
10. **UI/UX consistency:** If wireframes exist, match functional requirements

**Present review results:**

```
🔍 Final Review Complete

✅ Contract consistency - All docs align with locked contract
✅ Story dependencies - Correct sequential order
✅ Cross-references - All links verified
✅ TDD approach - Test-first in all stories
✅ Working output - User-testable emphasized
✅ Vertical slices - No horizontal layering
✅ Technical specs - Align with requirements

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
