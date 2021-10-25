Import-Module VMware.VimAutomation.Core
#Set-PowerCLIConfiguration -DefaultVIServerMode multiple -Confirm:$false

#Connect to all Vmware Environments
Connect-VIServer -Server vcenter 


#Get-VM | Where { $_.VMHost -eq "<VM_HOSTNAME>" -or $_.VMHost -eq "<VM_HOSTNAME>" -and $_.PowerState -eq "PoweredOn"}| 

Get-VM | Where { $_.name -eq "<COMPUTER>" -or $_.name -eq "<COMPUTER>"  -or $_.name -eq "<COMPUTER>"  -or $_.name -eq "<COMPUTER>"  -or $_.name -eq "<COMPUTER>"  -or $_.name -eq "<COMPUTER>"  -or $_.name -eq "<COMPUTER>" -or $_.name -eq "<COMPUTER>" -or $_.name -eq "<COMPUTER>" -or $_.name -eq "<COMPUTER>" }| 
Select Name, VMHost, NumCpu, MemoryMB,
 @{N="Cpu.UsageMhz.Average";E={[Math]::Round((($_ |Get-Stat -Stat cpu.usagemhz.average -Start (Get-Date).AddHours(-24)-IntervalMins 5 -MaxSamples (84) |Measure-Object Value -Average).Average),2)}},
 @{N="Mem.Usage.Average";E={[Math]::Round((($_ |Get-Stat -Stat mem.usage.average -Start (Get-Date).AddHours(-24)-IntervalMins 5 -MaxSamples (84) |Measure-Object Value -Average).Average),2)}} `
 | Export-Csv c:\Temp\1Day-Stats.csv

 Disconnect-VIServer vcenter  -confirm:$false
