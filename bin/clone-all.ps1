# Clone every Appliceo repo as a sibling of this dev-stack repo.
# Idempotent: skips repos that already exist; copies .env.example -> .env if missing.
# Usage:  pwsh bin/clone-all.ps1 [-WithMobile] [-Proto ssh|https]
[CmdletBinding()]
param(
  [switch]$WithMobile,
  [ValidateSet('ssh','https')][string]$Proto = 'ssh'
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $PSCommandPath
$Root      = Split-Path -Parent $ScriptDir

# (dir, github-repo-name) pairs
$CoreRepos = @(
  @{ Dir='api';          Repo='api' },
  @{ Dir='ui';           Repo='ui' },
  @{ Dir='lease-config'; Repo='lease-config' },
  @{ Dir='lease-editor'; Repo='lease-editor' },
  @{ Dir='docuceo';      Repo='docuceo' },
  @{ Dir='appliceo-php'; Repo='appliceo-php' }
)
$MobileRepos = @(
  @{ Dir='lease-editor-native'; Repo='lease-editor-native' },
  @{ Dir='EtatDesLieux';        Repo='etat-des-lieux' }
)

$Repos = $CoreRepos
if ($WithMobile) { $Repos = $Repos + $MobileRepos }

function Get-RepoUrl {
  param([string]$Name)
  if ($Proto -eq 'ssh') { "git@github.com:appliceo/$Name.git" } else { "https://github.com/appliceo/$Name.git" }
}

function Clone-One {
  param([string]$Dir, [string]$Repo)
  $target = Join-Path $Root $Dir
  if (Test-Path (Join-Path $target '.git')) {
    Write-Host "[skip] $Dir already cloned"
    return
  }
  $url = Get-RepoUrl -Name $Repo
  Write-Host "[clone] $Dir <- $url"
  git clone $url $target
}

function Seed-Env {
  param([string]$Dir)
  $target  = Join-Path $Root $Dir
  $example = Join-Path $target '.env.example'
  $env     = Join-Path $target '.env'
  if ((Test-Path $example) -and -not (Test-Path $env)) {
    Copy-Item $example $env
    Write-Host "[env] $Dir/.env <- .env.example"
  }
}

foreach ($r in $Repos) {
  Clone-One -Dir $r.Dir -Repo $r.Repo
  Seed-Env  -Dir $r.Dir
}

# Root .env (compose-only)
$rootEnvExample = Join-Path $Root '.env.docker.example'
$rootEnv        = Join-Path $Root '.env'
if ((Test-Path $rootEnvExample) -and -not (Test-Path $rootEnv)) {
  Copy-Item $rootEnvExample $rootEnv
  Write-Host "[env] .env <- .env.docker.example"
}

Write-Host ""
Write-Host "Done. Next:"
Write-Host "  cd $Root"
Write-Host "  docker compose up --build"
