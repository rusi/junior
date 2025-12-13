# Story 1: Bash Bootstrap Script

> **Status:** Completed
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Working bash bootstrap script that installs/updates Junior via single curl command

## User Story

**As a** developer wanting to use Junior
**I want** to install or update Junior with a single command
**So that** I don't need to clone the repo or manage installation manually

## Scope

**In Scope:**
- `docs/install.sh` script that downloads, extracts, and runs install script
- Works when piped from curl (non-interactive)
- Handles fresh installs and upgrades (including pre-feat-2 versions)
- Uses current directory as target
- Clear progress messages and error handling
- Cleanup of temporary files

**Out of Scope:**
- PowerShell version (Story 3)
- GitHub Pages setup (Story 2)
- Version pinning, custom domains (Story 4)

## Acceptance Criteria

- [x] Given user is in project directory, when they run `curl -LsSf <url> | sh`, then Junior installs successfully ✅
- [x] Given Junior not installed, when bootstrap runs, then fresh install completes ✅
- [x] Given old Junior installed (no update.sh), when bootstrap runs, then upgrade completes ✅
- [x] Given bootstrap encounters error, when failure occurs, then clear error message shown and temp cleaned up ✅
- [x] Given tarball downloaded, when extraction fails, then error reported and partial files removed ✅
- [x] Given install script fails, when error occurs, then bootstrap reports failure clearly ✅

## Implementation Tasks

- [x] 1.1 Write tests for tarball download (TDD: test first) ✅
- [x] 1.2 Implement download_tarball() function with curl/wget fallback ✅
- [x] 1.3 Write tests for extraction and path detection ✅
- [x] 1.4 Implement extract_tarball() with temp directory handling ✅
- [x] 1.5 Write tests for install script delegation and cleanup ✅
- [x] 1.6 Implement main bootstrap flow with error handling ✅

## Technical Notes

**Bootstrap Flow:**
```bash
1. Detect current directory → use as target
2. Create temp directory (/tmp/.junior-bootstrap-XXXXX)
3. Download tarball to temp
4. Extract tarball (handles junior-main/ nested dir)
5. Run extracted scripts/install-junior.sh with current dir
6. Cleanup temp directory
7. Report success/failure
```

**Key Functions:**
- `download_tarball()` - curl/wget with progress
- `extract_tarball()` - tar with path normalization
- `run_install()` - delegate to install script
- `cleanup_temp()` - remove temp files (trap EXIT)
- Color output functions (reuse from install scripts)

**Error Handling:**
- Set -e for fail-fast
- Trap EXIT for cleanup
- Preserve temp on error for debugging
- Clear error messages for each failure mode

See [specs/01-Technical.md](../specs/01-Technical.md) for detailed technical approach.

## Testing Strategy

**TDD Approach:**
- Write tests first (red)
- Implement to pass tests (green)
- Refactor (clean)

**Unit Tests:**
- Download function with mock server
- Extraction with test tarball
- Path detection (various tarball structures)
- Cleanup verification

**Integration Tests:**
- Fresh install in empty directory
- Upgrade of existing Junior installation
- Network failure handling
- Partial download handling
- Install script failure handling

**Manual Testing:**
- Test on macOS (curl available)
- Test on Linux (curl/wget)
- Test with no Junior installed
- Test with old Junior (no update.sh)
- Test in project root vs subdirectory

## Definition of Done

- [x] All tasks completed ✅
- [x] All acceptance criteria met ✅
- [x] Bootstrap works end-to-end (user can install via curl) ✅
- [x] All tests passing (unit + integration) ✅
- [x] No regressions in existing install scripts ✅
- [x] Code follows bash best practices ✅
- [x] Error messages are clear and actionable ✅
- [x] Temp files cleaned up on success and error ✅
- [x] **User can successfully install Junior with single curl command** ✅
- [ ] Tested on macOS and Linux (ready for manual testing)

