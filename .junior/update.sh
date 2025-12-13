#!/bin/bash

# Junior Update Script
# Usage: ./.junior/update.sh [options]
# Options:
#   --check-only    Only check for updates (don't install)
#   --force         Skip confirmation prompts
#   -v, --verbose   Show detailed update output
# Compatible with bash 3.2+ (macOS default)

set -e  # Exit on any error

# Colors for output (matching install-junior.sh style)
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verbose flag (default: false)
VERBOSE=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Debug output (only shown with --verbose)
print_debug() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# Function to prompt for confirmation
confirm_prompt() {
    local message="$1"
    echo -e "${YELLOW}$message${NC}"
    read -p "Continue? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
    return 0
}

# GitHub configuration
GITHUB_OWNER="rusi"
GITHUB_REPO="junior"
GITHUB_BRANCH="main"
METADATA_FILE=".junior/.junior-install.json"

# Function to read current version from metadata file
read_current_version() {
    if [ ! -f "$METADATA_FILE" ]; then
        print_error "Junior installation not found"
        print_error "Metadata file missing: $METADATA_FILE"
        print_status "Please install Junior first using the installation script"
        return 1
    fi

    # Verify jq is available
    if ! command -v jq &> /dev/null; then
        print_error "jq is required but not installed"
        print_status "Install jq with:"
        print_status "  macOS: brew install jq"
        print_status "  Ubuntu/Debian: sudo apt-get install jq"
        return 1
    fi

    # Read metadata
    local version=$(jq -r '.version // ""' "$METADATA_FILE" 2>/dev/null)
    local commit_hash=$(jq -r '.commit_hash // ""' "$METADATA_FILE" 2>/dev/null)
    local installed_at=$(jq -r '.installed_at // ""' "$METADATA_FILE" 2>/dev/null)

    # Validate required fields
    if [ -z "$version" ] || [ -z "$commit_hash" ]; then
        print_error "Invalid metadata file: missing required fields"
        return 1
    fi

    # Export for use by other functions
    export CURRENT_VERSION="$version"
    export CURRENT_COMMIT="$commit_hash"
    export CURRENT_INSTALLED_AT="$installed_at"

    return 0
}

# Function to query GitHub API for latest commit
query_github_latest() {
    local api_url="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/commits/${GITHUB_BRANCH}"

    print_status "Checking for updates from GitHub..."

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        return 1
    fi

    # Query GitHub API
    local response=$(curl -s -f "$api_url" 2>/dev/null)
    local curl_exit=$?

    # Check for network/API errors
    if [ $curl_exit -ne 0 ] || [ -z "$response" ]; then
        print_error "Failed to connect to GitHub API"
        print_status "Please check your internet connection and try again"
        return 1
    fi

    # Check for rate limit
    local message=$(echo "$response" | jq -r '.message // ""' 2>/dev/null)
    if [[ "$message" == *"rate limit"* ]]; then
        print_error "GitHub API rate limit exceeded"
        print_status "Please wait an hour or use a GitHub token for higher limits"
        return 1
    fi

    # Parse response
    local latest_sha=$(echo "$response" | jq -r '.sha // ""' 2>/dev/null)
    local latest_date=$(echo "$response" | jq -r '.commit.committer.date // ""' 2>/dev/null)

    # Validate response
    if [ -z "$latest_sha" ]; then
        print_error "Invalid response from GitHub API"
        return 1
    fi

    # Export for use by other functions
    export LATEST_COMMIT="$latest_sha"
    export LATEST_DATE="$latest_date"

    return 0
}

# Function to compare versions and display status
compare_and_report() {
    echo ""
    print_status "═══════════════════════════════════════════════════"
    print_status "Junior Version Check"
    print_status "═══════════════════════════════════════════════════"
    echo ""

    # Display current version
    print_status "Current version:"
    echo "  Commit: ${CURRENT_COMMIT:0:7}"
    echo "  Installed: $CURRENT_INSTALLED_AT"
    echo ""

    # Display latest version
    print_status "Latest version:"
    echo "  Commit: ${LATEST_COMMIT:0:7}"
    echo "  Date: $LATEST_DATE"
    echo ""

    # Compare versions
    if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
        print_success "✓ Junior is up-to-date!"
        echo ""
        return 0
    else
        print_warning "⚠ Update available!"
        echo ""
        return 2
    fi
}

# Function to download tarball from GitHub
download_tarball() {
    local temp_dir="$1"
    local tarball_url="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/archive/refs/heads/${GITHUB_BRANCH}.tar.gz"
    local tarball_path="$temp_dir/junior.tar.gz"

    print_status "Downloading Junior from GitHub..."
    echo "  URL: $tarball_url"
    echo ""

    # Download with progress indicator
    if ! curl -L -f --progress-bar -o "$tarball_path" "$tarball_url" 2>&1; then
        print_error "Failed to download tarball from GitHub"
        print_status "Please check your internet connection and try again"
        return 1
    fi

    # Verify download succeeded and file is not empty
    if [ ! -f "$tarball_path" ] || [ ! -s "$tarball_path" ]; then
        print_error "Downloaded file is missing or empty"
        return 1
    fi

    print_success "✓ Download complete"
    echo ""

    return 0
}

# Function to create tarball from local source directory (for testing)
make_tarball_from_local_source() {
    local temp_dir="$1"
    local source_dir="$2"
    local tarball_path="$temp_dir/junior.tar.gz"

    print_debug "Creating tarball from local source: $source_dir"

    # Verify source directory exists and looks like Junior
    if [ ! -d "$source_dir" ]; then
        print_error "Source directory does not exist: $source_dir"
        return 1
    fi

    if [ ! -f "$source_dir/.cursor/rules/00-junior.mdc" ]; then
        print_error "Source directory does not appear to be Junior repository"
        print_status "Expected to find: $source_dir/.cursor/rules/00-junior.mdc"
        return 1
    fi

    # Create tarball with same structure as GitHub (nested directory)
    # GitHub creates: junior-main/
    # We'll create: junior-local/
    local staging_dir="$temp_dir/staging"
    local nested_dir="$staging_dir/junior-local"

    mkdir -p "$nested_dir"

    # Copy source files (excluding .git, temp files, etc.)
    print_debug "Copying source files..."
    rsync -a \
        --exclude='.git' \
        --exclude='.junior/.junior-install.json' \
        --exclude='*.pyc' \
        --exclude='__pycache__' \
        --exclude='.DS_Store' \
        "$source_dir/" "$nested_dir/"

    # Create tarball
    print_debug "Creating tarball..."
    if ! tar -czf "$tarball_path" -C "$staging_dir" junior-local 2>&1; then
        print_error "Failed to create tarball"
        rm -rf "$staging_dir"
        return 1
    fi

    # Clean up staging directory
    rm -rf "$staging_dir"

    # Verify tarball
    if [ ! -f "$tarball_path" ] || [ ! -s "$tarball_path" ]; then
        print_error "Tarball creation failed or file is empty"
        return 1
    fi

    print_debug "✓ Tarball created from local source"

    return 0
}

# Function to extract tarball and find extracted directory
extract_tarball() {
    local temp_dir="$1"
    local tarball_path="$temp_dir/junior.tar.gz"

    print_debug "Extracting tarball..."

    # Extract tarball
    if ! tar -xzf "$tarball_path" -C "$temp_dir" 2>&1; then
        print_error "Failed to extract tarball"
        print_status "The downloaded file may be corrupted"
        return 1
    fi

    # Find extracted directory (GitHub creates nested directory like junior-main/)
    local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "${GITHUB_REPO}-*" | head -n 1)

    # Verify directory was found
    if [ -z "$extracted_dir" ] || [ ! -d "$extracted_dir" ]; then
        print_error "Could not find extracted directory"
        print_status "Expected directory pattern: ${GITHUB_REPO}-*"
        return 1
    fi

    # Export for use by other functions
    export EXTRACTED_DIR="$extracted_dir"

    print_debug "✓ Extraction complete (path: $extracted_dir)"

    return 0
}

# Function to run install script from extracted source
run_install() {
    local extracted_dir="$1"
    local project_root="$2"

    print_debug "Running install script (source: $extracted_dir, target: $project_root)"

    # Verify install script exists
    local install_script="$extracted_dir/scripts/install-junior.sh"
    if [ ! -f "$install_script" ]; then
        print_error "Install script not found: $install_script"
        return 1
    fi

    # Make install script executable
    chmod +x "$install_script"

    # Run install script
    # Note: No flags needed because:
    #   - Install script auto-detects non-git repos (tarball) and handles gracefully
    #   - Install script auto-detects existing installation and runs upgrade mode
    #   - No confirmation prompts during upgrades (only on fresh installs with Code Captain)
    if ! "$install_script" "$project_root" 2>&1; then
        print_error "Install script failed"
        print_status "Check the output above for details"
        return 1
    fi

    print_success "✓ Installation complete"
    echo ""

    return 0
}

# Parse arguments
CHECK_ONLY=false
FORCE=false
LOCAL_SOURCE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        --local-source)
            LOCAL_SOURCE="$2"
            if [ -z "$LOCAL_SOURCE" ]; then
                print_error "--local-source requires a directory path"
                exit 1
            fi
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose        Show detailed update output"
            echo "  --check-only         Check for updates without installing"
            echo "  -f, --force          Skip confirmation prompts"
            echo "  --local-source <dir> Update from local source directory (testing)"
            echo ""
            exit 1
            ;;
    esac
done

# Validate --local-source if provided
if [ -n "$LOCAL_SOURCE" ]; then
    # Convert to absolute path
    LOCAL_SOURCE=$(cd "$LOCAL_SOURCE" 2>/dev/null && pwd)
    if [ $? -ne 0 ]; then
        print_error "Local source directory does not exist or is not accessible"
        exit 1
    fi

    print_warning "═══════════════════════════════════════════════════"
    print_warning "TEST MODE: Using local source directory"
    print_warning "Source: $LOCAL_SOURCE"
    print_warning "═══════════════════════════════════════════════════"
    echo ""
fi

# Main update flow
print_status "Junior Update"
echo ""

# Step 1: Read current version
if ! read_current_version; then
    exit 1
fi

# Step 2: Query GitHub for latest version
if ! query_github_latest; then
    exit 1
fi

# Step 3: Compare versions
set +e
compare_and_report
version_check_result=$?
set -e

# If up-to-date or check-only mode, exit here
if [ $version_check_result -eq 0 ]; then
    # Already up-to-date
    exit 0
fi

if [ "$CHECK_ONLY" = true ]; then
    # Check-only mode, don't proceed with update
    print_status "Use './.junior/update.sh' (without --check-only) to install update"
    echo ""
    exit 2
fi

# Step 4: Confirm update (unless --force)
if [ "$FORCE" != true ]; then
    echo ""
    if ! confirm_prompt "Download and install Junior update?"; then
        print_status "Update cancelled by user"
        exit 0
    fi
    echo ""
fi

# Step 5: Create temp directory with cleanup trap
TEMP_DIR=$(mktemp -d /tmp/.junior-update-XXXXX)

# Track whether update succeeded
UPDATE_SUCCESS=false

cleanup_on_exit() {
    if [ "$UPDATE_SUCCESS" = true ]; then
        # Success - clean up temp directory
        if [ -d "$TEMP_DIR" ]; then
            rm -rf "$TEMP_DIR"
        fi
    else
        # Failure - preserve temp directory for debugging
        if [ -d "$TEMP_DIR" ]; then
            print_error "Update failed!"
            print_status "Temporary files preserved for debugging: $TEMP_DIR"
            print_status "After reviewing, remove with: rm -rf $TEMP_DIR"
        fi
    fi
}

trap cleanup_on_exit EXIT

# Step 6: Download or create tarball
if [ -n "$LOCAL_SOURCE" ]; then
    # Test mode: create tarball from local source
    if ! make_tarball_from_local_source "$TEMP_DIR" "$LOCAL_SOURCE"; then
        exit 1
    fi
else
    # Normal mode: download from GitHub
    if ! download_tarball "$TEMP_DIR"; then
        exit 1
    fi
fi

# Step 7: Extract tarball
if ! extract_tarball "$TEMP_DIR"; then
    exit 1
fi

# Step 8: Write git hash file for version tracking
if [ -n "$LOCAL_SOURCE" ]; then
    # Local source mode: try to get git info from source directory
    print_status "Reading version info from local source..."
    if [ -d "$LOCAL_SOURCE/.git" ]; then
        local_commit=$(cd "$LOCAL_SOURCE" && git rev-parse HEAD 2>/dev/null || echo "local-test")
        local_date=$(cd "$LOCAL_SOURCE" && git log -1 --format=%cI 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
        local_timestamp=$(cd "$LOCAL_SOURCE" && git log -1 --format=%ct 2>/dev/null || date -u +%s)

        cat > "$EXTRACTED_DIR/.githash" <<EOF
COMMIT_HASH=$local_commit
COMMIT_DATE=$local_date
COMMIT_TIMESTAMP=$local_timestamp
EOF
        print_debug "Version info from local git repository (commit: ${local_commit:0:7}, date: $local_date)"
    else
        cat > "$EXTRACTED_DIR/.githash" <<EOF
COMMIT_HASH=local-test
COMMIT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_TIMESTAMP=$(date -u +%s)
EOF
        print_warning "Local source has no git repository - using test values"
    fi
else
    # Normal mode: use GitHub API data
    cat > "$EXTRACTED_DIR/.githash" <<EOF
COMMIT_HASH=$LATEST_COMMIT
COMMIT_DATE=$LATEST_DATE
COMMIT_TIMESTAMP=$(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$LATEST_DATE" +%s 2>/dev/null || echo "unknown")
EOF
    print_status "Git hash info written for version tracking"
    echo "  Commit: ${LATEST_COMMIT:0:7}"
    echo "  Date: $LATEST_DATE"
    echo ""
fi

# Step 9: Determine project root (parent of .junior directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Step 10: Run install script
if ! run_install "$EXTRACTED_DIR" "$PROJECT_ROOT"; then
    exit 1
fi

# Mark update as successful
UPDATE_SUCCESS=true

# Step 11: Success message
echo ""
print_success "✓ Junior updated successfully!"
echo ""
print_status "Updated to commit: ${LATEST_COMMIT:0:7}"
if [ "$VERBOSE" = true ]; then
    print_debug "Temporary files cleaned up"
fi
echo ""

exit 0
