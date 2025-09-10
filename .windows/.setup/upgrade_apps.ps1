[CmdletBinding()]
param(
    [string]$ConfigFile = "$PSScriptRoot\apps.json",
    [string]$LocalConfigFile = "$PSScriptRoot\apps.local.json",
    [string[]]$Categories = @(),  # Update specific categories only
    [switch]$IncludeOptional = $false,
    [switch]$WhatIf = $false
)

# Dot-source helpers
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$helpers = Join-Path $ScriptRoot 'helpers.ps1'
if (Test-Path $helpers) { . $helpers } else { Write-Log "helpers.ps1 not found at $helpers" -Level 'WARN' }

function Update-WingetApp {
    param($app, [switch]$WhatIf)  # ADD THIS LINE - was missing!

    if ($WhatIf) {
        Write-Log "Would update: $($app.name)"
        return
    }

    Write-Log "Updating: $($app.name)"
    if ($app.source) {
        winget upgrade --exact --silent $app.name --source $app.source --accept-package-agreements --accept-source-agreements
    } else {
        winget upgrade --exact --silent $app.name --accept-package-agreements --accept-source-agreements
    }
}

function Update-ChocoApp {
    param($app, [switch]$WhatIf)

    if ($WhatIf) {
        Write-Log "Would update: $($app.name)"
        return
    }

    Write-Log "Updating: $($app.name)"
    choco upgrade $app.name -y --no-progress
}

function Update-UV {
    param([switch]$WhatIf)

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Log "uv not found - skipping update" -Level 'WARN'
        return
    }

    if ($WhatIf) {
        Write-Log "Would update: uv"
        return
    }

    Write-Log "Updating uv..."
    try {
        uv self update
        Write-Log "uv updated successfully"
    } catch {
        Write-Log "Failed to update uv: $($_.Exception.Message)" -Level 'WARN'
        Write-Log "Trying manual update..." -Level 'WARN'
        try {
            Invoke-Expression (Invoke-WebRequest -UseBasicParsing "https://astral.sh/uv/install.ps1").Content
            Write-Log "uv updated via reinstall"
        } catch {
            Write-Log "Failed to update uv: $($_.Exception.Message)" -Level 'ERROR'
        }
    }
}

function Merge-AppConfigs { param($BaseConfig, $LocalConfig) return Merge-AppConfigsGeneric -Base $BaseConfig -Local $LocalConfig }

Write-Log ""
Write-Log "====== Updating Applications ======"
Write-Log ""

# Load configuration using helpers
if (-not (Test-Path $ConfigFile)) { Write-Log "Configuration file not found: $ConfigFile" -Level 'ERROR'; exit 1 }
try { $config = Import-JsonConfig -Path $ConfigFile -AllowLeadingLineCommentsOnly } catch { Write-Log $_.Exception.Message -Level 'ERROR'; exit 1 }

$localConfig = $null
if (Test-Path $LocalConfigFile) { Write-Log "Loading local config: $LocalConfigFile"; try { $localConfig = Import-JsonConfig -Path $LocalConfigFile -AllowLeadingLineCommentsOnly } catch { Write-Log "Failed to parse local config: $LocalConfigFile" -Level 'WARN' } }

# Merge configurations
$config = Merge-AppConfigsGeneric -Base $config -Local $localConfig

if ($WhatIf) {
    Write-Log "DRY RUN - No changes will be made" -Level 'WARN'
    Write-Log ""
}

# Update uv first (tool dependency)
Write-Log "Updating uv..."
Update-UV -WhatIf:$WhatIf

# Update all winget apps
Write-Log ""
Write-Log "Updating all Winget apps..."
if (-not $WhatIf) {
    winget upgrade --all --accept-package-agreements --accept-source-agreements
}

# Update specific apps from our config
Write-Log ""
Write-Log "Updating configured Winget apps..."
$wingetApps = $config.winget_apps
if ($Categories.Count -gt 0) {
    $wingetApps = $wingetApps | Where-Object { $_.category -in $Categories }
}

foreach ($app in $wingetApps) {
    Update-WingetApp $app -WhatIf:$WhatIf
}

# Update optional apps if requested
if ($IncludeOptional) {
    Write-Log ""
    Write-Log "Updating Optional Apps..."
    $optionalWinget = $config.optional_apps | Where-Object { $_.manager -eq "winget" }
    if ($Categories.Count -gt 0) {
        $optionalWinget = $optionalWinget | Where-Object { $_.category -in $Categories }
    }

    foreach ($app in $optionalWinget) {
        Update-WingetApp $app -WhatIf:$WhatIf
    }
}

# Update Chocolatey apps
Write-Log ""
Write-Log "Updating Chocolatey apps..."
$chocoApps = $config.choco_apps
if ($Categories.Count -gt 0) {
    $chocoApps = $chocoApps | Where-Object { $_.category -in $Categories }
}

if (-not $WhatIf) {
    Write-Log "Updating all Chocolatey packages..."
    choco upgrade all -y --no-progress
}

Write-Log ""
Write-Log "====== Update Complete! ======"
Write-Log ""