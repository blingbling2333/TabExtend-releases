<#
.SYNOPSIS
  Download, SHA-256 verify, and unpack Open-TabExtend (Chrome extension name: TabNav).

.DESCRIPTION
  Safe for both humans and AI coding agents. Supports in-place upgrades that keep
  the installation path unchanged so Chrome can reload the extension without losing
  local data.

.EXAMPLE
  irm https://raw.githubusercontent.com/blingbling2333/Open-TabExtend/main/scripts/install.ps1 | iex

.EXAMPLE
  .\install.ps1 -Version 0.6.0 -Json
#>
[CmdletBinding()]
param(
  [string]$Dir = $(
    if ($env:TABEXTEND_INSTALL_DIR) {
      $env:TABEXTEND_INSTALL_DIR
    } elseif ((Test-Path (Join-Path $env:LOCALAPPDATA "TabExtend\manifest.json")) -and -not (Test-Path (Join-Path $env:LOCALAPPDATA "Open-TabExtend\manifest.json"))) {
      Join-Path $env:LOCALAPPDATA "TabExtend"
    } else {
      Join-Path $env:LOCALAPPDATA "Open-TabExtend"
    }
  ),
  [string]$Version = "latest",
  [switch]$Json,
  [switch]$Force,
  [switch]$Open
)

$ErrorActionPreference = "Stop"

$Repo = if ($env:TABEXTEND_REPO) { $env:TABEXTEND_REPO } else { "blingbling2333/Open-TabExtend" }
$ApiBase = if ($env:TABEXTEND_API_BASE) { $env:TABEXTEND_API_BASE } else { "https://api.github.com" }
$WebBase = if ($env:TABEXTEND_WEB_BASE) { $env:TABEXTEND_WEB_BASE } else { "https://github.com" }

function Write-Info([string]$Message) {
  if ($Json) {
    [Console]::Error.WriteLine($Message)
  } else {
    Write-Host $Message
  }
}

$ResolvedDir = [System.IO.Path]::GetFullPath($Dir)
$UnsafeDirs = @(
  [System.IO.Path]::GetPathRoot($ResolvedDir).TrimEnd('\'),
  $env:USERPROFILE.TrimEnd('\'),
  $env:LOCALAPPDATA.TrimEnd('\'),
  $env:SystemRoot.TrimEnd('\')
)
if ($UnsafeDirs -contains $ResolvedDir.TrimEnd('\')) {
  throw "Refusing to install directly into unsafe directory: $ResolvedDir"
}

if ($Version -eq "latest") {
  $ApiUrl = "$ApiBase/repos/$Repo/releases/latest"
} else {
  $Tag = if ($Version.StartsWith("v")) { $Version } else { "v$Version" }
  $ApiUrl = "$ApiBase/repos/$Repo/releases/tags/$Tag"
}

$Headers = @{
  "Accept"     = "application/vnd.github+json"
  "User-Agent" = "Open-TabExtend-Installer/1.0"
}
if ($env:GITHUB_TOKEN) {
  $Headers["Authorization"] = "Bearer $($env:GITHUB_TOKEN)"
}

Write-Info "Resolving release metadata for $Repo ($Version) ..."
$TagName = $null
$ReleaseUrl = $null
$ZipName = $null
$ZipUrl = $null
$ShaName = $null
$ShaUrl = $null
$ApiDigest = $null

try {
  $Release = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers
  $ZipAsset = $Release.assets | Where-Object { $_.name -match '^tabnav-v\d+\.\d+\.\d+\.zip$' } | Select-Object -First 1
  if ($ZipAsset) {
    $ShaCandidate = "$($ZipAsset.name).sha256"
    $ShaAsset = $Release.assets | Where-Object { $_.name -eq $ShaCandidate } | Select-Object -First 1
    if ($ShaAsset) {
      $TagName = [string]$Release.tag_name
      $ReleaseUrl = [string]$Release.html_url
      $ZipName = [string]$ZipAsset.name
      $ZipUrl = [string]$ZipAsset.browser_download_url
      $ShaName = [string]$ShaAsset.name
      $ShaUrl = [string]$ShaAsset.browser_download_url
      if ($ZipAsset.digest -and $ZipAsset.digest.StartsWith("sha256:")) {
        $ApiDigest = $ZipAsset.digest.Substring(7).ToLowerInvariant()
      }
    }
  }
} catch {
  Write-Info "GitHub API unavailable or rate-limited; falling back to direct release redirect ..."
}

if (-not $ZipUrl) {
  if ($Version -eq "latest") {
    $Resp = Invoke-WebRequest -Uri "$WebBase/$Repo/releases/latest" -Method Head -MaximumRedirection 5 -Headers @{ "User-Agent" = "Open-TabExtend-Installer/1.0" }
    $FinalUri = if ($Resp.BaseResponse.ResponseUri) { $Resp.BaseResponse.ResponseUri.AbsoluteUri } else { $Resp.BaseResponse.RequestMessage.RequestUri.AbsoluteUri }
    $TagName = ($FinalUri.TrimEnd('/') -split '/')[-1]
  } else {
    $TagName = $Tag
  }
  if ($TagName -notmatch '^v\d+\.\d+\.\d+$') {
    throw "Unexpected release tag resolved from redirect: $TagName"
  }
  $ReleaseUrl = "$WebBase/$Repo/releases/tag/$TagName"
  $ZipName = "tabnav-$TagName.zip"
  $ZipUrl = "$WebBase/$Repo/releases/download/$TagName/$ZipName"
  $ShaName = "$ZipName.sha256"
  $ShaUrl = "$WebBase/$Repo/releases/download/$TagName/$ShaName"
}

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("tabextend-install-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
  $ZipPath = Join-Path $TempDir $ZipName
  $ShaPath = Join-Path $TempDir $ShaName

  Write-Info "Downloading $ZipName ..."
  Invoke-WebRequest -Uri $ZipUrl -Headers @{ "User-Agent" = "Open-TabExtend-Installer/1.0" } -OutFile $ZipPath
  Invoke-WebRequest -Uri $ShaUrl -Headers @{ "User-Agent" = "Open-TabExtend-Installer/1.0" } -OutFile $ShaPath

  $ExpectedSha = ((Get-Content -Path $ShaPath -Raw).Trim() -split '\s+')[0].ToLowerInvariant()
  if ($ExpectedSha.Length -ne 64) {
    throw "Invalid SHA-256 format in $ShaName"
  }

  $ActualSha = (Get-FileHash -Path $ZipPath -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($ActualSha -ne $ExpectedSha) {
    throw "SHA-256 mismatch for ${ZipName}: expected $ExpectedSha, got $ActualSha"
  }
  if ($ApiDigest -and $ActualSha -ne $ApiDigest) {
    throw "GitHub asset digest mismatch for ${ZipName}: expected $ApiDigest, got $ActualSha"
  }
  Write-Info "Verified SHA-256: $ActualSha"

  $UnpackDir = Join-Path $TempDir "unpacked"
  Expand-Archive -Path $ZipPath -DestinationPath $UnpackDir -Force

  $ManifestFile = Get-ChildItem -Path $UnpackDir -Filter "manifest.json" -Recurse -File | Select-Object -First 1
  if (-not $ManifestFile) {
    throw "Archive $ZipName does not contain manifest.json"
  }
  $StageRoot = $ManifestFile.Directory.FullName
  $Manifest = Get-Content -Path $ManifestFile.FullName -Raw | ConvertFrom-Json
  $NewVersion = [string]$Manifest.version
  $ExtensionName = if ($Manifest.name) { [string]$Manifest.name } else { "TabNav" }

  $Action = "install"
  $PreviousVersion = $null
  $ExistingManifest = Join-Path $ResolvedDir "manifest.json"

  if (Test-Path -Path $ResolvedDir) {
    if (Test-Path -Path $ExistingManifest) {
      $Action = "upgrade"
      $PreviousVersion = [string](Get-Content -Path $ExistingManifest -Raw | ConvertFrom-Json).version
    } elseif ((Get-ChildItem -Path $ResolvedDir -Force | Measure-Object).Count -gt 0 -and -not $Force) {
      throw "Target directory '$ResolvedDir' is non-empty and does not contain manifest.json. Pass -Dir <empty-path> or -Force."
    }
  } else {
    New-Item -ItemType Directory -Path $ResolvedDir -Force | Out-Null
  }

  Get-ChildItem -Path $ResolvedDir -Force | Remove-Item -Recurse -Force
  Copy-Item -Path (Join-Path $StageRoot "*") -Destination $ResolvedDir -Recurse -Force

  if (-not (Test-Path -Path (Join-Path $ResolvedDir "manifest.json"))) {
    throw "Installation verification failed: manifest.json missing after copy"
  }

  if ($Open) {
    Start-Process explorer.exe $ResolvedDir
  }

  $NextStep = if ($Action -eq "upgrade") {
    "Open chrome://extensions and click the Reload button on the '$ExtensionName' extension card. No need to uninstall."
  } else {
    "Open chrome://extensions, enable Developer mode, click 'Load unpacked', and select: $ResolvedDir"
  }

  if ($Json) {
    [ordered]@{
      status          = "ok"
      action          = $Action
      repository      = $Repo
      tag             = $TagName
      version         = $NewVersion
      previousVersion = $PreviousVersion
      extensionName   = $ExtensionName
      archive         = $ZipName
      sha256          = $ActualSha
      sha256Verified  = $true
      installDir      = $ResolvedDir
      manifestPath    = (Join-Path $ResolvedDir "manifest.json")
      releaseUrl      = $ReleaseUrl
      nextStep        = $NextStep
    } | ConvertTo-Json -Depth 4
  } else {
    Write-Host ""
    Write-Host "Open-TabExtend $TagName ($Action) ready!"
    Write-Host "  Extension name : $ExtensionName"
    if ($PreviousVersion) {
      Write-Host "  Version        : $NewVersion (upgraded from $PreviousVersion)"
    } else {
      Write-Host "  Version        : $NewVersion"
    }
    Write-Host "  SHA-256        : $ActualSha (verified)"
    Write-Host "  Install folder : $ResolvedDir"
    Write-Host ""
    Write-Host "Next step in Chrome:"
    Write-Host "  $NextStep"
  }
} finally {
  if (Test-Path -Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}
