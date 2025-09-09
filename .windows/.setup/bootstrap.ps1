[CmdletBinding()]
param(
    [string]$Branch = "main"  # Add branch parameter
)

Write-Output ""
Write-Output "====== Setting up bare dotfiles repository (Windows) ======"
Write-Output ""

$DotfilesRepo = "https://github.com/chiplukes/.dotfiles.git"
$DotfilesDir = "$env:USERPROFILE\.dotfiles-bare"
$DotfilesBackup = "$env:USERPROFILE\.config-backup"

# Clean up any existing dotfiles setup
Write-Output "Cleaning up any existing dotfiles setup..."

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
        # Create a safe backup path by sanitizing the original path
        $SafePath = $ProfilePath

        # Replace common drive patterns and invalid path characters
        $SafePath = $SafePath -replace "^C:\\", "C_Drive\"
        $SafePath = $SafePath -replace "^[A-Z]:\\", { "$($_.Value[0])_Drive\" }
        $SafePath = $SafePath -replace ":", "_"
        $SafePath = $SafePath -replace "\\", "\"

        # Remove user profile path if it exists to make it relative
        if ($ProfilePath.StartsWith($env:USERPROFILE)) {
            $SafePath = $ProfilePath.Substring($env:USERPROFILE.Length + 1)
            $SafePath = "UserProfile\$SafePath"
        }

        $BackupPath = Join-Path $DotfilesBackup "powershell-profiles\$SafePath"
        $BackupDir = Split-Path $BackupPath -Parent

    Write-Output "Backing up PowerShell profile: $ProfilePath"
    Write-Output "  -> $BackupPath"

        try {
            New-Item -ItemType Directory -Force -Path $BackupDir -ErrorAction SilentlyContinue | Out-Null
            Copy-Item $ProfilePath $BackupPath -Force -ErrorAction SilentlyContinue
            $ProfilesBackedUp += $ProfilePath
        }
        catch {
            Write-Warning "Failed to backup profile $ProfilePath`: $($_.Exception.Message)"
        }

        # Remove the original
    Write-Output "Removing existing PowerShell profile: $ProfilePath"
        Remove-Item $ProfilePath -Force -ErrorAction SilentlyContinue
    }
}

if ($ProfilesBackedUp.Count -gt 0) {
    Write-Output "Backed up $($ProfilesBackedUp.Count) PowerShell profile(s) to $DotfilesBackup\powershell-profiles\"
}

# Dot-source helpers
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$helpers = Join-Path $ScriptRoot 'helpers.ps1'
if (Test-Path $helpers) { . $helpers } else { Write-Warning "helpers.ps1 not found at $helpers" }

# Create dotfiles function for this session
function dotfiles { git --git-dir="$DotfilesDir" --work-tree="$env:USERPROFILE" @args }

Write-Output "Using branch: $Branch"
Write-Output "Cloning dotfiles as bare repository to $DotfilesDir"

# Clone the repository as bare with specific branch
git clone --bare -b $Branch $DotfilesRepo $DotfilesDir

# Configure bare repository to fetch all branches properly
dotfiles config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
dotfiles fetch origin

# Detect and back up conflicting files after all git operations

Write-Output "Checking out dotfiles..."
# Try checkout, capture error output
$checkoutOutput = dotfiles checkout 2>&1
Write-Output "[DEBUG] Checkout output:"
$checkoutOutput | ForEach-Object { Write-Output $_ }
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
Write-Output "[DEBUG] Conflicting files detected:"
$conflictFiles | ForEach-Object { Write-Output $_ }

if ($conflictFiles.Count -gt 0) {
    Write-Host "Backing up pre-existing dot files to $DotfilesBackup"
    New-DirectoryIfMissing -Path $DotfilesBackup | Out-Null
    foreach ($file in $conflictFiles) {
        $sourcePath = Join-Path $env:USERPROFILE $file
        $backupPath = Join-Path $DotfilesBackup $file
        $backupDir = Split-Path $backupPath -Parent
        New-Item -ItemType Directory -Force -Path $backupDir -ErrorAction SilentlyContinue | Out-Null
        if (Test-Path $sourcePath) {
                    Write-Output "Backing up: $sourcePath -> $backupPath"
            Copy-Item $sourcePath $backupPath -Force -ErrorAction SilentlyContinue
        } else {
            Write-Warning "[Warning] Source file does not exist: $sourcePath"
        }
    }
    # Remove originals after backup
    foreach ($file in $conflictFiles) {
        $sourcePath = Join-Path $env:USERPROFILE $file
        if (Test-Path $sourcePath) {
            Write-Output "Removing original: $sourcePath"
            Remove-Item $sourcePath -Force -ErrorAction SilentlyContinue
        }
    }
    # Try checkout again
    Write-Output "Performing actual checkout after backup..."
    dotfiles checkout
}

# Configure the repository
Write-Output "Configuring dotfiles repository..."
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

Write-Output "Setting up PowerShell profile symlinks..."
Write-Output "Master profile location: $MasterProfile"

foreach ($Profile in $AllProfiles) {
    $ProfilePath = $Profile.Path
    $ProfileDesc = $Profile.Description

    if ($ProfilePath) {
        try {
            # Create profile directory if it doesn't exist
            $ProfileDir = Split-Path $ProfilePath -Parent
            if (-not (Test-Path $ProfileDir)) {
                Write-Output "Creating profile directory: $ProfileDir"
                New-Item -Path $ProfileDir -ItemType Directory -Force | Out-Null
            }

            # Remove existing profile file if it exists
            if (Test-Path $ProfilePath) {
                Write-Output "Removing existing profile: $ProfilePath"
                Remove-Item $ProfilePath -Force
            }

            # Create symlink to master profile
            if (Test-Path $MasterProfile) {
                Write-Output "Creating symlink for profile ($ProfileDesc): $ProfilePath -> $MasterProfile"
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

Write-Output ""
Write-Output "====== Dotfiles setup complete! ======"
Write-Output "Usage:"
Write-Output "  dotfiles status"
Write-Output "  dotfiles add .config\nvim\init.lua"
Write-Output "  dotfiles commit -m 'Update config'"
Write-Output "  dotfiles push"
Write-Output ""
Write-Output "PowerShell profile setup:"
Write-Output "  - Master profile: ~/profile.ps1 (version controlled)"
Write-Output "  - All PowerShell profiles are symlinked to the master profile"
Write-Output "  - Edit ~/profile.ps1 to customize your PowerShell environment"
Write-Output ""
Write-Output "Platform-specific setup scripts available in:"
Write-Output "  ~/.windows/setup/ (run as needed)"
Write-Output ""
Write-Output "To use the dotfiles function immediately:" 
Write-Output "  1. Restart PowerShell, OR"
Write-Output "  2. Run: . `$env:USERPROFILE\profile.ps1"
Write-Output ""
Write-Output "Note: If symlink creation failed, you may need to:"
Write-Output "  - Run PowerShell as Administrator, OR"
Write-Output "  - Enable Developer Mode in Windows Settings"
Write-Output ""
Write-Output "Your original conflicting files (if any) are backed up in: $DotfilesBackup"