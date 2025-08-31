[CmdletBinding()]
param(
    [string]$ConfigFile = "$PSScriptRoot\apps.json",
    [string]$LocalConfigFile = "$PSScriptRoot\apps.local.json",
    [string[]]$Categories = @(),  # Update specific categories only
    [switch]$IncludeOptional = $false,
    [switch]$WhatIf = $false
)

function Update-WingetApp {
    param($app, [switch]$WhatIf)  # ADD THIS LINE - was missing!

    if ($WhatIf) {
        Write-Host "Would update: $($app.name)" -ForegroundColor Cyan
        return
    }

    Write-Host "Updating: $($app.name)" -ForegroundColor Green
    if ($app.source) {
        winget upgrade --exact --silent $app.name --source $app.source --accept-package-agreements --accept-source-agreements
    } else {
        winget upgrade --exact --silent $app.name --accept-package-agreements --accept-source-agreements
    }
}

function Update-ChocoApp {
    param($app, [switch]$WhatIf)

    if ($WhatIf) {
        Write-Host "Would update: $($app.name)" -ForegroundColor Cyan
        return
    }

    Write-Host "Updating: $($app.name)" -ForegroundColor Green
    choco upgrade $app.name -y --no-progress
}

function Update-UV {
    param([switch]$WhatIf)

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Host "uv not found - skipping update" -ForegroundColor Yellow
        return
    }

    if ($WhatIf) {
        Write-Host "Would update: uv" -ForegroundColor Cyan
        return
    }

    Write-Host "Updating uv..." -ForegroundColor Green
    try {
        uv self update
        Write-Host "uv updated successfully" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to update uv: $($_.Exception.Message)"
        Write-Host "Trying manual update..." -ForegroundColor Yellow
        try {
            Invoke-Expression (Invoke-WebRequest -UseBasicParsing "https://astral.sh/uv/install.ps1").Content
            Write-Host "uv updated via reinstall" -ForegroundColor Green
        } catch {
            Write-Error "Failed to update uv: $($_.Exception.Message)"
        }
    }
}

function Merge-AppConfigs {
    param($BaseConfig, $LocalConfig)

    $merged = @{
        winget_apps = @()
        choco_apps = @()
        optional_apps = @()
    }

    # Start with base config
    if ($BaseConfig.winget_apps) { $merged.winget_apps += $BaseConfig.winget_apps }
    if ($BaseConfig.choco_apps) { $merged.choco_apps += $BaseConfig.choco_apps }
    if ($BaseConfig.optional_apps) { $merged.optional_apps += $BaseConfig.optional_apps }

    # Add local config if present
    if ($LocalConfig) {
        if ($LocalConfig.winget_apps) { $merged.winget_apps += $LocalConfig.winget_apps }
        if ($LocalConfig.choco_apps) { $merged.choco_apps += $LocalConfig.choco_apps }
        if ($LocalConfig.optional_apps) { $merged.optional_apps += $LocalConfig.optional_apps }
    }

    return $merged
}

Write-Host ""
Write-Host "====== Updating Applications ======"
Write-Host ""

# Load configuration
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Configuration file not found: $ConfigFile"
    exit 1
}

$config = Get-Content $ConfigFile | ConvertFrom-Json

# Load local configuration if it exists
$localConfig = $null
if (Test-Path $LocalConfigFile) {
    Write-Host "Loading local config: $LocalConfigFile" -ForegroundColor Cyan
    $localConfig = Get-Content $LocalConfigFile | ConvertFrom-Json
}

# Merge configurations
$config = Merge-AppConfigs -BaseConfig $config -LocalConfig $localConfig

if ($WhatIf) {
    Write-Host "DRY RUN - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

# Update uv first (tool dependency)
Write-Host "Updating uv..." -ForegroundColor Cyan
Update-UV -WhatIf:$WhatIf

# Update all winget apps
Write-Host ""
Write-Host "Updating all Winget apps..." -ForegroundColor Cyan
if (-not $WhatIf) {
    winget upgrade --all --accept-package-agreements --accept-source-agreements
}

# Update specific apps from our config
Write-Host ""
Write-Host "Updating configured Winget apps..." -ForegroundColor Cyan
$wingetApps = $config.winget_apps
if ($Categories.Count -gt 0) {
    $wingetApps = $wingetApps | Where-Object { $_.category -in $Categories }
}

foreach ($app in $wingetApps) {
    Update-WingetApp $app -WhatIf:$WhatIf
}

# Update optional apps if requested
if ($IncludeOptional) {
    Write-Host ""
    Write-Host "Updating Optional Apps..." -ForegroundColor Cyan
    $optionalWinget = $config.optional_apps | Where-Object { $_.manager -eq "winget" }
    if ($Categories.Count -gt 0) {
        $optionalWinget = $optionalWinget | Where-Object { $_.category -in $Categories }
    }

    foreach ($app in $optionalWinget) {
        Update-WingetApp $app -WhatIf:$WhatIf
    }
}

# Update Chocolatey apps
Write-Host ""
Write-Host "Updating Chocolatey apps..." -ForegroundColor Cyan
$chocoApps = $config.choco_apps
if ($Categories.Count -gt 0) {
    $chocoApps = $chocoApps | Where-Object { $_.category -in $Categories }
}

if (-not $WhatIf) {
    Write-Host "Updating all Chocolatey packages..." -ForegroundColor Cyan
    choco upgrade all -y --no-progress
}

Write-Host ""
Write-Host "====== Update Complete! ======" -ForegroundColor Green
Write-Host ""