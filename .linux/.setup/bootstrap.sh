#!/bin/bash
set -euo pipefail

echo -e "\n====== Setting up bare dotfiles repository ======\n"

# Configuration
DOTFILES_REPO="${1:-https://github.com/chiplukes/.dotfiles.git}"
DOTFILES_DIR="$HOME/.cfg"
DOTFILES_BACKUP="$HOME/.config-backup"

# Create alias function for this session
dotfiles() {
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

echo "Cloning dotfiles as bare repository to $DOTFILES_DIR"
if [[ -d "$DOTFILES_DIR" ]]; then
    echo "Warning: $DOTFILES_DIR already exists. Removing..."
    rm -rf "$DOTFILES_DIR"
fi

# Clone the repository as bare
git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"

# Checkout files, backing up any conflicts
echo "Checking out dotfiles..."
if ! dotfiles checkout 2>/dev/null; then
    echo "Backing up pre-existing dot files to $DOTFILES_BACKUP"
    mkdir -p "$DOTFILES_BACKUP"

    # Get list of conflicting files and back them up
    dotfiles checkout 2>&1 | egrep "\s+\." | awk '{print $1}' | while IFS= read -r file; do
        echo "Backing up: $file"
        mkdir -p "$DOTFILES_BACKUP/$(dirname "$file")" 2>/dev/null || true
        mv "$HOME/$file" "$DOTFILES_BACKUP/$file" 2>/dev/null || true
    done

    # Try checkout again
    dotfiles checkout
fi

# Configure the repository
echo "Configuring dotfiles repository..."
dotfiles config --local status.showUntrackedFiles no
dotfiles config --local core.worktree "$HOME"

# Add dotfiles alias to shell profiles
ALIAS_LINE='alias dotfiles="git --git-dir=$HOME/.cfg --work-tree=$HOME"'

for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile"; do
    if [[ -f "$profile" ]] && ! grep -q "alias dotfiles=" "$profile"; then
        echo "Adding dotfiles alias to $profile"
        echo "" >> "$profile"
        echo "# Dotfiles management alias" >> "$profile"
        echo "$ALIAS_LINE" >> "$profile"
    fi
done

# Create .config/nvim directory if it doesn't exist (for cross-platform config)
mkdir -p "$HOME/.config/nvim"

echo -e "\n====== Dotfiles setup complete! ======\n"
echo "Usage:"
echo "  dotfiles status"
echo "  dotfiles add .config/nvim/init.lua"
echo "  dotfiles commit -m 'Update config'"
echo "  dotfiles push"
echo ""
echo "Platform-specific setup scripts available in:"
echo "  ~/.linux/setup/ (run as needed)"
echo ""
echo "Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
echo "Your original conflicting files (if any) are backed up in: $DOTFILES_BACKUP"