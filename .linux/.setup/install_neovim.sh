#!/bin/bash
set -euo pipefail

echo -e "\n====== Install Neovim ======\n"

# Use python-user but get the real path for venv creation
PYTHON_CMD="python-user"

echo "Using Python command: $PYTHON_CMD"

# Verify Python executable exists
if ! command -v "$PYTHON_CMD" >/dev/null; then
    echo "Python executable $PYTHON_CMD not found!" >&2
    echo "Make sure install_python_uv.sh was run first." >&2
    exit 1
fi

# Get the real Python path for venv creation
PYTHON_REAL_PATH=$(readlink -f "$(which $PYTHON_CMD)")
echo "Python version: $("$PYTHON_CMD" --version)"
echo "Real Python path: $PYTHON_REAL_PATH"

echo "Installing Neovim and dependencies..."
if ! sudo apt update; then
    echo "Failed to update package list" >&2
    exit 1
fi

if ! sudo apt install -y neovim ripgrep gcc make unzip git xclip; then
    echo "Failed to install packages" >&2
    exit 1
fi

# Create Python venv for Neovim provider using the real Python path
NVIM_VENV="${HOME}/.config/nvim/.venv"
echo "Setting up Python virtual environment for Neovim..."

if [[ ! -d "$NVIM_VENV" ]]; then
    # Use the real Python path for venv creation to avoid symlink issues
    if ! "$PYTHON_REAL_PATH" -m venv "$NVIM_VENV"; then
        echo "Failed to create Python virtual environment" >&2
        exit 1
    fi
fi

# Use the venv's python executable for pip operations
if ! "$NVIM_VENV/bin/python" -m pip install --upgrade pip pynvim; then
    echo "Failed to install Python packages" >&2
    exit 1
fi

# Configure Python host program in init.lua
NVIM_INIT_LUA="${HOME}/.config/nvim/init.lua"
mkdir -p "$(dirname "$NVIM_INIT_LUA")"

# Check if Python host prog is already configured
if [[ -f "$NVIM_INIT_LUA" ]] && grep -q "python3_host_prog" "$NVIM_INIT_LUA"; then
    echo "Python host prog already configured in init.lua"
else
    echo "Configuring Python host prog in init.lua"
    # Ensure file exists and has proper spacing
    touch "$NVIM_INIT_LUA"
    if [[ -s "$NVIM_INIT_LUA" ]]; then
        echo "" >> "$NVIM_INIT_LUA"
    fi
    {
        echo "-- Added by install_neovim.sh"
        echo "vim.g.python3_host_prog = '${NVIM_VENV}/bin/python'"
    } >> "$NVIM_INIT_LUA"
fi

# Verify installation
if command -v nvim >/dev/null; then
    echo "✓ Neovim installed successfully"
    echo "nvim Installed" >> "${HOME}/install_progress_log.txt"
    nvim --version | head -1
else
    echo "✗ Neovim installation failed!"
    echo "nvim FAILED TO INSTALL!!!" >> "${HOME}/install_progress_log.txt"
    exit 1
fi

echo ""
echo "Neovim setup complete!"
echo "Virtual environment: $NVIM_VENV"
echo "Configuration: $NVIM_INIT_LUA"
echo "Python executable used: $PYTHON_CMD ($PYTHON_REAL_PATH)"