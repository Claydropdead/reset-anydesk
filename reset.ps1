function Show-Banner {
    Clear-Host
    Write-Host @"
    #################################################
    #                                               #
    #     ██████╗██╗      █████╗ ██╗   ██╗          #
    #    ██╔════╝██║     ██╔══██╗╚██╗ ██╔╝          #
    #    ██║     ██║     ███████║ ╚████╔╝           #
    #    ██║     ██║     ██╔══██║  ╚██╔╝            #
    #    ╚██████╗███████╗██║  ██║   ██║             #
    #     ╚═════╝╚══════╝╚═╝  ╚═╝   ╚═╝             #
    #                                               #
    #             ANYDESK ID RESETTER               #
    #################################################
"@ -ForegroundColor Cyan
}

function Reset-AnyDesk {
    Write-Host "`n[!] Stopping AnyDesk services..." -ForegroundColor Yellow
    Stop-Process -Name "AnyDesk" -Force -ErrorAction SilentlyContinue
    Stop-Service -Name "AnyDesk" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    $paths = @(
        @{src="$env:APPDATA\AnyDesk"; dest="$env:APPDATA\AnyDesk\old"},
        @{src="C:\ProgramData\AnyDesk"; dest="C:\ProgramData\AnyDesk\old"}
    )

    foreach ($path in $paths) {
        if (Test-Path $path.src) {
            if (!(Test-Path $path.dest)) { New-Item -ItemType Directory -Path $path.dest -Force | Out-Null }
            
            Get-ChildItem -Path $path.src -Include "service.conf", "system.conf" -File | ForEach-Object {
                Move-Item -Path $_.FullName -Destination $path.dest -Force
                Write-Host "[+] Moved $($_.Name) to backup folder." -ForegroundColor Green
            }
        }
    }
    Write-Host "`n[SUCCESS] AnyDesk ID reset complete!" -ForegroundColor Cyan
    Write-Host "Press any key to return to menu..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Main Loop
do {
    Show-Banner
    Write-Host " [01] Reset AnyDesk ID" -ForegroundColor White
    Write-Host " [00] Exit" -ForegroundColor Red
    Write-Host ""
    $choice = Read-Host "Select an option"

    switch ($choice) {
        "01" { Reset-AnyDesk }
        "00" { exit }
        default { Write-Host "Invalid option, try again." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
