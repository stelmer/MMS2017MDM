## Provisioining Packages
## https://docs.microsoft.com/en-us/windows/configuration/provisioning-packages/provisioning-powershell

cd C:\Users\sjeso\OneDrive\Documents\Windows Imaging and Configuration Designer (WICD)\MMSDemo1

Get-ProvisioningPackage


$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_Policy_Config01_WiFi02"

# Create a new instance for MDM_Policy_Config01_WiFi02 
New-CimInstance -Namespace $namespaceName -ClassName $className -Property @{ParentID="./Vendor/MSFT/Policy/Config";
                                                                            InstanceID="WiFi";
                                                                            #AllowInternetSharing=1;
                                                                            AllowAutoConnectToWiFiSenseHotspots=0;
                                                                            #WLANScanMode=100
                                                                        }

# Enumerate all instances available for MDM_DeviceStatus_Battery01
$namespaceName = "root\cimv2\mdm\dmmap"
$classname = "MDM_DeviceStatus_Battery01"
Get-CimInstance -Namespace $namespaceName -ClassName $className

# Enumerate all instances available for MMDM_Policy_Config01_WiFi02 
$namespaceName = "root\cimv2\mdm\dmmap"
$classname = "MDM_Policy_Config01_WiFi02 "
Get-CimInstance -Namespace $namespaceName -ClassName $className

# Query instances with matching properties
Get-CimInstance -Namespace $namespaceName -ClassName $className -Filter "InstanceID='WiFi'"

# Modify existing instance
$obj = Get-CimInstance -Namespace $namespaceName -ClassName $className -Filter "InstanceID='WiFi'"
$obj.AllowAutoConnectToWiFiSenseHotspots=1
Set-CimInstance -CimInstance $obj

# Delete existing instance
try
{
    $obj = Get-CimInstance -Namespace $namespaceName -ClassName $className -Filter "InstanceID='WiFi'"
    Remove-CimInstance -CimInstance $obj
}
catch [Exception]
{
    write-host $_ | out-string
}

