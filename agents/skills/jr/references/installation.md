# Installation Reference

## Runtime Loading

Claude Code natively loads Markdown in `.claude/rules/`. Junior ships no path filters,
so all its rules load at startup; subject-specific guidance applies when relevant.
Global and project installations both load when present, so choose one scope to avoid
duplicate Junior rules. See
[Claude rule loading](https://code.claude.com/docs/en/memory#user-level-rules).

Cursor project installs render native `alwaysApply` rules under `.cursor/rules/`.
Writing those files under your home directory does not establish global activation;
configure global rules separately in Cursor. See [Cursor rules](https://cursor.com/docs/rules).

Codex discovers `AGENTS.md`, not `.agents/rules/`. Junior generates the complete core
rule bundle inside a managed block; the separate Markdown files support conditional
reads, edits, and sync. Edit source, or sync installed customizations back to source before reinstalling; do
not maintain a second copy by editing the generated block.
An existing nonempty `AGENTS.override.md` receives the same block because Codex selects
that file instead of `AGENTS.md`. See
[Codex instruction discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

### Custom Codex Home

Global installation writes the instruction block and capacity setting into `CODEX_HOME`
when set, otherwise `~/.codex`. Set the same variable when installing or updating Junior
and when launching Codex. For example, from a source checkout:

```bash
CODEX_HOME="$HOME/.codex-assistant" ./scripts/install-junior.sh --target codex
```

Shared skills and editable rules remain in `~/.agents/`; Junior's ownership metadata remains
in `~/.codex/.junior-install.json` and `~/.agents/.junior-install.json`. Installation refreshes
the selected profile. After updating shared rules, re-run installation for each additional
profile: the shared version check can report up to date while another profile's block is older.
Project installations ignore `CODEX_HOME` for destinations: instructions stay in the project
root and capacity stays in the project's `.codex/config.toml`.

## Codex Capacity

Codex installation requires Python 3.11+. Junior adjusts `project_doc_max_bytes` in
the selected Codex profile's `config.toml` (or `.codex/config.toml` for a project install),
preserving other settings and higher limits. The installed limit
allows two complete instruction documents plus 64 KiB of project guidance. Larger
nested documents or configuration overrides may need more capacity.

Project configuration must be trusted for this setting to apply. Start a fresh session
after any update; an existing conversation retains its previous instruction context.

## Hooks and Consent

Claude's `PreToolUse` hook guards Bash against a process-polling loop that matches its own command
line and can deadlock. It denies that shape and otherwise fails open.

Installation confirmation includes this settings change. `--yes` supplies consent
for an unattended run; it does not authorize discarding edited files. Junior merges its
own hook entries and marked instruction blocks while preserving other content.

To unlink these additions, remove the entry naming `no-polling-loop.py` from `.claude/settings.json`, then remove Junior's marked block
from the `CLAUDE.md` that imports its contract. Installation adds them again.

Project hooks invoke `python3` on PATH; global hooks use the installing interpreter.

## Migration

Updates retire the former Junior startup scanner and unchanged owned handoff assets.
Existing feedback documents and inbox/archive contents remain untouched. Customized
startup commands require reconciliation before upgrade; edited obsolete assets are
preserved even with `--overwrite`. No inbox is created or scanned by installation.

The installer moves manifest-owned legacy Codex/Cursor skills and generated Cursor
commands into the shared `.agents/skills/` tree. Equivalent edits survive. Differing
edits or conflicting destinations stop installation, even with `--overwrite`; reconcile
the copies with source before retrying. Files without ownership evidence are reported
and preserved.

Legacy Codex rules are retired only when unchanged and replaced, or unused. Rules
referenced by operator instructions or hooks remain. Edited or referenced rules keep
their checksums and appear in `pending_cleanup` in the runtime manifest. Unchanged
legacy contracts can be replaced; text outside Junior's managed block is preserved.

The shared skill manifest inventories unowned assets belonging to runtimes without an
installation manifest. Runtime manifests reference that shared ownership. Migrate a
legacy layout through installation before syncing. Sync supports global installations;
project sync and unified discovery across scopes remain unsupported.

The direct update command discovers a project installation from the current directory.
Uncommitted managed changes block that update. If selected runtimes span global and
project installations, choose one explicitly with `--scope` and, when needed,
`--project-root`. These advanced flags remain available for scripts.

Updates refuse installers without support for the installed shared skill or native
Codex layout. Codex updates compare both its rule version and the shared skill version.
The bootstrap refuses releases lacking separate consent and project-install support;
use the original installer for releases predating Junior 2.0.

## Troubleshooting Rule Loading

For Claude, run `/context` and inspect Memory files and the applicable `.claude/rules/`
directory. Hook output does not establish whether native rules loaded.

For Codex, inspect the selected `AGENTS.md` or override and the effective instruction
capacity. For Cursor, check the applicable project rules or configured global rules.
Verify in a fresh session after updating files.
