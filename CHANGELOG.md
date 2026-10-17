# Changelog

## v2.4.0 - 2026-10-17

### Added

- `/jr-new-project` creates a repository and committed project brief for a fresh coding session.

### Fixed

- Installers select a compatible available Python interpreter, including Python 3.11+ for Codex.
- Installation output distinguishes currently installed versions from new results, preserves message order, and reports failures explicitly.
- Cleanup warnings focus on Junior assets, omitting unrelated runtime and user files.

## v2.3.0 - 2026-10-15

### Added

- `/jr-logo` for animated SVG concepts, themed previews, GIFs, and logo/favicon integration.
- XCTest/XCUITest still storyboards for iOS Simulator, with verified export from successful test results.
- `/jr-feedback` for verified file delivery to a selected source checkout or personal inbox.

### Changed

- Mobile visual explorations default to interactive web drafts informed by the application’s source.
- Authorized work continues across workflow boundaries without repeated command invocations.
- Implementation guidance includes rendered UI/UX refinement before completion.
- Implementation, testing, and review workflows define artifact retention and cleanup.
- Existing browser demo setups must copy `capture-directory.ts` and `viewer.ts` alongside the updated helpers.

### Fixed

- `/jr-status` includes every feature and numbered story, with evidence-supported states.
- `/jr sync` assesses delivered feedback even when installed assets have no changes.
- Multi-view recording acknowledges frames without waiting for disk writes and settles pending capture work before teardown.

### Removed

- `/jr feedback`; use `/jr-feedback`.

## v2.2.1 - 2026-09-28

### Changed

- UI prototypes reuse the application’s components and styles and render within their actual host layout.
- Prototype guidance prioritizes useful content, reduces redundant interface elements, and preserves useful controls during revisions.
- Next-step guidance favors continuing related work in the current session when its context remains useful. `/jr-archive` distinguishes readiness to close from reasons to continue.

## v2.2.0 - 2026-09-24

### Added

- Optional synchronized multi-view recordings in `/jr-demo` for demonstrating collaborative features across multiple users, with two labeled side-by-side views. Requires Chromium and `ffmpeg`.

### Changed

- Motion walkthroughs show essential actions and results together, preserve readable pacing, and require full playback review.
- When refreshing existing copied demo tooling, include the new `multiview.ts` helper alongside the updated `storyboard.ts` and `demo.ts` fixture.

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
