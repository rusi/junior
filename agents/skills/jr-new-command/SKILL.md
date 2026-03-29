---
name: jr-new-command
description: Create new Junior skills/commands using established structure, clarification, and contract approval before generation.
---

# New Command

## Purpose

Create new Junior commands following established patterns and conventions.

## Scope Guard (Non-Negotiable)

- Create and update command skills only inside this repository under `agents/skills/`.
- Update rule files only inside this repository under `agents/rules/`.
- Never read from or write to global skill/rule locations (for example `~/.codex/skills/` or `~/.codex/rules/`) when creating or editing commands for this project.

## Type

Contract-style - Clarification loop, then contract approval, then generation

## When to Use

- Need to add a new command to Junior
- Want to extend Junior's capabilities
- Creating custom workflow command

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan` with JSON list:

```json
{
  "todos": [
    {"id": "clarify-command", "content": "Clarify command purpose and requirements", "status": "in_progress"},
    {"id": "validate-fit", "content": "Validate command fits Junior ecosystem", "status": "pending"},
    {"id": "create-contract", "content": "Create command contract", "status": "pending"},
    {"id": "generate-command", "content": "Generate skill file", "status": "pending"}
  ]
}
```

This creates structured progress tracking for the command creation process.

### Step 2: Clarification & Analysis

**Scan existing commands:**

Use `list_dir` or `functions.shell_command` to check existing commands in `agents/skills/`

**Ask clarifying questions (one at a time):**

- What specific workflow does this command solve?
- Should this be contract-style (clarification loop) or direct execution?
- What inputs does it need?
- What outputs does it create?
- Where should outputs be stored (`.junior/specs/`, `.junior/research/`, etc.)?
- What agent tools will it need?

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

**Tools:** [agent tools needed]

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

### Step 4: Documentation Mode & Leak Prevention

**CRITICAL: Commands are Mode A documentation (Junior → Junior)**

Commands are written FOR Junior (the AI), not for end users. This means:

**Mode A Principles:**
- ✅ High-level workflow steps (what to do)
- ✅ Tool names to use (codebase_search, grep, etc.)
- ✅ Decision points (when to ask user)
- ✅ Generic examples (feat-N-name, user-X, etc.)
- ❌ Detailed implementation (grep patterns, regex)
- ❌ Language-specific syntax (unless command is language-specific)
- ❌ Project-specific references (file names, class names, domain terms)

**ZERO TOLERANCE for Project Leakage:**

Before writing command, verify:
- [ ] No project-specific file/module/class names in examples
- [ ] No domain-specific business terms
- [ ] Examples use generic placeholders only
- [ ] Command works for ANY project type (web/CLI/embedded/mobile)
- [ ] High-level instructions only - Junior knows how to implement

**Test:** "Would this command work in a completely different codebase tomorrow?"

### Step 5: Generate Command File

**Create skill file structure (Mode A - high-level only):**

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

**Language & Shell Agnostic** - Use `codebase_search` or `functions.shell_command`, `list_dir` or `functions.shell_command`, `grep` (via `functions.shell_command`) rather than language-specific commands. No assumptions about tech stack.

**Keep it high-level** - Junior knows how to use tools. Focus on WHAT to do, not detailed HOW.

**Write location (required):**
- Create the new command at `agents/skills/jr-[command-name]/SKILL.md`
- Do not create commands in global directories

### Step 6: Update Documentation

**Update project-root `README.md` with new command:**

Add command to the "Available Commands" section in `README.md`:
- Command name and brief description
- Maintain alphabetical or logical grouping
- Keep description concise (one line)

**This is the single source of truth for command list.**

If command section is missing in `README.md`:
- Create a clear "Available Commands" section first
- Then add the new command entry there

**Present documentation update:**

```
📝 Updated README.md with new command reference
```

### Step 6.1: Command Propagation Checklist (Required)

After creating a new command skill, update all command-discovery surfaces in the same change:
- `README.md` "Available Commands" section
- `scripts/install-config.json` -> `messages.availableCommands`

Do not mark command creation complete until both files are updated.

### Step 7: Verify Project Leakage

**Scan skill file for project-specific content**

Check the generated skill file for:
- Project-specific file/module/class names
- Domain-specific business terms
- Specific feature names beyond generic patterns
- Project-specific file structures

**If leaks found:**
- Remove project-specific terminology
- Replace with generic placeholders
- Use abstract examples (feat-N, feature X, etc.)

**Allowed generic terms:**
- ✅ "feature", "story", "task", "bug", "improvement"
- ✅ "feat-N-name", "feat-1-overview.md"
- ✅ "user", "system", "product", "workflow"
- ✅ Abstract patterns (validation, processing, configuration)

### Step 8: Validate & Complete

**Validate command:**
- Follows Junior patterns
- Uses `.junior/` structure correctly (if applicable)
- Clear tool integration (high-level, not detailed patterns)
- Generic examples (no project leakage)
- Language & shell agnostic
- **Mode A appropriate** - triggers and workflow, not implementation manual
- **ZERO project-specific references** (verified in Step 7)

**Present result:**

```
✅ Command created successfully!

📁 agents/skills/jr-[command-name]/SKILL.md
📝 README.md updated (single source of truth for command list)
📝 scripts/install-config.json updated (installer command list)
✅ Project leakage check: CLEAN
✅ Mode A documentation: HIGH-LEVEL

🚀 Ready to use: /[command-name]

Note: Commands are managed locally in this repository under agents/skills/
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
- `todo_write` or `functions.update_plan` - Progress tracking
- `list_dir` or `functions.shell_command` - Scan existing commands
- `write` or `functions.apply_patch` - Create skill file
- `read_file` or `functions.shell_command` - Reference existing commands

**agent tools for generated commands:**
- `codebase_search` or `functions.shell_command` - Search codebase
- `run_terminal_cmd` or `functions.shell_command` - Execute commands
- `grep` (via `functions.shell_command`) - Search files
- `read_file` or `functions.shell_command` - Read files
- `search_replace` or `functions.apply_patch` - Edit files
- `write` or `functions.apply_patch` - Create files

## Examples

**Create deployment command:**
```
User: /jr-new-command
Junior: What command would you like to create?
User: deploy command for production deployment
Junior: [Asks clarifying questions...]
Junior: What deployment steps are needed?
User: Build, run tests, push to registry, deploy to k8s
Junior: [Presents contract...]
User: yes
Junior: ✅ Command created at agents/skills/jr-deploy/SKILL.md
```

**Create database migration command:**
```
User: /jr-new-command
Junior: What command would you like to create?
User: migrate command to handle database migrations
Junior: [Clarification loop...]
Junior: Should this handle both up and down migrations?
User: Yes, and show migration status
Junior: [Contract with recommendations...]
User: yes
Junior: ✅ Subcommand contract created for /jr migrate and saved to agents/skills/jr/references/subcommands/migrate.md
```

---

Build commands that follow Junior principles: simple, clear, purposeful.
