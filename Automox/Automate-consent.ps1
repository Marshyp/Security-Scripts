<#
This script uses the Automox API to automate configuring devices in a certain device group
not to need remote control consent. This is particularly handy for meeting rooms etc. 

Author: Philip Marsh
Version: v1.0.0
Last updated: 13-01-2025
#>


# Define your API key and OrgID
$apiKey = "[yourAPIKey]"
$orgId = "[yourOrgID]"
$groupId = "[YourGroupID]"
$logFilePath = "C:\Scripts\Automox\AutomoxAPICall\Logs.txt"

# Ensure the log file and its directory exist
function Ensure-LogFile {
    param ([string]$path)
    $directory = Split-Path -Path $path -Parent

    # Create directory if it doesn't exist
    if (!(Test-Path -Path $directory)) {
        New-Item -Path $directory -ItemType Directory -Force | Out-Null
    }

    # Create log file if it doesn't exist
    if (!(Test-Path -Path $path)) {
        New-Item -Path $path -ItemType File -Force | Out-Null
    }
}

# Function to write to log with timestamp
function Write-Log {
    param ([string]$logMessage)
    Ensure-LogFile -path $logFilePath
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $logMessage"
    Add-Content -Path $logFilePath -Value $logMessage
}

# Ensure the log file is ready
Ensure-LogFile -path $logFilePath

# Define the first API endpoint
$apiUrl = "https://console.automox.com/api/servers?limit=500&page=0&o=[Legacyorgid]&groupId=$groupId"

# Set up the headers
$headers = @{
    "Authorization" = "Bearer $apiKey"
}

# Make the first API request and log the request
Write-Log "Making API request to fetch device UUIDs from Automox..."
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
    Write-Log "API request successful. Extracting UUIDs..."
} catch {
    Write-Log "Error making GET request: $_"
    exit
}

# Assuming the response contains an array of objects with 'uuid' field
$deviceUuids = $response | Where-Object { $_.uuid } | Select-Object -ExpandProperty uuid

# Log the number of UUIDs retrieved
Write-Log "Retrieved $($deviceUuids.Count) UUID(s) from the initial request."

if ($deviceUuids.Count -eq 0) {
    Write-Log "No UUIDs found, aborting the process."
    exit
}

# Format the device UUIDs for JSON body
$formattedUuids = ($deviceUuids | ForEach-Object { "`"$_`"" }) -join ",`n    "

# Construct the JSON body
$body = @"
{
  "device_uuids": [
    $formattedUuids
  ],
  "config": {
    "bypass_consent": true
  }
}
"@

# Define the second API endpoint for POST request
$secondApiUrl = "https://rc.automox.com/api/config/consent/account/[AccountUUID]/org/${orgId}/device"

# Set up the headers for the POST request, including Content-Type
$postHeaders = @{
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer $apiKey"
}

# Log the POST request preparation
Write-Log "Preparing to make POST request to consent API..."

# Make the POST request and log the response
try {
    $postResponse = Invoke-RestMethod -Uri $secondApiUrl -Headers $postHeaders -Method Post -Body $body
    Write-Log "POST request successful. Response received."
} catch {
    Write-Log "Error making POST request: $_"
    exit
}

# Optionally log the response from the POST request
# Write-Log "POST response: $($postResponse | ConvertTo-Json -Depth 3)"
