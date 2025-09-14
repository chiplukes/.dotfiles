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

# Install base packages with correct verification commands
install_packages_with_verify "git:git" "curl:curl" "subversion:svn" "ripgrep:rg"

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

# Install latest fd-find binary from GitHub
install_fd() {
    log_header "Installing fd-find from GitHub releases"

    local install_dir="$HOME/tmp/fd"
    local bin_dir="$HOME/tools/fd"
    local temp_dir
    temp_dir=$(mktemp -d)
    local start_dir="$PWD"

    # Create directories
    ensure_dir "$install_dir"
    ensure_dir "$bin_dir"

    safe_cd "$temp_dir"

    # Get latest release info and download URL
    log_info "Fetching latest fd release information..."
    local latest_url
    latest_url=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | \
                 grep "browser_download_url.*fd.*x86_64-unknown-linux-gnu.tar.gz" | \
                 cut -d '"' -f 4)

    if [[ -z "$latest_url" ]]; then
        safe_cd "$start_dir"
        rm -rf "$temp_dir"
        die "Failed to get fd download URL"
    fi

    log_info "Downloading fd from: $latest_url"
    if ! curl -L -o fd.tar.gz "$latest_url"; then
        safe_cd "$start_dir"
        rm -rf "$temp_dir"
        die "Failed to download fd"
    fi

    # Extract
    log_info "Extracting fd..."
    if ! tar xzf fd.tar.gz; then
        safe_cd "$start_dir"
        rm -rf "$temp_dir"
        die "Failed to extract fd"
    fi

    # Find the extracted directory (it will have a version number)
    local extracted_dir
    extracted_dir=$(find . -maxdepth 1 -type d -name "fd-*" | head -1)

    if [[ -z "$extracted_dir" ]]; then
        safe_cd "$start_dir"
        rm -rf "$temp_dir"
        die "Could not find extracted fd directory"
    fi

    # Install binary to ~/tools/fd
    log_info "Installing fd binary to $bin_dir..."
    if ! cp "$extracted_dir/fd" "$bin_dir/fd"; then
        safe_cd "$start_dir"
        rm -rf "$temp_dir"
        die "Failed to install fd binary"
    fi

    # Make executable
    chmod +x "$bin_dir/fd"

    # Cleanup
    safe_cd "$start_dir"
    rm -rf "$temp_dir"

    # Verify installation
    if "$bin_dir/fd" --version >/dev/null 2>&1; then
        log_success "fd installed successfully!"
        log_info "fd version: $("$bin_dir/fd" --version)"
        log_to_file "fd-find" "Installed from GitHub releases"
    else
        die "fd installation verification failed"
    fi

    # Add to PATH if not already there
    add_to_bashrc 'export PATH="$HOME/tools/fd:$PATH"' "Add ~/tools/fd/ to PATH for fd and other tools"
}

install_fd

log_success "Base installation complete!"
echo "Installed packages:"
echo "- git, curl, subversion, ripgrep (via apt)"
echo "- fzf (from GitHub)"
echo "- fd-find (latest from GitHub releases)"
echo "Note: Restart your shell to pick up fzf, fd, and PATH changes"