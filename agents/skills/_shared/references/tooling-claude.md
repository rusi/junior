# Tooling Map: Claude

Use these tool families in Claude environments.

- Repository scan: shell `find`, `grep`, `git` commands.
- File read: shell readers (`cat`, `sed`, `awk`) or available file tools.
- File edit: patch-style edits or deterministic scripted generation.
- Execution: shell tool invocations available in the host environment.
- Planning: explicit step lists in response when no dedicated plan tool exists.

Notes:
- Prefer plain shell primitives when environment-specific helpers are absent.
- Keep tool assumptions explicit in the response.
