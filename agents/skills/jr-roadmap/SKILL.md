---
name: jr-roadmap
description: Run `/jr-roadmap` to re-sequence the product roadmap by feature layer, then sync the product docs that follow from it.
---

# Jr Roadmap

## Purpose

Update and refine roadmap direction at the product level. Focus on feature layers, dependency-aware sequence, priorities, and non-goals. Do not create or redefine feature specs, stories, or tasks.

## Type

Contract-style - Clarification loop, then contract approval, then generation

## When to Use

- Product priorities changed and roadmap needs alignment.
- Roadmap should be reorganized by layers and sequence.
- Existing roadmap is timeline-heavy and needs timeline-free structure.
- High-level product docs need roadmap-consistent updates.

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan` with JSON list:

```json
{
  "todos": [
    {"id": "scan-roadmap-docs", "content": "Scan and classify roadmap-relevant docs", "status": "in_progress"},
    {"id": "clarify-direction", "content": "Clarify roadmap direction one question at a time", "status": "pending"},
    {"id": "create-contract", "content": "Present roadmap update contract", "status": "pending"},
    {"id": "apply-updates", "content": "Update roadmap and sync related docs", "status": "pending"},
    {"id": "validate-boundaries", "content": "Validate no timeline and no feature/story authoring", "status": "pending"}
  ]
}
```

### Step 2: Discover Candidate Files

Scan these locations:
- `.junior/product/**`
- `.junior/features/**` (read-only for roadmap gap detection)
- top-level `README.md`
- `docs/**`

Classify each file:
- In-scope: roadmap/product-definition/mission-direction docs
- Out-of-scope: implementation, feature specs, story/task planning docs

From `.junior/features/**`, read feature overviews and component overviews to detect:
- features or improvements added but not reflected in roadmap direction
- sequencing or dependency mismatches between roadmap and feature inventory

Use this inventory for roadmap alignment analysis only.
Do not edit feature/story artifacts in this command.

If `.junior/product/02-roadmap.md` is missing:
- Mark it as a planned output file.
- If `.junior/product/` does not exist, recommend running `/jr-init` first.
- Creation follows the same clarification + contract + approval flow as updates.

### Step 3: Clarification Loop

Use the shared discovery loop at:
- `../_shared/references/product-roadmap-definition-loop.md`

Execution requirements for `jr-roadmap`:
- Use the `roadmap` profile (timeline-free sequence-and-scope variant).
- Ask one focused question at a time until ~95% clear on roadmap direction.
- Cover problem/user/value alignment, layer placement, sequence/dependencies, priorities, and non-goals.
- Use `.junior/features/**` inventory gaps as clarification inputs.
- If roadmap direction conflicts with current product definition, resolve the conflict before contract lock.
- Capture these mandatory planning artifacts during clarification:
  - overall vision/direction/goal
  - high-level feature portfolio with per-feature success criteria
  - per-feature `/jr-feature` prompts that are ready to run
  - stage-based development plan with stage goals, focus, milestones, user-delivered value, success criteria, and risks

`/jr-feature` prompt quality is Best-only (required). Every feature prompt must include:
- clear feature outcome and user value scope
- primary constraints or exclusions (what is explicitly out)
- concrete expected outcomes (what must be true when done)
- enough specificity that `/jr-feature` can proceed with minimal clarification

### Step 4: Present Roadmap Contract

Before writing files, present:
- files to update and why each is in scope
- exact boundaries for each file
- explicit exclusions
- explicit statement: no timeline output, no feature/story/task authoring
- roadmap structure lock using:
  - `../_shared/templates/roadmap-template.md`
- explicit stage plan outline (stage names + value intent for each stage)

Approval options:
- `yes`
- `edit: <changes>`
- `no`

Do not write files until approved.

### Step 5: Apply Updates

Apply [product isolation](../_shared/references/product-isolation.md) when syncing README
or `docs/` outputs. Keep prompts, execution tracking, and planning links in the private
roadmap; product-facing documents receive only independently useful product direction.
Run the complete-tree check and semantic review after any product-document changes.

Primary file:
- `.junior/product/02-roadmap.md`

Roadmap structure is mandatory and must follow:
- `../_shared/templates/roadmap-template.md`

Required sections in `.junior/product/02-roadmap.md`:
- Product Direction (vision, strategic goal, core user value)
- Feature Portfolio (high-level features + `/jr-feature` prompt + user value + success criteria + dependencies)
- Development Plan (stage-based, no timeline) where each stage includes:
  - goal
  - focus
  - milestones (vertical slices)
  - user-delivered value
  - success criteria
  - risks and mitigations
- Cross-Stage Risks
- Roadmap Governance (review triggers + reprioritization signals)
- Boundaries

Sync related docs only if directly impacted:
- `.junior/product/01-mission.md`
- `.junior/product/03-tech-stack.md`
- `.junior/product/04-dev-env.md`
- top-level `README.md`
- roadmap-relevant product-definition docs in `docs/**`

Output constraints:
- timeline-free
- sequence-first and layer-oriented
- strategic and outcome-driven, not tactical-only
- no implementation breakdowns into stories/tasks
- use repository-relative paths only (e.g. `.junior/...`, `docs/...`), never absolute filesystem paths
- include roadmap execution tracking block with checkbox + progress sync rules from `../_shared/references/roadmap-progress-sync.md`

### Step 6: Validate Boundaries

Before completion, verify:
- no date- or timeline-based planning language
- no feature/story/task generation or redefinition
- no edits outside approved product-direction docs
- no project leakage in command guidance
- execution tracking section/checklists exist and use valid checkbox format (`- [ ]` / `- ✅`, never `- [x]`)
- all required roadmap sections from `../_shared/templates/roadmap-template.md` are present
- each stage explicitly states user-delivered value
- each feature has explicit success criteria
- each feature includes a concrete `/jr-feature` prompt line
- each `/jr-feature` prompt passes Best-only quality gate:
  - includes feature outcome + value scope
  - includes key constraints/exclusions
  - includes explicit expected outcomes
  - avoids vague phrasing ("improve", "handle", "support") without concrete behavior
  - can be executed by `/jr-feature` without major clarification loop

### Step 7: Output Spec

**Artifact 1 — `.junior/product/02-roadmap.md`, and the product docs synced with it.**

- **For:** whoever decides what to build next. Answers *what ships in what order, what each stage
  delivers, and what is deliberately not on the list.*
- **Goes in:** the sections required in Step 5 for the private roadmap; synced product docs hold only the standalone product direction relevant to their readers.
- **Never goes in:** what the clarification loop asked and answered · which files were scanned to
  find candidates · a superseded sequence kept beside the new one · sequencing that was proposed
  and cut, unless the exclusion is itself a standing non-goal, stated as one · that a contract was
  approved. Baseline: `../_shared/references/artifact-output-spec.md`.
- **Register:** headings are noun labels — never sentences, questions or conversational phrases.
  Prose states facts. No editorial lead, no anthropomorphising, no dramatic adjective.

**Artifact 2 — the completion report.** Files created or updated, what changed at roadmap level,
and the next command. A boundary check that passed is not reported; a boundary check that failed is
reported as the thing it caught, and it is fixed before completion.

Recommended next command:
- `/jr-feature` if user wants to define specific features from the updated roadmap.

## Tool Integration

Primary tools:
- `todo_write` or `functions.update_plan` - Progress tracking
- `list_dir` or `functions.shell_command` - Scan docs and classify files
- `read_file` or `functions.shell_command` - Review candidate docs
- `write` or `functions.apply_patch` - Apply updates

## Non-Negotiable Rules

- No timeline in roadmap output.
- One focused question per turn during clarification.
- Contract approval required before file updates.
- Stay at high-level product direction and sequencing.
- Do not ask tactical execution questions (e.g., "immediate next execution gate"). Tactical next-action selection belongs to `/jr-next`, not `/jr-roadmap`.
- Clarification questions in `/jr-roadmap` must resolve strategic sequencing, portfolio scope, dependencies, and boundaries only.
- Never create or redefine feature/story/task implementation artifacts.
- Must maintain `.junior/product/02-roadmap.md` execution tracking structure per `../_shared/references/roadmap-progress-sync.md`.

---

Build roadmap direction around product value sequencing, not schedules.
