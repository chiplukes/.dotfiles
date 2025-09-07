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

# Clean up all PowerShell profiles - remove any existing dotfiles-related lines
$AllProfiles = @(
    $PROFILE.AllUsersAllHosts,
    $PROFILE.AllUsersCurrentHost,
    $PROFILE.CurrentUserAllHosts,
    $PROFILE.CurrentUserCurrentHost
)

foreach ($ProfilePath in $AllProfiles) {
    if ($ProfilePath -and (Test-Path $ProfilePath)) {
        Write-Host "Cleaning up PowerShell profile: $ProfilePath"
        $ProfileContent = Get-Content $ProfilePath | Where-Object {
            $_ -notlike "*dotfiles*"
        }
        $ProfileContent | Set-Content $ProfilePath
    }
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

# Add dotfiles function to all PowerShell profiles
$AllProfiles = @(
    @{ Path = $PROFILE.CurrentUserCurrentHost; Description = "Current User, Current Host" },
    @{ Path = $PROFILE.CurrentUserAllHosts; Description = "Current User, All Hosts" },
    @{ Path = $PROFILE.AllUsersCurrentHost; Description = "All Users, Current Host" },
    @{ Path = $PROFILE.AllUsersAllHosts; Description = "All Users, All Hosts" }
)

$FunctionLine = 'function dotfiles { git --git-dir="$env:USERPROFILE\.dotfiles-bare" --work-tree="$env:USERPROFILE" @args }'

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

            # Create profile file if it doesn't exist
            if (-not (Test-Path $ProfilePath)) {
                Write-Host "Creating profile file: $ProfilePath"
                New-Item -Path $ProfilePath -ItemType File -Force | Out-Null
            }

            # Check if dotfiles function already exists in this profile
            $ExistingContent = Get-Content $ProfilePath -ErrorAction SilentlyContinue
            if ($ExistingContent -and ($ExistingContent -like "*function dotfiles*")) {
                Write-Host "Dotfiles function already exists in profile ($ProfileDesc): $ProfilePath"
            } else {
                Write-Host "Adding dotfiles function to PowerShell profile ($ProfileDesc): $ProfilePath"
                Add-Content $ProfilePath ""
                Add-Content $ProfilePath "# Dotfiles management function"
                Add-Content $ProfilePath $FunctionLine
            }
        }
        catch {
            Write-Warning "Failed to update profile ($ProfileDesc): $ProfilePath - $($_.Exception.Message)"
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
Write-Host "Platform-specific setup scripts available in:"
Write-Host "  ~/.windows/setup/ (run as needed)"
Write-Host ""
Write-Host "To use the dotfiles function immediately:"
Write-Host "  1. Restart PowerShell, OR"
Write-Host "  2. Run: . `$PROFILE"
Write-Host ""
Write-Host "If 'dotfiles' command is not found, manually reload with:"
Write-Host "  . `$PROFILE"
Write-Host ""
Write-Host "Your original conflicting files (if any) are backed up in: $DotfilesBackup"