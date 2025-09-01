#!/bin/bash
set -euo pipefail

echo -e "\n====== Installing HDL Tools ======\n"

# Use python-user but get the real path for venv creation
PYTHON_CMD="python-user"

echo "Using Python command: $PYTHON_CMD"

# Verify Python executable exists and works
if ! command -v "$PYTHON_CMD" >/dev/null; then
    echo "Python executable $PYTHON_CMD not found!" >&2
    echo "Make sure install_python_uv.sh was run first." >&2
    exit 1
fi

if ! "$PYTHON_CMD" --version >/dev/null 2>&1; then
    echo "Python command $PYTHON_CMD is not working!" >&2
    exit 1
fi

# Get the real Python path for venv creation
PYTHON_REAL_PATH=$(readlink -f "$(which $PYTHON_CMD)")
echo "Python version: $("$PYTHON_CMD" --version)"
echo "Real Python path: $PYTHON_REAL_PATH"

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

# Force remove build directory with proper permissions cleanup
if [[ -d "$BUILD_DIR" ]]; then
    echo "Cleaning up previous build directory..."
    # Fix permissions before removal
    chmod -R u+w "$BUILD_DIR" 2>/dev/null || true
    rm -rf "$BUILD_DIR"
fi

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

# Create and setup virtual environment using the real Python path
echo "Setting up MyHDL virtual environment..."
if ! "$PYTHON_REAL_PATH" -m venv .venv; then
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

# Clean up build directory to save space (with proper permissions)
echo "Cleaning up build directory..."
chmod -R u+w "$BUILD_DIR" 2>/dev/null || true
rm -rf "$BUILD_DIR"

echo ""
echo "Installation Summary:"
echo "- Icarus Verilog: $(iverilog -V | head -1)"
echo "- MyHDL VPI modules installed to /usr/lib/ivl/ and /usr/local/lib/ivl/"
echo "- Python executable used: $PYTHON_CMD ($PYTHON_REAL_PATH)"
echo "- Virtual environment: $MYHDL_DIR/.venv (cleaned up)"

