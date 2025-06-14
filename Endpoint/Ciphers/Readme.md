# Modern TLS 1.2 Cipher Suite Policy for Windows

This PowerShell script configures a secure, modern, and application-compatible cipher suite policy for Windows 10 and 11 systems, specifically targeting **TLS 1.2**. It ensures compatibility with Chromium-based applications (e.g. Discord, Microsoft Teams, Zoom) while excluding legacy or weak cipher suites such as 3DES, NULL, and RC4.

## 🔐 What This Script Does

- Enables a curated list of secure cipher suites under:
  `HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002`
- Prioritizes forward secrecy (ECDHE) and strong encryption (AES-GCM, AES-CBC)
- Avoids legacy or insecure ciphers
- Prompts the user to reboot for changes to take effect

## ✅ Cipher Suites Applied

The script applies the following cipher suites in order of strength and compatibility:
```
TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384
TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256
TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384
TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256
TLS_RSA_WITH_AES_256_GCM_SHA384
TLS_RSA_WITH_AES_128_GCM_SHA256
TLS_RSA_WITH_AES_256_CBC_SHA256
TLS_RSA_WITH_AES_128_CBC_SHA256
```

These are sufficient for modern Windows clients while remaining compatible with most enterprise and cloud services.

## 📌 Usage

1. **Run PowerShell as Administrator**
2. Execute the script
3. When prompted, choose to reboot immediately or later

After reboot, the new cipher suite order will take effect.

## ⚠️ Important Considerations

- **TLS 1.3 is not affected** — Windows manages it internally.
- This policy **overrides the system default cipher order** for TLS 1.2.
- If you later apply Group Policy security baselines or Intune compliance policies, they may overwrite or conflict with this registry key.
- This script does **not** remove any previously defined cipher policies. If you're replacing an old policy, remove it first using the rollback instructions below.

## 🔄 Rollback Instructions

To revert to system defaults:

```powershell
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002" -Name "Functions" -Force
shutdown /r /t 0
```
This will restore the default Windows cipher suite behavior after reboot.

💡 Recommended For
- Users who have hardened Windows TLS settings and run into compatibility issues (e.g. Discord update loops, web errors)
- Enterprise or home environments looking for a balanced mix of security and compatibility
- Power users applying baseline configurations via script instead of Group Policy

🧪 Tested With
- Windows 10 22H2
- Windows 11 23H2+
- Discord
- Microsoft Teams
- Zoom
- Chromium, Edge, Firefox
- Microsoft 365 endpoints
