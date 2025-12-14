#!/bin/bash

# Junior Bootstrap Script
# Install or update Junior with a single command:
#   curl -LsSf https://USER.github.io/junior/install.sh | sh
#
# This script downloads the latest Junior release, extracts it,
# and runs the install script with the current directory as target.

set -e  # Exit on any error

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_VERSION="2025-12-14 00:55:38 UTC"

GITHUB_REPO="rusi/junior"
GITHUB_BRANCH="main"
TARBALL_URL="https://github.com/${GITHUB_REPO}/archive/refs/heads/${GITHUB_BRANCH}.tar.gz"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# ============================================================================
# Output Functions
# ============================================================================

print_status() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# ============================================================================
# Core Functions
# ============================================================================

# Query GitHub API for latest commit info
query_github_latest() {
    local api_url="https://api.github.com/repos/${GITHUB_REPO}/commits/${GITHUB_BRANCH}"

    print_status "Fetching version info from GitHub..."

    # Check if curl is available (should be, since we need it for download too)
    if ! command -v curl &> /dev/null; then
        return 1
    fi

    # Query GitHub API (silently fail on errors - not critical for bootstrap)
    local response=$(curl -s -f "$api_url" 2>/dev/null)
    local curl_exit=$?

    # Check for network/API errors
    if [ $curl_exit -ne 0 ] || [ -z "$response" ]; then
        return 1
    fi

    # Use grep/sed extraction (more robust than jq for this case)
    # GitHub API response may contain control characters in commit messages that break jq
    # Note: JSON has spaces around colons: "sha": "value"
    LATEST_COMMIT=$(echo "$response" | grep -o '"sha"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"sha"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')
    LATEST_DATE=$(echo "$response" | grep '"date"' | grep -o '"date"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"date"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')

    # Validate response
    if [ -z "$LATEST_COMMIT" ]; then
        return 1
    fi

    return 0
}

# Download tarball using curl or wget
download_tarball() {
    local url="$1"
    local dest="$2"

    if command -v curl &> /dev/null; then
        curl -LsSf "$url" -o "$dest"
        return $?
    elif command -v wget &> /dev/null; then
        wget -qO "$dest" "$url"
        return $?
    else
        print_error "Neither curl nor wget found. Please install one of them."
        return 1
    fi
}

# Extract tarball to destination directory
extract_tarball() {
    local tarball="$1"
    local dest_dir="$2"

    tar -xzf "$tarball" -C "$dest_dir"
    return $?
}

# Run install script from extracted directory
run_install() {
    local extracted_dir="$1"
    local target_dir="$2"

    if [ ! -f "$extracted_dir/scripts/install-junior.sh" ]; then
        print_error "Install script not found in extracted directory"
        return 1
    fi

    cd "$extracted_dir"
    ./scripts/install-junior.sh "$target_dir"
    return $?
}

# Main bootstrap flow
main() {
    print_status "Installing Junior..."
    print_status "Bootstrap script version: $SCRIPT_VERSION"

    # Detect current directory as target
    TARGET_DIR="$(pwd)"
    print_status "Target directory: $TARGET_DIR"

    # Create temporary directory
    TEMP_DIR=$(mktemp -d /tmp/.junior-bootstrap-XXXXX)
    print_status "Using temp directory: $TEMP_DIR"

    # Setup cleanup trap
    trap "rm -rf $TEMP_DIR" EXIT

    # Query GitHub for latest commit info (best effort, continue on failure)
    if ! query_github_latest; then
        # Silently fall back to unknown - version tracking not critical for bootstrap
        LATEST_COMMIT="unknown"
        LATEST_DATE="unknown"
    fi

    # Download tarball
    print_status "Downloading Junior..."
    TARBALL_FILE="$TEMP_DIR/junior.tar.gz"
    if ! download_tarball "$TARBALL_URL" "$TARBALL_FILE"; then
        print_error "Failed to download Junior tarball"
        exit 1
    fi
    print_status "Download complete"

    # Extract tarball
    print_status "Extracting..."
    if ! extract_tarball "$TARBALL_FILE" "$TEMP_DIR"; then
        print_error "Failed to extract tarball"
        exit 1
    fi

    # Find extracted directory (handles junior-main, junior-master, etc.)
    EXTRACTED_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "junior-*" | head -1)
    if [ -z "$EXTRACTED_DIR" ]; then
        print_error "Could not find extracted Junior directory"
        exit 1
    fi
    print_status "Extracted to: $EXTRACTED_DIR"

    # Write git hash file for version tracking (always create, even if API failed)
    if [ "$LATEST_COMMIT" != "unknown" ]; then
        # Calculate timestamp from date
        if command -v date &> /dev/null; then
            # Try to convert ISO date to timestamp
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS date command
                COMMIT_TIMESTAMP=$(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$LATEST_DATE" +%s 2>/dev/null || echo "unknown")
            else
                # GNU date command
                COMMIT_TIMESTAMP=$(date -u -d "$LATEST_DATE" +%s 2>/dev/null || echo "unknown")
            fi
        else
            COMMIT_TIMESTAMP="unknown"
        fi

    else
        # API failed - use unknown values but still create file to suppress warning
        COMMIT_TIMESTAMP="unknown"
    fi

    # Always create .githash file (prevents "not a git repository" warning)
    cat > "$EXTRACTED_DIR/.githash" <<EOF
COMMIT_HASH=$LATEST_COMMIT
COMMIT_DATE=$LATEST_DATE
COMMIT_TIMESTAMP=$COMMIT_TIMESTAMP
EOF

    # Run install script
    print_status "Running install script..."
    if ! run_install "$EXTRACTED_DIR" "$TARGET_DIR"; then
        print_error "Installation failed"
        exit 1
    fi

    # Success!
    print_success "Junior bootstrap complete!"
    print_status "Junior has been installed to: $TARGET_DIR"
}

# ============================================================================
# Entry Point
# ============================================================================

main "$@"

