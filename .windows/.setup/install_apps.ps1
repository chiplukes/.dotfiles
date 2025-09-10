[CmdletBinding()]
param(
    [string]$ConfigFile = "$PSScriptRoot\apps.json",
    [string]$LocalConfigFile = "$PSScriptRoot\apps.local.json",
    [string[]]$Categories = @(),  # Install specific categories only
    [switch]$DryRun
)

# Dot-source shared helpers (resolve via script path)
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$helpers = Join-Path $ScriptRoot 'helpers.ps1'
if (Test-Path $helpers) { . $helpers } else { Write-Log "helpers.ps1 not found at $helpers" -Level 'WARN' }

# Resolve config paths relative to script root when needed
$ConfigFilePath = $ConfigFile
if (-not (Test-Path $ConfigFilePath)) { $ConfigFilePath = Join-Path $ScriptRoot (Split-Path $ConfigFile -Leaf) }
$ConfigFile = $ConfigFilePath

$LocalConfigFilePath = $LocalConfigFile
if (-not (Test-Path $LocalConfigFilePath)) { $LocalConfigFilePath = Join-Path $ScriptRoot (Split-Path $LocalConfigFile -Leaf) }
$LocalConfigFile = $LocalConfigFilePath

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Install-WingetApp {
    param($app)

    try {
        $listApp = winget list --exact -q $app.name --accept-source-agreements 2>$null
        if (-not ([string]::Join('', $listApp).Contains($app.name))) {
            Write-Log "Installing: $($app.name)"
            if ($app.source) {
                winget install --exact --silent $app.name --source $app.source --accept-package-agreements --accept-source-agreements
            } else {
                winget install --exact --silent $app.name --accept-package-agreements --accept-source-agreements
            }
        } else {
            Write-Verbose "Already installed: $($app.name)"
        }
    } catch {
        Write-Log "winget failed for $($app.name): $($_.Exception.Message)" -Level 'WARN'
    }
}

function Install-ChocoApp {
    param($app)

    try {
        choco list --localonly --exact $app.name | Select-String -Quiet " $($app.name) " >$null 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Installing: $($app.name)"
            choco install $app.name -y --no-progress
        } else {
            Write-Verbose "Already installed: $($app.name)"
        }
    } catch {
        Write-Log "choco failed for $($app.name): $($_.Exception.Message)" -Level 'WARN'
    }
}

function Install-UrlApp {
    param($app)

    $installPath = $ExecutionContext.InvokeCommand.ExpandString($app.install_path)
    $appName = $app.name

    # Check if already installed
    if (Test-Path $installPath) {
        Write-Verbose "Already installed: $appName"
        return
    }

    Write-Log "Installing: $appName from URL"
    $tempDir = Join-Path $env:TEMP "url_app_install_$appName"
    try {
        New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
        $uri = [System.Uri]$app.url
        $fileName = [System.IO.Path]::GetFileName($uri.LocalPath)
        $downloadPath = Join-Path $tempDir $fileName
        if (Get-Command curl -ErrorAction SilentlyContinue) { curl -L -o $downloadPath $app.url } else { Invoke-WebRequest -Uri $app.url -OutFile $downloadPath -UseBasicParsing }
        New-Item -ItemType Directory -Force -Path $installPath | Out-Null
        if ($fileName -like '*.zip') {
            if (Get-Command 7z -ErrorAction SilentlyContinue) { 7z x $downloadPath -o"$installPath" -y | Out-Null } else { Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force }
        } else {
            Copy-Item $downloadPath -Destination $installPath -Force
        }

        if ($app.executable_paths) {
            $userPath = [Environment]::GetEnvironmentVariable('Path','User')
            foreach ($p in $app.executable_paths) {
                $candidate = Join-Path $installPath $p
                if (Test-Path $candidate) {
                    if ($userPath -notlike "*$candidate*") { [Environment]::SetEnvironmentVariable('Path', "$candidate;$userPath", 'User'); $userPath = "$candidate;$userPath"; Write-Verbose "Added $candidate to user PATH" }
                }
            }
        }

        Write-Log "  [OK] Successfully installed $appName"
    } catch {
        Write-Log "Failed to install $appName`: $($_.Exception.Message)" -Level 'ERROR'
    } finally {
        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

# Load configs
Write-Log "`n====== Installing Applications ======`n"
try { $baseConfig = Import-JsonConfig -Path $ConfigFile -AllowLeadingLineCommentsOnly } catch { Write-Log $_.Exception.Message -Level 'ERROR'; exit 1 }
$localConfig = $null
if (Test-Path $LocalConfigFile) { try { $localConfig = Import-JsonConfig -Path $LocalConfigFile -AllowLeadingLineCommentsOnly } catch { Write-Log "Failed to parse local config: $LocalConfigFile" -Level 'WARN' } }

$config = Merge-AppConfigsGeneric -Base $baseConfig -Local $localConfig

Write-Log "Total apps to consider:"
Write-Log "  Winget: $($config.winget_apps.Count)"
Write-Log "  Chocolatey: $($config.choco_apps.Count)"
Write-Log "  URL-based: $($config.url_apps.Count)"

Write-Log "`nConfiguring winget..."
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
$settingsJson = @"
{
  "experimentalFeatures": { "experimentalMSStore": true }
}
"@
New-Item -ItemType Directory -Force -Path (Split-Path $settingsPath) | Out-Null
$settingsJson | Out-File $settingsPath -Encoding utf8 -Force

Write-Log "`nInstalling Winget Apps..."
$wingetApps = $config.winget_apps
if ($Categories.Count -gt 0) { $wingetApps = $wingetApps | Where-Object { $_.category -in $Categories }; Write-Verbose "Filtered to categories: $($Categories -join ', ')" }
foreach ($app in $wingetApps) { if ($DryRun) { Write-Log "[DRY RUN] Would install winget: $($app.name) (category: $($app.category))" } else { Install-WingetApp $app } }

Refresh-Path

Write-Log "`nInstalling URL-based Apps..."
$urlApps = $config.url_apps
if ($Categories.Count -gt 0) { $urlApps = $urlApps | Where-Object { $_.category -in $Categories } }
foreach ($app in $urlApps) { if ($DryRun) { Write-Log "[DRY RUN] Would install url-app: $($app.name) -> $($app.url) (category: $($app.category))" } else { Install-UrlApp $app } }

Refresh-Path

Write-Log "`nInstalling Chocolatey Apps..."
$chocoApps = $config.choco_apps
if ($Categories.Count -gt 0) { $chocoApps = $chocoApps | Where-Object { $_.category -in $Categories } }
foreach ($app in $chocoApps) { if ($DryRun) { Write-Log "[DRY RUN] Would install choco: $($app.name) (category: $($app.category))" } else { Install-ChocoApp $app } }

# Setup WSL
if ($DryRun) { Write-Log "`n[DRY RUN] Would run: wsl --install" } else { Write-Log "`nSetting up WSL..."; try { wsl --install } catch { Write-Verbose "WSL setup completed or already configured." } }

Write-Log "`n====== Installation Complete! ======`n"
