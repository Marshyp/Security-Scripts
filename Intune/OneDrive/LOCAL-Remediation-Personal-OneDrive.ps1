<#
.SYNOPSIS
  Logs detected Personal OneDrive sync details to a local file.

.DESCRIPTION
  Gathers timestamp, user, device name and synced OneDrive email,
  then appends them to a local log file at C:\Detections\OneDrive.txt.
#>

# Path to the local log file
$logDir  = 'C:\Detections'
$logFile = Join-Path -Path $logDir -ChildPath 'OneDrive.txt'

# Ensure the directory exists
if (-not (Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Read the Personal account email from registry
$regPath   = 'HKCU:\Software\Microsoft\OneDrive\Accounts\Personal'
$userEmail = (Get-ItemProperty -Path $regPath -Name 'UserEmail' -ErrorAction SilentlyContinue).UserEmail

# Build log entry
$timestamp   = (Get-Date).ToUniversalTime().ToString('o')  # Generate ISO TimeStamp
$username    = $env:USERNAME
$hostname    = $env:COMPUTERNAME

$entry = "{0} | User: {1} | Host: {2} | OneDrivePersonal: {3}" -f $timestamp, $username, $hostname, $userEmail

# Append to the log file
Add-Content -Path $logFile -Value $entry
