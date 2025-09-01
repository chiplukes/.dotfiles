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

echo "Installing dependencies..."
if ! sudo apt update; then
    echo "Failed to update package list" >&2
    exit 1
fi

if ! sudo apt install -y ripgrep gcc make unzip git xclip curl; then
    echo "Failed to install packages" >&2
    exit 1
fi

# Install latest stable Neovim following official instructions
echo "Installing latest stable Neovim..."

# Remove ALL existing Neovim installations first
echo "Removing any existing Neovim installations..."

# Remove apt version
sudo apt remove --purge neovim -y 2>/dev/null || echo "No apt neovim to remove"

# Remove snap version
sudo snap remove nvim 2>/dev/null || echo "No snap nvim to remove"

# Remove from common locations
sudo rm -rf /opt/nvim* /usr/local/bin/nvim* /usr/local/share/nvim*
rm -rf ~/.local/bin/nvim* ~/.local/share/nvim*

# Remove any nvim symlinks
sudo find /usr/bin /usr/local/bin -name "nvim*" -type l -delete 2>/dev/null || true

# Download Neovim
echo "Downloading latest Neovim..."
if ! curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz; then
    echo "Failed to download Neovim" >&2
    exit 1
fi

# Remove old installation and install new one
echo "Installing Neovim to /opt..."
if ! sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz; then
    echo "Failed to extract Neovim" >&2
    exit 1
fi

# Clean up download
rm nvim-linux-x86_64.tar.gz

# Add to PATH for current session
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Clean up old PATH entries in .bashrc and add new one
if [[ -f "$HOME/.bashrc" ]]; then
    # Remove old nvim PATH entries
    sed -i '/nvim/d' "$HOME/.bashrc"

    # Add new PATH entry
    echo '' >> "$HOME/.bashrc"
    echo '# Add Neovim to PATH' >> "$HOME/.bashrc"
    echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> "$HOME/.bashrc"
fi

# Create Python venv for Neovim provider using the real Python path
NVIM_VENV="${HOME}/.config/nvim/.venv"
echo "Setting up Python virtual environment for Neovim..."

# Clean up any existing virtual environment
if [[ -d "$NVIM_VENV" ]]; then
    echo "Removing existing Neovim virtual environment..."
    rm -rf "$NVIM_VENV"
fi

# Create fresh virtual environment
echo "Creating new virtual environment..."
if ! "$PYTHON_REAL_PATH" -m venv "$NVIM_VENV"; then
    echo "Failed to create Python virtual environment" >&2
    exit 1
fi

# Verify the new venv works
if ! "$NVIM_VENV/bin/python" --version >/dev/null 2>&1; then
    echo "Virtual environment Python is not working!" >&2
    exit 1
fi

echo "Installing Python packages in virtual environment..."
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
echo "Installation directory: /opt/nvim-linux-x86_64"
echo "Binary location: /opt/nvim-linux-x86_64/bin/nvim"
echo "Virtual environment: $NVIM_VENV"
echo "Configuration: $NVIM_INIT_LUA"
echo "Python executable used: $PYTHON_CMD ($PYTHON_REAL_PATH)"
echo ""
echo "Note: Restart your shell or run 'source ~/.bashrc' to ensure nvim is in your PATH"