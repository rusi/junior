# Story 1: Bash Version Check & Update Detection

> **Status:** Completed
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Working `.junior/update.sh` script that checks versions and reports update availability

## User Story

**As a** Junior user on macOS/Linux
**I want** to check if a Junior update is available
**So that** I know whether to run an update before deciding to download

## Scope

**In Scope:**
- `.junior/update.sh` script with version checking only
- Read current version from `.junior/.junior-install.json`
- Query GitHub API for latest commit
- Compare and report status (up-to-date, update available)
- Color-coded output matching install script style
- Basic error handling (no metadata, network failure, API errors)

**Out of Scope:**
- Actual download/install (Story 2)
- PowerShell version (Story 3)
- Install integration (Story 4)

## Acceptance Criteria

- [x] Given Junior is installed, when user runs `.junior/update.sh`, then script reads current version from `.junior/.junior-install.json` ✅
- [x] Given GitHub is reachable, when script queries API, then displays latest commit hash and timestamp ✅
- [x] Given current version equals latest version, when compared, then reports "Junior is up-to-date" ✅
- [x] Given current version differs from latest, when compared, then reports "Update available" with version details ✅
- [x] Given `.junior/.junior-install.json` missing, when script runs, then reports error and suggests installation ✅
- [x] Given network failure, when GitHub API call fails, then displays clear error message ✅

## Implementation Tasks

- [x] 1.1 Write tests for metadata file reading (TDD: test first) ✅
- [x] 1.2 Implement metadata reading (current version, commit hash) ✅
- [x] 1.3 Write tests for GitHub API integration (TDD: mock responses) ✅
- [x] 1.4 Implement GitHub API call (get latest commit from main branch) ✅
- [x] 1.5 Write tests for version comparison logic ✅
- [x] 1.6 Implement version comparison and reporting with color output ✅

## Technical Notes

**GitHub API Endpoint:**
```bash
curl -s https://api.github.com/repos/OWNER/REPO/commits/main
```

Response includes:
- `sha`: Commit hash
- `commit.committer.date`: Timestamp

**Metadata File Format:**
```json
{
  "version": "1733587200",
  "commit_hash": "abc1234...",
  "installed_at": "2025-12-07T12:00:00Z"
}
```

**Color Functions:**
Reuse style from `install-junior.sh`:
```bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
```

**Configuration:**
Hardcode GitHub repo for v1:
```bash
GITHUB_OWNER="your-username"
GITHUB_REPO="junior"
GITHUB_BRANCH="main"
```

See [specs/01-Technical.md](../specs/01-Technical.md) for detailed technical approach.

## Testing Strategy

**TDD Approach:**
- Write tests first (define expected behavior)
- Implement to pass tests
- Refactor for clarity

**Unit Tests:**
- Metadata parsing (valid JSON, missing fields, corrupted file)
- GitHub API response parsing (success, rate limit, network error)
- Version comparison logic (equal, different, unknown)

**Integration Tests:**
- Full version check with mocked GitHub API
- Real GitHub API call (optional, may hit rate limits during testing)

**Manual Testing:**
- Run `.junior/update.sh` in a test project with Junior installed
- Verify output format and colors
- Test with no internet connection
- Test with missing metadata file

## Definition of Done

- [x] All tasks completed ✅
- [x] All acceptance criteria met ✅
- [x] Script works end-to-end (reads metadata, queries GitHub, reports status) ✅
- [x] All tests passing (unit + integration) ✅
- [x] Error handling tested (missing metadata, network failures) ✅
- [x] Code follows bash best practices (set -e, quote variables, check commands exist) ✅
- [x] **User can run `.junior/update.sh` and see version comparison** ✅
- [x] Ready for Story 2 (download and install functionality) ✅

