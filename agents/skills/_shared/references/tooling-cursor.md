# Tooling Map: Cursor

Use these tool families in Cursor environments.

- Repository scan: `list_dir`, `glob_file_search`, shell `find`/`grep`.
- File read: `read_file`.
- File edit: `edit_file`, `search_replace`, patch/editor operations.
- Execution: `run_terminal_cmd`.
- Planning/todos: built-in todo/plan updates where available.

Notes:
- Prefer exact file references over broad scans when context is known.
- Keep edits minimal and reviewable.
