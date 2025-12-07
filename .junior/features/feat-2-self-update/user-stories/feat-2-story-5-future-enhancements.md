# Story 5: Future Enhancements & Follow-up Work

> **Status:** Not Started
> **Priority:** Low (Backlog)
> **Dependencies:** All previous stories completed
> **Deliverable:** Captured future work items for consideration in later iterations

## Purpose

This story captures features, enhancements, and technical considerations that were identified during feature planning but intentionally excluded from the initial scope. These items should be reviewed and potentially implemented in future iterations once the core update feature is stable.

## Out-of-Scope Features

### Automatic Update Notifications
**Context:** Currently users must manually run update script to check for updates.

**Enhancement:** Display "Update available" message when running Junior commands (e.g., `/status`, `/feature`).

**Implementation Ideas:**
- Periodic version check (cached with TTL)
- Display non-intrusive update notification
- Optional: Auto-check on first command of the day

**Complexity:** Medium (requires caching mechanism, background check)

### Rollback Mechanism
**Context:** No way to revert to previous Junior version if update causes issues.

**Enhancement:** Support rollback to previous version.

**Implementation Ideas:**
- Backup current installation before update (store in `.junior/.backup/`)
- Add `--rollback` flag to restore previous version
- Track version history in metadata

**Complexity:** Medium (requires backup/restore logic, version tracking)

### Update to Specific Version
**Context:** Can only update to latest main branch.

**Enhancement:** Allow updating to specific commit/tag/branch.

**Implementation Ideas:**
```bash
./.junior/update.sh --version v1.2.3
./.junior/update.sh --commit abc1234
./.junior/update.sh --branch develop
```

**Complexity:** Low (modify GitHub URL construction)

### Support for Forked Repositories
**Context:** Hardcoded to official Junior repository.

**Enhancement:** Allow users to update from their fork.

**Implementation Ideas:**
- Store GitHub repo URL in `.junior/.junior-install.json`
- Add `--repo` flag: `./.junior/update.sh --repo username/junior-fork`
- Detect fork during initial installation

**Complexity:** Low (make repo URL configurable)

### Offline Update
**Context:** Requires internet connection to GitHub.

**Enhancement:** Support offline update via local tarball.

**Implementation Ideas:**
```bash
./.junior/update.sh --local /path/to/junior.tar.gz
```

**Complexity:** Low (skip download, use provided tarball)

### GitHub Token Support
**Context:** Limited to 60 API requests/hour (unauthenticated).

**Enhancement:** Support GitHub personal access token for higher rate limits.

**Implementation Ideas:**
- Read token from environment: `GITHUB_TOKEN`
- Pass token in API requests: `Authorization: Bearer $GITHUB_TOKEN`
- Document in README

**Complexity:** Low (add header to API calls)

### Check-Only Mode
**Context:** Version check always leads to update prompt.

**Enhancement:** Add flag to check version without offering to update.

**Implementation Ideas:**
```bash
./.junior/update.sh --check-only
```

**Complexity:** Low (exit after version comparison)

## Technical Debt Considerations

### Cross-Platform Testing
**Issue:** Manual testing on macOS, Linux, Windows required.

**Future Work:** Automated CI testing on multiple platforms (GitHub Actions).

### Tarball Integrity Verification
**Issue:** No checksum verification of downloaded tarball.

**Future Work:** Download and verify GitHub-provided checksums or signatures.

### Progress Indicators
**Issue:** Basic "Downloading..." message, no progress bar.

**Future Work:** Add curl/wget progress bar or percentage indicator.

### Update Script Self-Update
**Issue:** Update script updates itself but may have breaking changes.

**Future Work:** Version update script, handle breaking changes gracefully.

## Enhancement Opportunities

### Better Error Messages
**Opportunity:** More specific error messages for common failures.

**Ideas:**
- Detect and suggest: "GitHub API rate limit exceeded. Try again in X minutes."
- Network issues: "Cannot reach GitHub. Check internet connection."
- Permission issues: "Cannot write to .junior/. Check file permissions."

### Dry-Run Mode
**Opportunity:** Preview what update would do without making changes.

**Ideas:**
```bash
./.junior/update.sh --dry-run
```
Shows: Files to update, version change, no actual modifications.

### Update Changelog Display
**Opportunity:** Show what changed between current and latest version.

**Ideas:**
- Fetch commit messages from GitHub API
- Display bullet points of changes
- Link to full changelog

### Parallel Platform Support
**Opportunity:** Improve PowerShell script maintenance workflow.

**Ideas:**
- Share test cases between bash and PowerShell
- Automated parity checks
- Document platform-specific differences

## Follow-up Work

### Performance Optimization
**Task:** Benchmark version check and download times.

**Goal:** Ensure <2 second check, <30 second full update on typical connections.

### Documentation Expansion
**Task:** Create troubleshooting guide for common update issues.

**Content:**
- GitHub API rate limiting
- Network proxy configuration
- Corporate firewall issues
- Offline scenarios

### User Feedback Collection
**Task:** Gather feedback on update experience after initial release.

**Questions:**
- Is update process clear?
- Any confusing error messages?
- Missing features?
- Performance issues?

### Analytics (Optional)
**Task:** Track update success/failure rates (privacy-respecting).

**Goal:** Identify common failure modes and improve reliability.

