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
 if (Test-Path $helpers) { . $helpers } else { Write-Log "helpers.ps1 not found at $helpers" -Level 'WARN' }


Write-Log "Windows New PC Setup" -Section

if ($WhatIf) {
    Write-Log "DRY RUN MODE - No changes will be made" -Level 'WARN'
    Write-Log ""
}

Write-Log "Script Directory: $ScriptDir"
Write-Log "Admin Rights: $(if (Test-AdminRights) { 'Yes' } else { 'No (some features may require elevation)' })"
Write-Log "Options:"
Write-Log "  Skip Debloat: $SkipDebloat"
Write-Log "  Skip Neovim: $SkipNeovim"
Write-Log "  Skip Python: $SkipPython"
Write-Log ""

$success = $true

Write-Log "Step 1: Base Tools Installation" -Section
$success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_base.ps1" -Description "Install winget and Chocolatey" -WhatIf:$WhatIf)

if (-not $success) {
    Write-Log "Base installation failed. Cannot continue." -Level 'ERROR'
    exit 1
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Log "Step 2: Application Installation" -Section
$success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_apps.ps1" -Description "Install applications via winget/choco" -WhatIf:$WhatIf)

if (-not $SkipDebloat) {
    Write-Log "Step 3: Windows Debloat" -Section
    $success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_debloat.ps1" -Description "Remove unwanted Windows apps and apply tweaks" -SkipIfMissing -WhatIf:$WhatIf)
} else {
    Write-Log ""
    Write-Log "Skipping debloat (SkipDebloat specified)" -Level 'WARN'
}

if (-not $SkipPython) {
    Write-Log "Step 4: Python Installation" -Section
    $success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\install_python_uv.ps1" -Description "Install Python via uv" -SkipIfMissing -WhatIf:$WhatIf)
} else {
    Write-Log ""
    Write-Log "Skipping Python installation (SkipPython specified)" -Level 'WARN'
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (-not $SkipNeovim) {
    Write-Log "Step 5: Neovim Configuration" -Section
    $success = $success -and (Invoke-SetupScript -ScriptPath "$ScriptDir\neovim_config.ps1" -Description "Install and configure Neovim" -SkipIfMissing -WhatIf:$WhatIf)
} else {
    Write-Log ""
    Write-Log "Skipping Neovim setup (SkipNeovim specified)" -Level 'WARN'
}

Write-Log "Setup Complete" -Section

if ($success) {
    Write-Log "All setup steps completed successfully!"
    Write-Log ""
    Write-Log "Next steps:"
    Write-Log "1. Restart PowerShell to pick up PATH changes"
    Write-Log "2. Run bootstrap.ps1 to set up dotfiles management"
    Write-Log "3. Restart your computer if prompted by any installers"
    Write-Log ""
    Write-Log "Available tools:"
    Write-Log "  - winget (package management)"
    Write-Log "  - choco (package management)"
    if (-not $SkipPython) { Write-Log "  - python-user (user Python via uv)" }
    if (-not $SkipNeovim) { Write-Log "  - nvim (Neovim editor)" }
    Write-Log ""
    Write-Log "To update apps later, run: .\upgrade_apps.ps1"
} else {
    Write-Log "Some setup steps failed. Check the output above for details." -Level 'ERROR'
    exit 1
}

if (-not $WhatIf -and (Test-AdminRights)) {
    Write-Log ""
    $restart = Read-Host "Some changes may require a restart. Restart now? (y/N)"
    if ($restart -eq 'y' -or $restart -eq 'Y') {
        Write-Log "Restarting computer..."
        Restart-Computer -Force
    }
}