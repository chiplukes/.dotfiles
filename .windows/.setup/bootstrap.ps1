[CmdletBinding()]
param(
    [string]$Branch = "main"  # Add branch parameter
)

Write-Host ""
Write-Host "====== Setting up bare dotfiles repository (Windows) ======"
Write-Host ""

$DotfilesRepo = "https://github.com/chiplukes/.dotfiles.git"
$DotfilesDir = "$env:USERPROFILE\.dotfiles-bare"
$DotfilesBackup = "$env:USERPROFILE\.config-backup"

# Clean up any existing dotfiles setup
Write-Host "Cleaning up any existing dotfiles setup..."

# Remove existing .dotfiles-bare directory
if (Test-Path $DotfilesDir) {
    Write-Host "Removing existing .dotfiles-bare directory..."
    Remove-Item -Recurse -Force $DotfilesDir
}

# Remove any existing dotfiles function/alias from current session
Remove-Item Function:\dotfiles -ErrorAction SilentlyContinue
Remove-Item Alias:\dotfiles -ErrorAction SilentlyContinue

# Clean up all PowerShell profiles - back up and remove existing files (including symlinks)
$AllProfiles = @(
    $PROFILE.AllUsersAllHosts,
    $PROFILE.AllUsersCurrentHost,
    $PROFILE.CurrentUserAllHosts,
    $PROFILE.CurrentUserCurrentHost
)

$ProfilesBackedUp = @()
foreach ($ProfilePath in $AllProfiles) {
    if ($ProfilePath -and (Test-Path $ProfilePath)) {
        # Create backup
        $RelativePath = $ProfilePath.Replace("$env:USERPROFILE\", "").Replace("C:\Program Files\", "ProgramFiles\")
        $BackupPath = Join-Path $DotfilesBackup "powershell-profiles\$RelativePath"
        $BackupDir = Split-Path $BackupPath -Parent

        Write-Host "Backing up PowerShell profile: $ProfilePath -> $BackupPath"
        New-Item -ItemType Directory -Force -Path $BackupDir -ErrorAction SilentlyContinue | Out-Null
        Copy-Item $ProfilePath $BackupPath -Force -ErrorAction SilentlyContinue
        $ProfilesBackedUp += $ProfilePath

        # Remove the original
        Write-Host "Removing existing PowerShell profile: $ProfilePath"
        Remove-Item $ProfilePath -Force -ErrorAction SilentlyContinue
    }
}

if ($ProfilesBackedUp.Count -gt 0) {
    Write-Host "Backed up $($ProfilesBackedUp.Count) PowerShell profile(s) to $DotfilesBackup\powershell-profiles\"
}

# Create dotfiles function for this session
function dotfiles { git --git-dir="$DotfilesDir" --work-tree="$env:USERPROFILE" @args }

Write-Host "Using branch: $Branch" -ForegroundColor Cyan
Write-Host "Cloning dotfiles as bare repository to $DotfilesDir"

# Clone the repository as bare with specific branch
git clone --bare -b $Branch $DotfilesRepo $DotfilesDir

# Configure bare repository to fetch all branches properly
dotfiles config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
dotfiles fetch origin

# Detect and back up conflicting files after all git operations

Write-Host "Checking out dotfiles..."
# Try checkout, capture error output
$checkoutOutput = dotfiles checkout 2>&1
Write-Host "[DEBUG] Checkout output:"
$checkoutOutput | ForEach-Object { Write-Host $_ }
$conflictFiles = @()
$collect = $false
foreach ($line in $checkoutOutput) {
    $strLine = $line.ToString()
    if ($strLine -match 'The following untracked working tree files would be overwritten by checkout:') {
        $collect = $true
        continue
    }
    if ($collect) {
        if ($strLine -match '^\s*$') { break }
        if ($strLine -match '^\s+(.+)$') {
            $file = $strLine.Trim()
            if ($file -and $file -ne '.') {
                $conflictFiles += $file
            }
        }
    }
}
Write-Host "[DEBUG] Conflicting files detected:"
$conflictFiles | ForEach-Object { Write-Host $_ }

if ($conflictFiles.Count -gt 0) {
    Write-Host "Backing up pre-existing dot files to $DotfilesBackup"
    New-Item -ItemType Directory -Force -Path $DotfilesBackup | Out-Null
    foreach ($file in $conflictFiles) {
        $sourcePath = Join-Path $env:USERPROFILE $file
        $backupPath = Join-Path $DotfilesBackup $file
        $backupDir = Split-Path $backupPath -Parent
        New-Item -ItemType Directory -Force -Path $backupDir -ErrorAction SilentlyContinue | Out-Null
        if (Test-Path $sourcePath) {
            Write-Host "Backing up: $sourcePath -> $backupPath"
            Copy-Item $sourcePath $backupPath -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "[Warning] Source file does not exist: $sourcePath"
        }
    }
    # Remove originals after backup
    foreach ($file in $conflictFiles) {
        $sourcePath = Join-Path $env:USERPROFILE $file
        if (Test-Path $sourcePath) {
            Write-Host "Removing original: $sourcePath"
            Remove-Item $sourcePath -Force -ErrorAction SilentlyContinue
        }
    }
    # Try checkout again
    Write-Host "Performing actual checkout after backup..."
    dotfiles checkout
}

# Configure the repository
Write-Host "Configuring dotfiles repository..."
dotfiles config --local status.showUntrackedFiles no
dotfiles config --local core.worktree $env:USERPROFILE

# Create symlinks from all PowerShell profile locations to the versioned profile.ps1
$MasterProfile = "$env:USERPROFILE\profile.ps1"
$AllProfiles = @(
    @{ Path = $PROFILE.CurrentUserCurrentHost; Description = "Current User, Current Host" },
    @{ Path = $PROFILE.CurrentUserAllHosts; Description = "Current User, All Hosts" },
    @{ Path = $PROFILE.AllUsersCurrentHost; Description = "All Users, Current Host" },
    @{ Path = $PROFILE.AllUsersAllHosts; Description = "All Users, All Hosts" }
)

Write-Host "Setting up PowerShell profile symlinks..."
Write-Host "Master profile location: $MasterProfile"

foreach ($Profile in $AllProfiles) {
    $ProfilePath = $Profile.Path
    $ProfileDesc = $Profile.Description

    if ($ProfilePath) {
        try {
            # Create profile directory if it doesn't exist
            $ProfileDir = Split-Path $ProfilePath -Parent
            if (-not (Test-Path $ProfileDir)) {
                Write-Host "Creating profile directory: $ProfileDir"
                New-Item -Path $ProfileDir -ItemType Directory -Force | Out-Null
            }

            # Remove existing profile file if it exists
            if (Test-Path $ProfilePath) {
                Write-Host "Removing existing profile: $ProfilePath"
                Remove-Item $ProfilePath -Force
            }

            # Create symlink to master profile
            if (Test-Path $MasterProfile) {
                Write-Host "Creating symlink for profile ($ProfileDesc): $ProfilePath -> $MasterProfile"
                New-Item -ItemType SymbolicLink -Path $ProfilePath -Target $MasterProfile -Force | Out-Null
            } else {
                Write-Warning "Master profile not found at $MasterProfile - skipping symlink creation for $ProfileDesc"
            }
        }
        catch {
            Write-Warning "Failed to create symlink for profile ($ProfileDesc): $ProfilePath - $($_.Exception.Message)"
            Write-Warning "You may need to run as Administrator to create symbolic links"
        }
    }
}

# Create .config directory if it doesn't exist (for cross-platform config)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\nvim" | Out-Null

Write-Host ""
Write-Host "====== Dotfiles setup complete! ======"
Write-Host "Usage:"
Write-Host "  dotfiles status"
Write-Host "  dotfiles add .config\nvim\init.lua"
Write-Host "  dotfiles commit -m 'Update config'"
Write-Host "  dotfiles push"
Write-Host ""
Write-Host "PowerShell profile setup:"
Write-Host "  - Master profile: ~/profile.ps1 (version controlled)"
Write-Host "  - All PowerShell profiles are symlinked to the master profile"
Write-Host "  - Edit ~/profile.ps1 to customize your PowerShell environment"
Write-Host ""
Write-Host "Platform-specific setup scripts available in:"
Write-Host "  ~/.windows/setup/ (run as needed)"
Write-Host ""
Write-Host "To use the dotfiles function immediately:"
Write-Host "  1. Restart PowerShell, OR"
Write-Host "  2. Run: . `$env:USERPROFILE\profile.ps1"
Write-Host ""
Write-Host "Note: If symlink creation failed, you may need to:"
Write-Host "  - Run PowerShell as Administrator, OR"
Write-Host "  - Enable Developer Mode in Windows Settings"
Write-Host ""
Write-Host "Your original conflicting files (if any) are backed up in: $DotfilesBackup"