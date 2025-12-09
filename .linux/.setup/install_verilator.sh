#!/bin/bash
# Install Verilator HDL simulator

# Load helpers
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"
set_strict_mode

log_header "Installing Verilator"

# Install prerequisites (allow some to fail)
install_verilator_deps() {
    log_info "Installing Verilator prerequisites..."
    apt_update

    local packages=(
        perl help2man make autoconf g++ flex bison ccache
        libgoogle-perftools-dev numactl perl-doc
        libfl2 libfl-dev zlibc zlib1g zlib1g-dev mold
    )

    for package in "${packages[@]}"; do
        if ! sudo apt-get install -y "$package"; then
            log_warning "Failed to install $package (continuing)"
        fi
    done
}

# Build and install Verilator
build_verilator() {
    local build_dir="$HOME/tmp/verilator"
    local parent_dir="$(dirname "$build_dir")"

    if [[ -d "$build_dir" ]]; then
        log_info "Updating existing Verilator repository..."
        safe_cd "$build_dir"
        git pull || die "Failed to update repository"
    else
        # Ensure parent directory exists before cloning
        mkdir -p "$parent_dir"
        safe_cd "$parent_dir"
        git_clone_or_update "https://github.com/verilator/verilator" "$build_dir"
        safe_cd "$build_dir"
    fi

    # Clean environment and checkout stable
    unset VERILATOR_ROOT 2>/dev/null || true

    log_info "Checking out stable branch..."
    if ! git checkout stable; then
        die "Failed to checkout stable branch"
    fi

    # Build
    log_info "Building Verilator..."

    if [[ -f "autogen.sh" ]]; then
        bash autogen.sh || die "autogen.sh failed"
    else
        autoconf || die "autoconf failed"
    fi

    ./configure || die "configure failed"
    make -j "$(nproc)" || die "make failed"
    sudo make install || die "make install failed"
}

install_verilator_deps
build_verilator

verify_installation verilator "Verilator" "--version"

log_success "Verilator installation complete!"