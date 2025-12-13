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

GITHUB_REPO="USER/junior"
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
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================================================
# Core Functions
# ============================================================================

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

    # Detect current directory as target
    TARGET_DIR="$(pwd)"
    print_status "Target directory: $TARGET_DIR"

    # Create temporary directory
    TEMP_DIR=$(mktemp -d /tmp/.junior-bootstrap-XXXXX)
    print_status "Using temp directory: $TEMP_DIR"

    # Setup cleanup trap
    trap "rm -rf $TEMP_DIR" EXIT

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

