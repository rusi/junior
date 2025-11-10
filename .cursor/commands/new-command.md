# New Command

## Purpose

Create new Junior commands following established patterns and conventions.

## Type

Contract-style - Clarification loop, then contract approval, then generation

## When to Use

- Need to add a new command to Junior
- Want to extend Junior's capabilities
- Creating custom workflow command

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` with JSON list:

```json
{
  "todos": [
    {"id": "clarify-command", "content": "Clarify command purpose and requirements", "status": "in_progress"},
    {"id": "validate-fit", "content": "Validate command fits Junior ecosystem", "status": "pending"},
    {"id": "create-contract", "content": "Create command contract", "status": "pending"},
    {"id": "generate-command", "content": "Generate command file", "status": "pending"}
  ]
}
```

This creates structured progress tracking for the command creation process.

### Step 2: Clarification & Analysis

**Scan existing commands:**

Use `list_dir` to check existing commands in `.cursor/commands/`

**Ask clarifying questions (one at a time):**

- What specific workflow does this command solve?
- Should this be contract-style (clarification loop) or direct execution?
- What inputs does it need?
- What outputs does it create?
- Where should outputs be stored (`.junior/specs/`, `.junior/research/`, etc.)?
- What Cursor tools will it need?

**Critical analysis - Challenge if:**
- Command duplicates existing functionality
- Scope is too broad or unclear
- Complexity doesn't justify the value
- Doesn't fit Junior's principles

**Continue until 95% clear on requirements**

### Step 3: Present Command Contract

**When confident, present contract:**

```
## Command Contract

**Name:** [command-name]

**Purpose:** [One sentence what it does]

**Type:** [Contract-style OR Direct execution]

**Workflow:**
1. [Step one]
2. [Step two]
3. [Step three]

**Inputs:** [What user provides]

**Outputs:** [Files/folders created]

**Tools:** [Cursor tools needed]

**⚠️ Concerns (if any):**
- [Any implementation concerns]

**💡 Recommendations:**
- [Suggestions to improve]

---
Lock contract and create command? [yes/no/edit]
```

**Options:**
- **yes** - Create the command
- **no** - Cancel
- **edit** - Modify contract

### Step 4: Generate Command File

**Create command file structure:**

```markdown
# [Command Name]

## Purpose
[From contract]

## When to Use
[Scenarios]

## Process

### Step 1: Initialize Progress Tracking
[todo_write structure]

### Step 2: [Main workflow steps]
[From contract]

## Tool Integration
[Tools and commands]

## Examples
[Usage examples]
```

**Command types determine structure:**

**Contract-style commands** (plan, research):
- Phase 1: Clarification loop
- Phase 2: Contract proposal
- Phase 3: File generation after approval

**Direct execution commands** (commit, refactor):
- todo_write initialization
- Step-by-step execution
- User confirmation at key points

**Language & Shell Agnostic** - Use `codebase_search`, `list_dir`, `grep` rather than language-specific commands. No assumptions about tech stack.

### Step 5: Update Documentation

**Update README.md with new command:**

Add command to command list in README.md:
- Command name and brief description
- Add to usage examples if applicable

**Present documentation update:**

```
📝 Updated README.md with new command reference
```

### Step 6: Validate & Complete

**Validate command:**
- Follows Junior patterns
- Uses `.junior/` structure correctly
- Has clear tool integration
- Includes examples
- Language & shell agnostic

**Present result:**

```
✅ Command created successfully!

📁 .cursor/commands/[command-name].md
📝 README.md updated with command reference

🚀 Ready to use: /[command-name]

Test the command to verify it works as expected.
```

## Command Naming Rules

**Format:**
- Lowercase letters, numbers, hyphens only
- No spaces or special characters
- Maximum 20 characters
- Cannot start with number or hyphen
- Must not conflict with existing commands

**Examples:**
- ✅ `plan`, `research`, `refactor`
- ❌ `Plan`, `do_research`, `CreatePlan`

## Tool Integration

**Primary tools:**
- `todo_write` - Progress tracking
- `list_dir` - Scan existing commands
- `write` - Create command file
- `read_file` - Reference existing commands

**Cursor tools for generated commands:**
- `codebase_search` - Search codebase
- `run_terminal_cmd` - Execute commands
- `grep` - Search files
- `read_file` - Read files
- `search_replace` - Edit files
- `write` - Create files

## Examples

**Create research command:**
```
User: /new-command
Junior: What command would you like to create?
User: research command for technical investigation
Junior: [Asks clarifying questions...]
Junior: [Presents contract...]
User: yes
Junior: ✅ Command created at .cursor/commands/research.md
```

**Create plan command:**
```
User: /new-command
Junior: What command would you like to create?
User: plan command for feature planning
Junior: [Clarification loop...]
Junior: [Contract with recommendations...]
User: yes
Junior: ✅ Command created at .cursor/commands/plan.md
```

---

Build commands that follow Junior principles: simple, clear, purposeful.

