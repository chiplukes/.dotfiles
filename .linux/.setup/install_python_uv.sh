#!/bin/bash
# Install user Python with uv

# Load helpers
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"
set_strict_mode

# Load Python version from central config
config_file="$(dirname "${BASH_SOURCE[0]}")/../python_config"
if [[ -f "$config_file" ]]; then
    USER_PY_VERSION=$(grep '^PYTHON_VERSION=' "$config_file" | cut -d'=' -f2 | tr -d ' ')
else
    USER_PY_VERSION="3.12"  # fallback
fi

log_header "Installing user Python with uv (${USER_PY_VERSION})"

# Install uv if not present
install_uv() {
    if has_command uv; then
        log_info "uv already installed"
        return 0
    fi

    log_info "Installing uv..."
    if ! has_command curl; then
        install_packages curl ca-certificates
    fi

    if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
        die "uv installation failed"
    fi

    export PATH="$HOME/.local/bin:$PATH"

    if ! has_command uv; then
        die "uv installation verification failed"
    fi
}

# Setup Python with uv
setup_python() {
    log_info "Installing Python $USER_PY_VERSION with uv..."

    # Install interpreter if not cached
    if ! uv python find "$USER_PY_VERSION" >/dev/null 2>&1; then
        uv python install "$USER_PY_VERSION"
    fi

    local py_path
    py_path="$(uv python find "$USER_PY_VERSION" 2>/dev/null || true)"

    if [[ -z "$py_path" ]]; then
        die "Failed to resolve Python $USER_PY_VERSION"
    fi

    # Get version info for logging
    local patch_ver
    patch_ver="$("$py_path" -c 'import sys;print(".".join(map(str,sys.version_info[:3])))')"

    # Clean up any existing symlinks from previous installations
    log_info "Cleaning up any existing Python symlinks..."
    rm -f "$HOME/bin/python-user" "$HOME/bin/python${USER_PY_VERSION}-user" 2>/dev/null || true

    # With uv-only approach, we don't need symlinks
    # uv handles Python discovery and management directly
    log_info "Python installed and managed by uv "

    # Verify uv can find the installed Python
    log_info "Verifying uv Python installation..."
    if uv python find "$USER_PY_VERSION" >/dev/null 2>&1; then
        log_success "uv can find Python $USER_PY_VERSION correctly"
    else
        log_warning "uv cannot find Python $USER_PY_VERSION"
    fi

    log_success "Python $patch_ver installed successfully!"
    log_info "Interpreter path: $py_path"
    log_info "Managed by: uv "

    # Use the original path for version check
    "$py_path" -V
    log_to_file "python${patch_ver}" "Installed (uv)"
}

install_uv
setup_python

log_success "Python is now managed by uv - use 'uv python find $USER_PY_VERSION' to get the path"
log_info "Scripts will use uv directly for virtual environment creation and package management"