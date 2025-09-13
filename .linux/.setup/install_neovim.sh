#!/bin/bash
# Install Neovim with Python support

# Load helpers
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"
set_strict_mode

# Create .config/nvim directory if it doesn't exist (for cross-platform config)
mkdir -p "$HOME/.config/nvim"

log_header "Install Neovim"

# Verify Python
verify_python
python_real_path=$(get_python_real_path)

# Install dependencies
install_build_deps ripgrep gcc make unzip git xclip curl

# Remove existing installations
remove_existing neovim /opt/nvim* /usr/local/bin/nvim* /usr/local/share/nvim* ~/.local/bin/nvim* ~/.local/share/nvim*

# Download and install Neovim
install_neovim() {
    log_info "Downloading latest Neovim..."
    local temp_dir
    temp_dir=$(mktemp -d)
    safe_cd "$temp_dir"

    if ! curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz; then
        die "Failed to download Neovim"
    fi

    log_info "Installing Neovim to /opt..."
    if ! sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz; then
        die "Failed to extract Neovim"
    fi

    rm -rf "$temp_dir"
}

# Setup Python venv for Neovim
setup_neovim_python() {
    local nvim_venv="$HOME/.config/nvim/.venv"

    log_info "Setting up Python virtual environment for Neovim..."
    create_venv "$nvim_venv" "$python_real_path"
    install_pip_packages "$nvim_venv" pynvim

    # Configure Python host in init.lua
    local nvim_init_lua="$HOME/.config/nvim/init.lua"
    ensure_dir "$(dirname "$nvim_init_lua")"

    if [[ -f "$nvim_init_lua" ]] && grep -q "python3_host_prog" "$nvim_init_lua"; then
        log_info "Python host prog already configured in init.lua"
    else
        log_info "Configuring Python host prog in init.lua"
        {
            [[ -s "$nvim_init_lua" ]] && echo ""
            echo "-- Added by install_neovim.sh"
            echo "vim.g.python3_host_prog = '${nvim_venv}/bin/python'"
        } >> "$nvim_init_lua"
    fi
}

# Add to PATH
setup_neovim_path() {
    add_to_bashrc 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' "Add Neovim to PATH"
    export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
}

install_neovim
setup_neovim_path
setup_neovim_python

verify_installation nvim "nvim" "--version"

log_success "Neovim setup complete!"
echo "Installation directory: /opt/nvim-linux-x86_64"
echo "Virtual environment: $HOME/.config/nvim/.venv"
echo "Note: Restart your shell or run 'source ~/.bashrc' to ensure nvim is in your PATH"