# Story 6: Create Command Structure Template

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None (but Phase 1 recommended to complete first)
> **Deliverable:** Standard command template defined

## Developer Story

**As a** maintainer of Junior commands
**I want** a standard command structure template
**So that** all commands follow consistent format and sections

**Note:** This template could be integrated with `/new-command` command as the standard format for new commands.

## Current State

**What's wrong with current code:**
- Commands have inconsistent structure:
  - `/status`: 7 numbered steps
  - `/debug`: 6 numbered steps, different section order
  - `/implement`: Mixes numbered steps with subsections
  - `/migrate`: 15 steps (too granular?)
- No standard for section order or naming
- Hard to learn command patterns
- Hard to maintain consistency

**Examples:**

Different structures:
```
Command A:
## Purpose
## When to Use
## Process (Steps 1-7)
## Examples

Command B:
## Overview
## Workflow (Steps 1-6)
## Best Practices

Command C:
## Description
## Process (mixed steps and subsections)
## Tool Integration
```

## Target State

**What improved code looks like:**
- Single template: `.cursor/commands/_shared/command-template.md` (Mode A)
- Standard sections for ALL commands:
  1. Purpose (one sentence)
  2. Type (contract-style | direct execution | adaptive)
  3. When to Use (scenarios)
  4. Process (numbered steps)
  5. Tool Integration (tools used)
  6. Error Handling (common errors)
  7. Best Practices (key reminders)
- Consistent structure across all 9 commands

**Shared module structure:**
- Template definition (Mode A)
- Section descriptions
- Formatting guidelines
- Example structure

## Scope

**In Scope:**
- Create `.cursor/commands/_shared/command-template.md` (Mode A)
- Define standard sections and order
- Document formatting guidelines
- Provide example structure

**Out of Scope:**
- Applying template to commands (that's Story 7)
- Command-specific variations (documented in template)
- Changing command content (just structure)

## Acceptance Criteria

- [ ] Given command template, when created, then `.cursor/commands/_shared/command-template.md` exists
- [ ] Given template, when reviewed, then all 7 standard sections defined
- [ ] Given template, when reviewed, then formatting guidelines clear
- [ ] Given template, when reviewed, then example structure provided

## Implementation Tasks

- [ ] 6.1 Create `command-template.md` (Mode A)
- [ ] 6.2 Define 7 standard sections
- [ ] 6.3 Document section purposes
- [ ] 6.4 Add formatting guidelines
- [ ] 6.5 Provide example structure
- [ ] 6.6 Document allowed variations
- [ ] 6.7 User review of template

## Verification Checklist

**Before marking story complete, verify:**
- [ ] Template file exists: `.cursor/commands/_shared/command-template.md`
- [ ] Template is Mode A (AI instructions)
- [ ] All 7 sections defined clearly
- [ ] Formatting guidelines present
- [ ] Example structure provided
- [ ] User has reviewed and approved template

## Regression Prevention

**Strategy:**
- Define template without applying (separate concern)
- Review template structure before application
- Ensure template fits all command types

**Validation:**
- Manual review: Template sections make sense
- Completeness check: All needed sections included
- Example check: Example structure clear

## Rollback Plan

**If issues arise:**
1. Revert commit
2. Refine template based on feedback
3. Re-create with improvements

**Rollback criteria:**
- Template missing critical sections
- Structure doesn't fit all commands
- Guidelines unclear

## Technical Notes

**Template structure (.cursor/commands/_shared/command-template.md):**

```markdown
# Command Template (AI Internal - Mode A)

## Purpose
Define standard structure for all Junior commands.

## Standard Sections (in order)

### 1. Purpose
[One sentence describing command]

### 2. Type
[Contract-style | Direct execution | Adaptive]

### 3. When to Use
- [Scenario 1]
- [Scenario 2]
[NOT for: counter-scenarios]

### 4. Process
Numbered steps (Step 1, Step 2, etc.)
Each step is major phase
Substeps allowed for clarity

### 5. Tool Integration
Tools used with examples
Workflow integration patterns

### 6. Error Handling
Common errors and responses
Recovery patterns

### 7. Best Practices
Key reminders and principles

## Formatting Guidelines
- Use ## for main sections
- Use ### for steps (Step 1, Step 2)
- Use #### for substeps if needed
- Consistent heading levels

## Example Structure
[Full example showing all sections]

## Allowed Variations
- Commands may add custom sections AFTER standard sections
- Commands may omit sections if truly not applicable (rare)
- Step count varies by command complexity

## Usage
"Follow command template from `_shared/command-template.md`"
```

**Next Story:**
Story 7 will apply this template to all 9 commands.

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Template file created (Mode A)
- [ ] All 7 sections defined
- [ ] Formatting guidelines present
- [ ] Example structure provided
- [ ] User reviewed and approved
- [ ] **Standard command template defined**

