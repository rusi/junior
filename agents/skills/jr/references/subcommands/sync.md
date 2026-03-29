# Subcommand: /jr sync

## Junior Maintenance Subcommand

This subcommand maintains Junior framework assets.
It can be installed globally, but it must only execute in the Junior source repository.

## Purpose

Sync Junior framework edits from globally installed files back into Junior source files, then normalize and reconcile any framework changes.

Default sync direction:
- Installed global files (`~/.codex/...`, `~/.cursor/...`)
- Junior source files (`agents/...`, `cursor/...`)

## When to Use

- You edited installed Junior files while working in another project and want to bring those edits back to source.
- You want to reconcile drift between global runtime files and Junior source.
- You added or changed rules/skills and need installer/docs to match.

## Path Model

Global installed paths:
- `~/.codex/rules/`
- `~/.codex/skills/`
- `~/.cursor/rules/JUNIOR.mdc`

Junior source paths (this repository):
- `agents/rules/`
- `agents/skills/`
- `cursor/rules/JUNIOR.mdc`

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan`:

```json
{
  "todos": [
    {"id": "validate-context", "content": "Validate Junior source repository context", "status": "in_progress"},
    {"id": "inspect-global", "content": "Inspect installed global roots and metadata", "status": "pending"},
    {"id": "sync", "content": "Run sync-back or fallback mapping flow", "status": "pending"},
    {"id": "present-plan", "content": "Present post-sync normalization plan", "status": "pending"},
    {"id": "analyze", "content": "Analyze synced files for leaks and issues", "status": "pending"},
    {"id": "normalize", "content": "Normalize files after approval", "status": "pending"},
    {"id": "update-system", "content": "Update installer/docs for rule-skill changes", "status": "pending"},
    {"id": "verify", "content": "Run automated verification and report", "status": "pending"}
  ]
}
```

### Step 2: Validate Context (Hard Stop)

Confirm this is the Junior source repository:
- `agents/rules/00-junior.mdc` exists
- `scripts/junior.py` exists

If either check fails:
- refuse to run sync
- explain that `/jr sync` only runs in Junior source
- stop immediately

### Step 3: Inspect Global Installation State

Check whether global install roots exist:
- `~/.codex/rules/`
- `~/.codex/skills/`
- `~/.cursor/rules/JUNIOR.mdc`

Then check metadata:
- `~/.codex/.junior-install.json`

If global files are missing, stop and explain that no sync source is available.

### Step 4: Run Canonical Sync First

Run:

```bash
python3 scripts/junior.py sync-back
```

If successful, capture and report:
- synced files count
- skipped files count
- conflicts (if any)
- resulting `git status --short`

### Step 5: Fallback Mapping (If Metadata Missing/Invalid)

If `sync-back` cannot operate due to missing or invalid metadata, run manual mapping.

1. Build mapping by relative path:
- `~/.codex/rules/**` <-> `agents/rules/**`
- `~/.codex/skills/**` <-> `agents/skills/**`
- `~/.cursor/rules/JUNIOR.mdc` <-> `cursor/rules/JUNIOR.mdc`

2. Compare checksum/content and classify each path:
- `different`
- `global_only`
- `source_only`
- `same`

3. Present explicit proposal before writing:
- default copy set: `different` + `global_only` from global -> source
- never auto-delete `source_only`

4. Apply only approved copy actions.

### Step 6: Analyze for Leaks and Issues

After sync, inspect changed source files for:
- project-specific leakage (class names, module names, domain terms)
- hardcoded local paths that should be generic
- stale references to old directories or command names
- broken links between skills/rules/templates/references

Use `read_file` + `grep` and capture findings with file path + concrete line context.

Mandatory leak audit (semantic, required):

1. Semantic scope review of every newly added instruction block:
- could this instruction apply to most Junior users/projects unchanged?
- does it enforce one product's UI flow/domain model (example: context-switch matrices tied to one app, domain-specific lifecycle rules)?
- does it mandate app-specific page types or business entities not part of Junior core operations?
- is the rule framed as a one-project incident response rather than framework policy?

2. Optional supporting scan (non-gating):
- Use regex/keyword search only as supporting evidence collection.
- Never treat a clean regex result as proof of "no leaks".

If any semantic answer indicates project specificity, mark as a leak candidate.

Output contract for Step 6:
- Provide `findings` grouped as `confirmed leak`, `leak candidate`, `clean`.
- For each candidate, include:
  - file path
  - line context
  - why it is likely project-specific
  - proposed action (`remove`, `generalize`, `keep with rationale`)

### Step 7: Present Normalization Plan

Provide a concise plan before edits:
- files with leaks/issues
- exact normalization actions
- installer/docs updates needed (if rules/skills were added/renamed/removed)

Ask for approval if normalization is non-trivial.

Hard gate:
- If any `confirmed leak` or `leak candidate` exists, do not conclude sync as "clean".
- Require explicit user decision per flagged block before finalizing.

### Step 8: Normalize Files After Approval

Apply targeted fixes:
- remove or generalize project-specific references
- repair broken links and path references
- keep command behavior and important instruction detail intact

### Step 9: Update Installer and Documentation System

When rules/skills changed, update system metadata:
- `scripts/install-config.json` entries
- `README.md` command/rule references (and other canonical docs if needed)

Rules:
- keep `/jr sync` behavior documented as source-repo-only execution
- do not silently drop commands from installer/docs

### Step 10: Automated Verification

Run checks:
1. Semantic leak checklist replay on all flagged diff hunks (must be empty or explicitly approved)
2. Config validation (`scripts/install-config.json` parses)
3. Reference checks for changed skill/rule paths
4. Final `git status --short` scope check

Expected:
- changed files limited to Junior source maintenance paths (`agents/`, `cursor/`, supporting docs/scripts)
- no unrelated application code edits
- no unresolved leak candidates

### Step 11: Completion Guidance (Required)

Always end with:
- synced file summary (count + key paths)
- leak/normalization summary
- installer/docs update summary
- verification summary
- recommended next step: run `/jr-commit` in Junior source

## Tool Integration

Primary tools:
- `todo_write` or `functions.update_plan` - Progress tracking
- `run_terminal_cmd` / `functions.shell_command` - Sync and verification commands
- `read_file` - Inspect metadata and changed files
- `grep` - Leak detection and reference checks
- `search_replace` / `functions.apply_patch` - Targeted normalization edits

## Guardrails

- Execute only in Junior source repository.
- Keep writes scoped to Junior maintenance files.
- Treat sync as controlled copy + normalization with explicit review.
