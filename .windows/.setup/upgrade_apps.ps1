[CmdletBinding()]
param(
    [string]$ConfigFile = "$PSScriptRoot\apps.json",
    [string]$LocalConfigFile = "$PSScriptRoot\apps.local.json",
    [string[]]$Categories = @(),  # Update specific categories only
    [switch]$IncludeOptional = $false,
    [switch]$WhatIf = $false
)

function Update-WingetApp {
    param($app, [switch]$WhatIf)

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

Write-Host "`n====== Updating Applications ======`n"

# Load configuration
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Configuration file not found: $ConfigFile"
    exit 1
}

# Load and merge configurations (same logic as install_apps.ps1)
$baseConfig = Get-Content $ConfigFile | ConvertFrom-Json
$localConfig = if (Test-Path $LocalConfigFile) { Get-Content $LocalConfigFile | ConvertFrom-Json } else { $null }
$config = Merge-AppConfigs -BaseConfig $baseConfig -LocalConfig $localConfig

if ($WhatIf) {
    Write-Host "DRY RUN - No changes will be made`n" -ForegroundColor Yellow
}

# Update uv first (tool dependency)
Write-Host "Updating uv..." -ForegroundColor Cyan
Update-UV -WhatIf:$WhatIf

# Update all winget apps
Write-Host "`nUpdating all Winget apps..." -ForegroundColor Cyan
if (-not $WhatIf) {
    winget upgrade --all --accept-package-agreements --accept-source-agreements
}

# Update specific apps from our config (redundant but ensures our list is covered)
Write-Host "`nUpdating configured Winget apps..." -ForegroundColor Cyan
$wingetApps = $config.winget_apps
if ($Categories.Count -gt 0) {
    $wingetApps = $wingetApps | Where-Object { $_.category -in $Categories }
}

foreach ($app in $wingetApps) {
    Update-WingetApp $app -WhatIf:$WhatIf
}

# Update optional apps if requested
if ($IncludeOptional) {
    Write-Host "`nUpdating Optional Apps..." -ForegroundColor Cyan
    $optionalWinget = $config.optional_apps | Where-Object { $_.manager -eq "winget" }
    if ($Categories.Count -gt 0) {
        $optionalWinget = $optionalWinget | Where-Object { $_.category -in $Categories }
    }

    foreach ($app in $optionalWinget) {
        Update-WingetApp $app -WhatIf:$WhatIf
    }
}

# Update Chocolatey apps
Write-Host "`nUpdating Chocolatey apps..." -ForegroundColor Cyan
$chocoApps = $config.choco_apps
if ($Categories.Count -gt 0) {
    $chocoApps = $chocoApps | Where-Object { $_.category -in $Categories }
}

if (-not $WhatIf) {
    Write-Host "Updating all Chocolatey packages..." -ForegroundColor Cyan
    choco upgrade all -y --no-progress
} else {
    foreach ($app in $chocoApps) {
        Update-ChocoApp $app -WhatIf:$WhatIf
    }
}

Write-Host "`n====== Update Complete! ======`n" -ForegroundColor Green