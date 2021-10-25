#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server vcenter 

# Get VMs with ISO mounted
get-vm | where { $_ | get-cddrive | where { $_.ConnectionState.Connected -eq "true" -and $_.ISOPath -like "*.ISO*"} } | select Name, @{Name=".ISO Path";Expression={(Get-CDDrive $_).isopath }}

# Get the names of VMs with connected CD drives:
get-vm | where { $_ | get-cddrive | where { $_.ConnectionState.Connected -eq "true" } } | select Name