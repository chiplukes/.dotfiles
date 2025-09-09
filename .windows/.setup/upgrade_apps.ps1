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
if (Test-Path $helpers) { . $helpers } else { Write-Warning "helpers.ps1 not found at $helpers" }

function Update-WingetApp {
    param($app, [switch]$WhatIf)  # ADD THIS LINE - was missing!

    if ($WhatIf) {
        Write-Output "Would update: $($app.name)"
        return
    }

    Write-Output "Updating: $($app.name)"
    if ($app.source) {
        winget upgrade --exact --silent $app.name --source $app.source --accept-package-agreements --accept-source-agreements
    } else {
        winget upgrade --exact --silent $app.name --accept-package-agreements --accept-source-agreements
    }
}

function Update-ChocoApp {
    param($app, [switch]$WhatIf)

    if ($WhatIf) {
        Write-Output "Would update: $($app.name)"
        return
    }

    Write-Output "Updating: $($app.name)"
    choco upgrade $app.name -y --no-progress
}

function Update-UV {
    param([switch]$WhatIf)

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Warning "uv not found - skipping update"
        return
    }

    if ($WhatIf) {
        Write-Output "Would update: uv"
        return
    }

    Write-Output "Updating uv..."
    try {
        uv self update
    Write-Output "uv updated successfully"
    } catch {
        Write-Warning "Failed to update uv: $($_.Exception.Message)"
    Write-Warning "Trying manual update..."
        try {
            Invoke-Expression (Invoke-WebRequest -UseBasicParsing "https://astral.sh/uv/install.ps1").Content
            Write-Output "uv updated via reinstall"
        } catch {
            Write-Error "Failed to update uv: $($_.Exception.Message)"
        }
    }
}

function Merge-AppConfigs { param($BaseConfig, $LocalConfig) return Merge-AppConfigsGeneric -Base $BaseConfig -Local $LocalConfig }

Write-Output ""
Write-Output "====== Updating Applications ======"
Write-Output ""

# Load configuration using helpers
if (-not (Test-Path $ConfigFile)) { Write-Error "Configuration file not found: $ConfigFile"; exit 1 }
try { $config = Import-JsonConfig -Path $ConfigFile -AllowLeadingLineCommentsOnly } catch { Write-Error $_.Exception.Message; exit 1 }

$localConfig = $null
if (Test-Path $LocalConfigFile) { Write-Output "Loading local config: $LocalConfigFile"; try { $localConfig = Import-JsonConfig -Path $LocalConfigFile -AllowLeadingLineCommentsOnly } catch { Write-Warning "Failed to parse local config: $LocalConfigFile" } }

# Merge configurations
$config = Merge-AppConfigsGeneric -Base $config -Local $localConfig

if ($WhatIf) {
    Write-Warning "DRY RUN - No changes will be made"
    Write-Output ""
}

# Update uv first (tool dependency)
Write-Output "Updating uv..."
Update-UV -WhatIf:$WhatIf

# Update all winget apps
Write-Output ""
Write-Output "Updating all Winget apps..."
if (-not $WhatIf) {
    winget upgrade --all --accept-package-agreements --accept-source-agreements
}

# Update specific apps from our config
Write-Output ""
Write-Output "Updating configured Winget apps..."
$wingetApps = $config.winget_apps
if ($Categories.Count -gt 0) {
    $wingetApps = $wingetApps | Where-Object { $_.category -in $Categories }
}

foreach ($app in $wingetApps) {
    Update-WingetApp $app -WhatIf:$WhatIf
}

# Update optional apps if requested
if ($IncludeOptional) {
    Write-Output ""
    Write-Output "Updating Optional Apps..."
    $optionalWinget = $config.optional_apps | Where-Object { $_.manager -eq "winget" }
    if ($Categories.Count -gt 0) {
        $optionalWinget = $optionalWinget | Where-Object { $_.category -in $Categories }
    }

    foreach ($app in $optionalWinget) {
        Update-WingetApp $app -WhatIf:$WhatIf
    }
}

# Update Chocolatey apps
Write-Output ""
Write-Output "Updating Chocolatey apps..."
$chocoApps = $config.choco_apps
if ($Categories.Count -gt 0) {
    $chocoApps = $chocoApps | Where-Object { $_.category -in $Categories }
}

if (-not $WhatIf) {
    Write-Output "Updating all Chocolatey packages..."
    choco upgrade all -y --no-progress
}

Write-Output ""
Write-Output "====== Update Complete! ======"
Write-Output ""