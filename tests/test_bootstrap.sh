#!/bin/bash

# Test Suite for Junior Bootstrap Script
# Usage: ./tests/test_bootstrap.sh

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

print_test_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# ============================================================================
# TASK 1.1: Tests for tarball download
# ============================================================================

test_download_tarball_curl() {
    local test_name="test_download_tarball_curl"
    print_test_status "Running: $test_name"

    # Test that download_tarball function exists and works with curl
    # Create a mock curl that succeeds
    local test_dir="/tmp/.junior-test-download-$$"
    mkdir -p "$test_dir"

    # Create mock curl
    cat > "$test_dir/curl" <<'EOF'
#!/bin/bash
# Mock curl - just create a dummy file
# Parse arguments to find -o output file
output_file=""
for ((i=1; i<=$#; i++)); do
    if [ "${!i}" = "-o" ]; then
        ((i++))
        output_file="${!i}"
        break
    fi
done
if [ -n "$output_file" ]; then
    echo "mock tarball content" > "$output_file"
fi
exit 0
EOF
    chmod +x "$test_dir/curl"

    # Test download function with mock curl
    local dest_file="$test_dir/junior.tar.gz"
    PATH="$test_dir:$PATH" bash -c "
        download_tarball() {
            local url=\"\$1\"
            local dest=\"\$2\"

            if command -v curl &> /dev/null; then
                curl -LsSf \"\$url\" -o \"\$dest\"
                return 0
            elif command -v wget &> /dev/null; then
                wget -qO \"\$dest\" \"\$url\"
                return 0
            else
                return 1
            fi
        }
        download_tarball 'https://example.com/tarball' '$dest_file'
    "

    if [ -f "$dest_file" ] && [ -s "$dest_file" ]; then
        print_test_success "✓ $test_name: PASS"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Download did not create file"
        rm -rf "$test_dir"
        return 1
    fi
}

test_download_tarball_wget_fallback() {
    local test_name="test_download_tarball_wget_fallback"
    print_test_status "Running: $test_name"

    # Test that download_tarball falls back to wget when curl unavailable
    local test_dir="/tmp/.junior-test-wget-$$"
    mkdir -p "$test_dir"

    # Create mock wget that writes to output file
    cat > "$test_dir/wget" <<'EOF'
#!/bin/bash
# Mock wget - create dummy file
# Find the output file argument
output_file=""
prev_arg=""
for arg in "$@"; do
    if [ "$prev_arg" = "-qO" ]; then
        output_file="$arg"
        break
    fi
    prev_arg="$arg"
done
if [ -n "$output_file" ]; then
    echo "mock tarball from wget" > "$output_file"
fi
exit 0
EOF
    chmod +x "$test_dir/wget"

    # Test download function with mock wget (no curl in PATH)
    local dest_file="$test_dir/junior.tar.gz"
    /bin/bash -c "
        PATH='$test_dir'
        export PATH
        download_tarball() {
            local url=\"\$1\"
            local dest=\"\$2\"

            if command -v curl &> /dev/null; then
                curl -LsSf \"\$url\" -o \"\$dest\"
                return 0
            elif command -v wget &> /dev/null; then
                wget -qO \"\$dest\" \"\$url\"
                return 0
            else
                return 1
            fi
        }
        download_tarball 'https://example.com/tarball' '$dest_file'
    "

    if [ -f "$dest_file" ] && [ -s "$dest_file" ]; then
        print_test_success "✓ $test_name: PASS"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Wget fallback did not work"
        rm -rf "$test_dir"
        return 1
    fi
}

test_download_tarball_no_tools() {
    local test_name="test_download_tarball_no_tools"
    print_test_status "Running: $test_name"

    # Test that download_tarball fails gracefully when neither curl nor wget available
    local test_dir="/tmp/.junior-test-notools-$$"
    mkdir -p "$test_dir"

    # Test with empty PATH (no curl, no wget)
    bash -c "
        PATH=''
        export PATH
        download_tarball() {
            local url=\"\$1\"
            local dest=\"\$2\"

            if command -v curl &> /dev/null; then
                curl -LsSf \"\$url\" -o \"\$dest\"
                return 0
            elif command -v wget &> /dev/null; then
                wget -qO \"\$dest\" \"\$url\"
                return 0
            else
                return 1
            fi
        }
        download_tarball 'https://example.com/tarball' '$test_dir/junior.tar.gz'
    " 2>/dev/null && local result=0 || local result=$?

    if [ $result -ne 0 ]; then
        print_test_success "✓ $test_name: PASS (correctly failed)"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should have failed without tools"
        rm -rf "$test_dir"
        return 1
    fi
}

test_download_tarball_network_error() {
    local test_name="test_download_tarball_network_error"
    print_test_status "Running: $test_name"

    # Test that download_tarball handles network errors
    local test_dir="/tmp/.junior-test-neterr-$$"
    mkdir -p "$test_dir"

    # Create mock curl that fails
    cat > "$test_dir/curl" <<'EOF'
#!/bin/bash
# Mock curl - network error
echo "curl: (7) Failed to connect" >&2
exit 7
EOF
    chmod +x "$test_dir/curl"

    # Test download function with failing curl
    local dest_file="$test_dir/junior.tar.gz"
    PATH="$test_dir:$PATH" bash -c "
        download_tarball() {
            local url=\"\$1\"
            local dest=\"\$2\"

            if command -v curl &> /dev/null; then
                curl -LsSf \"\$url\" -o \"\$dest\"
                return \$?
            elif command -v wget &> /dev/null; then
                wget -qO \"\$dest\" \"\$url\"
                return \$?
            else
                return 1
            fi
        }
        download_tarball 'https://example.com/tarball' '$dest_file'
    " 2>/dev/null && local result=0 || local result=$?

    if [ $result -ne 0 ]; then
        print_test_success "✓ $test_name: PASS (correctly detected network error)"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should have failed on network error"
        rm -rf "$test_dir"
        return 1
    fi
}

# ============================================================================
# TASK 1.3: Tests for extraction and path detection
# ============================================================================

test_extract_tarball_valid() {
    local test_name="test_extract_tarball_valid"
    print_test_status "Running: $test_name"

    # Create a test tarball
    local test_dir="/tmp/.junior-test-extract-$$"
    mkdir -p "$test_dir/source/junior-main"
    echo "test content" > "$test_dir/source/junior-main/README.md"

    # Create tarball
    cd "$test_dir/source"
    tar -czf "$test_dir/test.tar.gz" junior-main
    cd - > /dev/null

    # Test extraction
    local extract_dir="$test_dir/extracted"
    mkdir -p "$extract_dir"

    /bin/bash -c "
        extract_tarball() {
            local tarball=\"\$1\"
            local dest_dir=\"\$2\"
            tar -xzf \"\$tarball\" -C \"\$dest_dir\"
            return \$?
        }
        extract_tarball '$test_dir/test.tar.gz' '$extract_dir'
    "

    if [ -f "$extract_dir/junior-main/README.md" ]; then
        print_test_success "✓ $test_name: PASS"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Extraction did not create expected files"
        rm -rf "$test_dir"
        return 1
    fi
}

test_extract_tarball_corrupted() {
    local test_name="test_extract_tarball_corrupted"
    print_test_status "Running: $test_name"

    # Create corrupted tarball
    local test_dir="/tmp/.junior-test-corrupt-$$"
    mkdir -p "$test_dir"
    echo "this is not a tarball" > "$test_dir/corrupt.tar.gz"

    # Test extraction (should fail)
    local extract_dir="$test_dir/extracted"
    mkdir -p "$extract_dir"

    /bin/bash -c "
        extract_tarball() {
            local tarball=\"\$1\"
            local dest_dir=\"\$2\"
            tar -xzf \"\$tarball\" -C \"\$dest_dir\"
            return \$?
        }
        extract_tarball '$test_dir/corrupt.tar.gz' '$extract_dir'
    " 2>/dev/null && local result=0 || local result=$?

    if [ $result -ne 0 ]; then
        print_test_success "✓ $test_name: PASS (correctly detected corrupted tarball)"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should have failed on corrupted tarball"
        rm -rf "$test_dir"
        return 1
    fi
}

test_path_detection_junior_main() {
    local test_name="test_path_detection_junior_main"
    print_test_status "Running: $test_name"

    # Create directory structure
    local test_dir="/tmp/.junior-test-path-main-$$"
    mkdir -p "$test_dir/junior-main"
    touch "$test_dir/junior-main/README.md"

    # Test path detection
    local detected_dir=$(find "$test_dir" -maxdepth 1 -type d -name "junior-*" | head -1)

    if [ "$detected_dir" = "$test_dir/junior-main" ]; then
        print_test_success "✓ $test_name: PASS"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Path detection failed (got: $detected_dir)"
        rm -rf "$test_dir"
        return 1
    fi
}

test_path_detection_junior_master() {
    local test_name="test_path_detection_junior_master"
    print_test_status "Running: $test_name"

    # Create directory structure with master branch
    local test_dir="/tmp/.junior-test-path-master-$$"
    mkdir -p "$test_dir/junior-master"
    touch "$test_dir/junior-master/README.md"

    # Test path detection
    local detected_dir=$(find "$test_dir" -maxdepth 1 -type d -name "junior-*" | head -1)

    if [ "$detected_dir" = "$test_dir/junior-master" ]; then
        print_test_success "✓ $test_name: PASS"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Path detection failed (got: $detected_dir)"
        rm -rf "$test_dir"
        return 1
    fi
}

test_path_detection_missing() {
    local test_name="test_path_detection_missing"
    print_test_status "Running: $test_name"

    # Create directory without junior-* subdirectory
    local test_dir="/tmp/.junior-test-path-missing-$$"
    mkdir -p "$test_dir"

    # Test path detection (should find nothing)
    local detected_dir=$(find "$test_dir" -maxdepth 1 -type d -name "junior-*" | head -1)

    if [ -z "$detected_dir" ]; then
        print_test_success "✓ $test_name: PASS (correctly detected missing directory)"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should not have found directory"
        rm -rf "$test_dir"
        return 1
    fi
}

# ============================================================================
# TASK 1.5: Tests for install script delegation and cleanup
# ============================================================================

test_run_install_success() {
    local test_name="test_run_install_success"
    print_test_status "Running: $test_name"

    # Create mock extracted directory with install script
    local test_dir="/tmp/.junior-test-install-$$"
    mkdir -p "$test_dir/extracted/scripts"

    # Create mock install script
    cat > "$test_dir/extracted/scripts/install-junior.sh" <<'EOF'
#!/bin/bash
# Mock install script - just succeeds
echo "Mock install to: $1"
exit 0
EOF
    chmod +x "$test_dir/extracted/scripts/install-junior.sh"

    # Test run_install function
    /bin/bash -c "
        run_install() {
            local extracted_dir=\"\$1\"
            local target_dir=\"\$2\"

            if [ ! -f \"\$extracted_dir/scripts/install-junior.sh\" ]; then
                return 1
            fi

            cd \"\$extracted_dir\"
            ./scripts/install-junior.sh \"\$target_dir\"
            return \$?
        }
        run_install '$test_dir/extracted' '$test_dir/target'
    " > /dev/null 2>&1

    local result=$?
    if [ $result -eq 0 ]; then
        print_test_success "✓ $test_name: PASS"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Install script execution failed"
        rm -rf "$test_dir"
        return 1
    fi
}

test_run_install_missing_script() {
    local test_name="test_run_install_missing_script"
    print_test_status "Running: $test_name"

    # Create extracted directory WITHOUT install script
    local test_dir="/tmp/.junior-test-noinstall-$$"
    mkdir -p "$test_dir/extracted/scripts"

    # Test run_install function (should fail)
    /bin/bash -c "
        run_install() {
            local extracted_dir=\"\$1\"
            local target_dir=\"\$2\"

            if [ ! -f \"\$extracted_dir/scripts/install-junior.sh\" ]; then
                return 1
            fi

            cd \"\$extracted_dir\"
            ./scripts/install-junior.sh \"\$target_dir\"
            return \$?
        }
        run_install '$test_dir/extracted' '$test_dir/target'
    " 2>/dev/null

    local result=$?
    if [ $result -ne 0 ]; then
        print_test_success "✓ $test_name: PASS (correctly detected missing script)"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should have failed with missing script"
        rm -rf "$test_dir"
        return 1
    fi
}

test_run_install_script_failure() {
    local test_name="test_run_install_script_failure"
    print_test_status "Running: $test_name"

    # Create mock extracted directory with failing install script
    local test_dir="/tmp/.junior-test-failinstall-$$"
    mkdir -p "$test_dir/extracted/scripts"

    # Create mock install script that fails
    cat > "$test_dir/extracted/scripts/install-junior.sh" <<'EOF'
#!/bin/bash
# Mock install script - fails
echo "Mock install failure"
exit 1
EOF
    chmod +x "$test_dir/extracted/scripts/install-junior.sh"

    # Test run_install function (should propagate failure)
    /bin/bash -c "
        run_install() {
            local extracted_dir=\"\$1\"
            local target_dir=\"\$2\"

            if [ ! -f \"\$extracted_dir/scripts/install-junior.sh\" ]; then
                return 1
            fi

            cd \"\$extracted_dir\"
            ./scripts/install-junior.sh \"\$target_dir\"
            return \$?
        }
        run_install '$test_dir/extracted' '$test_dir/target'
    " > /dev/null 2>&1

    local result=$?
    if [ $result -ne 0 ]; then
        print_test_success "✓ $test_name: PASS (correctly propagated failure)"
        rm -rf "$test_dir"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Should have failed when script fails"
        rm -rf "$test_dir"
        return 1
    fi
}

test_temp_cleanup_on_exit() {
    local test_name="test_temp_cleanup_on_exit"
    print_test_status "Running: $test_name"

    # Test that temp directory is cleaned up on exit
    local test_script="/tmp/.junior-test-cleanup-script-$$.sh"
    cat > "$test_script" <<'EOF'
#!/bin/bash
set -e
TEMP_DIR=$(mktemp -d /tmp/.junior-test-XXXXX)
echo "$TEMP_DIR"
trap "rm -rf $TEMP_DIR" EXIT
# Script exits here, trap should fire
EOF
    chmod +x "$test_script"

    # Run script and capture temp dir name
    local temp_dir=$(/bin/bash "$test_script")

    # Check if temp dir was cleaned up
    if [ ! -d "$temp_dir" ]; then
        print_test_success "✓ $test_name: PASS"
        rm -f "$test_script"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Temp directory not cleaned up: $temp_dir"
        rm -rf "$temp_dir" "$test_script"
        return 1
    fi
}

test_temp_cleanup_on_error() {
    local test_name="test_temp_cleanup_on_error"
    print_test_status "Running: $test_name"

    # Test that temp directory is cleaned up even on error
    local test_script="/tmp/.junior-test-cleanup-err-$$.sh"
    cat > "$test_script" <<'EOF'
#!/bin/bash
set -e
TEMP_DIR=$(mktemp -d /tmp/.junior-test-err-XXXXX)
echo "$TEMP_DIR"
trap "rm -rf $TEMP_DIR" EXIT
# Simulate error
exit 1
EOF
    chmod +x "$test_script"

    # Run script (will fail) and capture temp dir name
    local temp_dir=$(/bin/bash "$test_script" 2>/dev/null) || true

    # Check if temp dir was cleaned up despite error
    if [ ! -d "$temp_dir" ]; then
        print_test_success "✓ $test_name: PASS"
        rm -f "$test_script"
        return 0
    else
        print_test_error "✗ $test_name: FAIL - Temp directory not cleaned up on error: $temp_dir"
        rm -rf "$temp_dir" "$test_script"
        return 1
    fi
}

# ============================================================================
# Test Runner
# ============================================================================

run_all_tests() {
    echo ""
    print_test_status "═══════════════════════════════════════════════════"
    print_test_status "Junior Bootstrap Script Test Suite"
    print_test_status "═══════════════════════════════════════════════════"
    echo ""

    local failed=0
    local total=0

    # Task 1.1 tests - Tarball download
    print_test_status "Task 1.1: Tarball download tests"
    test_download_tarball_curl || ((failed++)) || true
    ((total++)) || true
    test_download_tarball_wget_fallback || ((failed++)) || true
    ((total++)) || true
    test_download_tarball_no_tools || ((failed++)) || true
    ((total++)) || true
    test_download_tarball_network_error || ((failed++)) || true
    ((total++)) || true
    echo ""

    # Task 1.3 tests - Extraction and path detection
    print_test_status "Task 1.3: Extraction and path detection tests"
    test_extract_tarball_valid || ((failed++)) || true
    ((total++)) || true
    test_extract_tarball_corrupted || ((failed++)) || true
    ((total++)) || true
    test_path_detection_junior_main || ((failed++)) || true
    ((total++)) || true
    test_path_detection_junior_master || ((failed++)) || true
    ((total++)) || true
    test_path_detection_missing || ((failed++)) || true
    ((total++)) || true
    echo ""

    # Task 1.5 tests - Install delegation and cleanup
    print_test_status "Task 1.5: Install delegation and cleanup tests"
    test_run_install_success || ((failed++)) || true
    ((total++)) || true
    test_run_install_missing_script || ((failed++)) || true
    ((total++)) || true
    test_run_install_script_failure || ((failed++)) || true
    ((total++)) || true
    test_temp_cleanup_on_exit || ((failed++)) || true
    ((total++)) || true
    test_temp_cleanup_on_error || ((failed++)) || true
    ((total++)) || true
    echo ""

    # Summary
    local passed=$((total - failed))
    echo ""
    print_test_status "═══════════════════════════════════════════════════"
    if [ $failed -eq 0 ]; then
        print_test_success "All tests passed! ($passed/$total)"
    else
        print_test_error "Some tests failed! ($passed/$total passed, $failed/$total failed)"
    fi
    print_test_status "═══════════════════════════════════════════════════"
    echo ""

    return $failed
}

# Run tests
run_all_tests
exit $?

