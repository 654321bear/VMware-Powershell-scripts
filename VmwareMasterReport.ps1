Import-Module VMware.VimAutomation.Core
#Add-PSSnapin VMware.VimAutomation.Core
#Set-PowerCLIConfiguration -DefaultVIServerMode multiple -Confirm:$false

#Connect to all Vmware Environments
Connect-VIServer -Server PROD-vcenter 
Connect-VIServer -Server NV-vcenter

#Set Date variable
$a = date

#Initialise Array
$Report = @()
$DSReport = @()
$DescOutput = @()
$Outtofile = @()

#--------------------------------------------------------VM DESCRIPTION SECTION-------------------------------------------------------
New-VIProperty -Name ToolsVersionStatus -ObjectType VirtualMachine -ValueFromExtensionProperty 'Guest.ToolsVersionStatus' -Force
New-VIProperty -Name ToolsVersion -ObjectType VirtualMachine -ValueFromExtensionProperty 'Config.tools.ToolsVersion' -Force

        Get-VM | Sort Name | where-object {($_.powerstate -ne "PoweredOff")} | %{ 
            $data = "" | select Name, @{Name="IP";Expression={@($_.guest.IPAddress[0])}},@{Name="Cluster";Expression={$_.VMHost.Parent.Name}},Version,ToolsVersion,ToolsVersionStatus,PowerState,@{N="Running OS";E={$_.Guest.OSFullName}},Description
            $data.Name = $_.Name
            $data.IP = $_.guest.ipaddress[0]
            $data.Cluster = $_.VMHost.Parent.Name
            $data.PowerState = $_.PowerState
            $data.Version = $_.Version
            $data.ToolsVersion = $_.ToolsVersion
            $data.ToolsVersionStatus = $_.ToolsVersionStatus
            $data.'Running OS' = $_.Guest.OSFullName
            $data.Description = $_.Notes -replace "`t|`n|`r"," "
            $DescOutput += $data
             }# End Get-VM

#Create Report File
$VMexport = "VM_Descriptions_" + $a.Month + "_" + $a.Day + "_" + $a.Year + ".csv" 
$DescOutput | Export-Csv C:\temp\$VMexport -NoTypeInformation -UseCulture
echo "Done with VM Description"


#--------------------------------------------------------HOST DESCRIPTION SECTION-------------------------------------------------------
$Hostinfo = @()
$Hostreport = @()

    Get-VMHost | Sort Name | Get-View | %{
    $Hostinfo = "" | Select Name,Type,CPU,MEM #@{Label=“Type“;E={$_.Hardware.SystemInfo.Vendor+ “ “ + $_.Hardware.SystemInfo.Model}},    @{Label=“CPU“;E={“PROC:“ + $_.Hardware.CpuInfo.NumCpuPackages + “ CORES:“ + $_.Hardware.CpuInfo.NumCpuCores + “ MHZ: “ + [math]::round($_.Hardware.CpuInfo.Hz / 1000000, 0)}},    @{Label=“MEM“;E={“” + [math]::round($_.Hardware.MemorySize / 1GB, 0) + “ GB“}}
    $Hostinfo.Name = $_.Name
    $Hostinfo.Type = $_.Hardware.SystemInfo.Vendor + " " + $_.Hardware.SystemInfo.Model
    $Hostinfo.CPU = “PROC:“ + $_.Hardware.CpuInfo.NumCpuPackages + “ CORES:“ + $_.Hardware.CpuInfo.NumCpuCores + “ MHZ: “ + [math]::round($_.Hardware.CpuInfo.Hz / 1000000, 0)
    $Hostinfo.MEM = “” + [math]::round($_.Hardware.MemorySize / 1GB, 0) + “ GB“
    $Hostreport += $Hostinfo

    }
#Create Report File
$Hostexport = "Host_Descriptions_" + $a.Month + "_" + $a.Day + "_" + $a.Year + ".csv" 
$Hostreport | Export-Csv C:\temp\$Hostexport -NoTypeInformation -UseCulture
echo "Done with Host Description"
#--------------------------------------------------------DATASTORE SECTION------------------------------------------------------------


foreach($cluster in Get-Cluster){
    Get-VMHost -Location $cluster | Get-Datastore | Sort Name | %{
        $info = "" | select DataCenter, Cluster, Name, Capacity, Provisioned, Available 
        $info.Datacenter = $_.Datacenter
        $info.Cluster = $cluster.Name
        $info.Name = $_.Name 
        $info.Capacity = [math]::Round($_.capacityMB/1024,2) 
        $info.Provisioned = [math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,2) 
        $info.Available = [math]::Round($info.Capacity - $info.Provisioned,2) 
        $DSReport += $info
    }
}
#Create Report File
$DSexport = "DataStore_Descriptions_" + $a.Month + "_" + $a.Day + "_" + $a.Year + ".csv" 
$DSReport | Export-Csv C:\temp\$DSexport -NoTypeInformation -UseCulture
echo "Done with DataStore"

#--------------------------------------------------------SNAPSHOT SECTION------------------------------------------------------------

		get-vm | Sort Name | get-snapshot | %{
            
			$Snap = {} | Select VM,Name,Created,Description,@{Label="SizeGB";Expression={"{0:N2}" -f $_.SizeGB }},VMHost
			$Snap.VM = $_.vm.name
			$Snap.Name = $_.name
			$Snap.Created = $_.created
			$Snap.Description = $_.description
            $Snap.SizeGB = $_.SizeGB
			$Snap.VMHost = $_.vm.vmhost.name
            $Report += $Snap
            }
#Create Report File
$SNAPexport = "Snapshot_Descriptions_" + $a.Month + "_" + $a.Day + "_" + $a.Year + ".csv" 
$Report | Export-Csv C:\temp\$SNAPexport -NoTypeInformation -UseCulture
echo "Done with Snapshot"

#--------------------------------------------------------REPORT SECTION------------------------------------------------------------
#Global Functions
#This function generates a nice HTML output that uses CSS for style formatting.
function Generate-Report {
	Write-Output "<html><head><title></title><style type=""text/css"">.Error {color:#FF0000;font-weight: bold;}.Title {background: #0077D4;color: #FFFFFF;text-align:center;font-weight: bold;border-collapse: collapse;}.SubTitle {background: #DBDDEC;color: #000000;text-align:center;font-weight: bold;border-collapse: collapse;}.Normal {} .Table{border: 1px solid black;border-collapse: collapse;width: 100%;}</style></head><body>"
                
                #Add VM DESCRIPTION Table
                Write-Output "<table border="1" class="table"><tr class=""Title""><td colspan=""9"">VMware VM Description Report</td></tr><tr class=SubTitle><td>VM</td><td>IP Address </td><td>Cluster</td><td>Powered State</td><td>VM Hardware Version</td><td>VM Tools Version</td><td>VM Tools Status</td><td>OS Version</td><td>Description  </td></tr>"
                Foreach ($Desc in $DescOutput){
					Write-Output "<td>$($Desc.Name)</td><td>$($Desc.IP)</td><td>$($Desc.Cluster)</td><td>$($Desc.PowerState)</td><td>$($Desc.Version)</td><td>$($Desc.ToolsVersion)</td><td>$($Desc.ToolsVersionStatus)</td><td>$($Desc.'Running OS')</td><td>$($Desc.Description -replace "`t|`n|`r"," ")</td></tr> " 
				}
                Write-Output "</table></br>"                
                
                #Add HOST DESCRIPTION Table
                Write-Output "<table border=1 class="table"><tr class=""Title""><td colspan=""4"">VMware Host Description Report</td></tr><tr class=SubTitle><td>Host Name  </td><td>Hardware  </td><td>CPU  </td><td>Memory  </td></tr>"
                Foreach ($H in $Hostreport){
					Write-Output "<td>$($H.Name)</td><td>$($H.Type)</td><td>$($H.CPU)</td><td>$($H.MEM)</td></tr> " 
				}
                Write-Output "</table></br>"                
                
                
                #Add DataStore Table
                Write-Output "<table border=1 class="table"><tr class=""Title""><td colspan=""6"">VMware DataStore Report</td></tr><tr class=SubTitle><td>DataCenter  </td><td>Cluster  </td><td>DataStore Name  </td><td>Capacity  </td><td>Provisioned  </td><td>Available  </td></tr>"
                Foreach ($DS in $DSReport){
					Write-Output "<td>$($DS.Datacenter)</td><td>$($DS.Cluster)</td><td>$($DS.Name)</td><td>$($DS.Capacity)</td><td>$($DS.Provisioned)</td><td>$($DS.Available)</td></tr> " 
				}
                Write-Output "</table></br>"


                #Add Snapshot table
                Write-Output "<table border=1 class="table"><tr class=""Title""><td colspan=""6"">VMware Snaphot Report</td></tr><tr class=SubTitle><td>VM Name  </td><td>Snapshot Name  </td><td>Date Created  </td><td>Description  </td><td>Size  </td><td>Host  </td></tr>"
				Foreach ($snapshot in $report){
					Write-Output "<td>$($snapshot.vm)</td><td>$($snapshot.name)</td><td>$($snapshot.created)</td><td>$($snapshot.description)</td><td>$("{0:N2}" -f $snapshot.SizeGB)" GB"</td><td>$($snapshot.vmhost)</td></tr> " 
				}
                Write-Output "</table>"


        #End Report Table
		Write-Output "</table></body></html>" 
	}
echo "Done with Report"

#--------------------------------------------------------EMAIL REPORT SECTION------------------------------------------------------------
#Generate Master Report File
$MasterExport = "VmwareMaster_" + $a.Month + "_" + $a.Day + "_" + $a.Year + ".html" 
Generate-Report > c:\temp\$MasterExport

#Pause script to let the report finish being generated
Start-Sleep -s 10 

#Create attachments
$Masteratt = new-object Net.Mail.Attachment("C:\temp\" + $MasterExport)
$Hostatt = new-object Net.Mail.Attachment("C:\temp\" + $Hostexport)
$VMatt = new-object Net.Mail.Attachment("C:\temp\" + $VMexport)
$DSatt = new-object Net.Mail.Attachment("C:\temp\" + $DSexport)
$SNAPatt = new-object Net.Mail.Attachment("C:\temp\" + $SNAPexport)

#Generate email and add attachments
	IF ($Report -ne ""){
	$SmtpClient = New-Object system.net.mail.smtpClient
	$SmtpClient.host = "alerts.meritenergy.com"   #Change to a SMTP server in your environment
    $SmtpClient.port = "25"
	$MailMessage = New-Object system.net.mail.mailmessage
	$MailMessage.from = "Vmware.Automation@meritenergy.com"   #Change to email address you want emails to be coming from
	$MailMessage.To.add("john.thompson@meritenergy.com")	#Change to email address you would like to receive emails.
    #$MailMessage.To.add("DL-DAL-IT System Alerts <DL-DAL-ITSystemAlerts@ALONUSA.com>")	#Change to email address you would like to receive emails.
	$MailMessage.IsBodyHtml = 1
	$MailMessage.Subject = "Master Vmware Report"
	$MailMessage.Body = Generate-Report
    $MailMessage.Attachments.Add($Masteratt)
    $MailMessage.Attachments.Add($Hostatt)
    $MailMessage.Attachments.Add($VMatt)
    $MailMessage.Attachments.Add($DSatt)
    $MailMessage.Attachments.Add($SNAPatt)
	$SmtpClient.Send($MailMessage)}

echo "Done with Email"

#Disconnect from all Vmware Environments
Disconnect-VIServer	PROD-vcenter -confirm:$false


#Delete files after email is sent
$Masteratt.Dispose()
$Hostatt.Dispose()
$VMatt.Dispose()
$DSatt.Dispose()
$SNAPatt.Dispose()
Remove-Item c:\temp\$MasterExport
Remove-Item c:\temp\$Hostexport
Remove-Item c:\temp\$VMexport
Remove-Item c:\temp\$DSexport
Remove-Item c:\temp\$SNAPexport

echo "Deleted files"
echo "Finished"