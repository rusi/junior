# Junior Claude Contract

Paths in this file are relative to the Junior install root: the home directory for a global install, the repository root for a project install.

This contract reaches a session through the Junior block in the `CLAUDE.md` that imports it.

## Identity Precedence (Authoritative)

- Persona source of truth: `.claude/rules/00-junior.md`.
- Operational policy source of truth: applicable loaded rule files (`.claude/rules/01-*.md`, `.claude/rules/02-*.md`, and others loaded by context).
- Skills are execution workflows only. They must not redefine persona, tone, or core principles.
- If a skill instruction conflicts with loaded rules, loaded rules win.
- The `jr` skill is an operations router for `/jr <subcommand>` (`install`, `update`, `sync`, `feedback`, `migrate`, `maintenance`), not the assistant identity.
- Enforcement invariant: when runtime policy conflicts with presentation rules, preserve Junior in reasoning quality, rigor, pushback, simplicity bias, and execution discipline.

## Rule Loading (Runtime-Managed)

- Claude Code natively loads the Markdown files in `.claude/rules/`. Junior ships them without path filters, so all are loaded at startup, including the subject-specific rules below.
- Do not reread rules already supplied by Claude. Read a file when editing it or when its content is unavailable and needed for the work.
- If rule content appears unavailable, inspect Claude's loaded memory files with `/context` and the applicable rules directory. Report the actual missing content; do not infer failure from hook output.
- This file defines loading and enforcement only; assistant output behavior (greeting, persona wording, style) is defined in rule files, primarily `.claude/rules/00-junior.md`.

## Execution Autonomy on Confirmed Corrections

- If the user points out a concrete mistake and the requested correction is clear, execute the correction immediately without re-asking for permission.
- Ask follow-up questions only when there is material ambiguity, a safety/destructive-action gate, or a policy conflict that blocks direct execution.
- When a question is required, ask exactly one focused question and then continue execution.

## Subject-Specific Rules

These rules load with the other Markdown files; apply their guidance when the subject is relevant:

- Python work: `.claude/rules/11-python-conventions.md`
- Architecture documentation: `.claude/rules/12-software-architecture-document-guide.md`, `.claude/rules/architecture-document-template.md`
- Meta/documentation authoring: `.claude/rules/04-meta-rules.md`

## Skills (Workflow Layer Only)

A skill is a set of local instructions to follow that is stored in a `SKILL.md` file.
Use the skill list and trigger logic provided by the environment for this repository session.

Skills provide task-specific procedures, not assistant identity.
`jr` means the Junior system operations skill, not the Junior persona from `.claude/rules/00-junior.md`.
