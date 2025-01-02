## Disable NetBIOS
# Function to disable NetBIOS over TCP/IP via both TCP/IP and NetBT registry paths (Selected both due to inconsistencies in the documentation)
function Disable-NetBIOS {
    # Paths for TCP/IP and NetBT registry settings
    $tcpipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    $netbtPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces"

    # Disable NetBIOS in the TCP/IP registry path
    Write-Host "Disabling NetBIOS in the TCP/IP registry path..." -ForegroundColor Cyan
    $tcpipAdapters = Get-ChildItem -Path $tcpipPath
    foreach ($adapter in $tcpipAdapters) {
        try {
            # Set NetbiosOptions to 2 (Disable NetBIOS over TCP/IP)
            Set-ItemProperty -Path $adapter.PSPath -Name "NetbiosOptions" -Value 2 -ErrorAction SilentlyContinue
            Write-Host "NetBIOS disabled for TCP/IP adapter: $($adapter.PSChildName)" -ForegroundColor Green
        } catch {
            Write-Host "Failed to disable NetBIOS for TCP/IP adapter: $($adapter.PSChildName). Error: $_" -ForegroundColor Red
        }
    }

    # Disable NetBIOS in the NetBT registry path
    Write-Host "Disabling NetBIOS in the NetBT registry path..." -ForegroundColor Cyan
    $netbtAdapters = Get-ChildItem -Path $netbtPath
    foreach ($adapter in $netbtAdapters) {
        try {
            # Set NetbiosOptions to 2 (Disable NetBIOS over TCP/IP)
            Set-ItemProperty -Path $adapter.PSPath -Name "NetbiosOptions" -Value 2 -ErrorAction SilentlyContinue
            Write-Host "NetBIOS disabled for NetBT adapter: $($adapter.PSChildName)" -ForegroundColor Green
        } catch {
            Write-Host "Failed to disable NetBIOS for NetBT adapter: $($adapter.PSChildName). Error: $_" -ForegroundColor Red
        }
    }

    Write-Host "NetBIOS configuration changes applied. A system reboot may be required for changes to take effect." -ForegroundColor Yellow
}

# Execute the function
Disable-NetBIOS

## Disable LLMNR
REG ADD  "HKLM\Software\policies\Microsoft\Windows NT\DNSClient"
REG ADD  "HKLM\Software\policies\Microsoft\Windows NT\DNSClient" /v "EnableMulticast" /t REG_DWORD /d "0" /f
