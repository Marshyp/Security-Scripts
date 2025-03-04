Write-Host "Forcing Windows Update scan..."
try {
    # Trigger Windows Update scan (safe method for Intune)
    Start-Process -FilePath "C:\Windows\System32\UsoClient.exe" -ArgumentList "StartScan" -NoNewWindow -Wait
    Start-Sleep -Seconds 30  # Wait for the scan to complete

    Write-Host "Checking for outstanding updates..."
    
    # Define registry paths where Windows Update stores pending updates
    $PendingRebootPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    $PendingUpdatesPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Updates"
    
    # Default compliance to true
    $PendingRebootCompliance = $true
    $UpdateCompliance = $true
    $CurrentDate = Get-Date

    # Check if the system requires a reboot due to pending updates
    if (Test-Path $PendingRebootPath) {
        Write-Host "Device requires a reboot due to pending updates."
        $PendingRebootCompliance = $false
    }

    # Check for aged updates (older than 10 days)
    if (Test-Path $PendingUpdatesPath) {
        $PendingUpdates = Get-ChildItem -Path $PendingUpdatesPath
        foreach ($Update in $PendingUpdates) {
            # Assume update folder names contain install dates in format YYYYMMDD
            if ($Update.Name -match "\d{8}") {
                $UpdateDate = [datetime]::ParseExact($Update.Name, "yyyyMMdd", $null)
                $UpdateAge = ($CurrentDate - $UpdateDate).Days
                
                if ($UpdateAge -ge 10) {
                    Write-Host "Pending update '$($Update.Name)' is $UpdateAge days old. Marking device as noncompliant."
                    $UpdateCompliance = $false
                }
            }
        }
    }

    # Output compliance status in JSON format
    $result = @{ 
        "PendingRebootCompliance" = $PendingRebootCompliance
        "UpdateCompliance" = $UpdateCompliance
    }
    Write-Output ($result | ConvertTo-Json -Compress)

} catch {
    Write-Host "Error checking updates: $_"
    $result = @{ 
        "PendingRebootCompliance" = $false
        "UpdateCompliance" = $false
    }
    Write-Output ($result | ConvertTo-Json -Compress)
}
