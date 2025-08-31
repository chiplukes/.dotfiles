#!/bin/bash
set -euo pipefail

echo -e "\n====== Installing Verilator ======\n"

# Install prerequisites
echo "Installing Verilator prerequisites..."
packages=(
    perl help2man make autoconf g++ flex bison ccache
    libgoogle-perftools-dev numactl perl-doc
    libfl2 libfl-dev zlibc zlib1g zlib1g-dev mold
)

if ! sudo apt-get update; then
    echo "Failed to update package list" >&2
    exit 1
fi

for package in "${packages[@]}"; do
    if ! sudo apt-get install -y "$package"; then
        echo "Warning: Failed to install $package (continuing)" >&2
    fi
done

# Setup build directory
BUILD_DIR="$HOME/tmp"
VERILATOR_DIR="$BUILD_DIR/verilator"

echo "Setting up build directory: $BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit 1

# Clone or update repository
if [[ -d "$VERILATOR_DIR" ]]; then
    echo "Updating existing Verilator repository..."
    cd "$VERILATOR_DIR" || exit 1
    if ! git pull; then
        echo "Failed to update repository" >&2
        exit 1
    fi
else
    echo "Cloning Verilator repository..."
    if ! git clone https://github.com/verilator/verilator; then
        echo "Failed to clone repository" >&2
        exit 1
    fi
    cd "$VERILATOR_DIR" || exit 1
fi

# Clean environment and checkout stable
unset VERILATOR_ROOT 2>/dev/null || true

echo "Checking out stable branch..."
if ! git checkout stable; then
    echo "Failed to checkout stable branch" >&2
    exit 1
fi

# Build Verilator
echo "Building Verilator..."
if ! autoconf; then
    echo "Failed to run autoconf" >&2
    exit 1
fi

if ! ./configure; then
    echo "Failed to configure" >&2
    exit 1
fi

if ! make -j"$(nproc)"; then
    echo "Failed to build Verilator" >&2
    exit 1
fi

if ! sudo make install; then
    echo "Failed to install Verilator" >&2
    exit 1
fi

# Verify installation
if command -v verilator >/dev/null; then
    echo "✓ Verilator installed successfully"
    echo "Verilator Installed" >> "$HOME/install_progress_log.txt"
    verilator --version
else
    echo "✗ Verilator installation failed!"
    echo "Verilator FAILED TO INSTALL!!!" >> "$HOME/install_progress_log.txt"
    exit 1
fi

echo ""
echo "Verilator installation complete!"
echo "Build directory: $VERILATOR_DIR"
