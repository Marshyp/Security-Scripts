try {
    # Define the registry path
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"

    # Define the name and value for the registry key
    $registryName = "RequirePrivateStoreOnly"
    $registryValue = 0

    # Check if the registry path exists, create it if it doesn't
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }

    # Set the registry key value
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWord

    Write-Host "Registry key set successfully."
} catch {
    Write-Host "An error occurred: $_"
}
