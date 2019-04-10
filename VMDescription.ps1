Add-PSSnapin VMware.VimAutomation.Core
Set-PowerCLIConfiguration -DefaultVIServerMode multiple -Confirm:$false

#Connect to all Vmware Environments
Connect-VIServer -Server ALNS0080 
Connect-VIServer -Server pars0005

#Set Date variable
$a = date

#Initialise Array
$DescOutput = @()


#--------------------------------------------------------VM DESCRIPTION SECTION-------------------------------------------------------
New-VIProperty -Name ToolsVersionStatus -ObjectType VirtualMachine -ValueFromExtensionProperty 'Guest.ToolsVersionStatus' -Force
New-VIProperty -Name ToolsVersion -ObjectType VirtualMachine -ValueFromExtensionProperty 'Config.tools.ToolsVersion' -Force

        Get-VM | Sort Name | where-object {($_.powerstate -ne "PoweredOff")} | %{ # -and ($_.Extensiondata.Guest.ToolsStatus -Match ".*Ok.*")} | %{ 
            $data = "" | select Name,  @{Name="IP";Expression={@($_.guest.IPAddress[0])}},Version,ToolsVersion,ToolsVersionStatus,Description
            $data.Name = $_.Name
            $data.IP = $_.guest.ipaddress[0]
            $data.Version = $_.Version
            $data.ToolsVersion = $_.ToolsVersion
            $data.ToolsVersionStatus = $_.ToolsVersionStatus
            $data.Description = $_.Notes -replace "`t|`n|`r"," "
            $DescOutput += $data
             }# End Get-VM

#Create Report File
$VMexport = "VM_Descriptions_" + $a.Month + "_" + $a.Day + "_" + $a.Year + ".csv" 
$DescOutput | Export-Csv C:\temp\$VMexport -NoTypeInformation -UseCulture
echo "Done with VM Description"