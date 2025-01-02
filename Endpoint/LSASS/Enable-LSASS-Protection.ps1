# Create our log location
New-EventLog -LogName Intune-Deploy -Source "LSASS Protection" -ErrorAction SilentlyContinue
Write-EventLog -LogName Intune-Deploy -Source "LSASS Protection" -EntryType Information -EventId 001 -Message "LSASS Protection - Script ran from InTune." -ErrorAction SilentlyContinue

# Define the registry key and value name
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$valueName = "RunAsPPLBoot"
$ValueName2 = "RunAsPPL"

# Check if the value exists and is already set to 1
Write-EventLog -LogName Intune-Deploy -Source "LSASS Protection" -EntryType Information -EventId 001 -Message "LSASS Protection - Checking for presence of registry value." -ErrorAction SilentlyContinue
if ((Test-Path $regKey) -and (Get-ItemProperty $regKey -Name $valueName -ErrorAction SilentlyContinue).$valueName -eq 1) {
    Write-Host "The value of '$valueName' is already set to 1."
    Write-EventLog -LogName Intune-Deploy -Source "LSASS Protection" -EntryType Information -EventId 001 -Message "LSASS Protection - Key already exists and is set correctly." -ErrorAction SilentlyContinue

}
else {
try {
    # Set the value to 1
    Set-ItemProperty -Path $regKey -Name $valueName -Value 1 -Type DWORD -Force
    Write-Host "The value of '$valueName' has been set to 1."
    Write-EventLog -LogName Intune-Deploy -Source "LSASS Protection" -EntryType Information -EventId 001 -Message "LSASS Protection - Key did not exist or was not set to 1. We have now set this as expected.." -ErrorAction SilentlyContinue
    
}

catch {
    Write-EventLog -LogName Intune-Deploy -Source "LSASS Protection" -EntryType Error -EventId 001 -Message "LSASS Protection - There was an error setting the registry key value!" -ErrorAction SilentlyContinue
    Exit 1
}

}

if ((Test-Path $regKey) -and (Get-ItemProperty $regKey -Name $valueName2 -ErrorAction SilentlyContinue).$valueName2 -eq 1) {
Write-Host "The value of '$valueName' is already set to 1."
    Write-EventLog -LogName Intune-Deploy -Source "LSASS Protection" -EntryType Information -EventId 001 -Message "LSASS Protection - Key already exists and is set correctly." -ErrorAction SilentlyContinue
    }

Else {
try {
    # Enable LSASS!
    Set-ItemProperty -Path $regKey -Name $valueName2 -Value 1 -Type DWORD -Force
    Write-Host "The value of '$valueName2' has been set to 1."
    Write-EventLog -LogName Intune-Deploy -Source "LSASS Protection" -EntryType Information -EventId 001 -Message "LSASS Protection - Key did not exist or was not enabled. We have now set this as expected.." -ErrorAction SilentlyContinue
    
}

catch {
    Write-EventLog -LogName Intune-Deploy -Source "LSASS Protection" -EntryType Error -EventId 001 -Message "LSASS Protection - There was an error setting the registry key value!" -ErrorAction SilentlyContinue
    Exit 1
}

}
