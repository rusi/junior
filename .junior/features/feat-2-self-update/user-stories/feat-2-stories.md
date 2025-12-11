# User Stories Overview

> **Feature:** Self-Updating Junior Installation
> **Created:** 2025-12-07
> **Status:** Planning

## Stories Summary

| Story | Title | Status | Tasks | Progress |
|-------|-------|--------|-------|----------|
| 1 | Bash Version Check & Update Detection | Completed ✅ | 6 | 6/6 ✅ |
| 2 | Bash Full Update Flow (Download, Install, Cleanup) | Not Started | 6 | 0/6 |
| 3 | PowerShell Update Script with Platform Parity | Not Started | 6 | 0/6 |
| 4 | Install Integration & Documentation | Not Started | 5 | 0/5 |
| 5 | Future Enhancements & Follow-up Work | Not Started | - | Backlog |

**Total:** 6/23 tasks (26%) + Future work in backlog

## Story Dependencies

- Story 2 depends on Story 1 completion (version check must work before full update)
- Story 3 depends on Story 2 completion (PowerShell mirrors bash implementation)
- Story 4 depends on Story 3 completion (both scripts must exist before install integration)
- Story 5 (Future Work) depends on all previous stories

## Implementation Order

Follow stories sequentially. Each story must be:
- End-to-end integrated
- User-testable with working output
- Built using TDD (test first, implement, verify)

Story 5 captures out-of-scope items and future enhancements for later consideration.

## Quick Links

- [Story 1: Bash Version Check](./feat-2-story-1-bash-version-check.md)
- [Story 2: Bash Full Update Flow](./feat-2-story-2-bash-full-update.md)
- [Story 3: PowerShell Parity](./feat-2-story-3-powershell-parity.md)
- [Story 4: Install Integration](./feat-2-story-4-install-integration.md)
- [Story 5: Future Work](./feat-2-story-5-future-enhancements.md)

