#!/bin/bash

# Junior install wrapper.
# Delegates to scripts/junior.py for cross-platform install/update logic.
#
# Usage:
#   ./scripts/install-junior.sh [options]
# Options:
#   -v, --verbose
#   -s, --sync-back
#   -t, --target <claude|cursor|codex|all|csv>   required for install/update
#   -i, --ignore-dirty
#   -y, --yes          (assume yes to prompts, for a run with no terminal)
#   --overwrite        (replace installed files you have since modified)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY_SCRIPT="$SCRIPT_DIR/junior.py"

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

PYTHON_BIN="$(find_python)"
if [ -z "$PYTHON_BIN" ]; then
  echo "[ERROR] Python is required to install Junior (python3 or python not found)." >&2
  exit 1
fi

MODE="install"
ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--sync-back)
      MODE="sync-back"
      shift
      ;;
    -t|--target)
      if [[ $# -lt 2 ]]; then
        echo "[ERROR] --target requires a value: claude, cursor, codex, all, or csv list" >&2
        exit 1
      fi
      ARGS+=("--target" "$2")
      shift 2
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ "$MODE" == "install" && ! " ${ARGS[*]} " =~ " --target " ]]; then
  echo "[ERROR] Missing required --target: claude, cursor, codex, all, or csv list" >&2
  exit 1
fi

if [[ ${#ARGS[@]} -gt 0 ]]; then
  exec "$PYTHON_BIN" "$PY_SCRIPT" "$MODE" "${ARGS[@]}"
fi

exec "$PYTHON_BIN" "$PY_SCRIPT" "$MODE"
