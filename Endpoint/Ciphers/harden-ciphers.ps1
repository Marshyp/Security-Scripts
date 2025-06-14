# Ensure you're running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Host "❌ Please run this script as Administrator." -ForegroundColor Red
    exit
}

Write-Host "🔐 Applying modern TLS 1.2 cipher suite policy..." -ForegroundColor Cyan

# Define modern and compatible cipher suites
$modernSuites = @(
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384",
    "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
    "TLS_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_RSA_WITH_AES_256_CBC_SHA256",
    "TLS_RSA_WITH_AES_128_CBC_SHA256"
) -join ','

# Create the policy registry key if it doesn't exist
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002"
New-Item -Path $regPath -Force | Out-Null

# Set the Functions (cipher suite order) value
Set-ItemProperty -Path $regPath -Name "Functions" -Value $modernSuites

Write-Host "`n✅ Cipher suite policy successfully set." -ForegroundColor Green
Write-Host "➡️ Location: HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002"
Write-Host "🛠️ You must reboot for changes to take effect." -ForegroundColor Yellow

# Offer immediate reboot
$choice = Read-Host "`n🔁 Reboot now? (Y/N)"
if ($choice -match '^[Yy]') {
    Write-Host "Rebooting..." -ForegroundColor Cyan
    shutdown /r /t 0
} else {
    Write-Host "⚠️ Please reboot manually to apply changes." -ForegroundColor Yellow
}
