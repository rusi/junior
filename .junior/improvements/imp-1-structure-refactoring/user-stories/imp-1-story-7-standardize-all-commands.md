# Story 7: Apply Standard Structure to ALL Commands

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** Story 6 (template must exist first)
> **Deliverable:** All 9 commands follow standard template structure

## Developer Story

**As a** maintainer of Junior commands
**I want** all commands to follow the standard template structure
**So that** commands are consistent, predictable, and easy to maintain

## Current State

**What's wrong with current code:**
- 9 commands have different structures
- Section order varies
- Naming inconsistent (Overview vs Purpose, Workflow vs Process)
- Hard to navigate between commands
- Inconsistent user experience

**Commands to standardize:**
1. `feature.md`
2. `implement.md`
3. `commit.md`
4. `status.md`
5. `maintenance.md`
6. `debug.md`
7. `refactor.md`
8. `migrate.md`
9. `new-command.md`

## Target State

**What improved code looks like:**
- ALL 9 commands follow standard template (from Story 6)
- Consistent section order:
  1. Purpose
  2. Type
  3. When to Use
  4. Process
  5. Tool Integration
  6. Error Handling
  7. Best Practices
- Predictable structure (easier to learn and maintain)
- Zero content changes (just restructuring)

## Scope

**In Scope:**
- Apply template to ALL 9 commands (Mode A)
- Restructure sections to match template
- Standardize section names
- Maintain all existing content (just reorganize)
- Grep verification: All commands have standard sections

**Out of Scope:**
- Changing command content (just structure)
- Modularizing long commands (that's Phase 3, Stories 8-10)
- Adding new sections (just standardizing existing)

## Acceptance Criteria

- [ ] Given 9 commands, when restructured, then all follow standard template
- [ ] Given command sections, when reviewed, then all use standard names (Purpose, Type, When to Use, Process, Tool Integration, Error Handling, Best Practices)
- [ ] Given command content, when compared, then no content lost (only reorganized)
- [ ] Given commands, when grep searched, then all have standard sections

## Implementation Tasks

- [ ] 7.1 Update `feature.md` - apply template structure
- [ ] 7.2 Update `implement.md` - apply template structure
- [ ] 7.3 Update `commit.md` - apply template structure
- [ ] 7.4 Update `status.md` - apply template structure
- [ ] 7.5 Update `maintenance.md` - apply template structure
- [ ] 7.6 Update `debug.md` - apply template structure
- [ ] 7.7 Update `refactor.md` - apply template structure
- [ ] 7.8 Update `migrate.md` - apply template structure
- [ ] 7.9 Update `new-command.md` - apply template structure
- [ ] 7.10 Grep verification: All commands have "## Purpose", "## Type", "## When to Use", "## Process", "## Tool Integration", "## Error Handling", "## Best Practices"
- [ ] 7.11 User review of changes (all 9 files)

## Verification Checklist

**Before marking story complete, verify:**
- [ ] All 9 commands updated
- [ ] All commands have 7 standard sections
- [ ] Section order consistent across commands
- [ ] No content lost (only reorganized)
- [ ] Grep check passes (all sections present)
- [ ] User has reviewed all changes

## Regression Prevention

**Strategy:**
- Restructure without changing content
- Verify all content present after reorganization
- Each command tested manually

**Validation:**
- Manual review: Compare before/after for each command
- Content check: No paragraphs lost
- Structure check: All sections in standard order
- Grep verification: Standard sections present

## Rollback Plan

**If issues arise:**
1. Identify which commands have issues
2. Revert specific commands
3. Refine structure and re-apply

**Rollback criteria:**
- Content lost during reorganization
- Structure doesn't fit command
- User finds issues in review

## Technical Notes

**Restructuring approach:**

Before (example - varies per command):
```markdown
## Overview
[content]

## When to Use
[content]

## Workflow
Step 1: [step]
Step 2: [step]

## Best Practices
[content]
```

After (standard template):
```markdown
## Purpose
[one sentence from Overview]

## Type
[Contract-style | Direct execution | Adaptive]

## When to Use
[scenarios from When to Use section]
[Add "NOT for:" counter-scenarios if present]

## Process

### Step 1: [step name]
[content]

### Step 2: [step name]
[content]

## Tool Integration
[tools used, extracted from workflow or added]

## Error Handling
[common errors, extracted or added]

## Best Practices
[key reminders from Best Practices section]
```

**Per-command notes:**

- `feature.md`: Already close to template, minor reordering
- `implement.md`: Extract Tool Integration from Process section
- `commit.md`: Reorder sections, add Tool Integration
- `status.md`: Already close, minor adjustments
- `maintenance.md`: Reorder, add Error Handling
- `debug.md`: Restructure Process section
- `refactor.md`: Already close (recently updated)
- `migrate.md`: Major restructuring (15 steps → organized under Process)
- `new-command.md`: Minor reordering

**Mode A consistency:**
All commands are Mode A (AI instructions), maintain concise style.

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] All 9 commands restructured
- [ ] All commands follow standard template
- [ ] No content lost (only reorganized)
- [ ] Grep verification passes
- [ ] User reviewed all 9 files
- [ ] Zero functional changes
- [ ] **All commands follow standard structure**

