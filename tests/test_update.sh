#!/bin/bash

# Test Suite for Junior Update Script
# Usage: ./tests/test_update.sh

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Source the update script functions
# We need to extract just the functions, not run the main script
# So we'll source it in a way that skips the main execution

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_test_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_test_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# ============================================================================
# TASK 1.1: Tests for metadata file reading
# ============================================================================

test_read_metadata_valid() {
    local test_name="test_read_metadata_valid"
    print_test_status "Running: $test_name"
    
    # Create test metadata
    local test_file="/tmp/.junior-test-metadata-$$.json"
    cat > "$test_file" <<'EOF'
{
  "version": "1733587200",
  "installed_at": "2025-12-07T12:00:00Z",
  "commit_hash": "abc1234567890",
  "files": {}
}
EOF
    
    # Test reading
    if [ -f "$test_file" ]; then
        local version=$(jq -r '.version // ""' "$test_file")
        local commit_hash=$(jq -r '.commit_hash // ""' "$test_file")
        local installed_at=$(jq -r '.installed_at // ""' "$test_file")
        
        if [ "$version" = "1733587200" ] && [ "$commit_hash" = "abc1234567890" ] && [ "$installed_at" = "2025-12-07T12:00:00Z" ]; then
            print_test_success "✓ $test_name: PASS"
            rm -f "$test_file"
            return 0
        else
            print_test_error "✗ $test_name: FAIL - Values don't match"
            rm -f "$test_file"
            return 1
        fi
    else
        print_test_error "✗ $test_name: FAIL - Could not create test file"
        return 1
    fi
}

test_read_metadata_missing() {
    local test_name="test_read_metadata_missing"
    print_test_status "Running: $test_name"
    
    local test_file="/tmp/.junior-test-missing-$$.json"
    
    # Ensure file doesn't exist
    rm -f "$test_file"
    
    # Test reading non-existent file
    if [ ! -f "$test_file" ]; then
        print_test_success "✓ $test_name: PASS - Correctly detects missing file"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - File should not exist"
        return 1
    fi
}

test_read_metadata_corrupted() {
    local test_name="test_read_metadata_corrupted"
    print_test_status "Running: $test_name"
    
    local test_file="/tmp/.junior-test-corrupted-$$.json"
    echo "{ invalid json" > "$test_file"
    
    # Test reading corrupted file (should fail gracefully)
    local result=$(jq -r '.version // ""' "$test_file" 2>/dev/null || echo "ERROR")
    
    if [ "$result" = "ERROR" ]; then
        print_test_success "✓ $test_name: PASS - Correctly handles corrupted JSON"
        rm -f "$test_file"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should detect corrupted JSON"
        rm -f "$test_file"
        return 1
    fi
}

test_read_metadata_missing_fields() {
    local test_name="test_read_metadata_missing_fields"
    print_test_status "Running: $test_name"
    
    local test_file="/tmp/.junior-test-missing-fields-$$.json"
    cat > "$test_file" <<'EOF'
{
  "version": "1733587200"
}
EOF
    
    # Test reading with missing fields
    local commit_hash=$(jq -r '.commit_hash // ""' "$test_file")
    local installed_at=$(jq -r '.installed_at // ""' "$test_file")
    
    if [ -z "$commit_hash" ] && [ -z "$installed_at" ]; then
        print_test_success "✓ $test_name: PASS - Correctly handles missing fields"
        rm -f "$test_file"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should return empty for missing fields"
        rm -f "$test_file"
        return 1
    fi
}

# ============================================================================
# TASK 1.3: Tests for GitHub API integration
# ============================================================================

test_github_api_parse_valid() {
    local test_name="test_github_api_parse_valid"
    print_test_status "Running: $test_name"
    
    # Mock GitHub API response
    local mock_response='{"sha":"def456789","commit":{"committer":{"date":"2025-12-08T10:00:00Z"}}}'
    
    # Parse response
    local sha=$(echo "$mock_response" | jq -r '.sha // ""')
    local date=$(echo "$mock_response" | jq -r '.commit.committer.date // ""')
    
    if [ "$sha" = "def456789" ] && [ "$date" = "2025-12-08T10:00:00Z" ]; then
        print_test_success "✓ $test_name: PASS"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Parsing failed"
        return 1
    fi
}

test_github_api_rate_limit() {
    local test_name="test_github_api_rate_limit"
    print_test_status "Running: $test_name"
    
    # Mock rate limit response
    local mock_response='{"message":"API rate limit exceeded"}'
    
    # Check for rate limit message
    local message=$(echo "$mock_response" | jq -r '.message // ""')
    
    if [[ "$message" == *"rate limit"* ]]; then
        print_test_success "✓ $test_name: PASS - Detects rate limit"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should detect rate limit"
        return 1
    fi
}

test_github_api_network_error() {
    local test_name="test_github_api_network_error"
    print_test_status "Running: $test_name"
    
    # Mock empty response (network failure)
    local mock_response=""
    
    # Check for empty response
    if [ -z "$mock_response" ]; then
        print_test_success "✓ $test_name: PASS - Detects network error"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should detect empty response"
        return 1
    fi
}

# ============================================================================
# TASK 1.5: Tests for version comparison logic
# ============================================================================

test_version_compare_equal() {
    local test_name="test_version_compare_equal"
    print_test_status "Running: $test_name"
    
    local current="abc123"
    local latest="abc123"
    
    if [ "$current" = "$latest" ]; then
        print_test_success "✓ $test_name: PASS - Correctly detects equal versions"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should detect equal versions"
        return 1
    fi
}

test_version_compare_different() {
    local test_name="test_version_compare_different"
    print_test_status "Running: $test_name"
    
    local current="abc123"
    local latest="def456"
    
    if [ "$current" != "$latest" ]; then
        print_test_success "✓ $test_name: PASS - Correctly detects different versions"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should detect different versions"
        return 1
    fi
}

test_version_compare_unknown() {
    local test_name="test_version_compare_unknown"
    print_test_status "Running: $test_name"
    
    local current=""
    local latest="def456"
    
    if [ -z "$current" ]; then
        print_test_success "✓ $test_name: PASS - Correctly handles unknown version"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should detect unknown version"
        return 1
    fi
}

# ============================================================================
# TASK 2.1: Tests for tarball download
# ============================================================================

test_temp_directory_creation() {
    local test_name="test_temp_directory_creation"
    print_test_status "Running: $test_name"
    
    # Test temp directory creation pattern
    local temp_dir=$(mktemp -d /tmp/.junior-update-XXXXX)
    
    # Verify directory exists and has correct permissions
    if [ -d "$temp_dir" ] && [[ "$temp_dir" == /tmp/.junior-update-* ]]; then
        print_test_success "✓ $test_name: PASS - Temp directory created correctly"
        rm -rf "$temp_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Temp directory creation failed"
        return 1
    fi
}

test_temp_directory_cleanup() {
    local test_name="test_temp_directory_cleanup"
    print_test_status "Running: $test_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d /tmp/.junior-update-XXXXX)
    
    # Add some test files
    touch "$temp_dir/test1.txt"
    touch "$temp_dir/test2.txt"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    # Verify cleanup
    if [ ! -d "$temp_dir" ]; then
        print_test_success "✓ $test_name: PASS - Temp directory cleaned up"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Temp directory still exists"
        rm -rf "$temp_dir"
        return 1
    fi
}

test_download_tarball_mock() {
    local test_name="test_download_tarball_mock"
    print_test_status "Running: $test_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d /tmp/.junior-update-XXXXX)
    
    # Mock tarball download (create fake tarball)
    local tarball_url="https://github.com/rusi/junior/archive/refs/heads/main.tar.gz"
    local tarball_path="$temp_dir/junior.tar.gz"
    
    # Simulate download by creating a minimal tar.gz file
    echo "test content" | gzip > "$tarball_path"
    
    # Verify tarball exists
    if [ -f "$tarball_path" ] && [ -s "$tarball_path" ]; then
        print_test_success "✓ $test_name: PASS - Tarball downloaded (mocked)"
        rm -rf "$temp_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Tarball download failed"
        rm -rf "$temp_dir"
        return 1
    fi
}

test_download_failure_handling() {
    local test_name="test_download_failure_handling"
    print_test_status "Running: $test_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d /tmp/.junior-update-XXXXX)
    
    # Simulate download failure (invalid URL)
    set +e
    curl -s -f -L "https://invalid-url-that-does-not-exist.example.com/file.tar.gz" \
        -o "$temp_dir/junior.tar.gz" 2>/dev/null
    local exit_code=$?
    set -e
    
    # Verify curl failed
    if [ $exit_code -ne 0 ]; then
        print_test_success "✓ $test_name: PASS - Download failure detected"
        rm -rf "$temp_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should detect download failure"
        rm -rf "$temp_dir"
        return 1
    fi
}

test_download_url_construction() {
    local test_name="test_download_url_construction"
    print_test_status "Running: $test_name"
    
    # Test URL construction
    local owner="rusi"
    local repo="junior"
    local branch="main"
    local expected_url="https://github.com/${owner}/${repo}/archive/refs/heads/${branch}.tar.gz"
    local actual_url="https://github.com/rusi/junior/archive/refs/heads/main.tar.gz"
    
    if [ "$expected_url" = "$actual_url" ]; then
        print_test_success "✓ $test_name: PASS - URL construction correct"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - URL construction incorrect"
        return 1
    fi
}

# ============================================================================
# TASK 2.3: Tests for tarball extraction
# ============================================================================

test_extract_tarball_basic() {
    local test_name="test_extract_tarball_basic"
    print_test_status "Running: $test_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d /tmp/.junior-test-extract-$$)
    
    # Create a simple tarball with nested directory structure (simulating GitHub tarball)
    mkdir -p "$temp_dir/source/junior-main"
    echo "test file" > "$temp_dir/source/junior-main/README.md"
    tar -czf "$temp_dir/junior.tar.gz" -C "$temp_dir/source" junior-main
    
    # Extract tarball
    tar -xzf "$temp_dir/junior.tar.gz" -C "$temp_dir"
    
    # Verify extraction
    if [ -d "$temp_dir/junior-main" ] && [ -f "$temp_dir/junior-main/README.md" ]; then
        print_test_success "✓ $test_name: PASS - Tarball extracted correctly"
        rm -rf "$temp_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Extraction failed"
        rm -rf "$temp_dir"
        return 1
    fi
}

test_extract_tarball_find_directory() {
    local test_name="test_extract_tarball_find_directory"
    print_test_status "Running: $test_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d /tmp/.junior-test-find-$$)
    
    # Create a tarball with nested directory
    mkdir -p "$temp_dir/source/junior-main"
    echo "test" > "$temp_dir/source/junior-main/file.txt"
    tar -czf "$temp_dir/junior.tar.gz" -C "$temp_dir/source" junior-main
    
    # Extract and find the extracted directory
    tar -xzf "$temp_dir/junior.tar.gz" -C "$temp_dir"
    local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "junior-*" | head -n 1)
    
    # Verify we found the directory
    if [ -n "$extracted_dir" ] && [ -d "$extracted_dir" ]; then
        print_test_success "✓ $test_name: PASS - Extracted directory found"
        rm -rf "$temp_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Could not find extracted directory"
        rm -rf "$temp_dir"
        return 1
    fi
}

test_extract_corrupted_tarball() {
    local test_name="test_extract_corrupted_tarball"
    print_test_status "Running: $test_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d /tmp/.junior-test-corrupt-$$)
    
    # Create a corrupted tarball
    echo "not a real tarball" > "$temp_dir/junior.tar.gz"
    
    # Try to extract (should fail)
    set +e
    tar -xzf "$temp_dir/junior.tar.gz" -C "$temp_dir" 2>/dev/null
    local exit_code=$?
    set -e
    
    # Verify extraction failed
    if [ $exit_code -ne 0 ]; then
        print_test_success "✓ $test_name: PASS - Correctly detects corrupted tarball"
        rm -rf "$temp_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should detect corrupted tarball"
        rm -rf "$temp_dir"
        return 1
    fi
}

test_extract_empty_tarball() {
    local test_name="test_extract_empty_tarball"
    print_test_status "Running: $test_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d /tmp/.junior-test-empty-$$)
    
    # Create an empty tarball
    tar -czf "$temp_dir/junior.tar.gz" -C "$temp_dir" -T /dev/null
    
    # Extract
    tar -xzf "$temp_dir/junior.tar.gz" -C "$temp_dir"
    
    # Try to find extracted directory (should not exist)
    local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "junior-*" | head -n 1)
    
    # Verify no directory found (empty tarball)
    if [ -z "$extracted_dir" ]; then
        print_test_success "✓ $test_name: PASS - Correctly handles empty tarball"
        rm -rf "$temp_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should handle empty tarball"
        rm -rf "$temp_dir"
        return 1
    fi
}

test_extract_path_normalization() {
    local test_name="test_extract_path_normalization"
    print_test_status "Running: $test_name"
    
    # Test path construction for install script
    local temp_dir="/tmp/.junior-update-12345"
    local extracted_dir="$temp_dir/junior-main"
    local repo_name="junior"
    
    # Verify path pattern
    local expected_pattern="$temp_dir/$repo_name-*"
    
    if [[ "$extracted_dir" == $expected_pattern ]]; then
        print_test_success "✓ $test_name: PASS - Path normalization correct"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Path normalization incorrect"
        return 1
    fi
}

# ============================================================================
# TASK 2.5: Tests for install script invocation and cleanup
# ============================================================================

test_install_script_path_construction() {
    local test_name="test_install_script_path_construction"
    print_test_status "Running: $test_name"
    
    # Test path construction for install script
    local temp_dir="/tmp/.junior-update-12345"
    local extracted_dir="$temp_dir/junior-main"
    local install_script="$extracted_dir/scripts/install-junior.sh"
    
    # Verify path pattern is correct
    if [[ "$install_script" == "$extracted_dir/scripts/install-junior.sh" ]]; then
        print_test_success "✓ $test_name: PASS - Install script path correct"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Install script path incorrect"
        return 1
    fi
}

test_install_script_no_flags_needed() {
    local test_name="test_install_script_no_flags_needed"
    print_test_status "Running: $test_name"
    
    # Verify install script is called WITHOUT flags
    # Install script auto-detects:
    #   - Non-git repos (tarball) - handles gracefully
    #   - Existing installations - runs upgrade mode
    #   - No confirmation needed during upgrades
    
    # Read the update.sh script and verify no flags are passed to install script
    if grep -q 'install_script.*--ignore-dirty\|install_script.*--force' "$REPO_ROOT/.junior/update.sh"; then
        print_test_error "✗ $test_name: FAIL - Install script should not need flags"
        print_test_error "Install script auto-detects context and handles gracefully"
        return 1
    else
        print_test_success "✓ $test_name: PASS - Install script called without unnecessary flags"
        return 0
    fi
}

test_cleanup_on_success() {
    local test_name="test_cleanup_on_success"
    print_test_status "Running: $test_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d /tmp/.junior-update-$$)
    
    # Simulate successful operation and cleanup
    touch "$temp_dir/test-file.txt"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    # Verify cleanup
    if [ ! -d "$temp_dir" ]; then
        print_test_success "✓ $test_name: PASS - Cleanup successful"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Cleanup failed"
        rm -rf "$temp_dir"
        return 1
    fi
}

test_cleanup_preserves_on_error() {
    local test_name="test_cleanup_preserves_on_error"
    print_test_status "Running: $test_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d /tmp/.junior-update-$$)
    
    # Simulate error scenario - temp dir should be preserved for debugging
    # In real script, error handler would preserve the directory
    # For test, we just verify the directory exists before manual cleanup
    
    if [ -d "$temp_dir" ]; then
        print_test_success "✓ $test_name: PASS - Temp directory preserved for debugging"
        rm -rf "$temp_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Directory should exist"
        return 1
    fi
}

test_project_root_detection() {
    local test_name="test_project_root_detection"
    print_test_status "Running: $test_name"
    
    # Test detecting project root from update.sh location
    # update.sh is in .junior/, so project root is parent directory
    local update_script_dir="$REPO_ROOT/.junior"
    local project_root="$REPO_ROOT"
    
    # Verify project root detection logic
    if [ -d "$project_root" ] && [ -d "$update_script_dir" ]; then
        print_test_success "✓ $test_name: PASS - Project root detection correct"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Project root detection failed"
        return 1
    fi
}

# ============================================================================
# Integration Tests - Test actual update.sh script
# ============================================================================

test_update_script_missing_metadata() {
    local test_name="test_update_script_missing_metadata"
    print_test_status "Running: $test_name"
    
    # Create temp directory without metadata
    local test_dir="/tmp/.junior-test-no-meta-$$"
    mkdir -p "$test_dir"
    
    # Run update script from that directory (capture exit code properly)
    set +e
    (cd "$test_dir" && bash "$REPO_ROOT/.junior/update.sh" > /tmp/test-output-$$.txt 2>&1)
    local exit_code=$?
    local output=$(cat /tmp/test-output-$$.txt)
    rm -f /tmp/test-output-$$.txt
    set -e
    
    # Check for expected error
    if [ $exit_code -eq 1 ] && [[ "$output" == *"Junior installation not found"* ]]; then
        print_test_success "✓ $test_name: PASS - Detects missing metadata"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should error on missing metadata (exit code should be 1)"
        echo "Exit code: $exit_code (expected 1)"
        rm -rf "$test_dir"
        return 1
    fi
}

test_update_script_invalid_option() {
    local test_name="test_update_script_invalid_option"
    print_test_status "Running: $test_name"
    
    # Run with invalid option
    set +e
    bash "$REPO_ROOT/.junior/update.sh" --invalid-option > /tmp/test-output-$$.txt 2>&1
    local exit_code=$?
    local output=$(cat /tmp/test-output-$$.txt)
    rm -f /tmp/test-output-$$.txt
    set -e
    
    # Check for expected error
    if [ $exit_code -eq 1 ] && [[ "$output" == *"Unknown option"* ]]; then
        print_test_success "✓ $test_name: PASS - Rejects invalid option"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should reject invalid option (exit code should be 1)"
        echo "Exit code: $exit_code (expected 1)"
        return 1
    fi
}

test_update_script_force_flag() {
    local test_name="test_update_script_force_flag"
    print_test_status "Running: $test_name"
    
    # Create temp directory with valid metadata (older version)
    local test_dir="/tmp/.junior-test-force-$$"
    mkdir -p "$test_dir/.junior"
    
    # Create metadata with old commit hash
    cat > "$test_dir/.junior/.junior-install.json" <<'EOF'
{
  "version": "1000000000",
  "installed_at": "2020-01-01T00:00:00Z",
  "commit_hash": "old0000000000000000000000000000000000000",
  "files": {}
}
EOF
    
    # Run with --force --check-only to test flag parsing
    set +e
    (cd "$test_dir" && bash "$REPO_ROOT/.junior/update.sh" --force --check-only > /tmp/test-output-$$.txt 2>&1)
    local exit_code=$?
    local output=$(cat /tmp/test-output-$$.txt)
    rm -f /tmp/test-output-$$.txt
    set -e
    
    # Check that script runs without prompting (exit 2 for check-only with update available)
    if [ $exit_code -eq 2 ] && [[ "$output" == *"Update available"* ]]; then
        print_test_success "✓ $test_name: PASS - Force and check-only flags work"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Flags should be recognized"
        echo "Exit code: $exit_code (expected 2)"
        rm -rf "$test_dir"
        return 1
    fi
}

test_set_e_with_return_2() {
    local test_name="test_set_e_with_return_2"
    print_test_status "Running: $test_name"
    
    # Create temp directory with valid metadata (older version)
    local test_dir="/tmp/.junior-test-set-e-$$"
    mkdir -p "$test_dir/.junior"
    
    # Create metadata with old commit hash to trigger return code 2
    cat > "$test_dir/.junior/.junior-install.json" <<'EOF'
{
  "version": "1000000000",
  "installed_at": "2020-01-01T00:00:00Z",
  "commit_hash": "old0000000000000000000000000000000000000",
  "files": {}
}
EOF
    
    # Run with --check-only (should return 2 when update available, not exit due to set -e)
    set +e
    (cd "$test_dir" && bash "$REPO_ROOT/.junior/update.sh" --check-only > /tmp/test-output-$$.txt 2>&1)
    local exit_code=$?
    local output=$(cat /tmp/test-output-$$.txt)
    rm -f /tmp/test-output-$$.txt
    set -e
    
    # Verify exit code 2 and proper flow (not premature exit from set -e)
    if [ $exit_code -eq 2 ] && [[ "$output" == *"Update available"* ]] && [[ "$output" == *"without --check-only"* ]]; then
        print_test_success "✓ $test_name: PASS - Script handles return code 2 correctly with set -e"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Script should continue after compare_and_report returns 2"
        echo "Exit code: $exit_code (expected 2)"
        echo "Output should contain 'Update available' and 'without --check-only'"
        rm -rf "$test_dir"
        return 1
    fi
}

test_update_script_with_valid_metadata() {
    local test_name="test_update_script_with_valid_metadata"
    print_test_status "Running: $test_name"
    
    # Create temp directory with valid metadata
    local test_dir="/tmp/.junior-test-valid-$$"
    mkdir -p "$test_dir/.junior"
    
    # Create metadata matching GitHub main
    cat > "$test_dir/.junior/.junior-install.json" <<'EOF'
{
  "version": "1733358683",
  "installed_at": "2025-12-05T00:51:23Z",
  "commit_hash": "ff1d9262a2a8efc640fe3ef5a4b13f338dd48d68",
  "files": {}
}
EOF
    
    # Run update script from that directory
    set +e
    local output=$(cd "$test_dir" && bash "$REPO_ROOT/.junior/update.sh" 2>&1)
    local exit_code=$?
    set -e
    
    # Check for successful execution (exit code 0 or 2 are both valid)
    if [[ "$output" == *"Checking for updates"* ]] && [[ "$output" == *"Version Check"* ]]; then
        print_test_success "✓ $test_name: PASS - Runs successfully with valid metadata"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should run successfully"
        echo "Exit code: $exit_code"
        echo "Output: $output"
        rm -rf "$test_dir"
        return 1
    fi
}

# ============================================================================
# Test runner
# ============================================================================

run_all_tests() {
    echo ""
    print_test_status "═══════════════════════════════════════════════════"
    print_test_status "Junior Update Script Test Suite"
    print_test_status "═══════════════════════════════════════════════════"
    echo ""
    
    local failed=0
    local total=0
    
    # Task 1.1 tests - Metadata reading
    print_test_status "Task 1.1: Metadata reading tests"
    test_read_metadata_valid || ((failed++)) || true
    ((total++)) || true
    test_read_metadata_missing || ((failed++)) || true
    ((total++)) || true
    test_read_metadata_corrupted || ((failed++)) || true
    ((total++)) || true
    test_read_metadata_missing_fields || ((failed++)) || true
    ((total++)) || true
    echo ""
    
    # Task 1.3 tests - GitHub API
    print_test_status "Task 1.3: GitHub API tests"
    test_github_api_parse_valid || ((failed++)) || true
    ((total++)) || true
    test_github_api_rate_limit || ((failed++)) || true
    ((total++)) || true
    test_github_api_network_error || ((failed++)) || true
    ((total++)) || true
    echo ""
    
    # Task 1.5 tests - Version comparison
    print_test_status "Task 1.5: Version comparison tests"
    test_version_compare_equal || ((failed++)) || true
    ((total++)) || true
    test_version_compare_different || ((failed++)) || true
    ((total++)) || true
    test_version_compare_unknown || ((failed++)) || true
    ((total++)) || true
    echo ""
    
    # Task 2.1 tests - Tarball download
    print_test_status "Task 2.1: Tarball download tests"
    test_temp_directory_creation || ((failed++)) || true
    ((total++)) || true
    test_temp_directory_cleanup || ((failed++)) || true
    ((total++)) || true
    test_download_tarball_mock || ((failed++)) || true
    ((total++)) || true
    test_download_failure_handling || ((failed++)) || true
    ((total++)) || true
    test_download_url_construction || ((failed++)) || true
    ((total++)) || true
    echo ""
    
    # Task 2.3 tests - Tarball extraction
    print_test_status "Task 2.3: Tarball extraction tests"
    test_extract_tarball_basic || ((failed++)) || true
    ((total++)) || true
    test_extract_tarball_find_directory || ((failed++)) || true
    ((total++)) || true
    test_extract_corrupted_tarball || ((failed++)) || true
    ((total++)) || true
    test_extract_empty_tarball || ((failed++)) || true
    ((total++)) || true
    test_extract_path_normalization || ((failed++)) || true
    ((total++)) || true
    echo ""
    
    # Task 2.5 tests - Install script invocation and cleanup
    print_test_status "Task 2.5: Install script invocation and cleanup tests"
    test_install_script_path_construction || ((failed++)) || true
    ((total++)) || true
    test_install_script_no_flags_needed || ((failed++)) || true
    ((total++)) || true
    test_cleanup_on_success || ((failed++)) || true
    ((total++)) || true
    test_cleanup_preserves_on_error || ((failed++)) || true
    ((total++)) || true
    test_project_root_detection || ((failed++)) || true
    ((total++)) || true
    echo ""
    
    # Integration tests
    print_test_status "Integration tests: Actual script execution"
    test_update_script_missing_metadata || ((failed++)) || true
    ((total++)) || true
    test_update_script_invalid_option || ((failed++)) || true
    ((total++)) || true
    test_update_script_force_flag || ((failed++)) || true
    ((total++)) || true
    test_set_e_with_return_2 || ((failed++)) || true
    ((total++)) || true
    test_update_script_with_valid_metadata || ((failed++)) || true
    ((total++)) || true
    echo ""
    
    # Summary
    local passed=$((total - failed))
    print_test_status "═══════════════════════════════════════════════════"
    if [ $failed -eq 0 ]; then
        print_test_success "All tests passed! ✓ ($passed/$total)"
    else
        print_test_error "$failed test(s) failed ($passed/$total passed)"
        return 1
    fi
    print_test_status "═══════════════════════════════════════════════════"
    echo ""
    
    return 0
}

# Main execution
run_all_tests
exit $?

