New-EventLog -LogName ForcedUpdate -Source "Update-Office" -ErrorAction SilentlyContinue
Write-EventLog -LogName ForcedUpdate -Source "Update-Office" -EntryType Information -EventId 001 -Message "Office update script from InTune ran successfully." -ErrorAction SilentlyContinue
Start-Process -wait -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList {/c "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" /update user displaylevel=false forceappshutdown=false}
