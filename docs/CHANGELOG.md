# Changelog

## v2.1.0 - 2026-09-21

### Added

- Product isolation checks for complete trees, staged files and commit messages, and commit ranges, with content-bound review decisions.
- `/jr-demo` promotion of selected, verified capture bundles into standalone documentation, with content verification and backups when replacing existing bundles.

### Changed

- Planning, generation, review, and commit workflows keep product code, documentation, and media independent of private planning material.
- Product changes and planning updates use separate commits.
- Playwright captures record successful-run completion before becoming eligible for promotion. Refresh existing copied demo helpers and configuration, then recapture before promoting older bundles.

## v2.0.0 - 2026-09-16

### Added

- Project installation through an optional destination path, with `--scope project` and `--project-root` retained for scripts.
- `jr-product-review` for whole-product review with prioritized findings and explicit coverage gaps.
- `jr-demo` for assertion-verified screenshot storyboards and motion recordings.
- `jr-integrate` for acceptance testing all integration-branch changes, including direct, squash, and merge commits.
- `jr-archive` for checking session completeness and persistence before manual archival.
- `/jr feedback` for preparing Junior improvement proposals for submission or delivery to a known local source checkout.
- `jr-ui-prototype` for iterative interface design before implementation.
- Installation command selectors and rendered changelog pages.

### Changed

- Bootstrap installation and remote updates default to the latest stable tagged release. Use `--choose-version`, `--version`, or `--development` to select another source; release archives are downloaded by resolved commit.
- Codex and Cursor share native skills in `.agents/skills`, with shared ownership tracking.
- Claude loads rules natively. Codex receives managed startup instructions and instruction-capacity configuration; Cursor rules are rendered from shared Markdown sources.
- Installation command listings derive from shipped skills.
- Feature planning supports API, CLI, library, document, configuration, and UI outcomes, with scope approval followed by generated-artifact review.
- Coding workflows use project-agreed coverage metrics and executable thresholds. Establish missing agreements before implementation; existing agreements carry forward.
- Portable instructions follow the consuming project’s tooling. Skill authoring distinguishes portable workflows from repository-only workflows.

### Fixed

- Reinstallation preserves the original comparison baseline for customized files, allowing sync to detect independent source changes.
- Updates protect unsynced global edits and verify recovery before replacing customized project files.
- Legacy migration preserves conflicting edits and retires only eligible obsolete assets.
- Sync-back handles installed hooks, additions, deletions, and source divergence.
- Claude hook updates preserve neighboring registrations.
- Installation validates Claude startup settings before changing selected runtime assets.
- Maintenance guidance restricts commits to reviewed paths and preserves unrelated staged changes.
- Product-document migration retains discoverable mission, roadmap, and technical context.
- Debugging and status workflows require verification evidence before reporting resolution.
- Nested Markdown examples retain their intended code-block boundaries.

### Breaking Changes

- `--force` is retired. Use `--yes` for unattended consent and `--overwrite` for deliberate replacement of modified files during installation.
- Gemini is no longer an installation target. Existing Gemini files remain untouched.
- `jr-new-command` is renamed to `jr-new-skill`; update saved invocations.
- Codex installation requires Python 3.11 or newer. Re-run installation to migrate legacy layouts, reconcile reported conflicts, and start a fresh session. Trust project installations so Codex loads their configuration.
- The bootstrap requires Junior 2.0 or newer; use the original installer for older releases.
