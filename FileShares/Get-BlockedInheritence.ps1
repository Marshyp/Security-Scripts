$scandir = "<Dir Path to scan>"
$Exportfile = "C:\<Results dir>\Blockedinheritence.csv"

dir $scandir -Directory -recurse | get-acl |
Where {$_.AreAccessRulesProtected} |
Select @{Name="Path";Expression={Convert-Path $_.Path}},AreAccessRulesProtected |
output-csv $Exportfile
