# Story 7: Implement /init Command

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None (but better to implement after core workflow is working)
> **Deliverable:** Working /init command that bootstraps new projects with Junior setup combining technical and product initialization

## User Story

**As a** developer starting a new project
**I want** to bootstrap the project with Junior's structure and initial planning
**So that** I can quickly set up development environment and establish project direction

## Scope

**In Scope:**
- Create `.cursor/commands/init.md` command specification
- Detect greenfield (new) vs brownfield (existing) projects
- For greenfield: technical setup + product planning combined
- For brownfield: Junior structure setup only (respect existing codebase)
- Create `.junior/` structure with initial documentation
- Contract-first approach for both technical and product aspects
- Technology recommendations based on project type

**Out of Scope:**
- Automatic code generation or scaffolding
- CI/CD pipeline setup
- Cloud deployment configuration
- Team collaboration tool integrations

## Acceptance Criteria

- [ ] Given an empty directory, when user runs `/init`, then it's detected as greenfield and both technical + product planning is offered
- [ ] Given an existing codebase, when user runs `/init`, then it's detected as brownfield and Junior structure is added without disrupting existing code
- [ ] Given greenfield initialization, when contract is approved, then `.junior/` structure is created with tech-stack.md, README.md, and initial docs
- [ ] Given product planning is included, when complete, then `.junior/docs/mission.md` captures project vision and goals
- [ ] Given initialization completes, when user runs `/status`, then project structure is recognized and ready for `/feature`
- [ ] Given technical setup, when tools are recommended, then they match project type and scale requirements

## Implementation Tasks

- [ ] 7.1 Research `reference-impl/cursor/commands/initialize.md` and `plan-product.md` for bootstrap patterns
- [ ] 7.2 Run `/new-command` with prompt: "Create init command that combines technical setup (initialize) and product planning (plan-product). Detects greenfield (new) vs brownfield (existing) projects. For greenfield: asks technical stack + product vision questions, creates tech-stack.md, mission.md, and README.md. For brownfield: adds Junior structure to existing project. Creates `.junior/` directories and initial documentation. Implements feat-1-story-7."
- [ ] 7.3 User review: Test greenfield workflow (empty directory), verify complete initialization
- [ ] 7.4 User review: Test brownfield workflow (existing project), verify Junior adds safely
- [ ] 7.5 Refine questions and templates based on clarity and usefulness
- [ ] 7.6 Finalize: Verify both workflows complete successfully

## Technical Notes

**Command Structure:**

```markdown
# Init Command

## Purpose
Bootstrap new projects with Junior's development structure, combining technical setup and product planning.

## Process

### Step 1: Project Detection
- Scan current directory for indicators:
  - package.json, requirements.txt, Cargo.toml, go.mod, etc.
  - Source directories (src/, lib/, app/)
  - Git repository status
  - Existing `.junior/` or `.code-captain/` structure

- Classify as:
  - **Greenfield**: Empty or minimal files → Technical + Product setup
  - **Brownfield**: Existing codebase → Junior structure only
  - **Migration**: Existing `.code-captain/` → Redirect to `/migrate`

### Step 2: Greenfield Workflow

**Technical Foundation Questions:**
- "What type of application? (web app, API, mobile, library, CLI)"
- "Any required technologies or platforms?"
- "Development setup preference? (local, containerized, cloud)"
- "Expected scale? (prototype, small team, enterprise)"

**Product Planning Questions:**
- "What problem does this solve?"
- "Who is this for?"
- "What's the core value proposition?"
- "How will you measure success?"

**Technical + Product Contract:**
```
## Initialization Contract

**Project Type:** [web app / API / etc.]
**Technology Stack:** [Recommended stack based on type]
**Architecture:** [Monolith / Microservices / Serverless]

**Product Vision:** [One sentence value proposition]
**Target Users:** [Who this serves]
**Success Metrics:** [How you'll measure success]

**Initial Setup:**
- Create `.junior/` structure
- Generate tech-stack.md
- Generate mission.md
- Create README.md with setup instructions
- Initialize git (if not exists)
- Create .gitignore

Options: yes | edit: [changes]
```

### Step 3: Brownfield Workflow

**Simple questions:**
- "Confirm existing tech stack? [detected from package files]"
- "Add product planning docs or just Junior structure?"

**Brownfield Contract:**
```
## Junior Setup Contract

**Detected:** [Existing tech stack and structure]
**Action:** Add `.junior/` structure without disrupting codebase

**Will Create:**
- `.junior/` directory structure
- Basic documentation templates
- [Optional] mission.md if product planning requested

**Will NOT Touch:**
- Existing source code
- Existing configuration files
- Existing documentation

Options: yes | edit: [changes]
```

### Step 4: Structure Creation

Create directory structure:
```
.junior/
├── features/              # Feature specifications (empty)
├── experiments/           # Experiments (empty)
├── research/              # Research docs (empty)
├── prototypes/            # Prototype plans (empty)
├── decisions/             # ADRs (empty)
└── docs/
    ├── tech-stack.md      # Technology documentation
    ├── mission.md         # Product vision (if greenfield)
    └── README.md          # Junior usage guide
```

**Tech-Stack.md Template:**
```markdown
# Technology Stack

> **Project:** {Name}
> **Type:** {Type}
> **Created:** {Date}

## Core Technologies

**Language:** [Primary language]
**Framework:** [Main framework]
**Database:** [Database choice]

## Development Tools

**Testing:** [Test framework]
**Linting:** [Linter]
**Build:** [Build tool]

## Architecture

[Architecture pattern and rationale]

## Dependencies

[Key external dependencies]
```

**Mission.md Template (Greenfield):**
```markdown
# Project Mission

> **Created:** {Date}

## Vision

[One sentence value proposition]

## Problem

[What problem this solves]

## Target Users

[Who this is for]

## Success Metrics

[How you'll measure success]

## Core Principles

[Guiding principles for development]
```
```

**Reference Implementation:**
- Adapt from `reference-impl/cursor/commands/initialize.md` (technical)
- Adapt from `reference-impl/cursor/commands/plan-product.md` (product)
- Combine into single cohesive workflow

**Testing Strategy:**

**TDD Approach:**
- Write init.md specification
- Test detection logic with sample directory structures
- Implement greenfield and brownfield workflows
- Verify structure creation is correct

**Integration Tests:**
- Test in empty directory (greenfield)
- Test in existing project (brownfield)
- Test with existing `.code-captain/` (migration detection)
- Verify all templates are generated correctly

**Manual Testing:**
- Run `/init` in new empty directory
- Answer questions and approve contract
- Verify `.junior/` structure is created
- Test brownfield in existing project
- Ensure no disruption to existing code
- Verify `/status` recognizes initialized project

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] `/init` command file created at `.cursor/commands/init.md`
- [ ] Project detection works for greenfield and brownfield
- [ ] Greenfield workflow combines technical + product setup
- [ ] Brownfield workflow respects existing codebase
- [ ] `.junior/` structure is created correctly
- [ ] All documentation templates are comprehensive
- [ ] Technology recommendations are sensible
- [ ] Migration detection redirects to `/migrate`
- [ ] No regressions in project structure
- [ ] Code follows Junior's principles
- [ ] Documentation complete in init.md
- [ ] **User can run /init in empty directory and get complete project setup**
- [ ] **User can run /init in existing project and get Junior structure without disruption**
- [ ] Tested in both greenfield and brownfield scenarios

