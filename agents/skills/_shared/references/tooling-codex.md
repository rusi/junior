# Tooling Map: Codex

Use these tool families in Codex environments.

- Repository scan: `find`, `rg --files`, `rg`.
- File read: `sed -n`, `cat`, `nl -ba`.
- File edit: `apply_patch` for targeted edits, shell redirection for generated files.
- Execution: `functions.exec_command`.
- Parallel reads: `multi_tool_use.parallel` for independent discovery calls.
- Planning: `functions.update_plan`.

Notes:
- Prefer non-interactive commands.
- Keep commands deterministic and scriptable.
