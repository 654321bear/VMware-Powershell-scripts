Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server vcenter 
$ServerList = "vcenter"

$Report = Get-VM | Get-Snapshot | Select VM,Name,Description,@{Label="Size";Expression={"{0:N2} GB" -f ($_.SizeGB)}},Created
If (-not $Report)
{  $Report = New-Object PSObject -Property @{
      VM = "No snapshots found on any VM's controlled by $VIServer"
      Name = ""
      Description = ""
      Size = ""
      Created = ""
   }
}
$Report = $Report | Select VM,Name,Description,Size,Created | ConvertTo-Html -Head $Header -PreContent "<p><h2>Snapshot Report - $VIServer</h2></p><br>" | Set-AlternatingRows -CSSEvenClass even -CSSOddClass odd

# Generate the report and email it as a HTML body of an email
#Generate-Report > "VmwareSnapshots.html"
	IF ($Report -ne ""){
	$SmtpClient = New-Object system.net.mail.smtpClient
	$SmtpClient.host = "smtp.COMPANY.com"   #Change to a SMTP server in your environment
	$MailMessage = New-Object system.net.mail.mailmessage
	$MailMessage.from = "Vmware.Automation@COMPANY.com"   #Change to email address you want emails to be coming from
	$MailMessage.To.add("USER@COMPANY.com")	#Change to email address you would like to receive emails.
	$MailMessage.IsBodyHtml = 1
	$MailMessage.Subject = "Vmware Snapshots (Test Report)"
	$MailMessage.Body = $Report
	$SmtpClient.Send($MailMessage)}

$Report | Out-File c:\temp\VmwareSnapshots.html