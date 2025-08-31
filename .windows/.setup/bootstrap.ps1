[CmdletBinding()]
param(
    [string]$Branch = "main"  # Add branch parameter
)

Write-Host ""
Write-Host "====== Setting up bare dotfiles repository (Windows) ======"
Write-Host ""

$DotfilesRepo = "https://github.com/chiplukes/.dotfiles.git"
$DotfilesDir = "$env:USERPROFILE\.cfg"
$DotfilesBackup = "$env:USERPROFILE\.config-backup"

# Create dotfiles function for this session
function dotfiles { git --git-dir="$DotfilesDir" --work-tree="$env:USERPROFILE" @args }

Write-Host "Using branch: $Branch" -ForegroundColor Cyan
Write-Host "Cloning dotfiles as bare repository to $DotfilesDir"

if (Test-Path $DotfilesDir) {
    Write-Host "Warning: $DotfilesDir already exists. Removing..."
    Remove-Item -Recurse -Force $DotfilesDir
}

# Clone the repository as bare with specific branch
git clone --bare -b $Branch $DotfilesRepo $DotfilesDir

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
$ProfilePath = $PROFILE.CurrentUserCurrentHost
if (-not (Test-Path $ProfilePath)) {
    New-Item -Path $ProfilePath -Force | Out-Null
}

$FunctionLine = 'function dotfiles { git --git-dir="$env:USERPROFILE\.cfg" --work-tree="$env:USERPROFILE" @args }'
if (-not (Get-Content $ProfilePath -ErrorAction SilentlyContinue | Select-String "function dotfiles")) {
    Write-Host "Adding dotfiles function to PowerShell profile"
    Add-Content $ProfilePath ""
    Add-Content $ProfilePath "# Dotfiles management function"
    Add-Content $ProfilePath $FunctionLine
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
Write-Host "Restart PowerShell to pick up the dotfiles function."
Write-Host "Your original conflicting files (if any) are backed up in: $DotfilesBackup"