[CmdletBinding()]
param(
    [string]$Branch = "main"  # Add branch parameter
)

Write-Log ""
Write-Log "====== Setting up bare dotfiles repository (Windows) ======"
Write-Log ""

$DotfilesRepo = "https://github.com/chiplukes/.dotfiles.git"
$DotfilesDir = "$env:USERPROFILE\.dotfiles-bare"
$DotfilesBackup = "$env:USERPROFILE\.config-backup"

# Load shared helpers from the known location under the user's home
$HelpersPath = Join-Path $env:USERPROFILE ".windows\.setup\helpers.ps1"
if (Test-Path $HelpersPath) {
    try {
        . $HelpersPath
        Write-Log "Loaded helpers from: $HelpersPath"
    } catch {
        $msg = "Failed to dot-source helpers.ps1 from {0}: {1}" -f $HelpersPath, $_.Exception.Message
        throw $msg
    }
} else {
    throw ("helpers.ps1 not found at expected location: {0}. Ensure helpers.ps1 exists in ~/.windows/.setup/" -f $HelpersPath)
}

# Clean up any existing dotfiles setup
Write-Log "Cleaning up any existing dotfiles setup..."

# Remove existing .dotfiles-bare directory
if (Test-Path $DotfilesDir) {
    Write-Log "Removing existing .dotfiles-bare directory..."
    Remove-Item -Recurse -Force $DotfilesDir
}

# Remove any existing dotfiles function/alias from current session
Remove-Item Function:\dotfiles -ErrorAction SilentlyContinue
Remove-Item Alias:\dotfiles -ErrorAction SilentlyContinue

# Clean up PowerShell profile - remove any existing dotfiles function
$ProfilePath = $PROFILE.CurrentUserCurrentHost
if (Test-Path $ProfilePath) {
    Write-Log "Cleaning up PowerShell profile..."
    $ProfileContent = Get-Content $ProfilePath | Where-Object {
        $_ -notmatch "function dotfiles" -and
        $_ -notmatch "# Dotfiles management function"
    }
    $ProfileContent | Set-Content $ProfilePath
}

# Create dotfiles function for this session
function dotfiles { git --git-dir="$DotfilesDir" --work-tree="$env:USERPROFILE" @args }

Write-Log "Using branch: $Branch"
Write-Log "Cloning dotfiles as bare repository to $DotfilesDir"

# Clone the repository as bare with specific branch
git clone --bare -b $Branch $DotfilesRepo $DotfilesDir

# Configure bare repository to fetch all branches properly
dotfiles config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
dotfiles fetch origin

# Detect and back up conflicting files after all git operations

Write-Log "Checking out dotfiles..."
# Try checkout, capture error output
$checkoutOutput = dotfiles checkout 2>&1
Write-Verbose "[DEBUG] Checkout output:"
$checkoutOutput | ForEach-Object { Write-Verbose $_ }
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
Write-Verbose "[DEBUG] Conflicting files detected:"
$conflictFiles | ForEach-Object { Write-Verbose $_ }

if ($conflictFiles.Count -gt 0) {
    Write-Log "Backing up pre-existing dot files to $DotfilesBackup"
    New-Item -ItemType Directory -Force -Path $DotfilesBackup | Out-Null
    foreach ($file in $conflictFiles) {
        $sourcePath = Join-Path $env:USERPROFILE $file
        $backupPath = Join-Path $DotfilesBackup $file
        $backupDir = Split-Path $backupPath -Parent
        New-Item -ItemType Directory -Force -Path $backupDir -ErrorAction SilentlyContinue | Out-Null
        if (Test-Path $sourcePath) {
            Write-Log "Backing up: $sourcePath -> $backupPath"
            Copy-Item $sourcePath $backupPath -Force -ErrorAction SilentlyContinue
        } else {
            Write-Log "[Warning] Source file does not exist: $sourcePath" -Level 'WARNING'
        }
    }
    # Remove originals after backup
    foreach ($file in $conflictFiles) {
        $sourcePath = Join-Path $env:USERPROFILE $file
        if (Test-Path $sourcePath) {
            Write-Log "Removing original: $sourcePath"
            Remove-Item $sourcePath -Force -ErrorAction SilentlyContinue
        }
    }
    # Try checkout again
    Write-Log "Performing actual checkout after backup..."
    dotfiles checkout
}

# Configure the repository
Write-Log "Configuring dotfiles repository..."
dotfiles config --local status.showUntrackedFiles no
dotfiles config --local core.worktree $env:USERPROFILE

# Add dotfiles function to PowerShell profile
if (-not (Test-Path $ProfilePath)) {
    New-Item -Path $ProfilePath -Force | Out-Null
}

$FunctionLine = 'function dotfiles { git --git-dir="$env:USERPROFILE\.dotfiles-bare" --work-tree="$env:USERPROFILE" @args }'
Write-Log "Adding dotfiles function to PowerShell profile"
Add-Content $ProfilePath ""
Add-Content $ProfilePath "# Dotfiles management function"
Add-Content $ProfilePath $FunctionLine

# Create .config directory if it doesn't exist (for cross-platform config)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\nvim" | Out-Null

Write-Log ""
Write-Log "====== Dotfiles setup complete! ======"
Write-Log "Usage:"
Write-Log "  dotfiles status"
Write-Log "  dotfiles add .config\nvim\init.lua"
Write-Log "  dotfiles commit -m 'Update config'"
Write-Log "  dotfiles push"
Write-Log ""
Write-Log "Platform-specific setup scripts available in:"
Write-Log "  ~/.windows/setup/ (run as needed)"
Write-Log ""
Write-Log "Restart PowerShell to pick up the dotfiles function."
Write-Log "Your original conflicting files (if any) are backed up in: $DotfilesBackup"