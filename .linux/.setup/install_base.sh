#!/bin/bash
set -euo pipefail

echo -e "\n====== Base Utils for all installs ======\n"

# Get Ubuntu version
ubuntu_version=$(grep -oP 'VERSION_ID="\K[\d.]+' /etc/os-release 2>/dev/null || echo "unknown")
echo "Found Ubuntu version: $ubuntu_version"

# Fix deb-src URIs based on version
case "$ubuntu_version" in
    "22.04")
        echo "Fixing 22.04 deb-src URIs"
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
        sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
        ;;
    "24.04")
        echo "Fixing 24.04 deb-src URIs"
        sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.backup
        sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
        ;;
    *)
        echo "No URI fix needed for version: $ubuntu_version"
        ;;
esac

# Update and upgrade
echo "Updating package lists..."
if ! sudo apt-get update; then
    echo "Failed to update package list" >&2
    exit 1
fi

echo "Upgrading packages..."
if ! sudo apt-get upgrade -y; then
    echo "Warning: Some packages failed to upgrade" >&2
fi

# Install base packages using helper script
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
packages=(git curl subversion ripgrep)

for package in "${packages[@]}"; do
    if [[ -f "$SCRIPT_DIR/apt_install_check.sh" ]]; then
        bash "$SCRIPT_DIR/apt_install_check.sh" "$package"
    else
        echo "Installing $package..."
        if ! sudo apt-get install -y "$package"; then
            echo "$package FAILED TO INSTALL!!!" >> "$HOME/install_progress_log.txt"
        else
            echo "$package Installed" >> "$HOME/install_progress_log.txt"
        fi
    fi
done

# Install fzf
echo "Installing fzf..."
FZF_DIR="$HOME/.fzf"
if [[ -d "$FZF_DIR" ]]; then
    echo "Updating existing fzf installation..."
    cd "$FZF_DIR" || exit 1
    git pull
else
    echo "Cloning fzf repository..."
    if ! git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"; then
        echo "Failed to clone fzf repository" >&2
        exit 1
    fi
fi

# Install fzf (automatically answers yes to prompts)
if ! "$FZF_DIR/install" --all; then
    echo "Warning: fzf installation had issues" >&2
fi

echo "✓ Base installation complete!"
echo "Note: Restart your shell to pick up fzf and other changes"
