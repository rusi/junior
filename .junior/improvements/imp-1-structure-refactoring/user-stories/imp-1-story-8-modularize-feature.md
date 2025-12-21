# Story 8: Modularize feature.md

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** Story 7 (commands should be standardized first)
> **Deliverable:** feature.md modularized from 1200 lines to ~300 lines main + submodules

## Developer Story

**As a** maintainer of Junior commands
**I want** feature.md broken into manageable submodules
**So that** the command is easier to navigate, understand, and maintain

## Current State

**What's wrong with current code:**
- `feature.md`: 1200 lines (too long)
- Hard to navigate and find specific sections
- Large file takes time to load and search
- Difficult to review changes
- Mixing of concerns (clarification, contract, generation, templates all in one file)

## Target State

**What improved code looks like:**
- Main file: `feature.md` at top level (~300 lines, orchestration only) - **NOT feature/feature.md**
- Submodules in `.cursor/commands/feature/` directory:
  - `contract.md` (Mode C) - Contract presentation to user
  - `generation.md` (Mode A) - Spec generation logic
  - `templates/` directory (Mode B) - Template files
- Main file references submodules
- **Clarification uses shared module from Story 3** (not duplicate submodule)
- Total lines same, just organized

**Structure:**
```
.cursor/commands/
├── feature.md                    # Main command (Mode A, ~300 lines)
│                                 # References _shared/clarification-loop.md
└── feature/
    ├── contract.md              # Mode B - template format (AI generates, user reviews)
    ├── generation.md            # Mode A - AI instructions
    └── templates/
        ├── feature-overview.md  # Mode B - spec templates
        ├── story.md             # Mode B - spec templates
        └── technical-spec.md    # Mode B - spec templates
```

**CRITICAL:** Keep simple `/feature` command path, NOT `/feature/feature`

## Scope

**In Scope:**
- Create `.cursor/commands/feature/` directory
- Split `feature.md` into main + submodules
- Extract contract format/template to submodule (Mode B - AI generates, user reviews)
- Extract generation logic to submodule (Mode A - AI instructions)
- Extract templates to templates/ directory (Mode B - spec templates)
- Update main file to reference submodules
- **Use shared clarification module from Story 3** (not duplicate)
- **Keep feature.md at top level** (simple `/feature` path)

**Out of Scope:**
- Changing feature command logic (just organizing)
- Other commands (separate stories)

## Acceptance Criteria

- [ ] Given feature.md, when split, then main file is ~300 lines
- [ ] Given submodules, when created, then clarification.md, contract.md, generation.md exist
- [ ] Given templates, when extracted, then templates/ directory exists with all templates
- [ ] Given main file, when reviewed, then it references all submodules correctly
- [ ] Given feature command, when tested, then it works identically to before

## Implementation Tasks

- [ ] 8.1 Create `.cursor/commands/feature/` directory
- [ ] 8.2 Create `feature/contract.md` (extract contract template from main, Mode B)
- [ ] 8.3 Create `feature/generation.md` (extract generation logic from main, Mode A)
- [ ] 8.4 Create `feature/templates/` directory (if not done in Story 5a)
- [ ] 8.5 Extract templates to `feature/templates/` (if not done in Story 5a)
- [ ] 8.6 Update `feature.md` to reference `_shared/clarification-loop.md` (not duplicate)
- [ ] 8.7 Update `feature.md` to reference contract.md and generation.md submodules
- [ ] 8.8 Verify `feature.md` stays at top level (simple `/feature` path)
- [ ] 8.9 Test feature command works correctly
- [ ] 8.10 User review of structure

## Verification Checklist

**Before marking story complete, verify:**
- [ ] Directory structure created
- [ ] Main file ~300 lines
- [ ] All submodules created with correct content
- [ ] Templates extracted to templates/
- [ ] Main file references submodules
- [ ] Feature command tested and works
- [ ] User has reviewed structure

## Regression Prevention

**Strategy:**
- Split without changing logic
- Test command after split
- Verify references work

**Validation:**
- Manual test: Run `/feature` command
- Structure check: All files present
- Reference check: Main file properly references submodules

## Rollback Plan

**If issues arise:**
1. Revert commit
2. Return to monolithic feature.md
3. Refine split and re-apply

**Rollback criteria:**
- References broken
- Content lost during split
- Command doesn't work

## Technical Notes

**Main file structure (feature.md ~300 lines):**
```markdown
## Purpose
[one sentence]

## Type
Contract-style

## When to Use
[scenarios]

## Process

### Step 1-3: [Early steps remain inline]
[Content]

### Step 4: Gap Analysis & Clarification
Use clarification loop from `_shared/clarification-loop.md` (Story 3).

### Step 5: Present Contract
See [feature/contract.md](feature/contract.md) for contract format.

### Step 6: Generate Specification
See [feature/generation.md](feature/generation.md) for generation logic.

[Remaining inline steps]

## Tool Integration
[tools list]

## Error Handling
[errors]

## Best Practices
[reminders]
```

**Mode assignment:**
- `feature.md` - Mode A (orchestration at top level)
- Clarification - Uses `_shared/clarification-loop.md` (Mode A from Story 3)
- `feature/contract.md` - Mode B (contract template format - AI generates, user reviews)
- `feature/generation.md` - Mode A (AI instructions for generation logic)
- `feature/templates/` - Mode B (spec templates - AI uses to generate, user reviews generated specs)

**Key principles:**
- Simple `/feature` command path (NOT `/feature/feature`)
- No duplicate clarification logic (use shared module)
- 3 layers avoided: command → shared module (not command → submodule → shared module)

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] feature.md split into main + submodules
- [ ] Main file ~300 lines
- [ ] All submodules created
- [ ] Templates extracted
- [ ] References work correctly
- [ ] Command tested successfully
- [ ] User reviewed structure
- [ ] **feature.md modularized (1200→300 lines)**

