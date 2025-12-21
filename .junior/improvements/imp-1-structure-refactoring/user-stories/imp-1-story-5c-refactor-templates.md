# Story 5c: Extract Refactor Command Templates

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Refactor templates extracted to command-specific directory

## Developer Story

**As a** maintainer of refactor command
**I want** refactor (improvement) templates extracted to `refactor/templates/` directory
**So that** refactor command context is focused and templates are co-located with refactor logic

## Current State

**What's wrong:**
- Refactor/improvement templates embedded in main `refactor.md` file
- Hard to find and update templates
- Increases file size unnecessarily

## Target State

**What improved code looks like:**
```
.cursor/commands/
├── refactor.md (references templates/)
└── refactor/
    └── templates/
        ├── improvement-overview.md (Mode B)
        └── refactor-story.md (Mode B)
```

## Scope

**In Scope:**
- Create `.cursor/commands/refactor/templates/` directory
- Extract improvement overview template
- Extract refactor story template
- Update `refactor.md` to reference `refactor/templates/`

**Out of Scope:**
- Other command templates (separate stories)
- Changing template content

## Acceptance Criteria

- [ ] `refactor/templates/` directory exists
- [ ] All templates extracted (overview, story)
- [ ] `refactor.md` references templates correctly
- [ ] Templates are Mode B (user-facing formats)

## Implementation Tasks

- [ ] 5c.1 Create `refactor/templates/` directory
- [ ] 5c.2 Extract improvement-overview.md template
- [ ] 5c.3 Extract refactor-story.md template
- [ ] 5c.4 Update refactor.md with references
- [ ] 5c.5 User review

## Definition of Done

- [ ] All tasks completed
- [ ] Templates extracted to refactor/templates/
- [ ] refactor.md references work correctly
- [ ] Templates are Mode B
- [ ] User reviewed
- [ ] **Refactor templates focused in command-specific directory**

