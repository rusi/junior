# Story 12: Implement /update-feature Command

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** Story 1 (needs /feature patterns and structure)
> **Deliverable:** Fully working /update-feature command for modifying existing features

## User Story

**As a** developer working with Junior
**I want** to update existing feature specifications
**So that** I can add stories, reorder tasks, update scope, or refine requirements without manual file editing

## Scope

**In Scope:**
- Add new stories to existing feature (with automatic numbering like 2b, 3a, etc.)
- Reorder/reorganize stories without breaking references
- Update feature contract (scope, requirements, success criteria)
- Update story details (tasks, acceptance criteria, technical notes)
- Maintain consistency across all feature files
- Update cross-references automatically
- Support contract-first workflow (clarification → preview → approval)

**Out of Scope:**
- Deleting stories (use manual file deletion for now)
- Merging features
- Feature versioning/history
- Automated refactoring of implementation code
- Story splitting (use /split-story in future)

## Acceptance Criteria

- [ ] Given feature name, when adding story, then inserts at specified position with appropriate numbering (2b, 3a, etc.)
- [ ] Given story reordering, when executed, then updates all cross-references correctly
- [ ] Given contract update, when approved, then propagates changes to all relevant files
- [ ] Given story update, when saved, then maintains consistency with feature contract
- [ ] Given update operation, when completed, then all links still work
- [ ] Given multiple updates, when executed, then tracks changes and shows summary

## Implementation Tasks

- [ ] 12.1 Research `reference-impl/cursor/commands/update-story.md` for feature modification patterns
- [ ] 12.2 Run `/new-command` with prompt: "Create update-feature command for modifying existing features. Contract-first workflow: clarify what to update (add-story, reorder, update-contract, update-story) → show preview → get approval → execute with consistency checks. Add story operation: insert at position with alphabetic sub-numbering (2b, 3a). Reorder stories: update table, links, dependencies. Update contract/story: modify files, verify consistency. Includes automatic cross-reference updates and consistency checker. Implements feat-1-story-12."

## Technical Notes

**Command Structure:**

```markdown
# Update Feature

## Purpose
Modify existing feature specifications while maintaining consistency

## Type
Contract-style (clarification → preview → approval → execution)

## Process

### Step 1: Verify Git State
Must have clean working directory

### Step 2: Select Feature & Operation
- List existing features
- User selects feature to update
- User selects operation: add-story | reorder | update-contract | update-story

### Step 3: Gather Update Details
Based on operation:
- **add-story:** Position (after story N), title, scope, tasks
- **reorder:** New order (e.g., "move story 12 to 2b")
- **update-contract:** What to change (scope, requirements, constraints)
- **update-story:** Which story, what to change

### Step 4: Show Preview
Display what will change:
- Files to be modified
- New content preview
- Reference updates needed

### Step 5: Execute with Approval
User approves → Execute updates → Run consistency check → Show summary

### Step 6: Consistency Check
- Verify all links work
- Verify story numbers in table match files
- Verify dependencies still make sense
- Report any issues found
```

**Update Operations:**

**1. Add Story (with alphabetic sub-numbering):**
```
Current: Story 2, Story 3, Story 4
User: "Add installation script after Story 2"
Result: Story 2, Story 2b (new), Story 3, Story 4
- Create feat-1-story-2b-{name}.md
- Update feat-1-stories.md table
- Insert link in Quick Links section
- Update dependencies if needed
```

**2. Reorder Stories:**
```
Current: Story 2, Story 12 (installation), Story 3
User: "Move Story 12 to Story 2b"
Result: Story 2, Story 2b (was 12), Story 3, Story 12 (new or delete)
- Rename file or update content
- Update table and links
- Update dependencies
```

**3. Update Contract:**
```
User: "Add /update-feature to included scope"
- Modify feature.md ✅ Included section
- Verify stories still align with contract
- Update story count if adding new stories
```

**4. Update Story:**
```
User: "Change Story 3 priority to High"
- Modify feat-1-story-3-{name}.md metadata
- Update table if progress/status changed
- Maintain consistency with feature.md
```

**Consistency Checks:**
- All story file names match table entries
- All Quick Links point to existing files
- All dependencies reference valid stories
- Total task count matches sum of story tasks
- Feature contract aligns with story scopes

See [../feature.md](../feature.md) for overall feature context.

## Testing Strategy

**TDD Approach:**
- Write tests first (define expected updates)
- Implement update operations
- Verify consistency after each operation

**Unit Tests:**
- Story numbering logic (2 → 2b → 2c, etc.)
- File renaming operations
- Cross-reference updates
- Consistency checking logic

**Integration Tests:**
- Complete add-story workflow
- Complete reorder workflow
- Complete contract update workflow
- Verify all files remain valid after updates

**Manual Testing:**
- Update feat-1-core-commands (add story, reorder, update contract)
- Verify all links work after updates
- Test with feature that has many stories (10+)
- Test with feature that has complex dependencies

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] All update operations work end-to-end
- [ ] All tests passing (unit + integration + manual)
- [ ] Consistency checker catches broken references
- [ ] Code follows Junior's principles (simple, contract-first, vertical slice)
- [ ] Documentation complete in command file
- [ ] **User can update features without manual file editing**
- [ ] Command tested on feat-1-core-commands successfully

