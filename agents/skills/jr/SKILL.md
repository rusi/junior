---
name: jr
description: Run `/jr` to install, update, sync, migrate, or maintain Junior framework assets and contribute feedback.
---

# Junior

## Purpose

Provide one canonical meta-skill for Junior framework operations.

## When to Use

- User asks to install or update Junior in a repository.
- User asks to sync framework changes back to the source repo.
- User asks to contribute feedback about Junior.
- User asks to migrate legacy structure to current Junior conventions.
- User asks to reorganize/normalize Junior artifacts.
- User invokes `/jr <subcommand>`.

## Supported Subcommands

- `install`
- `update`
- `sync`
- `feedback`
- `migrate`
- `maintenance`

## Command Forms

- Preferred: `/jr <subcommand>`

## Dispatch (Progressive Disclosure)

1. Parse subcommand from user intent.
2. Load only the matching subcommand workflow.
3. Execute exactly that workflow and report outputs.

Subcommand workflow map:

- `feedback` -> `references/subcommands/feedback.md`
- `sync` -> `references/subcommands/sync.md`
- `migrate` -> `references/subcommands/migrate.md`
- `maintenance` -> `references/subcommands/maintenance.md`

For `install` or `update`:

- Select the requested target (`claude`, `cursor`, or `codex`) from the active runtime or user request; ask if it is ambiguous. These examples use `codex`; substitute the selected target.
- use bootstrap commands as authoritative implementation:
  - macOS/Linux: `curl -LsSf https://rusi.github.io/junior/install.sh | bash -s -- --target codex`
  - Windows PowerShell: `& ([scriptblock]::Create((irm https://rusi.github.io/junior/install.ps1))) -Target codex`
- Default to the latest tagged release. Use `--choose-version` (`-ChooseVersion`) when the user wants to choose; `--development` (`-Development`) explicitly selects main. Do not choose development code implicitly.
- Omit a destination for global installation; add a positional project path (`-Destination` in PowerShell) for a project install. Display the version and destination before proceeding. For updates, retain the existing installation destination.
- See `references/installation.md` for loading, migration, and conflict details.
- if running inside the Junior repository, `scripts/install-junior.sh` and `scripts/install-junior.ps1` install that exact checkout with the same explicit target (`--target` or `-Target`); use them only when local-source installation is intended.
- report exact files installed/updated/skipped.
- Codex installs canonical rules in `.agents/rules` and shared skills in `.agents/skills`.
  Its full startup rules are embedded in a managed `AGENTS.md` block (and an existing
  nonempty override), with instruction capacity configured in `.codex/config.toml`.
  Use Python 3.11+ for Codex installation. Project installs require trusted project
  configuration. Preserve operator text and report retained legacy files.
- Verify rule loading in a fresh session after an update. The current session retains
  its old instruction context; file parity alone does not establish native loading.

Post-install/update conflict-resolution validation (required):

- [ ] Junior's applicable rules are in the fresh session's context, verified using the runtime-specific loading guidance in `references/installation.md`. A hook marker alone does not establish rule loading.
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

## Output Spec

**Artifact — the operations report.**

- **For:** the user deciding whether the Junior install is now in the state they wanted. It answers
  *what changed on disk, and is it sound.*
- **Goes in:** the subcommand that ran and why this one · files created, updated, and deleted, as a
  list of paths · anything a check found wrong, and whether it was fixed · the next command.
  Feedback produces the improvement proposal defined in its subcommand workflow.
- **Never goes in:** checks that passed, enumerated · the dispatch reasoning that selected the
  subcommand, beyond the one-line why · files read while deciding · the reference docs consulted.
  A verification pass that found nothing is one line, not a section.
  Baseline: `../_shared/references/artifact-output-spec.md`.
- **Register:** headings are noun labels — never sentences, questions or conversational phrases.
  Prose states facts. No editorial lead, no anthropomorphising, no dramatic adjective.

Subcommands that write project documents — `maintenance` creating `comp-N-overview.md` — follow the
template in their own reference and the same exclusion baseline: an overview holds the component's
purpose, scope, and item tables, never the clustering that proposed it or the run that reorganized.
