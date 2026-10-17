#!/usr/bin/env bash
# Install Junior's latest tagged release. An optional path selects project scope.
set -euo pipefail

find_python() {
  local minimum=10 target="" argument candidate version major minor patch score
  local best="" best_score=0 found="" directory
  local directories=() candidates=()
  while [[ $# -gt 0 ]]; do
    argument="$1"
    shift
    case "$argument" in
      -t|--target) target="${1:-}"; if [[ $# -gt 0 ]]; then shift; fi ;;
      --target=*) target="${argument#*=}" ;;
      -h|--help|--list-versions) minimum=10 ;;
    esac
  done
  target="${target//[[:space:]]/}"
  if [[ -n "$target" ]]; then
    case ",$target," in
      *,[Cc][Oo][Dd][Ee][Xx],*|,[Aa][Ll][Ll],) minimum=11 ;;
      *) minimum=10 ;;
    esac
  fi
  for candidate in python3 python; do
    if candidate="$(command -v "$candidate")"; then candidates+=("$candidate"); fi
  done
  IFS=: read -r -a directories <<< "$PATH"
  for directory in "${directories[@]}"; do
    for candidate in "${directory:-.}"/python3.[0-9]*; do
      if [[ -x "$candidate" && ! -d "$candidate" ]]; then candidates+=("$candidate"); fi
    done
  done
  for candidate in ${candidates[@]+"${candidates[@]}"}; do
    if ! version="$("$candidate" -c 'import sys; print(" ".join(map(str, sys.version_info[:3])))' 2>/dev/null)"; then
      found+=" $candidate (unusable);"
      continue
    fi
    if [[ ! "$version" =~ ^[0-9]+\ [0-9]+\ [0-9]+$ ]]; then continue; fi
    read -r major minor patch <<< "$version"
    found+=" $candidate (${major}.${minor}.${patch});"
    score=$((major * 1000000 + minor * 1000 + patch))
    if (( score >= 3000000 + minimum * 1000 && score > best_score )); then
      best="$candidate"
      best_score="$score"
    fi
  done
  if [[ -z "$best" ]]; then
    echo "[ERROR] Python 3.$minimum or newer is required for the selected targets (Codex requires 3.11+). Found:${found:- none}." >&2
    return 1
  fi
  printf '%s\n' "$best"
}

# Checkout wrappers source this selector; piped and downloaded entry points run below.
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "$0" ]]; then return; fi
PYTHON_BIN="$(find_python "$@")"

BOOTSTRAP_DIR="$(mktemp -d)"
trap 'rm -rf "$BOOTSTRAP_DIR"' EXIT
BOOTSTRAP_URL="https://raw.githubusercontent.com/rusi/junior/main/scripts/release_source.py"
if command -v curl >/dev/null 2>&1; then
  curl -LsSf "$BOOTSTRAP_URL" -o "$BOOTSTRAP_DIR/release_source.py"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$BOOTSTRAP_DIR/release_source.py" "$BOOTSTRAP_URL"
else
  echo "[ERROR] curl or wget is required." >&2
  exit 1
fi

"$PYTHON_BIN" "$BOOTSTRAP_DIR/release_source.py" "$@"
