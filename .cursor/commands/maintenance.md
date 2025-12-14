# Maintenance

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

### Step 1: Initialize Progress Tracking

Create todos using `todo_write`:

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

**Use stage detection from 01-structure.mdc:**

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

**Stage 1 → Stage 2 Analysis (Semantic Clustering):**

If currently Stage 1, check if features naturally cluster:

1. **Extract feature names and descriptions:**
   - Read each `feat-N-overview.md`
   - Extract feature name and brief description
   - Build list of features with metadata

2. **Keyword-based clustering:**
   - Extract keywords from feature names (remove stopwords: "feature", "system", "module")
   - Find features with shared keywords
   - Identify clusters of 3-4+ features

3. **Clustering threshold:**
   - **Recommend Stage 2 if:** 4-6+ features cluster into distinct groups
   - **Example:** 8 features → 4 auth-related, 3 analytics-related, 1 standalone → Recommend 2 components

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

```
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

---
Options: yes | adjust: [grouping changes] | cancel
```

**For Stage 2→3 Transition:**

```
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

---
Options: yes | adjust: [changes] | cancel
```

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

# Commit Phase 1
git add -A
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

# Commit Phase 1
git add -A
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

```bash
git add -A
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

```
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
```

## Key Implementation Notes

**Semantic Clustering (Stage 1→2):**
- Extract keywords from feature names and descriptions
- Remove stopwords: "feature", "system", "module", "core", "main"
- Find features sharing 2+ keywords
- Group into clusters of 3-4+ features
- Name components based on dominant shared keywords
- Simple keyword matching, no NLP/AI required

**Git Discipline:**
- **ALWAYS use git mv** for file moves (preserves history)
- **TWO commits required:**
  1. File moves only (no content changes)
  2. Content updates and reference corrections
- Verify after each phase (count files, check references)
- Clear commit messages explaining reasoning

**Component Overview Template:**
- Use structure from 01-structure.mdc
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
- `todo_write` - Progress tracking
- `codebase_search` - Find feature descriptions for clustering
- `grep` - Search for cross-references to update
- `read_file` - Load feature overviews for analysis
- `write` - Create component overview files
- `search_replace` - Update cross-references
- `run_terminal_cmd` - Git operations, structure analysis

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

# Commits
git add -A
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
- Load all feature overviews to understand content
- Look for natural groupings based on keywords
- Consider feature dependencies when grouping
- Propose 2-4 components (not too many)

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

---

**Implements:** feat-4-story-2 (Component Organization)
**See also:** 01-structure.mdc for structure definitions, 01-Technical.md for architecture details
