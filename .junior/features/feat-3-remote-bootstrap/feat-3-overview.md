# Remote Install/Update Bootstrap

> Created: 2025-12-07
> Status: In Progress
> Contract Locked: ✅

## Feature Contract

**Feature:** Remote install/update bootstrap via GitHub Pages

**User Value:** Install or update Junior with single command (no repo clone needed), works for fresh installs and legacy versions without update.sh

**Hardest Constraint:** Must work across platforms (bash/PowerShell) and handle both fresh installs and updates of pre-feat-2 versions

**Success Criteria:** `curl -LsSf https://USER.github.io/junior/install.sh | sh` successfully installs or updates Junior in current directory

**Scope:**
- ✅ Included: Bootstrap scripts (`docs/install.sh`, `docs/install.ps1`) that download tarball and run install scripts
- ✅ Included: GitHub Pages configuration (serve from `/docs`)
- ✅ Included: README documentation with clear install/update instructions
- ✅ Included: Current directory as target (user cd's to project first)
- ❌ Excluded: Custom domain setup (use github.io), version pinning, rollback, offline mode

**Integration Points:**
- GitHub tarball API (same as feat-2)
- Existing `scripts/install-junior.sh` and `scripts/install-junior.ps1`
- Complements feat-2's `.junior/update.sh` (users with it use that instead)
- GitHub Pages static hosting

**⚠️ Technical Concerns:**
- Bootstrap script runs with piped stdin (can't prompt for input) - must use current directory
- GitHub raw URLs vs GitHub Pages URLs (gh-pages cleaner, but requires setup)
- Tarball extraction creates nested directory - must handle path correctly

**💡 Recommendations:**
- Keep bootstrap scripts minimal (download + extract + delegate)
- Add `--version` flag support for future version pinning
- Reuse color/output functions from existing install scripts
- Test with projects that have no Junior, old Junior (pre-feat-2), and current Junior

## Detailed Requirements

### Functional Requirements

**Bootstrap Script (Bash: `docs/install.sh`):**
- Download latest Junior tarball from GitHub
- Extract to temporary directory
- Run `scripts/install-junior.sh` with current directory as target
- Clean up temporary files
- Handle errors gracefully with clear messages
- Work when piped from curl (non-interactive)

**Bootstrap Script (PowerShell: `docs/install.ps1`):**
- Same functionality as bash version
- Use native PowerShell commands (Invoke-WebRequest, Expand-Archive)
- Handle Windows paths correctly
- Maintain feature parity with bash

**GitHub Pages Setup:**
- Enable GitHub Pages for repository
- Serve from `/docs` directory
- Scripts accessible via `https://USER.github.io/junior/install.sh`
- Optional: Custom 404 page, index.html landing page

**Documentation:**
- README section with installation instructions
- Show both fresh install and update scenarios
- Include bash and PowerShell examples
- Explain when to use bootstrap vs `.junior/update.sh`
- Document current directory behavior

### Non-Functional Requirements

- **Performance:** Bootstrap completes in <30 seconds (download + extract + install)
  - Target: Fast user onboarding
  - Benchmark: Compare against manual clone + install
- **Security:** HTTPS for all downloads, verify tarball integrity
- **Reliability:** Graceful handling of network failures, partial downloads
- **Usability:** Clear progress messages, actionable error messages
- **Maintainability:** Minimal code in bootstrap, delegate to install scripts

## User Stories

See [user-stories/feat-3-stories.md](./user-stories/feat-3-stories.md) for implementation breakdown.

## Technical Approach

See [specs/01-Technical.md](./specs/01-Technical.md) for detailed technical approach.

High-level strategy:
- Thin bootstrap script: download tarball → extract → delegate to install script
- GitHub tarball API: `/archive/refs/heads/main.tar.gz`
- Temporary directory for extraction (auto-cleanup)
- Current directory as install target (`$(pwd)`)
- GitHub Pages for static hosting from `/docs`

## Dependencies

**External:**
- `curl` or `wget` for downloads (bash)
- `tar` for extraction
- GitHub tarball API (public, no auth)
- GitHub Pages hosting

**Internal:**
- Existing `scripts/install-junior.sh` (feat-1)
- Existing `scripts/install-junior.ps1` (feat-1)
- Complements `.junior/update.sh` (feat-2)

## Risks & Mitigations

**Risk:** Bootstrap runs with piped stdin - can't prompt user for input
- **Mitigation:** Use current directory automatically, document clearly in README

**Risk:** GitHub Pages not enabled or misconfigured
- **Mitigation:** Test GitHub Pages setup, document configuration steps

**Risk:** Tarball extraction path varies (e.g., `junior-main/` vs `junior-master/`)
- **Mitigation:** Detect extracted directory name dynamically, normalize paths

**Risk:** User runs bootstrap in wrong directory (not their project)
- **Mitigation:** Clear documentation, show example workflow

**Risk:** Network failure mid-download leaves partial files
- **Mitigation:** Use unique temp directory, cleanup on error

## Success Metrics

- Users can install Junior with single command (no repo clone)
- Bootstrap completes in <30 seconds (typical)
- Works for fresh installs and pre-feat-2 upgrades
- Zero manual steps beyond running curl command
- Clear documentation guides users successfully

## Future Enhancements

- Version pinning: Install specific version via `curl ... | sh -s -- --version v1.2.3`
- Custom domain: `https://junior.dev/install.sh` (requires domain + redirect)
- Offline install: `curl -O install.sh && bash install.sh --tarball local.tar.gz`
- GitHub token support: Higher rate limits, private repos
- Checksum verification: SHA256 hash check before extraction
- Rollback support: Restore previous version if update fails

