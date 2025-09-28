# PowerShell Profile for dotfiles management
# This file is version controlled and symlinked to all PowerShell profile locations

# Dotfiles management function
function dotfiles { git --git-dir="$env:USERPROFILE\.dotfiles-bare" --work-tree="$env:USERPROFILE" @args }

# Load Python interceptor
$interceptorPath = "$env:USERPROFILE\.windows\.scripts\.python_uv_interceptor.ps1"
if (Test-Path $interceptorPath) {
    . $interceptorPath
    Write-Host "[OK] Python -> uv interceptor loaded" -ForegroundColor Green
}

# Add any other PowerShell customizations here