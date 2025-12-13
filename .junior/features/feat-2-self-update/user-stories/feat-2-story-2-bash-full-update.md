# Story 2: Bash Full Update Flow (Download, Install, Cleanup)

> **Status:** Completed
> **Priority:** High
> **Dependencies:** Story 1 (version check must work)
> **Deliverable:** Complete update workflow - download tarball, extract, install, cleanup

## User Story

**As a** Junior user on macOS/Linux
**I want** to update my Junior installation with a single command
**So that** I get the latest features and fixes without managing the Junior repository

## Scope

**In Scope:**
- Extend `.junior/update.sh` with download and install functionality
- Download GitHub tarball to temporary directory
- Extract tarball and handle nested directory structure
- Run install script from extracted source
- Cleanup temporary files (success or failure)
- Confirmation prompt before download (skip with `--force`)
- Full error handling and rollback

**Out of Scope:**
- PowerShell version (Story 3)
- Install integration (Story 4)
- Rollback to previous version (future enhancement)

## Acceptance Criteria

- [x] Given update is available, when user confirms, then tarball downloads to temp directory ✅
- [x] Given tarball downloaded, when extracted, then handles nested directory (junior-main/) ✅
- [x] Given source extracted, when install script runs, then uses correct path to install ✅
- [x] Given install completes, when cleanup runs, then removes all temporary files ✅
- [x] Given download fails, when error occurs, then displays error and cleans up partial files ✅
- [x] Given `--force` flag, when script runs, then skips confirmation prompt ✅
- [x] Given install script fails, when error occurs, then displays error and preserves temp directory for debugging ✅

## Implementation Tasks

- [x] 2.1 Write tests for tarball download (TDD: mock curl, verify temp directory) ✅
- [x] 2.2 Implement GitHub tarball download with progress indicator ✅
- [x] 2.3 Write tests for tarball extraction (TDD: verify directory structure) ✅
- [x] 2.4 Implement tarball extraction and path normalization ✅
- [x] 2.5 Write tests for install script invocation and cleanup ✅
- [x] 2.6 Implement install script execution, error handling, and temp cleanup ✅

## Technical Notes

**Temporary Directory:**
```bash
TEMP_DIR=$(mktemp -d /tmp/.junior-update-XXXXX)
trap "rm -rf $TEMP_DIR" EXIT
```

**GitHub Tarball Download:**
```bash
TARBALL_URL="https://github.com/${OWNER}/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
curl -L -o "$TEMP_DIR/junior.tar.gz" "$TARBALL_URL"
```

**Extraction (handles nested directory):**
```bash
tar -xzf "$TEMP_DIR/junior.tar.gz" -C "$TEMP_DIR"
EXTRACTED_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "${REPO}-*" | head -n 1)
```

**Install Script Invocation:**
```bash
cd "$EXTRACTED_DIR"
./scripts/install-junior.sh --ignore-dirty --force "$(pwd)/../../../.."
```

**Flags:**
- `--ignore-dirty`: Update source isn't a git repo (tarball)
- `--force`: Skip confirmations during automated update
- Target path: Navigate back to original project root

**Error Handling:**
```bash
set -e  # Exit on error
trap cleanup_on_error ERR

cleanup_on_error() {
    print_error "Update failed. Temp files preserved for debugging: $TEMP_DIR"
    exit 1
}
```

See [specs/01-Technical.md](../specs/01-Technical.md) for detailed technical approach.

## Testing Strategy

**TDD Approach:**
- Write tests first (define expected behavior)
- Implement to pass tests
- Refactor for clarity

**Unit Tests:**
- Temp directory creation and cleanup
- Tarball download (mocked curl)
- Tarball extraction and path detection
- Install script path construction

**Integration Tests:**
- Full update flow with mocked GitHub (local tarball)
- Error scenarios (download failure, extraction failure, install failure)
- Cleanup verification (temp files removed)

**Manual Testing:**
- Run `.junior/update.sh` in test project
- Verify download progress indicator
- Confirm installation succeeds
- Check temp files cleaned up
- Test `--force` flag
- Test network failure during download
- Test with already up-to-date version

## Definition of Done

- [x] All tasks completed ✅
- [x] All acceptance criteria met ✅
- [x] Full update flow works end-to-end (check, download, extract, install, cleanup) ✅
- [x] All tests passing (unit + integration) - 29/29 tests ✅
- [x] Error handling tested (download failure, install failure) ✅
- [x] Temp cleanup verified in success and error cases ✅
- [x] Code follows bash best practices ✅
- [x] **User can run `.junior/update.sh`, confirm, and see Junior updated** ✅
- [x] Ready for Story 3 (PowerShell implementation) ✅

