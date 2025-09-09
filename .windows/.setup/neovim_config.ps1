[CmdletBinding()]
param()

Write-Output ""
Write-Output "====== Neovim Configuration Setup ======"
Write-Output ""

# Dot-source helpers
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$helpers = Join-Path $ScriptRoot 'helpers.ps1'
if (Test-Path $helpers) { . $helpers } else { Write-Warning "helpers.ps1 not found at $helpers" }

# Install NeoVim with WinGet, if not already present
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Neovim..."
    winget install Neovim.Neovim --accept-package-agreements --accept-source-agreements
} else {
    Write-Verbose "Neovim already installed"
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Set up symbolic link from Windows Neovim config location to dotfiles
$localConfiguration = "$env:LOCALAPPDATA\nvim"
$dotfilesConfiguration = "$env:USERPROFILE\.config\nvim"

# Remove existing config if it's not a symbolic link
if (Test-Path $localConfiguration -PathType Container) {
    $item = Get-Item $localConfiguration
    if ($item.LinkType -ne "SymbolicLink") {
    Write-Warning "Removing existing Neovim config (not a symlink)..."
        Remove-Item $localConfiguration -Recurse -Force
    } else {
    Write-Verbose "Neovim config symlink already exists"
        # continue on to Python venv setup even if the symlink is present
    }
}

# Create the symbolic link (requires elevation)
if (Test-Path $dotfilesConfiguration) {
    Write-Output "Creating symbolic link for Neovim config..."
    if (New-Symlink-Elevated -Link $localConfiguration -Target $dotfilesConfiguration) {
        Write-Output "✓ Neovim config linked successfully"
    } else {
        Write-Error "Failed to create symbolic link: $localConfiguration -> $dotfilesConfiguration"
        Write-Warning "Manual step required: Create symlink from $localConfiguration to $dotfilesConfiguration"
    }
} else {
    Write-Warning "Dotfiles Neovim config not found at: $dotfilesConfiguration"
    Write-Host "Make sure you've run the dotfiles bootstrap script first"
}

# Create Python venv for Neovim if Python is available
# Detect python executable: prefer `python`, fallback to `py -3` launcher
$pythonCmdInfo = Get-Command python -ErrorAction SilentlyContinue
$pyLauncherInfo = Get-Command py -ErrorAction SilentlyContinue

if ($pythonCmdInfo -or $pyLauncherInfo) {
    if ($pythonCmdInfo) {
        $pythonExe = $pythonCmdInfo.Source
        $pythonArgs = @()
    } else {
        # Use the py launcher with -3 to prefer Python 3
        $pythonExe = $pyLauncherInfo.Source
        $pythonArgs = @('-3')
    }

    $nvimVenv = Join-Path $env:LOCALAPPDATA 'nvim\.venv'
    if (-not (Test-Path $nvimVenv)) {
        Write-Output "Creating Python venv for Neovim at $nvimVenv..."
        New-DirectoryIfMissing -Path $nvimVenv | Out-Null
        & $pythonExe @pythonArgs -m venv $nvimVenv

        # Use the venv python to run pip (more reliable than calling pip.exe directly)
        $venvPy = Join-Path $nvimVenv 'Scripts\python.exe'
        if (Test-Path $venvPy) {
            & $venvPy -m pip install --upgrade pip pynvim neovim
            Write-Output "✓ Python provider configured (pynvim installed)"
        } else {
            Write-Error "Failed to create venv python at: $venvPy"
        }
    } else {
    Write-Verbose "Python venv already exists at $nvimVenv"
    }
} else {
    Write-Warning "Python not found - skipping Python provider setup"
}

Write-Output ""
Write-Output "====== Neovim setup complete ======"
Write-Output ""