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

    # Ensure we don't let global error preferences turn non-zero exits into stops
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        Write-Log "Checking/Installing winget app: $($app.name) (category: $($app.category))"

        # Query installed state (capture all output)
        $listOutput = & winget list --exact -q $app.name --accept-source-agreements 2>&1 | Out-String
        Write-Log "winget list output for $($app.name):" -Level 'DEBUG'
        $listOutput -split "`n" | ForEach-Object { if ($_ -ne '') { Write-Log $_ -Level 'DEBUG' } }

        $isInstalled = $false
        if ($listOutput -and $listOutput -match [regex]::Escape($app.name)) { $isInstalled = $true }

        if (-not $isInstalled) {
            Write-Log "Installing: $($app.name)"
            # Build args explicitly so we can log them
            $args = @('install','--exact','--silent',$app.name,'--accept-package-agreements','--accept-source-agreements')
            if ($app.source) { $args = @('install','--exact','--silent',$app.name,'--source',$app.source,'--accept-package-agreements','--accept-source-agreements') }

            Write-Log ("Running: winget {0}" -f ($args -join ' ')) -Level 'DEBUG'

            # Run winget and capture output; do not let non-zero exit throw
            $installOutput = & winget @args 2>&1 | Out-String
            $installOutput -split "`n" | ForEach-Object { if ($_ -ne '') { Write-Log $_ -Level 'DEBUG' } }

            # Inspect output / last exit code
            if ($LASTEXITCODE -ne 0) {
                Write-Log "Installer reported exit code $LASTEXITCODE for $($app.name). See winget output above (DEBUG) or winget logs." -Level 'WARN'
            } else {
                Write-Log "Successfully initiated install for $($app.name)"
            }
        } else {
            Write-Log "Already installed: $($app.name)" -Level 'DEBUG'
        }
    } catch {
        Write-Log "winget failed for $($app.name): $($_.Exception.Message)" -Level 'WARN'
    } finally {
        $ErrorActionPreference = $prevEAP
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
            Write-Log "Already installed: $($app.name)" -Level 'DEBUG'
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
        Write-Log "Already installed: $appName" -Level 'INFO'
        return
    }

    Write-Log "Installing: $appName from URL"
    $tempDir = Join-Path $env:TEMP "url_app_install_$appName"
    try {
        New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
        $uri = [System.Uri]$app.url
        $fileName = [System.IO.Path]::GetFileName($uri.LocalPath)
        $downloadPath = Join-Path $tempDir $fileName
        # Prefer external curl.exe when available (supports -L -o). Fallback to Invoke-WebRequest.
        if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
            & curl.exe -L -o $downloadPath $app.url
        } else {
            # Use Invoke-WebRequest (PowerShell) as fallback; note -UseBasicParsing is for Windows PowerShell only
            Invoke-WebRequest -Uri $app.url -OutFile $downloadPath
        }
        New-Item -ItemType Directory -Force -Path $installPath | Out-Null
        if ($fileName -like '*.zip') {
            if (Get-Command 7z -ErrorAction SilentlyContinue) { 7z x $downloadPath -o"$installPath" -y | Out-Null } else { Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force }
        } else {
            Copy-Item $downloadPath -Destination $installPath -Force
        }

        # Determine list of binary-name candidates to search for.
        # Preferred new JSON field: "binary_name": ["luarocks-3.12.2-windows-64","bin","luarocks.exe"]
        # Backwards-compatible: if binary_name absent, fall back to executable_paths; if those absent use "*"
        $candidates = @()
        if ($null -ne $app.binary_name) {
            $candidates = $app.binary_name
        } elseif ($null -ne $app.executable_paths) {
            $candidates = $app.executable_paths
        } else {
            $candidates = @('*')
        }

        $addedPaths = @()
        foreach ($cand in $candidates) {
            if ($cand -eq '*') {
                # add installPath itself
                if (Test-Path $installPath) { $addedPaths += (Get-Item $installPath).FullName }
                continue
            }

            # 1) Prefer matching executable files: search recursively for files matching the candidate.
            try {
                $fileMatches = Get-ChildItem -Path $installPath -File -Recurse -ErrorAction SilentlyContinue |
                               Where-Object { $_.Name -like "*$cand*" -or $_.Name -ieq $cand }
            } catch {
                $fileMatches = @()
            }

            if ($fileMatches.Count -gt 0) {
                foreach ($f in $fileMatches) { $addedPaths += $f.DirectoryName }
                continue
            }

            # 2) Try direct top-level match first (folder)
            $topMatch = Join-Path $installPath $cand
            if (Test-Path $topMatch) {
                $addedPaths += (Get-Item $topMatch).FullName
                continue
            }

            # 3) Search for matching directories under installPath (case-insensitive, partial match)
            try {
                $matches = Get-ChildItem -Path $installPath -Directory -Recurse -ErrorAction SilentlyContinue |
                           Where-Object { $_.Name -like "*$cand*" -or $_.FullName -like "*$cand*" }
            } catch {
                $matches = @()
            }

            foreach ($m in $matches) { $addedPaths += $m.FullName }
        }

        # If nothing matched, as a last resort add the installPath itself
        if ($addedPaths.Count -eq 0 -and (Test-Path $installPath)) {
            $addedPaths += (Get-Item $installPath).FullName
        }

        # Add unique paths to User PATH
        if ($addedPaths.Count -gt 0) {
            $userPath = [Environment]::GetEnvironmentVariable('Path','User')
            foreach ($p in ($addedPaths | Select-Object -Unique)) {
                if ($userPath -notlike "*$p*") {
                    [Environment]::SetEnvironmentVariable('Path', "$p;$userPath", 'User')
                    $userPath = "$p;$userPath"
                    Write-Log "Added $p to user PATH" -Level 'INFO'
                } else {
                    Write-Log "Path already in user PATH: $p" -Level 'DEBUG'
                }
            }
        } else {
            Write-Log "No candidate binary folders found for $appName; install path: $installPath" -Level 'WARN'
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
if ($Categories.Count -gt 0) { $wingetApps = $wingetApps | Where-Object { $_.category -in $Categories }; Write-Log "Filtered to categories: $($Categories -join ', ')" -Level 'INFO' }
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
if ($DryRun) { Write-Log "`n[DRY RUN] Would run: wsl --install" } else { Write-Log "`nSetting up WSL..."; try { wsl --install } catch { Write-Log "WSL setup completed or already configured." -Level 'INFO' } }

Write-Log "`n====== Installation Complete! ======`n"
