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
        Write-Log "Backed up $TargetPath -> $bk" -Level 'INFO'
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
        [string[]]$ArrayKeys = @('winget_apps','choco_apps','url_apps','uv_apps','optional_apps')
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
        Write-Log "Added to user PATH: $Path" -Level 'INFO'
    } else {
        Write-Log "Already in user PATH: $Path" -Level 'INFO'
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
        Write-Log "Symlink creation requires elevation; retrying elevated..." -Level 'WARN'
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
        if ($SkipIfMissing) { Write-Log "Skipping missing script: $ScriptPath" -Level 'WARN'; return $true }
        Write-Log "Required script missing: $ScriptPath" -Level 'ERROR'; return $false
    }
    Write-Log "Running: $Description"
    if ($WhatIf) { Write-Log "WOULD RUN: $ScriptPath"; return $true }
    try {
        if ($Arguments.Count -gt 0) { & $ScriptPath @Arguments } else { & $ScriptPath }
        return $true
    } catch {
        Write-Log ('Failed running {0}: {1}' -f $ScriptPath, $_.Exception.Message) -Level 'ERROR'; return $false
    }
}


function Write-DryRun {
    param([switch]$DryRun,[string]$Message)
    if ($DryRun) { Write-Log "[DRY RUN] $Message"; return $false } else { return $true }
}


# Ensure severity map and default log level are initialized
if (-not $Script:SeverityMap -or $null -eq $Script:SeverityMap) {
    $Script:SeverityMap = @{
        'DEBUG' = 10
        'INFO'  = 20
        'WARN'  = 30
        'ERROR' = 40
    }
}

if (-not $Global:InstallLogLevel -or $null -eq $Global:InstallLogLevel) {
    $envLevel = $env:INSTALL_LOG_LEVEL
    $Global:InstallLogLevel = if ($envLevel) { $envLevel.ToUpper() } else { 'INFO' }
}

function Write-Log {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [AllowEmptyString()]
        [string]$Message,

        [Parameter(Position=1)]
        [ValidateSet('INFO','WARN','ERROR','DEBUG')]
        [string]$Level = 'INFO',

        [switch]$Section
    )

    # Defensive: ensure severity map exists
    if (-not $Script:SeverityMap) {
        $Script:SeverityMap = @{
            'DEBUG' = 10
            'INFO'  = 20
            'WARN'  = 30
            'ERROR' = 40
        }
    }

    # Only emit if message severity >= configured level
    if ($Script:SeverityMap[$Level] -lt $Script:SeverityMap[$Global:InstallLogLevel]) { return }

    $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $logPath = Join-Path $env:USERPROFILE 'install.log'

    # If caller asked for a true blank line: host blank, file gets a timestamped placeholder line
    if ($Message -eq '') {
        Write-Host ''
        try {
            $fileLine = "$timestamp [$Level]"
            Add-Content -Path $logPath -Value $fileLine
        } catch { Write-Warning "Write-Log: failed to write to install.log : $($_.Exception.Message)" }
        return
    }

    # scriptblock now accepts explicit params to avoid capturing ambiguous outer variables
    $WriteLine = {
        param(
            [string]$Text,
            [string]$Lvl,
            [string]$Ts,
            [string]$LogFile
        )

        # Host output: no timestamp for INFO/DEBUG; include level prefix for WARN/ERROR
        switch ($Lvl) {
            'ERROR' {
                $hostLine = "[$Lvl] $Text"
                $fileLine = "$Ts [$Lvl] $Text"
                Write-Host $hostLine -ForegroundColor Red
                Write-Error -Message $Text -ErrorAction Continue
            }
            'WARN' {
                $hostLine = "[$Lvl] $Text"
                $fileLine = "$Ts [$Lvl] $Text"
                Write-Host $hostLine -ForegroundColor Yellow
                Write-Warning $Text
            }
            'DEBUG' {
                $hostLine = $Text
                $fileLine = "$Ts [$Lvl] $Text"
                if ($VerbosePreference -ne 'SilentlyContinue') { Write-Host $hostLine -ForegroundColor DarkGray }
            }
            default {
                # INFO and default: no level prefix on host
                $hostLine = $Text
                $fileLine = "$Ts [$Lvl] $Text"
                Write-Host $hostLine
            }
        }

        try { Add-Content -Path $LogFile -Value $fileLine } catch { Write-Warning "Write-Log: failed to write to install.log : $($_.Exception.Message)" }
    }

    if ($Section) {
        $title = $Message
        $sepLen = [Math]::Max(10, ($title.Length + 8))
        $sep = ('=' * $sepLen)
        $center = "  $title  "
        $WriteLine.Invoke('', $Level, $timestamp, $logPath)
        $WriteLine.Invoke($sep, $Level, $timestamp, $logPath)
        $WriteLine.Invoke($center, $Level, $timestamp, $logPath)
        $WriteLine.Invoke($sep, $Level, $timestamp, $logPath)
        $WriteLine.Invoke('', $Level, $timestamp, $logPath)
        return
    }

    # Normal single-line log (use .Invoke() for PS 5.1 compatibility)
    $WriteLine.Invoke($Message, $Level, $timestamp, $logPath)
}