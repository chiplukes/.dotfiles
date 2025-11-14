#!/bin/bash
# Install UV tools - Python CLI tools via UV package manager

# Load helpers
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"
set_strict_mode

log_header "Installing UV Tools"

# Ensure UV is available
if ! has_command uv; then
    log_error "UV not found! Running install_python_uv.sh first..."
    if source_script "install_python_uv.sh"; then
        log_success "UV installed successfully"
    else
        die "Failed to install UV - cannot proceed with UV tools installation"
    fi
fi

# Verify UV is working
if ! uv --version >/dev/null 2>&1; then
    die "UV command is not working correctly"
fi

log_info "UV version: $(uv --version)"

# Install a UV tool (package from PyPI)
install_uv_tool() {
    local tool_name="$1"
    local description="${2:-Python tool}"

    log_info "Installing UV tool: $tool_name ($description)"

    # Check if already installed
    if uv tool list 2>/dev/null | grep -q "^$tool_name "; then
        log_info "$tool_name already installed via UV"
        log_to_file "$tool_name" "Already installed (UV tool)"
        return 0
    fi

    # Install the tool
    if uv tool install --force "$tool_name"; then
        log_success "$tool_name installed successfully"
        log_to_file "$tool_name" "Installed (UV tool)"

        # Verify installation
        if uv tool list 2>/dev/null | grep -q "^$tool_name "; then
            log_info "Verification: $tool_name is installed"
        else
            log_warning "$tool_name installation couldn't be verified"
        fi
        return 0
    else
        log_error "Failed to install $tool_name"
        log_to_file "$tool_name" "FAILED TO INSTALL (UV tool)!!!"
        return 1
    fi
}

# Install a local Python file as a UV tool
install_uv_tool_from_path() {
    local tool_name="$1"
    local tool_path="$2"
    local description="${3:-Local Python tool}"

    log_info "Installing local UV tool: $tool_name from $tool_path ($description)"

    # Expand tilde and environment variables
    tool_path="${tool_path/#\~/$HOME}"
    tool_path=$(eval echo "$tool_path")

    # Check if path exists
    if [[ ! -f "$tool_path" ]]; then
        log_error "Tool path not found: $tool_path"
        log_to_file "$tool_name" "FAILED TO INSTALL (path not found)!!!"
        return 1
    fi

    # Check if already installed
    if uv tool list 2>/dev/null | grep -q "^$tool_name "; then
        log_info "$tool_name already installed via UV"
        log_to_file "$tool_name" "Already installed (UV tool from path)"
        return 0
    fi

    # Install the tool from path
    if uv tool install --force "$tool_path"; then
        log_success "$tool_name installed successfully from $tool_path"
        log_to_file "$tool_name" "Installed (UV tool from path)"
        return 0
    else
        log_error "Failed to install $tool_name from $tool_path"
        log_to_file "$tool_name" "FAILED TO INSTALL (UV tool from path)!!!"
        return 1
    fi
}

# Core UV tools - common Python development tools
log_header "Installing Core UV Tools"

install_uv_tool "ruff" "Extremely fast Python linter and formatter"
install_uv_tool "mypy" "Static type checker for Python"
install_uv_tool "uv" "UV tool itself (ensuring latest version)"

# Optional UV tools (uncomment to install)
# install_uv_tool "black" "Python code formatter"
# install_uv_tool "pytest" "Python testing framework"
# install_uv_tool "ipython" "Enhanced Python interactive shell"
# install_uv_tool "httpie" "User-friendly HTTP client"

# Example: Install local Python tools
# Uncomment and modify the paths below to install your custom tools
# install_uv_tool_from_path "my-tool" "$HOME/.python/scripts/my_tool.py" "My custom CLI tool"
# install_uv_tool_from_path "work-helper" "$HOME/projects/scripts/helper.py" "Work helper script"

log_success "UV tools installation complete!"

# Show installed tools
log_header "Installed UV Tools"
if has_command uv; then
    uv tool list || log_warning "Could not list UV tools"
fi

echo ""
echo "UV tools are installed in: $HOME/.local/bin"
echo "Make sure $HOME/.local/bin is in your PATH"
echo ""
echo "To add more UV tools, edit: $script_dir/install_uv_tools.sh"
echo "Or install manually with: uv tool install <package-name>"
