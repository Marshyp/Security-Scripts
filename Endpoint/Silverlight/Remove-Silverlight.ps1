$Silverlight = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Silverlight" } 

if ($Silverlight -eq $null) {

write-host "Silverlight not detected on this device!" 

}

else {
foreach ($Product in $Silverlight) { 
 
try {
    $Product.Uninstall() 
    write-host "$Product removed from device"
}
catch {
write-host "Failed to remove $Product"
}

} 
}
