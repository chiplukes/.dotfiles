[CmdletBinding()]
param()

Write-Log ""
Write-Log "====== Neovim Configuration Setup ======"
Write-Log ""

# Dot-source helpers
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$helpers = Join-Path $ScriptRoot 'helpers.ps1'
if (Test-Path $helpers) { . $helpers } else { Write-Log "helpers.ps1 not found at $helpers" -Level 'WARN' }

# Install NeoVim with WinGet, if not already present
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Neovim..."
    winget install Neovim.Neovim --accept-package-agreements --accept-source-agreements
} else {
    Write-Log "Neovim already installed" -Level 'INFO'
}

# Create .config directory if it doesn't exist (for cross-platform config)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\nvim" | Out-Null

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Set up symbolic link from Windows Neovim config location to dotfiles
$localConfiguration = "$env:LOCALAPPDATA\nvim"
$dotfilesConfiguration = "$env:USERPROFILE\.config\nvim"

# Remove existing config if it's not a symbolic link
if (Test-Path $localConfiguration -PathType Container) {
    $item = Get-Item $localConfiguration
    if ($item.LinkType -ne "SymbolicLink") {
        Write-Log "Removing existing Neovim config (not a symlink)..." -Level 'WARN'
        Remove-Item $localConfiguration -Recurse -Force
    } else {
        Write-Log "Neovim config symlink already exists" -Level 'WARN'
        # continue on to Python venv setup even if the symlink is present
    }
}

# Create the symbolic link (requires elevation)
if (Test-Path $dotfilesConfiguration) {
    Write-Log "Creating symbolic link for Neovim config..."
    if (New-Symlink-Elevated -Link $localConfiguration -Target $dotfilesConfiguration) {
        Write-Log "✓ Neovim config linked successfully"
    } else {
        Write-Log "Failed to create symbolic link: $localConfiguration -> $dotfilesConfiguration" -Level 'ERROR'
        Write-Log "Manual step required: Create symlink from $localConfiguration to $dotfilesConfiguration" -Level 'WARN'
    }
} else {
    Write-Log "Dotfiles Neovim config not found at: $dotfilesConfiguration" -Level 'WARN'
    Write-Log "Make sure you've run the dotfiles bootstrap script first"
}

# Create Python venv for Neovim using uv
# Load Python version from central config
$configFile = Join-Path (Split-Path -Parent $PSScriptRoot) 'python_config'
if (Test-Path $configFile) {
    $pythonVersion = (Get-Content $configFile | Where-Object { $_ -match '^PYTHON_VERSION=' } | ForEach-Object { ($_ -split '=')[1].Trim() })
    if (-not $pythonVersion) { $pythonVersion = "3.12" }
} else {
    $pythonVersion = "3.12"
}

# Check if uv is available
if (Get-Command uv -ErrorAction SilentlyContinue) {
    $nvimVenv = Join-Path $env:LOCALAPPDATA 'nvim\.venv'
    if (-not (Test-Path $nvimVenv)) {
        Write-Log "Creating Python venv for Neovim using uv (Python $pythonVersion) at $nvimVenv..."
        New-DirectoryIfMissing -Path (Split-Path -Parent $nvimVenv) | Out-Null
        uv venv --python $pythonVersion $nvimVenv

        # Install packages using uv pip\n        $venvPy = Join-Path $nvimVenv 'Scripts\\python.exe'\n        if (Test-Path $venvPy) {\n            uv pip install --python $venvPy pynvim neovim\n            Write-Log \"✓ Python provider configured (pynvim installed with uv)\"\n        } else {\n            Write-Log \"Failed to create venv python at: $venvPy\" -Level 'ERROR'\n        }\n    } else {\n        Write-Log \"Python venv already exists at $nvimVenv\" -Level 'WARN'\n    }\n} else {\n    Write-Log \"uv not found - please run install_python_uv.ps1 first\" -Level 'WARN'\n}

Write-Log ""
Write-Log "====== Neovim setup complete ======"
Write-Log ""