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

    local optional_packages=(mold)
    
    local packages=(
        perl help2man make autoconf g++ flex bison ccache
        libgoogle-perftools-dev numactl perl-doc
        libfl2 libfl-dev zlibc zlib1g zlib1g-dev mold
    )
    
    for package in "${packages[@]}"; do
        if ! apt-cache show "$package" >/dev/null 2>&1; then
            if [[ " ${optional_packages[*]} " == *" $package "* ]]; then
                log_info "Skipping optional package $package (not available in apt sources)"
                continue
            fi
        fi

        if ! sudo apt-get install -y "$package"; then
            log_warning "Failed to install $package (continuing)"
        fi
    done
}

# Build and install Verilator
build_verilator() {
    local build_dir="$HOME/tmp/verilator"

    git_clone_or_update "https://github.com/verilator/verilator" "$build_dir" "stable"
    
    # Clean environment and checkout stable
    unset VERILATOR_ROOT 2>/dev/null || true
    
    # Build
    run_autotools_build
}

install_verilator_deps
build_verilator

verify_installation verilator "Verilator" "--version"

safe_cleanup "$HOME/tmp"

log_success "Verilator installation complete!"