﻿param(
    [string]$ComplianceFile = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Compliance.json"
)

# Ensure the device checks for updates first
Write-Host "Checking for outstanding updates..."
try {
    # Get pending updates using Windows Update status from WMI
    $PendingUpdates = Get-WmiObject -Namespace root\cimv2 -Class Win32_QuickFixEngineering | Where-Object { $_.InstalledOn -eq $null }
    $CurrentDate = Get-Date
    
    # Set compliance flag
    $IsCompliant = $true
    
    if ($PendingUpdates.Count -gt 0) {
        foreach ($Update in $PendingUpdates) {
            $UpdateAge = ($CurrentDate - $Update.HotFixID).Days
            
            if ($UpdateAge -ge 10) {
                $IsCompliant = $false
                Write-Host "Pending update '$($Update.HotFixID)' is $UpdateAge days old. Marking device as noncompliant."
            }
        }
    }
    
    # Output result to Intune compliance log
    $ComplianceResult = @{ "isCompliant" = $IsCompliant }
    $ComplianceResult | ConvertTo-Json | Set-Content -Path $ComplianceFile
    
    # Exit based on compliance
    if ($IsCompliant) {
        Write-Host "Device is compliant."
        exit 0
    } else {
        Write-Host "Device is noncompliant."
        exit 1
    }
} catch {
    Write-Host "Error checking updates: $_"
    exit 1
}
