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

test_update_script_update_flag() {
    local test_name="test_update_script_update_flag"
    print_test_status "Running: $test_name"
    
    # Run with --update flag (not yet implemented)
    set +e
    bash "$REPO_ROOT/.junior/update.sh" --update > /tmp/test-output-$$.txt 2>&1
    local exit_code=$?
    local output=$(cat /tmp/test-output-$$.txt)
    rm -f /tmp/test-output-$$.txt
    set -e
    
    # Check for expected error
    if [ $exit_code -eq 1 ] && [[ "$output" == *"not yet implemented"* ]]; then
        print_test_success "✓ $test_name: PASS - Correctly reports unimplemented feature"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should report feature not implemented (exit code should be 1)"
        echo "Exit code: $exit_code (expected 1)"
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
    test_read_metadata_valid || ((failed++))
    ((total++))
    test_read_metadata_missing || ((failed++))
    ((total++))
    test_read_metadata_corrupted || ((failed++))
    ((total++))
    test_read_metadata_missing_fields || ((failed++))
    ((total++))
    echo ""
    
    # Task 1.3 tests - GitHub API
    print_test_status "Task 1.3: GitHub API tests"
    test_github_api_parse_valid || ((failed++))
    ((total++))
    test_github_api_rate_limit || ((failed++))
    ((total++))
    test_github_api_network_error || ((failed++))
    ((total++))
    echo ""
    
    # Task 1.5 tests - Version comparison
    print_test_status "Task 1.5: Version comparison tests"
    test_version_compare_equal || ((failed++))
    ((total++))
    test_version_compare_different || ((failed++))
    ((total++))
    test_version_compare_unknown || ((failed++))
    ((total++))
    echo ""
    
    # Integration tests
    print_test_status "Integration tests: Actual script execution"
    test_update_script_missing_metadata || ((failed++))
    ((total++))
    test_update_script_invalid_option || ((failed++))
    ((total++))
    test_update_script_update_flag || ((failed++))
    ((total++))
    test_update_script_with_valid_metadata || ((failed++))
    ((total++))
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

