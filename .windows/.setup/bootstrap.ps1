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

# Clean up PowerShell profile - remove any existing dotfiles function
$ProfilePath = $PROFILE.CurrentUserCurrentHost
if (Test-Path $ProfilePath) {
    Write-Host "Cleaning up PowerShell profile..."
    $ProfileContent = Get-Content $ProfilePath | Where-Object { 
        $_ -notmatch "function dotfiles" -and 
        $_ -notmatch "# Dotfiles management function"
    }
    $ProfileContent | Set-Content $ProfilePath
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

# Checkout files, backing up any conflicts
Write-Host "Checking out dotfiles..."
try {
    dotfiles checkout 2>$null
} catch {
    Write-Host "Backing up pre-existing dot files to $DotfilesBackup"
    New-Item -ItemType Directory -Force -Path $DotfilesBackup | Out-Null

    # Get conflicting files and back them up
    $conflicts = dotfiles checkout 2>&1 | Where-Object { $_ -match '^\s+\.' }
    foreach ($line in $conflicts) {
        $file = ($line -split '\s+')[1]
        if ($file) {
            Write-Host "Backing up: $file"
            $backupPath = Join-Path $DotfilesBackup $file
            $backupDir = Split-Path $backupPath -Parent
            New-Item -ItemType Directory -Force -Path $backupDir -ErrorAction SilentlyContinue | Out-Null
            $sourcePath = Join-Path $env:USERPROFILE $file
            if (Test-Path $sourcePath) {
                Move-Item $sourcePath $backupPath -ErrorAction SilentlyContinue
            }
        }
    }

    # Try checkout again
    dotfiles checkout
}

# Configure the repository
Write-Host "Configuring dotfiles repository..."
dotfiles config --local status.showUntrackedFiles no
dotfiles config --local core.worktree $env:USERPROFILE

# Add dotfiles function to PowerShell profile
if (-not (Test-Path $ProfilePath)) {
    New-Item -Path $ProfilePath -Force | Out-Null
}

$FunctionLine = 'function dotfiles { git --git-dir="$env:USERPROFILE\.dotfiles-bare" --work-tree="$env:USERPROFILE" @args }'
Write-Host "Adding dotfiles function to PowerShell profile"
Add-Content $ProfilePath ""
Add-Content $ProfilePath "# Dotfiles management function"
Add-Content $ProfilePath $FunctionLine

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
Write-Host "Restart PowerShell to pick up the dotfiles function."
Write-Host "Your original conflicting files (if any) are backed up in: $DotfilesBackup"