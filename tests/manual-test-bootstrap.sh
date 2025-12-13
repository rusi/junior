#!/bin/bash

# Manual Test Script for Bootstrap
# This script simulates the bootstrap flow locally without GitHub

set -e

echo "========================================"
echo "Manual Bootstrap Test"
echo "========================================"
echo ""

# Get repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Create test project directory
TEST_PROJECT="/tmp/junior-manual-test-$$"
echo "Creating test project: $TEST_PROJECT"
mkdir -p "$TEST_PROJECT"

# Create a local tarball (simulating GitHub download)
echo "Creating local tarball (simulating GitHub)..."
TARBALL_PATH="/tmp/junior-test-tarball-$$.tar.gz"

# Create temp directory with renamed structure (GitHub uses junior-main/)
TEMP_TAR_DIR="/tmp/junior-tar-build-$$"
mkdir -p "$TEMP_TAR_DIR"
cp -R "$REPO_ROOT" "$TEMP_TAR_DIR/junior-main"

# Remove .git directory from copy
rm -rf "$TEMP_TAR_DIR/junior-main/.git"

# Create tarball from renamed structure
cd "$TEMP_TAR_DIR"
tar -czf "$TARBALL_PATH" junior-main

# Cleanup temp directory
rm -rf "$TEMP_TAR_DIR"

# Modify bootstrap script to use local tarball
echo "Creating modified bootstrap for local testing..."
MODIFIED_BOOTSTRAP="/tmp/junior-bootstrap-test-$$.sh"
cat "$REPO_ROOT/docs/install.sh" | sed "s|TARBALL_URL=.*|TARBALL_URL=\"file://$TARBALL_PATH\"|" > "$MODIFIED_BOOTSTRAP"
chmod +x "$MODIFIED_BOOTSTRAP"

echo ""
echo "========================================"
echo "Running Bootstrap Script"
echo "========================================"
echo ""

# Run bootstrap in test project
cd "$TEST_PROJECT"
bash "$MODIFIED_BOOTSTRAP"

echo ""
echo "========================================"
echo "Verification"
echo "========================================"
echo ""

# Verify installation
if [ -f "$TEST_PROJECT/.junior/.junior-install.json" ]; then
    echo "✓ Installation metadata exists"
else
    echo "✗ Installation metadata missing"
    exit 1
fi

if [ -d "$TEST_PROJECT/.cursor/rules" ]; then
    echo "✓ Rules directory created"
else
    echo "✗ Rules directory missing"
    exit 1
fi

if [ -d "$TEST_PROJECT/.cursor/commands" ]; then
    echo "✓ Commands directory created"
else
    echo "✗ Commands directory missing"
    exit 1
fi

if [ -f "$TEST_PROJECT/JUNIOR.md" ]; then
    echo "✓ JUNIOR.md exists"
else
    echo "✗ JUNIOR.md missing"
    exit 1
fi

echo ""
echo "========================================"
echo "Test Complete!"
echo "========================================"
echo ""
echo "Test project location: $TEST_PROJECT"
echo "Review files manually, then cleanup with:"
echo "  rm -rf $TEST_PROJECT $TARBALL_PATH $MODIFIED_BOOTSTRAP"
echo ""

