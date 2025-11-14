# Python/pip command interceptor for uv (PowerShell)
# Add this to your PowerShell profile ($PROFILE)

function Show-UVAlternative {
    param(
        [string]$Command,
        [string]$Arguments
    )

    Write-Host "[!] Consider using uv instead of $Command :" -ForegroundColor Yellow
    Write-Host ""

    switch ($Command) {
        "python" {
            Write-Host "# Instead of: python $Arguments" -ForegroundColor Green
            Write-Host "# Use uv to run Python:" -ForegroundColor Cyan
            Write-Host "uv run python $Arguments"
            Write-Host ""
            Write-Host "# Or create a project:" -ForegroundColor Cyan
            Write-Host "uv init my_project; cd my_project"
            Write-Host "uv add <package>  # Adds dependencies"
            Write-Host "uv run python script.py"
        }
        "pip" {
            if ($Arguments -match "^install") {
                Write-Host "# Instead of: pip $Arguments" -ForegroundColor Green
                Write-Host "# Use uv for faster installs:" -ForegroundColor Cyan
                $package = ($Arguments -replace "^install\s+", "")
                Write-Host "uv add $package"
                Write-Host "# or for global install:"
                Write-Host "uv tool install $package"
            } else {
                Write-Host "# Instead of: pip $Arguments" -ForegroundColor Green
                Write-Host "# Use uv pip:" -ForegroundColor Cyan
                Write-Host "uv pip $Arguments"
            }
        }
        "venv" {
            Write-Host "# Instead of: python -m venv $Arguments" -ForegroundColor Green
            Write-Host "# Use uv for faster venv creation:" -ForegroundColor Cyan
            Write-Host "uv venv $Arguments"
            Write-Host "# or create a project:"
            Write-Host "uv init my_project"
        }
    }

    Write-Host ""
    Write-Host "# Common uv commands:" -ForegroundColor Cyan
    Write-Host "uv init <project>     # Create new Python project"
    Write-Host "uv add <package>      # Add dependency to project"
    Write-Host "uv run <command>      # Run command in project environment"
    Write-Host "uv sync              # Install all dependencies"
    Write-Host "uv venv              # Create virtual environment"
    Write-Host "uv pip install <pkg> # Install package globally"
    Write-Host "uv tool install <pkg># Install CLI tool globally"
    Write-Host ""
    Write-Host "[i] To proceed with the original command anyway, use: & $Command $Arguments" -ForegroundColor Yellow
    Write-Host ""

    $response = Read-Host "Continue with original command? [y/N]"
    return ($response -match "^[Yy]")
}

# Store original commands
if (-not (Get-Command python-original -ErrorAction SilentlyContinue)) {
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCmd -and $pythonCmd.Source) {
        Set-Alias python-original $pythonCmd.Source -Force
    }
}

if (-not (Get-Command pip-original -ErrorAction SilentlyContinue)) {
    $pipCmd = Get-Command pip -ErrorAction SilentlyContinue
    if ($pipCmd -and $pipCmd.Source) {
        Set-Alias pip-original $pipCmd.Source -Force
    }
}

# Intercept python command
function python {
    if (Show-UVAlternative "python" ($args -join " ")) {
        & python-original @args
    }
}

# Intercept pip command
function pip {
    if (Show-UVAlternative "pip" ($args -join " ")) {
        & pip-original @args
    }
}

# Create venv function for python -m venv
function venv {
    if ($args.Count -eq 0) {
        $target = ".venv"
    } else {
        $target = $args -join " "
    }

    if (Show-UVAlternative "venv" $target) {
        & python-original -m venv @args
    }
}

# Create pyvenv alias
function pyvenv {
    if (Show-UVAlternative "venv" ($args -join " ")) {
        & python-original -m venv @args
    }
}

Write-Host "[OK] Python -> uv interceptor loaded" -ForegroundColor Green
Write-Host "  Use python-original, pip-original to bypass suggestions" -ForegroundColor Yellow