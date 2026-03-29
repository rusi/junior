# Roadmap Progress Sync (Shared)

Use this reference to keep `.junior/product/02-roadmap.md` synchronized with actual execution progress from feature and story artifacts.

## Purpose

- Keep roadmap planning and implementation progress in one consistent view.
- Track roadmap progress with checkboxes and explicit progress values.
- Prevent roadmap drift when features/stories are added or completed.

## Scope

- Primary file: `.junior/product/02-roadmap.md`
- Source of truth for execution progress:
  - `feat-N-overview.md`
  - `user-stories/feat-N-stories.md`
  - story files (`feat-N-story-M-*.md`)

If roadmap file does not exist, do not create ad-hoc content in implementation commands. Instead, recommend running `/jr-roadmap` to establish structure first.

## Required Roadmap Tracking Block

Maintain an explicit roadmap tracking section:

```markdown
## Execution Tracking

| Roadmap Item | Linked Spec | Status | Progress | Notes |
|--------------|-------------|--------|----------|-------|
| [Feature title] | feat-3-admin-panel | In Progress | 2/5 stories (40%) | Story 3 active |
```

Also maintain checklist entries for quick visual scanning:

```markdown
- [ ] [Feature title] (feat-3-admin-panel) - 2/5 stories (40%)
- ✅ [Feature title] (feat-2-auth) - 4/4 stories (100%)
```

Checkbox rule:
- Unchecked item: `- [ ]`
- Completed item: `- ✅`
- Never use `- [x]`

## Update Rules

When feature planning or implementation changes execution state:

1. Update or add roadmap row in `## Execution Tracking`.
2. Update matching checklist entry.
3. Keep status/progress aligned with `feat-N-stories.md`.
4. Add a short note when scope changed (split/merged/resequenced roadmap item).

## Mapping Heuristic

- Match by normalized title first (lowercase, remove punctuation, collapse spaces).
- If ambiguous, add note and keep current mapping until user confirms.
- If no roadmap item exists, append a new item under the most appropriate phase/layer and tracking block.

## Completion Semantics

- `Planning`: feature exists but all stories are `0/N`.
- `In Progress`: `0 < completed < total`.
- `Completed`: all feature stories are complete.

## Command Responsibilities

- `/jr-feature`: add new roadmap item and initialize tracking (`0/N`).
- `/jr-implement`: update tracking after task/story completion and at final story completion.
- `/jr-roadmap`: maintain structure, sequencing, and tracking blocks.
- `/jr-status`: read tracking block first for completion reporting.
- `/jr-next`: use tracking block + story progress to choose next highest-value action.
