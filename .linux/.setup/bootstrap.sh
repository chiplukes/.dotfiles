#!/bin/bash
set -euo pipefail

# Parse command line arguments
BRANCH="main"
REPO_URL="https://github.com/chiplukes/.dotfiles.git"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -r|--repo)
            REPO_URL="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -b, --branch BRANCH    Git branch to clone (default: main)"
            echo "  -r, --repo URL         Repository URL (default: https://github.com/chiplukes/.dotfiles.git)"
            echo "  -h, --help             Show this help message"
            exit 0
            ;;
        *)
            # Support old positional argument for backward compatibility
            REPO_URL="$1"
            shift
            ;;
    esac
done

echo -e "\n====== Setting up bare dotfiles repository ======\n"

# Configuration
DOTFILES_REPO="${REPO_URL}"
DOTFILES_DIR="$HOME/.dotfiles-bare"
DOTFILES_BACKUP="$HOME/.config-backup"

# Create alias function for this session
dotfiles() {
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

echo "Using branch: $BRANCH"
echo "Cloning dotfiles as bare repository to $DOTFILES_DIR"

if [[ -d "$DOTFILES_DIR" ]]; then
    echo "Warning: $DOTFILES_DIR already exists. Removing..."
    rm -rf "$DOTFILES_DIR"
fi

# Clone the repository as bare with specific branch
git clone --bare -b "$BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"

# Checkout files, backing up any conflicts
echo "Checking out dotfiles..."
if ! dotfiles checkout 2>/dev/null; then
    echo "Backing up pre-existing files to $DOTFILES_BACKUP"
    mkdir -p "$DOTFILES_BACKUP"

    # Get ALL conflicting files from git's error output
    # Git outputs different formats:
    # "        .bashrc" (with leading whitespace)
    # "README.md" (without leading whitespace)
    readarray -t conflicting_files < <(
        dotfiles checkout 2>&1 | \
        sed -n '/would be overwritten by checkout:/,/Aborting/p' | \
        grep -v -E "(would be overwritten|Please move|Aborting)" | \
        sed 's/^[[:space:]]*//' | \
        grep -v '^$'
    )

    for file in "${conflicting_files[@]}"; do
        if [[ -n "$file" && -e "$HOME/$file" ]]; then
            echo "Backing up: $file"
            backup_path="$DOTFILES_BACKUP/$file"
            backup_dir=$(dirname "$backup_path")
            mkdir -p "$backup_dir"
            mv "$HOME/$file" "$backup_path"
        fi
    done

    # Try checkout again
    echo "Retrying checkout after backing up conflicts..."
    if ! dotfiles checkout; then
        echo "Error: Checkout still failed after backing up conflicts" >&2
        echo "Trying to force checkout..."
        if ! dotfiles checkout -f; then
            echo "Force checkout also failed!" >&2
            exit 1
        fi
    fi
fi

# Configure the repository
echo "Configuring dotfiles repository..."
dotfiles config --local status.showUntrackedFiles no
dotfiles config --local core.worktree "$HOME"

# Add dotfiles alias to shell profiles
ALIAS_LINE='alias dotfiles="git --git-dir=$HOME/.dotfiles-bare --work-tree=$HOME"'

for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile"; do
    if [[ -f "$profile" ]] && ! grep -q "alias dotfiles=" "$profile"; then
        echo "Adding dotfiles alias to $profile"
        echo "" >> "$profile"
        echo "# Dotfiles management alias" >> "$profile"
        echo "$ALIAS_LINE" >> "$profile"
    elif [[ ! -f "$profile" ]] && [[ "$profile" == "$HOME/.bashrc" ]]; then
        # Create .bashrc if it doesn't exist (common on minimal systems)
        echo "Creating .bashrc with dotfiles alias"
        echo "# Dotfiles management alias" > "$profile"
        echo "$ALIAS_LINE" >> "$profile"
    fi
done

# Create .config/nvim directory if it doesn't exist (for cross-platform config)
mkdir -p "$HOME/.config/nvim"

echo -e "\n====== Dotfiles setup complete! ======\n"
echo "Branch used: $BRANCH"
echo ""
echo "Usage:"
echo "  dotfiles status"
echo "  dotfiles add .config/nvim/init.lua"
echo "  dotfiles commit -m 'Update config'"
echo "  dotfiles push"
echo ""
echo "Platform-specific setup scripts available in:"
echo "  ~/.linux/.setup/ (run as needed)"
echo ""
echo "Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
if [[ -d "$DOTFILES_BACKUP" ]]; then
    echo "Your original conflicting files are backed up in: $DOTFILES_BACKUP"
fi

# Verify checkout worked
echo ""
echo "Verifying checkout..."
if dotfiles status >/dev/null 2>&1; then
    echo "✓ Dotfiles checkout successful!"
    echo "Files in your home directory:"
    dotfiles ls-tree --name-only HEAD | head -10
    if [[ $(dotfiles ls-tree --name-only HEAD | wc -l) -gt 10 ]]; then
        echo "... and $(($(dotfiles ls-tree --name-only HEAD | wc -l) - 10)) more files"
    fi
else
    echo "✗ Dotfiles checkout verification failed!"
    exit 1
fi