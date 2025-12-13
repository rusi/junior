# Story 13: Refactor Command Foundation

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Restructured `.junior/` organization with nested bugs/enhancements and new improvements bucket

## User Story

**As a** Junior user working on code quality
**I want** a clear organizational structure for bugs, enhancements, and improvements
**So that** work is properly categorized and tracked within appropriate contexts

## Scope

**In Scope:**
- Update `01-structure.md` rule with new organization
- Document nested bugs: `features/feat-N/bugs/bug-1/` structure
- Document nested enhancements: `features/feat-N/enhancements/enh-1/` structure
- Document new top-level `improvements/imp-N/` bucket
- Clarify improvements cover: refactoring, optimization, tech debt, code quality, library migrations (non-user-facing)
- Update Story 10 (bugfix) specification to use nested structure
- Update Story 11 (enhancement) specification to use nested structure
- Update `.cursor/commands/migrate.md` to handle Code Captain bugs/enhancements → nest under features
- Update install scripts to create only `.junior/` and `.junior/features/` directories

**Out of Scope:**
- Migrating existing bugs/enhancements (none exist yet)
- Implementing bugfix/enhancement/refactor commands themselves
- Creating example improvements

## Acceptance Criteria

- [ ] Given `01-structure.md` is updated, when developer reads it, then structure clearly shows nested bugs/enhancements and top-level improvements
- [ ] Given Story 10 spec is updated, when `/bugfix` is implemented, then bugs are created in `features/feat-N/bugs/bug-1/` structure
- [ ] Given Story 11 spec is updated, when `/enhancement` is implemented, then enhancements are created in `features/feat-N/enhancements/enh-1/` structure
- [ ] Given migrate command is updated, when converting Code Captain project with bugs, then bugs are nested under appropriate features
- [ ] Given migrate command is updated, when converting Code Captain project with enhancements, then enhancements are nested under appropriate features
- [ ] Given install script is updated, when Junior is installed, then only `.junior/` and `.junior/features/` directories are created

## Implementation Tasks

- [ ] 13.1 Read and analyze current `01-structure.md` to understand existing format and conventions
- [ ] 13.2 Update `01-structure.md` with new organizational structure:
  - Add nested bugs structure under features
  - Add nested enhancements structure under features
  - Add top-level improvements bucket with clear scope definition
  - Include directory tree examples for each structure
  - Document numbering conventions (bug-1, enh-1, imp-1)
- [ ] 13.3 Update Story 10 (`feat-1-story-10-bugfix-command.md`) specification:
  - Change bug location from `.junior/bugs/` to `.junior/features/feat-N/bugs/`
  - Update technical notes with nested structure
  - Update command examples to reflect new paths
- [ ] 13.4 Update Story 11 (`feat-1-story-11-enhancement-command.md`) specification:
  - Change enhancement location from `.junior/enhancements/` to `.junior/features/feat-N/enhancements/`
  - Update technical notes with nested structure
  - Update command examples to reflect new paths
- [ ] 13.5 Update `.cursor/commands/migrate.md` script:
  - Add logic to detect bugs in Code Captain projects
  - Add logic to detect enhancements in Code Captain projects
  - Map bugs/enhancements to appropriate features (may require user input)
  - Document migration strategy in command
- [ ] 13.6 Update install scripts (`scripts/install-junior.sh` and `scripts/install-junior.ps1`):
  - Remove automatic creation of bugs/, enhancements/, research/, experiments/, etc.
  - Keep only `.junior/` and `.junior/features/` creation
  - Document that commands create other directories as needed

## Technical Notes

### New `.junior/` Structure

```
.junior/
├── features/              # Feature specifications (numbered: feat-1-name, feat-2-name)
│   └── feat-N-name/
│       ├── feat-N-overview.md
│       ├── user-stories/
│       ├── specs/
│       ├── bugs/          # NEW: Nested bugs within features
│       │   └── bug-1-name/
│       │       ├── bug-1-overview.md
│       │       └── bug-1-resolution.md
│       └── enhancements/  # NEW: Nested enhancements within features
│           └── enh-1-name/
│               └── enh-1-overview.md
├── improvements/          # NEW: Top-level improvements bucket
│   └── imp-N-name/
│       ├── imp-N-overview.md
│       └── user-stories/
├── debugging/             # Debug investigations (unchanged)
├── experiments/           # Experiments (unchanged)
├── research/              # Technical research (unchanged)
├── decisions/             # Architecture Decision Records (unchanged)
├── docs/                  # Reference documentation (unchanged)
└── ideas/                 # Product ideas (unchanged)
```

### Improvements Bucket Scope

**Improvements include:**
- ✅ Refactoring (systematic code improvements, architectural restructuring)
- ✅ Performance optimization (no behavior change)
- ✅ Technical debt reduction
- ✅ Code quality improvements
- ✅ Library/dependency migrations
- ✅ Pattern modernization
- ❌ **NOT user-facing feature changes** (those are features)
- ❌ **NOT bug fixes** (those nest in features)
- ❌ **NOT feature enhancements** (those nest in features)

### Migration Strategy for Code Captain

When migrating from Code Captain, bugs and enhancements need feature association:

**Option 1: User specifies during migration**
- Prompt: "bug-1-login-issue → which feature? [feat-1-auth | feat-2-dashboard | create-new-feat]"

**Option 2: Auto-detect from content**
- Parse bug/enhancement descriptions for feature keywords
- Suggest mapping, allow user override

**Option 3: Create temporary "legacy" feature**
- Create `feat-X-legacy-bugs/` and `feat-X-legacy-enhancements/` as intermediate
- User can reorganize later

**Recommendation for Story 13:** Document Option 1 in migrate command (user-driven mapping). Actual implementation happens when migrate command is built.

### Install Script Changes

**Before (created many directories):**
```bash
mkdir -p .junior/{features,bugs,enhancements,research,experiments,debugging,decisions,docs,ideas}
```

**After (minimal creation):**
```bash
mkdir -p .junior/features
```

Commands create their own directories:
- `/research` creates `.junior/research/`
- `/experiment` creates `.junior/experiments/`
- `/refactor` creates `.junior/improvements/`
- `/bugfix` creates `.junior/features/feat-N/bugs/`
- `/enhancement` creates `.junior/features/feat-N/enhancements/`

## Testing Strategy

**TDD Approach:**
- Write updated documentation first
- Review for consistency and clarity
- Verify all cross-references are correct
- Test that updated specs make sense for future implementation

**Validation:**
- Read updated `01-structure.md` - structure is clear and comprehensive
- Read updated Story 10 - bugfix command will create nested bugs
- Read updated Story 11 - enhancement command will create nested enhancements
- Read updated migrate command - handles bugs/enhancements migration
- Check install scripts - only create minimal directories

**Manual Testing (for future stories):**
- When implementing Story 10, verify bugs are created in correct nested location
- When implementing Story 11, verify enhancements are created in correct nested location
- When implementing Story 14, verify improvements are created at top level
- When running migrate, verify Code Captain bugs/enhancements are properly nested

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] `01-structure.md` updated with complete new structure
- [ ] Story 10 specification reflects nested bugs structure
- [ ] Story 11 specification reflects nested enhancements structure
- [ ] Migrate command documentation includes bugs/enhancements handling
- [ ] Install scripts updated to minimal directory creation
- [ ] All cross-references in documentation are correct
- [ ] Structure is clear, consistent, and follows Junior's principles
- [ ] No regressions in existing features
- [ ] **Foundation ready for Story 14 (refactor command) implementation**

