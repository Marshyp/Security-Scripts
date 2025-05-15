<#
.SYNOPSIS
  Detects if a Personal OneDrive account is configured for the current user.

.DESCRIPTION
  Checks for the registry key where OneDrive stores Personal account info.
  Exits with code 1 if found (i.e. remediation needed/logging), or 0 otherwise.

#>

# Path to the Personal OneDrive account in HKCU
$regPath = "HKCU:\Software\Microsoft\OneDrive\Accounts\Personal"

if (Test-Path $regPath) {
    # Personal OneDrive is syncing
    Exit 1
}
else {
    # No Personal OneDrive found
    Exit 0
}
