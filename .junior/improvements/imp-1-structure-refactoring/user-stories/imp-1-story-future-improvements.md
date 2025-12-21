# Future Improvements

> **Type:** Backlog / Documentation
> **Priority:** Low
> **Status:** For Future Consideration

## Purpose

This document captures out-of-scope improvements identified during assessment but deferred to maintain focus on critical and moderate issues. These items should be reviewed and potentially implemented in future iterations.

**Note:** This is a backlog document, NOT a numbered story. It does not interfere with adding new numbered stories to this improvement.

## Future Enhancement Opportunities

### 1. Quick Reference Cards

**Opportunity:** Create one-page guides for common patterns

**Proposal:**
```
.cursor/quick-reference/
├── stage-transitions.md          # When to transition Stage 1→2→3
├── command-decision-tree.md      # Which command to use when
├── vertical-slice-checklist.md   # How to ensure stories are vertical
└── evidence-based-debugging.md   # Evidence gathering patterns
```

**Benefit:**
- Fast reference for common decisions
- Reduces cognitive load
- Helps maintain consistency

**Effort:** Medium (4-6 stories to create all reference cards)

**Priority:** Medium

**Why deferred:** Not critical to fixing the 8 identified issues. Can be added once foundation is solid.

---

### 2. Command Execution Metrics

**Opportunity:** Add expected execution time estimates

**Example:**
```markdown
## Performance Targets
- Step 1 (Initialize): ~2 seconds
- Step 2 (Scan): ~5-10 seconds
- Step 3 (Clarification): User-dependent (5-15 minutes typical)
- Step 4 (Generation): ~30-60 seconds
- **Total**: 6-20 minutes typical
```

**Benefit:**
- Helps users know if something is stuck
- Sets expectations for command duration
- Easier to identify performance issues

**Effort:** Low (1-2 stories to add metrics to all commands)

**Priority:** Low

**Why deferred:** Nice to have but not essential. Commands work without metrics.

---

### 3. Error Recovery Patterns

**Opportunity:** Add recovery workflows to all commands

**Proposal:**
```markdown
## Error Recovery

### If command fails mid-execution:
1. Check which TODO is marked `in_progress`
2. Resume from that step
3. Skip completed steps

### If generated files are corrupted:
1. Delete partial files
2. Re-run command from Step 1
3. Review TODOs to see progress

### If need to cancel:
1. Say "cancel" or "stop"
2. Files remain in current state
3. Use git to revert if needed
```

**Benefit:**
- Easier to recover from failures
- Clear guidance for partial completions
- Better user experience with errors

**Effort:** Medium (2-3 stories to add to all commands and test)

**Priority:** Medium

**Why deferred:** Commands currently work. Error recovery is enhancement, not fix.

---

### 4. Command Decision Tree

**Opportunity:** Visual guide for which command to use

**Proposal:** Interactive or static decision tree answering:
- Want to add functionality? → `/feature`
- Want to improve existing code? → `/refactor`
- Something broken? → `/debug`
- Need research? → `/research`
- Execute stories? → `/implement`
- etc.

**Benefit:**
- Reduces confusion about command selection
- Faster onboarding for new users
- Self-service guidance

**Effort:** Low-Medium (1-2 stories)

**Priority:** Medium

**Why deferred:** `/help` command covers basic discovery. Decision tree is enhancement.

---

### 5. Vertical Slice Checklist

**Opportunity:** Checklist to verify stories are truly vertical

**Proposal:**
```markdown
Vertical Slice Checklist:
- [ ] Story delivers end-to-end value
- [ ] System works after story complete
- [ ] No "horizontal" layers (not "all models" or "all views")
- [ ] Foundation + functionality + tests + docs included
- [ ] Independently deployable/testable
```

**Benefit:**
- Ensures story quality
- Catches horizontal slicing early
- Better iteration planning

**Effort:** Low (1 story to create checklist)

**Priority:** Low

**Why deferred:** Stories in this improvement are vertical by design. Checklist is nice to have for future work.

---

### 6. Evidence-Based Debugging Quick Guide

**Opportunity:** Extract debugging patterns from `13-software-implementation-principles.mdc`

**Proposal:** Quick reference card for debugging process:
- Observe → Measure → Hypothesize → Test → Verify → Fix → Confirm
- Evidence sources checklist
- Anti-patterns to avoid
- "Works elsewhere" protocol

**Benefit:**
- Faster debugging
- Consistent process
- Fewer speculation-based fixes

**Effort:** Low (1 story to extract and format)

**Priority:** Medium

**Why deferred:** Principle already documented in rule. Quick guide is convenience, not necessity.

---

## Related Work

**Completed in this improvement:**
- Shared command modules (DRY enforcement)
- Command structure standardization
- Long command modularization
- Rule cross-references
- Validation checklists
- Help system

**Future improvements complement these foundations:**
- Quick references build on standardized structure
- Metrics build on consistent commands
- Error recovery builds on standard patterns
- Decision trees build on help system

## Notes

**When to implement:**
- After improvement 1 complete and Junior tested on real projects
- Based on user feedback about what's most valuable
- Prioritize based on pain points encountered in practice

**How to implement:**
- Create new numbered stories (Story 18+) for selected items
- Each item can be its own story or combined if related
- Follow same vertical slice approach

**Don't forget:**
- Keep Mode A (AI instructions) concise
- Test thoroughly after each addition
- User review before finalizing

## How to Use This Document

When ready to implement items from this backlog:
1. Review and prioritize items based on actual needs
2. Create new numbered stories (e.g., Story 18, Story 19) for selected items
3. Follow normal story workflow (contract → approval → implementation)
4. User reviews and refines each addition

**File sorts last:** This file uses `story-future` naming so it appears after all numbered stories in directory listings.

