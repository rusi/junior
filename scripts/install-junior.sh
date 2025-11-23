#!/bin/bash

# Junior Installation Script
# Usage: ./scripts/install-junior.sh /path/to/project
# Compatible with bash 3.2+ (macOS default)

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

# Function to add file to metadata JSON (bash 3.2 compatible)
add_file_metadata() {
    local dest="$1"
    local checksum="$2"
    local size="$3"
    local modified="${4:-false}"
    
    local entry=$(jq -n \
        --arg path "$dest" \
        --arg sha "$checksum" \
        --arg sz "$size" \
        --arg mod "$modified" \
        '{($path): {sha256: $sha, size: ($sz|tonumber), modified: ($mod=="true")}}')
    
    if [ -z "$FILE_METADATA_JSON" ]; then
        FILE_METADATA_JSON="$entry"
    else
        FILE_METADATA_JSON=$(echo "$FILE_METADATA_JSON" | jq ". + $entry")
    fi
}

# Function to install a single file with checksum tracking
install_file() {
    local source="$1"
    local dest="$2"
    local file_existed=false
    
    [ -f "$dest" ] && file_existed=true
    
    # Check for file conflicts (capture immediately to avoid set -e exit)
    local conflict_type
    check_file_conflict "$dest" && conflict_type=$? || conflict_type=$?
    
    if [ $conflict_type -eq 1 ]; then
        # User modified Junior file - preserve
        print_warning "User-modified: $dest (preserving)"
        MODIFIED_FILES+=("$dest")
        
        local checksum=$(calculate_checksum "$dest")
        local size=$(get_file_size "$dest")
        add_file_metadata "$dest" "$checksum" "$size" "true"
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
        add_file_metadata "$dest" "$checksum" "$size" "false"
        
        if [ "$file_existed" = true ]; then
            print_success "Up-to-date: $dest"
        else
            print_success "Installed: $dest"
        fi
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
IGNORE_DIRTY=false
FORCE=false
TARGET_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --sync-back)
            SYNC_BACK=true
            shift
            ;;
        --ignore-dirty)
            IGNORE_DIRTY=true
            shift
            ;;
        --force)
            FORCE=true
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
    print_error "Usage: $0 [OPTIONS] <target_project_directory>"
    echo ""
    echo "Options:"
    echo "  --sync-back      Sync modified files back to Junior source"
    echo "  --ignore-dirty   Skip git clean check (for testing/development)"
    echo "  --force          Skip all confirmation prompts and proceed with installation"
    echo ""
    echo "Examples:"
    echo "  $0 ~/sources/my_project                           # Install Junior"
    echo "  $0 --ignore-dirty ~/sources/my_project            # Install (skip git check)"
    echo "  $0 --force ~/sources/my_project                   # Install (skip confirmations)"
    echo "  $0 --ignore-dirty --force ~/sources/my_project    # Install (testing mode)"
    echo "  $0 --sync-back ~/sources/my_project               # Sync modifications back"
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
    
    # Find files marked as modified (or compare against source)
    SYNC_FILES=()
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Check if file is marked as modified in metadata
            IS_MODIFIED=$(echo "$EXISTING_METADATA" | jq -r ".files[\"$file\"].modified // false")
            
            if [ "$IS_MODIFIED" = "true" ]; then
                SYNC_FILES+=("$file")
            else
                # Also check if file differs from source (for files modified after last install)
                # Determine source file path
                source_file=""
                if [[ "$file" == .cursor/rules/* ]] || [[ "$file" == .cursor/commands/* ]]; then
                    source_file="$REPO_ROOT/$file"
                elif [ "$file" = "JUNIOR.md" ]; then
                    source_file="$REPO_ROOT/README.md"
                fi
                
                if [ -n "$source_file" ] && [ -f "$source_file" ]; then
                    CURRENT_CHECKSUM=$(calculate_checksum "$file")
                    SOURCE_CHECKSUM=$(calculate_checksum "$source_file")
                    
                    if [ "$CURRENT_CHECKSUM" != "$SOURCE_CHECKSUM" ]; then
                        SYNC_FILES+=("$file")
                    fi
                fi
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
    print_status "Syncing files back to Junior source..."
    
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
        if [ "$IGNORE_DIRTY" = true ]; then
            print_warning "Git has uncommitted changes (ignored via --ignore-dirty)"
            print_warning "Note: Version may not reflect actual state"
        else
            print_error "Junior source git not clean. Commit or stash changes first."
            print_error "Version is based on commit timestamp - need clean state."
            echo ""
            print_status "Uncommitted changes:"
            git status --short
            echo ""
            print_status "Options:"
            echo "  1. Commit or stash changes"
            echo "  2. Use --ignore-dirty flag (for testing only)"
            exit 1
        fi
    fi
    
    # Get version info from git
    COMMIT_HASH=$(git rev-parse HEAD)
    COMMIT_TIMESTAMP=$(git log -1 --format=%ct)
    
    if [ "$IGNORE_DIRTY" = true ]; then
        print_warning "Using commit: ${COMMIT_HASH:0:7} (with local changes)"
    else
        print_success "Junior source is clean (commit: ${COMMIT_HASH:0:7})"
    fi
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

# Check for Code Captain (requires explicit --force to proceed)
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
    
    if [ "$FORCE" != true ]; then
        print_status "Recommendations:"
        echo "  1. Review .cursor/commands/ for custom commands you want to keep"
        echo "  2. Review .cursor/rules/ for custom rules you want to keep"
        echo "  3. Consider backing up .code-captain/ if it contains work"
        echo "  4. Use /migrate command (coming soon) for proper migration"
        echo ""
        print_error "Installation aborted. Use --force to install alongside Code Captain."
        exit 1
    else
        print_warning "Proceeding with installation (--force enabled)"
        echo ""
    fi
fi

# Note: If Junior is already installed (has metadata), upgrade proceeds automatically
# Conflict detection happens during file installation - only uncontrolled files abort

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

# Initialize metadata tracking (bash 3.2 compatible - no associative arrays)
FILE_METADATA_JSON=""
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

# Use accumulated FILE_METADATA_JSON (already in correct format)
if [ -z "$FILE_METADATA_JSON" ]; then
    FILES_JSON="{}"
else
    FILES_JSON="$FILE_METADATA_JSON"
fi

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

