# install NeoVim with WinGet, if not already present on system
if (!$(Get-Command nvim -ErrorAction SilentlyContinue)) {
    winget install Neovim.Neovim
}

# clone my Dotfiles repo
$dotFilesRoot = Join-Path $HOME "dotfiles"

if (!(Test-Path $dotFilesRoot -PathType Container)) {
    git clone https://github.com/chiplukes/dotfiles.git $dotFilesRoot
}

# link NeoVim configuration
$localConfiguration = Join-Path $env:LOCALAPPDATA "nvim"
$dotfilesConfiguration = Join-Path $dotFilesRoot ".config" "nvim"

if (!(Test-Path $localConfiguration -PathType Container)) {
    Start-Process -FilePath "pwsh" -ArgumentList "-c New-Item -Path $localConfiguration -ItemType SymbolicLink -Value $dotfilesConfiguration".Split(" ") -Verb runas
}
