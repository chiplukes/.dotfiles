[CmdletBinding()]
param()

$UserPyVersion = "3.12"
Write-Host ""
Write-Host "====== Installing user Python with uv ($UserPyVersion) ======"
Write-Host ""
$LogFile = "$env:USERPROFILE\install_progress_log.txt"

function Ensure-Curl {
  if (Get-Command curl -ErrorAction SilentlyContinue) { return }
  Write-Host "curl not found; attempting install..."
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    try {
      winget install --id cURL.cURL -e --accept-package-agreements --accept-source-agreements -h
      if ($LASTEXITCODE -ne 0) {
        winget install cURL.cURL -e --accept-package-agreements --accept-source-agreements
      }
    } catch { }
    if (Get-Command curl -ErrorAction SilentlyContinue) { return }
  }
  if (Get-Command choco -ErrorAction SilentlyContinue) {
    try { choco install curl -y --no-progress } catch { }
    if (Get-Command curl -ErrorAction SilentlyContinue) { return }
  }
  Write-Host "Could not install curl automatically (continuing with Invoke-WebRequest)."
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
  $env:PATH = "$env:USERPROFILE\.local\bin;$env:PATH"
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

$UserPath = [Environment]::GetEnvironmentVariable("Path","User")
if ($UserPath -notmatch [Regex]::Escape($BinDir)) {
  [Environment]::SetEnvironmentVariable("Path","$BinDir;$UserPath","User")
  Write-Host "Added $BinDir to user PATH (restart shells)."
}

& $PyExe -V
"Interpreter path: $PyExe"
"Wrappers: python$MajMin python$Patch python-user"

"python$Patch Installed (uv)" | Tee-Object -FilePath $LogFile -Append

@"
USER_PYTHON_PATH=$PyExe
USER_PYTHON_MAJOR_MINOR=$MajMin
USER_PYTHON_PATCH=$Patch
"@ | Set-Content -Encoding UTF8 "$env:USERPROFILE\.user_python_resolved"
