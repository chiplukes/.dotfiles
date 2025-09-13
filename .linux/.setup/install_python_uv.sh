#!/bin/bash
# Install user Python with uv

# Load helpers
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"
set_strict_mode

# Configuration
USER_PY_VERSION="3.12"

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
    
    # Get version info
    local maj_min patch_ver
    maj_min="$("$py_path" -c 'import sys;print(".".join(map(str,sys.version_info[:2])))')"
    patch_ver="$("$py_path" -c 'import sys;print(".".join(map(str,sys.version_info[:3])))')"
    
    # Create symlinks
    ensure_dir "$HOME/bin"
    ln -sf "$py_path" "$HOME/bin/python${maj_min}"
    ln -sf "$py_path" "$HOME/bin/python${patch_ver}"
    ln -sf "$py_path" "$HOME/bin/python-user"
    ln -sf "$py_path" "$HOME/bin/python${maj_min}-user"
    
    log_success "Python $patch_ver installed successfully!"
    log_info "Interpreter path: $py_path"
    log_info "Symlinks: python${maj_min} python${patch_ver} python-user"
    
    "$py_path" -V
    log_to_file "python${patch_ver}" "Installed (uv)"
}

install_uv
setup_python

log_success "Use 'python-user' in all scripts for version-independent access"