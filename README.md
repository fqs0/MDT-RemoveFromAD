# MDT Deployment Monitoring and Active Directory Cleanup Script

This PowerShell script is designed to monitor Microsoft Deployment Toolkit (MDT) deployment progress and remove computers from Active Directory upon completion.

## Features
- Monitors MDT deployment progress by continuously checking the MDT monitoring data.
- Automatically removes computers from Active Directory when deployment is completed.
- Logs the success or failure of each removal operation to a specified log file.
- Solves the problem of adding computers to the domain through MDT by removing old hostnames, which resolves errors when attempting to join the domain due to existing hostnames in the same OU.

## Prerequisites
- Microsoft Deployment Toolkit (MDT) must be installed and accessible at "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1".
- Active Directory PowerShell module must be available.
- Valid credentials with sufficient permissions to remove computers from Active Directory are required.

## Usage
1. Ensure that the prerequisites are met.
2. Modify the script to specify the log file path (`$logFile`), remote username (`$remoteUsername`), and remote password (`$remotePassword`).
3. Run the script using PowerShell.
4. The script will continuously monitor MDT deployment progress and remove completed computers from Active Directory.

## Important Notes
- This script will run indefinitely until manually stopped. Consider setting up scheduled tasks or appropriate monitoring mechanisms.
- Carefully review and test the script in a non-production environment before deploying it in a production environment.
- Removing old hostnames resolves issues with adding computers to the domain through MDT and addresses errors related to existing hostnames in the same OU.