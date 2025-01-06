# Function to detect if NetBIOS is disabled
function Detect-NetBIOS {
    $tcpipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    $netbtPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces"
    $isDisabled = $true

    # Check NetBIOS in the TCP/IP registry path
    $tcpipAdapters = Get-ChildItem -Path $tcpipPath -ErrorAction SilentlyContinue
    foreach ($adapter in $tcpipAdapters) {
        $value = Get-ItemProperty -Path $adapter.PSPath -Name "NetbiosOptions" -ErrorAction SilentlyContinue
        if ($value.NetbiosOptions -ne 2) {
            $isDisabled = $false
            break
        }
    }

    # Check NetBIOS in the NetBT registry path
    if ($isDisabled) {
        $netbtAdapters = Get-ChildItem -Path $netbtPath -ErrorAction SilentlyContinue
        foreach ($adapter in $netbtAdapters) {
            $value = Get-ItemProperty -Path $adapter.PSPath -Name "NetbiosOptions" -ErrorAction SilentlyContinue
            if ($value.NetbiosOptions -ne 2) {
                $isDisabled = $false
                break
            }
        }
    }

    return $isDisabled
}

# Function to detect if LLMNR is disabled
function Detect-LLMNR {
    try {
        $value = Get-ItemProperty -Path "HKLM:\Software\policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -ErrorAction SilentlyContinue
        return $value.EnableMulticast -eq 0
    } catch {
        return $false
    }
}

# Detection logic
if ((Detect-NetBIOS) -and (Detect-LLMNR)) {
    Write-Output "NetBIOS and LLMNR are both disabled."
    exit 0 # Detection successful
} else {
    Write-Output "NetBIOS and/or LLMNR are not disabled."
    exit 1 # Detection failed
}
