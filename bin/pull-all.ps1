# Pull every Appliceo repo (this dev-stack + all sibling projects).
# Skips repos with uncommitted changes or detached HEAD; reports them.
# Uses --ff-only so divergent histories don't get merged/rebased silently.
# Usage:  pwsh bin/pull-all.ps1 [-WithMobile]
[CmdletBinding()]
param(
  [switch]$WithMobile
)

$ErrorActionPreference = 'Continue'
$ScriptDir = Split-Path -Parent $PSCommandPath
$Root      = Split-Path -Parent $ScriptDir

$CoreDirs   = @('.', 'api', 'ui', 'lease-config', 'lease-editor', 'docuceo', 'appliceo-php')
$MobileDirs = @('lease-editor-native', 'EtatDesLieux')
$Dirs       = if ($WithMobile) { $CoreDirs + $MobileDirs } else { $CoreDirs }

$Failed = @()

function Pull-One {
  param([string]$Rel)
  $target = if ($Rel -eq '.') { $Root } else { Join-Path $Root $Rel }
  $label  = if ($Rel -eq '.') { '(dev-stack)' } else { $Rel }

  if (-not (Test-Path (Join-Path $target '.git'))) {
    Write-Host "[skip] $label  — not a git repo"
    return
  }

  $branch = (git -C $target branch --show-current 2>$null).Trim()
  if (-not $branch) {
    Write-Host "[skip] $label  — detached HEAD"
    $script:Failed += $label
    return
  }

  git -C $target diff --quiet
  $hasWorktreeChanges = $LASTEXITCODE -ne 0
  git -C $target diff --cached --quiet
  $hasIndexChanges = $LASTEXITCODE -ne 0
  if ($hasWorktreeChanges -or $hasIndexChanges) {
    Write-Host "[skip] $label  — uncommitted changes (branch: $branch)"
    $script:Failed += $label
    return
  }

  Write-Host "[pull] $label  ($branch)"
  git -C $target pull --ff-only --quiet
  if ($LASTEXITCODE -ne 0) {
    Write-Host "[fail] $label  — pull rejected (diverged or no upstream?)"
    $script:Failed += $label
  }
}

foreach ($d in $Dirs) { Pull-One -Rel $d }

if ($Failed.Count -gt 0) {
  Write-Host ""
  Write-Host "Some repos need attention: $($Failed -join ' ')"
  exit 1
}
Write-Host ""
Write-Host "All in sync."
