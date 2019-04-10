Import-Module VMware.VimAutomation.Core
Connect-VIServer prod-vcenter
$todayTimestamp = "$([DateTime]::Now.Year)-$([DateTime]::Now.Month)-$([DateTime]::Now.Day)";
$allvms = @()
$vms = Get-VM | Where { $_.name -eq "vdev-dwd-aci" -or $_.name -eq "vdev-MD1-ACI"  -or $_.name -eq "vprod-dwp-aci"  -or $_.name -eq "vprod-MP1-ACI"  -or $_.name -eq "vprod-MP1-AS1"  -or $_.name -eq "vprod-MP1-AS2"  -or $_.name -eq "vprod-SMP-ACI" -or $_.name -eq "vqa-MQ1-ACI" -or $_.name -eq "vqa-MQ1-AS1" -or $_.name -eq "vqa-MQ1-AS2" } 
$hours = (0,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16,-17,-18,-19,-20,-21,-22,-23,-168)
forEach($hour in $hours)
 {
    $stats = Get-Stat -Entity $vms -start (get-date).AddHours($hour-1) -Finish (Get-Date).AddHours($hour) -MaxSamples 10000 -stat "cpu.usage.average","mem.usage.average"
    $stats | Group-Object -Property Entity | %{
    $vmstat = "" | Select VmName, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin, Hour
    $vmstat.VmName = $_.name
 
    $cpu = $_.Group | where {$_.MetricId -eq "cpu.usage.average"} | Measure-Object -Property value -Average -Maximum -Minimum
    $mem = $_.Group | where {$_.MetricId -eq "mem.usage.average"} | Measure-Object -Property value -Average -Maximum -Minimum
    $time = (Get-Date).addHours($hour)
    $vmstat.CPUMax = [int]$cpu.Maximum
    $vmstat.CPUAvg = [int]$cpu.Average
    $vmstat.CPUMin = [int]$cpu.Minimum
    $vmstat.MemMax = [int]$mem.Maximum
    $vmstat.MemAvg = [int]$mem.Average
    $vmstat.MemMin = [int]$mem.Minimum  
    $vmstat.Hour = $time.ToString()
    $vmstat.vmhost = $hour.vmhost
    echo $vmstat
    $allvms += $vmstat
} 



}$allvms | Select VmName, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin, Hour| Export-Csv "c:\temp\Hana_VMs_Stats.csv" -noTypeInformation
Start-Sleep -s 10
#Generate email and add attachments
    $attachment = "c:\temp\Hana_VMs_Stats.csv"

	$SmtpClient = New-Object system.net.mail.smtpClient
	$SmtpClient.host = "alerts.meritenergy.com"   #Change to a SMTP server in your environment
    $SmtpClient.port = "25"
	$MailMessage = New-Object system.net.mail.mailmessage
	$MailMessage.from = "Vmware.Automation@meritenergy.com"   #Change to email address you want emails to be coming from
	$MailMessage.To.add("john.thompson@meritenergy.com")	#Change to email address you would like to receive emails.
	$MailMessage.Subject = "HANA VM Performance stats: $($todayTimestamp)"
	$MailMessage.Body = "HANA VM Performance stats: $($todayTimestamp)"
    $MailMessage.Attachments.Add($attachment)
	$SmtpClient.Send($MailMessage)

echo "Done with Email"
Disconnect-VIServer	PROD-vcenter -confirm:$false
$SmtpClient.dispose()
$MailMessage.Dispose()
Start-Sleep -s 10