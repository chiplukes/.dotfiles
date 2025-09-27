#!/bin/bash
# Install HDL development tools (Icarus Verilog and MyHDL)

# Load helpers
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"
set_strict_mode

log_header "Installing HDL Tools"

# Verify Python
ensure_python
python_version=$(get_python_version)
log_info "Using Python version: $python_version"

# Install Icarus Verilog
install_icarus_verilog() {
    log_header "Installing Icarus Verilog"

    # Install prerequisites
    install_build_deps gperf autoconf flex bison

    # Setup and build from stable directory
    local build_dir="$HOME/tmp/iverilog"
    local start_dir="$PWD"

    # Prepare build directory without changing to it
    safe_cleanup "$build_dir"
    ensure_dir "$build_dir"

    git_clone_or_update "https://github.com/steveicarus/iverilog.git" "$build_dir" "master"
    chmod -R u+w .
    run_autotools_build

    verify_installation iverilog "Icarus Verilog" "-V"

    # Return to stable directory before cleanup
    safe_cd "$start_dir"
    safe_cleanup "$build_dir"
}

# Install MyHDL with VPI
install_myhdl() {
    log_header "Installing MyHDL"

    local build_dir="$HOME/tmp/myhdl"
    local start_dir="$PWD"

    # Prepare build directory without changing to it
    safe_cleanup "$build_dir"
    ensure_dir "$build_dir"

    git_clone_or_update "https://github.com/jandecaluwe/myhdl.git" "$build_dir" "master"
    chmod -R u+w .

    # Create venv and install MyHDL (use absolute path for venv)
    local venv_dir="$build_dir/.venv"
    create_venv "$venv_dir" "$python_version"
    install_pip_packages "$venv_dir" setuptools wheel

    if ! "$venv_dir/bin/python" setup.py install; then
        die "Failed to install MyHDL"
    fi

    # Build and install VPI module
    log_info "Installing MyHDL VPI module..."
    safe_cd "cosimulation/icarus"
    chmod -R u+w .

    if ! make; then
        die "Failed to build MyHDL VPI"
    fi

    # Install VPI to both common locations
    sudo mkdir -p /usr/lib/ivl /usr/local/lib/ivl
    sudo install -m 0755 -D ./myhdl.vpi /usr/lib/ivl/myhdl.vpi
    sudo cp ./myhdl.vpi /usr/local/lib/ivl/ || log_warning "Failed to copy to /usr/local/lib/ivl/"

    log_to_file "MyHDL" "Installed"

    # Return to stable directory before cleanup
    safe_cd "$start_dir"
    safe_cleanup "$build_dir"
}

# Install Verible HDL tools
install_verible() {
    log_header "Installing Verible from GitHub releases"

    local install_dir="$HOME/tools/verible"  # Fixed: was $HOME/tmp/verible
    local temp_dir
    temp_dir=$(mktemp -d)
    local start_dir="$PWD"

    safe_cd "$temp_dir"

    # Get latest release version
    log_info "Fetching latest Verible release information..."
    local latest_release
    latest_release=$(curl -s "https://api.github.com/repos/chipsalliance/verible/releases/latest" | \
                    grep -Po '"tag_name": *"\K[^"]*')

    if [[ -z "$latest_release" ]]; then
        safe_cd "$start_dir"
        rm -rf "$temp_dir"
        die "Failed to get latest Verible release version"
    fi

    log_info "Latest Verible version: $latest_release"

    # Download Verible
    local download_url="https://github.com/chipsalliance/verible/releases/download/${latest_release}/verible-${latest_release}-linux-static-x86_64.tar.gz"
    log_info "Downloading Verible from: $download_url"

    if ! curl -Lo verible.tar.gz "$download_url"; then
        safe_cd "$start_dir"
        rm -rf "$temp_dir"
        die "Failed to download Verible"
    fi

    # Extract
    log_info "Extracting Verible..."
    if ! tar xzf verible.tar.gz; then
        safe_cd "$start_dir"
        rm -rf "$temp_dir"
        die "Failed to extract Verible"
    fi

    # Find extracted directory (should be something like verible-v0.0-4023-gc1271a00-linux-static-x86_64)
    local extracted_dir
    extracted_dir=$(find . -maxdepth 1 -type d -name "verible-*" | head -1)

    if [[ -z "$extracted_dir" ]]; then
        safe_cd "$start_dir"
        rm -rf "$temp_dir"
        die "Could not find extracted Verible directory"
    fi

    # Remove old installation and install to ~/tools/verible
    log_info "Installing Verible to $install_dir..."
    rm -rf "$install_dir"
    ensure_dir "$(dirname "$install_dir")"

    if ! mv "$extracted_dir" "$install_dir"; then
        safe_cd "$start_dir"
        rm -rf "$temp_dir"
        die "Failed to move Verible to install directory"
    fi

    # Make binaries executable
    chmod +x "$install_dir/bin"/*

    # Cleanup
    safe_cd "$start_dir"
    rm -rf "$temp_dir"

    # Verify installation
    if "$install_dir/bin/verible-verilog-format" --version >/dev/null 2>&1; then
        log_success "Verible installed successfully!"
        log_info "Verible location: $install_dir"
        log_to_file "Verible" "Installed from GitHub releases"
    else
        die "Verible installation verification failed"
    fi

    # Add to PATH if not already there
    add_to_bashrc 'export PATH="$HOME/tools/verible/bin:$PATH"' "Add Verible tools to PATH"
}

install_icarus_verilog
install_myhdl
install_verible

log_success "HDL Tools installation complete!"
echo "Installation Summary:"
echo "- Icarus Verilog: $(iverilog -V | head -1)"
echo "- MyHDL VPI modules installed to /usr/lib/ivl/ and /usr/local/lib/ivl/"
echo "- Verible: Installed to $HOME/tools/verible"