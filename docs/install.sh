#!/usr/bin/env bash
# Install Junior's latest tagged release. An optional path selects project scope.
set -euo pipefail

if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN=python3
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN=python
else
  echo "[ERROR] Python is required (python3 or python not found)." >&2
  exit 1
fi

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
