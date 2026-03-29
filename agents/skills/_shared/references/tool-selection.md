# Tool Selection Decision Tree

1. Detect execution environment.
- If Codex tool runtime is available: use `tooling-codex.md`.
- Else if Cursor runtime is available: use `tooling-cursor.md`.
- Else: use `tooling-claude.md` and shell fallbacks.

2. Map intent to tool family.
- Need discoverability: repository scan tools.
- Need precision: file read + targeted edit tools.
- Need verification: terminal execution tools.
- Need progress tracking: plan/todo tool if available; otherwise explicit checklist.

3. Safety gates.
- Confirm repository state before writes.
- Avoid destructive commands unless explicitly requested.
- Validate outputs after edits.
