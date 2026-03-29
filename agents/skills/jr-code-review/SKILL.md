---
name: jr-code-review
description: Run comprehensive expert code review on current branch changes and fix findings across debug/dead code, rule violations, correctness risks, and explicit architecture/design/structure/DRY reporting.
---

# Code Review

## Purpose

Comprehensive expert-level code review of all changes in current branch. Detect and fix issues across 4 execution categories:
- Debug code (always safe to remove)
- Dead code (safe to remove)
- Rule violations (mechanical fixes)
- Correctness (architectural, logical, security, resource management - expert review)

Mandatory report must also include explicit cross-cutting checks/counts for:
- Architectural violations
- Design pattern violations
- Structure/layering violations
- DRY violations

Junior acts as expert code reviewer ensuring production-ready, architecturally sound, bug-free code.

## When to Use

- **Before creating a pull request** - Catch issues before review
- **After completing a feature branch** - Ensure production quality
- **When cleaning up development code** - Remove debug artifacts and dead code
- **Periodic code quality checks** - Architectural review and refactoring opportunities
- **Before merging to main** - Final comprehensive review

This is expert-level code review covering:
- Architecture and design patterns
- Logical correctness and algorithms
- Type safety and resource management
- Security and thread safety
- Maintainability and separation of concerns
- NOT just linting (comprehensive expert review)

## Usage

```
/jr-code-review [base-branch]
```

**Parameters:**
- `base-branch` (optional): Branch to compare against (e.g., `main`, `develop`, `origin/main`)
  - If not provided and local git changes exist, review local changes directly
  - If not provided and no local git changes exist, ask user for base branch

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan`:

```json
{
  "todos": [
    {"id": "find-changes", "content": "Find branch changes", "status": "in_progress"},
    {"id": "scan-issues", "content": "Scan for issues in 4 categories", "status": "pending"},
    {"id": "review-debug", "content": "Review debug code", "status": "pending"},
    {"id": "review-dead", "content": "Review dead code", "status": "pending"},
    {"id": "review-rules", "content": "Review rule violations", "status": "pending"},
    {"id": "review-correctness", "content": "Review correctness issues", "status": "pending"}
  ]
}
```

### Step 2: Find Branch Changes

**Determine review target:**
- If `base-branch` is provided, use branch-diff mode
- If `base-branch` is not provided:
  1. Check for local changes:
     ```bash
     git status --porcelain
     ```
  2. If local changes exist, use local-change mode (do NOT ask for base branch)
  3. If no local changes exist, ask user: "What branch should I compare against? (e.g., main, develop, origin/develop)"

**Branch-diff mode (when base branch is known):**

```bash
git merge-base <base-branch> HEAD
```

**Get actual changes (diffs):**

```bash
git diff <merge-base>..HEAD
```

**Local-change mode (when no base branch and working tree is dirty):**

```bash
git diff --cached
git diff
git ls-files --others --exclude-standard
```

- Review staged and unstaged diffs as the primary review target.
- Include untracked files by reading their current contents and reviewing them as new files.
- If changes map to a `.junior/.../feat-N-story-M*.md` scope, load `../_shared/references/session-artifact-log.md` and maintain that story's `## Session Artifact Log` for this review pass.

**Focus on changed lines, not entire files:**
- Review only what changed (added, modified, deleted lines)
- Include surrounding context for understanding
- Filter to relevant files (source code only, exclude generated files)

### Step 3: Scan for Issues

Scan the **changes** (diffs) for issues in 4 categories:

**Focus on changed lines only** - Don't review entire files, only what was added/modified in this PR.
**Non-negotiable in every run (including local-change mode):**
- DRY violations must always be checked and fixed.
- Security issues must always be checked and fixed.
- Architectural and maintainability violations must always be checked and fixed.

**1. Debug Code** (Always Safe to Remove)
- Print statements, console.log
- Debug flags (`DEBUG = True`)
- Verbose logging in production code (initialization messages, "Created X", "Subscribed to Y", debug prefixes with brackets/component names)
- Temporary test code
- Pattern: Find debug artifacts
  - Search: `print\(`, `console\.log`, `logging\.(info|debug)\([^)]*"(Created|Subscribed|Initialized|NEW|DEBUG|\[)`
  - Look for logging.info/jr-debug with debug-style messages (brackets, initialization status, component names)

**2. Dead Code** (Safe to Remove)
- Unused imports (`read_lints`)
- Commented-out code blocks
- Unreachable code after return
- Unused variables/functions
- TODO/FIXME comments
- Pattern: Find unused/commented code

**3. Rule Violations** (Mostly Mechanical)
- Linter violations (`read_lints`)
- Import style violations (per local/project rules)
- DRY violations (repeated code - extract immediately)
- Missing type hints
- Missing docstrings
- Code style issues
- Pattern: Check against local project standards

**4. Correctness Issues** (Expert Review - Comprehensive)

**Architectural & Design:**
- Missing design patterns (Context Manager, Strategy, Factory, Template Method)
- Manual setup/cleanup pairs (should be RAII/Context Manager)
- If/else chains on type/mode (should be Strategy pattern)
- Repeated code patterns (DRY violations - extract immediately)
- Tight coupling (dependencies that shouldn't exist)
- God classes/functions (doing too much)
- Layering violations (wrong concern in wrong layer)
  - Route/API handlers performing DB access directly (raw SQL, ORM queries, repository logic)
  - Route/API handlers performing business orchestration, aggregation, or response shaping beyond transport concerns
  - Framework/web-layer details leaking into domain/service layer
  - Data-access calls bypassing service/repository boundaries
- **Encapsulation violations:** Accessing private attributes (obj._private_var) - should use public API/methods
  - Pattern: Search for `\._[a-z]` (underscore-prefixed attributes)
  - Fix: Add public property/method or refactor to avoid need

**Maintainability & Evolvability:**
- Handlers/functions with mixed responsibilities (validation + business logic + persistence + response assembly in one place)
- Repeated transformation/aggregation code that should be centralized
- Poorly located logic that makes testing harder (requires HTTP layer to test domain behavior)
- Inconsistent data access style within same subsystem (raw SQL mixed with ORM/select without clear rationale)
- High-churn areas lacking clear seams (service/repository interfaces) for safe change

**Logical Flaws:**
- Wrong algorithms (incorrect implementation)
- Off-by-one errors (array bounds, loop conditions)
- Out of bounds errors (array access, buffer overrun)
- Incorrect logic flow (wrong order of operations)
- Wrong operators (`<` instead of `<=`, `and` instead of `or`)
- Assignment vs comparison (`=` vs `==`)
- Always true/false conditions (dead branches)
- Unreachable code (after return, in impossible branches)

**Type Issues:**
- Type mismatches (`read_lints`)
- Missing type hints (should have explicit types)
- Wrong return types (function returns wrong type)
- Type errors in complex expressions

**Resource Management:**
- Unclosed files/connections/streams
- Missing cleanup in error paths
- Memory leaks (unclosed resources, circular references)
- Transaction/lock management issues (acquire without release)

**Concurrency Issues:**
- Race conditions (shared state without synchronization)
- Deadlock potential (lock ordering issues)
- Missing thread safety (mutable shared state)
- Async/await misuse

**Error Handling:** (NOT Defensive - Fail Fast)
- Silent failures (catching without action)
- Swallowing exceptions (logging instead of handling/propagating)
- Wrong exception types (catching wrong errors, throwing wrong types)
- Missing fail-fast checks at boundaries (validate inputs at entry points)
- Try/except wrapping everything (defensive anti-pattern - DON'T DO THIS)
- Inconsistent error handling patterns (mixing styles)

**CRITICAL: Error Handling Philosophy**
- ✅ **DO:** Fail fast at boundaries (validate inputs, check preconditions)
- ✅ **DO:** Let exceptions propagate (don't catch unless you can handle)
- ✅ **DO:** Use consistent error patterns across codebase
- ✅ **DO:** Handle errors where resolution is clear (retry, fallback, cleanup)
- ❌ **DON'T:** Add defensive null checks everywhere (let it crash)
- ❌ **DON'T:** Catch exceptions just to log them (propagate instead)
- ❌ **DON'T:** Add try/except around everything (defensive anti-pattern)
- ❌ **DON'T:** Check for conditions that "should never happen" (if they can't, don't check)

**Security Issues:**
- Input validation missing at boundaries
- Unsafe data handling (SQL injection, command injection)
- Sensitive data in logs
- Unsafe deserialization
- Auth/session/audit weaknesses (missing authorization checks, unsafe session creation/use, incomplete audit trails)

**Pattern:** Architectural thinking + static analysis + manual inspection + expert judgment
**Note:** Focus on real bugs and design improvements. NOT defensive programming (fail fast, not defensive).
**CRITICAL:** Base all findings on actual code evidence. NEVER SPECULATE. If uncertain, read more context.

**Architecture-specific review rule (mandatory):**
- Do not stop at "no immediate bug." If a change violates layering or maintainability, report it as a real finding.
- For each architecture finding, include:
  - exact file:line evidence
  - violated boundary (e.g., route layer contains SQL/business logic)
  - concrete refactor direction (e.g., move query/aggregation into service, keep route thin)
  - expected benefit (testability, consistency, change safety)

**Present initial summary:**
- Total changed files and lines changed
- Issues found per category (count + files affected, with 1-2 examples per category)
- For correctness issues: briefly categorize (architectural, maintainability, logic, security, etc.)
- Include mandatory expanded report lines:
  - Debug code: X
  - Dead code: X
  - Rule violations: X
  - Correctness issues: X
  - Architectural violations: X
  - Design pattern violations: X
  - Structure/layering violations: X
  - DRY violations: X
  - Notes: ...
- Cross-cutting counts are mandatory even when also counted inside rule-violation/correctness categories.
- State: "Will review category by category. For each category, you can choose to review one-by-one or apply all fixes."

### Step 4: Review Each Category

**For each category with issues (one at a time):**

**1. Present category findings with proposed solutions:**
- Category name (e.g., "Debug Code")
- Show all issues in this category with file:line references
- For each issue: Show context AND proposed fix (enough detail for user to understand what will change)
- Make it clear what the fixes will do (remove lines, extract pattern, fix logic, etc.)

**2. Ask user preference FOR THIS CATEGORY ONLY (after showing proposed solutions):**
- "**For [Category Name]: review one-by-one or apply all?**"
- User now has enough information to decide (they've seen what the fixes will be)
- Make it clear this decision is ONLY for the current category

**3. Execute based on choice:**

**If "One-by-one":**
- For each issue: Show with context → Suggest fix → Get approval → Apply
- Move through all issues in this category

**If "Apply all":**
- Apply all fixes in this category immediately
- Show results summary when complete

**4. After category complete:**
- Suggest committing (optional)
- Move to next category
- Repeat steps 1-4 for next category

**After category complete:**
- Suggest committing changes
- If user confirms, stage and commit

### Step 5: Continue Through Categories

Repeat Step 4 for each category in order:
1. Debug code (safest)
2. Dead code (safe)
3. Rule violations (mostly safe, some judgment)
4. Correctness (always requires judgment)

**For correctness issues, always require explicit approval:**
- **CRITICAL:** Base findings on actual code changes, NOT speculation
- Show issue with sufficient context (read surrounding code if needed)
- Explain what's wrong (architectural, maintainability, logical, security, etc.) with evidence
- Suggest specific fix with rationale
- Explain benefit/impact (quantify if possible: "eliminates 40 lines", "fixes race condition")
- Get explicit approval before applying
- If uncertain about issue, get more context or ask user - NEVER GUESS

### Step 6: Final Summary

After all categories reviewed:
- Show summary of all fixes applied (count per category, total files affected)
- Highlight key improvements (patterns applied, bugs fixed, lines eliminated)
- Include mandatory expanded category summary block in final report:
  - Debug code: X
  - Dead code: X
  - Rule violations: X
  - Correctness issues: X
  - Architectural violations: X
  - Design pattern violations: X
  - Structure/layering violations: X
  - DRY violations: X
  - Notes: ...
- Recommend next steps (review diff, run tests, run linter)
- Suggest running `/jr-commit` if ready for PR
- If this review was story-scoped and fixes were applied, append a `## Session Artifact Log` entry to the story file per `../_shared/references/session-artifact-log.md` with touched files + validation evidence.

## Tool Integration

**Git commands:**
- `run_terminal_cmd` or `functions.shell_command`: Find branch point and changed files
- Use configured base branch (not hardcoded)

**Issue detection:**
- `grep` (via `functions.shell_command`): Find patterns (debug statements, dead code)
- `read_lints`: Get linter errors
- `read_file` or `functions.shell_command`: Read file content for analysis
- `codebase_search` or `functions.shell_command`: Find rule violations

**Fix application:**
- Use appropriate tools to apply fixes
- `run_terminal_cmd` or `functions.shell_command`: Stage and commit fixes when user approves


## Notes

**CRITICAL: Evidence-Based Review - ZERO TOLERANCE**

**NEVER SPECULATE. NEVER GUESS. NEVER JUMP TO CONCLUSIONS.**

- ❌ **FORBIDDEN:** "This might be...", "Could be...", "Probably..."
- ❌ **FORBIDDEN:** Assumptions about what code does without reading it
- ❌ **FORBIDDEN:** Guessing at intent or behavior
- ❌ **FORBIDDEN:** Making up issues that might not exist
- ✅ **REQUIRED:** Read the actual diff/changes
- ✅ **REQUIRED:** Understand what changed and why
- ✅ **REQUIRED:** Base findings on actual code, not speculation
- ✅ **REQUIRED:** If unsure, read more context or ask user

**If you don't know for certain, don't claim it's an issue.**

---

**Expert Code Review Philosophy:**

This is comprehensive expert-level review. You are Junior - expert software engineer, architect, and code reviewer. Your job is to ensure code is production-ready:
- Architecturally sound (right patterns, clean design)
- Logically correct (no bugs, right algorithms)
- Properly typed (type safety, clear contracts)
- Resource-safe (no leaks, proper cleanup)
- Thread-safe (if concurrent)
- Secure (input validation, safe handling)
- Maintainable (clear boundaries, thin handlers, testable service logic)
- **NOT defensive** (fail fast at boundaries, not defensive checks everywhere)

**Category Order:**
1. Debug code - always safe to remove
2. Dead code - safe to remove
3. Rule violations - mostly mechanical
4. Correctness - requires expert judgment (architectural, logical, security, resource, concurrency)

**Batching:** If > 50 issues, offer to batch by file or category for manageability.

**Language Agnostic:** Works for any language - adapt patterns per language.

---

Clean code is good code. Review early, review often.
