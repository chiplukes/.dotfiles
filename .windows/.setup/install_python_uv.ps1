[CmdletBinding()]
param()

# Dot-source helpers
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$helpers = Join-Path $ScriptRoot 'helpers.ps1'
$UserPyVersion = "3.12"
if (Test-Path $helpers) { . $helpers } else { Write-Warning "helpers.ps1 not found at $helpers" }

Write-Output ""
Write-Output "====== Installing user Python with uv ($UserPyVersion) ======"
Write-Output ""
$LogFile = "$env:USERPROFILE\install_progress_log.txt"

function Ensure-Curl {
  if (Test-CommandExists -CmdName 'curl') { return }
  Write-Verbose "curl not found; attempting install..."
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
  Write-Warning "Could not install curl automatically (continuing with Invoke-WebRequest)."
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

New-PythonWrapper -Name "python$MajMin" -TargetExe $PyExe
New-PythonWrapper -Name "python$Patch" -TargetExe $PyExe
New-PythonWrapper -Name "python-user" -TargetExe $PyExe
New-PythonWrapper -Name "python$MajMin-user" -TargetExe $PyExe

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
  Write-Output "No usable 'python' command found — creating 'python' wrapper pointing to user Python."
  New-PythonWrapper -Name "python" -TargetExe $PyExe
} else {
  Write-Verbose "Usable 'python' command already exists in PATH; not creating wrapper."
}
if (-not (Test-RealPythonCommand 'python3')) {
  Write-Output "No usable 'python3' command found — creating 'python3' wrapper pointing to user Python."
  New-PythonWrapper -Name "python3" -TargetExe $PyExe
} else {
  Write-Verbose "Usable 'python3' command already exists in PATH; not creating wrapper."
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
