Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -server vcenter 


$vmlist = Get-Content C:\temp\Servers.txt
foreach($VM in $VMlist) {    Get-Snapshot -VM $vm | Remove-Snapshot -confirm:$false
 }
Disconnect-VIServer -Confirm:$false   
