---
name: jr-feature
description: Run `/jr-feature` to specify a new feature end to end and break it into stories before any code is written.
---

# Feature

## Purpose

Create comprehensive feature specifications through contract-first clarification, transforming rough ideas into actionable specs with end-to-end user stories.

## Type

Contract-style (clarification → scope approval → generation → artifact review → consistency checks)

Keep two distinct review points: approval of the scope contract and review of the generated
artifacts. Placement, component assignment, and story sequencing belong in the scope contract;
ask separate clarification questions only for unresolved decisions. Reuse explicit approval
already given for the same scope. Final consistency checks and repairs within that scope run
under existing approval. This is an agent workflow norm, not an automated guarantee.

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
- **Reference 01-structure.md for structure definitions (DON'T repeat)**
- **ONE SENTENCE for implementations agent knows (clustering, sorting, parsing)**

**User Stories (user-stories/feat-N-story-M.md):**
- Context-gathering step (read existing files to understand before changing)
- Implementation tasks (WHAT to do, not HOW - agent figures out HOW)
- Review/refinement/testing steps after main work
- Testing scenarios (validate behavior, not detailed test code)
- Definition of Done (acceptance criteria, completeness checks)
- **Do NOT pre-check acceptance criteria or Definition of Done** (leave unchecked until verified)

**Key Principles:**
- **DRY:** Define structures/functions once in 01-structure.md, reference everywhere
- **Thorough:** Include design decisions, rationale, trade-offs
- **Concise:** Exclude pseudo-code for known patterns, avoid repetition
- **Reference:** Link to existing definitions instead of duplicating

**What each artifact is for:**

- **`feat-N-overview.md`** — read by whoever picks this feature up cold. Answers *what is being
  built, for whom, and what counts as done.*
- **`specs/01-Technical.md`** — read while implementing. Answers *how the pieces fit and why this
  design over the alternatives.*
- **`feat-N-story-M.md`** — read by the run that implements this slice. Answers *what to build, and
  how to know it works.*
- **`feat-N-stories.md`** — read to find the next slice. Answers *what is done and what is next.*

**Never goes in any of them:**

- What was clarified in the contract loop, and which question produced which answer
- Which files were scanned to reach the scope, and how many
- Scope that was proposed and cut, unless a reader would otherwise propose it again — and then it
  belongs in the future-enhancements document, as a candidate, not as a record of the cut
- The contract's own approval history, or that an approval happened
- Rule citations standing in for the requirement they justify

Baseline: `../_shared/references/artifact-output-spec.md`.

**Register:** headings are noun labels — never sentences, questions or conversational phrases. Prose
states facts. No editorial lead, no anthropomorphising, no dramatic adjective.

## Process

### Step 1: Verify Git State

```bash
git status --short
```

If not clean, ask for explicit user override:
```
⚠️ Uncommitted changes detected.

Scope check:
- Review changed paths from `git status --short`.
- If changes are clearly isolated from the feature planning scope, recommend proceeding.
- If changes touch related areas or scope is unclear, ask for explicit override.

Default: use /jr-commit first.
Override: If you confirm the changes are unrelated, reply "override: proceed".
```

Proceed only if:
- Working directory is clean, OR
- You recommend proceeding based on isolated scope, OR
- User explicitly confirms override with "override: proceed".

If override is used, suggest (not require) optional safety actions:
- Stash unrelated changes
- Confirm scope is isolated

### Step 2: Initialize Tracking

**Use `update_plan` (required). Do NOT output raw JSON for tracking.**

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

**3.0: Detect current stage**

First, detect which stage the project is in (see `01-structure.md` for detection logic):

```bash
# Stage detection (filesystem checks)
# Stage 1: No comp-*/ directories under .junior/features/
# Stage 2: comp-*/ directories exist, no features/ subdirectory within
# Stage 3: comp-*/ directories with features/ subdirectories
```

**Detection logic:**
- Check for `comp-*/` directories under `.junior/features/`
- If none: **Stage 1** (flat structure)
- If exist: Check for `features/` subdirectory within components
  - If no `features/` subdirectory: **Stage 2** (component organization)
  - If `features/` subdirectory exists: **Stage 3** (grouped structure)

Store detected stage for use in later steps (component proposal, path resolution).

**3.1: Scan & build comprehensive context**

Scan all `.junior/` working memory to understand existing work:

- `list_dir` or `functions.shell_command` `.junior/features/` → existing features and components
  - **Stage 1:** Read `feat-N-overview.md` files directly under features/
  - **Stage 2+:** Read `comp-N-overview.md` files to understand components, then read features within
  - `read_file` or `functions.shell_command` each `feat-N-overview.md` to understand feature scope and status
  - `read_file` or `functions.shell_command` each `feat-N-stories.md` to see current story breakdown
- `list_dir` or `functions.shell_command` `.junior/research/` → technical investigations
- `list_dir` or `functions.shell_command` `.junior/experiments/` → validation experiments
- `list_dir` or `functions.shell_command` `.junior/debugging/` → active debugging sessions
- `list_dir` or `functions.shell_command` feature-local `bugs/` directories → tracked bugs (see `01-structure.md`)
- `list_dir` or `functions.shell_command` feature-local `enhancements/` directories → small improvements (see `01-structure.md`)
- `read_file` or `functions.shell_command` `.junior/product/01-mission.md` → product vision, problem, users, value (if exists)
- `read_file` or `functions.shell_command` `.junior/product/02-roadmap.md` → roadmap sequence, scope, and execution tracking (if exists)
- `read_file` or `functions.shell_command` `.junior/product/03-tech-stack.md` → tech stack and architecture (if exists)
- `codebase_search` or `functions.shell_command` for architecture patterns relevant to request
- Load project context if available

**Build mental model:**
- **Current stage** (1, 2, or 3) and what it means for feature placement
- **Existing components** (Stage 2+): What components exist, their purposes, what features they contain
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

3. **Modification of Existing Story (use this skill’s Update Existing mode)**
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

**Recommendation: [New Feature | Add to feat-X | Update Existing]**

**Reasoning:**
[1-2 sentences explaining why this placement makes sense]

**If new feature:**
- Will be created as feat-{N+1}
- Scope: [Initial understanding of scope]

**If add to existing:**
- Will add story to feat-X
- Current stories: {M} stories
- New story will be: feat-X-story-{M+1}

```

Proceed to clarification. Ask about placement only if the request and repository evidence
leave a material ambiguity; otherwise carry the recommendation into Step 5.

**3.3: Component Proposal (Stage 2+ only)**

**If Stage 2 or Stage 3 detected AND creating new feature:**

For the recommended new feature placement, propose component assignment in the scope contract:

**Semantic Matching Process:**

1. **Extract keywords from feature description** (use feature name + user description)
2. **Compare with existing components:**
   - Read `comp-N-overview.md` files to understand component purposes
   - Match keywords between feature and components
   - Calculate semantic similarity (shared keywords, related terms)
3. **Decision:**
   - **Good match found** (>60% keyword overlap or clear domain alignment): Propose existing component
   - **No good match** (domain mismatch or no shared keywords): Propose new component

**Present component proposal:**

```
🏗️ Component Assignment (Stage {2|3})

Based on your feature description, I recommend:

**Option 1 (Recommended): Add to existing component**
- Component: comp-{M}-{name}
- Purpose: [Component purpose from comp-M-overview.md]
- Reasoning: [Why this feature fits - shared keywords, domain alignment]
- Current features: {X} features (highest is feat-{K})
- New feature: feat-{K+1} (increment highest in this component)
- Path: .junior/features/comp-{M}/feat-{K+1}/  [Stage 2]
        .junior/features/comp-{M}/features/feat-{K+1}/  [Stage 3]

**Option 2: Create new component**
- Component: comp-{M+1}-{suggested-name}
- Purpose: [Inferred from feature description]
- Reasoning: [Why separate component makes sense]
- New feature: feat-1 (new component always starts at feat-1)
- Path: .junior/features/comp-{M+1}/feat-1/  [Stage 2]
        .junior/features/comp-{M+1}/features/feat-1/  [Stage 3]

```

Include the recommended component and its rationale in the scope contract. Ask separately
only if a material placement decision remains unresolved.

**For an existing component:**
- Feature will be added to existing component
- Component overview will be auto-updated (add feature row to table)

**For a new component:**
- New component will be created
- Component overview will be generated using template from `01-structure.md`

**Store component assignment for use in Step 6 (directory creation).**

**If Stage 1 detected:**
- Skip component proposal (flat structure)
- Feature will be created directly under `.junior/features/`

**🔢 CRITICAL: Feature Numbering Convention**

**Features are numbered LOCAL to each component, NOT globally:**

- **New component** → Start at `feat-1`
- **Existing component** → Increment highest feat-N in that component
- Each component has its own `feat-1`, `feat-2`, `feat-3`, etc.

**Examples:**
- `comp-1-auth/features/feat-1-user-login/`
- `comp-3-payments/features/feat-1-checkout/` ← New component starts at feat-1
- `comp-1-auth/features/feat-2-password-reset/` ← Second feature in comp-1

**Legacy Note:**
Existing features may have non-sequential numbers (feat-3, feat-8, feat-12) because they were migrated from a flat structure and kept their original numbers for continuity. This is correct - don't renumber legacy features.

**NEVER use global feature numbering.** Each component maintains its own feature sequence.

**3.4: Set working mode**

Based on the request and placement analysis:
- **New Feature mode:** Full feature specification (contract + stories + specs)
- **Add Story mode:** Add story to existing feature (update existing feat-X)
- **Update Existing:** Modify existing story/jr-feature specifications

All modes proceed to Step 4 for clarification (scope varies by mode).

**Output:** Placement and component recommendation for the scope contract

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

**4.5: Prepare the Story Outline**

Include the planned story titles, consumer outcomes, and high-impact sequencing decisions in
Step 5's Stories Preview. Review them as part of the scope contract, without a separate outline
approval. Apply [Vertical Slice Validation](../_shared/references/vertical-slices.md) before
presenting the contract; resolve missing consumer outcomes or required integration.

---

### Step 5: Present Contract

**Contract format varies by mode:**

**For New Feature:**

```
## Feature Contract

**Placement:** [New feature / add story / update existing; component and path where applicable]
**Feature:** [One sentence describing what will be built]
**User Value:** [Core problem solved and who it helps]
**Hardest Constraint:** [Biggest technical/business limitation]
**Success Criteria:** [How we'll know it works correctly]

**Scope:**
- ✅ Included: [2-3 key capabilities]
- ❌ Excluded: [2-3 things we won't build]

**Integration Points:**
- [Existing system/jr-feature this connects to]
- [New dependencies or services needed]

**⚠️ Technical Concerns (if any):**
- [Specific concern about feasibility, performance, or architecture]
- [Suggested mitigation approach]

**💡 Recommendations:**
- [Suggestions for simpler/better approach based on codebase analysis]
- [Ways to reduce risk or complexity]

**Stories Preview (MUST be vertical slices):**

Story 1: [Title - ONE sentence what user sees working]
- **Layers:** [Only layers required by this consumer outcome]
- **User sees:** [Specific working output - what can user test/validate?]
- **Deliverable:** [End-to-end feature working - reduced scope but complete]

Story 2: [Title - Enhancement to Story 1]
- **Layers:** [Required layers extended for this outcome]
- **User sees:** [Additional working capability]
- **Deliverable:** [More features, still end-to-end working]

Story 3: [Title - Further enhancement or new capability]
- **Layers:** [Required layers added or extended]
- **User sees:** [Complete feature working]
- **Deliverable:** [Full scope achieved, end-to-end]

**Validation:** Every story must pass [Vertical Slice Validation](../_shared/references/vertical-slices.md).
Name its consumer outcome, required layers, and acceptance evidence in the preview.

---
Options: yes | edit: [changes] | risks | simpler
```

**For Add Story to Existing Feature:**

- Use `../_shared/references/story-contracts.md` -> "Add Story Contract" as canonical structure.
- Preserve all contract sections; do not compress scope, integration, or impact analysis.

**For Update Existing Feature/Story:**

- Use `../_shared/references/story-contracts.md` -> "Update Existing Feature/Story Contract" as canonical structure.
- Include explicit dependency and regression impact analysis for every requested change.

Include the placement and sequencing recommendations in the applicable contract. Obtain scope
approval before generation, unless the user has already explicitly approved that same scope.
If a material scope decision remains open, ask one focused question about that decision.

### Step 6: Generate Spec Package

Keep this package in working material. If standalone product documentation is part of the approved scope, apply [product isolation](../_shared/references/product-isolation.md) at its write step; do not copy private planning templates verbatim.

For approved interface design exploration, load and follow [UI Prototype](../jr-ui-prototype/SKILL.md),
including its parent context and return contract, before final specification review.

**Generation scope varies by mode:**

- **New Feature:** Full feature package (overview + stories + specs)
- **Add Story:** New story file + update feat-X-stories.md
- **Update Existing:** Modify targeted files + update dependent files

#### 6.1: Create Directory Structure

**For New Feature:**

**Path resolution based on detected stage:**

**Stage 1 (Flat structure):**
```
.junior/features/feat-{N}-{name}/
├── feat-{N}-overview.md
├── user-stories/
│   ├── feat-{N}-stories.md
│   └── feat-{N}-story-{M}-{name}.md
└── specs/ (only if needed)
    ├── 01-Technical.md
    ├── 02-API.md
    ├── 03-Database.md
    └── 04-UI-Wireframes.md
```

**Stage 2 (Component organization, flat within component):**
```
.junior/features/comp-{M}-{name}/
├── comp-{M}-overview.md                    ← Auto-update or create
├── feat-{N}-{name}/                        ← New feature here
│   ├── feat-{N}-overview.md
│   ├── user-stories/
│   │   ├── feat-{N}-stories.md
│   │   └── feat-{N}-story-{M}-{name}.md
│   └── specs/ (only if needed)
│       └── 01-Technical.md
└── [other features/improvements in component]
```

**Stage 3 (Grouped structure, type-based organization):**
```
.junior/features/comp-{M}-{name}/
├── comp-{M}-overview.md                    ← Auto-update
├── features/                               ← Features grouped by type
│   └── feat-{N}-{name}/                    ← New feature here
│       ├── feat-{N}-overview.md
│       ├── user-stories/
│       │   ├── feat-{N}-stories.md
│       │   └── feat-{N}-story-{M}-{name}.md
│       └── specs/ (only if needed)
│           └── 01-Technical.md
├── improvements/ (if exist)
├── docs/ (component-level, if exist)
└── specs/ (component-level, if exist)
```

**Directory creation process:**

Determine correct path based on detected stage and component assignment from Step 3:

- **Stage 1:** Create at `.junior/features/feat-N-name/`
- **Stage 2:** Create at `.junior/features/comp-M-name/feat-N-name/`
  - If new component: Create component directory + `comp-M-overview.md`
  - If existing component: Update `comp-M-overview.md` (add feature row)
- **Stage 3:** Create at `.junior/features/comp-M-name/features/feat-N-name/`
  - Update `comp-M-overview.md` (add feature row)

Create feature subdirectories:
- `user-stories/` (always)
- `specs/` (only if technical specs needed)

**Generation checklist (required):**
- [ ] Create `feat-{N}-overview.md`
- [ ] Create `user-stories/feat-{N}-stories.md`
- [ ] Create numbered story files for all planned stories
- [ ] Create `user-stories/feat-{N}-story-future-enhancements.md`
- [ ] Link future enhancements doc from `feat-{N}-stories.md`
- [ ] Update `.junior/product/02-roadmap.md` execution tracking (checkboxes + progress) via `../_shared/references/roadmap-progress-sync.md`

**Component overview auto-update (Stage 2+):**

When adding feature to existing component, append row to Features table in `comp-M-overview.md`:

```markdown
| feat-N | [Feature Title] | Planning | [Brief description from feature contract] |
```

Update "Last Updated" timestamp in component overview.

**For Add Story:**

- Reuse `../_shared/references/story-file-generation.md` for path resolution, story file template, checkbox format, and required related updates.
- For this mode, generate one story file and update `feat-X-stories.md` (plus `comp-M-overview.md` on Stage 2/3).
- Also update roadmap tracking in `.junior/product/02-roadmap.md` using `../_shared/references/roadmap-progress-sync.md`.

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

- Use `templates/feat-overview-template.md` as the canonical structure for `feat-{N}-overview.md`.
- The template includes the Technical Approach section with architecture overview, key integration points, and testing strategy.

#### 6.3: Generate User Stories

**For New Feature:** Generate all stories
**For Add Story:** Generate one new story + update stories.md
**For Update Existing:** Modify targeted story + cascade updates

**🔴 CRITICAL: Checkbox Format Consistency**

**ALL checkboxes in story files MUST use this format:**
- Unchecked: `- [ ] Task description`
- Checked: `- ✅ Task description`

**NEVER generate:**
- ❌ `- [x] Task description` (markdown checked format)
- ❌ `- [x] Task description ✅` (mixed/redundant format)

This format is MANDATORY for consistency with commit instructions.

**🔴 CRITICAL: Every Story MUST Be a Vertical Slice**

Apply [Vertical Slice Validation](../_shared/references/vertical-slices.md) before generating each story.

**Story breakdown pattern:**
1. **Story 1:** Smallest possible working feature (full stack, minimal scope)
   - Example: "Button → renders ONE test screen → saves PNG file"
2. **Story 2:** Enhance with more capability (full stack, more features)
   - Example: "Progress bar → renders ALL scenarios → English only"
3. **Story 3:** Expand to full scope (full stack, complete feature)
   - Example: "All supported languages → organized output → complete localized screenshot set"

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
**Total:** 0/9 tasks (0%)

**Note:** Future enhancements backlog captured in `feat-{N}-story-future-enhancements.md` (not numbered, allows adding more stories)

## Story Dependencies

- Story 2 depends on Story 1 completion
- Story 3 can run parallel to Story 2

## Implementation Order

Follow stories sequentially. Each story must be:
- End-to-end integrated
- User-testable with working output
- Built using TDD (test first, implement, verify)

Future enhancements are captured separately for later consideration.

## Quick Links

- [Story 1](./feat-{N}-story-1-{name}.md)
- [Story 2](./feat-{N}-story-2-{name}.md)
- [Future Enhancements](./feat-{N}-story-future-enhancements.md)
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

## Demo Script

**Medium:** [`stills`, or `motion` where the answer is in the passage between two states —
a hover menu crossing into its submenu, stale data flashing before a switch lands. Name the
question that decides it, not just the word. Most questions that feel like motion are state
questions with a panel missing.]

[Ordered prose — what a reviewer should be shown of this working, one line per thing to
see, six to ten of them. Written here while the intent is fresh, and read later by the
command that captures it.]

[Where the story renders nothing a person can look at, write "Not applicable" and why.]

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

**Generate final document: Future Enhancements (NOT a numbered story)**

After generating all planned implementation stories, automatically create a future enhancements backlog document:

**CRITICAL: This is NOT a numbered story. It does NOT take a story number. This allows adding more numbered stories later without conflicts.**

**Filename:** `feat-{N}-story-future-enhancements.md` (NOT `feat-{N}-story-{M}-...`)

**Why this naming:** Uses `story-future` prefix so it sorts AFTER all numbered stories (feat-1-story-1, feat-1-story-2, feat-1-story-future)

```markdown
# Future Enhancements & Follow-up Work

> **Type:** Backlog / Documentation
> **Priority:** Low
> **Status:** For Future Consideration

## Purpose

This document captures features, enhancements, and technical considerations that were identified during feature planning but intentionally excluded from the initial scope. These items should be reviewed and potentially implemented in future iterations once the core feature is stable.

**Note:** This is a backlog document, NOT a numbered story. It does not interfere with adding new numbered stories to this feature.

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

## How to Use This Document

When ready to implement items from this backlog:
1. Review and prioritize items
2. Create new numbered stories (e.g., Story 3, Story 4) for selected items
3. Follow normal story workflow (contract → approval → implementation)

**File sorts last:** This file uses `story-future` naming so it appears after all numbered stories in directory listings.
```

**🔴 CRITICAL STORY RULES (NON-NEGOTIABLE):**

1. **VERTICAL SLICES** - Apply [Vertical Slice Validation](../_shared/references/vertical-slices.md).
2. **CONSUMER OUTCOME** - Name what the consumer can verify after each story.
3. **COMPLETE IMPLEMENTATION** - Include the required integration for that outcome.

4. **TDD THROUGHOUT** - Test first, implement, verify (in EVERY story)

5. **MAX 5-7 TASKS** - Split if more (keeps stories focused)

6. **FINAL FUTURE WORK DOCUMENT** - Always generate unnumbered future enhancements backlog

**USER MUST SEE WORKING OUTPUT AFTER EACH STORY**

Every story completion must result in something the user can:
- See working (UI/CLI output)
- Test manually
- Verify functionality
- Validate against requirements

**✅ Correct Approach (Vertical Slices):**

**Example: Data Dashboard Feature**

**Story 1: Basic Data Display**
- **What:** TDD, basic DB schema, backend fetch basic data, simple UI table with manual refresh
- **Why:** Full stack working end-to-end, minimal scope
- **User sees:** Working dashboard showing basic data list, can manually refresh to see real data
- **Deliverable:** Deployed feature - database, API, UI all working together

**Story 2: Enhanced Data Details**
- **What:** TDD, scheduled fetching (backend), fetch all data details, add columns to UI table
- **Why:** Builds on working foundation, enhances entire stack
- **User sees:** Auto-refreshing dashboard with more information (status, dates, etc.)
- **Deliverable:** More useful feature, still fully working end-to-end

**Story 3: Add Metadata Tracking**
- **What:** TDD, extend DB schema for metadata, backend fetch metadata, UI shows additional details
- **Why:** New capability through entire stack
- **User sees:** Data items with metadata and status information
- **Deliverable:** Additional capability, fully integrated

**Story 4-6:** Filtering, Sorting, Analytics, Multi-Source Sync
- Each adds capability through full stack (DB + Backend + UI)
- User validates each addition before moving forward
- Can stop/pivot at any point with working feature

**Pattern for this web application:** Each slice spans its required database, backend, and frontend. Other product types use their own consumer boundary and required layers.

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

Use the UI Specification output contract in [UI Prototype](../jr-ui-prototype/SKILL.md).
Reference its accepted prototype, launch instructions, and matching screenshots; do
not generate a second design or replace runnable artifacts with static descriptions.
For requirements that need no design exploration, document the relevant existing
behavior and constraints without manufacturing a prototype. Prototype verification
does not complete production acceptance criteria.

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

Please review the generated specification and share any changes. When it looks good, I will run the final consistency checks.
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

**Trigger:** The user accepts the generated artifacts in Step 7 (for example, "ready" or
"looks good"). Continue directly under that approval; do not request another specification
confirmation. Preserve saved feedback and apply requested refinements within the approved scope.

Update todos:
```json
{
  "todos": [
    {"id": "verify-contract", "content": "Verify contract matches all docs", "status": "in_progress"},
    {"id": "check-stories", "content": "Check story consistency and dependencies", "status": "pending"},
    {"id": "validate-specs", "content": "Validate spec cross-references", "status": "pending"},
    {"id": "check-tdd", "content": "Ensure TDD approach in all stories", "status": "pending"},
    {"id": "check-stage", "content": "Check if project has outgrown current stage", "status": "pending"}
  ]
}
```

Run the checks below and repair inconsistencies within the approved scope without asking again.
If a check exposes a new requirement or a material change to an accepted decision, ask only about
that change, revise the affected artifacts for review, and resume these checks after acceptance.
Do not reopen unchanged decisions or treat consistency repairs as a new approval gate.

**Consistency checklist (agent review, with mechanical link checks where available):**

1. **Contract consistency:** feat-N-overview.md contract matches stories and specs
2. **Story dependencies:** Stories reference each other correctly
3. **Cross-references:** All links work (feat-N-overview.md ↔ stories ↔ specs)
4. **TDD approach:** All stories include test-first tasks
5. **Working output:** All stories emphasize user-testable output
6. **Vertical slices:** Every story passes [Vertical Slice Validation](../_shared/references/vertical-slices.md).
7. **Technical alignment:** specs/01-Technical.md aligns with feat-N-overview.md
8. **API consistency:** If API spec exists, matches feature requirements
9. **Database consistency:** If DB spec exists, matches data requirements
10. **UI/UX consistency:** If wireframes exist, match functional requirements
11. **Roadmap tracking consistency:** `.junior/product/02-roadmap.md` checkboxes/progress align with generated or updated feature stories (see `../_shared/references/roadmap-progress-sync.md`)

**Review all documents for consistency:**

- Read feat-N-overview.md contract
- Read all user stories
- Read all specs (if exist)
- Verify cross-references work
- Check alignment and consistency
- Ensure all file references use repository-relative paths (e.g. `.junior/...`, `docs/...`), never absolute filesystem paths

**Stage Growth Check (performed after all other checks):**

After completing consistency checks, evaluate if the project has outgrown its current stage:

**Stage 1 → Stage 2 evaluation:**
- Count total features in `.junior/features/`
- If 6+ features, check for natural clustering (shared keywords, related domains)
- If clear clustering exists: Recommend `/jr maintenance` to reorganize

**Stage 2 → Stage 3 evaluation:**
- Check each component in `.junior/features/`
- Count items in component (features + improvements + bugs + enhancements)
- If component has 13+ items OR would benefit from `docs/` or `specs/` directories at component level: Recommend `/jr maintenance`

**If stage growth detected, present recommendation:**

```
💡 Structure Recommendation

Your project may benefit from reorganization:

**Current:** Stage {1|2}
**Recommended:** Stage {2|3}

**Reasoning:** [Brief explanation - e.g., "8 features now cluster into 3 distinct components" or "Component has 14 items, would benefit from type grouping"]

**Next step:** Run `/jr maintenance` to analyze and reorganize structure

This is optional - you can continue with current structure if you prefer.
```

Treat stage growth as an optional follow-up. Complete the consistency review without waiting
for a reorganization decision; it does not reopen the approved specification.

**Present review results:** Follow the [planning completion handoff](../_shared/references/planning-completion.md); offer `/jr-commit` before implementation or unrelated follow-ups.

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

Feature specification is complete.

**Next step:** Commit the reviewed planning changes.

Would you like me to run `/jr-commit` for this feature specification?
```

## Tools

- `todo_write` or `functions.update_plan` - Progress tracking
- `list_dir` or `functions.shell_command` - Scan features
- `codebase_search` or `functions.shell_command` - Architecture analysis
- `grep` (via `functions.shell_command`) - Code patterns
- `read_file` or `functions.shell_command` - Context loading
- `run_terminal_cmd` or `functions.shell_command` - Git status, current date
- `write` or `functions.apply_patch` - File creation

**"Simplicity is the ultimate sophistication."**
