# Create our log location
New-EventLog -LogName MS-Office -Source "Office Updates" -ErrorAction SilentlyContinue
Write-EventLog -LogName MS-Office -Source "Office Updates" -EntryType Information -EventId 001 -Message "Script ran from InTune to hide option to hide option to enable or disable office updates" -ErrorAction SilentlyContinue

# Define the registry key and value name
$regKey = "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate"
$valueName = "hideenabledisableupdates"

# Check if the value exists and is already set to 1
Write-EventLog -LogName MS-Office -Source "Office Updates" -EntryType Information -EventId 001 -Message "Office Updates - Checking for presence of registry value." -ErrorAction SilentlyContinue
if ((Test-Path $regKey) -and (Get-ItemProperty $regKey -Name $valueName -ErrorAction SilentlyContinue).$valueName -eq 1) {
    Write-Host "The value of '$valueName' is already set to 1."
    Write-EventLog -LogName MS-Office -Source "Office Updates" -EntryType Information -EventId 001 -Message "Office Updates - Key already exists and is set correctly." -ErrorAction SilentlyContinue

}
else {
try {
    # Set the value to 1
    Set-ItemProperty -Path $regKey -Name $valueName -Value 1 -Type DWORD -Force
    Write-Host "The value of '$valueName' has been set to 1."
    Write-EventLog -LogName MS-Office -Source "Office Updates" -EntryType Information -EventId 001 -Message "Office Updates - Key did not exist or was not set to 1. We have now set this as expected.." -ErrorAction SilentlyContinue
    
}

catch {
    Write-EventLog -LogName MS-Office -Source "Office Updates" -EntryType Error -EventId 001 -Message "Office Updates - There was an error setting the registry key value!" -ErrorAction SilentlyContinue
    Exit 1
}

}
