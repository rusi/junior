---
name: jr-init
description: Initialize or re-initialize project direction with a contract-style workflow that defines product mission, roadmap, technical foundation, and development environment before implementation starts. Use for new projects, unclear strategy, stale planning docs, or when `/jr-init` is requested.
---

# Jr Init

## Purpose

Define product vision and document technical foundation. Focus on delivering USER VALUE through SIMPLICITY. This is about understanding WHAT you're building and WHY before thinking about HOW.

## Type

Contract-style (clarification -> contract -> approval -> generation)

## When to Use

- Starting a new project and need to define product direction.
- Existing project lacks clear vision or technical documentation.
- Need to articulate product value and technical strategy.
- Team needs aligned scope before `/jr-feature` and `/jr-implement`.

## Process

### Step 1: Initialize Progress Tracking

```json
{
  "todos": [
    {"id": "detect-project", "content": "Detect new vs existing project and git status", "status": "in_progress"},
    {"id": "product-discovery", "content": "Product discovery with USER VALUE focus", "status": "pending"},
    {"id": "tech-analysis", "content": "Tech stack analysis/recommendations", "status": "pending"},
    {"id": "create-contract", "content": "Present initialization contract", "status": "pending"},
    {"id": "generate-docs", "content": "Generate product and tech documentation", "status": "pending"},
    {"id": "finalize", "content": "Present completion and next steps", "status": "pending"}
  ]
}
```

### Step 2: Project Detection and Git Check

Scan current directory:

- Dependency files: package manifests and build files.
- Source directories: `src/`, `lib/`, `app/`, `pkg/`, `internal/`, `components/`, `modules/`, `docs/`.
- Git repository: `.git/`.
- Existing documentation: `README.md`, `docs/`, `.junior/product/`.
- Junior structure: `.junior/`.

Classification:

1. New Project
- Empty or minimal files (roughly <5 non-config files)
- No dependency files or source code
- `.junior/` may exist from installation
- Outcome: define product vision, recommend stack, create documentation

2. Existing Project
- Has dependency files and/or source code
- May have existing documentation (including `.junior/product/`)
- Outcome: define/refine product vision, document/analyze stack, update docs

Git check (mandatory):

- Run `git status`.
- Apply `../_shared/references/git-safety.md` before broad writes.

If NOT a git repository:

```text
⚠️ Git Repository Required

This project is not a git repository.

Git is REQUIRED for:
- Version control
- Collaboration
- Junior workflow tracking

Initialize git now? [yes | no]
```

If yes, initialize git repository.

If uncommitted changes exist:

```text
⚠️ Uncommitted changes detected.

Scope check:
- Review changed paths from `git status --short`.
- If changes are clearly isolated from initialization scope, recommend proceeding.
- If changes touch related areas or scope is unclear, ask for explicit override.

Default: use `/jr-commit` first.
Override: If you confirm the changes are unrelated, reply `override: proceed`.
```

Proceed only if:

- Working directory is clean, or
- You recommend proceeding based on isolated scope, or
- User explicitly confirms override with `override: proceed`.

Present detection:

```text
Project Detection

Type: [New Project | Existing Project]
Git: [Repository exists | Created new repository]

[If Existing Project]
Detected:
- Language: [detected or "Unknown"]
- Framework: [detected or "None detected"]
- Project type: [web app / API / CLI / library / docs-only / other]

Existing Documentation:
- README.md: [exists/missing]
- .junior/product/: [exists/empty]

Proceed? [yes | override: {new|existing}]
```

Tool note:

- If tool choice is ambiguous in the current runtime, use `../_shared/references/tool-selection.md`.

### Step 3: Product Discovery

Use the shared discovery loop at:
- `../_shared/references/product-roadmap-definition-loop.md`

Execution requirements for `jr-init`:
- Use the `init` profile (includes initial-slice and product-horizon scope questions).
- Preserve the one-question rule.
- Challenge vague responses and complexity exactly as defined in the shared loop.
- Continue until 95% clarity before proceeding.
- Do not proceed to tech stack until product direction is crystal clear.

### Step 4: Tech Stack Analysis

After product is clear, address technical foundation.

Tech stack questions:

1. Project Type (infer from product description, confirm with user)
- "Based on what we're building, this seems like a [web app/API/CLI/library/docs-only]. Correct?"
- Web application (frontend + backend)
- API service (backend only)
- CLI tool (command-line)
- Library/package (reusable code)
- Desktop application
- Mobile application
- Documentation project
- Embedded system
- Other

2. For New Projects: "Tech stack preferences or constraints?"
- Team expertise (languages/frameworks known)
- Platform requirements (Windows/Mac/Linux/cross-platform)
- Integration needs (must work with existing systems)
- Recommend based on: product needs + team expertise + simplicity

3. For Existing Projects: "Confirm detected stack?"
- Show detected language, framework, tools
- Ask about architecture pattern and design patterns used
- Ask about pain points or planned changes
- Scan codebase for patterns, technical debt, gaps

Analyze existing codebase (for existing projects):

Use `codebase_search` or `functions.shell_command` and `grep` (via `functions.shell_command`) to identify:

- Missing technical documentation: areas lacking docs or clarity
- Inconsistent code patterns: where patterns vary or break down
- Technical debt and improvement opportunities: duplication, complexity, outdated approaches
- Testing coverage gaps: untested code, missing integration tests
- Development workflow improvements: build, deploy, local dev issues
- Architecture optimization opportunities: bottlenecks, scaling concerns, modularity
- Design patterns used: identify patterns (or lack thereof) in codebase

Recommendations based on:

- Product needs: real-time -> WebSockets, data-heavy -> database, simple -> minimal stack
- Simplicity: fewer dependencies, established tools, clear patterns
- Team: use what team knows unless strong reason to change
- Scale: match complexity to actual need (prototype != production)

Present analysis:

- Current/recommended stack with rationale
- Alternatives considered and why not chosen
- Development environment (local/Docker/cloud)
- Key dependencies and why needed

### Step 5: Present Initialization Contract

Before writing files, present contract using `templates/init-contract-template.md`.

Contract must include:

- project type
- problem, user, value proposition
- core capabilities (<=3)
- primary success metric
- initial slice target and long-term product horizon
- initial-slice non-goals and product-level exclusions
- Include both "initial slice" and "long-term horizon".
- Non-goals must be phase-scoped or product-exclusion scoped.
- If user states a long-term capability, it cannot appear in non-goals.
- technical foundation and rationale
- exact files to generate/update

Approval options:

- `yes`
- `edit: <changes>`
- `simpler`
- `challenge`

Do not generate files until approval.

### Step 6: Generate Product Documentation

Generate/update using templates:

- `templates/mission-template.md` -> `.junior/product/01-mission.md`
- `../_shared/templates/roadmap-template.md` -> `.junior/product/02-roadmap.md`
- `templates/tech-stack-template.md` -> `.junior/product/03-tech-stack.md`
- `templates/dev-env-template.md` -> `.junior/product/04-dev-env.md`
- `templates/readme-template.md` -> `README.md`

Template fidelity rules:

- Keep all major sections from each template.
- Use concrete project-specific content (no unresolved placeholders).
- Preserve vertical-slice guidance in roadmap.
- Include actionable setup/commands in dev-env output.
- Keep README focused on value, quick start, and doc links.
- Stamp dates consistently.

### Step 7: Generate Real Project Files (Critical)

Principle: generate ACTUAL files, not only documentation.

Common project files to generate (adapt to stack):

1. Build automation
- `Makefile`, task runner, or equivalent

2. Environment templates
- `.env.example` with inline comments

3. IDE configuration (if user requested/needed)
- format/lint/type-check settings
- extensions/debug configs

4. Development scripts
- setup/dependency/util scripts

5. Container/dev infra config (if applicable)
- `docker-compose.yml`, `Dockerfile`, local services

6. `.gitignore` updates
- environment files
- build artifacts
- IDE files
- dependency directories

Decision framework:

- CREATE FILE if configuration/template/executable.
- DOCUMENT ONLY if explanation/reference/guidance.

Examples:

- Wrong: put Makefile content only in docs.
- Right: create `Makefile` and reference it.
- Wrong: list env vars only in markdown prose.
- Right: create `.env.example` with comments.

### Step 8: Completion Summary

Present a completion summary with this structure:

```text
✅ Project Initialized

Product Documentation Created/Updated:
- .junior/product/01-mission.md
- .junior/product/02-roadmap.md
- .junior/product/03-tech-stack.md
- .junior/product/04-dev-env.md

Project Documentation:
- README.md [created/updated]

Project Files Generated:
- [list actual files generated]

Clarity Achieved:
- Clear problem and users
- Focused value proposition
- Bounded scope (<=3 core capabilities)
- Measurable success criteria
- Technical foundation documented

Ready to build with purpose.

Next Steps:
1. Review `.junior/product/01-mission.md`
2. Run `/jr-feature "first core capability"`
3. Run `/jr-implement` after feature scope approval
```

### Step 9: Tool Integration

Primary tools:

- `functions.update_plan` (or equivalent todo tracking) - progress tracking
- shell/list/find/rg tools - project detection and scanning
- search/read tools - analyze existing docs/code
- edit/apply-patch/write tools - generate docs/files
- shell commands - git/date operations

Example commands:

```bash
git status
git init
date +"%Y-%m-%d"
```

## Non-Negotiable Rules

- Ask one focused discovery question at a time.
- Keep V1 constrained to essential user value.
- Challenge unnecessary complexity.
- Use explicit approvals before generation.
- Produce concrete deliverables; avoid status-only prose.

---

Focus: USER VALUE through SIMPLICITY. Define WHAT and WHY before HOW.
