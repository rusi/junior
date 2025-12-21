# Story 5a: Extract Feature Command Templates

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Feature templates extracted to command-specific directory

## Developer Story

**As a** maintainer of feature command
**I want** feature templates extracted to `feature/templates/` directory
**So that** feature command context is focused and templates are co-located with feature logic

## Current State

**What's wrong:**
- Feature templates embedded in main `feature.md` file
- Hard to find and update templates
- Increases file size unnecessarily

## Target State

**What improved code looks like:**
```
.cursor/commands/
├── feature.md (references templates/)
└── feature/
    └── templates/
        ├── feature-overview.md (Mode B)
        ├── story.md (Mode B)
        └── technical-spec.md (Mode B)
```

**Goal:** Focus context per command, not centralized templates

## Scope

**In Scope:**
- Create `.cursor/commands/feature/templates/` directory
- Extract feature overview template
- Extract story template
- Extract technical spec template
- Update `feature.md` to reference `feature/templates/`

**Out of Scope:**
- Other command templates (separate stories)
- Changing template content

## Acceptance Criteria

- [ ] `feature/templates/` directory exists
- [ ] All 3 templates extracted (overview, story, spec)
- [ ] `feature.md` references templates correctly
- [ ] Templates are Mode B (user-facing formats)

## Implementation Tasks

- [ ] 5a.1 Create `feature/templates/` directory
- [ ] 5a.2 Extract feature-overview.md template
- [ ] 5a.3 Extract story.md template
- [ ] 5a.4 Extract technical-spec.md template
- [ ] 5a.5 Update feature.md with references
- [ ] 5a.6 User review

## Definition of Done

- [ ] All tasks completed
- [ ] Templates extracted to feature/templates/
- [ ] feature.md references work correctly
- [ ] Templates are Mode B
- [ ] User reviewed
- [ ] **Feature templates focused in command-specific directory**

