Import-Module VMware.VimAutomation.Core
#Set-PowerCLIConfiguration -DefaultVIServerMode multiple -Confirm:$false

#Connect to all Vmware Environments
Connect-VIServer -Server PROD-vcenter 
#Connect-VIServer -Server NV-vcenter

Get-VM | Where { $_.name -eq "vdev-dwd-aci" -or $_.name -eq "vdev-MD1-ACI"  -or $_.name -eq "vprod-dwp-aci"  -or $_.name -eq "vprod-MP1-ACI"  -or $_.name -eq "vprod-MP1-AS1"  -or $_.name -eq "vprod-MP1-AS2"  -or $_.name -eq "vprod-SMP-ACI" -or $_.name -eq "vqa-MQ1-ACI" -or $_.name -eq "vqa-MQ1-AS1" -or $_.name -eq "vqa-MQ1-AS2" }| 
Select Name, VMHost, NumCpu, MemoryMB,
 @{N="Cpu.UsageMhz.Average";E={[Math]::Round((($_ |Get-Stat -Stat cpu.usagemhz.average -Start (Get-Date).AddHours(-24)-IntervalMins 5 -MaxSamples (84) |Measure-Object Value -Average).Average),2)}},
 @{N="Mem.Usage.Average";E={[Math]::Round((($_ |Get-Stat -Stat mem.usage.average -Start (Get-Date).AddHours(-24)-IntervalMins 5 -MaxSamples (84) |Measure-Object Value -Average).Average),2)}} `
 | Export-Csv c:\Temp\1Day-Stats.csv

 Disconnect-VIServer PROD-vcenter  -confirm:$false
