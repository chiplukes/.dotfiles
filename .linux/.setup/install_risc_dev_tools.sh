#!/bin/bash
# Install RISC-V development toolchain

# Load helpers
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"
set_strict_mode

log_header "Installing RISC-V Development Tools"

# Configuration
PREFIX="/usr/local/share/gcc-riscv32-unknown-elf"

# Install prerequisites
install_riscv_deps() {
    log_info "Installing RISC-V toolchain prerequisites..."
    
    local packages=(
        autoconf automake autotools-dev curl libmpc-dev libmpfr-dev
        libgmp-dev gawk build-essential bison flex texinfo gperf
        libtool patchutils bc zlib1g-dev libexpat-dev
    )
    
    apt_update
    install_build_deps "${packages[@]}"
}

# Clone toolchain repositories
clone_toolchain_repos() {
    local build_dir="$HOME/tmp/riscv-toolchain"
    setup_build_dir "$build_dir"
    
    log_info "Cloning toolchain repositories (this may take a while)..."
    
    git_clone_or_update "https://gcc.gnu.org/git/gcc.git" "gcc"
    git_clone_or_update "https://sourceware.org/git/binutils-gdb.git" "binutils-gdb" 
    git_clone_or_update "https://sourceware.org/git/newlib-cygwin.git" "newlib-cygwin"
    
    # Create combined source directory with symlinks
    log_info "Creating combined source directory..."
    rm -rf combined
    ensure_dir combined
    safe_cd combined
    
    ln -sf ../newlib-cygwin/* .
    ln -sf ../binutils-gdb/* .
    ln -sf ../gcc/* .
}

# Build toolchain
build_riscv_toolchain() {
    log_info "Building RISC-V toolchain (this will take a long time)..."
    
    ensure_dir build
    safe_cd build
    
    log_info "Configuring build..."
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
        die "Failed to configure toolchain"
    fi
    
    log_info "Building (using $(nproc) jobs)..."
    if ! make -j"$(nproc)"; then
        die "Failed to build toolchain"
    fi
    
    log_info "Installing..."
    if ! sudo make install; then
        die "Failed to install toolchain"
    fi
}

install_riscv_deps
clone_toolchain_repos
build_riscv_toolchain

# Add to PATH
add_to_bashrc "export PATH=\$PATH:$PREFIX/bin" "RISC-V toolchain"
export PATH="$PATH:$PREFIX/bin"

verify_installation riscv32-unknown-elf-gcc "RISC-V toolchain" "-v"

safe_cleanup "$HOME/tmp"

log_success "RISC-V toolchain installation complete!"
echo "Toolchain installed to: $PREFIX"
echo "Restart your shell or run: source ~/.bashrc"