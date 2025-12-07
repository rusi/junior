# Self-Updating Junior Installation

> Created: 2025-12-07
> Status: Planning
> Contract Locked: ✅

## Feature Contract

**Feature:** Self-updating Junior installation via GitHub
**User Value:** Users can update their Junior installation without maintaining Junior repo clone, with single command checking and applying updates
**Hardest Constraint:** Must work across platforms (bash/PowerShell) and handle all install script features (upgrade detection, conflict resolution, user-modified files)
**Success Criteria:** Running `.junior/update.sh` checks GitHub, shows available updates, and upgrades Junior installation with same safety guarantees as install script

**Scope:**
- ✅ Included: Update scripts (bash + PowerShell), GitHub tarball download, version checking via GitHub API, integration with existing upgrade mechanism
- ✅ Included: PowerShell script parity with bash improvements
- ✅ Included: Add update scripts to install-config.json
- ❌ Excluded: Automatic updates, update notifications, rollback mechanism

**Integration Points:**
- GitHub API for commit hash checking
- GitHub tarball download for source
- Existing `.junior/.junior-install.json` for current version
- Existing install scripts (`install-junior.sh`, `install-junior.ps1`)

**⚠️ Technical Concerns:**
- Tarball extraction creates nested directory (e.g., `junior-main/`) — need to handle path correctly
- GitHub API rate limiting (60 req/hour unauthenticated) — should be fine for checking updates
- PowerShell and bash scripts must stay in sync — bash is reference implementation

**💡 Recommendations:**
- Store GitHub repo URL in metadata or make it configurable (future: support forks)
- Consider `--force` flag to skip confirmation prompt (CI/automation scenarios)
- Reuse install script's color functions and output formatting for consistency

## Detailed Requirements

### Functional Requirements

**Version Checking:**
- Read current version from `.junior/.junior-install.json` (commit hash)
- Query GitHub API for latest commit hash on main branch
- Compare versions and report status (up-to-date, update available, unknown)
- Display current and available version info (commit hash, timestamp)

**Update Workflow:**
- Download GitHub tarball to temporary directory
- Extract tarball
- Run install script from extracted source
- Clean up temporary files
- Report success/failure with details

**User Experience:**
- Clear status messages with color-coded output
- Confirmation prompt before downloading/installing (skip with `--force`)
- Progress indicators for download and install
- Error handling with actionable messages

**Platform Support:**
- Bash script for macOS/Linux (`.junior/update.sh`)
- PowerShell script for Windows (`.junior/update.ps1`)
- Feature parity between platforms

### Non-Functional Requirements

- **Performance:** Version check completes within 2 seconds (network permitting)
  - Benchmark: GitHub API response time
  - Target: Display version info quickly before user confirmation
- **Security:** Download verification via HTTPS, tarball integrity check optional
- **Reliability:** Graceful handling of network failures, GitHub API errors, partial downloads
- **Maintainability:** Code reuse from install scripts where possible

## User Stories

See [user-stories/feat-2-stories.md](./user-stories/feat-2-stories.md) for implementation breakdown.

## Technical Approach

See [specs/01-Technical.md](./specs/01-Technical.md) for detailed technical approach.

High-level strategy:
- GitHub API (`/repos/:owner/:repo/commits/:branch`) for version checking
- GitHub archive download (`/archive/refs/heads/:branch.tar.gz`)
- Temporary directory (`/tmp/.junior-update-XXXXX`) for download/extract
- Delegate to existing install script for actual installation
- TDD approach: Test version checking, download, extraction, cleanup separately

## Dependencies

**External:**
- `curl` or `wget` for downloads (bash)
- `jq` for JSON parsing (bash)
- GitHub public API (no auth required)
- Existing install scripts

**Internal:**
- `.junior/.junior-install.json` metadata file
- `scripts/install-config.json` structure

## Risks & Mitigations

**Risk:** GitHub API rate limiting (60 req/hour unauthenticated)
- **Mitigation:** Acceptable for manual updates; add note in docs; future: support GitHub token

**Risk:** Tarball extraction path handling differs across platforms
- **Mitigation:** Test on macOS, Linux, Windows; normalize paths

**Risk:** PowerShell script drift from bash improvements
- **Mitigation:** Bash is reference implementation; sync PowerShell in Story 3

**Risk:** Network failure mid-download leaves partial files
- **Mitigation:** Use unique temp directory; cleanup on error; verify download

**Risk:** User has customized install-config.json (future scenario)
- **Mitigation:** Out of scope for v1; document in future enhancements

## Success Metrics

- Users can update Junior with single command
- Update check completes in <2 seconds
- Full update completes in <30 seconds (typical)
- All install script features work during update (upgrade detection, conflict resolution)
- Zero data loss (user-modified files preserved)

## Future Enhancements

- Automatic update notifications on `/status` or other commands
- Rollback mechanism (restore previous version)
- Update to specific version/commit (not just latest)
- Support for forked Junior repositories
- Offline update via local tarball
- GitHub token support for higher rate limits
- Update checking without immediate install option

