#!/bin/bash
set -euo pipefail

echo -e "\n====== Installing RISC-V Development Tools ======\n"

# Install prerequisites
echo "Installing RISC-V toolchain prerequisites..."
packages=(
    autoconf automake autotools-dev curl libmpc-dev libmpfr-dev
    libgmp-dev gawk build-essential bison flex texinfo gperf
    libtool patchutils bc zlib1g-dev libexpat-dev
)

if ! sudo apt-get update; then
    echo "Failed to update package list" >&2
    exit 1
fi

for package in "${packages[@]}"; do
    if ! sudo apt-get install -y "$package"; then
        echo "Failed to install $package" >&2
        exit 1
    fi
done

# Setup build directory
BUILD_DIR="$HOME/tmp/riscv-toolchain"
PREFIX="/usr/local/share/gcc-riscv32-unknown-elf"

echo "Setting up build directory: $BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit 1

# Clone repositories
echo "Cloning toolchain repositories (this may take a while)..."
if [[ ! -d "gcc" ]]; then
    if ! git clone --depth=1 https://gcc.gnu.org/git/gcc.git; then
        echo "Failed to clone GCC repository" >&2
        exit 1
    fi
fi

if [[ ! -d "binutils-gdb" ]]; then
    if ! git clone --depth=1 https://sourceware.org/git/binutils-gdb.git; then
        echo "Failed to clone binutils repository" >&2
        exit 1
    fi
fi

if [[ ! -d "newlib-cygwin" ]]; then
    if ! git clone --depth=1 https://sourceware.org/git/newlib-cygwin.git; then
        echo "Failed to clone newlib repository" >&2
        exit 1
    fi
fi

# Create combined source directory
echo "Creating combined source directory..."
rm -rf combined
mkdir combined
cd combined || exit 1

# Create symlinks
ln -sf ../newlib-cygwin/* .
ln -sf ../binutils-gdb/* .
ln -sf ../gcc/* .

# Build toolchain
echo "Building RISC-V toolchain (this will take a long time)..."
mkdir -p build
cd build || exit 1

if ! ../configure \
    --target=riscv32-unknown-elf \
    --enable-languages=c \
    --disable-shared \
    --disable-threads \
    --disable-multilib \
    --disable-gdb \
    --disable-libssp \
    --with-newlib \
    --with-arch=rv32ima \
    --with-abi=ilp32 \
    --prefix="$PREFIX"; then
    echo "Failed to configure toolchain" >&2
    exit 1
fi

if ! make -j"$(nproc)"; then
    echo "Failed to build toolchain" >&2
    exit 1
fi

if ! sudo make install; then
    echo "Failed to install toolchain" >&2
    exit 1
fi

# Add to PATH
echo "Adding toolchain to PATH..."
if ! grep -q "$PREFIX/bin" "$HOME/.bashrc"; then
    echo "export PATH=\$PATH:$PREFIX/bin" >> "$HOME/.bashrc"
fi

# Verify installation
export PATH="$PATH:$PREFIX/bin"
if command -v riscv32-unknown-elf-gcc >/dev/null; then
    echo "✓ RISC-V toolchain installed successfully"
    echo "RISC-V toolchain Installed" >> "$HOME/install_progress_log.txt"
    riscv32-unknown-elf-gcc -v
else
    echo "✗ RISC-V toolchain installation failed!"
    echo "RISC-V toolchain FAILED TO INSTALL!!!" >> "$HOME/install_progress_log.txt"
    exit 1
fi

echo ""
echo "RISC-V toolchain installation complete!"
echo "Toolchain installed to: $PREFIX"
echo "Restart your shell or run: source ~/.bashrc"
