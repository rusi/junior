#!/bin/bash

# Junior bootstrap script.
# Install or update Junior with:
#   curl -LsSf https://rusi.github.io/junior/install.sh | sh

set -euo pipefail

TARGET=""

GITHUB_REPO="rusi/junior"
GITHUB_BRANCH="main"
TARBALL_URL="https://github.com/${GITHUB_REPO}/archive/refs/heads/${GITHUB_BRANCH}.tar.gz"
API_URL="https://api.github.com/repos/${GITHUB_REPO}/commits/${GITHUB_BRANCH}"

info() { printf "[INFO] %s\n" "$1"; }
error() { printf "[ERROR] %s\n" "$1" >&2; }

find_python() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
    return
  fi
  if command -v python >/dev/null 2>&1; then
    echo "python"
    return
  fi
  echo ""
}

download_file() {
  local url="$1"
  local dest="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -LsSf "$url" -o "$dest"
    return
  fi
  if command -v wget >/dev/null 2>&1; then
    wget -qO "$dest" "$url"
    return
  fi
  error "curl or wget is required"
  exit 1
}

extract_json_field() {
  local json="$1"
  local key="$2"
  printf "%s" "$json" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed "s/\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\"/\1/"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--target)
        if [[ $# -lt 2 ]]; then
          error "--target requires a value: codex, cursor, gemini, claude, all, or csv list"
          exit 1
        fi
        TARGET="$2"
        shift 2
        ;;
      *)
        error "Unknown option: $1"
        exit 1
        ;;
    esac
  done

  if [[ -z "$TARGET" ]]; then
    error "Missing required --target. Use one of: claude, codex, cursor, gemini, all, or a csv list."
    exit 1
  fi

  local py_bin
  py_bin="$(find_python)"
  if [ -z "$py_bin" ]; then
    error "Python is required (python3 or python not found)."
    exit 1
  fi

  if [[ "$TARGET" == "codex" ]]; then
    info "Installing Junior global assets (~/.codex)"
  elif [[ "$TARGET" == "cursor" ]]; then
    info "Installing Junior global assets (~/.cursor)"
  elif [[ "$TARGET" == "gemini" ]]; then
    info "Installing Junior global assets (~/.gemini)"
  elif [[ "$TARGET" == "claude" ]]; then
    info "Installing Junior global assets (~/.claude)"
  elif [[ "$TARGET" == "all" || "$TARGET" == *","* ]]; then
    info "Installing Junior global assets for multiple targets: $TARGET"
  else
    info "Installing Junior global assets for target: $TARGET"
  fi

  local temp_dir
  temp_dir="$(mktemp -d /tmp/.junior-bootstrap-XXXXX)"
  trap 'rm -rf "$temp_dir"' EXIT

  local tarball
  tarball="$temp_dir/junior.tar.gz"

  info "Downloading Junior..."
  download_file "$TARBALL_URL" "$tarball"

  info "Extracting..."
  tar -xzf "$tarball" -C "$temp_dir"

  local extracted_dir
  extracted_dir="$(find "$temp_dir" -maxdepth 1 -type d -name "junior-*" | head -1)"
  if [ -z "$extracted_dir" ]; then
    error "Could not find extracted Junior directory"
    exit 1
  fi

  local latest_commit=""
  local latest_date=""
  local latest_timestamp="unknown"
  if command -v curl >/dev/null 2>&1; then
    local response
    response="$(curl -s -f "$API_URL" 2>/dev/null || true)"
    if [ -n "$response" ]; then
      latest_commit="$(extract_json_field "$response" "sha")"
      latest_date="$(printf "%s" "$response" | grep -o '"date"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"date"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')"
      if [ -n "$latest_date" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
          latest_timestamp="$(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$latest_date" +%s 2>/dev/null || echo "unknown")"
        else
          latest_timestamp="$(date -u -d "$latest_date" +%s 2>/dev/null || echo "unknown")"
        fi
      fi
    fi
  fi

  cat > "$extracted_dir/.githash" <<EOF
COMMIT_HASH=${latest_commit:-unknown}
COMMIT_DATE=${latest_date:-unknown}
COMMIT_TIMESTAMP=${latest_timestamp:-unknown}
EOF

  local installer
  installer="$extracted_dir/scripts/junior.py"
  if [ ! -f "$installer" ]; then
    error "Missing installer: $installer"
    exit 1
  fi

  info "Running installer..."
  "$py_bin" "$installer" install --force --target "$TARGET"

  info "Junior bootstrap complete."
}

main "$@"
