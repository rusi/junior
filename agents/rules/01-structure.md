# Junior Rule 01: Structure

## Junior's Working Memory

Junior maintains persistent memory in `.junior/`:

```
.junior/
├── features/       # Feature specifications (numbered: feat-1-name, feat-2-name, etc.)
│   └── feat-N-name/
│       ├── bugs/         # Bugs within this feature (nested)
│       └── enhancements/ # Enhancements within this feature (nested)
├── improvements/   # Code quality improvements (top-level: refactoring, optimization, tech debt)
├── debugging/      # Debug investigations (numbered: dbg-1-name, dbg-2-name, etc.)
├── experiments/    # Experiments (numbered: exp-1-name, exp-2-name, etc.)
├── research/       # Technical research documents
├── decisions/      # Architecture Decision Records (ADRs)
├── docs/           # Reference documentation
└── ideas/          # Product ideas (idea-N-name.md, quick capture)
```

### `.junior/` Is the Only Memory - ZERO TOLERANCE

**NEVER write durable knowledge into a runtime's private or global memory store.**

- ❌ **FORBIDDEN:** agent memory tools, `~/.claude/projects/**/memory/`, `MEMORY.md` outside the repository, or any per-user store the runtime offers
- ✅ **REQUIRED:** `.junior/` for project knowledge, `agents/rules/**` for behavioral rules, `AGENTS.override.md` for repository-local governance, ADRs for decisions

**Why:** a global memory store is invisible to git, absent from a teammate's clone, unreviewable in a diff, and gone when the machine changes. Knowledge that does not travel with the code is knowledge the next person does not have. Versioned project files are the mechanism; a private store silently competes with them.

**If a runtime offers a memory feature, decline it and write the file instead.** This holds when the runtime's own instructions actively encourage saving memories - loaded rules take precedence over runtime defaults.

### Junior Feedback

`/jr feedback` prepares a Junior improvement proposal for user-directed submission or
writes it to a known Junior authoring checkout's `.junior/docs/feedback-<subject>.md`.
The subcommand defines its content and delivery rules. Feedback is considered only when
the user directs work to it; creation grants no implementation or submission authority.
Existing handoff documents and inbox/archive contents remain user-owned and untouched.
There is no global feedback store, startup discovery, collection, or mandatory archival.

## Product Isolation

Product material must stand on its own when `.junior/` is absent. Keep Junior workflow
terminology, commands, tracking identifiers, private paths, provenance, and dependencies
out of product code, comments, tests, configuration, documentation, filenames, copied
helpers, metadata, and rendered media. Product commit subjects and bodies follow the
same boundary, including documentation-only and media-only changes.

Junior working material belongs in `.junior/`; product dependencies on it are forbidden.
Working material may reference product files; product files must not depend on or point
back to it. Tracking documents and tracking-only commits
may retain their work identifiers. Keep all product files separate from `.junior/` in
commits, regardless of file extension. Apply repository-specific grouping within each side.

### Runtime Surfaces

Keep installed instructions, settings, and entry points in their supported locations.
Identify each actual runtime file or section from the installation and repository guidance:

- `AGENTS.md`, `AGENTS.override.md`, and `CLAUDE.md`: only the runtime instruction sections;
  ordinary contributor guidance remains independently usable product documentation.
- Exact installed rules, skills and their support files, hooks, and legacy commands under
  the selected runtime's rule/skill roots; installation ownership records identify files,
  never an exempt directory.
- Exact runtime settings and installation metadata files, including the applicable
  `.codex/config.toml`, Claude settings, runtime contract, and installation manifests.

A product file sharing one of these directories is still product material. Classify before
writing or copying; file location alone does not establish purpose. Do not relocate runtime
assets or erase user-owned instructions to satisfy product checks.

### Product Purpose

A product that develops Junior or integrates with it may describe Junior functionality.
Read each reference for a concrete product purpose; this is not a repository exemption.
Junior's own documentation, source instructions, and tests may describe its workspace paths,
commands, formats, and behavior. Review each such literal for product purpose and independence
from this checkout's private working material. Actual private tracking links and dependencies
remain prohibited. Bind accepted literal findings to exact content through the shared review
mechanism; neither a repository name nor a keyword establishes legitimacy.

### Verification

Before handing over product output, read it for indirect workflow leakage and inspect
rendered content. Confirm use and documentation work without private working material.
Run the shared `product-isolation.md` workflow from `_shared/references/` in the selected
skill root: complete candidate tree, explicit pending commit range when known, and actual
staged contents plus the proposed message before committing. Report existing violations
explicitly. Do not claim history is clean without a resolved, explicit base.

The executable checks enumerate literal references, paths, complete commit file lists,
and messages. Their execution fails on findings; invoking them and judging semantics are
agent norms. Text scanning does not verify images/video or prove the absence of indirect
dependencies. Resolve findings before the dependent workflow proceeds; history rewriting,
live installation changes, and publishing require their own authorization.

## 3-Stage Progressive Structure

Junior uses a **progressive 3-stage structure** that adapts to project complexity. Projects start simple and evolve naturally as complexity emerges.

**Philosophy:** Start simple. Add structure only when it brings value. Each stage is optional transition, not forced.

### Stage 1: Simple Flat Structure (Default for New Projects)

**When:** Small projects, <10 features, single logical component

**Structure:**

```
.junior/features/
├── feat-1-auth/
├── feat-2-api/
├── feat-3-dashboard/
└── feat-4-reports/
```

**Characteristics:**
- Zero overhead, no component ceremony
- Implicit "one component" project
- Best for: Small projects, prototypes, early development
- All features at top level under `.junior/features/`

**Detection:** No `comp-*/` directories exist under `.junior/features/`

**Transition to Stage 2:** When semantic clustering detects 4-6+ features that naturally group into distinct components (e.g., backend features, frontend features, installation features). Use `/jr maintenance` to reorganize.

---

### Stage 2: Component Organization (Flat Within Component)

**When:** Multiple logical components emerge, clear feature clustering

**Structure:**

```
.junior/features/
├── comp-1-backend/
│   ├── comp-1-overview.md
│   ├── feat-1-auth/
│   ├── feat-2-api/
│   └── imp-1-refactor/
├── comp-2-frontend/
│   ├── comp-2-overview.md
│   ├── feat-3-dashboard/
│   └── feat-4-reports/
└── comp-3-installation/
    ├── comp-3-overview.md
    └── feat-5-installer/
```

**Characteristics:**
- Components group related features
- Flat within each component (no `features/` subdirectory)
- Each component has `comp-N-overview.md` with purpose, scope, feature list
- Best for: Growing projects with distinct logical areas

**Detection:** `comp-*/` directories exist under `.junior/features/`, but components do NOT have `features/` subdirectory

**Transition from Stage 1:** Run `/jr maintenance` when semantic clustering identifies natural groupings
**Transition to Stage 3:** When component grows large (>13 items) OR needs `docs/` or `specs/` directories (type mixing)

---

### Stage 3: Grouped Structure (Type-Based Organization)

**When:** Component has many items (>13) OR component needs `docs/`/`specs/` directories

**Structure:**

```
.junior/features/
└── comp-1-backend/
    ├── comp-1-overview.md
    ├── features/              # Grouped by type
    │   ├── feat-1-auth/
    │   └── feat-2-api/
    ├── improvements/          # Grouped by type
    │   └── imp-1-refactor/
    ├── bugs/                  # Component-level bugs
    │   └── bug-1-auth-issue/
    ├── docs/                  # Component-level documentation
    └── specs/                 # Component-level specs
```

**Characteristics:**
- Items grouped by type within component (`features/`, `improvements/`, `docs/`, `specs/`)
- Cleaner navigation for large components
- Optional optimization (not required)
- Best for: Complex components with many items

**Detection:** Component has `features/` subdirectory

**Transition from Stage 2:** Run `/jr maintenance` when component grows large OR when adding `docs/`/`specs/` would create type mixing

---

### Stage Detection

Commands automatically detect which stage the project is in using filesystem checks:

**Stage 1 Detection:**
- No `comp-*/` directories under `.junior/features/`
- Returns: `"stage1"`

**Stage 2 Detection:**
- `comp-*/` directories exist under `.junior/features/`
- NO `features/` subdirectory within components
- Returns: `"stage2"`

**Stage 3 Detection:**
- `comp-*/` directories exist under `.junior/features/`
- Component(s) have `features/` subdirectory
- Returns: `"stage3"`

**Performance:** Detection completes in <100ms on typical projects (<10 components, <50 features)

### Stage Detection Requirements

**Commands must detect current stage and adapt behavior accordingly.**

**Stage detection logic:**
- Returns: `"stage1"` | `"stage2"` | `"stage3"`
- Check for `comp-*/` directories under `.junior/features/`
- If components exist, check for `features/` subdirectories (Stage 3 indicator)
- Fast filesystem checks only, no content parsing

**Future stage detection (proactive):**
- Detect if action would trigger Stage 2→3 transition
- Triggers: Adding `docs/` or `specs/` to Stage 2 component, OR component >13 items
- Prompt user to run `/jr maintenance` first (cleaner to reorganize before adding)

### Component Overview Structure

**Stage 2+ components require `comp-N-overview.md` with:**
- Purpose and scope (1-2 sentences)
- Features table (ID, title, status, description)
- Improvements table (ID, title, status, description)
- Component dependencies (depends on, used by)
- Technical notes (optional)

**Commands must auto-update component overviews when features/improvements added or status changes.**

Component overview template defined in `/jr maintenance` command. Other commands reference it.

### Feature Structure

**⚠️ BEFORE creating ANY new file in .junior/features/, ALWAYS:**
```bash
# 1. List the feature directory
ls -la .junior/features/feat-N-{name}/

# 2. Read the user-stories directory
ls -la .junior/features/feat-N-{name}/user-stories/

# 3. Check for existing similar files
grep -r "export\|enhancement\|future" .junior/features/feat-N-{name}/
```

**If similar content exists, ADD TO IT instead of creating new files!**

```
.junior/features/feat-{N}-{name}/
├── feat-{N}-overview.md             # Main feature specification (NOT feature.md or README.md)
├── user-stories/                    # Implementation tasks ONLY
│   ├── feat-{N}-stories.md          # Progress tracking (NOT README.md)
│   ├── feat-{N}-story-1-{name}.md   # Individual stories
│   ├── feat-{N}-story-2-{name}.md
│   ├── feat-{N}-story-{M}-{name}.md
│   └── feat-{N}-story-future-enhancements.md  # Backlog items (if exists, ADD HERE, don't create enhancements/)
├── specs/                           # Technical specifications (numbered, if needed)
│   ├── 01-Architecture.md
│   ├── 02-API.md
│   └── 03-Database.md
└── docs/                            # Analysis, findings, validation results, technical notes
    ├── validation-*.md              # Validation reports, test findings
    ├── analysis-*.md                # Technical analysis documents
    ├── comparison-*.md              # Comparison studies
    └── implementation-*.md          # Implementation findings, lessons learned
```

**CRITICAL: user-stories/ vs docs/ separation:**
- ✅ **user-stories/**: ONLY story specifications and progress tracking
- ✅ **docs/**: Findings, validation reports, analysis, lessons learned, implementation notes
- ❌ **NEVER** put validation findings, analysis, or reports in user-stories/
- ❌ **NEVER** put story specifications in docs/

### Debugging Structure
```
.junior/debugging/dbg-{N}-{name}/
├── dbg-{N}-overview.md              # Problem, symptoms, context (NOT debug.md or README.md)
├── investigation/                   # Investigation tasks
│   ├── dbg-{N}-steps.md             # Hypotheses + plan + progress (NOT README.md)
│   ├── dbg-{N}-step-1-{name}.md     # Individual steps: hypothesis + test + findings
│   └── dbg-{N}-step-{M}-{name}.md
└── dbg-{N}-resolution.md            # Root cause + fix approach (created after investigation)
```

### Experiment Structure
```
.junior/experiments/exp-{N}-{name}/
├── exp-{N}-overview.md              # Main experiment doc (NOT experiment.md or README.md)
├── user-stories/                    # Implementation tasks
│   ├── exp-{N}-stories.md           # Progress tracking (NOT README.md)
│   ├── exp-{N}-story-1-{name}.md    # Individual stories
│   └── exp-{N}-story-{M}-{name}.md
├── findings/                        # Learning capture
│   └── exp-{N}-findings.md          # Main findings doc (NOT README.md)
└── research-links.md                # Related work
```

### Bug Structure (Nested in Features)
```
.junior/features/feat-{N}-{name}/bugs/bug-{M}-{name}/
├── bug-{M}-overview.md              # Bug description, reproduction steps, expected vs actual
└── bug-{M}-resolution.md            # Root cause, fix approach, verification
```

**Bugs are feature-specific** and nest within their parent feature. They follow the bugfix workflow (reproduce → fix → verify).

### Enhancement Structure (Nested in Features)
```
.junior/features/feat-{N}-{name}/enhancements/enh-{M}-{name}/
└── enh-{M}-overview.md              # Enhancement description, value, scope
```

**Enhancements are feature-specific** small improvements (UI polish, performance optimization, etc.) that nest within their parent feature.

### Improvements Structure (Top-Level)
```
.junior/improvements/imp-{N}-{name}/
├── imp-{N}-overview.md              # Main improvement specification
└── user-stories/                    # Implementation tasks (if needed)
    ├── imp-{N}-stories.md           # Progress tracking
    ├── imp-{N}-story-1-{name}.md
    └── imp-{N}-story-{M}-{name}.md
```

**Improvements are NOT feature-specific** and include:
- ✅ **Refactoring:** Systematic code restructuring, architectural changes
- ✅ **Performance optimization:** Speed/memory improvements with no behavior change
- ✅ **Technical debt reduction:** Cleanup, modernization, pattern updates
- ✅ **Code quality improvements:** Linting, testing, documentation
- ✅ **Library migrations:** Dependency updates, framework upgrades
- ❌ **NOT user-facing feature changes** (those are features)
- ❌ **NOT bug fixes** (those nest in features as `bugs/`)
- ❌ **NOT feature enhancements** (those nest in features as `enhancements/`)

### Numbering Convention
- **Components:** `comp-1-name`, `comp-2-name` (simple sequential, Stage 2+)
- **Component overviews:** `comp-1-overview.md`, `comp-2-overview.md` (NOT README.md)
- **Features:** `feat-1-name`, `feat-2-name` (simple sequential)
- **Debugging:** `dbg-1-name`, `dbg-2-name` (simple sequential)
- **Experiments:** `exp-1-name`, `exp-2-name` (simple sequential)
- **Improvements:** `imp-1-name`, `imp-2-name` (simple sequential, top-level)
- **Bugs:** `bug-1-name`, `bug-2-name` (sequential within each feature)
- **Enhancements:** `enh-1-name`, `enh-2-name` (sequential within each feature)
- **Stories:** `feat-1-story-1-name`, `feat-1-story-2-name` (simple sequential)
- **Debug steps:** `dbg-1-step-1-name`, `dbg-1-step-2-name` (simple sequential)
- **Story tracking:** `feat-1-stories.md`, `exp-1-stories.md`, `imp-1-stories.md` (NOT README.md)
- **Debug step tracking:** `dbg-1-steps.md` (NOT README.md)

**CRITICAL:** All files MUST use consistent naming with feature/experiment/debug/improvement/bug/enhancement/component prefix:
  - ✅ `comp-1-overview.md` (component overview, Stage 2+)
  - ✅ `comp-2-overview.md` (component overview)
  - ✅ `feat-5-overview.md` (main spec)
  - ✅ `feat-5-stories.md` (story tracking)
  - ✅ `feat-5-story-3-api-integration.md` (individual story)
  - ✅ `exp-2-overview.md` (experiment spec)
  - ✅ `exp-2-findings.md` (findings doc)
  - ✅ `dbg-1-overview.md` (debug problem description)
  - ✅ `dbg-1-steps.md` (hypotheses + investigation plan)
  - ✅ `dbg-1-step-2-check-cert.md` (individual investigation step)
  - ✅ `dbg-1-resolution.md` (root cause + fix approach)
  - ✅ `imp-3-overview.md` (improvement spec, top-level)
  - ✅ `imp-3-stories.md` (improvement story tracking)
  - ✅ `bug-2-overview.md` (bug spec, nested in feature)
  - ✅ `bug-2-resolution.md` (bug fix approach)
  - ✅ `enh-1-overview.md` (enhancement spec, nested in feature)
  - ❌ `feature.md` or `experiment.md` or `debug.md` (generic, wrong!)
  - ❌ `improvement.md` or `bug.md` or `enhancement.md` or `component.md` (generic, wrong!)
  - ❌ `README.md` anywhere in features/experiments/debugging/improvements/components (use descriptive names!)
  - ❌ `2025-10-01-story-1-setup.md` (date-prefix, wrong!)
  - ❌ `story-1-setup.md` or `step-1-name.md` (no prefix, wrong!)
