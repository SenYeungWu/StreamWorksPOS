<#
.SYNOPSIS
    Packages a clean, production-ready distribution zip of the Stream Works application.
.DESCRIPTION
    Archives all application source code, assets, backend services, documentation, tests,
    web runner, and dependency configurations while strictly excluding:
      - Git repositories and version control files (.git, .gitignore, .gitattributes)
      - Build outputs and compiler artifacts (build/, .dart_tool/, .gradle/, .pub/, .pub-cache/)
      - IDE & editor configurations (.idea/, .vscode/, *.iml)
      - Generated Flutter dependency locks & metadata (.flutter-plugins*, .metadata, .packages)
      - Temporary, log, and zip archive files (*.log, *.zip, .DS_Store, Thumbs.db)
.PARAMETER OutputPath
    The destination path for the output zip file. Defaults to "StreamWorks_clean_<timestamp>.zip" in the workspace parent directory.
.EXAMPLE
    .\scripts\zip_app.ps1
.EXAMPLE
    .\scripts\zip_app.ps1 -OutputPath "StreamWorks_release.zip"
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

# Determine Workspace Root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (Test-Path (Join-Path $ScriptDir "..\pubspec.yaml")) {
    $WorkspaceRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
} elseif (Test-Path (Join-Path $PWD.Path "pubspec.yaml")) {
    $WorkspaceRoot = $PWD.Path
} else {
    $WorkspaceRoot = $ScriptDir
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $ParentDir = Split-Path -Parent $WorkspaceRoot
    $OutputPath = Join-Path $ParentDir "StreamWorks_clean_$Timestamp.zip"
} else {
    if (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
        $OutputPath = Join-Path $PWD.Path $OutputPath
    }
    $OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Stream Works - Clean Application Packager" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Workspace Root : $WorkspaceRoot"
Write-Host "Output Zip     : $OutputPath"
Write-Host ""

# Directories to exclude anywhere in relative path
$ExcludedDirs = @(
    ".git",
    ".gradle",
    ".dart_tool",
    ".pub",
    ".pub-cache",
    ".idea",
    ".vscode",
    "build",
    "ios/Pods",
    "ios/.symlinks"
)

# File names to exclude
$ExcludedFileNames = @(
    ".flutter-plugins-dependencies",
    ".flutter-plugins",
    ".packages",
    ".metadata",
    ".gitignore",
    ".gitattributes",
    ".DS_Store",
    "Thumbs.db"
)

# File extensions to exclude
$ExcludedExtensions = @(
    ".zip",
    ".iml",
    ".log",
    ".tmp"
)

# Ensure output directory exists
$OutputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# If destination zip already exists, delete it first
if (Test-Path $OutputPath) {
    Remove-Item -Path $OutputPath -Force
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$ZipArchive = [System.IO.Compression.ZipFile]::Open($OutputPath, [System.IO.Compression.ZipArchiveMode]::Create)

$FilesArchived = 0
$BytesArchived = 0

try {
    # Scan all files recursively
    $AllFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -File -Force

    foreach ($file in $AllFiles) {
        $RelativePath = $file.FullName.Substring($WorkspaceRoot.Length).TrimStart("\", "/")
        $RelativePathNormalized = $RelativePath.Replace("\", "/")

        # Skip if the file is the output zip itself
        if ($file.FullName -eq $OutputPath) {
            continue
        }

        # Check directory exclusions
        $Skip = $false
        foreach ($dir in $ExcludedDirs) {
            $dirNorm = $dir.TrimStart("\", "/").Replace("\", "/")
            if ($RelativePathNormalized -eq $dirNorm -or 
                $RelativePathNormalized.StartsWith("$dirNorm/") -or 
                $RelativePathNormalized.Contains("/$dirNorm/")) {
                $Skip = $true
                break
            }
        }
        if ($Skip) { continue }

        # Check exact file name exclusions
        if ($ExcludedFileNames -contains $file.Name) {
            continue
        }

        # Check file extension exclusions
        if ($ExcludedExtensions -contains $file.Extension.ToLower()) {
            continue
        }

        # Add to zip archive with normalized unix forward-slash paths
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $ZipArchive,
            $file.FullName,
            $RelativePathNormalized,
            [System.IO.Compression.CompressionLevel]::Optimal
        ) | Out-Null

        $FilesArchived++
        $BytesArchived += $file.Length
    }
}
finally {
    $ZipArchive.Dispose()
}

$ZipSize = (Get-Item $OutputPath).Length
$ZipSizeMB = [math]::Round($ZipSize / 1MB, 2)

Write-Host "Packaging Complete!" -ForegroundColor Green
Write-Host "Files Archived : $FilesArchived"
Write-Host "Source Bytes   : $([math]::Round($BytesArchived / 1MB, 2)) MB"
Write-Host "Archive Size   : $ZipSizeMB MB"
Write-Host "Saved to       : $OutputPath" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
