[CmdletBinding()]
param(
    [string]$Branch = "master"  # Add branch parameter
)

Write-Host ""
Write-Host "====== Setting up bare dotfiles repository ======"
Write-Host ""

$DotfilesRepo = "https://github.com/chiplukes/.dotfiles.git"
$DotfilesDir = "$env:USERPROFILE\.dotfiles-bare"
$DotfilesBackup = "$env:USERPROFILE\.config-backup"

# Remove existing .dotfiles-bare directory
if (Test-Path $DotfilesDir) {
    Write-Host "Removing existing .dotfiles-bare directory..."
    Remove-Item -Recurse -Force $DotfilesDir
}

# Remove any existing dotfiles function/alias from current session
Remove-Item Function:\dotfiles -ErrorAction SilentlyContinue
Remove-Item Alias:\dotfiles -ErrorAction SilentlyContinue

# Create dotfiles function for this session
function dotfiles { git --git-dir="$DotfilesDir" --work-tree="$env:USERPROFILE" @args }

Write-Host "Using branch: $Branch"
Write-Host "Cloning dotfiles as bare repository to $DotfilesDir"

# Clone the repository as bare with specific branch
git clone --bare -b $Branch $DotfilesRepo $DotfilesDir

# Configure bare repository to fetch all branches properly
dotfiles config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
dotfiles fetch origin

# Configure the repository
Write-Host "Configuring dotfiles repository..."
dotfiles config --local status.showUntrackedFiles no
dotfiles config --local core.worktree $env:USERPROFILE

# Detect and back up conflicting files after all git operations
Write-Host "Checking for conflicting files during checkout..."
# Try checkout, capture error output
$checkoutOutput = dotfiles checkout 2>&1
#$checkoutOutput | ForEach-Object { Write-Host $_ } # uncomment for debugging
$conflictFiles = @()
$collect = $false
foreach ($line in $checkoutOutput) {
    $strLine = $line.ToString()
    if ($strLine -and ($strLine.IndexOf('files would be overwritten by checkout:', [System.StringComparison]::Ordinal) -ge 0)) {
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
Write-Warning "The following files will be overwritten by checkout:"
$conflictFiles | ForEach-Object { Write-Host $_ }

if ($conflictFiles.Count -gt 0) {
    Write-Warning "Backing up pre-existing dot files to $DotfilesBackup"
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
            Write-Warning "[Warning] Source file does not exist: $sourcePath"
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

# Consolidated: backup, remove, and symlink each PowerShell profile
$MasterProfile = Join-Path $env:USERPROFILE 'profile.ps1'
# Potential locations for powershell profiles (may or may not exist on a given system)
$ProfileObjects = @(
    @{ Path = $PROFILE.AllUsersAllHosts; Description = 'All Users, All Hosts' },
    @{ Path = $PROFILE.AllUsersCurrentHost; Description = 'All Users, Current Host' },
    @{ Path = $PROFILE.CurrentUserAllHosts; Description = 'Current User, All Hosts' },
    @{ Path = $PROFILE.CurrentUserCurrentHost; Description = 'Current User, Current Host' }
)

$ProfilesBackedUp = @()
Write-Host "Dotfiles Powershell profile location: $MasterProfile"

foreach ($p in $ProfileObjects) {
    $ProfilePath = $p.Path
    $ProfileDesc = $p.Description
    if (-not $ProfilePath) { continue }

    # If profile exists, back it up before removing
    if (Test-Path $ProfilePath) {
        try {
            if ($ProfilePath.StartsWith($env:USERPROFILE, [System.StringComparison]::OrdinalIgnoreCase)) {
                $rel = $ProfilePath.Substring($env:USERPROFILE.Length).TrimStart('\')
                $safe = Join-Path 'UserProfile' $rel
            } else {
                $drive = $ProfilePath.Substring(0,1).ToUpper()
                $rest  = $ProfilePath.Substring(2).TrimStart('\')
                $safe  = Join-Path ("${drive}_Drive") $rest
            }

            $BackupPath = Join-Path $DotfilesBackup (Join-Path 'powershell-profiles' $safe)
            $BackupDir  = Split-Path $BackupPath -Parent
            New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
            Copy-Item -Path $ProfilePath -Destination $BackupPath -Force -ErrorAction Stop
            $ProfilesBackedUp += $ProfilePath
            Write-Host "Backed up PowerShell profile: $ProfilePath -> $BackupPath"
        } catch {
            Write-Warning "Failed to backup profile $ProfilePath`: $($_.Exception.Message)"
        }

        try { Remove-Item -Path $ProfilePath -Force -ErrorAction SilentlyContinue } catch { }
        Write-Host "Removed existing PowerShell profile: $ProfilePath"
    }

    # Ensure parent directory exists before creating a symlink
    $ProfileDir = Split-Path $ProfilePath -Parent
    if (-not (Test-Path $ProfileDir)) {
        New-Item -Path $ProfileDir -ItemType Directory -Force | Out-Null
    }

    # Create symlink to master profile if it exists
    if (Test-Path $MasterProfile) {
        try {
            Write-Host "Creating symlink for profile ($ProfileDesc): $ProfilePath -> $MasterProfile"
            New-Item -ItemType SymbolicLink -Path $ProfilePath -Target $MasterProfile -Force | Out-Null
        } catch {
            Write-Warning "Failed to create symlink for profile ($ProfileDesc): $ProfilePath - $($_.Exception.Message)"
            Write-Warning "You may need to run as Administrator to create symbolic links"
        }
    } else {
        Write-Warning "Master profile not found at $MasterProfile - skipping symlink creation for $ProfileDesc"
        Write-Host "Note: The profile.ps1 file should be checked out to $MasterProfile by the bare repo"
    }
}

if ($ProfilesBackedUp.Count -gt 0) {
    Write-Host "Backed up $($ProfilesBackedUp.Count) PowerShell profile(s) to $DotfilesBackup\powershell-profiles\"
}

Write-Host ""
Write-Host "====== Dotfiles setup complete! ======"
Write-Host "Usage:"
Write-Host "  dotfiles status"
Write-Host "  dotfiles add .config\nvim\init.lua"
Write-Host "  dotfiles commit -m 'Update config'"
Write-Host "  dotfiles push"
Write-Host ""
Write-Host "Platform-specific setup scripts available in:"
Write-Host "  ~/.windows/setup/ (run as needed)"
Write-Host ""
Write-Host "Restart PowerShell to pick up the dotfiles function."
Write-Host "Your original conflicting files (if any) are backed up in: $DotfilesBackup"