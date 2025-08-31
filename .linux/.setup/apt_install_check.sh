#!/bin/bash
# apt install then check if install worked
# $1 app to install

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <package_name>" >&2
    exit 1
fi

package="$1"

echo "Installing $package..."
if sudo apt-get install -y "$package"; then
    if command -v "$package" >/dev/null; then
        echo "$package Installed" >> "$HOME/install_progress_log.txt"
        echo "✓ $package installed successfully"
    else
        echo "$package FAILED TO INSTALL!!!" >> "$HOME/install_progress_log.txt"
        echo "✗ $package installation verification failed"
    fi
else
    echo "$package FAILED TO INSTALL!!!" >> "$HOME/install_progress_log.txt"
    echo "✗ $package installation failed"
fi

