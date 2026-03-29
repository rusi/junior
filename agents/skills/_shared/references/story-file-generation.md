# Story File Generation

Use this reference for consistent story-file generation and updates.

## Stage Path Resolution

- Stage 1: `.junior/features/feat-X/user-stories/`
- Stage 2: `.junior/features/comp-M/feat-X/user-stories/`
- Stage 3: `.junior/features/comp-M/features/feat-X/user-stories/`

## New Story File

File: `feat-X-story-{M+1}-{name}.md`

Use this structure:

```markdown
# Story {M+1}: [Title]

> **Status:** Not Started
> **Priority:** [High | Medium | Low]
> **Dependencies:** [Story Y OR None]
> **Deliverable:** [Fully working, integrated, user-testable feature]

## User Story

**As a** [user type]
**I want** [action]
**So that** [value]

## Scope

**In Scope:**
- [Deliverable 1 - fully integrated, working end-to-end]
- [Deliverable 2 - user can see/test working]

**Out of Scope:**
- [Features saved for future stories]

## Acceptance Criteria

- [ ] Given [context], when [action], then [outcome]
- [ ] Given [context], when [action], then [outcome]
- [ ] Given existing stories, when [integration], then [works correctly]

## Implementation Tasks

- [ ] {M+1}.1 Write tests (TDD: test first)
- [ ] {M+1}.2 Implement [component]
- [ ] {M+1}.3 [Next component]
- [ ] {M+1}.4 Integrate with existing stories
- [ ] {M+1}.5 Verify acceptance criteria
- [ ] {M+1}.6 Deploy and test end-to-end

## Technical Notes

[Implementation approach, integration points, key decisions]

See [../specs/01-Technical.md](../specs/01-Technical.md) for feature-level technical details.

## Testing Strategy

**TDD Approach:**
- Write tests first (red)
- Implement to pass tests (green)
- Refactor (clean)

**Unit Tests:** [What to test]
**Integration Tests:** [What to test with existing stories]
**Manual Testing:** [End-to-end scenarios user can verify]

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Feature works end-to-end (no stubs/mocks)
- [ ] All tests passing (unit + integration + end-to-end)
- [ ] No regressions in previous stories
- [ ] Integrates correctly with existing stories
- [ ] Code follows project conventions
- [ ] Documentation updated
- [ ] **User can see/test/validate working functionality**
- [ ] Deployed and verified
```

## Required Related Updates

1. Update `feat-X-stories.md` table with new row:

```markdown
| {M+1} | [Story Title] | Not Started | {N} | 0/{N} |
```

2. Update total task count and `Last Updated` timestamp.
3. For Stage 2/3, update `comp-M-overview.md` story counts and timestamp.

## Checkbox Format Rule

- Unchecked: `- [ ] Task description`
- Checked: `- ✅ Task description`
- Never use `- [x]` formats.
