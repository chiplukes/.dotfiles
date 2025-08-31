# powershell install command:
#iex ((New-Object System.Net.WebClient).DownloadString('https://gist.githubusercontent.com/chiplukes/f276a30c78cc6cb162cdb55533f60b7d/raw/a888dea57de571a985297ea9c14f77bb65de920f/DevMachineSetup.ps1'))

# Pieces taken from:
# https://chris-ayers.com/2021/08/01/scripting-winget/
# https://github.com/ChrisTitusTech/winutilwinutil
# https://gist.github.com/NateWeiler/f01aa5c6e8209263bc2daa328b1ae7e2
# ...existing code...
function refresh-path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Assume winget & choco already installed by install_base.ps1

#Configure WinGet
Write-Output "Configuring winget"
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
$settingsJson = @"
{
  "experimentalFeatures": {
    "experimentalMSStore": true
  }
}
"@
$settingsJson | Out-File $settingsPath -Encoding utf8

Write-Output "Installing Winget Apps"
$apps = @(

    # core tools
    @{name = "Git.Git" },
    @{name = "GitHub.cli" },
    @{name = "GitHub.GitHubDesktop" },
    @{name = "Mozilla.Firefox" },
    @{name = "Adobe.Acrobat.Reader.64-bit" },
    @{name = "Joplin.Joplin" },
    @{name = "Microsoft.VisualStudioCode" },
    @{name = "Bitwarden.Bitwarden" },
    @{name = "Zzip.7zip" },
    @{name = "Microsoft.WindowsTerminal"; source = "msstore" },
    @{name = "Microsoft.PowerShell" },
    @{name = "Microsoft.PowerToys" },
    @{name = "Microsoft.Sysinternals.ProcessMonitor" },
    @{name = "Canonical.Ubuntu.2204" },
    @{name = "Nilesoft.Shell" }, # add whatever you want to right-click context menu
    @{name = "GitExtensionsTeam.GitExtensions" }, # add whatever you want to right-click context menu

    # image tools
    @{name = "KDE.Krita" }, # image editor
    @{name = "Inkscape.Inkscape" },

    # work tools
    @{name = "PuTTY.PuTTY" },
    @{name = "WiresharkFoundation.Wireshark" },

    # gaming
    @{name = "Valve.Steam" },
    #@{name = "CPUID.CPU-Z" },
    #@{name = "TechPowerUp.GPU-Z" },
    #@{name = "REALiX.HWiNFO" },

    # misc
    @{name = "Sandboxie.Plus" },
    #@{name = "BurntSushi.ripgrep.GNU"},

    # UI for winget
    @{name = "SomePythonThings.WingetUIStore" }

)
foreach ($app in $apps) {
  $listApp = winget list --exact -q $app.name --accept-source-agreements 2>$null
  if (-not ([string]::Join("",$listApp).Contains($app.name))) {
    Write-Host "Installing: $($app.name)"
    if ($app.source) {
      winget install --exact --silent $app.name --source $app.source --accept-package-agreements --accept-source-agreements
    } else {
      winget install --exact --silent $app.name --accept-package-agreements --accept-source-agreements
    }
  } else {
    Write-Host "Skipping (already installed): $($app.name)"
  }
}

refresh-path

Write-Output "Installing Chocolatey Apps"
$chocoApps = @("mingw","make","fd","luarocks","ripgrep","llvm")
foreach ($c in $chocoApps) {
  choco list --localonly --exact $c | Select-String -Quiet " $c " >$null 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "choco install $c"
    choco install $c -y --no-progress
  } else {
    Write-Host "Already installed: $c"
  }
}

# Debloat section (unchanged)
# ...existing code continues (removal list, tweaks, WSL, etc.)...




# ...existing code continues (removal list, tweaks, WSL, etc.)...