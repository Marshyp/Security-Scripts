# Function to check if the script is running as an administrator
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to get drive letter and GUID of connected USB drives
function Get-USBDrives {
    Get-WmiObject -Query "SELECT * FROM Win32_DiskDrive WHERE InterfaceType='USB'" | 
    ForEach-Object {
        $DriveLetter = (Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='$($_.DeviceID)'} WHERE AssocClass=Win32_DiskDriveToDiskPartition" |
        ForEach-Object {
            Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($_.DeviceID)'} WHERE AssocClass=Win32_LogicalDiskToPartition"
        }).DeviceID

        $DriveLetterWithBackslash = "$DriveLetter\"

        $GUID = (Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter -eq $DriveLetter }).DeviceID

        [PSCustomObject]@{
            DriveLetter = $DriveLetterWithBackslash
            GUID = $GUID
        }
    }
}

# Function to run defender scan on a given drive
function Run-DefenderScan {
    param (
        [string]$DriveLetter
    )

    try {
        $scanResult = Start-MpScan -ScanType CustomScan -ScanPath $DriveLetter
        $detectionStatus = $scanResult.StatusDescription

        return $detectionStatus
    }
    catch {
        if ($_.FullyQualifiedErrorId -eq 'HRESULT 0x80508023,Start-MpScan') {
            Write-Host "Error encountered during scan: HRESULT 0x80508023,Start-MpScan" -ForegroundColor Red
            return $null
        }
        else {
            Write-Host "Error encountered during scan: $_" -ForegroundColor Red
            return "Scan failed"
        }
    }
}

# Function to send email
function Send-Email {
    param (
        [string]$Subject,
        [string]$Body
    )

    $smtpServer = "yourSMTP"
    $smtpFrom = "USBScanning@company.org"
    $smtpTo = "phil@marshsecurity.org"

    $message = New-Object system.net.mail.mailmessage
    $message.from = $smtpFrom
    $message.To.add($smtpTo)
    $message.Subject = $Subject
    $message.Body = $Body

    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    $smtp.Send($message)
}

# Function to get valid user input
function Get-ValidInput {
    param (
        [string]$prompt
    )
    
    while ($true) {
        try {
            $input = Read-Host $prompt
            if (-not [string]::IsNullOrWhiteSpace($input)) {
                return $input
            }
            else {
                throw "Input cannot be empty or whitespace."
            }
        }
        catch {
            Write-Host "Invalid input. Please try again." -ForegroundColor Red
        }
    }
}

# Function to perform scan with retry logic
function Perform-ScanWithRetry {
    param (
        [string]$DriveLetter
    )

    $retryCount = 0
    $maxRetries = 3
    $scanStatus = $null

    while ($retryCount -lt $maxRetries -and $scanStatus -eq $null) {
        $scanStatus = Run-DefenderScan -DriveLetter $DriveLetter
        if ($scanStatus -eq $null) {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-Host "Retrying scan for $DriveLetter ($retryCount/$maxRetries)" -ForegroundColor Yellow
            }
        }
    }

    if ($scanStatus -eq $null) {
        Write-Host "Failed to scan $DriveLetter after $maxRetries attempts." -ForegroundColor Red
    }

    return $scanStatus
}

# Check if the script is running as administrator
if (-not (Test-Admin)) {
    Write-Host "This script must be run as an administrator." -ForegroundColor Red
    exit 1
}

# Get user inputs
$user = Get-ValidInput "Please enter your name"
$ticket = Get-ValidInput "Please enter a ticket reference for the USB being scanned"

# Main script
$usbDrives = Get-USBDrives

foreach ($usbDrive in $usbDrives) {
    $driveLetter = $usbDrive.DriveLetter
    $guid = $usbDrive.GUID
    $scanDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $scanStatus = Perform-ScanWithRetry -DriveLetter $driveLetter

    if ($scanStatus -eq $null) {
        # Scan failed after retries, do not send email
        continue
    }

    if ($scanStatus -eq "No threats detected") {
        $result = "Clean"
    } else {
        $result = "Malicious files detected. Detection details: $scanStatus"
    }

    $subject = "USB Drive Scan Result"
    $body = @"
User: $user
Date/Time of scan: $scanDate
USB GUID: $guid
Scan Result: $result
"@

    Send-Email -Subject $subject -Body $body
}
