# Story 11: Add Cross-References to Core Rules

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** None (independent from other phases)
> **Deliverable:** Cross-references added to 3 core rules

## Developer Story

**As a** maintainer of Junior rules
**I want** core rules to cross-reference related rules
**So that** dependencies are clear and duplication is avoided

## Current State

**What's wrong:**
- Rules don't reference each other
- Overlapping content between rules
- Hard to know which rule to check for specific guidance
- Updates might miss related rules

**Core rules:**
- `00-junior.mdc` - Identity and core philosophy
- `01-structure.mdc` - Structure definitions
- `04-meta-rules.mdc` - Documentation modes (A/B/C)

## Target State

**What improved code looks like:**
- Each rule has dependency declarations in frontmatter
- "See also" sections point to related rules
- Clear boundaries between rules documented
- No overlapping content (cross-reference instead)

## Scope

**In Scope:**
- Add frontmatter with dependencies to 3 core rules
- Add "See also" sections
- Clarify rule boundaries (e.g., 00-junior vs 13-software-implementation)
- Update any overlapping content to cross-reference

**Out of Scope:**
- Changing rule content (just adding references)
- Other rules (separate stories)

## Acceptance Criteria

- [ ] Given 3 core rules, when updated, then all have dependency declarations
- [ ] Given rules, when reviewed, then "See also" sections present
- [ ] Given overlapping content, when found, then replaced with cross-references
- [ ] Given rule boundaries, when reviewed, then clearly documented

## Implementation Tasks

- [ ] 11.1 Update `00-junior.mdc` - add dependencies, "See also" sections
- [ ] 11.2 Update `01-structure.mdc` - add dependencies, "See also" sections
- [ ] 11.3 Update `04-meta-rules.mdc` - add dependencies, "See also" sections, clarify boundary with 03-style-guide.mdc
- [ ] 11.4 Check for overlapping content, add cross-references
- [ ] 11.5 User review of changes

## Verification Checklist

**Before marking story complete, verify:**
- [ ] All 3 rules have dependency frontmatter
- [ ] All rules have "See also" sections
- [ ] Overlapping content replaced with cross-references
- [ ] Rule boundaries documented
- [ ] User reviewed changes

## Technical Notes

**Frontmatter format:**
```markdown
---
alwaysApply: true
dependencies:
  - 01-structure.mdc      # Relies on structure definitions
  - 03-style-guide.mdc    # Uses documentation guidelines
---
```

**Cross-reference format:**
```markdown
## Critical Principle: DRY

[Principle content...]

**See also:** `13-software-implementation-principles.mdc` for DRY implementation patterns.
```

**Rule boundaries to clarify:**
- `00-junior.mdc` (philosophy) vs `13-software-implementation-principles.mdc` (implementation)
- `03-style-guide.mdc` (general docs) vs `04-meta-rules.mdc` (Mode A/B/C)

## Definition of Done

- [ ] All tasks completed
- [ ] 3 core rules updated
- [ ] Dependencies declared
- [ ] "See also" sections added
- [ ] Boundaries clarified
- [ ] User reviewed
- [ ] **Core rules cross-referenced**

