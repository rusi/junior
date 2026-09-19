# Working on Junior

These instructions govern contributions to Junior itself. They are not installed into
projects that use Junior. Paths below are relative to this source checkout.

## Source of Truth

- Edit portable rules in `agents/rules/`, skills in `agents/skills/`, and Claude's installed
  contract in `agents/contracts/claude.md`. Cursor's `.mdc` rules are rendered from the
  same Markdown rule sources; there is no separate Cursor rule source tree.
- Keep installer behavior and its assets consistent. `scripts/install-config.json` defines
  the installed targets; `scripts/junior.py` implements installation, update, and sync.
- Installed runtime copies are not authoring sources. Reconcile installed edits through
  `/jr sync` before updating; see the README for scope-specific update protections.
  For requests naming an installed path, find and edit its matching source under `agents/`.
- Changing a source rule does not reload the running session. Propagate changes through
  the appropriate Junior installation workflow when requested, then start a fresh session.
- Source maintenance changes stay in this checkout; do not mirror edits into global or
  installed copies. Installation, update, and sync are separate, explicitly requested
  workflows governed by `/jr`.
- When adding or renaming commands, update the root `README.md` command documentation.
  Installation listings derive from shipped `agents/skills/*/SKILL.md` entries;
  `scripts/install-config.json` retains explicit runtime installation mappings.

## Runtime Entry Points

- Codex and Cursor read this root `AGENTS.md`; Claude reads it through root `CLAUDE.md`.
- These contributor instructions do not require a global Junior installation and do not
  assume any runtime's installed rule paths or startup hooks.
- When Junior is installed, its runtime rules govern how the assistant works; this file
  identifies the source files to change when the work is on Junior itself.

## Verification

- Validate installer changes in disposable homes and projects for Claude, Codex, and Cursor.
  Cover installation, update, and sync-back without altering the operator's live installation.
- Preserve user-owned instructions and installed edits; test migration behavior as well as
  fresh installs. Never overwrite repository guidance with an installed contract.
- Use the repository's test runner when available. Keep tests and tracking out of installed
  assets, and keep public instructions self-contained within the exported source tree.
- Keep shared contributor guidance here. Runtime adapters should reference it, not copy it.
