#!/bin/bash

# Junior Installation Script
# Usage: ./scripts/install-junior.sh /path/to/project

set -e  # Exit on any error

# Colors for output
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

# Function to calculate SHA256 checksum
calculate_checksum() {
    local file="$1"
    if command -v sha256sum &> /dev/null; then
        sha256sum "$file" | awk '{print $1}'
    elif command -v shasum &> /dev/null; then
        shasum -a 256 "$file" | awk '{print $1}'
    else
        print_error "Neither sha256sum nor shasum found. Cannot calculate checksums."
        exit 1
    fi
}

# Function to get file size
get_file_size() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f%z "$file"
    else
        stat -c%s "$file"
    fi
}

# Function to check file conflict type
# Returns: 0=no conflict, 1=user modified (preserve), 2=uncontrolled file (abort)
check_file_conflict() {
    local dest_file="$1"
    
    # File doesn't exist - no conflict
    if [ ! -f "$dest_file" ]; then
        return 0
    fi
    
    # File exists - determine conflict type
    # First check: is this an upgrade (Junior was previously installed)?
    if [ "$IS_UPGRADE" != true ]; then
        # Fresh install + file exists = uncontrolled file
        return 2
    fi
    
    # This is an upgrade - check if file was installed by Junior
    local original_checksum=$(echo "$EXISTING_METADATA" | jq -r ".files[\"$dest_file\"].sha256 // \"\"")
    
    if [ -z "$original_checksum" ]; then
        # Upgrade but file NOT in metadata = uncontrolled file
        return 2
    fi
    
    # File was installed by Junior - check if user modified it
    local current_checksum=$(calculate_checksum "$dest_file")
    if [ "$current_checksum" != "$original_checksum" ]; then
        return 1  # User modified Junior file
    fi
    
    # Unchanged Junior file - safe to overwrite
    return 0
}

# Function to install a single file with checksum tracking
install_file() {
    local source="$1"
    local dest="$2"
    
    # Check for file conflicts
    check_file_conflict "$dest"
    local conflict_type=$?
    
    if [ $conflict_type -eq 1 ]; then
        # User modified Junior file - preserve
        print_warning "User-modified: $dest (preserving)"
        MODIFIED_FILES+=("$dest")
        
        local checksum=$(calculate_checksum "$dest")
        local size=$(get_file_size "$dest")
        FILE_METADATA["$dest"]="$checksum|$size|true"
        return 0
        
    elif [ $conflict_type -eq 2 ]; then
        # Uncontrolled file exists - conflict
        print_error "Conflict: $dest exists but was not installed by Junior"
        CONFLICTING_FILES+=("$dest")
        return 1
    fi
    
    # Safe to install - copy file
    if [ -f "$REPO_ROOT/$source" ]; then
        cp "$REPO_ROOT/$source" "$dest"
        
        local checksum=$(calculate_checksum "$dest")
        local size=$(get_file_size "$dest")
        FILE_METADATA["$dest"]="$checksum|$size"
        
        print_success "Installed: $source -> $dest"
        return 0
    else
        print_warning "Source file not found: $REPO_ROOT/$source"
        return 1
    fi
}

# Function to extract directories from JSON config using jq
extract_directories() {
    local json="$1"
    echo "$json" | jq -r '.directories[]' 2>/dev/null || echo ""
}

# Function to extract file operations from JSON config using jq
extract_files() {
    local json="$1"
    echo "$json" | jq -r '.files[] | "\(.source)|\(.destination)|\(.isDirectory // false)|\(.skipIfExists // false)"' 2>/dev/null || echo ""
}

# Parse arguments
SYNC_BACK=false
TARGET_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --sync-back)
            SYNC_BACK=true
            shift
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Check if target directory is provided
if [ -z "$TARGET_DIR" ]; then
    print_error "Usage: $0 [--sync-back] <target_project_directory>"
    echo ""
    echo "Examples:"
    echo "  $0 ~/sources/my_project          # Install Junior"
    echo "  $0 --sync-back ~/sources/my_project  # Sync modifications back to Junior source"
    exit 1
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SCRIPT_DIR/install-config.json"

# Handle --sync-back mode
if [ "$SYNC_BACK" = true ]; then
    print_status "Syncing modifications back to Junior source..."
    print_status "Target directory: $TARGET_DIR"
    print_status "Source directory: $REPO_ROOT"
    
    cd "$TARGET_DIR"
    
    # Check for metadata file
    METADATA_FILE=".junior/.junior-install.json"
    if [ ! -f "$METADATA_FILE" ]; then
        print_error "No Junior installation found in $TARGET_DIR"
        print_error "Metadata file not found: $METADATA_FILE"
        exit 1
    fi
    
    # Load metadata
    EXISTING_METADATA=$(cat "$METADATA_FILE")
    
    # Find modified files
    SYNC_FILES=()
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            CURRENT_CHECKSUM=$(calculate_checksum "$file")
            ORIGINAL_CHECKSUM=$(echo "$EXISTING_METADATA" | jq -r ".files[\"$file\"].sha256 // \"\"")
            
            if [ -n "$ORIGINAL_CHECKSUM" ] && [ "$CURRENT_CHECKSUM" != "$ORIGINAL_CHECKSUM" ]; then
                SYNC_FILES+=("$file")
            fi
        fi
    done < <(echo "$EXISTING_METADATA" | jq -r '.files | keys[]')
    
    if [ ${#SYNC_FILES[@]} -eq 0 ]; then
        print_success "No modified files to sync"
        exit 0
    fi
    
    echo ""
    print_status "Modified files found (${#SYNC_FILES[@]}):"
    for file in "${SYNC_FILES[@]}"; do
        echo "  • $file"
    done
    echo ""
    
    print_status "Sync these files back to Junior source? [yes/no]"
    read -r CONFIRM
    
    if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "y" ]; then
        print_status "Sync cancelled"
        exit 0
    fi
    
    # Sync files back
    print_status "Syncing files..."
    for file in "${SYNC_FILES[@]}"; do
        # Determine source path
        if [[ "$file" == .cursor/rules/* ]]; then
            src_path="$REPO_ROOT/$file"
        elif [[ "$file" == .cursor/commands/* ]]; then
            src_path="$REPO_ROOT/$file"
        elif [ "$file" = "JUNIOR.md" ]; then
            src_path="$REPO_ROOT/README.md"
        else
            print_warning "Skipping: $file (unknown mapping)"
            continue
        fi
        
        cp "$file" "$src_path"
        print_success "Synced: $file -> $src_path"
    done
    
    echo ""
    print_success "═══════════════════════════════════════════════════"
    print_success "Sync complete! ${#SYNC_FILES[@]} files copied to Junior source"
    print_success "═══════════════════════════════════════════════════"
    echo ""
    print_warning "Don't forget to commit these changes in Junior repository!"
    
    exit 0
fi

# Normal installation mode
print_status "Installing Junior - Your expert AI developer..."
print_status "Target directory: $TARGET_DIR"
print_status "Source directory: $REPO_ROOT"

# Verify we're in a Junior repository (check for Junior-specific files)
if [ ! -f "$REPO_ROOT/.cursor/rules/00-junior.mdc" ]; then
    print_error "Cannot find Junior files. Make sure you're running this from the Junior repository."
    exit 1
fi

# Git clean check - verify Junior source is clean for accurate version tracking
print_status "Checking Junior source git status..."
cd "$REPO_ROOT"

if [ ! -d ".git" ]; then
    print_warning "Junior source is not a git repository. Version tracking will be limited."
    COMMIT_HASH="unknown"
    COMMIT_TIMESTAMP="unknown"
else
    if [[ -n $(git status --porcelain) ]]; then
        print_error "Junior source git not clean. Commit or stash changes first."
        print_error "Version is based on commit timestamp - need clean state."
        echo ""
        print_status "Uncommitted changes:"
        git status --short
        exit 1
    fi
    
    # Get version info from git
    COMMIT_HASH=$(git rev-parse HEAD)
    COMMIT_TIMESTAMP=$(git log -1 --format=%ct)
    print_success "Junior source is clean (commit: ${COMMIT_HASH:0:7})"
fi

# Verify target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    print_error "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

# Verify config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    print_error "jq is required but not installed. Please install jq to continue."
    print_status "Install jq with:"
    print_status "  macOS: brew install jq"
    print_status "  Ubuntu/Debian: sudo apt-get install jq"
    print_status "  CentOS/RHEL: sudo yum install jq"
    exit 1
fi

# Change to target directory
cd "$TARGET_DIR"
print_status "Working in: $(pwd)"

# Check for existing Cursor installation (Code Captain or other)
if [ -d ".cursor" ]; then
    print_warning "Existing .cursor directory detected!"
    
    # Check for Code Captain
    if [ -f ".cursor/rules/cc.mdc" ] || [ -f "CODE_CAPTAIN.md" ] || [ -d ".code-captain" ]; then
        echo ""
        print_warning "═══════════════════════════════════════════════════"
        print_warning "Code Captain installation detected!"
        print_warning "═══════════════════════════════════════════════════"
        echo ""
        print_status "Found:"
        [ -f ".cursor/rules/cc.mdc" ] && echo "  • .cursor/rules/cc.mdc"
        [ -f "CODE_CAPTAIN.md" ] && echo "  • CODE_CAPTAIN.md"
        [ -d ".code-captain" ] && echo "  • .code-captain/ directory"
        echo ""
        print_status "Recommendations before installing Junior:"
        echo "  1. Review .cursor/commands/ for custom commands you want to keep"
        echo "  2. Review .cursor/rules/ for custom rules you want to keep"
        echo "  3. Consider backing up .code-captain/ if it contains work"
        echo "  4. Use /migrate command (coming soon) for proper migration"
        echo ""
        print_warning "Installing Junior will:"
        echo "  • Install Junior files to .cursor/rules/ and .cursor/commands/"
        echo "  • Code Captain files (cc.mdc, etc.) will remain untouched"
        echo "  • Files with same names will be checked for conflicts"
        echo "  • NOT touch .code-captain/ (you can delete manually later)"
        echo "  • Create new .junior/ structure"
        echo ""
        print_status "Continue with installation? [yes/no]"
        read -r CONTINUE
        
        if [ "$CONTINUE" != "yes" ] && [ "$CONTINUE" != "y" ]; then
            print_status "Installation cancelled. Review and clean up before installing."
            exit 0
        fi
    else
        echo ""
        print_status "Existing Cursor commands/rules found (not Code Captain)"
        print_status "Junior will install files to .cursor/rules/ and .cursor/commands/"
        print_status "Conflicts will be detected. Continue? [yes/no]"
        read -r CONTINUE
        
        if [ "$CONTINUE" != "yes" ] && [ "$CONTINUE" != "y" ]; then
            print_status "Installation cancelled."
            exit 0
        fi
    fi
    echo ""
fi

# Load configuration
CONFIG_CONTENT=$(cat "$CONFIG_FILE")

# Check for existing installation
METADATA_FILE=".junior/.junior-install.json"
IS_UPGRADE=false
EXISTING_METADATA=""

if [ -f "$METADATA_FILE" ]; then
    IS_UPGRADE=true
    EXISTING_METADATA=$(cat "$METADATA_FILE")
    print_status "Existing Junior installation detected - performing upgrade"
    
    # Extract existing version
    EXISTING_VERSION=$(echo "$EXISTING_METADATA" | jq -r '.version // "unknown"')
    EXISTING_COMMIT=$(echo "$EXISTING_METADATA" | jq -r '.commit_hash // "unknown"')
    print_status "Current version: $EXISTING_VERSION (commit: ${EXISTING_COMMIT:0:7})"
fi

# Create directory structure
print_status "Creating directory structure..."

# Create directories from config
while IFS= read -r dir; do
    if [ -n "$dir" ]; then
        mkdir -p "$dir"
        print_success "Created directory: $dir"
    fi
done <<< "$(extract_directories "$CONFIG_CONTENT")"

print_success "Directory structure created"

# Initialize metadata tracking
declare -A FILE_METADATA
MODIFIED_FILES=()
CONFLICTING_FILES=()

# Install files based on configuration
print_status "Installing files..."

# Process files from config using jq
while IFS='|' read -r SOURCE DEST IS_DIR SKIP_IF_EXISTS; do
    if [ -n "$SOURCE" ] && [ -n "$DEST" ]; then
        if [ "$IS_DIR" = "true" ]; then
            print_status "Installing directory: $SOURCE -> $DEST"
            if [ -d "$REPO_ROOT/$SOURCE" ]; then
                # Copy all files from directory
                for src_file in "$REPO_ROOT/$SOURCE"*; do
                    if [ -f "$src_file" ]; then
                        filename=$(basename "$src_file")
                        dest_file="$DEST$filename"
                        install_file "$SOURCE$filename" "$dest_file"
                    fi
                done
            else
                print_warning "Source directory not found: $REPO_ROOT/$SOURCE"
            fi
        else
            # Check if file should be skipped if it exists
            if [ "$SKIP_IF_EXISTS" = "true" ] && [ -f "$DEST" ]; then
                print_status "Skipping existing file: $DEST (preserving local customizations)"
            else
                print_status "Installing file: $SOURCE -> $DEST"
                install_file "$SOURCE" "$DEST"
            fi
        fi
    fi
done <<< "$(extract_files "$CONFIG_CONTENT")"

# Check for conflicting files - abort if found
if [ ${#CONFLICTING_FILES[@]} -gt 0 ]; then
    echo ""
    print_error "═══════════════════════════════════════════════════"
    print_error "INSTALLATION ABORTED - File conflicts detected!"
    print_error "═══════════════════════════════════════════════════"
    echo ""
    print_error "These files exist but were NOT installed by Junior:"
    for file in "${CONFLICTING_FILES[@]}"; do
        echo "  • $file"
    done
    echo ""
    print_status "Resolution options:"
    echo "  1. Back up and remove these files, then re-run installation"
    echo "  2. Use /migrate command if migrating from Code Captain"
    echo "  3. Manually review and resolve conflicts"
    echo ""
    exit 1
fi

# Report modified files
if [ ${#MODIFIED_FILES[@]} -gt 0 ]; then
    echo ""
    print_warning "═══════════════════════════════════════════════════"
    print_warning "User-modified files preserved (${#MODIFIED_FILES[@]} files):"
    for file in "${MODIFIED_FILES[@]}"; do
        echo "  • $file"
    done
    echo ""
    print_status "Your customizations were NOT overwritten."
    print_status "To sync changes back: $0 --sync-back <target_dir>"
    print_warning "═══════════════════════════════════════════════════"
    echo ""
fi

# Generate installation metadata
print_status "Generating installation metadata..."

# Build files JSON
FILES_JSON="{"
FIRST=true
for dest_file in "${!FILE_METADATA[@]}"; do
    IFS='|' read -r CHECKSUM SIZE MODIFIED <<< "${FILE_METADATA[$dest_file]}"
    MODIFIED=${MODIFIED:-false}
    
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        FILES_JSON+=","
    fi
    
    FILES_JSON+="\"$dest_file\":{\"sha256\":\"$CHECKSUM\",\"size\":$SIZE,\"modified\":$MODIFIED}"
done
FILES_JSON+="}"

# Get current timestamp
INSTALLED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create metadata JSON
METADATA_JSON=$(jq -n \
    --arg version "$COMMIT_TIMESTAMP" \
    --arg installed_at "$INSTALLED_AT" \
    --arg commit_hash "$COMMIT_HASH" \
    --argjson files "$FILES_JSON" \
    '{
        version: $version,
        installed_at: $installed_at,
        commit_hash: $commit_hash,
        files: $files
    }')

# Write metadata file
echo "$METADATA_JSON" > "$METADATA_FILE"
print_success "Metadata saved to $METADATA_FILE"

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    print_warning "No git repository found. Consider running 'git init' to track your changes."
fi

# Extract messages from config
SUCCESS_MSG=$(echo "$CONFIG_CONTENT" | jq -r '.messages.success // "Junior installation complete!"')
NEXT_STEPS=$(echo "$CONFIG_CONTENT" | jq -r '.messages.nextSteps[]' 2>/dev/null || echo "")
AVAILABLE_COMMANDS=$(echo "$CONFIG_CONTENT" | jq -r '.messages.availableCommands // "Available commands: /feature, /implement, /commit"')

echo ""
print_success "═══════════════════════════════════════════════════"
print_success "$SUCCESS_MSG"
print_success "═══════════════════════════════════════════════════"
echo ""

# Show installation summary
print_status "Installation summary:"
echo "  ✓ Cursor rules: .cursor/rules/ (4 files)"
echo "  ✓ Commands: .cursor/commands/ (4 files)"
echo "  ✓ Junior guide: JUNIOR.md"
echo "  ✓ Working memory: .junior/ (structure created)"
echo "  ✓ Version: $COMMIT_TIMESTAMP (commit: ${COMMIT_HASH:0:7})"
echo ""

if [ -n "$NEXT_STEPS" ]; then
    print_status "Next steps:"
    echo "$NEXT_STEPS" | while IFS= read -r step; do
        if [ -n "$step" ]; then
            echo "  $step"
        fi
    done
    echo ""
fi

print_status "Available commands: $AVAILABLE_COMMANDS"

