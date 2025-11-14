[CmdletBinding()]
param()

# Dot-source helpers
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$helpers = Join-Path $ScriptRoot 'helpers.ps1'

# Load Python version from central config
$configFile = Join-Path (Split-Path -Parent $ScriptRoot) 'python_config'
if (Test-Path $configFile) {
    $UserPyVersion = (Get-Content $configFile | Where-Object { $_ -match '^PYTHON_VERSION=' } | ForEach-Object { ($_ -split '=')[1].Trim() })
    if (-not $UserPyVersion) { $UserPyVersion = "3.12" }
} else {
    $UserPyVersion = "3.12"
}
if (Test-Path $helpers) { . $helpers } else { Write-Log "helpers.ps1 not found at $helpers" -Level 'WARN' }

Write-Log ""
Write-Log "====== Installing user Python with uv ($UserPyVersion) ======"
Write-Log ""
$LogFile = "$env:USERPROFILE\install_progress_log.txt"

function Ensure-Curl {
  if (Test-CommandExists -CmdName 'curl') { return }
  Write-Log "curl not found; attempting install..." -Level 'INFO'
  if (Test-CommandExists -CmdName 'winget') {
    try {
      winget install --id cURL.cURL -e --accept-package-agreements --accept-source-agreements -h
      if ($LASTEXITCODE -ne 0) {
        winget install cURL.cURL -e --accept-package-agreements --accept-source-agreements
      }
    } catch { }
    if (Get-Command curl -ErrorAction SilentlyContinue) { return }
  }
  if (Test-CommandExists -CmdName 'choco') {
    try { choco install curl -y --no-progress } catch { }
    if (Get-Command curl -ErrorAction SilentlyContinue) { return }
  }
  Write-Log "Could not install curl automatically (continuing with Invoke-WebRequest)." -Level 'WARN'
}

# Ensure uv
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
  Ensure-Curl
  try {
    # Use curl if now available, else Invoke-WebRequest
    if (Get-Command curl -ErrorAction SilentlyContinue) {
      $script = curl -LsSf https://astral.sh/uv/install.ps1
      Invoke-Expression $script
    } else {
      Invoke-Expression (Invoke-WebRequest -UseBasicParsing https://astral.sh/uv/install.ps1).Content
    }
  } catch {
    "uv install failed: $($_.Exception.Message)" | Tee-Object -FilePath $LogFile -Append
    exit 1
  }
  Add-ToUserPath -Path "$env:USERPROFILE\.local\bin"
}

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
  "uv still not available" | Tee-Object -FilePath $LogFile -Append
  exit 1
}

# Install / locate Python
if (-not (uv python find $UserPyVersion *> $null)) {
  uv python install $UserPyVersion
}
$PyPath = uv python find $UserPyVersion 2>$null
if (-not $PyPath) {
  "Failed to resolve Python $UserPyVersion" | Tee-Object -FilePath $LogFile -Append
  exit 1
}

$PyExe  = (Resolve-Path $PyPath).Path
$MajMin = & $PyExe -c "import sys; print('.'.join(map(str, sys.version_info[:2])))"
$Patch  = & $PyExe -c "import sys; print('.'.join(map(str, sys.version_info[:3])))"

$BinDir = Join-Path $env:USERPROFILE "bin"
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

function New-PythonWrapper {
  param([string]$Name,[string]$TargetExe)
  $CmdPath = Join-Path $BinDir "$Name.cmd"
  @"
@echo off
REM Auto-generated launcher
"$TargetExe" %*
"@ | Set-Content -Encoding ASCII $CmdPath
}

#New-PythonWrapper -Name "python$MajMin" -TargetExe $PyExe
#New-PythonWrapper -Name "python$Patch" -TargetExe $PyExe
New-PythonWrapper -Name "python-user" -TargetExe $PyExe
#New-PythonWrapper -Name "python$MajMin-user" -TargetExe $PyExe

function Test-RealPythonCommand {
  param([string]$CmdName)
  $c = Get-Command $CmdName -ErrorAction SilentlyContinue
  if (-not $c) { return $false }
  # If the command path points into WindowsApps, it's the Microsoft Store stub — treat as not real
  $path = $null
  try { $path = $c.Path } catch { $path = $null }
  if (-not $path) { return $false }
  if ($path -match '\\WindowsApps\\') { return $false }
  return Test-Path $path
}

# Create plain 'python' and 'python3' wrappers only if a usable system python isn't present
if (-not (Test-RealPythonCommand 'python')) {
  Write-Log "No usable 'python' command found — creating 'python' wrapper pointing to user Python."
  New-PythonWrapper -Name "python" -TargetExe $PyExe
} else {
  Write-Log "Usable 'python' command already exists in PATH; not creating wrapper." -Level 'WARN'
}
if (-not (Test-RealPythonCommand 'python3')) {
  Write-Log "No usable 'python3' command found — creating 'python3' wrapper pointing to user Python."
  New-PythonWrapper -Name "python3" -TargetExe $PyExe
} else {
  Write-Log "Usable 'python3' command already exists in PATH; not creating wrapper." -Level 'WARN'
}

$UserPath = [Environment]::GetEnvironmentVariable("Path","User")
Add-ToUserPath -Path $BinDir

& $PyExe -V
"Interpreter path: $PyExe"
"Wrappers: python$MajMin python$Patch python-user"

"python$Patch Installed (uv)" | Tee-Object -FilePath $LogFile -Append

@"
USER_PYTHON_PATH=$PyExe
USER_PYTHON_MAJOR_MINOR=$MajMin
USER_PYTHON_PATCH=$Patch
"@ | Set-Content -Encoding UTF8 "$env:USERPROFILE\.user_python_resolved"


Write-Host "Disabling Windows Store Python aliases..." -ForegroundColor Yellow
try {
    # Remove the app execution aliases for python
    $aliasPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"

    if (Test-Path "$aliasPath\python.exe") {
        Remove-Item "$aliasPath\python.exe" -Force
        Write-Host "[OK] Removed python.exe alias" -ForegroundColor Green
    }

    if (Test-Path "$aliasPath\python3.exe") {
        Remove-Item "$aliasPath\python3.exe" -Force
        Write-Host "[OK] Removed python3.exe alias" -ForegroundColor Green
    }

    # Alternative: Disable via registry (requires admin)
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\microsoft.windowsstore_8wekyb3d8bbwe\AliasManager"

    if (Test-Path $regPath) {
        try {
            Set-ItemProperty -Path $regPath -Name "python.exe" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $regPath -Name "python3.exe" -Value 0 -ErrorAction SilentlyContinue
            Write-Host "[OK] Disabled aliases via registry" -ForegroundColor Green
        } catch {
            Write-Host "[!] Registry modification failed (may need admin rights)" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "Python aliases disabled. Please:" -ForegroundColor Cyan
    Write-Host "1. Close and reopen your PowerShell/Terminal" -ForegroundColor White
    Write-Host "2. Test by typing 'python' - should show uv interceptor" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual steps:" -ForegroundColor Yellow
    Write-Host "1. Go to Windows Settings -> Apps -> Advanced app settings -> App execution aliases" -ForegroundColor White
    Write-Host "2. Turn OFF toggles for python.exe and python3.exe" -ForegroundColor White
}

