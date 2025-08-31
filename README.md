# Dotfiles

Cross-platform dotfiles management using bare git repository.

## Structure

- `.config/` - Cross-platform configurations (Neovim, etc.)
- `.linux/` - Linux-specific files and setup scripts
- `.windows/` - Windows-specific files and setup scripts
- `.python/` - Cross-platform Python scripts

## Prerequisites

* git
* curl (Linux/macOS)

# Bootstrap

## Linux

```bash
curl -fsSL https://raw.githubusercontent.com/chiplukes/.dotfiles/main/.linux/.setup/bootstrap.sh | bash
```

## Windows

```powershell
# In Admin PowerShell - runs immediately with main branch
Invoke-Expression (Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/chiplukes/.dotfiles/main/.windows/.setup/bootstrap.ps1").Content
```

## Testing from Branch

```powershell
# For branch testing - download then run
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/chiplukes/.dotfiles/linux_and_windows/.windows/.setup/bootstrap.ps1" -OutFile "bootstrap.ps1"
.\bootstrap.ps1 -Branch linux_and_windows
```

## Usage

After bootstrap, manage your dotfiles with:

```bash
# Check status
dotfiles status

# Add new files
dotfiles add .config/nvim/init.lua
dotfiles add .bashrc

# Commit and push
dotfiles commit -m "Update configuration"
dotfiles push

# Pull updates on other machines
dotfiles pull
```

# Provisioning Apps

## Windows

### Copy example to create your local config
Copy-Item apps.local.json.example apps.local.json

### Edit to add your machine-specific apps
notepad apps.local.json

### Full setup (recommended for new PC)
.\install_new_pc.ps1

### Skip debloat if you want to keep Windows apps
.\install_new_pc.ps1 -SkipDebloat

### Skip Neovim if you don't use it
.\install_new_pc.ps1 -SkipNeovim

### Skip Python if you have other Python installs
.\install_new_pc.ps1 -SkipPython

### Dry run to see what would be executed
.\install_new_pc.ps1 -WhatIf

### Custom combination
.\install_new_pc.ps1 -SkipDebloat -SkipNeovim

### Run as Administrator for best results
### Right-click PowerShell -> "Run as Administrator"
.\install_new_pc.ps1

### Install all apps
.\install_apps.ps1

### Install only core apps
.\install_apps.ps1 -Categories @("core")

### Install core and dev tools
.\install_apps.ps1 -Categories @("core", "dev")

### Install with optional apps
.\install_apps.ps1 -IncludeOptional

### Update all apps
.\update_apps.ps1

### Dry run update (see what would be updated)
.\update_apps.ps1 -WhatIf

### Update only gaming apps
.\update_apps.ps1 -Categories @("gaming") -IncludeOptional



