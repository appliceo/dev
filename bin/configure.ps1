# Render every per-project .env file + gestion/config.php from the dev-stack's
# central config (defaults + active profile + local.env).
# Idempotent — re-run any time. Overwrites the rendered files in place.
# Usage:  pwsh bin/configure.ps1 [-Profile full-local|frontends-only|staging] [-Check]
[CmdletBinding()]
param(
  [string]$Profile = 'full-local',
  [switch]$Check
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $PSCommandPath
$Root      = Split-Path -Parent $ScriptDir
$Config    = Join-Path $Root 'config'
$Templates = Join-Path $Config 'templates'

$ProfileFile = Join-Path $Config "profiles/$Profile.env"
if (-not (Test-Path $ProfileFile)) {
  Write-Error "no such profile: $ProfileFile"
}

# Read KEY=VALUE pairs (ignore comments and blanks). Later wins.
function Import-EnvFile {
  param([string]$Path)
  if (-not (Test-Path $Path)) { return }
  Get-Content $Path | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq '' -or $line.StartsWith('#')) { return }
    $idx = $line.IndexOf('=')
    if ($idx -lt 0) { return }
    $k = $line.Substring(0, $idx).Trim()
    $v = $line.Substring($idx + 1)
    Set-Item -Path "Env:$k" -Value $v
  }
}

Import-EnvFile (Join-Path $Config 'defaults.env')
Import-EnvFile $ProfileFile
Import-EnvFile (Join-Path $Config 'local.env')

# Shell-style ${VAR} substitution.
function Expand-Template {
  param([string]$Text)
  return [regex]::Replace($Text, '\$\{([A-Z_][A-Z0-9_]*)\}', {
    param($m)
    $name = $m.Groups[1].Value
    $val = [Environment]::GetEnvironmentVariable($name)
    if ($null -eq $val) { return '' } else { return $val }
  })
}

$Mappings = @(
  @{ Src = "$Templates/dev-stack.env.tmpl";        Dst = "$Root/.env" },
  @{ Src = "$Templates/api.env.tmpl";              Dst = "$Root/api/.env" },
  @{ Src = "$Templates/docuceo.env.tmpl";          Dst = "$Root/docuceo/.env" },
  @{ Src = "$Templates/appliceo-php.env.tmpl";     Dst = "$Root/appliceo-php/.env" },
  @{ Src = "$Templates/gestion-config.php.tmpl";   Dst = "$Root/docker/php/gestion-config.php" }
)

$drift = 0
Write-Host "profile: $Profile"
foreach ($m in $Mappings) {
  if (-not (Test-Path $m.Src)) { Write-Warning "missing template: $($m.Src)"; continue }
  $rendered = Expand-Template (Get-Content $m.Src -Raw)
  if ($Check) {
    if ((Test-Path $m.Dst) -and ((Get-Content $m.Dst -Raw) -eq $rendered)) {
      Write-Host "  [ok]    $($m.Dst)"
    } else {
      Write-Warning "  [drift] $($m.Dst)"; $drift = 1
    }
  } else {
    $dstDir = Split-Path -Parent $m.Dst
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    Set-Content -Path $m.Dst -Value $rendered -NoNewline
    Write-Host "  [write] $($m.Dst)"
  }
}

if ($Check) {
  if ($drift -eq 0) { Write-Host "in sync"; exit 0 } else { exit 1 }
}

Write-Host ""
Write-Host "Done. Run 'docker compose up --build' to apply."
