New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name "disabledomaincreds" -Value 1 -PropertyType "Dword" -Force -ea SilentlyContinue
