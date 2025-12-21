# Story 5b: Extract Debug Command Templates

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Debug templates extracted to command-specific directory

## Developer Story

**As a** maintainer of debug command
**I want** debug templates extracted to `debug/templates/` directory
**So that** debug command context is focused and templates are co-located with debug logic

## Current State

**What's wrong:**
- Debug templates embedded in main `debug.md` file
- Hard to find and update templates
- Increases file size unnecessarily

## Target State

**What improved code looks like:**
```
.cursor/commands/
├── debug.md (references templates/)
└── debug/
    └── templates/
        ├── debug-overview.md (Mode B)
        └── investigation-step.md (Mode B)
```

## Scope

**In Scope:**
- Create `.cursor/commands/debug/templates/` directory
- Extract debug overview template
- Extract investigation step template
- Update `debug.md` to reference `debug/templates/`

**Out of Scope:**
- Other command templates (separate stories)
- Changing template content

## Acceptance Criteria

- [ ] `debug/templates/` directory exists
- [ ] All templates extracted (overview, step)
- [ ] `debug.md` references templates correctly
- [ ] Templates are Mode B (user-facing formats)

## Implementation Tasks

- [ ] 5b.1 Create `debug/templates/` directory
- [ ] 5b.2 Extract debug-overview.md template
- [ ] 5b.3 Extract investigation-step.md template
- [ ] 5b.4 Update debug.md with references
- [ ] 5b.5 User review

## Definition of Done

- [ ] All tasks completed
- [ ] Templates extracted to debug/templates/
- [ ] debug.md references work correctly
- [ ] Templates are Mode B
- [ ] User reviewed
- [ ] **Debug templates focused in command-specific directory**

