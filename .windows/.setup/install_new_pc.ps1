[CmdletBinding()]
param(
    [switch]$SkipDebloat = $false,
    [switch]$SkipNeovim = $false,
    [switch]$SkipPython = $false,
    [switch]$WhatIf = $false
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host " $Title " -ForegroundColor Yellow
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-SetupScript {
    param(
        [string]$ScriptPath,
        [string]$Description,
        [hashtable]$Arguments = @{},
        [switch]$SkipIfMissing = $false
    )

    if (-not (Test-Path $ScriptPath)) {
        if ($SkipIfMissing) {
            Write-Warning "Script not found: $ScriptPath (skipping)"
            return $true
        } else {
            Write-Error "Required script not found: $ScriptPath"
            return $false
        }
    }

    Write-Host "Running: $Description" -ForegroundColor Green
    Write-Host "Script: $ScriptPath" -ForegroundColor Gray

    if ($WhatIf) {
        Write-Host "WOULD RUN: $ScriptPath" -ForegroundColor Yellow
        return $true
    }

    try {
        if ($Arguments.Count -gt 0) {
            & $ScriptPath @Arguments
        } else {
            & $ScriptPath
        }
        Write-Host "Completed: $Description" -ForegroundColor Green
        return $true
    } catch {
        Write-Error "Failed: $Description - $($_.Exception.Message)"
        return $false
    }
}

function Test-AdminRights {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-Section "Windows New PC Setup"

if ($WhatIf) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Script Directory: $ScriptDir"
Write-Host "Admin Rights: $(if (Test-AdminRights) { 'Yes' } else { 'No (some features may require elevation)' })"
Write-Host "Options:"
Write-Host "  Skip Debloat: $SkipDebloat"
Write-Host "  Skip Neovim: $SkipNeovim"
Write-Host "  Skip Python: $SkipPython"
Write-Host ""

$success = $true

Write-Section "Step 1: Base Tools Installation"
$success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_base.ps1" -Description "Install winget and Chocolatey")

if (-not $success) {
    Write-Error "Base installation failed. Cannot continue."
    exit 1
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Section "Step 2: Application Installation"
$success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_apps.ps1" -Description "Install applications via winget/choco")

if (-not $SkipDebloat) {
    Write-Section "Step 3: Windows Debloat"
    $success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_debloat.ps1" -Description "Remove unwanted Windows apps and apply tweaks" -SkipIfMissing)
} else {
    Write-Host ""
    Write-Host "Skipping debloat (SkipDebloat specified)" -ForegroundColor Yellow
}

if (-not $SkipPython) {
    Write-Section "Step 4: Python Installation"
    $success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_python_uv.ps1" -Description "Install Python via uv" -SkipIfMissing)
} else {
    Write-Host ""
    Write-Host "Skipping Python installation (SkipPython specified)" -ForegroundColor Yellow
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (-not $SkipNeovim) {
    Write-Section "Step 5: Neovim Configuration"
    $success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\neovim_config.ps1" -Description "Install and configure Neovim" -SkipIfMissing)
} else {
    Write-Host ""
    Write-Host "Skipping Neovim setup (SkipNeovim specified)" -ForegroundColor Yellow
}

Write-Section "Setup Complete"

if ($success) {
    Write-Host "All setup steps completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Restart PowerShell to pick up PATH changes"
    Write-Host "2. Run bootstrap.ps1 to set up dotfiles management"
    Write-Host "3. Restart your computer if prompted by any installers"
    Write-Host ""
    Write-Host "Available tools:" -ForegroundColor Cyan
    Write-Host "  - winget (package management)"
    Write-Host "  - choco (package management)"
    if (-not $SkipPython) { Write-Host "  - python-user (user Python via uv)" }
    if (-not $SkipNeovim) { Write-Host "  - nvim (Neovim editor)" }
    Write-Host ""
    Write-Host "To update apps later, run: .\upgrade_apps.ps1" -ForegroundColor Cyan
} else {
    Write-Host "Some setup steps failed. Check the output above for details." -ForegroundColor Red
    exit 1
}

if (-not $WhatIf -and (Test-AdminRights)) {
    Write-Host ""
    $restart = Read-Host "Some changes may require a restart. Restart now? (y/N)"
    if ($restart -eq 'y' -or $restart -eq 'Y') {
        Write-Host "Restarting computer..." -ForegroundColor Yellow
        Restart-Computer -Force
    }
}