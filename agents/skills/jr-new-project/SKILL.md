---
name: jr-new-project
description: Run `/jr-new-project` to create a repository with a committed project brief ready for a fresh coding session.
---

# New Project

## Purpose

Prepare a new project repository and carry the available intent into a fresh coding session. Repository preparation ends at a committed, self-contained brief; `/jr-init` owns product discovery, its approval contract, planning documents, and development setup.

## Type

Direct execution. An explicit request to create the project authorizes its local folder, Git initialization, baseline commit, and handoff commit. Ask only for missing inputs or authority, conflicting destination state, or a separately gated operation. Respect the source workspace's write and Git boundaries.

## Inputs

- Project name and destination directory, supplied or established from the conversation and local conventions.
- Available project intent, research, accepted decisions, constraints, and existing assets.
- Intended coding runtime and session mode when known.

## Process

### 1. Orientation

Track destination verification, repository preparation, brief preparation, and handoff verification with the runtime's progress tool when available.

Read the supplied sources before asking questions. Inspect the destination and applicable instructions, its parent if absent, and any existing project or planning material. Resolve aliases and filesystem identity, including case differences, before deciding whether a repository already exists. State the exact destination and planned outputs before writing.

Use `/jr-init` for product definition in an existing project home. An established repository with active planning keeps that planning authority and its actual next command; do not restart it or create a competing brief. For incomplete preparation, resume only the missing work after inspecting files, commits, and staged changes.

### 2. Repository Preparation

Verify the target Git root, including enclosing repositories and worktrees. Never initialize or commit against a parent repository by accident. An absent destination may be created once its location is established. If a new nested repository would be intentional but was not requested, resolve that boundary first.

Establish the initial branch from the user's convention or configured default. Verify usable Git author identity and signing requirements; missing configuration is a blocker, not permission to invent an identity, change global settings, or bypass signing. Preserve existing branches and history.

For a new repository with no existing files, initialize Git at the verified root, create an empty `.gitignore`, and commit only that file with message `initial commit`. Apply [product isolation](../_shared/references/product-isolation.md) before this product write and commit: read the complete candidate tree, inspect actual staged bytes and paths, and validate the exact message. Verify the resulting root commit contains only the zero-byte `.gitignore` and the intended message.

Existing or partially prepared destinations retain their contents. Inspect a nonempty directory, an existing ignore file, dirty state, or staged entries before narrowing the operation. Never truncate `.gitignore`, stage unrelated files, fabricate the baseline retrospectively, or rewrite history. Reuse a verified baseline without duplicating it; record a differing existing baseline honestly. Ask only when ownership or the safe scope remains unclear.

### 3. Runtime Readiness

Read the receiving `/jr-init` entry skill and check that the intended runtime can discover its installed rules and skills from the destination. Prefer a compatible existing installation; do not copy global instructions or handwrite installation substitutes. If installation is absent or incompatible, use `/jr install` only under that workflow's authorization requirements, or report installation as a remaining prerequisite.

Filesystem discovery is evidence of available assets, not proof that a fresh runtime loaded them. Distinguish those claims in the handoff.

### 4. Project Brief

Write `.junior/research/project-brief.md` using the Output Spec below. Add a separate, linked context file in the same directory only when substantial necessary material warrants it. Refine an existing matching brief instead of duplicating it, preserving user content and accepted decisions.

Carry enough substance for an agent with only this repository to begin. Follow useful references, distinguish confirmed decisions from recommendations, and retain unresolved product questions for `/jr-init`; do not force its discovery interview into this setup workflow. Record material evidence limits without claiming old research verifies current behavior.

Do not create mission, roadmap, stack, development-environment, or placeholder product files. Do not select a license, generate application scaffolding, create a remote, or push as setup ceremony.

### 5. Handoff Commit

Read the saved brief and any linked context from disk. Apply [product isolation](../_shared/references/product-isolation.md), including the complete-tree and semantic review, before staging explicit reviewed paths. Keep working material separate from product and runtime files. If installation produced files, review and group those under the installation workflow before proceeding; never sweep them into the brief commit.

Require the complete candidate commit file list to equal the reviewed handoff paths; explicit staging alone does not exclude pre-existing staged files. Preserve unrelated staged state and stop the commit if it cannot be safely excluded without changing that state. Use a descriptive handoff commit message and the shared staged check with that exact message. Inspect the resulting commit's actual files and message, run the required single-commit range check when it has a parent, and verify the brief is readable from `HEAD`. Do not alter or restage unrelated content to obtain a clean status.

### 6. Cold Start

Verify the destination, Git root, branch, baseline disposition, committed input paths, and working-tree status. A newly prepared repository is ready only when its intended files are committed, status is clean, and runtime prerequisites are satisfied. For a resumed destination with unrelated changes, report their disposition and whether the selected session mode safely carries the required inputs; never describe it as clean.

For a new project, give this prompt for a **new coding session in the verified directory**:

`/jr-init — read .junior/research/project-brief.md; use confirmed decisions as inputs, resolve the marked open questions, and present the initialization contract before generating the project.`

The brief is explicitly named because `.junior/research/` is not assumed to load automatically. A fresh worktree must start from a revision containing the handoff commit; an untracked local file or a commit on another branch is not sufficient. If launch tooling is available, use it only when the user explicitly requests a new session and the target directory, revision, and inputs can be carried correctly. Otherwise provide the directory and prompt without claiming a session was started.

If preparation is blocked, name the actual saved location, completed state, exact blocker, and remaining action. Do not call an uncommitted brief or an undelivered transfer ready, and never claim product initialization ran.

## Output Spec

Baseline: [artifact output spec](../_shared/references/artifact-output-spec.md). Classify `.gitignore` as product configuration, installation-managed files as runtime assets, and the brief and optional context as working material under `01-structure.md`.

### Baseline

**For:** version control and the next developer; establishes a minimal recoverable repository.

**Goes in:** a zero-byte `.gitignore` and its `initial commit`, only for a new empty repository.

**Never goes in:** guessed stack exclusions, credentials, unrelated files, planning references, attribution trailers, or invented history.

### Project Brief

**For:** the receiving coding agent; answers what is known about the intended product and what still needs resolution.

**Goes in:** purpose and users; current pain and desired outcome; confirmed initial scope, later ambitions, and product exclusions kept distinct; accepted constraints and decisions; success or stop conditions; open decisions; existing assets, usable source URLs or repository-relative references, integration risks, and material evidence limits. Optional context expands necessary research rather than repeating the brief.

**Never goes in:** private source-workspace paths or note syntax, transcripts, credentials, unrelated personal circumstances, invented approvals, prewritten framework-owned product plans, implementation scaffolding, source-scan narration, provenance stamps, compliance paperwork, counts of material reviewed, superseded plans, or resolved-question history. Source citations and evidence limitations serve product decisions, not a recap of how the agent found them.

### Completion Message

**For:** the operator opening the next coding session; answers where to start and what remains blocked.

**Goes in:** exact destination, clickable brief path, concise verified preparation state, material prerequisites or limitations, and the receiving prompt with its session venue.

**Never goes in:** research recaps, command transcripts, rule-compliance narration, counts of files scanned, or claims of installation, runtime loading, session creation, or product initialization that were not verified.

Headings are noun labels — never sentences, questions, or conversational phrases. Prose states facts. No editorial lead, no anthropomorphising, no dramatic adjective.

## Tool Integration

Use the runtime's search and file tools for source reading and writes, shell tools for filesystem and Git inspection and commits, and progress tracking when available. Use the actual Junior installation workflow for runtime setup. A session launcher is optional and requires explicit user authorization.

## Examples

- `/jr-new-project — create the project at <destination> from the decisions in this conversation.`
- `/jr-new-project — resume repository preparation at <destination>; preserve the existing files and history.`
