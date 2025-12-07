# Technical Specification

## Overview

Bootstrap mechanism for remote installation/update of Junior via GitHub Pages. Provides thin wrapper scripts that download the latest Junior release tarball and delegate to existing install scripts. Enables single-command install/update without requiring repository clone.

## Architecture

```
User Workflow:
┌─────────────────────────────────────────────────────┐
│ User runs: curl -LsSf <url>/install.sh | sh        │
└─────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│ GitHub Pages (docs/install.sh)                      │
│ ├─ Download tarball from GitHub                    │
│ ├─ Extract to temp directory                       │
│ ├─ Run scripts/install-junior.sh (current dir)     │
│ └─ Cleanup temp directory                          │
└─────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│ scripts/install-junior.sh (from tarball)            │
│ ├─ Detect: Fresh install or upgrade?               │
│ ├─ Handle conflicts (feat-1 logic)                 │
│ ├─ Install files to current directory              │
│ └─ Update .junior/.junior-install.json             │
└─────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│ Result: Junior installed/updated in current dir    │
│ ├─ .cursor/rules/ (Junior rules)                   │
│ ├─ .cursor/commands/ (Junior commands)             │
│ ├─ .junior/ (working memory + metadata)            │
│ └─ .junior/update.sh (for future updates)          │
└─────────────────────────────────────────────────────┘

Directory Structure:
/Users/rusi/Sources/junior/
├── docs/
│   ├── install.sh       # Bash bootstrap (served via GitHub Pages)
│   ├── install.ps1      # PowerShell bootstrap (served via GitHub Pages)
│   └── index.html       # (optional) Landing page
├── scripts/
│   ├── install-junior.sh   # Existing install script (feat-1)
│   └── install-junior.ps1  # Existing install script (feat-1)
└── .junior/
    ├── update.sh        # Self-update script (feat-2, installed by feat-1)
    └── update.ps1       # Self-update script (feat-2, installed by feat-1)
```

## Components

### Bootstrap Script (Bash: `docs/install.sh`)

**Responsibility:** Download Junior tarball and delegate to install script

**Interface:**
- Executed via: `curl -LsSf <url>/install.sh | sh`
- Target: Current directory (`$(pwd)`)
- Exit codes: 0 (success), 1 (error)

**Dependencies:**
- `curl` or `wget` (download)
- `tar` (extraction)
- Bash 3.2+ (macOS compatibility)

**Core Logic:**
```bash
#!/bin/bash
set -e

# Constants
GITHUB_REPO="USER/junior"
GITHUB_BRANCH="main"
TARBALL_URL="https://github.com/${GITHUB_REPO}/archive/refs/heads/${GITHUB_BRANCH}.tar.gz"
TEMP_DIR=$(mktemp -d /tmp/.junior-bootstrap-XXXXX)

# Cleanup trap
trap "rm -rf $TEMP_DIR" EXIT

# Main flow
main() {
    print_status "Installing Junior..."
    
    # 1. Download tarball
    download_tarball "$TARBALL_URL" "$TEMP_DIR/junior.tar.gz"
    
    # 2. Extract (handles nested junior-main/ directory)
    extract_tarball "$TEMP_DIR/junior.tar.gz" "$TEMP_DIR"
    
    # 3. Find extracted directory (junior-main or junior-master)
    EXTRACTED_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "junior-*" | head -1)
    
    # 4. Run install script with current directory
    TARGET_DIR="$(pwd)"
    cd "$EXTRACTED_DIR"
    ./scripts/install-junior.sh "$TARGET_DIR"
    
    print_success "Installation complete!"
}

main
```

**Functions:**
```bash
download_tarball() {
    local url="$1"
    local dest="$2"
    
    if command -v curl &> /dev/null; then
        curl -LsSf "$url" -o "$dest"
    elif command -v wget &> /dev/null; then
        wget -qO "$dest" "$url"
    else
        print_error "Neither curl nor wget found"
        exit 1
    fi
}

extract_tarball() {
    local tarball="$1"
    local dest_dir="$2"
    
    tar -xzf "$tarball" -C "$dest_dir"
}

print_status() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}
```

### Bootstrap Script (PowerShell: `docs/install.ps1`)

**Responsibility:** Same as bash, PowerShell implementation

**Interface:**
- Executed via: `irm <url>/install.ps1 | iex`
- Target: Current location (`$PWD`)
- Exit codes: Same as bash

**Dependencies:**
- PowerShell 5.1+ (Windows built-in)
- `tar` (Windows 10+) or Expand-Archive

**Core Logic:**
```powershell
$ErrorActionPreference = "Stop"

# Constants
$GitHubRepo = "USER/junior"
$GitHubBranch = "main"
$TarballUrl = "https://github.com/$GitHubRepo/archive/refs/heads/$GitHubBranch.tar.gz"
$TempDir = New-Item -ItemType Directory -Path "$env:TEMP\.junior-bootstrap-$(Get-Random)" -Force

try {
    Write-Status "Installing Junior..."
    
    # 1. Download tarball
    $TarballPath = Join-Path $TempDir "junior.tar.gz"
    Invoke-WebRequest -Uri $TarballUrl -OutFile $TarballPath
    
    # 2. Extract
    if (Get-Command tar -ErrorAction SilentlyContinue) {
        tar -xzf $TarballPath -C $TempDir
    } else {
        # Fallback: Convert to .zip or use Expand-Archive
        Expand-Archive -Path $TarballPath -DestinationPath $TempDir
    }
    
    # 3. Find extracted directory
    $ExtractedDir = Get-ChildItem -Path $TempDir -Directory | Where-Object { $_.Name -like "junior-*" } | Select-Object -First 1
    
    # 4. Run install script
    $TargetDir = $PWD.Path
    Set-Location $ExtractedDir.FullName
    & ".\scripts\install-junior.ps1" -TargetPath $TargetDir
    
    Write-Success "Installation complete!"
    
} finally {
    # Cleanup
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}
```

### GitHub Pages Configuration

**Setup:**
1. Repository Settings → Pages
2. Source: Deploy from branch
3. Branch: `main`, Folder: `/docs`
4. Custom domain: (optional, future enhancement)

**URLs:**
- Bash: `https://USER.github.io/junior/install.sh`
- PowerShell: `https://USER.github.io/junior/install.ps1`
- Landing: `https://USER.github.io/junior/` (optional index.html)

**Files in `/docs`:**
```
docs/
├── install.sh      # Bash bootstrap (executable permissions not needed for download)
├── install.ps1     # PowerShell bootstrap
└── index.html      # (optional) Landing page with install instructions
```

### Integration with Existing Install Scripts

**Current Directory Handling:**
```bash
# Bootstrap script
TARGET_DIR="$(pwd)"
./scripts/install-junior.sh "$TARGET_DIR"

# Install script (feat-1) already supports target directory
# No changes needed - it handles fresh install and upgrade
```

**Upgrade Detection:**
- Install script checks for `.junior/.junior-install.json`
- If exists → upgrade mode (preserve user-modified files)
- If not exists → fresh install mode

**feat-2 Integration:**
- After install, `.junior/update.sh` exists (from feat-1)
- Future updates: User runs `.junior/update.sh` directly
- Bootstrap only needed for: fresh install OR pre-feat-2 upgrade

## Design Decisions

### Thin Bootstrap Philosophy

**Context:** How much logic should bootstrap contain?

**Decision:** Minimal - only download, extract, delegate

**Rationale:**
- DRY: Don't duplicate install logic
- Maintainability: One source of truth (install scripts)
- Simplicity: Bootstrap is easy to understand and audit
- Trust: Users can inspect bootstrap before running

**Alternatives Considered:**
- Full installation logic in bootstrap: Would duplicate feat-1, hard to maintain
- Multi-stage bootstrap: Unnecessary complexity for simple task

### Current Directory as Target

**Context:** Bootstrap runs piped from curl (no stdin for prompts)

**Decision:** Use current directory automatically

**Rationale:**
- Matches uv's behavior (familiar pattern)
- User controls via `cd` before running command
- No stdin needed (works with piping)
- Clear mental model: "Install Junior here"

**Alternatives Considered:**
- Prompt for directory: Can't work with piped stdin
- Auto-detect git root: Too magical, user might not want git root
- Home directory default: Wrong for project-specific tool

### GitHub Pages from /docs

**Context:** Where to host bootstrap scripts?

**Decision:** GitHub Pages serving from `/docs` directory

**Rationale:**
- No separate branch needed (docs/ in main branch)
- Easy to maintain (scripts live with code)
- Version control for bootstrap (same repo)
- Free hosting (GitHub Pages)

**Alternatives Considered:**
- `gh-pages` branch: Separate branch, harder to maintain
- GitHub raw URLs: Ugly, no caching, not official
- External hosting: Costs money, additional complexity

### Tarball Path Detection

**Context:** GitHub tarball extracts to `junior-main/` or `junior-master/`

**Decision:** Detect dynamically with find

**Rationale:**
- Branch-agnostic (works with main, master, develop)
- Handles renamed default branches
- Robust to GitHub changes

**Implementation:**
```bash
EXTRACTED_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "junior-*" | head -1)
```

### Error Handling Strategy

**Context:** Network failures, extraction errors, etc.

**Decision:** Fail fast, cleanup on EXIT, preserve temp on error for debugging

**Rationale:**
- Safety: Don't partially install
- Debuggability: User/dev can inspect temp files
- Clarity: Specific error messages for each failure

**Implementation:**
```bash
set -e  # Exit on any error
trap "rm -rf $TEMP_DIR" EXIT  # Always cleanup
```

## Testing Strategy

### Unit Tests

**Bash (using bats or custom framework):**
- Download function: curl/wget availability, network errors
- Extract function: Valid tarball, corrupted tarball
- Path detection: Various tarball structures, missing directory
- Cleanup: Temp directory removed on success/error

**PowerShell (using Pester):**
- Same coverage as bash
- Windows-specific: Path separators, temp location, tar availability

### Integration Tests

**Test Scenarios:**
1. Fresh install in empty directory
2. Upgrade existing Junior (with feat-1 only)
3. Upgrade with feat-2 update.sh (should still work)
4. Network failure during download
5. Corrupted tarball (extraction fails)
6. Install script failure (conflicts)
7. Cleanup verification

**Test Setup:**
- Mock GitHub tarball (local test server or file)
- Test projects in various states
- Automated test suite

### Manual Testing

**Checklist:**
- [ ] Fresh install on macOS (bash)
- [ ] Fresh install on Linux (bash)
- [ ] Fresh install on Windows (PowerShell)
- [ ] Upgrade old Junior (no update.sh)
- [ ] Upgrade current Junior (has update.sh)
- [ ] Network failure (disconnect wifi)
- [ ] Wrong directory (not project root)
- [ ] GitHub Pages URL accessible

## Cross-References

- Implements requirements from [feat-3-overview.md](../feat-3-overview.md)
- Delegates to feat-1: [scripts/install-junior.sh](../../../scripts/install-junior.sh)
- Complements feat-2: [.junior/update.sh](../../feat-2-self-update/specs/01-Technical.md)
- Related to Story 1: [Bash Bootstrap](../user-stories/feat-3-story-1-bash-bootstrap.md)
- Related to Story 2: [GitHub Pages + Docs](../user-stories/feat-3-story-2-github-pages-docs.md)
- Related to Story 3: [PowerShell Bootstrap](../user-stories/feat-3-story-3-powershell-bootstrap.md)

## Performance Targets

**Bootstrap Execution:**
- Target: <30 seconds (download + extract + install)
- Breakdown:
  - Download: 10-20s (depends on connection, ~1-2MB tarball)
  - Extract: 1-2s
  - Install: 5-10s (feat-1 install script)
  - Cleanup: <1s

**Benchmarking:**
- Measure with `time` command
- Log timestamps at each step
- Compare against manual clone + install workflow

