#!/bin/bash
set -euo pipefail

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

# Setup build directory with proper permissions
BUILD_DIR="$HOME/tmp"
IVERILOG_DIR="$BUILD_DIR/iverilog"

echo "Setting up build directory: $BUILD_DIR"
rm -rf "$BUILD_DIR"  # Clean slate
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit 1

# Clone Icarus Verilog (fresh clone to avoid permission issues)
echo "Cloning Icarus Verilog repository..."
if ! git clone https://github.com/steveicarus/iverilog.git; then
    echo "Failed to clone Icarus Verilog repository" >&2
    exit 1
fi

cd "$IVERILOG_DIR" || exit 1

# Ensure we have write permissions in the directory
chmod -R u+w .

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

# Clean any previous build artifacts that might have wrong permissions
make clean 2>/dev/null || true

if ! make -j"$(nproc)"; then
    echo "Failed to build Icarus Verilog" >&2
    echo "Trying single-threaded build..."
    if ! make; then
        echo "Single-threaded build also failed" >&2
        exit 1
    fi
fi

if ! sudo make install; then
    echo "Failed to install Icarus Verilog" >&2
    exit 1
fi

# Verify Icarus Verilog installation
if command -v iverilog >/dev/null; then
    echo "✓ Icarus Verilog installed successfully"
    echo "Icarus Verilog Installed" >> "$HOME/install_progress_log.txt"
    iverilog -V | head -1
else
    echo "✗ Icarus Verilog installation failed!"
    echo "Icarus Verilog FAILED TO INSTALL!!!" >> "$HOME/install_progress_log.txt"
    exit 1
fi

echo -e "\n====== Installing MyHDL ======\n"

# Setup MyHDL (fresh clone)
MYHDL_DIR="$BUILD_DIR/myhdl"
cd "$BUILD_DIR" || exit 1

echo "Cloning MyHDL repository..."
if ! git clone https://github.com/jandecaluwe/myhdl.git; then
    echo "Failed to clone MyHDL repository" >&2
    exit 1
fi

cd "$MYHDL_DIR" || exit 1

# Ensure proper permissions
chmod -R u+w .

# Create and setup virtual environment
echo "Setting up MyHDL virtual environment..."
if ! python"$PYTHON_USER_VER" -m venv .venv; then
    echo "Failed to create virtual environment" >&2
    exit 1
fi

if ! .venv/bin/python -m pip install --upgrade pip setuptools wheel; then
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

# Ensure write permissions for VPI build
chmod -R u+w .

if ! make; then
    echo "Failed to build MyHDL VPI" >&2
    exit 1
fi

# Create VPI directories if they don't exist
sudo mkdir -p /usr/lib/ivl /usr/local/lib/ivl

# Install VPI module to both locations
if ! sudo install -m 0755 -D ./myhdl.vpi /usr/lib/ivl/myhdl.vpi; then
    echo "Warning: Failed to install VPI to /usr/lib/ivl/"
fi

if ! sudo cp ./myhdl.vpi /usr/local/lib/ivl/; then
    echo "Warning: Failed to install VPI to /usr/local/lib/ivl/"
fi

echo "✓ HDL Tools installation complete!"
echo "MyHDL Installed" >> "$HOME/install_progress_log.txt"

# Clean up build directory to save space
echo "Cleaning up build directory..."
rm -rf "$BUILD_DIR"

echo ""
echo "Installation Summary:"
echo "- Icarus Verilog: $(iverilog -V | head -1)"
echo "- MyHDL VPI modules installed to /usr/lib/ivl/ and /usr/local/lib/ivl/"
echo "- Virtual environment: $MYHDL_DIR/.venv (cleaned up)"

