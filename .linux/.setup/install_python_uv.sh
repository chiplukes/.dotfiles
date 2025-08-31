#!/bin/bash
set -euo pipefail

# Set the desired major.minor (or full patch) user Python version here.
USER_PY_VERSION="3.12"

echo -e "\n====== Installing user Python with uv (${USER_PY_VERSION}) ======\n"

LOGFILE="$HOME/install_progress_log.txt"

# Ensure uv present (bootstrap only if missing)
if ! command -v uv >/dev/null 2>&1; then
  if ! command -v curl >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y curl ca-certificates
  fi
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "uv install failed" | tee -a "$LOGFILE"
  exit 1
fi

# Install interpreter if not already cached (idempotent)
if ! uv python find "$USER_PY_VERSION" >/dev/null 2>&1; then
  uv python install "$USER_PY_VERSION"
fi

PY_PATH="$(uv python find "$USER_PY_VERSION" 2>/dev/null || true)"
if [[ -z "$PY_PATH" ]]; then
  echo "Failed to resolve Python $USER_PY_VERSION" | tee -a "$LOGFILE"
  exit 1
fi

MAJ_MIN="$("$PY_PATH" -c 'import sys;print(".".join(map(str,sys.version_info[:2])))')"
PATCH_VER="$("$PY_PATH" -c 'import sys;print(".".join(map(str,sys.version_info[:3])))')"

mkdir -p "$HOME/bin"

# Symlinks (avoid overriding system 'python')
ln -sf "$PY_PATH" "$HOME/bin/python${MAJ_MIN}"
ln -sf "$PY_PATH" "$HOME/bin/python${PATCH_VER}"
ln -sf "$PY_PATH" "$HOME/bin/python-user"           # generic alias
ln -sf "$PY_PATH" "$HOME/bin/python${MAJ_MIN}-user" # versioned alias

"$PY_PATH" -V
echo "Interpreter path: $PY_PATH"
echo "Symlinks: python${MAJ_MIN} python${PATCH_VER} python-user"

echo "python${PATCH_VER} Installed (uv)" >> "$LOGFILE"

# Optional: write resolved info
cat > "$HOME/.user_python_resolved" <<EOF
USER_PYTHON_PATH=$PY_PATH
USER_PYTHON_MAJOR_MINOR=$MAJ_MIN
USER_PYTHON_PATCH=$PATCH_VER
EOF
