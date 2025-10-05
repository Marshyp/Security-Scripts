<#
.SYNOPSIS
  ClickFix: Create a REG_SZ value "REX"="REX" under HKCU\...\Explorer\Advanced and log all output.

.DESCRIPTION
  - Requires the script to be deployed via Intune with “Run this script using the logged on credentials” = Yes
#>

#region — Configuration
# Registry target
$RegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$ValueName    = 'DisabledHotKeys'
$ValueData    = 'REX'

Write-Output "========== ClickFix Deployment Started: $(Get-Date -Format o) =========="

Try {
    Write-Output "Ensuring registry path exists: $RegistryPath"
    if (-not (Test-Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
        Write-Output "Created missing key."
    }

    Write-Output "Setting registry value: Name='$ValueName', Data='$ValueData'"
    New-ItemProperty -Path $RegistryPath `
                     -Name $ValueName `
                     -PropertyType String `
                     -Value $ValueData `
                     -Force `
                     -ErrorAction Stop

    Write-Output "✅ Registry value successfully created."
}
Catch {
    Write-Error "❌ Failed to create registry value: $_"
}

Write-Output "========== ClickFix Deployment Finished: $(Get-Date -Format o) =========="
