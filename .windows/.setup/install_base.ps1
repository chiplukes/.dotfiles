[CmdletBinding()]
param()

Write-Host "`n=== Base Bootstrap: winget + Chocolatey ===`n"

# (Optional) Restore point if elevated
try {
  if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
     ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Checkpoint-Computer -Description "BaseBootstrap" -RestorePointType MODIFY_SETTINGS
  } else {
    Write-Host "Not elevated; skipping restore point."
  }
} catch { Write-Warning "Checkpoint skipped: $($_.Exception.Message)" }

# Ensure winget (DesktopAppInstaller)
$pkg = Get-AppPackage -Name 'Microsoft.DesktopAppInstaller' -ErrorAction SilentlyContinue
if (!$pkg -or [version]$pkg.Version -lt [version]"1.10.0.0") {
  Write-Host "Installing / updating winget..."
  Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
  $relUrl = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $releases = Invoke-RestMethod -Uri $relUrl
  $bundle = $releases.assets | Where-Object { $_.browser_download_url -match 'msixbundle$' } | Select-Object -First 1
  Add-AppxPackage -Path $bundle.browser_download_url
} else {
  Write-Host "winget already present."
}

# Ensure Chocolatey (official bootstrap)
if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
  Write-Host "Installing Chocolatey..."
  Set-ExecutionPolicy Bypass -Scope Process -Force
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
  Write-Host "Chocolatey already present."
}

Write-Host "`nBase tools ready. Run install_apps.ps1 next.`n"
