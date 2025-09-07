[CmdletBinding()]
param(
    [string]$ConfigFile = "$PSScriptRoot\apps.json",
    [string]$LocalConfigFile = "$PSScriptRoot\apps.local.json",
    [string[]]$Categories = @()  # Install specific categories only
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

function Install-UrlApp {
    param($app)

    $installPath = $ExecutionContext.InvokeCommand.ExpandString($app.install_path)
    $appName = $app.name

    # Check if already installed
    if (Test-Path $installPath) {
        Write-Host "Already installed: $appName" -ForegroundColor Yellow
        return
    }

    Write-Host "Installing: $appName from URL" -ForegroundColor Green

    try {
        # Create temporary download directory
        $tempDir = Join-Path $env:TEMP "url_app_install_$appName"
        New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

        # Determine file extension and download path
        $uri = [System.Uri]$app.url
        $fileName = [System.IO.Path]::GetFileName($uri.LocalPath)
        $downloadPath = Join-Path $tempDir $fileName

        Write-Host "  Downloading $fileName..." -ForegroundColor Gray

        # Download file
        if (Get-Command curl -ErrorAction SilentlyContinue) {
            curl -L -o $downloadPath $app.url
        } else {
            Invoke-WebRequest -Uri $app.url -OutFile $downloadPath -UseBasicParsing
        }

        # Create install directory
        New-Item -ItemType Directory -Force -Path $installPath | Out-Null

        # Extract if it's a zip file, otherwise copy directly
        if ($fileName -like "*.zip") {
            Write-Host "  Extracting archive..." -ForegroundColor Gray
            if (Get-Command 7z -ErrorAction SilentlyContinue) {
                7z x $downloadPath -o"$installPath" -y | Out-Null
            } else {
                Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force
            }
        } else {
            Write-Host "  Copying executable..." -ForegroundColor Gray
            Copy-Item $downloadPath -Destination $installPath -Force
        }

        # Add executable paths to user PATH if specified
        if ($app.executable_paths) {
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            foreach ($exePath in $app.executable_paths) {
                $fullExePath = Join-Path $installPath $exePath
                if (Test-Path $fullExePath) {
                    $escapedPath = [Regex]::Escape($fullExePath)
                    if ($userPath -notmatch $escapedPath) {
                        Write-Host "  Adding to PATH: $fullExePath" -ForegroundColor Gray
                        [Environment]::SetEnvironmentVariable("Path", "$fullExePath;$userPath", "User")
                        $userPath = "$fullExePath;$userPath"
                    }
                }
            }
        }

        Write-Host "  ✓ Successfully installed $appName" -ForegroundColor Green

        # Clean up
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    } catch {
        Write-Error "Failed to install $appName`: $($_.Exception.Message)"
        # Clean up on failure
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $installPath) {
            Remove-Item $installPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Merge-AppConfigs {
    param($BaseConfig, $LocalConfig)

    $merged = @{
        winget_apps = @()
        choco_apps = @()
        url_apps = @()
    }

    # Start with base config
    if ($BaseConfig.winget_apps) { $merged.winget_apps += $BaseConfig.winget_apps }
    if ($BaseConfig.choco_apps) { $merged.choco_apps += $BaseConfig.choco_apps }
    if ($BaseConfig.url_apps) { $merged.url_apps += $BaseConfig.url_apps }

    # Add local config if present
    if ($LocalConfig) {
        if ($LocalConfig.winget_apps) { $merged.winget_apps += $LocalConfig.winget_apps }
        if ($LocalConfig.choco_apps) { $merged.choco_apps += $LocalConfig.choco_apps }
        if ($LocalConfig.url_apps) { $merged.url_apps += $LocalConfig.url_apps }
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
Write-Host "  URL-based: $($config.url_apps.Count)"

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

Refresh-Path

# Install URL-based apps
Write-Host "`nInstalling URL-based Apps..." -ForegroundColor Cyan
$urlApps = $config.url_apps
    if ($Categories.Count -gt 0) {
    $urlApps = $urlApps | Where-Object { $_.category -in $Categories }
    }

foreach ($app in $urlApps) {
    Install-UrlApp $app
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
