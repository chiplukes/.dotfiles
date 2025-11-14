#!/bin/bash
# Main PC setup script - runs all installation components

# Load helpers
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"
set_strict_mode

log_header "Work PC Setup"

# Installation scripts in order
scripts=(
    "install_base.sh"
    "install_python_uv.sh"
    "install_uv_tools.sh"
    "install_neovim.sh"
    "install_hdl_tools.sh"
)

# Ensure ~/bin is in PATH for all subsequent scripts
if [[ -d "$HOME/bin" ]] && ! echo "$PATH" | grep -q "$HOME/bin"; then
    export PATH="$HOME/bin:$PATH"
    log_info "Added ~/bin to PATH for current session"
fi

# Run each script
for script in "${scripts[@]}"; do
    log_info "Starting $script..."

    # Refresh PATH between scripts in case symlinks were created
    if [[ -d "$HOME/bin" ]] && ! echo "$PATH" | grep -q "$HOME/bin"; then
        export PATH="$HOME/bin:$PATH"
    fi

    if source_script "$script"; then
        log_success "$script completed"
    else
        log_error "$script failed"
        # Continue with other scripts even if one fails
    fi
done

# Show installation summary
show_summary() {
    log_header "Installation Summary"

    if [[ -f "$LOG_FILE" ]]; then
        cat "$LOG_FILE"
        rm "$LOG_FILE"
    else
        echo "No installation log found"
    fi
}

show_summary

log_header "Setup Complete!"
echo "Please restart your shell to pick up all changes"