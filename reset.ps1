# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run PowerShell as Administrator to use this script."
    return
}

# 1. Stop AnyDesk to unlock files
Write-Host "Stopping AnyDesk..." -ForegroundColor Yellow
Stop-Process -Name "AnyDesk" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "AnyDesk" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# 2. Define source and destination folders
$roamingSource = "$env:APPDATA\AnyDesk"
$roamingDestination = "$env:APPDATA\AnyDesk\old"

$programDataSource = "C:\ProgramData\AnyDesk"
$programDataDestination = "C:\ProgramData\AnyDesk\old"

# 3. Create destination folders if they don't exist
if (!(Test-Path $roamingDestination)) {
    New-Item -ItemType Directory -Path $roamingDestination -Force | Out-Null
}
if (!(Test-Path $programDataDestination)) {
    New-Item -ItemType Directory -Path $programDataDestination -Force | Out-Null
}

# 4. Define the files to be moved
$filesToMove = @("service.conf", "system.conf")

# 5. Move files from Roaming
foreach ($file in $filesToMove) {
    $filePath = Join-Path $roamingSource $file
    if (Test-Path $filePath) {
        Move-Item -Path $filePath -Destination $roamingDestination -Force
        Write-Host "Moved $file from Roaming AppData" -ForegroundColor Green
    }
}

# 6. Move files from ProgramData
foreach ($file in $filesToMove) {
    $filePath = Join-Path $programDataSource $file
    if (Test-Path $filePath) {
        Move-Item -Path $filePath -Destination $programDataDestination -Force
        Write-Host "Moved $file from ProgramData" -ForegroundColor Green
    }
}

Write-Host "`nFiles moved successfully! AnyDesk will generate a new ID on next launch." -ForegroundColor Cyan
