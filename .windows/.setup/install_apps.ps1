[CmdletBinding()]
param(
    [string]$ConfigFile = "$PSScriptRoot\apps.json",  # ADD THIS LINE
    [string]$LocalConfigFile = "$PSScriptRoot\apps.local.json",
    [string[]]$Categories = @(),  # Install specific categories only
    [switch]$IncludeOptional = $false
)

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Install-WingetApp {
    param($app)

    $listApp = winget list --exact -q $app.name --accept-source-agreements 2>$null
    if (-not ([string]::Join("",$listApp).Contains($app.name))) {
        Write-Host "Installing: $($app.name)" -ForegroundColor Green
        if ($app.source) {
            winget install --exact --silent $app.name --source $app.source --accept-package-agreements --accept-source-agreements
        } else {
            winget install --exact --silent $app.name --accept-package-agreements --accept-source-agreements
        }
    } else {
        Write-Host "Already installed: $($app.name)" -ForegroundColor Yellow
    }
}

function Install-ChocoApp {
    param($app)

    choco list --localonly --exact $app.name | Select-String -Quiet " $($app.name) " >$null 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installing: $($app.name)" -ForegroundColor Green
        choco install $app.name -y --no-progress
    } else {
        Write-Host "Already installed: $($app.name)" -ForegroundColor Yellow
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

Write-Host "`n====== Installing Applications ======`n"

# Load base configuration
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Base configuration file not found: $ConfigFile"
    exit 1
}

Write-Host "Loading base config: $ConfigFile" -ForegroundColor Cyan
$baseConfig = Get-Content $ConfigFile | ConvertFrom-Json

# Load local configuration if it exists
$localConfig = $null
if (Test-Path $LocalConfigFile) {
    Write-Host "Loading local config: $LocalConfigFile" -ForegroundColor Cyan
    $localConfig = Get-Content $LocalConfigFile | ConvertFrom-Json
} else {
    Write-Host "No local config found: $LocalConfigFile (this is normal)" -ForegroundColor Gray
}

# Merge configurations
$config = Merge-AppConfigs -BaseConfig $baseConfig -LocalConfig $localConfig

Write-Host "Total apps to consider:" -ForegroundColor Yellow
Write-Host "  Winget: $($config.winget_apps.Count)"
Write-Host "  Chocolatey: $($config.choco_apps.Count)"
Write-Host "  Optional: $($config.optional_apps.Count)"

# Configure WinGet
Write-Host "`nConfiguring winget..." -ForegroundColor Cyan
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
$settingsJson = @"
{
  "experimentalFeatures": {
    "experimentalMSStore": true
  }
}
"@
New-Item -ItemType Directory -Force -Path (Split-Path $settingsPath) | Out-Null
$settingsJson | Out-File $settingsPath -Encoding utf8 -Force

# Install Winget apps
Write-Host "`nInstalling Winget Apps..." -ForegroundColor Cyan
$wingetApps = $config.winget_apps
if ($Categories.Count -gt 0) {
    $wingetApps = $wingetApps | Where-Object { $_.category -in $Categories }
    Write-Host "Filtered to categories: $($Categories -join ', ')" -ForegroundColor Gray
}

foreach ($app in $wingetApps) {
    Install-WingetApp $app
}

# Install optional apps if requested
if ($IncludeOptional) {
    Write-Host "`nInstalling Optional Apps..." -ForegroundColor Cyan
    $optionalWinget = $config.optional_apps | Where-Object { $_.manager -eq "winget" }
    if ($Categories.Count -gt 0) {
        $optionalWinget = $optionalWinget | Where-Object { $_.category -in $Categories }
    }

    foreach ($app in $optionalWinget) {
        Install-WingetApp $app
    }
}

Refresh-Path

# Install Chocolatey apps
Write-Host "`nInstalling Chocolatey Apps..." -ForegroundColor Cyan
$chocoApps = $config.choco_apps
if ($Categories.Count -gt 0) {
    $chocoApps = $chocoApps | Where-Object { $_.category -in $Categories }
}

foreach ($app in $chocoApps) {
    Install-ChocoApp $app
}

# Setup WSL
Write-Host "`nSetting up WSL..." -ForegroundColor Cyan
try {
    wsl --install
} catch {
    Write-Host "WSL setup completed or already configured." -ForegroundColor Yellow
}

Write-Host "`n====== Installation Complete! ======`n"
