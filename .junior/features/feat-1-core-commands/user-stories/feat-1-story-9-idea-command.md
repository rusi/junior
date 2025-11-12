# Story 9: Implement /idea Command

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** None
> **Deliverable:** Fully working idea capture command for quick product idea documentation

## User Story

**As a** developer or product thinker
**I want** to quickly capture product ideas without disrupting my current work
**So that** good ideas don't get lost and can be reviewed later for feature planning

## Scope

**In Scope:**
- Create idea.md command file with lightweight capture workflow
- Quick prompts for idea essence (1-2 questions max)
- Store ideas in `.junior/ideas/` directory
- Simple markdown format with timestamps
- Tag ideas with categories (feature, improvement, exploration)
- List existing ideas when requested

**Out of Scope:**
- Full feature planning (use `/feature` for that)
- Idea prioritization or voting
- Idea-to-feature conversion workflow (manual for now)
- Collaboration features (comments, discussions)

## Acceptance Criteria

- [ ] Given user has idea, when `/idea` runs, then captures with 1-2 questions max
- [ ] Given idea captured, when saved, then stored in `.junior/ideas/idea-N-name.md`
- [ ] Given multiple ideas, when user requests, then can list all ideas with summaries
- [ ] Given idea file, when reviewing, then includes timestamp, category, and description
- [ ] Given quick capture, when complete, then takes < 2 minutes to document
- [ ] Given git clean state required, when `/idea` runs, then no git check (ideas are low-friction)

## Implementation Tasks

- [ ] 9.1 Research `reference-impl/cursor/commands/create-idea.md` for lightweight capture patterns
- [ ] 9.2 Run `/new-command` with prompt: "Create idea command for quick product idea capture without disrupting workflow. Minimal friction: 1-2 questions max (idea description, category: feature/improvement/exploration). Generates idea file in `.junior/ideas/idea-N-name.md` with timestamp, category, status, and description sections. Includes optional listing (`/idea list`) and show (`/idea show N`) functionality. Quick capture completes in under 2 minutes. Implements feat-1-story-9."
- [ ] 9.3 User review: Capture multiple ideas quickly, verify low friction
- [ ] 9.4 Test listing and show functionality
- [ ] 9.5 Refine to ensure truly minimal questions (not too many)
- [ ] 9.6 Finalize: Verify integration with workflow (doesn't disrupt current work)

## Technical Notes

**Idea File Format:**
```markdown
# [Idea Title]

> **Captured:** YYYY-MM-DD
> **Category:** [feature|improvement|exploration]
> **Status:** [new|reviewing|planned|implemented|rejected]

## The Idea

[Quick description of the idea - what problem does it solve?]

## Why It Matters

[Brief context on value or impact]

## Possible Approach

[Optional: Initial thoughts on how to implement]

## Related Work

- [Links to related features, experiments, research]

## Notes

[Additional context or considerations]
```

**Quick Capture Flow:**
1. Ask: "What's the idea in one sentence?"
2. Ask: "What category? (feature/improvement/exploration)"
3. Optional: "Any quick context or why this matters?"
4. Generate file with timestamp
5. Done - back to work

**Listing Ideas:**
- `/idea list` - Show all ideas with status
- `/idea list new` - Show only new ideas
- `/idea show N` - Display specific idea

See [../feature.md](../feature.md) for overall feature context.

## Testing Strategy

**TDD Approach:**
- Write tests first (red)
- Implement to pass tests (green)
- Refactor (clean)

**Unit Tests:** 
- Idea file generation
- Category validation
- Numbering logic (idea-1, idea-2, etc.)

**Integration Tests:** 
- Complete capture workflow
- List ideas functionality
- Show specific idea

**Manual Testing:** 
- Capture idea in < 2 minutes
- List and review ideas
- Verify low friction (no unnecessary questions)

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Command works end-to-end (no stubs/mocks)
- [ ] All tests passing (unit + integration + end-to-end)
- [ ] No regressions in existing commands
- [ ] Code follows Junior's principles (simple, TDD, vertical slice)
- [ ] Documentation updated
- [ ] **User can capture ideas in under 2 minutes**
- [ ] Ideas can be listed and reviewed easily

