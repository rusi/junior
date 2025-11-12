# Story 1b: Add User Review Phase to /feature Command

> **Status:** Completed
> **Priority:** High
> **Dependencies:** Story 1
> **Deliverable:** /feature command includes user review/refinement phase before final consistency check

## User Story

**As a** developer planning features
**I want** to review and refine generated specs/stories before final lock
**So that** the final consistency review happens after all user feedback is incorporated

## Scope

**In Scope:**
- Add Step 7 "User Review & Refinement Phase" between generation (Step 6) and final review (Step 8)
- Allow user to request changes to stories, specs, or contract
- Update generated content based on user feedback
- Iterate until user confirms "ready for final review"
- Move current Step 8 final review to happen AFTER user says "ready"
- Track review iterations with todo_write

**Out of Scope:**
- Automated validation of user changes
- Version history of iterations (git handles this)
- Collaboration features (multiple reviewers)
- Templates for common refinement patterns

## Acceptance Criteria

- ✅ Given feature generation completes, when presenting package, then prompts user to review
- ✅ Given user requests changes, when feedback provided, then updates relevant stories/specs
- ✅ Given user makes multiple refinement rounds, when iterating, then tracks changes clearly
- ✅ Given user confirms "ready", when final review triggered, then performs consistency check
- ✅ Given final review finds issues, when reporting, then lists specific inconsistencies with suggestions
- ✅ Given final review passes, when complete, then marks feature "locked and ready for implementation"

## Implementation Tasks

- ✅ 1b.1 Research review phase patterns and user feedback workflows
- ✅ 1b.2 Add Step 7 "User Review & Refinement Phase" after Step 6 generation
- ✅ 1b.3 Implement refinement prompt showing review options (stories/specs/contract/ready)
- ✅ 1b.4 Implement story update logic based on user feedback
- ✅ 1b.5 Implement spec update logic based on user feedback
- ✅ 1b.6 Move current final review to Step 8, trigger only after user says "ready"
- ✅ 1b.7 Update todo tracking to include review iterations
- ✅ 1b.8 User review: Test workflow with multiple refinement rounds, refine based on feedback

## Technical Notes

**Step 7: User Review & Refinement Phase**

After generating feature package (Step 6), present for review:

```
✅ Feature specification created!

📁 .junior/features/feat-{N}-{name}/
├── 📋 feature.md
├── 👥 user-stories/
│   ├── 📊 README.md
│   ├── 📝 feat-{N}-story-1-{name}.md
│   ├── 📝 feat-{N}-story-2-{name}.md
│   └── 📝 feat-{N}-story-3-{name}.md
└── 📂 specs/
    └── 📄 01-Technical.md

**Stories:** 3 user stories with focused task groups
**Total Tasks:** 18 implementation tasks
**Approach:** TDD, end-to-end integrated, user-testable after each story

---

🔍 **Review Phase**

Please review the generated specification:
- Read feature.md for overall contract
- Review user stories for scope and tasks
- Check specs for technical approach

**Options:**
- **update story N** - Refine a specific story
- **update spec** - Modify technical specs
- **update contract** - Adjust feature contract (will regenerate stories)
- **ready** - Proceed to final consistency review

What would you like to do?
```

**Refinement Loop:**

Track review iterations:
```json
{
  "todos": [
    {"id": "user-review", "content": "User reviewing generated specification", "status": "in_progress"},
    {"id": "final-review", "content": "Final consistency review", "status": "pending"}
  ]
}
```

**Update Story Example:**
```
User: update story 2

Which aspect of Story 2 would you like to refine?
- Tasks (add/remove/modify implementation tasks)
- Scope (adjust what's in/out of scope)
- Acceptance criteria (change success conditions)
- Technical notes (update implementation approach)

User: tasks - add integration test task

[Update story file with new task]
[Recalculate task counts in README.md]

Updated Story 2 with additional task.
Current total: 19 tasks (was 18)

Continue reviewing? [update story N/update spec/ready]
```

**Move Current Step 8 → Triggered After "ready":**

Only when user says "ready", perform:
1. Contract consistency check
2. Story dependency validation
3. Cross-reference verification
4. TDD approach verification
5. Working output emphasis verification
6. Vertical slice validation

**Final Review Output (unchanged, just moved):**
```
🔍 Final Review Complete

✅ Contract consistency - All docs align with locked contract
✅ Story dependencies - Correct sequential order
✅ Cross-references - All links verified
✅ TDD approach - Test-first in all stories
✅ Working output - User-testable emphasized
✅ Vertical slices - No horizontal layering

Feature specification is ready for implementation!
```

See [../feature.md](../feature.md) for overall feature context.

## Workflow Strategy

**Research → Update → Review → Refine:**
1. Research existing review/feedback patterns in Junior
2. Update feature.md with Step 7 review phase
3. User review: Generate feature, test review loop with changes
4. Refine based on user experience

**Validation Testing:** 
- Generate complete feature
- Request story changes (verify update works)
- Request spec changes (verify update works)
- Iterate multiple times (verify loop continues)
- Confirm "ready" (verify final review triggers)
- Test with various change types (add tasks, change scope, update contract)

## Definition of Done

- ✅ All tasks completed
- ✅ All acceptance criteria met
- ✅ Command works end-to-end (no stubs/mocks)
- ✅ All tests passing (unit + integration + end-to-end)
- ✅ No regressions in existing feature command
- ✅ Code follows Junior's principles (simple, TDD, vertical slice)
- ✅ Documentation updated
- ✅ **User can review and refine specs before final lock**
- ✅ Final review only happens after user confirmation
- ✅ Multiple refinement rounds supported

