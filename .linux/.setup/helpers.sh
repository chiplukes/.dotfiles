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
        chmod -R u+w "$dir" 2>/dev/null || true
        rm -rf "$dir"
    fi
}

# Command existence check
has_command() {
    command -v "$1" >/dev/null 2>&1
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
    local verify_cmd="${2:-$package}"  # Command to verify (defaults to package name)
    
    log_info "Installing $package..."
    if sudo apt-get install -y "$package"; then
        if has_command "$verify_cmd"; then
            log_success "$package installed successfully"
            log_to_file "$package" "Installed"
            return 0
        else
            log_error "$package installation verification failed"
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
get_python_cmd() {
    local python_cmd="python-user"
    if ! has_command "$python_cmd"; then
        die "Python executable $python_cmd not found! Run install_python_uv.sh first."
    fi
    echo "$python_cmd"
}

get_python_real_path() {
    local python_cmd
    python_cmd=$(get_python_cmd)
    readlink -f "$(which "$python_cmd")"
}

verify_python() {
    local python_cmd
    python_cmd=$(get_python_cmd)
    
    if ! "$python_cmd" --version >/dev/null 2>&1; then
        die "Python command $python_cmd is not working!"
    fi
    
    log_info "Python version: $("$python_cmd" --version)"
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
    local branch="${3:-main}"
    
    if [[ -d "$target_dir" ]]; then
        log_info "Updating existing repository: $(basename "$target_dir")"
        safe_cd "$target_dir"
        if ! git pull; then
            die "Failed to update repository"
        fi
    else
        log_info "Cloning repository: $(basename "$target_dir")"
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
    local python_path="$2"
    
    safe_cleanup "$venv_path"
    
    log_info "Creating virtual environment: $venv_path"
    if ! "$python_path" -m venv "$venv_path"; then
        die "Failed to create virtual environment"
    fi
    
    # Verify venv works
    if ! "$venv_path/bin/python" --version >/dev/null 2>&1; then
        die "Virtual environment Python is not working!"
    fi
}

install_pip_packages() {
    local venv_path="$1"
    shift
    local packages=("$@")
    
    log_info "Installing Python packages: ${packages[*]}"
    if ! "$venv_path/bin/python" -m pip install --upgrade pip "${packages[@]}"; then
        die "Failed to install Python packages"
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