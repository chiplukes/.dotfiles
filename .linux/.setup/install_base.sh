#!/bin/bash
# Install base utilities for all Linux setups

# Load helpers
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"
set_strict_mode

log_header "Base Utils for all installs"

# Fix Ubuntu sources and update
fix_ubuntu_sources
apt_update
apt_upgrade

# Install base packages
base_packages=(git curl subversion ripgrep)
install_packages "${base_packages[@]}"

# Install fzf
install_fzf() {
    log_info "Installing fzf..."
    local fzf_dir="$HOME/.fzf"
    
    if [[ -d "$fzf_dir" ]]; then
        log_info "Updating existing fzf installation..."
        safe_cd "$fzf_dir"
        git pull
    else
        log_info "Cloning fzf repository..."
        git_clone_or_update "https://github.com/junegunn/fzf.git" "$fzf_dir"
    fi
    
    # Install fzf (automatically answers yes to prompts)
    if ! "$fzf_dir/install" --all; then
        log_warning "fzf installation had issues"
    else
        log_success "fzf installed successfully"
        log_to_file "fzf" "Installed"
    fi
}

install_fzf

log_success "Base installation complete!"
echo "Note: Restart your shell to pick up fzf and other changes"