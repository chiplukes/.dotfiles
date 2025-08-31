#!/bin/bash
set -euo pipefail

echo -e "\n====== Work PC Setup ======\n"

# Get script directory
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Source installation scripts
scripts=(
    "install_base.sh"
    "install_python_uv.sh"
    "install_neovim.sh"
    "install_hdl_tools.sh"
)

for script in "${scripts[@]}"; do
    script_path="$SCRIPT_DIR/$script"
    if [[ -f "$script_path" ]]; then
        echo "Running $script..."
        if ! bash "$script_path"; then
            echo "Warning: $script failed" >&2
        fi
    else
        echo "Warning: Script not found: $script_path" >&2
    fi
done

# Install summary
echo -e "\n====== Installation Summary ======\n"
if [[ -f "$HOME/install_progress_log.txt" ]]; then
    cat "$HOME/install_progress_log.txt"
    rm "$HOME/install_progress_log.txt"
else
    echo "No installation log found"
fi

echo -e "\n====== Setup Complete! ======"
echo "Please restart your shell to pick up all changes"
