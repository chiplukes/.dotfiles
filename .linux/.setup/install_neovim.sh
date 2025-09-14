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

# Ensure Python environment is available
ensure_python
python_real_path=$(get_python_real_path)

# Install dependencies for building from source
install_build_deps ripgrep gcc make git xclip curl cmake ninja-build gettext fd-find lua5.1 liblua5.1-dev wget

# Remove existing installations
remove_existing neovim /opt/nvim* /usr/local/bin/nvim* /usr/local/share/nvim* ~/.local/bin/nvim* ~/.local/share/nvim* "$HOME/tools/neovim"

# Build and install Neovim from source
install_neovim() {
    log_header "Building Neovim from source"

    local build_dir="$HOME/tmp/neovim"
    local install_dir="$HOME/tools/neovim"
    local start_dir="$PWD"

    # Prepare build directory
    safe_cleanup "$build_dir"
    ensure_dir "$build_dir"

    # Clone and checkout stable branch
    git_clone_or_update "https://github.com/neovim/neovim.git" "$build_dir" "master"

    log_info "Checking out stable branch..."
    if ! git checkout stable; then
        die "Failed to checkout stable branch"
    fi

    # Clear any existing build cache
    log_info "Clearing CMake cache..."
    rm -rf build/

    # Build with specified flags
    log_info "Building Neovim..."
    if ! make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$install_dir"; then
        safe_cd "$start_dir"
        die "Failed to build Neovim"
    fi

    # Install
    log_info "Installing Neovim to $install_dir..."
    if ! make install; then
        safe_cd "$start_dir"
        die "Failed to install Neovim"
    fi

    # Return to stable directory and cleanup
    safe_cd "$start_dir"
    safe_cleanup "$build_dir"

    log_success "Neovim built and installed successfully!"
}

# Install LuaRocks
install_luarocks() {
    log_header "Installing LuaRocks"

    local build_dir="$HOME/tmp/luarocks"
    local start_dir="$PWD"

    # Prepare build directory
    safe_cleanup "$build_dir"
    ensure_dir "$build_dir"
    safe_cd "$build_dir"

    # Download LuaRocks
    log_info "Downloading LuaRocks 3.12.2..."
    if ! wget https://luarocks.org/releases/luarocks-3.12.2.tar.gz; then
        safe_cd "$start_dir"
        die "Failed to download LuaRocks"
    fi

    # Extract
    log_info "Extracting LuaRocks..."
    if ! tar zxpf luarocks-3.12.2.tar.gz; then
        safe_cd "$start_dir"
        die "Failed to extract LuaRocks"
    fi

    safe_cd luarocks-3.12.2

    # Configure, build and install
    log_info "Configuring and building LuaRocks..."
    if ! ./configure --lua-version=5.1; then
        safe_cd "$start_dir"
        die "Failed to configure LuaRocks"
    fi

    if ! make; then
        safe_cd "$start_dir"
        die "Failed to build LuaRocks"
    fi

    log_info "Installing LuaRocks..."
    if ! sudo make install; then
        safe_cd "$start_dir"
        die "Failed to install LuaRocks"
    fi

    # Install luasocket
    log_info "Installing luasocket..."
    if ! sudo luarocks install luasocket; then
        log_warning "Failed to install luasocket, but continuing..."
    fi

    # Return to stable directory and cleanup
    safe_cd "$start_dir"
    safe_cleanup "$build_dir"

    log_success "LuaRocks installed successfully!"
}

# Setup Python venv for Neovim
setup_neovim_python() {
    local nvim_venv="$HOME/.config/nvim/.venv"

    # Always work from HOME directory for stability
    safe_cd "$HOME"

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
    add_to_bashrc 'export PATH="$HOME/tools/neovim/bin:$PATH"' "Add Neovim to PATH"
    export PATH="$HOME/tools/neovim/bin:$PATH"
}

# Ensure we start in a stable directory
safe_cd "$HOME"

install_neovim
install_luarocks
setup_neovim_path
setup_neovim_python

verify_installation nvim "nvim" "--version"

log_success "Neovim setup complete!"
echo "Installation directory: $HOME/tools/neovim"
echo "Virtual environment: $HOME/.config/nvim/.venv"
echo "Note: Restart your shell or run 'source ~/.bashrc' to ensure nvim is in your PATH"