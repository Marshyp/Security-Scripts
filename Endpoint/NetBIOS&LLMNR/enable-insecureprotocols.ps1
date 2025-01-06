# Function to enable NetBIOS over TCP/IP via both TCP/IP and NetBT registry paths
function Enable-NetBIOS {
    # Paths for TCP/IP and NetBT registry settings
    $tcpipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    $netbtPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces"

    # Enable NetBIOS in the TCP/IP registry path
    Write-Host "Enabling NetBIOS in the TCP/IP registry path..." -ForegroundColor Cyan
    $tcpipAdapters = Get-ChildItem -Path $tcpipPath
    foreach ($adapter in $tcpipAdapters) {
        try {
            # Set NetbiosOptions to 1 (Enable NetBIOS over TCP/IP)
            Set-ItemProperty -Path $adapter.PSPath -Name "NetbiosOptions" -Value 1 -ErrorAction SilentlyContinue
            Write-Host "NetBIOS enabled for TCP/IP adapter: $($adapter.PSChildName)" -ForegroundColor Green
        } catch {
            Write-Host "Failed to enable NetBIOS for TCP/IP adapter: $($adapter.PSChildName). Error: $_" -ForegroundColor Red
        }
    }

    # Enable NetBIOS in the NetBT registry path
    Write-Host "Enabling NetBIOS in the NetBT registry path..." -ForegroundColor Cyan
    $netbtAdapters = Get-ChildItem -Path $netbtPath
    foreach ($adapter in $netbtAdapters) {
        try {
            # Set NetbiosOptions to 1 (Enable NetBIOS over TCP/IP)
            Set-ItemProperty -Path $adapter.PSPath -Name "NetbiosOptions" -Value 1 -ErrorAction SilentlyContinue
            Write-Host "NetBIOS enabled for NetBT adapter: $($adapter.PSChildName)" -ForegroundColor Green
        } catch {
            Write-Host "Failed to enable NetBIOS for NetBT adapter: $($adapter.PSChildName). Error: $_" -ForegroundColor Red
        }
    }

    Write-Host "NetBIOS configuration changes applied. A system reboot may be required for changes to take effect." -ForegroundColor Yellow
}

# Enable LLMNR
function Enable-LLMNR {
    Write-Host "Enabling LLMNR..." -ForegroundColor Cyan
    try {
        # Set EnableMulticast to 1 (Enable LLMNR)
        REG ADD "HKLM\Software\policies\Microsoft\Windows NT\DNSClient" /v "EnableMulticast" /t REG_DWORD /d "1" /f
        Write-Host "LLMNR enabled successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to enable LLMNR. Error: $_" -ForegroundColor Red
    }
}

# Execute the functions
Enable-NetBIOS
Enable-LLMNR
