#!/bin/bash

# Junior Update Script
# Usage: ./.junior/update.sh [--check-only] [--force]
# Compatible with bash 3.2+ (macOS default)

set -e  # Exit on any error

# Colors for output (matching install-junior.sh style)
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
        print_status "To update Junior, run:"
        echo "  ./.junior/update.sh --update"
        echo ""
        print_status "(Full update functionality coming in Story 2)"
        echo ""
        return 2
    fi
}

# Parse arguments
CHECK_ONLY=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --update)
            print_error "Full update functionality not yet implemented"
            print_status "This will be available in Story 2"
            exit 1
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --check-only    Check for updates without installing"
            echo "  --force         Skip confirmation prompts"
            echo ""
            exit 1
            ;;
    esac
done

# Main version check flow
print_status "Junior Update - Version Check"
echo ""

# Step 1: Read current version
if ! read_current_version; then
    exit 1
fi

# Step 2: Query GitHub for latest version
if ! query_github_latest; then
    exit 1
fi

# Step 3: Compare and report
compare_and_report
exit $?
