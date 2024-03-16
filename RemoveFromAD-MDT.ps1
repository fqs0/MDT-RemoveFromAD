<#
.SYNOPSIS
This script monitors Microsoft Deployment Toolkit (MDT) deployment progress and removes computers from Active Directory upon completion.

.DESCRIPTION
This script is designed to monitor MDT deployment progress by continuously checking the MDT monitoring data. When a deployment is started (DeploymentStatus equals "1"), the script removes the corresponding computer from Active Directory. 
It logs the success or failure of each removal operation to a specified log file.

.PARAMETER LogFile
Specifies the path where the log file will be saved.

.PARAMETER RemoteUsername
Specifies the username for the remote connection.

.PARAMETER RemotePassword
Specifies the password for the remote connection.

.NOTES
- Ensure that the MDT module is installed and accessible at "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1".
- The script requires the Active Directory module for PowerShell.
- The script will continuously monitor the MDT deployment progress until manually stopped.
#>


# Imports MDT module
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "MDT_monitoring" -PSProvider MDTProvider "C:\DeploymentShare\"
$logFile = "C:\RemoveFromAD_logs.log"

# Credentials
$remoteUsername = "UserName"
$remotePassword = ConvertTo-SecureString -String "Password" -AsPlainText -Force
$remoteCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $remoteUsername, $remotePassword


function Remove-HostFromAD {
    param($computerName, $domainCredidential)

    # Import module
    Import-Module ActiveDirectory

    # Get computer object
    $computer = Get-ADComputer -Filter {name -eq $computerName} -Credential $domainCredidential

    # Delete computer with leaf object
    if ($computer){
        Remove-ADObject -Identity $computer.DistinguishedName -Credential $domainCredidential -Recursive -Confirm:$false
        #Save logs
        "$(Get-Date):$computername Success! removed from AD" | Out-File -Append -FilePath $logFile

        return $true
    }
    else {
        #Save logs
        "$(Get-Date):$computername - Failed! not exist in AD" | Out-File -Append -FilePath $logFile

        return $false
    }
}

# Inicialization of list removed hosts
$removedHosts = @()

# Monitoring loop for MDTMonitorData
while ($true) {
    $monitorData = Get-MDTMonitorData -Path "MDT_monitoring:" | Where-Object { $_.DeploymentStatus -eq "1" }

    # Checking if hosts have been found that have started deployment
    if ($monitorData) {
        foreach ($item in $monitorData) {
            $HostName = $item.Name

            # Check if hosts has been already been removed
            if (-not ($removedHosts -contains $HostName)) {
                Write-Host "Selected - $(Get-Date): $HostName"
                $removed = Remove-HostFromAD -computerName $HostName -domainCredidential $remoteCredential

                if ($removed) {
                    # Add host to list as removed
                    $removedHosts += $HostName
                    #Save logs
                    $logMessage = "$(Get-Date):$HostName - Success! added to list as removed" | Out-File -Append -FilePath $logFile
                } else {   
                    #Save logs
                    $removedHosts += $HostName
                    "$(Get-Date):$HostName - Failed! has not been removed" | Out-File -Append -FilePath $logFile
                }
            }
        }
    }

    Start-Sleep -Seconds 60
}
