Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server vcenter 

#Get-VM | Select VMHost,Name, Select-Object -ExpandProperty Notes
#Get-VM | Select VMHost,Name | Select-Object -ExpandProperty Notes | Export-Csv -Path C:\temp\VMsAndHostsInfo.csv -NoTypeInformation -UseCulture
$Output = "Host,VM,Notes" + "`n" 
 
ForEach ($VM in Get-VM){ 
$vhost = $VM.VMHost
$name = $VM.Name

if (($VMNotes = get-vm $VM | Select-Object -ExpandProperty Notes) -ne $null) {
echo $VM.Name
} else {$VMNotes = " "}

$Output = $Output + $vhost, $name, $VMNotes + "`n" 

} # End ForEach ($VM in Get-VM)
 
$Output 
