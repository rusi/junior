# Story 15: Create /help Command

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** New /help command for command discovery

## Developer Story

**As a** Junior user
**I want** a /help command
**So that** I can list all commands and understand what each does

## Current State

**What's wrong:**
- No way to list available commands
- Users can't remember command names
- No quick reference for command purposes
- Poor discoverability

## Target State

**What improved code looks like:**
- New command: `.cursor/commands/help.md`
- Command instructions (Mode A) - How to display help
- Help output (Mode C) - User-facing command list
- Categorized by purpose (Planning, Implementation, Project Management, Utilities)

## Scope

**In Scope:**
- Create new `/help` command file
- List all 9 commands with descriptions
- Categorize commands by purpose
- Include usage examples

**Out of Scope:**
- Interactive help (just static list)
- Command-specific help (separate consideration)
- Search functionality

## Acceptance Criteria

- [ ] Given help command, when created, then `.cursor/commands/help.md` exists
- [ ] Given help command, when executed, then displays all commands with descriptions
- [ ] Given output, when reviewed, then commands categorized appropriately
- [ ] Given output, when reviewed, then includes usage examples

## Implementation Tasks

- [ ] 15.1 Create `help.md` command file
- [ ] 15.2 Add command instructions (Mode A)
- [ ] 15.3 Define help output format (Mode C)
- [ ] 15.4 Categorize commands (Planning, Implementation, Project Management, Utilities)
- [ ] 15.5 Add all 9 commands with descriptions
- [ ] 15.6 Add usage examples
- [ ] 15.7 Test help command
- [ ] 15.8 User review

## Verification Checklist

- [ ] Help command file exists
- [ ] All 9 commands listed
- [ ] Descriptions clear and concise
- [ ] Categories make sense
- [ ] Usage examples provided
- [ ] Command tested
- [ ] User reviewed

## Technical Notes

**Help command structure (.cursor/commands/help.md):**

```markdown
# Help

## Purpose
Display list of all available Junior commands

## Type
Direct execution

## When to Use
- Need to see available commands
- Can't remember command name
- Want quick command reference

## Process

### Step 1: Display Help
Show categorized command list (Mode C output below).

## Help Output (Mode C)

🎯 Junior Commands

**Planning & Design:**
  /feature     - Create feature specification with stories
  /research    - Technical research and investigation

**Implementation:**
  /implement   - Execute stories with TDD workflow
  /refactor    - Code quality improvements
  /debug       - Systematic debugging investigation

**Project Management:**
  /status      - Complete project overview and next actions
  /commit      - Intelligent git commit with message generation
  /maintenance - Reorganize structure (Stage 1→2→3)
  /migrate     - Convert Code Captain projects to Junior

**Utilities:**
  /new-command - Create new Junior commands
  /help        - Show this help

Usage: Type /[command-name] to run a command
Example: /feature to create a new feature specification

## Tool Integration
None (just displays help text)

## Best Practices
- Use /help when unsure which command to use
- Commands are categorized by purpose for easier discovery
```

**Mode A vs Mode C:**
- Command instructions = Mode A (how AI displays help)
- Help output = Mode C (full user-facing list)

## Definition of Done

- [ ] All tasks completed
- [ ] Help command created
- [ ] All 9 commands listed with descriptions
- [ ] Commands categorized
- [ ] Usage examples included
- [ ] Command tested
- [ ] User reviewed
- [ ] **/help command works**

