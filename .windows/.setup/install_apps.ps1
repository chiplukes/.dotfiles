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

            # Debug: Show directory structure after extraction
            Write-Host "  Directory structure after extraction:" -ForegroundColor Gray
            Get-ChildItem -Path $installPath -Recurse | Where-Object { $_.PSIsContainer -or $_.Name -like "*.exe" } | ForEach-Object {
                $indent = "    " * (($_.FullName.Substring($installPath.Length) -split '\\').Count - 1)
                $marker = if ($_.PSIsContainer) { "[DIR]" } else { "[EXE]" }
                Write-Host "  $indent$marker $($_.Name)" -ForegroundColor Gray
            }
        } else {
            Write-Host "  Copying executable..." -ForegroundColor Gray
            Copy-Item $downloadPath -Destination $installPath -Force
        }

        # Add executable paths to user PATH if specified
        if ($app.executable_paths) {
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            $pathsToAdd = @()

            foreach ($exePath in $app.executable_paths) {
                $resolvedPaths = @()

                # Handle wildcard patterns like "*/bin", "*", or "**/bin"
                if ($exePath -like "*`*") {
                    Write-Host "  Resolving wildcard pattern: $exePath" -ForegroundColor Gray

                    # For * pattern, find all subdirectories that contain executable files
                    if ($exePath -eq "*") {
                        $foundPaths = Get-ChildItem -Path $installPath -Directory | ForEach-Object {
                            $dirPath = $_.FullName
                            $executables = Get-ChildItem -Path $dirPath -File -ErrorAction SilentlyContinue | Where-Object {
                                $_.Extension -in @('.exe', '.bat', '.cmd') -or $_.Extension -eq ''
                            }
                            if ($executables.Count -gt 0) {
                                $dirPath
                            }
                        }
                        $resolvedPaths = $foundPaths | Where-Object { $_ -ne $null }
                    }
                    # For */bin pattern, find all subdirectories that contain a bin folder
                    elseif ($exePath -eq "*/bin") {
                        $foundPaths = Get-ChildItem -Path $installPath -Directory | ForEach-Object {
                            $binPath = Join-Path $_.FullName "bin"
                            if (Test-Path $binPath -PathType Container) {
                                $binPath
                            }
                        }
                        $resolvedPaths = $foundPaths | Where-Object { $_ -ne $null }
                    }
                    # For other wildcard patterns, use recursive search
                    else {
                        $searchPattern = $exePath -replace '\*', '*'
                        $resolvedPaths = Get-ChildItem -Path $installPath -Recurse -Directory | Where-Object {
                            $relativePath = $_.FullName.Substring($installPath.Length + 1)
                            $relativePath -like $searchPattern
                        } | Select-Object -ExpandProperty FullName
                    }

                    if ($resolvedPaths.Count -eq 0) {
                        Write-Host "  No paths found matching pattern: $exePath" -ForegroundColor Yellow
                    } else {
                        Write-Host "  Found $($resolvedPaths.Count) path(s) matching pattern" -ForegroundColor Gray
                    }
                } else {
                    # Handle explicit paths
                    $fullExePath = Join-Path $installPath $exePath
                    if (Test-Path $fullExePath) {
                        $resolvedPaths = @($fullExePath)
                    }
                }

                # Add all resolved paths
                foreach ($resolvedPath in $resolvedPaths) {
                    if (Test-Path $resolvedPath) {
                        $pathsToAdd += $resolvedPath
                    }
                }
            }

            # If no explicit paths were found, try auto-detection
            if ($pathsToAdd.Count -eq 0 -and $app.executable_paths) {
                Write-Host "  Auto-detecting executable directories..." -ForegroundColor Gray

                # First, look for bin directories recursively
                $binDirs = Get-ChildItem -Path $installPath -Recurse -Directory | Where-Object { $_.Name -eq "bin" }

                foreach ($binDir in $binDirs) {
                    $executables = Get-ChildItem -Path $binDir.FullName -File -ErrorAction SilentlyContinue | Where-Object {
                        $_.Extension -in @('.exe', '.bat', '.cmd') -or $_.Extension -eq ''
                    }

                    if ($executables.Count -gt 0) {
                        Write-Host "  Found executable directory: $($binDir.FullName)" -ForegroundColor Gray
                        $pathsToAdd += $binDir.FullName
                    }
                }

                # If no bin directories found, look for any directories with executables
                if ($pathsToAdd.Count -eq 0) {
                    $allDirs = Get-ChildItem -Path $installPath -Recurse -Directory

                    foreach ($dir in $allDirs) {
                        $executables = Get-ChildItem -Path $dir.FullName -File -ErrorAction SilentlyContinue | Where-Object {
                            $_.Extension -in @('.exe', '.bat', '.cmd') -or $_.Extension -eq ''
                        }

                        if ($executables.Count -gt 0) {
                            Write-Host "  Found executable directory: $($dir.FullName)" -ForegroundColor Gray
                            $pathsToAdd += $dir.FullName
                        }
                    }
                }
            }

            # Add unique paths to user PATH
            foreach ($pathToAdd in ($pathsToAdd | Select-Object -Unique)) {
                $escapedPath = [Regex]::Escape($pathToAdd)
                if ($userPath -notmatch $escapedPath) {
                    Write-Host "  Adding to PATH: $pathToAdd" -ForegroundColor Gray
                    [Environment]::SetEnvironmentVariable("Path", "$pathToAdd;$userPath", "User")
                    $userPath = "$pathToAdd;$userPath"
                } else {
                    Write-Host "  Already in PATH: $pathToAdd" -ForegroundColor Gray
                }
            }

            if ($pathsToAdd.Count -eq 0) {
                Write-Host "  No executable paths found to add to PATH" -ForegroundColor Yellow
            }
        }

        Write-Host "  [OK] Successfully installed $appName" -ForegroundColor Green

        # Clean up
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    catch {
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
