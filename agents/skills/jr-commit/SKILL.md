---
name: jr-commit
description: Run `/jr-commit` to stage this session's work by concern, reconcile story checklists against evidence, and commit.
---

# Commit Command

## Purpose

Intelligent git commit that stages files from current session, analyzes changes, and generates standardized commit messages.

## Commit Authorization

Invoking `/jr-commit` or explicitly asking to commit authorizes staging and committing the reviewed scope. Complete the scope, diff, documentation, and validation checks, then commit without asking again for grouping, staging, or message approval.

Honor an explicit request to preview a message or wait before committing. Ask only when a material scope ambiguity or a blocking validation or safety issue needs the user's decision; do not treat routine local commits as an approval gate.

## 🔴 CRITICAL: Session Scope + Quality-Gate Carryover Scope

**This command commits files from THIS thread plus required carryover files from `/jr-test` and `/jr-code-review` for the same story/feature.**

What gets committed:
- ✅ Files you created in this session
- ✅ Files you edited in this session
- ✅ Documentation updated in this session
- ✅ Files changed by the latest `/jr-test` or `/jr-code-review` pass for the same story/feature, even if changed in a different conversation thread

What does NOT get committed:
- ❌ Unrelated changes showing in git status
- ❌ Files from other stories/features
- ❌ Random modified files from other work

**Scope rule:** Start with files touched in THIS thread, then explicitly add quality-gate carryover files linked to the same story/feature before staging.

## 🔴 CRITICAL: Full-Context Commit Message Guard (No Partial Summaries)

Commit messages must be generated from a full evidence pass, not recent-memory snippets.

Mandatory before writing any commit message:
1. Review the complete diff for the current commit group:
   - `git diff -- <file>` for unstaged files in the group
   - `git diff --cached -- <file>` for staged files in the group
   - `git diff --stat` and `git diff --cached --stat` for scope sanity check
2. Reconstruct the full thread timeline from available conversation history:
   - Read from the earliest available user/assistant messages in this thread
   - Extract major decisions, reversals, fixes, and intent changes
3. If full chat history is not available (context truncation/window limit):
   - State this explicitly before commit
   - Fall back to evidence from full git diffs, changed tests/docs, and current session notes
   - Ask one focused question only if a critical intent gap remains

Forbidden behavior:
- Generating commit text from only `git status` filenames
- Generating commit text from only the most recent chat turns
- Omitting earlier significant changes in the same commit group

## Evidence-Based Checklist Updates

Apply [Completion Evidence](../_shared/references/completion-evidence.md) when reconciling
acceptance criteria, Definition of Done, manual checks, and existing verification. Rule 13,
section 16 defines the boundary between timeless product material and tracking artifacts.

## 🔴 CRITICAL: Evidence-First Status Reconciliation (Stale Notes Never Win)

When story status signals conflict, reconcile in this order:
1. **Evidence first:** AC/DoD/test/log evidence determines status.
2. **Checklist second:** Checkbox state must match evidence.
3. **Notes last:** Workflow notes (for example, "pending /jr-test gate") are advisory only.

Rules:
- If evidence shows `/jr-test` and required fixes are complete, do **not** keep status In Progress because of stale pending notes.
- Remove or rewrite stale pending notes in the same edit where status/checklists are corrected.
- Keep status In Progress only when specific unchecked items still lack evidence or required manual validation.

## 🔴 CRITICAL: Documentation Alignment Confirmation

**Before committing, explicitly confirm documentation is aligned:**
- List the exact `.junior/` files reviewed and which needed updates; unchanged accurate files need no edit.
- State whether Acceptance Criteria and DoD were checked (and why).
- If any remain unchecked, say what evidence is missing.

## 🔴 CRITICAL: Code + .junior/ Documentation = 2 Commits

**MANDATORY SPLIT PATTERN - CHECK THIS FIRST BEFORE ANY STAGING:**

```
IF session changes include BOTH:
  - Code files (.py, .ts, .js, .qml, .cpp, etc.)
  - .junior/ documentation files

THEN you MUST create 2 separate commits:
  Commit 1: Code implementation + Project Rules (feat/fix/jr-refactor)
  Commit 2: .junior/ Documentation ONLY (docs)
```

**Path scope rule (mandatory):**
- Use only repository-local paths that appear in `git status` for the current repository.

**What goes in each commit:**

**Commit 1 (Implementation - TIMELESS):**
- ✅ Code files (*.py, *.ts, *.js, *.qml, *.cpp, etc.)
- ✅ Test files (test_*.py, *.test.ts, etc.)
- ✅ Project rule files (if present): `.cursor/rules/100+` or `.codex/rules/100+`
- ✅ Configuration files (package.json, pyproject.toml, etc.)
- ❌ NO Junior framework files in the same commit: `.agents/skills/`, `.agents/rules/00-99`, `.cursor/skills/`, `.codex/skills/`, `.cursor/rules/00-99`, `.codex/rules/00-99`
- ❌ NO story/task references in messages or code

**Commit 2 (Junior Documentation - CAN reference stories):**
- ✅ ALL `.junior/` documentation (features, improvements, debugging, experiments, research, decisions, docs, ideas)
- ✅ CAN reference Story X, Task Y, etc. (tracking work)

**Note on rule/skill layout:**
- `.agents/rules/00-99`, `.cursor/rules/00-99`, `.codex/rules/00-99` = Junior framework rules
- `.cursor/rules/100+`, `.codex/rules/100+` = Project-specific rules
- `.agents/skills/`, `.cursor/skills/`, `.codex/skills/` = Junior framework skills/commands

**When to commit framework/project rule files:**
- Project rules (`.cursor/rules/100+`, `.codex/rules/100+`) → WITH code changes
- Junior framework rules (`.agents/rules/00-99`, `.cursor/rules/00-99`, `.codex/rules/00-99`) → separate framework commit
- Junior framework skills (`.agents/skills/`, `.cursor/skills/`, `.codex/skills/`) → separate framework commit

**Example pattern:**
```
Session files:
  ✅ backend/controller.py                    ← CODE (Commit 1)
  ✅ frontend/Widget.qml                      ← CODE (Commit 1)
  ✅ <project-rule-file>.md      ← PROJECT RULES 100+ (Commit 1)
  ✅ .junior/features/feat-N-story-M.md       ← JUNIOR DOCS (Commit 2)

WRONG: Stage all files together ❌

RIGHT:
  Commit 1: controller.py + Widget.qml + 1xx-project-rule.md
    → feat(module): add feature implementation

  Commit 2: feat-N-story-M.md
    → docs(module): mark Story M complete
```

**Why split this way:**
- Code + Project Rules (100+) are TIMELESS (no story references)
- Project rules (100+) document patterns used in this project's code
- `.junior/` docs track WORK (Story X, Task Y) - separate concern
- Code+Project Rules can be reverted together without losing work tracking
- Clear separation: Implementation vs Project Management vs Framework

**Default assumption:**
- In normal application repositories, Junior framework files are not present in `git status`.
- If framework files are present (for example in Junior source maintenance), treat them as a separate concern and commit separately.

**Why project rules (100+) go with code:**
- Project-specific conventions that document patterns in THIS codebase
- Rules change when code patterns change → same commit makes sense
- Example: Adding service layer → update backend conventions rule

**Why framework skills/rules are separate:**
- These are Junior framework files (work across ALL projects)
- Not project-specific, not tied to any particular implementation
- Changes to these are Junior framework improvements
- Should be committed separately with `feat(junior):` or `docs(junior):` type

**Analogy:**
- Project rules (100+) = Your project's style guide (changes with your code)
- Framework rules (00-99) = Junior's operating manual (rarely changes)
- Framework skills = Junior's command library (rarely changes)
- `.junior/` = Your project management tracking (changes with work status)

**This check happens BEFORE staging in Step 2.5**

## Type

Direct execution - Review, validate, stage, and commit the authorized scope

## When to Use

- Ready to commit changes from current session
- Need help writing clear commit message
- Want reviewed changes committed with a clear message

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan`:

```json
{
  "todos": [
    {"id": "analyze-status", "content": "Analyze git status and identify changes", "status": "in_progress"},
    {"id": "update-docs", "content": "Update ALL documentation sections", "status": "pending"},
    {"id": "verify-docs", "content": "Verify documentation completeness with grep", "status": "pending"},
    {"id": "validate-tests", "content": "Run test validation if code changes present", "status": "pending"},
    {"id": "stage-files", "content": "Stage reviewed session files", "status": "pending"},
    {"id": "generate-message", "content": "Generate commit message", "status": "pending"},
    {"id": "commit-changes", "content": "Execute commit", "status": "pending"}
  ]
}
```

### Step 1.5: Staging Safety Rule

- ❌ **Never use `git add -A` or `git add .`** — always stage explicit file paths only.

### Step 1.6: Commit Message Format (Required)

**Always include a short summary line AND a brief body with 2-4 bullets.**

**Format:**
```
<type>(scope): short summary

- Detail 1 (what changed)
- Detail 2 (why or impact)
- Detail 3 (optional: scope/notes)
```

**Commit command rule (avoid blank lines in body):**
- Use a **single message** with explicit newlines, not multiple `-m` flags.
- Recommended:
  - `git commit -m $'summary\n\n- bullet 1\n- bullet 2\n- bullet 3'`
  - Or write a temp file and use `git commit -F /path/to/message.txt`

**Rules:**
- Summary ≤ 72 chars
- Body bullets concise, factual, no story/task IDs in non-doc commits
- Prefer “what changed” + “why” over generic phrasing

### Step 2: Git Status Analysis & Logical Grouping

**Check current git state:**

```bash
git status --porcelain
```

**🔴 CRITICAL: Analyze changes to identify commit-scope files**

1. **Identify commit-scope files:**
   - Start with files explicitly worked on in THIS session.
   - Add quality-gate carryover files from latest `/jr-test` and `/jr-code-review` for the same story/feature.
   - Parse related story `## Session Artifact Log` entries (see `../_shared/references/session-artifact-log.md`) and add listed `Files touched` paths as commit-scope candidates.
   - Intersect artifact-log candidates with current `git status --porcelain` so only currently changed files are staged.
   - Include carryover only when paths map to the same story/feature scope.
   - **Exclude ALL unrelated changes in git status.**

2. **If no commit-scope changes:**
   - Display "No files in commit scope to commit" and exit.

3. **Categorize commit-scope changes:**
   - Code files (implementation)
   - Test files (validation)
   - Configuration files
   - Documentation files

**Example:**
```
Commit-scope files:
  ✅ feat-2-overview.md (created in this session)
  ✅ feat-2-story-1.md (created in this session)
  ✅ auth.test.ts (from latest /jr-test for same story)

Out-of-scope files (EXCLUDE):
  ❌ other.py (from different work)
  ❌ widget.tsx (from previous session)
  ❌ submodules (not touched in this session)
```

### Step 2.5: Detect Logical Commit Groupings

**🔴 CRITICAL: Automatically detect when changes should be split into multiple commits**

**FIRST: Check for Code + .junior/ Documentation Pattern (MANDATORY SPLIT)**

**Detection triggers (check FIRST):**
- Implementation files (code, tests, config) + `.junior/` docs → MANDATORY split
- Implementation includes: code, tests, project rules (100+), config
- Junior framework files (skills/rules 00-99) → separate from implementation

**Split logic:**
1. Identify implementation files vs `.junior/` docs
2. Check for project-rule files (`.cursor/rules/100+`, `.codex/rules/100+`) vs framework files (`.agents/skills/`, `.agents/rules/00-99`, `.cursor/skills/`, `.codex/skills/`, `.cursor/rules/00-99`, `.codex/rules/00-99`)
3. Create 2+ commits: implementation, junior docs, optional framework

**If the above pattern is NOT detected, then proceed with general pattern-based analysis:**

Analyze session files to detect distinct concerns using these patterns:

## Commit Message Style

**What a commit message is for:** read by whoever runs `git log` or `git blame` on this code, months
or years from now, asking *what changed here and why.* It is the most durable artifact this skill
writes and the one with the least context around it.

**Never goes in one:** the session that produced it · story or task numbers in implementation
commits · counts of tests run or files touched, where the diff says it · the reasoning that led to
the change, where the change states itself · attribution trailers of any kind, including ones a
runtime appends automatically (`03-style-guide.md`).

**Register:** the subject is a noun-headed action, never a sentence or a question. Body bullets
state facts. No editorial lead, no anthropomorphising, no dramatic adjective — a fix is described,
not praised. Baseline: `../_shared/references/artifact-output-spec.md`.

**Default style:**
- **Subject:** concise, action-oriented, present tense
- **Body:** 3–6 bullets with key changes only

**Implementation commits (code/tests/config):**
- ✅ Keep subject short
- ✅ Body summarizes the main functional changes and any migration/tooling impact
- ❌ No story/task references
- ❌ No test counts or long changelog-style lists

**Documentation commits (.junior/):**
- ✅ Can be more detailed and mention story/task tracking
- ✅ Longer body is OK if it clarifies progress or decisions

**Body content guidance:**
- Focus on high-impact changes and cross-cutting behavior
- Prefer 4–6 bullets over paragraphs
- Include rationale only when it affects usage or safety

1. **Different purposes/types:**
   - Implementation vs documentation vs configuration vs tests
   - New features vs bug fixes vs refactoring
   - Different modules/components being changed

2. **Different contexts:**
   - Files grouped by directory/module structure
   - Changes affecting different parts of the system
   - Separate work streams happening in parallel

3. **Natural boundaries:**
   - Infrastructure/framework changes vs application code
   - Spec/design documents vs implementation
   - Multiple unrelated features/fixes in same session

**Heuristics for splitting (NOT rigid rules, EXCEPT .junior/ pattern):**

```
MANDATORY SPLIT (checked in Step 2.5 FIRST):
🔴 Implementation + .junior/ docs → ALWAYS 2 commits (NO EXCEPTIONS)
   Implementation = code + tests + project rules (100+) + config
   Example: controller.py + test_controller.py + 130-rules.md + story-2.md
   → Commit 1: code + tests + project rules (100+), Commit 2: junior docs

Note: framework rules/skills are separate (`.agents/.cursor/.codex` layout)
      → Separate commit if changed (not grouped with implementation)

STRONG signals to split:
✅ Multiple feature directories → Different features
✅ New feature + bug fix → Different types of work
✅ Frontend + backend changes for different purposes → Different modules

WEAK signals (usually keep together):
⚠️ Implementation + its tests → Same feature (keep together)
⚠️ Implementation + project rules (100+) → Same concern (keep together)
⚠️ Related changes in same module → Same concern (keep together)

SPECIAL PATTERN - .junior/ Documentation:
ALWAYS split into 2+ commits when both implementation and .junior/ docs changed:

  Commit 1: Implementation (code + tests + project rules (100+) + config)
            - TIMELESS, no story refs
            - feat/fix/jr-refactor type

  Commit 2: Junior Documentation (.junior/ files only)
            - CAN reference stories/features
            - docs type

Example Session:
  Files changed:
    - auth.py, test_auth.py
    - <project-rule-file>.md (project rule)
    - .junior/features/feat-2-story-2.md

  Commits:
    1. feat(auth): implement login with JWT
       Files: auth.py, test_auth.py, 1xx-project-rule.md

    2. docs(auth): record authentication completion
       Files: .junior/features/feat-2-story-2.md

Why project rules (100+) go with code:
  - Project-specific rules document patterns used in THIS project
  - Rules change when project code patterns change
  - Example: Adding service layer → update backend conventions

Why framework rules/skills are separate:
  - Junior framework files (work across ALL projects)
  - Not tied to any specific project implementation
  - Changes are Junior improvements, not project features

ASK YOURSELF:
- Would these changes make sense in separate pull requests?
- Do they have different purposes/motivations?
- Could one be reverted without affecting the other?
- Would someone reviewing understand each commit independently?

If YES to most → Split
If NO to most → Keep together
```

**Report the selected grouping and proceed:**

```
📊 Detected Multiple Logical Groups

Your changes can be split into focused commits:

Group 1: Feature Specification
  📁 docs/features/new-dashboard/
     - overview.md
     - requirements.md
     - user-stories/ (4 files)

  Purpose: New feature specification
  Type: docs

Group 2: Infrastructure Updates
  📁 config/eslint.config.js
  📁 .github/workflows/ci.yml
  📁 package.json

  Purpose: Improve code quality tools
  Type: chore

Creating 2 focused commits, one group at a time.
```

Apply the grouping rules above without a separate approval step. Stage and commit each group before moving to the next.

### Step 3: Update Related Documentation

**🔴 CRITICAL: Update docs BEFORE staging - This step is MANDATORY, not optional**

**🔴 CRITICAL: PARTIAL UPDATES ARE NOT ACCEPTABLE - Update ALL sections or nothing**

**You MUST check for and update documentation EVERY TIME before staging files.**

**What goes into those documents:** checkbox states, and evidence in the fields that hold evidence.
Not this session's reasoning, not what was verified in which order, not a note recording that this
command updated them. The `## Session Artifact Log` entry is the story file's only provenance and
it is enough. Spec: `../_shared/references/artifact-output-spec.md`.

**Process:**

**1. Find ALL related documentation:**
```bash
# Find story files related to your changes
find .junior/features -name "*story*.md" | xargs grep -l "filename_you_changed"

# OR if you know the feature number
ls .junior/features/feat-N/user-stories/
```

**2. For EACH story file, READ THE ENTIRE FILE (not just one section):**
```bash
# Use read_file tool to read the COMPLETE file from line 1 to end
# DO NOT scan or skim - READ EVERY SECTION
# If Session Artifact Log exists, use it to reconstruct full touched-file context
```

**3. Count ALL checkboxes BEFORE making changes:**
```bash
# Count unchecked boxes (should become 0 for completed stories)
grep -c "\[ \]" .junior/features/feat-N/user-stories/feat-N-story-X.md

# Count checked boxes (should increase)
grep -c "✅" .junior/features/feat-N/user-stories/feat-N-story-X.md
```

**4. Identify ALL sections with checkboxes in the story file:**

Common sections to check:
- ✅ Status field (at top: `> Status: In Progress` → `> Status: Completed ✅`)
- ✅ Acceptance Criteria section
- ✅ Implementation Tasks section
- ✅ Definition of Done section
- ✅ Any other sections with `- [ ]` checkboxes

**Use grep to find ALL checkbox sections:**
```bash
# Show line numbers of ALL checkboxes in file
grep -n "\[ \]" feat-N-story-X.md

# This tells you which sections need updating - UPDATE THEM ALL
```

**5. Update ALL sections systematically:**

**🔴 CRITICAL: Checkbox Format (MUST be consistent across all .junior/ files)**

**ALWAYS use this format:**
- Unchecked: `- [ ] Task description`
- Checked: `- ✅ Task description`

**NEVER use or accept:**
- ❌ `- [x] Task description` (markdown checked format - WRONG)
- ❌ `- [x] Task description ✅` (mixed/redundant format - WRONG)

If you find checkboxes using `[x]` format, you MUST fix them before proceeding.

For completed work, mark EVERY checkbox:
- Change `- [ ]` → `- ✅` for ALL completed items
- Change `Status: In Progress` → `Status: Completed ✅` in individual story files
- Update progress tracking in `feat-N-stories.md`:
  - Update **Status field at top** (Planning → In Progress → Completed ✅)
  - Update task counts (X/Y completed)
  - Update percentages
  - Update story table rows (status column)
- Update `feat-N-overview.md` Status field if all stories complete

**🔴 CRITICAL: Determining Feature Completion Status:**

When checking if "all stories complete" for feature status:
- ✅ **Count ONLY deliverable stories** (stories with actual implementation work)
- ❌ **Exclude future enhancements backlog** (NOT in story table, separate document)
- **Future enhancements:** Captured in `feat-N-story-future-enhancements.md` (not numbered, not in story table)

**Example:**
```
| Story | Title | Status | Tasks | Progress |
|-------|-------|--------|-------|----------|
| 1 | User Auth | Completed ✅ | 5 | 5/5 ✅ |
| 2 | Dashboard | Completed ✅ | 4 | 4/4 ✅ |
| 3 | Reports | Completed ✅ | 6 | 6/6 ✅ |

**Total:** 15/15 tasks (100%)

**Note:** Future enhancements backlog captured in feat-N-story-future-enhancements.md

Status: Completed ✅  ← All numbered stories done
```

**If all deliverable stories complete:**
- feat-N-stories.md Status → "Completed ✅"
- feat-N-overview.md Status → "Completed ✅"

**If any deliverable story incomplete:**
- Keep Status as "In Progress" or "Planning"

**6. VERIFY completeness with grep AFTER updates:**
```bash
# Count remaining unchecked boxes (should be 0 for completed stories)
grep -c "\[ \]" feat-N-story-X.md

# If > 0, you missed checkboxes - GO BACK AND FIX
```

**7. Update other documentation:**
- READMEs that describe changed functionality
- Technical specs that document changed components
- API docs for changed endpoints

### Step 4: Resolve Missing Manual Evidence

Apply [Completion Evidence](../_shared/references/completion-evidence.md#manual-verification).
Only unresolved criteria that require a human observation need a question. Ask about one
specific criterion, retain verified evidence, and leave any unsupported items pending.

**🔴 MANDATORY CHECKLIST - Answer YES to ALL before proceeding:**

```
Documentation Update Checklist:

[ ] Did I read the ENTIRE story file (not just one section)?
[ ] Did I use grep to find ALL checkbox sections?
[ ] Does the story Status field match its evidence?
[ ] Do ALL Acceptance Criteria checkboxes match applicable evidence?
[ ] Do ALL Implementation Tasks checkboxes match applicable evidence?
[ ] Do ALL Definition of Done checkboxes match applicable evidence?
[ ] Did I reconcile status/checklists from evidence first (not stale pending notes)?
[ ] Did I reconcile manual items using the shared evidence contract?
[ ] Does feat-N-stories.md Status match the reconciled stories?
[ ] Do feat-N-stories.md progress totals match the reconciled stories?
[ ] Did I check if feature should be "Completed" (excluding backlog stories)?
[ ] Did I verify with grep that unchecked count is 0 (for completed stories)?
[ ] Did I update any related READMEs or technical docs?

If ANY answer is NO, STOP and complete that step before staging.
```

**Example:**
```bash
# Changed: app/auth.py from feat-1-story-2
# Must check: .junior/features/feat-1-auth/user-stories/feat-1-story-2-login.md

# Read entire file
cat .junior/features/feat-1-auth/user-stories/feat-1-story-2-login.md

# Count before
grep -c "\[ \]" feat-1-story-2-login.md  # Shows: 19

# Update ALL sections (Status, Acceptance Criteria, Tasks, Definition of Done)

# Count after
grep -c "\[ \]" feat-1-story-2-login.md  # Shows: 0
grep -c "✅" feat-1-story-2-login.md      # Shows: 19
```

**This step is NOT optional:**
- Even if changes seem trivial
- Even if you "think" docs are already up to date
- Even if you're in a hurry
- **Even if you already updated ONE section** ← Must review ALL sections; edit only where reconciliation requires it

**⚠️ Common Mistakes to Avoid:**
- ❌ Updating only Implementation Tasks but not Acceptance Criteria
- ❌ Updating only one section and assuming others are done
- ❌ Not reading the entire file before updating
- ❌ Not verifying with grep after updates
- ❌ Trusting memory instead of checking the actual file

**Skip documentation updates ONLY if:**
- Changes are pure documentation updates (no code changed)
- Absolutely no related docs exist (extremely rare)

### Step 5: Verify Documentation Completeness

**🔴 MANDATORY: Run these verification commands before proceeding**

**This step MUST be completed - mark the verify-docs todo as complete only after running ALL checks**

**Verification Commands:**

```bash
# 0. FIRST: Check for incorrect checkbox format (MUST be 0)
grep -rn "\- \[x\]" .junior/features/feat-N/
# If ANY files found → FIX IMMEDIATELY before proceeding
# Change `- [x]` → `- ✅` and remove redundant ✅ emoji at end

# 1. Check for remaining unchecked boxes in ALL story files you touched
find .junior/features/feat-N -name "*story*.md" -exec echo "=== {} ===" \; -exec grep -c "\[ \]" {} \;

# 2. If any file shows count > 0, display those unchecked boxes
grep -n "\[ \]" .junior/features/feat-N/user-stories/feat-N-story-X.md

# 3. Verify checked boxes match evidence (an unchanged count can be correct)
grep -c "✅" .junior/features/feat-N/user-stories/feat-N-story-X.md
```

**Expected Results:**

For checkbox format:
- ✅ Incorrect format count (`\- \[x\]`): **0** (MANDATORY)
- ❌ If any found → STOP and fix format before proceeding

For completed stories:
- ✅ Unchecked count (`\[ \]`): **0**
- ✅ Checked count (`✅`): **> 0** (should equal total tasks)

For in-progress stories:
- ⚠️ Unchecked count: Some remaining (document which tasks are pending)
- ✅ Checked count: Matches applicable evidence, including evidence recorded before this command

**If verification fails:**
- ❌ ANY incorrect checkbox format found (`[x]`) → STOP, FIX FORMAT, rerun verification
- ❌ Any completed story still has unchecked boxes → GO BACK to Step 3
- ❌ Checkbox states do not match evidence → GO BACK to Step 3
- ❌ Any checklist section has not been reviewed against evidence → GO BACK to Step 3

**Only proceed to Step 6 after:**
- ✅ All verification commands run
- ✅ Results match expectations
- ✅ verify-docs todo marked as completed

### Step 6: Test & Coverage Validation

For executable changes, including code shipped inside documentation, apply
[Coding Verification](../_shared/references/completion-evidence.md#coding-verification).
Use the project's established runner and reuse evidence only when it covers the exact
current changes. Documentation-only prose corrections use artifact verification instead.

Report the shared contract's verdict and evidence before staging. A passing percentage
alone cannot establish readiness, and this command introduces no separate coverage target.

- **Contract satisfied:** Proceed to staging within the authorized commit scope.
- **Contract not satisfied:** Fix the failures or gaps. If the user explicitly authorizes
  preserving incomplete work, mark the commit `WIP` and name the unmet requirements and risk.
- **User explicitly requests omitted validation:** Name the checks not run and remaining
  risk; do not claim verification or completion based on the commit.

### Step 7: Stage Files (Per Logical Group)

**🔴 CRITICAL: Session-Based Staging Logic**

**Stage ONLY commit-scope files (session + same-story quality-gate carryover) - nothing else!**

**NEVER use `git add .` - Always stage files explicitly file-by-file**

**Mandatory explicit add-ons (when present in git status and in-scope):**
- Story file: `.junior/features/feat-N-*/user-stories/feat-N-story-M*.md`
- Story index: `.junior/features/feat-N-*/user-stories/feat-N-stories.md`
- Feature overview: `.junior/features/feat-N-*/feat-N-overview.md`
- Test/code files touched by latest `/jr-test` and `/jr-code-review` for the same story/feature

**If multiple logical groups detected (Step 2.5):**
- Stage and commit ONE group at a time
- After each commit, move to next group
- This creates focused, atomic commits

**For current group, present staging plan:**
```
📁 Files to stage (Group 1 of 2):

Feature Specification (feat-N):
  A  .junior/features/feat-N-feature-name/feat-N-overview.md
  A  .junior/features/feat-N-feature-name/user-stories/feat-N-stories.md
  A  .junior/features/feat-N-feature-name/user-stories/feat-N-story-1-name.md
  ... (6 more story files)
  A  .junior/features/feat-N-feature-name/specs/01-Technical.md

📋 Excluding (will commit in Group 2):
  M  .agents/rules/00-junior.md
  M  .agents/rules/03-style-guide.md
  M  .agents/skills/jr-feature/SKILL.md

📋 Excluding (NOT part of this session):
  M  backend/other.py         ← From different work
  M  frontend/widget.tsx      ← From previous session

Staging the reviewed files in Group 1.
```

**Stage explicitly (for current group):**
```bash
git add .junior/features/feat-N-feature-name/feat-N-overview.md
```

**After committing Group 1, repeat for Group 2:**
- Present Group 2 staging plan
- Stage Group 2 files
- Generate Group 2 commit message
- Commit Group 2

### Step 8: Generate Commit Message (Per Logical Group)

**For current logical group, analyze changes to determine commit type:**

**Commit Types:**
- `feat` - New features
- `fix` - Bug fixes and corrections
- `docs` - Documentation updates
- `refactor` - Code restructuring without feature changes
- `test` - Adding or updating tests
- `chore` - Maintenance tasks (dependencies, cleanup)
- `config` - Configuration changes

**Message Generation Logic:**

1. **Analyze for work context (current group only):**
   - Determine if changes are part of specific work (features, experiments, bugfixes, etc.)
   - **Extract TIMELESS context:** Use feature/component names, NOT story numbers
     - Good: `auth`, `dashboard`, `payment`, `api`
     - Bad: `feat-1-story-2`, `story-3`, `task-1.5`
   - Add status: (WIP) if in progress, omit if complete or not tracked work
   - **Keep product commit messages timeless**; documentation-only tracking commits may name work identifiers under the commit-grouping rules above

2. **Run full-diff review for this group (mandatory):**
   - Read every changed hunk for every file in the group (staged + unstaged if relevant)
   - Verify subject/body reflects the full scope, not just latest edits
3. **Run chat-history review (best effort, mandatory attempt):**
   - Scan the thread from earliest available message to latest
   - Capture decisions that materially changed implementation direction
   - If history is truncated, note that limitation and rely on git/test/doc evidence
4. Analyze file changes to determine primary type
5. Generate concise subject line with timeless context
6. Add optional detailed body with bullet points
7. Use imperative mood ("Add feature" not "Added")

**Format (with context):**
```
[type]([context]): [status] [brief description]

[Optional details]
```

**Format (without context):**
```
[type]: [brief description]

[Optional details]
```

**Examples (Group-Specific):**

Group 1 (New feature implementation):
- `feat(auth): add JWT authentication system`
- `feat(dashboard): implement real-time analytics`

Group 2 (Infrastructure/config):
- `chore: update ESLint rules and CI pipeline`
- `docs: improve API documentation and examples`

Single commit (related work):
- `feat(login): implement OAuth with tests and docs`
- `fix(payment): resolve race condition in checkout flow`

### Step 9: Commit Execution (Per Logical Group)

Follow **Commit Authorization** above. Check the staged diff contains only the reviewed group and that the generated message describes it, then execute the commit using the message format from Step 1.6. Do not pause for message approval unless the user requested a preview or hold.

After committing, verify the resulting commit and remaining working-tree changes. Report the commit hash and subject, then continue with any remaining groups.

**Show completion:**

```
Commit 1 of 2 completed!

📝 Commit: <commit-hash> - feat(component): add component behavior
📁 Files: <file-count> staged
📊 Changes: <diff-summary>

Moving to Group 2...
```

**If multiple groups:**
- Repeat Steps 5-9 for each group
- After all groups committed, show final summary

**Final summary (after all groups):**

```
All commits completed successfully!

📝 Commit 1: <implementation-hash> - feat(component): add component behavior
   📁 <implementation-diff-summary>

📝 Commit 2: <documentation-hash> - docs(component): update component guidance
   📁 <documentation-diff-summary>

Total: 2 commits, <combined-diff-summary>
```

## Format Guidelines

**Subject Line:**
- Under 80 characters
- Capitalize first word after colon
- Use imperative mood
- No period at end

**Body (optional):**
- Blank line after subject
- Bullet points for multiple changes
- Wrap at 80 characters
- Explain what and why

## Tool Integration

**Primary tools:**
- `todo_write` or `functions.update_plan` - Progress tracking
- `run_terminal_cmd` or `functions.shell_command` - Git commands
- `read_file` or `functions.shell_command` - Read story files and documentation
- `search_replace` or `functions.apply_patch` - Update documentation checkboxes and progress
- `glob_file_search` or `functions.shell_command` - Find related story files
- `grep` (via `functions.shell_command`) - Search for file references in documentation
- `codebase_search` or `functions.shell_command` - Context analysis (if needed)

**Git commands:**
- `git status --porcelain` - Check status
- `git add file1.ts file2.ts` - Stage files explicitly
- `git commit -m "[message]"` - Commit changes

**Test validation commands (language-agnostic):**
- `npm test` / `npm test -- --coverage` - Node.js/JavaScript
- `pytest --cov --cov-report=term-missing` - Python
- `go test -cover ./...` - Go
- `cargo test` / `cargo tarpaulin` - Rust
- `make test` / `gcov` / `lcov` - C/C++
- `swift test --enable-code-coverage` - Swift

**Documentation commands:**
- `find .junior -name "feat-*-story-*.md"` - Find story files
- `grep -r "filename" .junior/` - Find file references

**CRITICAL:** NEVER use `git add .` - Always stage files explicitly by name, one by one.

## Git Command Reference

**Checking status:**
```bash
git status                  # Overview
git status --porcelain      # Script-parseable format
```

**Viewing changes:**
```bash
git diff                    # Unstaged changes
git diff --cached           # Staged changes
git show HEAD               # Last commit
```

**Staging:**
```bash
git add file.ts             # Stage specific file
git add file1.ts file2.ts   # Stage multiple files explicitly
```

**CRITICAL:** NEVER use `git add .` or `git add -A` - Always list files explicitly.

## Examples

**With timeless context (feature/component names):**
```
feat(auth): implement login endpoint

- Add JWT token generation
- Implement password validation
- Add comprehensive tests
```

```
feat(auth): WIP add OAuth integration

- Google OAuth provider configured
- Callback endpoint implemented
- TODO: Add token refresh logic
- TODO: Handle error cases
```

```
feat(dashboard): implement real-time analytics

Add WebSocket connection and live data updates:
- Real-time data streaming from backend
- Auto-refresh charts on data change
- Handle connection errors gracefully
- Performance optimizations for large datasets
```

```
fix(data-processor): resolve memory leak in cleanup

Handle cleanup in destructor properly.
```

**Without context:**
```
fix: resolve Safari compatibility in auth flow

Handle edge case where localStorage is disabled.
```

**Documentation:**
```
docs: update API reference for authentication
```

**Refactor:**
```
refactor: extract validation logic to utils

Improve testability and reusability.
```

---

Clear commits. Clear intent. Simple.
