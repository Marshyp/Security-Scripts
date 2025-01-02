# Edge-Password-Removal.ps1
# This script removes existing Edge passwords, disables password sync for all users, and clears cache and cookies.

# Define registry path and values
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\SyncTypesListDisabled"
$RegistryValueName = "1"
$RegistryValueData = "passwords"

# Ensure the registry path exists
if (-not (Test-Path -Path $RegistryPath)) {
    Write-Host "Creating registry path: $RegistryPath"
    New-Item -Path $RegistryPath -Force | Out-Null
}

# Set the registry value to disable password sync
Write-Host "Disabling Edge password sync via registry for all users."
Set-ItemProperty -Path $RegistryPath -Name $RegistryValueName -Value $RegistryValueData -Type String

# Define the backup directory path
$BackupRootDir = 'C:\Intune-Deploy\Edge'

# Create the root backup directory if it doesn't exist
if (-not (Test-Path -Path $BackupRootDir)) {
    Write-Host "Creating root backup directory: $BackupRootDir"
    New-Item -ItemType Directory -Path $BackupRootDir | Out-Null
}

# Loop until all msedge.exe processes are terminated
do {
    # Get all msedge.exe processes
    $EdgeProcesses = Get-Process -Name 'msedge' -ErrorAction SilentlyContinue

    if ($EdgeProcesses) {
        Write-Host "Killing Edge processes."
        $EdgeProcesses | Stop-Process -Force

        # Give the system a short time to process the termination
        Start-Sleep -Seconds 2
    }

    # Refresh the process list
    $EdgeProcesses = Get-Process -Name 'msedge' -ErrorAction SilentlyContinue
} while ($EdgeProcesses)

Write-Host "All instances of msedge.exe have been successfully terminated."

# Define the base path to user profiles
$UserPath = Join-Path -Path $ENV:SystemDrive -ChildPath 'Users'
$UserProfiles = Get-ChildItem -Path $UserPath -Directory -ErrorAction SilentlyContinue

# Loop through each user profile to find and remove the Edge "Login Data" file
foreach ($UserProfile in $UserProfiles) {
    $EdgeProfilePath = Join-Path -Path $UserProfile.FullName -ChildPath 'AppData\Local\Microsoft\Edge\User Data\'
    $EdgeStateFile = Join-Path $EdgeProfilePath -ChildPath 'Local State'
    $EdgeState = Get-Content -Path $EdgeStateFile -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json

    if ($EdgeState) {
        $EdgeProfiles = $EdgeState.profile.info_cache.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' } | Select-Object -ExpandProperty Name
        foreach ($EdgeProfile in $EdgeProfiles) {
            $EdgeProfilePath = Join-Path -Path $UserProfile.FullName -ChildPath "AppData\Local\Microsoft\Edge\User Data\$EdgeProfile"
            $EdgePasswordFile = Join-Path -Path $EdgeProfilePath -ChildPath 'Login Data'

            if (Test-Path -Path $EdgePasswordFile) {
                # Create a backup subdirectory within the root backup directory
                $UserBackupDir = Join-Path -Path $BackupRootDir -ChildPath $UserProfile.Name
                $ProfileBackupDir = Join-Path -Path $UserBackupDir -ChildPath $EdgeProfile

                if (-not (Test-Path -Path $ProfileBackupDir)) {
                    Write-Host "Creating backup directory: $ProfileBackupDir"
                    New-Item -ItemType Directory -Path $ProfileBackupDir | Out-Null
                }

                # Move the Login Data file to the backup directory
                $BackupFilePath = Join-Path -Path $ProfileBackupDir -ChildPath 'Login Data'
                Write-Host "Backing up and removing password file for user profile: $($UserProfile.Name), Edge profile: $EdgeProfile."
                Move-Item -Force -Path $EdgePasswordFile -Destination $BackupFilePath
            } else {
                Write-Warning "User $($UserProfile.Name) profile $EdgeProfile does not have a password file."
            }
        }
    }

    # Additionally, clear cache and other related data
    $CachePath = Join-Path -Path $UserProfile.FullName -ChildPath 'AppData\Local\Microsoft\Edge\User Data\Default\Cache'
    if (Test-Path -Path $CachePath) {
        Write-Host "Clearing Edge cache for user profile: $($UserProfile.Name)."
        Remove-Item -Recurse -Force -Path $CachePath
    }

    $CookiesPath = Join-Path -Path $UserProfile.FullName -ChildPath 'AppData\Local\Microsoft\Edge\User Data\Default\Cookies'
    if (Test-Path -Path $CookiesPath) {
        Write-Host "Clearing Edge cookies for user profile: $($UserProfile.Name)."
        Remove-Item -Force -Path $CookiesPath
    }
}
