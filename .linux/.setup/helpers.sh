#!/bin/bash
# Common helper functions for Linux setup scripts

# Set strict error handling (call this in each script)
set_strict_mode() {
    set -euo pipefail
}

# Colors and formatting for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global log file
readonly LOG_FILE="$HOME/install_progress_log.txt"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_header() {
    echo -e "\n${BLUE}====== $1 ======${NC}\n"
}

# Progress logging to file
log_to_file() {
    local package="$1"
    local status="$2"  # "Installed" or "FAILED TO INSTALL!!!"
    echo "$package $status" >> "$LOG_FILE"
}

# Enhanced error handling
die() {
    log_error "$1"
    exit 1
}

# Safe directory operations
ensure_dir() {
    local dir="$1"
    if ! mkdir -p "$dir"; then
        die "Failed to create directory: $dir"
    fi
}

safe_cd() {
    local dir="$1"
    if ! cd "$dir"; then
        die "Failed to change to directory: $dir"
    fi
}

# Clean up directories with permission fixes
safe_cleanup() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        log_info "Cleaning up: $dir"

        # Multiple attempts to fix permissions and remove
        local attempts=3
        local success=false

        for ((i=1; i<=attempts; i++)); do
            # Try increasingly aggressive permission fixes
            if [[ $i -eq 1 ]]; then
                # First attempt: standard permission fix
                chmod -R u+w "$dir" 2>/dev/null || true
            elif [[ $i -eq 2 ]]; then
                # Second attempt: more aggressive permission fix
                find "$dir" -type d -exec chmod u+wx {} \; 2>/dev/null || true
                find "$dir" -type f -exec chmod u+w {} \; 2>/dev/null || true
            else
                # Third attempt: nuclear option with sudo if available
                if command -v sudo >/dev/null 2>&1; then
                    log_warning "Using sudo to fix stubborn permissions in $dir"
                    sudo chmod -R u+w "$dir" 2>/dev/null || true
                fi
            fi

            # Try to remove
            if rm -rf "$dir" 2>/dev/null; then
                success=true
                break
            fi

            # If not the last attempt, wait a moment
            if [[ $i -lt $attempts ]]; then
                sleep 1
            fi
        done

        if [[ "$success" == "false" ]] && [[ -d "$dir" ]]; then
            log_warning "Could not completely remove $dir (some permission issues)"
            log_info "You may need to manually run: sudo rm -rf $dir"
        fi
    fi
}

# Command existence check
has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Safe temporary directory operations
with_temp_dir() {
    local callback="$1"
    local temp_dir
    temp_dir=$(mktemp -d)
    local original_dir="$PWD"

    # Ensure we can return to original directory
    if [[ ! -d "$original_dir" ]]; then
        original_dir="$HOME"
    fi

    # Execute callback in temp directory
    (
        safe_cd "$temp_dir"
        "$callback" "$temp_dir"
    )
    local exit_code=$?

    # Always clean up and return to safe directory
    safe_cd "$original_dir"
    rm -rf "$temp_dir" 2>/dev/null || true

    return $exit_code
}

# Safe symlink creation (removes existing link first to prevent circular references)
safe_symlink() {
    local target="$1"
    local link_name="$2"

    # Remove existing symlink/file
    rm -f "$link_name" 2>/dev/null || true

    # Create new symlink
    if ! ln -sf "$target" "$link_name"; then
        log_error "Failed to create symlink: $link_name -> $target"
        return 1
    fi

    # Verify the symlink works
    if [[ -e "$link_name" ]]; then
        log_info "Created symlink: $(basename "$link_name") -> $target"
        return 0
    else
        log_error "Symlink verification failed: $link_name"
        return 1
    fi
}

# Package management
apt_update() {
    log_info "Updating package lists..."
    if ! sudo apt-get update; then
        die "Failed to update package list"
    fi
}

apt_upgrade() {
    log_info "Upgrading packages..."
    if ! sudo apt-get upgrade -y; then
        log_warning "Some packages failed to upgrade"
    fi
}

# Install single package with verification
install_package() {
    local package="$1"
    local verify_cmd="${2:-}"  # Command to verify (optional)

    log_info "Installing $package..."
    if sudo apt-get install -y "$package"; then
        # If no verify command specified, just check if package was installed via dpkg
        if [[ -z "$verify_cmd" ]]; then
            if dpkg -l | grep -q "^ii  $package "; then
                log_success "$package installed successfully"
                log_to_file "$package" "Installed"
                return 0
            else
                log_error "$package installation verification failed (not in dpkg list)"
                log_to_file "$package" "FAILED TO INSTALL!!!"
                return 1
            fi
        # If verify command specified, check if it exists
        elif has_command "$verify_cmd"; then
            log_success "$package installed successfully"
            log_to_file "$package" "Installed"
            return 0
        else
            log_error "$package installation verification failed (command '$verify_cmd' not found)"
            log_to_file "$package" "FAILED TO INSTALL!!!"
            return 1
        fi
    else
        log_error "$package installation failed"
        log_to_file "$package" "FAILED TO INSTALL!!!"
        return 1
    fi
}

# Install multiple packages
install_packages() {
    local packages=("$@")
    local failed=0

    for package in "${packages[@]}"; do
        if ! install_package "$package"; then
            ((failed++))
        fi
    done

    if [[ $failed -gt 0 ]]; then
        log_warning "$failed packages failed to install"
    fi
}

# Install packages with custom verification commands
# Usage: install_packages_with_verify "package1:command1" "package2:command2" "package3"
install_packages_with_verify() {
    local failed=0

    for pkg_spec in "$@"; do
        if [[ "$pkg_spec" == *":"* ]]; then
            local package="${pkg_spec%%:*}"
            local verify_cmd="${pkg_spec##*:}"
            if ! install_package "$package" "$verify_cmd"; then
                ((failed++))
            fi
        else
            if ! install_package "$pkg_spec"; then
                ((failed++))
            fi
        fi
    done

    if [[ $failed -gt 0 ]]; then
        log_warning "$failed packages failed to install"
    fi
}

# Install packages without verification (for build dependencies)
install_build_deps() {
    local packages=("$@")

    log_info "Installing build dependencies: ${packages[*]}"
    for package in "${packages[@]}"; do
        if ! sudo apt-get install -y "$package"; then
            die "Failed to install build dependency: $package"
        fi
    done
}

# Python helpers
get_python_version() {
    local config_file="$HOME/.dotfiles/python_config"
    if [[ -f "$config_file" ]]; then
        grep '^PYTHON_VERSION=' "$config_file" | cut -d'=' -f2 | tr -d ' '
    else
        echo "3.12"  # fallback
    fi
}

get_python_cmd() {
    # With uv-only approach, we don't need python-user symlinks
    # Just ensure uv is available and let it handle Python discovery
    if ! has_command uv; then
        die "uv not found! Run install_python_uv.sh first."
    fi

    local python_version
    python_version=$(get_python_version)

    # Verify uv can find this Python version
    if ! uv python find "$python_version" >/dev/null 2>&1; then
        die "Python $python_version not found via uv! Run install_python_uv.sh first."
    fi

    # Return the uv python path for compatibility
    uv python find "$python_version"
}

# Deprecated: get_python_real_path - use get_python_version() instead
# This function is kept for backward compatibility but will be removed
get_python_real_path() {
    log_warning "get_python_real_path is deprecated - scripts should use uv directly"
    get_python_cmd
}

verify_python() {
    local python_cmd
    python_cmd=$(get_python_cmd)

    if ! "$python_cmd" --version >/dev/null 2>&1; then
        die "Python command $python_cmd is not working!"
    fi

    log_info "Python version: $("$python_cmd" --version)"
}

# Ensure Python environment is available (run install_python_uv.sh if needed)
ensure_python() {
    local python_version
    python_version=$(get_python_version)

    if ! has_command uv; then
        log_info "uv not found, installing..."
        local script_dir
        script_dir=$(get_script_dir)

        if [[ -f "$script_dir/install_python_uv.sh" ]]; then
            if ! source_script "install_python_uv.sh"; then
                die "Failed to install Python environment"
            fi
        else
            die "uv not found and install_python_uv.sh not available"
        fi
    elif ! uv python find "$python_version" >/dev/null 2>&1; then
        log_info "Python $python_version not found, installing..."
        if ! uv python install "$python_version"; then
            die "Failed to install Python $python_version with uv"
        fi
    else
        verify_python
    fi
}

# Build helpers
setup_build_dir() {
    local build_dir="$1"

    safe_cleanup "$build_dir"
    ensure_dir "$build_dir"
    safe_cd "$build_dir"
}

# Git operations
git_clone_or_update() {
    local repo_url="$1"
    local target_dir="$2"
    local branch="${3:-master}"

    if [[ -d "$target_dir/.git" ]]; then
        log_info "Updating existing repository: $(basename "$target_dir")"
        safe_cd "$target_dir"
        if ! git pull; then
            die "Failed to update repository"
        fi
    else
        log_info "Cloning repository: $(basename "$target_dir")"
        # Remove any existing non-git directory
        if [[ -d "$target_dir" ]]; then
            rm -rf "$target_dir"
        fi
        if ! git clone${branch:+ -b "$branch"} "$repo_url" "$target_dir"; then
            die "Failed to clone repository"
        fi
        safe_cd "$target_dir"
    fi
}

# Build operations
run_autotools_build() {
    local make_jobs="${1:-$(nproc)}"

    log_info "Running autoconf..."
    if ! autoconf || ! sh autoconf.sh 2>/dev/null; then
        if ! ./autogen.sh 2>/dev/null; then
            die "Failed to run autoconf/autogen"
        fi
    fi

    log_info "Configuring build..."
    if ! ./configure; then
        die "Failed to configure build"
    fi

    log_info "Building (using $make_jobs jobs)..."
    make clean 2>/dev/null || true

    if ! make -j"$make_jobs"; then
        log_warning "Parallel build failed, trying single-threaded..."
        if ! make; then
            die "Build failed"
        fi
    fi

    log_info "Installing..."
    if ! sudo make install; then
        die "Installation failed"
    fi
}

# Installation verification
verify_installation() {
    local command="$1"
    local name="$2"
    local version_flag="${3:---version}"

    if has_command "$command"; then
        log_success "$name installed successfully"
        log_to_file "$name" "Installed"

        # Show version if available
        if "$command" "$version_flag" >/dev/null 2>&1; then
            "$command" "$version_flag" | head -1
        fi
        return 0
    else
        log_error "$name installation failed!"
        log_to_file "$name" "FAILED TO INSTALL!!!"
        return 1
    fi
}

# Virtual environment helpers
create_venv() {
    local venv_path="$1"
    local python_version="${2:-3.12}"  # Optional version parameter, defaults to 3.12

    safe_cleanup "$venv_path"

    log_info "Creating virtual environment with uv: $venv_path (Python $python_version)"

    # Check if uv is available
    if ! has_command uv; then
        log_error "uv not found! Please run install_python_uv.sh first."
        die "uv is required for virtual environment creation"
    fi

    # Create venv with uv (let uv find the right Python)
    if ! uv venv --python "$python_version" "$venv_path"; then
        die "Failed to create virtual environment with uv"
    fi

    # Verify venv works
    if ! "$venv_path/bin/python" --version >/dev/null 2>&1; then
        die "Virtual environment Python is not working!"
    fi

    log_success "Virtual environment created successfully with uv (Python $python_version)"
}

install_pip_packages() {
    local venv_path="$1"
    shift
    local packages=("$@")

    log_info "Installing Python packages with uv: ${packages[*]}"

    # Verify venv exists and works
    if [[ ! -f "$venv_path/bin/python" ]]; then
        die "Virtual environment not found: $venv_path"
    fi

    if ! "$venv_path/bin/python" --version >/dev/null 2>&1; then
        die "Virtual environment Python is not working: $venv_path"
    fi

    # Check if uv is available
    if ! has_command uv; then
        log_error "uv not found! Please run install_python_uv.sh first."
        die "uv is required for package installation"
    fi

    # Change to a stable directory to avoid "No such file or directory" errors
    local current_dir="$PWD"
    safe_cd "$HOME"

    # Install packages using uv pip
    if ! uv pip install --python "$venv_path/bin/python" "${packages[@]}"; then
        # Return to original directory and fail
        safe_cd "$current_dir"
        die "Failed to install Python packages: ${packages[*]}"
    fi

    # Return to original directory
    safe_cd "$current_dir"
    log_success "Python packages installed successfully with uv: ${packages[*]}"
}

# UV tool installation helpers
install_uv_tool() {
    local tool_name="$1"
    local description="${2:-Python tool}"

    # Ensure UV is available
    if ! has_command uv; then
        log_error "UV not found! Please run install_python_uv.sh first."
        return 1
    fi

    log_info "Installing UV tool: $tool_name ($description)"

    # Check if already installed
    if uv tool list 2>/dev/null | grep -q "^$tool_name "; then
        log_info "$tool_name already installed via UV"
        log_to_file "$tool_name" "Already installed (UV tool)"
        return 0
    fi

    # Install the tool
    if uv tool install "$tool_name"; then
        log_success "$tool_name installed successfully"
        log_to_file "$tool_name" "Installed (UV tool)"
        return 0
    else
        log_error "Failed to install $tool_name"
        log_to_file "$tool_name" "FAILED TO INSTALL (UV tool)!!!"
        return 1
    fi
}

install_uv_tool_from_path() {
    local tool_name="$1"
    local tool_path="$2"
    local description="${3:-Local Python tool}"

    # Ensure UV is available
    if ! has_command uv; then
        log_error "UV not found! Please run install_python_uv.sh first."
        return 1
    fi

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
    if uv tool install "$tool_path"; then
        log_success "$tool_name installed successfully from $tool_path"
        log_to_file "$tool_name" "Installed (UV tool from path)"
        return 0
    else
        log_error "Failed to install $tool_name from $tool_path"
        log_to_file "$tool_name" "FAILED TO INSTALL (UV tool from path)!!!"
        return 1
    fi
}


# Path management
add_to_bashrc() {
    local line="$1"
    local comment="${2:-Added by setup script}"

    if ! grep -q "$line" "$HOME/.bashrc" 2>/dev/null; then
        log_info "Adding to ~/.bashrc: $line"
        {
            echo ""
            echo "# $comment"
            echo "$line"
        } >> "$HOME/.bashrc"
    fi
}

# Ubuntu version detection
get_ubuntu_version() {
    grep -oP 'VERSION_ID="\K[\d.]+' /etc/os-release 2>/dev/null || echo "unknown"
}

# Fix Ubuntu sources based on version
fix_ubuntu_sources() {
    local ubuntu_version
    ubuntu_version=$(get_ubuntu_version)

    log_info "Found Ubuntu version: $ubuntu_version"

    case "$ubuntu_version" in
        "22.04")
            log_info "Fixing 22.04 deb-src URIs"
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
            sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
            ;;
        "24.04")
            log_info "Fixing 24.04 deb-src URIs"
            sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.backup
            sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
            ;;
        *)
            log_info "No URI fix needed for version: $ubuntu_version"
            ;;
    esac
}

# Script directory helper
get_script_dir() {
    dirname "${BASH_SOURCE[1]}"
}

# Source other scripts
source_script() {
    local script="$1"
    local script_dir
    script_dir=$(get_script_dir)
    local script_path="$script_dir/$script"

    if [[ -f "$script_path" ]]; then
        log_info "Running $script..."
        # shellcheck source=/dev/null
        if ! bash "$script_path"; then
            log_warning "$script failed"
            return 1
        fi
    else
        log_warning "Script not found: $script_path"
        return 1
    fi
}

# Remove existing installations (for clean installs)
remove_existing() {
    local package="$1"
    local locations=("${@:2}")  # Additional locations to clean

    log_info "Removing any existing $package installations..."

    # Remove apt version
    sudo apt remove --purge "$package" -y 2>/dev/null || true

    # Remove snap version
    sudo snap remove "$package" 2>/dev/null || true

    # Remove from specified locations
    for location in "${locations[@]}"; do
        sudo rm -rf "$location" 2>/dev/null || true
    done

    # Remove symlinks
    sudo find /usr/bin /usr/local/bin -name "$package*" -type l -delete 2>/dev/null || true
}