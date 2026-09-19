
# Subcommand: /jr maintenance

## Purpose

Analyze project structure and propose reorganization when complexity warrants it (Stage 1→2 or Stage 2→3).

## Type

Direct execution with approval gate

## When to Use

- Project has grown and features could be better organized
- Component has become large (>13 items) or has type mixing (docs/ + features)
- Want to understand if structure reorganization would help
- Transitioning from flat structure to component-based organization

## Process

### Step 0: Verify Git State

Run the Git commands below from the repository root. Define this helper in the shell used
for each phase so display settings cannot hide staged submodules or produce unusable patches:

```bash
maintenance_diff() {
  git --no-pager --literal-pathspecs diff --cached --no-color --no-relative \
    --no-ext-diff --no-textconv --ignore-submodules=none --submodule=short \
    --src-prefix=a/ --dst-prefix=b/ "$@"
}

git status --short
maintenance_diff --name-status
```

If not clean:
```
⚠️ Uncommitted changes detected.

Scope check:
- Review changed paths from `git status --short`.
- If changes are clearly isolated from maintenance scope, recommend proceeding.
- If changes touch related areas or scope is unclear, ask for explicit override.

Default: use /jr-commit first.
Override: If you confirm the changes are unrelated, reply "override: proceed".
```

Proceed only if:
- Working directory is clean, OR
- You recommend proceeding based on isolated scope, OR
- User explicitly confirms override with "override: proceed".

Permission to proceed with unrelated changes does not include them in maintenance commits.
Before any move, review exact source/destination file pairs and the complete staged diff.
If maintenance paths contain unrelated edits, or an existing staged rename crosses the
maintenance boundary, stop and resolve that overlap with the user. Do not silently include
those edits in a moves-only commit. Inventory untracked and ignored files inside directories
to be moved; move reviewed tracked files individually when moving the directory would also
relocate unrelated files.

If unrelated index entries exist, preserve their exact staged versions outside the worktree
with `maintenance_diff --binary --full-index --`, restricted to their
explicit literal file paths (both sides of renames). Verify the saved patch before using
`git --literal-pathspecs restore --staged --` on only those paths; never restore working-tree content. Keep the
patch until maintenance finishes, then run `git apply --cached --whitespace=nowarn --check`
followed by `git apply --cached --whitespace=nowarn` on it. This overrides whitespace-fixing
configuration so restoration retains the saved bytes. Compare the restored
`maintenance_diff --binary --full-index` with the saved one. Re-adding
working-tree files is not restoration: partially staged files can contain different bytes.
If preservation, isolation, or restoration fails, stop and retain the patch for recovery.
Never discard staged work, reset commits, or overwrite concurrent index changes.
Unmerged or intent-to-add entries need resolution before isolation; a diff patch cannot
faithfully restore those index states.

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan`:

```json
{
  "todos": [
    {"id": "detect-stage", "content": "Detect current stage and analyze structure", "status": "in_progress"},
    {"id": "find-opportunities", "content": "Find reorganization opportunities", "status": "pending"},
    {"id": "present-proposal", "content": "Present proposal with before/after trees", "status": "pending"},
    {"id": "wait-approval", "content": "Wait for user approval or adjustments", "status": "pending"},
    {"id": "execute-phase1", "content": "Phase 1: File moves with git mv", "status": "pending"},
    {"id": "execute-phase2", "content": "Phase 2: Create overviews and update references", "status": "pending"},
    {"id": "verify-complete", "content": "Verify reorganization complete", "status": "pending"}
  ]
}
```

### Step 2: Detect Current Stage

**Use stage detection from 01-structure.md:**

Detect which stage the project is currently in:
- **Stage 1:** No `comp-*/` directories under `.junior/features/`
- **Stage 2:** `comp-*/` directories exist, no `features/` subdirectory within components
- **Stage 3:** Component(s) have `features/` subdirectory

```bash
# Check for components
find .junior/features -maxdepth 1 -type d -name "comp-*"

# Check for Stage 3 indicators
find .junior/features/comp-* -maxdepth 1 -type d -name "features" 2>/dev/null
```

**Load current structure:**

```bash
# List all features/components
ls -la .junior/features/

# For Stage 2+: list contents of each component
ls -la .junior/features/comp-*/
```

### Step 3: Analyze for Reorganization Opportunities

**Stage 1 → Stage 2 Analysis (LLM-Based Semantic Clustering):**

If currently Stage 1, check if features naturally cluster:

1. **Read all feature overviews completely:**
   - Read each `feat-N-overview.md` in full (not just titles)
   - Understand the feature's purpose, deliverable, and scope
   - Note any integration points or dependencies mentioned

2. **Domain-Aware Semantic Analysis:**
   - **Understand the project domain** from the features (e.g., dashboard with widgets, API platform, mobile app)
   - **Identify logical user-facing entities:**
     - For dashboards: Which widgets do features relate to?
     - For APIs: Which domain entities or services?
     - For apps: Which screens or user flows?
   - **Recognize feature types:**
     - Infrastructure features (OS, deployment, build systems)
     - Widget/component-specific features (frontend + backend for one widget)
     - Core system features (shared infrastructure like routing, scheduling, layout)
     - Integration features (API clients, external services)

3. **Intelligent Grouping Strategy:**
   - **Primary grouping:** Around user-facing components/entities
     - Example: Dashboard project → Group by widget (all features for Widget X together)
     - Example: E-commerce → Group by domain (cart features, checkout features, product catalog)
     - Example: Mobile app → Group by screen/flow (onboarding, profile, messaging)
   - **Infrastructure grouping:** System-level features separate from user features
     - Example: OS/deployment, build systems, CI/CD separate from application features
   - **Core systems grouping:** Foundational shared code separate from domain features
     - Example: Routing, state management, authentication framework
   - **Keep related features together** even if they touch different technical layers
     - Frontend + backend + database for same entity should be in same component

4. **Clustering threshold:**
   - **Recommend Stage 2 if:** 4-6+ features cluster into distinct logical components
   - **Prefer domain/entity-based components** over technical layer groupings
   - **Good grouping:** Features organized by user-facing entity (Widget A, Service B, Screen C)
   - **Avoid:** Pure technical layers (all frontend together, all backend together, all database together)

**Stage 2 → Stage 3 Analysis (Size/Type Triggers):**

If currently Stage 2, check each component:

1. **Count items in each component:**
   - Features, improvements, bugs, enhancements
   - **Trigger:** Component has >13 items

2. **Check for type mixing:**
   - Does component have `docs/` directory?
   - Does component have `specs/` directory?
   - **Trigger:** Component has type mixing (features + docs at same level)

3. **Recommend Stage 3 if:** Any component meets size or type trigger

**No Reorganization Needed:**

If neither Stage 1→2 nor Stage 2→3 triggers met:

```
✅ Structure Looks Good

Current stage: [Stage 1/2/3]
No reorganization recommended at this time.

[Brief explanation of current state and what would trigger reorganization]
```

Exit gracefully.

### Step 4: Present Reorganization Proposal

**If reorganization opportunity found, present detailed proposal:**

**For Stage 1→2 Transition:**

````markdown
📊 Structure Reorganization Proposal

**Current Stage:** Stage 1 (Flat features)
**Recommended:** Stage 2 (Component organization)

**Reasoning:**
Found [N] features that cluster into [M] distinct components:
- [Component 1 name]: [K features] - [shared keywords: auth, user, session]
- [Component 2 name]: [L features] - [shared keywords: analytics, reports, metrics]
- [Component 3 name]: [O features] - [shared keywords: admin, config, settings]

**Before (Stage 1):**
```
.junior/features/
├── feat-1-user-auth/
├── feat-2-session-mgmt/
├── feat-3-password-reset/
├── feat-4-analytics-dashboard/
├── feat-5-report-generation/
├── feat-6-metrics-tracking/
├── feat-7-admin-panel/
└── feat-8-config-mgmt/
```

**After (Stage 2):**
```
.junior/features/
├── comp-1-authentication/
│   ├── comp-1-overview.md
│   ├── feat-1-user-auth/
│   ├── feat-2-session-mgmt/
│   └── feat-3-password-reset/
├── comp-2-analytics/
│   ├── comp-2-overview.md
│   ├── feat-4-analytics-dashboard/
│   ├── feat-5-report-generation/
│   └── feat-6-metrics-tracking/
└── comp-3-administration/
    ├── comp-3-overview.md
    ├── feat-7-admin-panel/
    └── feat-8-config-mgmt/
```

**Changes:**
- Create 3 components with logical groupings
- Move features into appropriate components
- Create comp-N-overview.md for each component
- Update cross-references in all docs

**Git Operations:**
- Phase 1: File moves (preserve history with git mv)
- Phase 2: Create component overviews and update references
- Two commits (moves separate from content)

Options: yes | adjust: [grouping changes] | cancel
````

**For Stage 2→3 Transition:**

````markdown
📊 Structure Reorganization Proposal

**Current Stage:** Stage 2 (Component organization)
**Recommended:** Stage 3 (Grouped structure)

**Reasoning:**
Component [comp-N-name] triggers Stage 3:
- [Size trigger: 15 items > 13 threshold] OR
- [Type mixing: has docs/ directory alongside features]

**Before (Stage 2):**
```
.junior/features/comp-1-backend/
├── comp-1-overview.md
├── feat-1-auth/
├── feat-2-api/
├── feat-3-database/
├── feat-4-caching/
├── feat-5-queue/
├── feat-6-workers/
├── feat-7-logging/
├── feat-8-monitoring/
├── feat-9-deployment/
├── feat-10-scaling/
├── imp-1-refactor/
├── imp-2-optimization/
├── docs/
└── specs/
```

**After (Stage 3):**
```
.junior/features/comp-1-backend/
├── comp-1-overview.md
├── features/
│   ├── feat-1-auth/
│   ├── feat-2-api/
│   ├── feat-3-database/
│   ├── feat-4-caching/
│   ├── feat-5-queue/
│   ├── feat-6-workers/
│   ├── feat-7-logging/
│   ├── feat-8-monitoring/
│   ├── feat-9-deployment/
│   └── feat-10-scaling/
├── improvements/
│   ├── imp-1-refactor/
│   └── imp-2-optimization/
├── docs/
└── specs/
```

**Changes:**
- Group items by type (features/, improvements/)
- Cleaner navigation for large component
- Maintain all functionality, just better organized

**Git Operations:**
- Phase 1: File moves (preserve history with git mv)
- Phase 2: Update references in all docs
- Two commits (moves separate from content)

Options: yes | adjust: [changes] | cancel
````

### Step 5: Wait for Approval

**User response options:**

1. **yes** - Proceed with reorganization as proposed
2. **adjust: [description]** - Modify grouping/organization before executing
   - Example: `adjust: move feat-3 to comp-2 instead of comp-1`
   - Update proposal based on adjustment
   - Re-present proposal
   - Wait for new approval
3. **cancel** - Abort reorganization

**Handle adjustments:**

If user requests adjustments:
- Parse adjustment request
- Modify proposal accordingly
- Re-present updated proposal with changes highlighted
- Loop back to approval step

**Only proceed to execution when user says "yes"**

### Step 6: Execute Reorganization - Phase 1 (File Moves)

**CRITICAL: Use git mv to preserve history**

#### Maintenance Commit Gate

Use this gate immediately before every maintenance commit below. It is an agent workflow
requirement, not an automated guarantee.

1. Review the exact file list for the current phase, including both paths of each move.
   For content updates, populate `maintenance_paths` with only reviewed file paths, including
   approved additions and deletions. Never use directory paths, globs, `git add .`, or
   repository-wide staging. Review any newly discovered reference-update paths before adding
   them to the list.
2. Moves are already staged by `git mv`; do not stage working-tree content in the moves phase.
   For the content phase only, stage the reviewed list from the repository root:

   ```bash
   git --literal-pathspecs add -- "${maintenance_paths[@]}"
   ```

3. Inspect the **complete index without a path filter**, not just the maintenance subset:

   ```bash
   maintenance_diff --name-status --find-renames
   maintenance_diff --check
   maintenance_diff --binary --full-index
   ```

   Every staged path and hunk must belong to the reviewed phase. Moves-only commits must
   contain exactly the planned renames with unchanged file modes and blob contents; content
   commits must contain only approved overview/reference edits. Reject unexpected entries,
   content changes in the moves phase, conflicts, and failed checks before committing.
4. Commit only the verified index. If it changes after inspection, repeat this gate. Inspect
   the resulting commit and remaining status after each phase. Restore the unrelated staged
   patch from Step 0 only after both commits (or when stopping safely), and verify those entries
   and their working-tree bytes are preserved.

**For Stage 1→2 transition:**

```bash
# Create component directories
mkdir -p .junior/features/comp-1-[name]
mkdir -p .junior/features/comp-2-[name]
mkdir -p .junior/features/comp-3-[name]

# Move features to components (git mv preserves history)
git mv .junior/features/feat-1-[name] .junior/features/comp-1-[name]/
git mv .junior/features/feat-2-[name] .junior/features/comp-1-[name]/
git mv .junior/features/feat-4-[name] .junior/features/comp-2-[name]/
# ... continue for all features

# Verify moves (count files before/after)
verify_file_moves()

# Check git status
git status

# Run the Maintenance Commit Gate, then commit Phase 1
git commit -m "$(cat <<'EOF'
Reorganize into component structure (file moves)

- Transition from Stage 1 (flat) to Stage 2 (components)
- Created [N] components: [comp-1-name], [comp-2-name], [comp-3-name]
- Moved [M] features into appropriate components
- Used git mv to preserve file history

Phase 1 of 2: File moves only (no content changes)
EOF
)"
```

**For Stage 2→3 transition:**

```bash
# Create type subdirectories within component
mkdir -p .junior/features/comp-1-[name]/features
mkdir -p .junior/features/comp-1-[name]/improvements

# Move items to type subdirectories (git mv preserves history)
git mv .junior/features/comp-1-[name]/feat-* .junior/features/comp-1-[name]/features/
git mv .junior/features/comp-1-[name]/imp-* .junior/features/comp-1-[name]/improvements/

# Keep comp-N-overview.md at component root
# Keep docs/ and specs/ at component root (already correct)

# Verify moves
verify_file_moves()

# Check git status
git status

# Run the Maintenance Commit Gate, then commit Phase 1
git commit -m "$(cat <<'EOF'
Group component items by type (file moves)

- Transition comp-[N]-[name] from Stage 2 to Stage 3
- Created features/ and improvements/ subdirectories
- Moved [M] items into type-based organization
- Used git mv to preserve file history

Phase 1 of 2: File moves only (no content changes)
EOF
)"
```

**Verification after Phase 1:**

```bash
# Count files moved
find .junior/features -type f -name "*.md" | wc -l

# Verify no files lost
git status --short

# Show structure
tree .junior/features -L 3
```

### Step 7: Execute Reorganization - Phase 2 (Content & References)

**For Stage 1→2 transition:**

**7.1: Create component overview files**

For each component, create `comp-N-overview.md`:

```markdown
# [Component Name]

> Created: [current date]
> Status: Active

## Purpose

[1-2 sentences describing component purpose - inferred from feature names/descriptions]

## Scope

[What this component covers, boundaries with other components]

## Features

| ID | Title | Status | Description |
|----|-------|--------|-------------|
| feat-1 | [Feature Name] | [Status from feat-1-overview.md] | [Brief description] |
| feat-2 | [Feature Name] | [Status] | [Brief description] |

## Improvements

| ID | Title | Status | Description |
|----|-------|--------|-------------|
| imp-1 | [Improvement Name] | [Status] | [Brief description] |

## Dependencies

**Depends on:**
- [Other components this depends on, if any]

**Used by:**
- [Components that depend on this one, if any]

## Technical Notes

[Any component-level technical considerations]
```

**7.2: Update cross-references**

Search for all references to moved features and update paths:

```bash
# Find references to old paths
grep -r "feat-1-" .junior/ --include="*.md"
grep -r "feat-2-" .junior/ --include="*.md"

# Update references: feat-1 → comp-1/feat-1
# Use search_replace to update all cross-references
```

**For Stage 2→3 transition:**

**7.2: Update cross-references only**

Update paths in all markdown files:

```bash
# Find references to old paths
grep -r "comp-1-[name]/feat-" .junior/ --include="*.md"

# Update references: comp-1/feat-1 → comp-1/features/feat-1
# Use search_replace to update all cross-references
```

**7.3: Verification after Phase 2**

```bash
# Search for old path references (should find none)
grep -r ".junior/features/feat-" .junior/ --include="*.md"
grep -r "comp-1-[name]/feat-[0-9]" .junior/ --include="*.md"

# Verify component overviews exist (Stage 1→2 only)
find .junior/features -name "comp-*-overview.md"

# Verify structure
tree .junior/features -L 3
```

**7.4: Commit Phase 2**

Run the **Maintenance Commit Gate** with the reviewed content-update file list.

```bash
git commit -m "$(cat <<'EOF'
Add component overviews and update cross-references

- Created comp-N-overview.md for each component (Stage 1→2)
- Updated all cross-references to new paths
- Verified no broken references remain

Phase 2 of 2: Content updates and reference corrections

Reorganization complete!
EOF
)"
```

### Step 8: Report Success

**Present completion summary:**

````markdown
✅ Reorganization Complete!

**Transition:** Stage [1/2] → Stage [2/3]
**Components:** [N components created/updated]
**Features moved:** [M features]
**Git commits:** 2 commits (moves + content)

**Structure:**
[Show final structure tree]

**Git Log:**
```bash
git log --oneline -2
```

**Verification:**
✅ All files moved successfully
✅ Component overviews created (if Stage 1→2)
✅ Cross-references updated
✅ No broken references found
✅ Git history preserved

**Next steps:**
- Review git commits to verify changes
- Update any external documentation if needed
- Continue working with new structure

New structure is ready to use!
````

## Key Implementation Notes

**LLM-Based Semantic Clustering (Stage 1→2):**
- Read complete feature overviews (full context, not just keywords)
- Understand project domain from feature descriptions
- Identify logical user-facing entities (widgets, services, screens, flows)
- Group features around those entities (keep related frontend+backend together)
- Separate infrastructure, core systems, and domain features
- Use LLM semantic understanding, not simple keyword matching
- Prefer domain/entity-centric groupings over technical layer groupings
- Keep vertical slices together (all layers for one entity in same component)

**Git Discipline:**
- **ALWAYS use git mv** for file moves (preserves history)
- **TWO commits required:**
  1. File moves only (no content changes)
  2. Content updates and reference corrections
- Verify after each phase (count files, check references)
- Apply the Maintenance Commit Gate before each commit; preserve unrelated index entries per Step 0
- Clear commit messages explaining reasoning

**Component Overview Template:**
- Use structure from 01-structure.md
- Populate purpose/scope from feature descriptions
- Auto-generate features table from feat-N-overview.md files
- Include dependencies between components

**User Approval:**
- Show before/after trees with clear reasoning
- Allow adjustments before executing
- Never proceed without explicit "yes"
- Support iterative refinement

**Verification Steps:**
- Count files before/after (must match)
- Search for old path references (must find none)
- Verify git history preserved (use `git log --follow`)
- Check structure with `tree` command

## Tool Integration

**Primary tools:**
- `todo_write` or `functions.update_plan` - Progress tracking
- `codebase_search` or `functions.shell_command` - Find feature descriptions for clustering
- `grep` (via `functions.shell_command`) - Search for cross-references to update
- `read_file` or `functions.shell_command` - Load feature overviews for analysis
- `write` or `functions.apply_patch` - Create component overview files
- `search_replace` or `functions.apply_patch` - Update cross-references
- `run_terminal_cmd` or `functions.shell_command` - Git operations, structure analysis

**Git commands:**
```bash
# Stage detection
find .junior/features -name "comp-*" -type d

# Create directories
mkdir -p .junior/features/comp-N-name

# Move files (preserve history)
git mv source destination

# Verification
tree .junior/features -L 3
git log --follow file.md

# Commits: first run the Maintenance Commit Gate for the current phase
git commit -m "message"
```

**Filesystem commands:**
```bash
# Count files
find .junior/features -type f -name "*.md" | wc -l

# Show structure
tree .junior/features -L 3
ls -la .junior/features/
```

## Error Handling

**No reorganization needed:**

```
✅ Structure looks good

Current stage: [Stage N]
No reorganization recommended.

[Explanation of current state and thresholds]
```

**User cancels:**

```
❌ Reorganization cancelled

No changes made. Structure remains at Stage [N].
```

**Verification fails:**

```
⚠️ Verification Issue

[Specific issue found]

Recommend: Review git status and fix manually, or git reset to undo.
```

**Git operation fails:**

```
❌ Git Operation Failed

[Error message]

Recommend: Check git status, resolve conflicts, and retry.
```

## Best Practices

**Analysis:**
- Load all feature overviews to understand full context
- Understand project domain from feature descriptions
- Look for natural groupings around user-facing entities (widgets, services, screens)
- Keep related features together even across technical layers (frontend + backend for same widget)
- Consider feature dependencies when grouping
- Separate infrastructure, core systems, and user features
- Propose logical number of components (avoid over-splitting)

**Proposal:**
- Show clear before/after trees
- Explain reasoning for groupings
- Be specific about what changes
- Allow user to adjust groupings

**Execution:**
- Always use `git mv` (never move + add)
- Verify after each phase
- Two-phase commits (moves, then content)
- Clear commit messages with reasoning

**Component Overviews:**
- Infer purpose from feature names/descriptions
- Keep descriptions concise (1-2 sentences)
- Auto-populate features table from feat-N-overview.md
- Update when features added/modified

**See also:** 01-structure.md for structure definitions
