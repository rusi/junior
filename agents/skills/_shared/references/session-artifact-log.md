# Session Artifact Log (Shared Contract)

Purpose: preserve durable execution context across `/jr-implement`, `/jr-test`, `/jr-code-review`, and `/jr-commit` so staging and commit scope do not depend on short chat memory.

## Canonical Location

Inside each active story file (`feat-N-story-M-*.md`), maintain a section:

```md
## Session Artifact Log
```

If missing, create it near the bottom of the story file.

## Entry Format (Required)

Each command run appends one entry (newest first):

```md
### <YYYY-MM-DD HH:MM> /<command>
- Scope: feat-N-story-M
- Files touched:
  - `path/to/file-a.ext` (modified)
  - `path/to/file-b.ext` (created)
- Evidence:
  - `make test` (pass)
  - `uv run pytest tests/test_x.py` (pass)
- Handoff: none
```

Rules:
- `Files touched` must list only repository-relative paths.
- Include every file changed by the command run (code, tests, config, docs, `.junior/` docs).
- Keep statuses factual: `created`, `modified`, `deleted`, `renamed`.
- `Evidence` records the exact validation commands run and outcome.
- `Handoff` is required (`none` if no handoff).

## Consumption Rule for `/jr-commit`

`/jr-commit` must parse the latest entries for the target story and treat `Files touched` paths as commit-scope candidates, then intersect with `git status` to stage only currently changed files.
