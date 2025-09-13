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
    "install_neovim.sh"
    "install_hdl_tools.sh"
)

# Run each script
for script in "${scripts[@]}"; do
    if source_script "$script"; then
        log_success "$script completed"
    else
        log_error "$script failed"
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