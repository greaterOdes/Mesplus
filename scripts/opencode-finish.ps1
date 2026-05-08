param(
  [Parameter(Mandatory = $true)]
  [string]$TaskName,

  [string]$Message = "",

  [switch]$DryRun,

  [switch]$SkipVerify,

  [switch]$AllowMain
)

$ErrorActionPreference = "Stop"

function Invoke-Step {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Command,
    [string]$Description = ""
  )

  if ($Description.Length -gt 0) {
    Write-Host "==> $Description"
  }

  if ($DryRun) {
    Write-Host "DRY RUN: $Command"
    return
  }

  Invoke-Expression $Command
}

function Get-Slug {
  param([Parameter(Mandatory = $true)][string]$Value)

  $slug = $Value.Trim().ToLowerInvariant()
  $slug = $slug -replace '[^a-z0-9]+', '-'
  $slug = $slug.Trim('-')
  if ($slug.Length -eq 0) {
    return "task"
  }
  if ($slug.Length -gt 40) {
    return $slug.Substring(0, 40).Trim('-')
  }
  return $slug
}

function Test-CommandAvailable {
  param([Parameter(Mandatory = $true)][string]$Name)
  return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Assert-NoSecretFiles {
  $blockedPatterns = @(
    '.env',
    '.env.*',
    '*secret*',
    '*credential*',
    '*credentials*',
    '*.pem',
    '*.key',
    'id_rsa',
    'id_ed25519',
    'local.properties'
  )

  $changedFiles = git status --porcelain | ForEach-Object {
    if ($_.Length -ge 4) {
      $_.Substring(3).Trim()
    }
  }

  foreach ($file in $changedFiles) {
    foreach ($pattern in $blockedPatterns) {
      if ($file -like $pattern -or (Split-Path $file -Leaf) -like $pattern) {
        throw "Blocked sensitive file from commit: $file"
      }
    }
  }
}

function Invoke-Verification {
  if ($SkipVerify) {
    Write-Host "==> Verification skipped by -SkipVerify"
    return
  }

  $hvigorCommand = "hvigorw --mode module -p product=default -p module=entry@default assembleHap --analyze=normal --parallel --incremental --daemon"

  if (Test-CommandAvailable "hvigorw") {
    Invoke-Step -Command "cmd /c $hvigorCommand" -Description "Running HarmonyOS build validation"
    return
  }

  if (Test-Path ".\hvigorw.bat") {
    Invoke-Step -Command "cmd /c .\hvigorw.bat --mode module -p product=default -p module=entry@default assembleHap --analyze=normal --parallel --incremental --daemon" -Description "Running HarmonyOS build validation"
    return
  }

  Write-Warning "No hvigorw command found. Run DevEco Studio build validation manually. Use -SkipVerify only when you have verified another way."
}

git rev-parse --is-inside-work-tree | Out-Null

$status = git status --porcelain
if ($status.Length -eq 0) {
  Write-Host "No changes to commit."
  exit 0
}

Assert-NoSecretFiles
Invoke-Verification

$currentBranch = (git branch --show-current).Trim()
if ($currentBranch.Length -eq 0) {
  throw "Detached HEAD is not supported. Checkout a branch first."
}

if (($currentBranch -eq "main" -or $currentBranch -eq "master") -and -not $AllowMain) {
  $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
  $branchName = "opencode/$timestamp-$(Get-Slug $TaskName)"
  Invoke-Step -Command "git switch -c `"$branchName`"" -Description "Creating feature branch $branchName"
} else {
  $branchName = $currentBranch
}

if ($Message.Trim().Length -eq 0) {
  $Message = "chore: $TaskName"
}

Invoke-Step -Command "git add -A" -Description "Staging changes"

if ($DryRun) {
  Invoke-Step -Command "git commit -m `"$Message`"" -Description "Creating commit"
  Invoke-Step -Command "git push -u origin `"$branchName`"" -Description "Pushing branch to origin"
  Write-Host "DRY RUN complete. Planned branch: $branchName"
  exit 0
}

$staged = git diff --cached --name-only
if ($staged.Length -eq 0) {
  Write-Host "No staged changes to commit."
  exit 0
}

Invoke-Step -Command "git commit -m `"$Message`"" -Description "Creating commit"
Invoke-Step -Command "git push -u origin `"$branchName`"" -Description "Pushing branch to origin"

Write-Host "Pushed branch: $branchName"
Write-Host "Remote: origin"
