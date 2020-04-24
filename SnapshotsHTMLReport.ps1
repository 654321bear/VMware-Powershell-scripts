@"
===============================================================================
Title: 			Get-VmwareSnaphots.ps1
Description: 	List snapshots on all VMWARE ESX/ESXi servers as well as VM's managed by Virtual Center.
Requirements: 	Windows Powershell and the VI Toolkit
Usage:			.\Get-VmwareSnaphots.ps1
Author: 		Chris Uys
===============================================================================
"@

#Global Functions
#This function generates a nice HTML output that uses CSS for style formatting.
function Generate-Report {
	Write-Output "<html><head><title></title><style type=""text/css"">.Error {color:#FF0000;font-weight: bold;}.Title {background: #0077D4;color: #FFFFFF;text-align:center;font-weight: bold;}.Normal {}</style></head><body><table><tr class=""Title""><td colspan=""6"">VMware Snaphot Report</td></tr><tr class="Title"><td>VM Name  </td><td>Snapshot Name  </td><td>Date Created  </td><td>Description  </td><td>Size  </td><td>Host  </td></tr>"
 
				Foreach ($snapshot in $report){
					Write-Output "<td>$($snapshot.vm)</td><td>$($snapshot.name)</td><td>$($snapshot.created)</td><td>$($snapshot.description)</td><td>$("{0:N2}" -f $snapshot.SizeGB)" GB"</td><td>$($snapshot.vmhost)</td></tr> " 
				}
		Write-Output "</table></body></html>" 
	}

$ServerList = "prod-vcenter"	#Chance to DNS Names/IP addresses of your ESXi servers or Virtual Center Server
#Import-Module -Name VMware.PowerCLI
Import-Module VMware.VimAutomation.Core
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server prod-vcenter 


#Initialise Array
$Report = @()

#Get snapshots from all servers
		foreach ($server in $serverlist){
		get-vm | get-snapshot | %{
            
			$Snap = {} | Select VM,Name,Created,Description,@{Label="SizeGB";Expression={"{0:N2}" -f $_.SizeGB }},VMHost
			$Snap.VM = $_.vm.name
			$Snap.Name = $_.name
			$Snap.Created = $_.created
			$Snap.Description = $_.description
            $Snap.SizeGB = $_.SizeGB
            #echo $Snap.SizeGB
			$Snap.VMHost = $_.vm.vmhost.name
            $Report += $Snap

								}
										}

# Generate the report and email it as a HTML body of an email
Generate-Report > "VmwareSnapshots.html"
	IF ($Report -ne ""){
	$SmtpClient = New-Object system.net.mail.smtpClient
	$SmtpClient.host = ""   #Change to a SMTP server in your environment
	$MailMessage = New-Object system.net.mail.mailmessage
	$MailMessage.from = ""   #Change to email address you want emails to be coming from
	$MailMessage.To.add(")	#Change to email address you would like to receive emails.
    #$MailMessage.To.add("john.thompson@alonusa.com,jehad.alasad@alonusa.com,earl.fischer@alonusa.com")	#Change to email address you would like to receive emails.
	$MailMessage.IsBodyHtml = 1
	$MailMessage.Subject = ""
	$MailMessage.Body = Generate-Report
	$SmtpClient.Send($MailMessage)}

Generate-Report > c:\temp\VmwareSnapshots.html
Disconnect-VIServer	prod-vcenter -confirm:$false
