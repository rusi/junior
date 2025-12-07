# Technical Specification

## Overview

Self-updating mechanism for Junior installations that downloads the latest version from GitHub and applies updates using existing install infrastructure. The update process leverages GitHub's tarball API and delegates to the existing install scripts for actual file management.

## Architecture

```
User Project
├── .junior/
│   ├── update.sh               # Bash update script
│   ├── update.ps1              # PowerShell update script
│   └── .junior-install.json    # Current version metadata
│
Update Flow:
1. Read current version from metadata
2. Query GitHub API for latest commit
3. Compare versions
4. Download tarball to temp directory
5. Extract tarball
6. Run install script from extracted source
7. Clean up temp directory
8. Report success/failure
```

## Components

### Update Script (Bash: `.junior/update.sh`)

**Responsibility:** Orchestrate version checking, download, installation, and cleanup

**Interface:**
- CLI: `./.junior/update.sh [--force] [--check-only]`
- Exit codes: 0 (success), 1 (error), 2 (up-to-date, no update)

**Dependencies:**
- `curl` or `wget` for downloads
- `jq` for JSON parsing
- `tar` for extraction
- Existing `install-junior.sh` script

**Functions:**
```bash
# Core functions
check_dependencies()        # Verify curl, jq, tar available
read_current_version()      # Parse .junior-install.json
query_github_latest()       # Call GitHub API
compare_versions()          # Determine if update needed
download_tarball()          # Fetch from GitHub
extract_tarball()           # Uncompress to temp dir
run_install()              # Execute install script
cleanup_temp()             # Remove temp files

# Utility functions
print_status()             # Blue info messages
print_success()            # Green success messages
print_warning()            # Yellow warnings
print_error()              # Red errors
confirm_prompt()           # Yes/no confirmation
```

### Update Script (PowerShell: `.junior/update.ps1`)

**Responsibility:** Same as bash version, PowerShell implementation

**Interface:**
- CLI: `.\.junior\update.ps1 [-Force] [-CheckOnly]`
- Exit codes: Same as bash

**Dependencies:**
- `Invoke-RestMethod` for API calls
- `Invoke-WebRequest` for downloads
- `tar` (built-in Windows 10+) for extraction
- Existing `install-junior.ps1` script

**Functions:**
```powershell
# Core functions (mirror bash)
Test-Dependencies()
Get-CurrentVersion()
Get-LatestVersion()
Compare-Versions()
Get-Tarball()
Expand-Tarball()
Invoke-Install()
Remove-TempFiles()

# Utility functions
Write-Status()
Write-Success()
Write-Warning()
Write-ErrorMsg()
Get-Confirmation()
```

### GitHub Integration

**API Endpoint:**
```
GET https://api.github.com/repos/{owner}/{repo}/commits/{branch}
```

**Response:**
```json
{
  "sha": "abc123...",
  "commit": {
    "committer": {
      "date": "2025-12-07T12:00:00Z"
    }
  }
}
```

**Tarball Endpoint:**
```
GET https://github.com/{owner}/{repo}/archive/refs/heads/{branch}.tar.gz
```

**Rate Limiting:**
- 60 requests/hour (unauthenticated)
- 5000 requests/hour (with token, future enhancement)

### Metadata Format

**Current (`.junior/.junior-install.json`):**
```json
{
  "version": "1733587200",
  "installed_at": "2025-12-07T12:00:00Z",
  "commit_hash": "abc123def456...",
  "files": {
    ".cursor/rules/00-junior.mdc": {
      "sha256": "...",
      "size": 1234,
      "modified": false
    }
  }
}
```

**Used by update script:**
- `commit_hash`: Compare with GitHub latest
- `version`: Timestamp for user display
- `installed_at`: Show when current version installed

## Design Decisions

### Tarball vs Git Clone

**Context:** Need to download Junior source for update

**Decision:** Use GitHub tarball API

**Rationale:**
- Lightweight (no git history)
- No git dependency required
- Simple HTTP download
- Fast extraction

**Alternatives Considered:**
- Git clone: Requires git, downloads full history (slower, larger)
- GitHub API file downloads: Multiple requests, complex, rate limit concerns

### Temporary Directory Strategy

**Context:** Need safe location for download/extract

**Decision:** Use system temp directory with unique suffix

**Rationale:**
- OS-appropriate location (`/tmp` on Unix, `$env:TEMP` on Windows)
- Unique suffix prevents conflicts
- Automatic cleanup on error (trap/finally)
- User can inspect on failure

**Implementation:**
```bash
TEMP_DIR=$(mktemp -d /tmp/.junior-update-XXXXX)
trap "rm -rf $TEMP_DIR" EXIT
```

### Install Script Delegation

**Context:** Need to apply update (copy files, update metadata)

**Decision:** Reuse existing install scripts

**Rationale:**
- DRY: Don't duplicate install logic
- Proven code: Install scripts already handle upgrade detection, conflict resolution
- Consistency: Same file management rules
- Maintenance: Bug fixes in install scripts automatically benefit updates

**Alternatives Considered:**
- Custom update logic: Would duplicate install script, risk divergence
- In-place file copy: Wouldn't handle conflicts, metadata, cleanup

### Version Comparison Strategy

**Context:** Determine if update needed

**Decision:** Compare commit hashes (SHA)

**Rationale:**
- Precise: Exact version match
- Simple: String comparison
- Future-proof: Works with branches, tags, commits

**Alternatives Considered:**
- Timestamp comparison: Less precise, can have collisions
- Semantic versioning: Would require tagging, more complex

### Error Handling Philosophy

**Context:** Network failures, API errors, partial downloads

**Decision:** Fail fast with clear error messages, preserve temp directory on error

**Rationale:**
- Debugging: User/developer can inspect temp files
- Safety: Don't partially update
- Clarity: Specific error messages for each failure mode

**Implementation:**
```bash
set -e  # Exit on any error

cleanup_on_error() {
    print_error "Update failed. Temp preserved: $TEMP_DIR"
    print_error "Review logs, then manually remove: rm -rf $TEMP_DIR"
    exit 1
}

trap cleanup_on_error ERR
```

## Testing Strategy

### Unit Tests

**Bash (using bats or custom test framework):**
- Metadata parsing: Valid JSON, missing fields, corrupted file
- Version comparison: Equal, different, invalid hashes
- GitHub API response parsing: Success, rate limit, 404, network error
- Temp directory creation: Unique paths, cleanup
- Path normalization: Handle extracted directory name variations

**PowerShell (using Pester):**
- Same test coverage as bash
- Platform-specific behaviors (path separators, temp locations)

### Integration Tests

**Test Scenarios:**
1. Fresh update (up-to-date to latest)
2. Version behind (update available)
3. Already up-to-date (no action)
4. Network failure (before download)
5. Download failure (partial file)
6. Extraction failure (corrupted tarball)
7. Install script failure (conflict)
8. Cleanup verification (temp removed)

**Test Setup:**
- Mock GitHub API (local server or fixtures)
- Mock tarball (pre-built test archive)
- Test project with Junior installed
- Various metadata scenarios

### Manual Testing

**Checklist:**
- [ ] Fresh Junior install → run update (should be up-to-date)
- [ ] Older Junior install → run update (should update)
- [ ] No internet → run update (should error gracefully)
- [ ] Invalid metadata → run update (should error clearly)
- [ ] `--force` flag → skip confirmation
- [ ] `--check-only` flag → check without update
- [ ] Cross-platform (macOS, Linux, Windows)
- [ ] User-modified files preserved during update

## Cross-References

- Implements requirements from [feat-2-overview.md](../feat-2-overview.md)
- Related to Story 1: [Version Check](../user-stories/feat-2-story-1-bash-version-check.md)
- Related to Story 2: [Full Update](../user-stories/feat-2-story-2-bash-full-update.md)
- Related to Story 3: [PowerShell Parity](../user-stories/feat-2-story-3-powershell-parity.md)
- Related to Story 4: [Install Integration](../user-stories/feat-2-story-4-install-integration.md)

## Performance Targets

**Version Check:**
- Target: <2 seconds
- Breakdown: API call (1s), parsing (0.5s), display (0.5s)

**Full Update:**
- Target: <30 seconds (typical)
- Breakdown: Check (2s), download (10-20s), extract (2s), install (5s), cleanup (1s)
- Variable: Download time depends on connection speed

**Benchmarking:**
- Measure with `time` command
- Log timestamps at each step
- Compare against targets

