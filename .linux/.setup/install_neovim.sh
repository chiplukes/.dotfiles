#!/bin/bash

set -euo pipefail

echo -e "\n====== Install Neovim ======\n"

# Optional: use stable PPA (uncomment if needed newer than repo)
# sudo add-apt-repository -y ppa:neovim-ppa/stable

echo "Installing Neovim and dependencies..."
if ! sudo apt update; then
    echo "Failed to update package list" >&2
    exit 1
fi

if ! sudo apt install -y neovim python3 python3-venv python3-pip ripgrep gcc make unzip git xclip; then
    echo "Failed to install packages" >&2
    exit 1
fi

# Create Python venv for Neovim provider
NVIM_VENV="${HOME}/.config/nvim/.venv"
echo "Setting up Python virtual environment for Neovim..."

if [[ ! -d "$NVIM_VENV" ]]; then
    if ! python3 -m venv "$NVIM_VENV"; then
        echo "Failed to create Python virtual environment" >&2
        exit 1
    fi
fi

if ! "$NVIM_VENV/bin/pip" install --upgrade pip pynvim; then
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

echo -e "\n====== Installing HDL Tools ======\n"

# Check for Python setup script
PYTHON_SETUP_SCRIPT="$HOME/bash_scripts/setpython.bash"
if [[ -f "$PYTHON_SETUP_SCRIPT" ]]; then
    echo "Sourcing Python setup..."
    source "$PYTHON_SETUP_SCRIPT"
else
    echo "Warning: Python setup script not found at $PYTHON_SETUP_SCRIPT"
    echo "Using default Python version detection..."
    PYTHON_USER_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
fi

echo "Using Python version: $PYTHON_USER_VER"

echo -e "\n====== Installing Icarus Verilog ======\n"

# Install prerequisites
packages=(gperf autoconf flex bison)
for package in "${packages[@]}"; do
    if ! sudo apt-get install -y "$package"; then
        echo "Failed to install $package" >&2
        exit 1
    fi
done

# Setup build directory
BUILD_DIR="$HOME/tmp"
IVERILOG_DIR="$BUILD_DIR/iverilog"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit 1

# Clone or update Icarus Verilog
if [[ -d "$IVERILOG_DIR" ]]; then
    echo "Updating existing Icarus Verilog repository..."
    cd "$IVERILOG_DIR" || exit 1
    git pull
else
    echo "Cloning Icarus Verilog repository..."
    if ! git clone https://github.com/steveicarus/iverilog.git; then
        echo "Failed to clone Icarus Verilog repository" >&2
        exit 1
    fi
    cd "$IVERILOG_DIR" || exit 1
fi

# Build and install Icarus Verilog
echo "Building Icarus Verilog..."
if ! sh autoconf.sh; then
    echo "Failed to run autoconf" >&2
    exit 1
fi

if ! ./configure; then
    echo "Failed to configure Icarus Verilog" >&2
    exit 1
fi

if ! make -j"$(nproc)"; then
    echo "Failed to build Icarus Verilog" >&2
    exit 1
fi

if ! sudo make install; then
    echo "Failed to install Icarus Verilog" >&2
    exit 1
fi

# Verify Icarus Verilog installation
if command -v iverilog >/dev/null; then
    echo "✓ Icarus Verilog installed successfully"
    echo "Icarus Verilog Installed" >> "$HOME/install_progress_log.txt"
else
    echo "✗ Icarus Verilog installation failed!"
    echo "Icarus Verilog FAILED TO INSTALL!!!" >> "$HOME/install_progress_log.txt"
    exit 1
fi

echo -e "\n====== Installing MyHDL ======\n"

# Setup MyHDL
MYHDL_DIR="$BUILD_DIR/myhdl"
cd "$BUILD_DIR" || exit 1

if [[ -d "$MYHDL_DIR" ]]; then
    echo "Updating existing MyHDL repository..."
    cd "$MYHDL_DIR" || exit 1
    git pull
else
    echo "Cloning MyHDL repository..."
    if ! git clone https://github.com/jandecaluwe/myhdl.git; then
        echo "Failed to clone MyHDL repository" >&2
        exit 1
    fi
    cd "$MYHDL_DIR" || exit 1
fi

# Create and setup virtual environment
echo "Setting up MyHDL virtual environment..."
if ! python"$PYTHON_USER_VER" -m venv .venv; then
    echo "Failed to create virtual environment" >&2
    exit 1
fi

if ! .venv/bin/python -m pip install setuptools; then
    echo "Failed to install setuptools" >&2
    exit 1
fi

# Install MyHDL
echo "Installing MyHDL..."
if ! .venv/bin/python setup.py install; then
    echo "Failed to install MyHDL" >&2
    exit 1
fi

# Compile and install cosimulation VPI
echo "Installing MyHDL VPI module..."
cd "$MYHDL_DIR/cosimulation/icarus" || exit 1

if ! make; then
    echo "Failed to build MyHDL VPI" >&2
    exit 1
fi

# Install VPI module to both locations
if ! sudo install -m 0755 -D ./myhdl.vpi /usr/lib/ivl/myhdl.vpi; then
    echo "Warning: Failed to install VPI to /usr/lib/ivl/"
fi

if ! sudo cp ./myhdl.vpi /usr/local/lib/ivl/; then
    echo "Warning: Failed to install VPI to /usr/local/lib/ivl/"
fi

echo "✓ HDL Tools installation complete!"
echo "MyHDL Installed" >> "$HOME/install_progress_log.txt"
