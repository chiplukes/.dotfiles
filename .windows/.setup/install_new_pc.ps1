[CmdletBinding()]
param(
    [switch]$SkipDebloat = $false,
    [switch]$SkipNeovim = $false,
    [switch]$SkipPython = $false,
    [switch]$WhatIf = $false
)

 $ErrorActionPreference = "Stop"
 $ScriptDir = $PSScriptRoot

# Dot-source shared helpers
 $helpers = Join-Path $ScriptDir 'helpers.ps1'
 if (Test-Path $helpers) { . $helpers } else { Write-Warning "helpers.ps1 not found at $helpers" }

 # Reuse Write-Section and Invoke-SetupScript from helpers

Write-Section "Windows New PC Setup"

if ($WhatIf) {
    Write-Warning "DRY RUN MODE - No changes will be made"
    Write-Output ""
}

Write-Output "Script Directory: $ScriptDir"
Write-Output "Admin Rights: $(if (Test-AdminRights) { 'Yes' } else { 'No (some features may require elevation)' })"
Write-Output "Options:"
Write-Output "  Skip Debloat: $SkipDebloat"
Write-Output "  Skip Neovim: $SkipNeovim"
Write-Output "  Skip Python: $SkipPython"
Write-Output ""

$success = $true

Write-Section "Step 1: Base Tools Installation"
$success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_base.ps1" -Description "Install winget and Chocolatey" -WhatIf:$WhatIf)

if (-not $success) {
    Write-Error "Base installation failed. Cannot continue."
    exit 1
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Section "Step 2: Application Installation"
$success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_apps.ps1" -Description "Install applications via winget/choco" -WhatIf:$WhatIf)

if (-not $SkipDebloat) {
    Write-Section "Step 3: Windows Debloat"
    $success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_debloat.ps1" -Description "Remove unwanted Windows apps and apply tweaks" -SkipIfMissing -WhatIf:$WhatIf)
} else {
    Write-Output ""
    Write-Warning "Skipping debloat (SkipDebloat specified)"
}

if (-not $SkipPython) {
    Write-Section "Step 4: Python Installation"
    $success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_python_uv.ps1" -Description "Install Python via uv" -SkipIfMissing -WhatIf:$WhatIf)
} else {
    Write-Output ""
    Write-Warning "Skipping Python installation (SkipPython specified)"
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (-not $SkipNeovim) {
    Write-Section "Step 5: Neovim Configuration"
    $success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\neovim_config.ps1" -Description "Install and configure Neovim" -SkipIfMissing -WhatIf:$WhatIf)
} else {
    Write-Output ""
    Write-Warning "Skipping Neovim setup (SkipNeovim specified)"
}

Write-Section "Setup Complete"

if ($success) {
    Write-Output "All setup steps completed successfully!"
    Write-Output ""
    Write-Output "Next steps:"
    Write-Output "1. Restart PowerShell to pick up PATH changes"
    Write-Output "2. Run bootstrap.ps1 to set up dotfiles management"
    Write-Output "3. Restart your computer if prompted by any installers"
    Write-Output ""
    Write-Output "Available tools:"
    Write-Output "  - winget (package management)"
    Write-Output "  - choco (package management)"
    if (-not $SkipPython) { Write-Output "  - python-user (user Python via uv)" }
    if (-not $SkipNeovim) { Write-Output "  - nvim (Neovim editor)" }
    Write-Output ""
    Write-Output "To update apps later, run: .\upgrade_apps.ps1"
} else {
    Write-Error "Some setup steps failed. Check the output above for details."
    exit 1
}

if (-not $WhatIf -and (Test-AdminRights)) {
    Write-Output ""
    $restart = Read-Host "Some changes may require a restart. Restart now? (y/N)"
    if ($restart -eq 'y' -or $restart -eq 'Y') {
        Write-Warning "Restarting computer..."
        Restart-Computer -Force
    }
}