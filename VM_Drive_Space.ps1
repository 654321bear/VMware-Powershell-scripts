
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server vcenter 

$Output = "VM,Disk,Capacity (MB),Free Space (MB), Percentage Free" + "`n"  
ForEach ($VM in get-vm | where-object {($_.powerstate -ne "PoweredOff") -and ($_.Extensiondata.Guest.ToolsStatus -Match ".*Ok.*")}){
ForEach ($1 in $VM) {
echo $1.name
ForEach ($Drive in $VM.Extensiondata.Guest.Disk) {
 
#$Path = $Drive.DiskPath
 
#Calculations 
$Freespace = [math]::Round($Drive.FreeSpace / 1MB)
$Capacity = [math]::Round($Drive.Capacity/ 1MB)
 
$SpaceOverview = "$Freespace" + "/" + "$capacity" 
$PercentFree = [math]::Round(($FreeSpace)/ ($Capacity) * 100) 

 
#VMs with less space
if ($PercentFree -lt 20) {     
    $Output = $Output + $VM.Name + ","
    #$Output = $Output + $Path + ","
    $Output = $Output + $Capacity + ","
    $OutPut = $Output + $Freespace + ","
    $Output = $Output + $PercentFree + "%" + "`n"  
}
 
} # End ForEach ($Drive in in $VM.Extensiondata.Guest.Disk)
 
} # End ForEach ($VM in Get-VM)
 }
$Output