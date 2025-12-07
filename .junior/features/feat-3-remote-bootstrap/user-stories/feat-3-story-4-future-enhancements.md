# Story 4: Future Enhancements & Follow-up Work

> **Status:** Not Started
> **Priority:** Low (Backlog)
> **Dependencies:** All previous stories completed
> **Deliverable:** Captured future work items for consideration in later iterations

## Purpose

This story captures features, enhancements, and technical considerations that were identified during feature planning but intentionally excluded from the initial scope. These items should be reviewed and potentially implemented in future iterations once the core bootstrap functionality is stable.

## Out-of-Scope Features

### Version Pinning

**Problem:** Users may want to install specific Junior version, not always latest

**Solution:**
```bash
# Bash
curl -LsSf https://USER.github.io/junior/install.sh | sh -s -- --version v1.2.3

# PowerShell
irm https://USER.github.io/junior/install.ps1 | iex -version v1.2.3
```

**Implementation:**
- Parse `--version` argument in bootstrap
- Modify GitHub URL to download specific tag/commit
- Verify version exists before downloading
- Document version pinning usage

### Custom Domain

**Problem:** GitHub Pages URL is long and unmemorable

**Solution:** Setup custom domain like `https://junior.dev/install.sh`

**Implementation:**
- Register domain (junior.dev or similar)
- Configure DNS CNAME to github.io
- Add CNAME file to `/docs`
- Update all documentation with new URL
- Keep github.io as fallback

### Offline Installation

**Problem:** Some environments have no internet or restricted access

**Solution:**
```bash
# Download once with internet
curl -LO https://USER.github.io/junior/install.sh
curl -LO https://github.com/USER/junior/archive/refs/heads/main.tar.gz

# Install offline
bash install.sh --tarball main.tar.gz
```

**Implementation:**
- Add `--tarball` flag to bootstrap
- Skip download if tarball provided
- Extract from local file instead
- Document offline workflow

### Checksum Verification

**Problem:** No verification that downloaded tarball is intact/authentic

**Solution:** Verify SHA256 hash before extraction

**Implementation:**
- Publish checksums alongside releases
- Download checksum file
- Calculate downloaded tarball hash
- Compare and abort if mismatch
- Document security verification

### GitHub Token Support

**Problem:** Private repos or higher rate limits need authentication

**Solution:**
```bash
export JUNIOR_GITHUB_TOKEN=ghp_xxxxx
curl -LsSf https://USER.github.io/junior/install.sh | sh
```

**Implementation:**
- Check for `JUNIOR_GITHUB_TOKEN` env var
- Add Authorization header to GitHub API calls
- Document token creation and usage
- Note: Avoid echoing token in output

### Rollback Support

**Problem:** If update breaks something, no easy way to restore previous version

**Solution:** Keep backup of previous installation, provide rollback command

**Implementation:**
- Backup `.junior/` before update
- Store backup with version info
- Add `--rollback` flag
- Restore from backup if needed
- Document rollback procedure

### Landing Page

**Problem:** Visiting github.io base URL shows raw script or 404

**Solution:** Create `docs/index.html` landing page with project info

**Implementation:**
- Simple HTML page with:
  - Project description
  - Installation instructions
  - Links to README, GitHub
  - Copy-paste install commands
- Keep it minimal and fast

## Technical Debt Considerations

### Bootstrap Script Duplication

**Issue:** Bash and PowerShell bootstrap have duplicated logic

**Future Consideration:**
- Explore unified scripting approach
- Consider single "universal" installer
- Balance simplicity vs maintenance

### Error Message Consistency

**Issue:** Ensure bash and PowerShell have identical error messages

**Future Work:**
- Create shared error message catalog
- Keep both implementations in sync
- Regular parity testing

## Enhancement Opportunities

### Progress Indicators

**Enhancement:** Better visual feedback during long operations

**Ideas:**
- Download progress bar (not just curl's)
- Extraction progress
- Step-by-step status (1/5, 2/5, etc.)
- Time estimates

### Pre-flight Checks

**Enhancement:** Verify system requirements before starting

**Checks:**
- Required commands available (tar, etc.)
- Sufficient disk space
- Write permissions in target directory
- Internet connectivity

### Telemetry (Optional)

**Enhancement:** Anonymous usage statistics (opt-in only)

**Metrics:**
- Install success/failure rates
- Common error types
- Platform distribution
- Performance metrics

**Privacy:**
- Completely optional (opt-in)
- Anonymous IDs only
- Transparent about data collected
- Easy opt-out

## Follow-up Work

### Testing Improvements

- Add automated cross-platform testing (GitHub Actions)
- Test matrix: macOS, Linux (Ubuntu, CentOS), Windows
- Regular smoke tests on each commit
- Performance benchmarking

### Documentation Expansion

- Video walkthrough of installation
- GIF/screenshots in README
- FAQ section based on user feedback
- Troubleshooting guide expansion

### Community Feedback Integration

- Collect user feedback on install experience
- Track common issues in GitHub Issues
- Regular review of pain points
- Iterate on documentation based on feedback

