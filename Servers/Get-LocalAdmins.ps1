invoke-command { 
$members = net localgroup administrators | 
    where {$_ -AND $_ -notmatch "command completed successfully"} | 
    select -skip 4
New-Object PSObject -Property @{ 
    Computername = $env:COMPUTERNAME 
    Group = "Administrators"
    Members=$members
    status = $status
    } 
   } -computer (Get-Content c:\_scripts\LocalAdmins\servers.txt) | 
   Select * -ExcludeProperty RunspaceID | Export-CSV c:\_scripts\LocalAdmins\local_admins.csv -NoTypeInformation
