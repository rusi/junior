# Git Safety

Use this safety gate before mutating project files.

1. Verify repository status.
- Run `git status --short`.
- If not a git repository, state that clearly and ask whether to initialize git.

2. Handle dirty working tree.
- If clean: proceed.
- If dirty: review changed paths and decide if they are isolated from requested scope.
- If isolation is unclear, ask for explicit user confirmation before proceeding.

3. Default stance.
- Recommend committing/stashing unrelated changes before wide edits.
- Never silently overwrite or revert unrelated user work.

4. Evidence.
- Include git-state evidence in completion summary when it influenced decisions.
