# Python/pip command interceptor for uv
# Add this to your ~/.bashrc or ~/.bash_profile

# Function to suggest uv alternatives
suggest_uv() {
    local cmd="$1"
    local args="$2"

    echo -e "\033[1;33m⚠️  Consider using uv instead of $cmd:\033[0m"
    echo ""

    case "$cmd" in
        "python")
            echo -e "\033[1;32m# Instead of: python $args\033[0m"
            echo -e "\033[1;36m# Use uv to run Python:\033[0m"
            echo "uv run python $args"
            echo ""
            echo -e "\033[1;36m# Or create a project:\033[0m"
            echo "uv init my_project && cd my_project"
            echo "uv add <package>  # Adds dependencies"
            echo "uv run python script.py"
            ;;
        "pip")
            case "$args" in
                install*)
                    echo -e "\033[1;32m# Instead of: pip $args\033[0m"
                    echo -e "\033[1;36m# Use uv for faster installs:\033[0m"
                    echo "uv add ${args#install }"
                    echo "# or for global install:"
                    echo "uv tool install ${args#install }"
                    ;;
                *)
                    echo -e "\033[1;32m# Instead of: pip $args\033[0m"
                    echo -e "\033[1;36m# Use uv pip:\033[0m"
                    echo "uv pip $args"
                    ;;
            esac
            ;;
        "venv")
            echo -e "\033[1;32m# Instead of: python -m venv $args\033[0m"
            echo -e "\033[1;36m# Use uv for faster venv creation:\033[0m"
            echo "uv venv $args"
            echo "# or create a project:"
            echo "uv init my_project"
            ;;
    esac

    echo ""
    echo -e "\033[1;36m# Common uv commands:\033[0m"
    echo "uv init <project>     # Create new Python project"
    echo "uv add <package>      # Add dependency to project"
    echo "uv run <command>      # Run command in project environment"
    echo "uv sync              # Install all dependencies"
    echo "uv venv              # Create virtual environment"
    echo "uv pip install <pkg> # Install package globally"
    echo "uv tool install <pkg># Install CLI tool globally"
    echo ""
    echo -e "\033[1;33m💡 To proceed with the original command anyway, use: \\$cmd $args\033[0m"
    echo ""

    read -p "Continue with original command? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0  # Continue with original command
    else
        return 1  # Cancel original command
    fi
}

# Intercept python command
python() {
    if suggest_uv "python" "$*"; then
        command python "$@"
    fi
}

# Intercept pip command
pip() {
    if suggest_uv "pip" "$*"; then
        command pip "$@"
    fi
}

# Intercept python -m venv
# This is trickier since it's a python subcommand, but we can create a venv function
venv() {
    if [[ $# -eq 0 ]]; then
        if suggest_uv "venv" ".venv"; then
            command python -m venv .venv
        fi
    else
        if suggest_uv "venv" "$*"; then
            command python -m venv "$@"
        fi
    fi
}

# Override pyvenv function to show uv suggestion
pyvenv() {
    if suggest_uv "venv" "$*"; then
        command python -m venv "$@"
    fi
}

echo -e "\033[1;32m✓ Python → uv interceptor loaded\033[0m"
echo -e "\033[1;33m  Use \\python, \\pip, or \\pyvenv to bypass suggestions\033[0m"