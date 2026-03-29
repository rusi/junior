---
name: jr
description: Operate the Junior system itself across install, update, sync, migrate, and maintenance workflows. Use when user requests `/jr <subcommand>` or asks to manage Junior rules/skills/framework files.
---

# Junior

## Purpose

Provide one canonical meta-skill for Junior framework operations.

## When to Use

- User asks to install or update Junior in a repository.
- User asks to sync framework changes back to the source repo.
- User asks to migrate legacy structure to current Junior conventions.
- User asks to reorganize/normalize Junior artifacts.
- User invokes `/jr <subcommand>`.

## Supported Subcommands

- `install`
- `update`
- `sync`
- `migrate`
- `maintenance`

## Command Forms

- Preferred: `/jr <subcommand>`

## Dispatch (Progressive Disclosure)

1. Parse subcommand from user intent.
2. Load only the matching subcommand workflow.
3. Execute exactly that workflow and report outputs.

Subcommand workflow map:

- `sync` -> `references/subcommands/sync.md`
- `migrate` -> `references/subcommands/migrate.md`
- `maintenance` -> `references/subcommands/maintenance.md`

For `install` or `update`:

- use bootstrap commands as authoritative implementation:
  - macOS/Linux: `curl -LsSf https://rusi.github.io/junior/install.sh | sh`
  - Windows PowerShell: `irm https://rusi.github.io/junior/install.ps1 | iex`
- if running inside the Junior repository, `scripts/install-junior.sh` and `scripts/install-junior.ps1` are acceptable local equivalents.
- report exact files installed/updated/skipped.

Post-install/update conflict-resolution validation (required):

- [ ] Preflight executes first: required rule files are read in order before other work starts.
- [ ] First response includes one welcome line from the approved Junior greeting list.
- [ ] Greeting line is treated as operational status marker (persona active), not filler/chitchat.
- [ ] If style-level conflict appears, Junior still enforces core behavior:
  - rigorous reasoning and evidence-first debugging
  - direct pushback on weak assumptions
  - simplicity/DRY bias in implementation decisions
  - execution discipline (plan, verify, test, complete)
- [ ] No loss of critical principles due to style constraints (identity preserved in decisions and output quality).

Pass criteria:
- Greeting/status marker appears.
- Core principles are clearly visible in decisions/actions.
- No regression in quality gates, verification, or completion discipline.

If subcommand is missing or ambiguous:

- ask one focused question with 2-4 concrete options.

## Safety Requirements

- Apply git safety before broad mutation: `../_shared/references/git-safety.md`.
- Do not overwrite user-customized files silently.
- Present approval gates before destructive or high-blast-radius operations.

## Output Requirements

- Show selected subcommand and why.
- Show files changed (created/updated/deleted).
- Show verification checks run.
- Recommend next action.
