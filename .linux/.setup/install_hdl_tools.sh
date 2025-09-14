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
python_real_path=$(get_python_real_path)

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

    git_clone_or_update "https://github.com/steveicarus/iverilog.git" "$build_dir"
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

    git_clone_or_update "https://github.com/jandecaluwe/myhdl.git" "$build_dir"
    chmod -R u+w .

    # Create venv and install MyHDL
    create_venv ".venv" "$python_real_path"
    install_pip_packages ".venv" setuptools wheel

    if ! .venv/bin/python setup.py install; then
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

install_icarus_verilog
install_myhdl

log_success "HDL Tools installation complete!"
echo "Installation Summary:"
echo "- Icarus Verilog: $(iverilog -V | head -1)"
echo "- MyHDL VPI modules installed to /usr/lib/ivl/ and /usr/local/lib/ivl/"