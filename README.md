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

**Default (main branch):**
```bash
curl -fsSL https://raw.githubusercontent.com/chiplukes/.dotfiles/main/.linux/.setup/bootstrap.sh | bash
```

**From specific branch:**
```bash
# Download and run with branch parameter
curl -fsSL https://raw.githubusercontent.com/chiplukes/.dotfiles/linux_and_windows/.linux/.setup/bootstrap.sh -o bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh --branch linux_and_windows

# Or with short option
./bootstrap.sh -b linux_and_windows

# Custom repo and branch
./bootstrap.sh --repo https://github.com/user/dotfiles.git --branch feature-branch
```

## Windows

**Open Admin PowerShell with Bypass:**
- **Win + R** → `powershell -ExecutionPolicy Bypass` → **Ctrl + Shift + Enter**

**Default (main branch):**
```powershell
Invoke-Expression (Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/chiplukes/.dotfiles/main/.windows/.setup/bootstrap.ps1").Content
```

**From specific branch:**
```powershell
# Download and run with branch parameter
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

**Prerequisites:**
```powershell
# Set execution policy to allow local scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Or run with bypass:**
```powershell
# Run PowerShell with bypass for testing
powershell -ExecutionPolicy Bypass
cd ~/.windows/.setup
```

### Copy example to create your local config
```powershell
Copy-Item apps.local.json.example apps.local.json
```

### Edit to add your machine-specific apps
```powershell
notepad apps.local.json
```

### Full setup (recommended for new PC)
```powershell
.\install_new_pc.ps1
```

### Options and combinations
```powershell
# Skip debloat if you want to keep Windows apps
.\install_new_pc.ps1 -SkipDebloat

# Skip Neovim if you don't use it
.\install_new_pc.ps1 -SkipNeovim

# Skip Python if you have other Python installs
.\install_new_pc.ps1 -SkipPython

# Dry run to see what would be executed
.\install_new_pc.ps1 -WhatIf

# Custom combination
.\install_new_pc.ps1 -SkipDebloat -SkipNeovim
```

### Individual installation scripts
```powershell
# Install all apps
.\install_apps.ps1

# Install only core apps
.\install_apps.ps1 -Categories @("core")

# Install core and dev tools
.\install_apps.ps1 -Categories @("core", "dev")

# Install with optional apps
.\install_apps.ps1 -IncludeOptional
```

### Update apps
```powershell
# Update all apps
.\upgrade_apps.ps1

# Dry run update (see what would be updated)
.\upgrade_apps.ps1 -WhatIf

# Update only gaming apps
.\upgrade_apps.ps1 -Categories @("gaming") -IncludeOptional
```

## Linux

**Available setup scripts in `~/.linux/.setup/`:**
```bash
# Base tools and utilities
./install_base.sh

# Neovim with Python integration
./install_neovim.sh

# HDL development tools (Icarus Verilog, MyHDL)
./install_hdl_tools.sh

# Verilator HDL simulator
./install_verilator.sh

# RISC-V development toolchain
./install_risc_dev_tools.sh

# Complete work environment setup
./install_desktop_work.sh
```

**Run individual scripts as needed:**
```bash
cd ~/.linux/.setup
chmod +x *.sh
./install_base.sh
./install_neovim.sh
# etc.
```
