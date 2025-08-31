[CmdletBinding()]
param()

Write-Host "`n====== Neovim Configuration Setup ======`n"

# Install NeoVim with WinGet, if not already present
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Neovim..." -ForegroundColor Green
    winget install Neovim.Neovim --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Neovim already installed" -ForegroundColor Yellow
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
        Write-Host "Removing existing Neovim config (not a symlink)..." -ForegroundColor Yellow
        Remove-Item $localConfiguration -Recurse -Force
    } else {
        Write-Host "Neovim config symlink already exists" -ForegroundColor Yellow
        return
    }
}

# Create the symbolic link (requires elevation)
if (Test-Path $dotfilesConfiguration) {
    Write-Host "Creating symbolic link for Neovim config..." -ForegroundColor Green
    try {
        # Try without elevation first
        New-Item -Path $localConfiguration -ItemType SymbolicLink -Value $dotfilesConfiguration -Force
        Write-Host "✓ Neovim config linked successfully" -ForegroundColor Green
    } catch {
        Write-Host "Elevation required for symbolic link creation..." -ForegroundColor Yellow
        try {
            Start-Process -FilePath "powershell" -ArgumentList "-Command", "New-Item -Path '$localConfiguration' -ItemType SymbolicLink -Value '$dotfilesConfiguration' -Force" -Verb RunAs -Wait
            Write-Host "✓ Neovim config linked successfully (elevated)" -ForegroundColor Green
        } catch {
            Write-Error "Failed to create symbolic link: $($_.Exception.Message)"
            Write-Host "Manual step required: Create symlink from $localConfiguration to $dotfilesConfiguration"
        }
    }
} else {
    Write-Warning "Dotfiles Neovim config not found at: $dotfilesConfiguration"
    Write-Host "Make sure you've run the dotfiles bootstrap script first"
}

# Create Python venv for Neovim if Python is available
if (Get-Command python -ErrorAction SilentlyContinue) {
    $nvimVenv = "$env:LOCALAPPDATA\nvim\.venv"
    if (-not (Test-Path $nvimVenv)) {
        Write-Host "Creating Python venv for Neovim..." -ForegroundColor Green
        python -m venv $nvimVenv
        & "$nvimVenv\Scripts\pip.exe" install --upgrade pip pynvim
        Write-Host "✓ Python provider configured" -ForegroundColor Green
    } else {
        Write-Host "Python venv already exists" -ForegroundColor Yellow
    }
} else {
    Write-Host "Python not found - skipping Python provider setup" -ForegroundColor Yellow
}

Write-Host "`n====== Neovim setup complete ======`n" -ForegroundColor Green