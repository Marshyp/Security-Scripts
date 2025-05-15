<#
.SYNOPSIS
  Logs detected Personal OneDrive sync details to Azure Log Analytics.

.DESCRIPTION
  Gathers timestamp, user, device name and synced OneDrive email, 
  then posts them via the Data Collector API to your Log Analytics Workspace.
#>

#region === USER CONFIGURATION ===
# Replace these with your workspace details
$WorkspaceID = "<Your-Workspace-ID-GUID>"
$SharedKey   = "<Your-Primary-or-Secondary-Key (Base64)>"
$LogType     = "OneDrivePersonalSync"   # Custom log name (no spaces)
#endregion

function Send-LogAnalyticsData {
    param(
        [string]$workspaceId,
        [string]$sharedKey,
        [string]$logType,
        [PSObject]$record
    )

    # Prepare JSON payload
    $body = $record | ConvertTo-Json -Depth 4
    $contentLength = $body.Length

    # Timestamp
    $TimeStamp = (Get-Date).ToUniversalTime().ToString("r")

    # Build signature as per Data Collector API
    $stringToHash = "POST`n$contentLength`napplication/json`nx-ms-date:$TimeStamp`n/api/logs"
    $bytesToHash   = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes      = [Convert]::FromBase64String($sharedKey)
    $hasher        = New-Object System.Security.Cryptography.HMACSHA256
    $hasher.Key    = $keyBytes
    $signature     = [Convert]::ToBase64String($hasher.ComputeHash($bytesToHash))
    $authHeader    = "SharedKey $workspaceId:$signature"

    # Headers
    $headers = @{
        "Authorization"      = $authHeader
        "Content-Type"       = "application/json"
        "Log-Type"           = $logType
        "x-ms-date"          = $TimeStamp
        "time-generated-field" = ""   # use server time
    }

    # Endpoint
    $url = "https://$workspaceId.ods.opinsights.azure.com/api/logs?api-version=2016-04-01"

    # Send
    try {
        Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to send log to Log Analytics: $_"
    }
}

#--- Gather detection details ---#
# Read the Personal account email from registry
$regPath = "HKCU:\Software\Microsoft\OneDrive\Accounts\Personal"
$userEmail = (Get-ItemProperty -Path $regPath -Name "UserEmail" -ErrorAction SilentlyContinue).UserEmail

# Build record
$record = [PSCustomObject]@{
    TimeUtc                  = (Get-Date).ToUniversalTime().ToString("o")
    Username                 = $env:USERNAME
    Hostname                 = $env:COMPUTERNAME
    OneDrivePersonalAccount  = $userEmail
}

# Send to Log Analytics
Send-LogAnalyticsData -workspaceId $WorkspaceID `
                      -sharedKey   $SharedKey `
                      -logType     $LogType `
                      -record      $record
