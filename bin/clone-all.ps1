# Clone every Appliceo repo as a sibling of this dev-stack repo.
# Idempotent: skips repos that already exist; copies .env.example -> .env if missing.
# For repos with a non-default working branch (appliceo-php uses `develop`),
# the script also ensures the branch is checked out on existing clones.
# Usage:  pwsh bin/clone-all.ps1 [-WithMobile] [-Proto ssh|https]
[CmdletBinding()]
param(
  [switch]$WithMobile,
  [ValidateSet('ssh','https')][string]$Proto = 'ssh'
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $PSCommandPath
$Root      = Split-Path -Parent $ScriptDir

# (Dir, Repo, Branch). Empty branch = remote default. appliceo-php tracks develop.
$CoreRepos = @(
  @{ Dir='api';          Repo='api';          Branch='' },
  @{ Dir='ui';           Repo='ui';           Branch='' },
  @{ Dir='lease-config'; Repo='lease-config'; Branch='' },
  @{ Dir='lease-editor'; Repo='lease-editor'; Branch='' },
  @{ Dir='docuceo';      Repo='docuceo';      Branch='' },
  @{ Dir='appliceo-php'; Repo='appliceo-php'; Branch='develop' }
)
$MobileRepos = @(
  @{ Dir='lease-editor-native'; Repo='lease-editor-native'; Branch='' },
  @{ Dir='EtatDesLieux';        Repo='etat-des-lieux';      Branch='' }
)

$Repos = $CoreRepos
if ($WithMobile) { $Repos = $Repos + $MobileRepos }

function Get-RepoUrl {
  param([string]$Name)
  if ($Proto -eq 'ssh') { "git@github.com:appliceo/$Name.git" } else { "https://github.com/appliceo/$Name.git" }
}

function Clone-One {
  param([string]$Dir, [string]$Repo, [string]$Branch)
  $target = Join-Path $Root $Dir
  if (Test-Path (Join-Path $target '.git')) {
    Write-Host "[skip] $Dir already cloned"
    if ($Branch) {
      $current = (git -C $target branch --show-current).Trim()
      if ($current -ne $Branch) {
        Write-Host "[branch] $Dir: $current -> $Branch"
        git -C $target fetch origin $Branch
        git -C $target checkout $Branch
      }
    }
    return
  }
  $url = Get-RepoUrl -Name $Repo
  $extra = if ($Branch) { " (branch: $Branch)" } else { '' }
  Write-Host "[clone] $Dir <- $url$extra"
  if ($Branch) {
    git clone --branch $Branch $url $target
  } else {
    git clone $url $target
  }
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
  Clone-One -Dir $r.Dir -Repo $r.Repo -Branch $r.Branch
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
