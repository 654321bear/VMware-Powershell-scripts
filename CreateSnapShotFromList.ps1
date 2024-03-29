Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server vcenter 

$a = Get-Date
$snapshotName = "BeforePatch_" + $a.Month + "_" + $a.Day + "_" + $a.Year
$snapdescription = "BeforePatch_" + $a.Month + "_" + $a.Day + "_" + $a.Year
$vmlist = Get-Content C:\temp\Servers.txt
foreach($VM in $VMlist) {    New-Snapshot -VM $vm -Name $snapshotName -Description $snapdescription
 }
Disconnect-VIServer -Confirm:$false  