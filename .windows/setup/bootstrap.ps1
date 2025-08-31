[CmdletBinding()]
param()

Write-Host "`n====== Setting up bare dotfiles repository (Windows) ======`n"

$DotfilesRepo = if ($args[0]) { $args[0] } else { "https://github.com/chiplukes/dotfiles.git" }
$DotfilesDir = "$env:USERPROFILE\.cfg"
$DotfilesBackup = "$env:USERPROFILE\.config-backup"

# Create dotfiles function for this session
function dotfiles { git --git-dir="$DotfilesDir" --work-tree="$env:USERPROFILE" @args }

Write-Host "Cloning dotfiles as bare repository to $DotfilesDir"
if (Test-Path $DotfilesDir) {
    Write-Host "Warning: $DotfilesDir already exists. Removing..."
    Remove-Item -Recurse -Force $DotfilesDir
}

# Clone the repository as bare
git clone --bare $DotfilesRepo $DotfilesDir

# Checkout files, backing up any conflicts
Write-Host "Checking out dotfiles..."
try {
    dotfiles checkout 2>$null
    Write-Host "✓ Dotfiles checked out successfully" -ForegroundColor Green
} catch {
    Write-Host "Backing up pre-existing dot files to $DotfilesBackup" -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $DotfilesBackup | Out-Null

    # Get conflicting files and back them up
    $conflicts = dotfiles checkout 2>&1 | Where-Object { $_ -match '^\s+\.' }
    $conflictCount = 0

    foreach ($line in $conflicts) {
        # Extract filename from git output
        if ($line -match '^\s+(.+)$') {
            $file = $matches[1].Trim()
            if ($file -and (Test-Path "$env:USERPROFILE\$file")) {
                Write-Host "Backing up: $file" -ForegroundColor Gray
                $backupPath = Join-Path $DotfilesBackup $file
                $backupDir = Split-Path $backupPath -Parent

                # Create backup directory if needed
                if (-not (Test-Path $backupDir)) {
                    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
                }

                # Move the conflicting file
                try {
                    Move-Item "$env:USERPROFILE\$file" $backupPath -Force
                    $conflictCount++
                } catch {
                    Write-Warning "Could not backup $file: $($_.Exception.Message)"
                }
            }
        }
    }

    Write-Host "Backed up $conflictCount conflicting files" -ForegroundColor Yellow

    # Try checkout again
    try {
        dotfiles checkout
        Write-Host "✓ Dotfiles checked out successfully after backup" -ForegroundColor Green
    } catch {
        Write-Error "Failed to checkout dotfiles even after backup: $($_.Exception.Message)"
        exit 1
    }
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
    Add-Content $ProfilePath "`n# Dotfiles management function"
    Add-Content $ProfilePath $FunctionLine
}

# Create .config directory if it doesn't exist (for cross-platform config)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\nvim" | Out-Null

Write-Host "`n====== Dotfiles setup complete! ======`n"
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
if (Test-Path $DotfilesBackup) {
    Write-Host "Your original conflicting files are backed up in: $DotfilesBackup" -ForegroundColor Yellow
}