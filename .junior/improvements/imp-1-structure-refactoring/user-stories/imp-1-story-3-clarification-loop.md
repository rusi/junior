# Story 3: Extract Clarification Loop Pattern

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Clarification loop pattern DRY'd across 4 commands

## Developer Story

**As a** maintainer of Junior commands
**I want** clarification loop patterns extracted to a shared module
**So that** question patterns and 95% clarity threshold are consistent across all commands

## 🔴 CRITICAL: ONE QUESTION AT A TIME

**This is the MOST IMPORTANT rule of clarification:**
- Ask ONE question at a time
- NOT 2 questions
- NOT 3 questions
- ONE FOCUSED QUESTION
- Wait for answer
- Then ask next question

**This must be emphasized explicitly in the shared module.**

## Current State

**What's wrong with current code:**
- Clarification patterns duplicated in `feature.md`, `debug.md`, `refactor.md`, `new-command.md`
- Same pattern: Ask focused questions, one at a time, continue until 95% clear
- Question templates and clarity guidance repeated
- If pattern changes (e.g., add confidence threshold), must update 4 files
- DRY violation: ~40 lines repeated 4 times

**Examples:**

In multiple commands:
```markdown
Ask ONE focused question at a time
Continue until 95% clarity
Each question targets highest-impact unknown
Present options when possible
```

## Target State

**What improved code looks like:**
- Single source of truth: `.cursor/commands/_shared/clarification-loop.md` (Mode A + Mode C)
- Commands reference: "Use clarification loop from `_shared/clarification-loop.md`"
- Standard question patterns (Mode C - user-facing)
- Clarity threshold guidance (Mode A - AI instructions)
- ~160 lines reduced to ~40 lines + 4 references

**Shared module structure:**
- Clarification process (Mode A - how to clarify)
- Question patterns (Mode C - question templates shown to user)
- 95% clarity threshold (Mode A - when to stop)
- Option presentation format (Mode C - how to show choices)

## Scope

**In Scope:**
- Create `.cursor/commands/_shared/clarification-loop.md`
- Extract clarification patterns (Mode A + Mode C mix)
- Update 4 commands to reference shared module:
  - `feature.md` - feature-specific clarification
  - `debug.md` - debug-specific clarification
  - `refactor.md` - refactor-specific clarification
  - `new-command.md` - command design clarification
- Grep verification: old pattern removed

**Out of Scope:**
- Changing clarification logic itself (just extracting)
- Command-specific clarification topics (stays in commands)
- Guardian routing (separate pattern)

## Acceptance Criteria

- [ ] Given clarification loop pattern, when extracted to shared module, then `.cursor/commands/_shared/clarification-loop.md` exists
- [ ] Given 4 commands, when updated, then they reference shared module for clarification process
- [ ] Given commands, when updated, then command-specific questions remain (only pattern extracted)
- [ ] Given old clarification pattern, when grep search performed, then 0 results found (only in shared module)

## Implementation Tasks

- [ ] 3.1 Create `clarification-loop.md` with patterns (Mode A + Mode C)
- [ ] 3.2 Update `feature.md` - replace pattern with reference (keep feature-specific questions)
- [ ] 3.3 Update `debug.md` - replace pattern with reference (keep debug-specific questions)
- [ ] 3.4 Update `refactor.md` - replace pattern with reference (keep refactor-specific questions)
- [ ] 3.5 Update `new-command.md` - replace pattern with reference (keep command-specific questions)
- [ ] 3.6 Grep verification: Pattern gone (questions remain)
- [ ] 3.7 User review of changes

## Verification Checklist

**Before marking story complete, verify:**
- [ ] Shared module exists: `.cursor/commands/_shared/clarification-loop.md`
- [ ] Module mixes Mode A (process) and Mode C (questions)
- [ ] 4 commands updated with references
- [ ] Command-specific questions still in commands (only pattern extracted)
- [ ] Grep check passes (pattern removed, not questions)
- [ ] User has reviewed and approved changes

## Regression Prevention

**Strategy:**
- Extract process pattern (how to clarify)
- Leave command-specific questions in commands
- Standard question templates in shared module

**Validation:**
- Manual review: Pattern vs command-specific content separated
- Grep verification: "95% clarity" only in shared module
- Commands check: Still contain their specific question lists

## Rollback Plan

**If issues arise:**
1. Revert commit
2. Commands return to inline clarification patterns
3. Module can be refined and re-extracted

**Rollback criteria:**
- Pattern/content separation incorrect
- Commands lose important clarification guidance
- References don't work

## Technical Notes

**Shared module structure (.cursor/commands/_shared/clarification-loop.md):**

```markdown
# Clarification Loop (AI Internal - Mode A + User Questions Mode C)

## Process (Mode A)
Ask ONE focused question at a time
Continue until 95% clear
Each question targets highest-impact unknown

## Question Patterns (Mode C - Templates)
[Standard question formats shown to user]
- What is X?
- Why is X needed?
- What scope: [option A | option B | option C]?

## Clarity Threshold (Mode A)
95% clarity required before proceeding
If uncertain, ask follow-up question
Never proceed with <95% understanding

## Option Presentation (Mode C)
[Format for showing options to user]
**Options:** yes | no | edit: [changes]

## Usage in Commands
"Use clarification loop from `_shared/clarification-loop.md`"
[Then list command-specific questions]
```

**Reference pattern in commands:**
```markdown
### Step X: Clarification

Use clarification loop from `_shared/clarification-loop.md`.

**Command-specific questions:**
- [Feature/Debug/Refactor-specific questions remain here]
- [Context-dependent questions remain here]
```

**Mode A vs Mode C:**
- Process guidance = Mode A (AI instructions)
- Question templates = Mode C (user-facing)
- Command-specific questions = Mode C (stay in commands)

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Shared module created (Mode A process + Mode C templates)
- [ ] 4 commands updated with references
- [ ] Command-specific questions still in commands
- [ ] Old pattern removed (grep verified)
- [ ] User reviewed and approved changes
- [ ] Zero functional changes
- [ ] **Clarification loop DRY'd across 4 commands**

