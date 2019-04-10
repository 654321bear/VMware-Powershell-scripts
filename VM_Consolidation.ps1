Add-PSSnapin VMware.VimAutomation.Core
Set-PowerCLIConfiguration -DefaultVIServerMode multiple -Confirm:$false

#Connect to all Vmware Environments
Connect-VIServer -Server ALNS0080 

Get-VM |
Where-Object {$_.Extensiondata.Runtime.ConsolidationNeeded} |
ForEach-Object {
    Write-host $_
    $_.ExtensionData.ConsolidateVMDisks()
}