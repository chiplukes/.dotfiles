# helpers.ps1 - shared helper functions for setup scripts

function Resolve-ScriptRoot {
    param([string]$FallbackPath = $MyInvocation.MyCommand.Path)
    if ($null -ne $PSScriptRoot -and $PSScriptRoot -ne '') { return $PSScriptRoot }
    return Split-Path -Parent $FallbackPath
}

function New-DirectoryIfMissing {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    return $Path
}

function Copy-FileBackup {
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$BackupRoot = (Join-Path $env:USERPROFILE '.config-backup'),
        [string]$Tag = (Get-Date -Format 'yyyyMMdd-HHmmss')
    )
    if (-not (Test-Path $Path)) { return $null }
    $leaf = Split-Path $Path -Leaf
    $relDir = Split-Path $Path -Parent
    $destDir = Join-Path $BackupRoot $relDir
    New-DirectoryIfMissing -Path $destDir | Out-Null
    $dest = Join-Path $destDir ("{0}.{1}.bak" -f $leaf, $Tag)
    Copy-Item -Path $Path -Destination $dest -Force
    return $dest
}

function Set-FileWithBackup {
    param(
      [Parameter(Mandatory)][string]$TargetPath,
      [Parameter(Mandatory)][string]$SourcePath,
      [string]$BackupRoot = (Join-Path $env:USERPROFILE '.config-backup')
    )
    if (Test-Path $TargetPath) {
        $bk = Copy-FileBackup -Path $TargetPath -BackupRoot $BackupRoot
        Write-Verbose "Backed up $TargetPath -> $bk"
    } else {
        New-DirectoryIfMissing -Path (Split-Path $TargetPath -Parent) | Out-Null
    }
    Copy-Item -Path $SourcePath -Destination $TargetPath -Force
}

function Remove-JsonComments {
    param(
        [string]$JsonText,
        [switch]$AllowOnlyLeadingDoubleSlash
    )
    if ($null -eq $JsonText) { return $JsonText }
    if ($AllowOnlyLeadingDoubleSlash) {
        $res = [Regex]::Replace($JsonText, '(?m)^\s*//.*$', '')
    } else {
        # conservative: remove whole-line // and trailing commas
        $res = [Regex]::Replace($JsonText, '(?m)^\s*//.*$', '')
        $res = [Regex]::Replace($res, ',\s*(?=[}\]])', '')
    }
    return $res
}

function Import-JsonConfig {
    param(
        [Parameter(Mandatory)][string]$Path,
        [switch]$AllowLeadingLineCommentsOnly
    )
    if (-not (Test-Path $Path)) { throw ("Config file not found: {0}" -f $Path) }
    try {
        $raw = Get-Content $Path -Raw
        $clean = Remove-JsonComments -JsonText $raw -AllowOnlyLeadingDoubleSlash:$AllowLeadingLineCommentsOnly
        return $clean | ConvertFrom-Json
    } catch {
        throw ('Failed to parse JSON config {0}: {1}' -f $Path, $_.Exception.Message)
    }
}

function Merge-AppConfigsGeneric {
    param(
        [Parameter(Mandatory)][psobject]$Base,
        [psobject]$Local,
        [string[]]$ArrayKeys = @('winget_apps','choco_apps','url_apps','optional_apps')
    )
    $merged = @{}
    foreach ($k in $ArrayKeys) { $merged[$k] = @() }
    foreach ($k in $ArrayKeys) {
        if ($Base -and $Base.$k) { $merged[$k] += $Base.$k }
    }
    if ($Local) {
        foreach ($k in $ArrayKeys) {
            if ($Local.$k) { $merged[$k] += $Local.$k }
        }
    }
    return $merged
}

function Add-ToUserPath {
    param([Parameter(Mandatory)][string]$Path)
    $userPath = [Environment]::GetEnvironmentVariable('Path','User')
    if ($userPath -notmatch [Regex]::Escape($Path)) {
        [Environment]::SetEnvironmentVariable('Path', ("{0};{1}" -f $Path, $userPath), 'User')
        Write-Verbose "Added to user PATH: $Path"
    } else {
        Write-Verbose "Already in user PATH: $Path"
    }
}

function Test-CommandExists {
    param([Parameter(Mandatory)][string]$CmdName)
    return [bool](Get-Command $CmdName -ErrorAction SilentlyContinue)
}

function Test-AdminRights { return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) }

function New-Symlink-Elevated {
    param([Parameter(Mandatory)][string]$Link,[Parameter(Mandatory)][string]$Target)
    try {
        New-Item -Path $Link -ItemType SymbolicLink -Value $Target -Force -ErrorAction Stop | Out-Null
        return $true
    } catch {
        Write-Warning "Symlink creation requires elevation; retrying elevated..."
        $ps = "New-Item -Path '$Link' -ItemType SymbolicLink -Value '$Target' -Force"
        Start-Process -FilePath 'powershell' -ArgumentList '-NoProfile','-Command',$ps -Verb RunAs -Wait
        return (Test-Path $Link)
    }
}

function Invoke-SetupScript {
    param(
        [Parameter(Mandatory)][string]$ScriptPath,
        [string]$Description = '',
        [hashtable]$Arguments = @{},
        [switch]$SkipIfMissing,
        [switch]$WhatIf
    )
    if (-not (Test-Path $ScriptPath)) {
        if ($SkipIfMissing) { Write-Warning "Skipping missing script: $ScriptPath"; return $true }
        Write-Error "Required script missing: $ScriptPath"; return $false
    }
    Write-Output "Running: $Description"
    if ($WhatIf) { Write-Output "WOULD RUN: $ScriptPath"; return $true }
    try {
        if ($Arguments.Count -gt 0) { & $ScriptPath @Arguments } else { & $ScriptPath }
        return $true
    } catch {
        Write-Error ('Failed running {0}: {1}' -f $ScriptPath, $_.Exception.Message); return $false
    }
}

function Write-Section {
    param([string]$Title)
    Write-Output ""
    Write-Output ('=' * 60)
    Write-Output " $Title "
    Write-Output ('=' * 60)
    Write-Output ""
}

function Write-DryRun {
    param([switch]$DryRun,[string]$Message)
    if ($DryRun) { Write-Output "[DRY RUN] $Message"; return $false } else { return $true }
}
