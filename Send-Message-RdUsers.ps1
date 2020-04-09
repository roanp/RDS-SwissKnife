

<# 

.SYNOPSIS 
Send messages to all logged users 

.DESCRIPTION 
Sometimes you need to message your users about maintanence tasks or to logout from one node whilst you have the node draines.

.PARAMETER Path 

.EXAMPLE 
Send-Message-RdUsers.ps1 -Server HOST -MessageTitle "Urgent Maintanance" -Message "This server is going under maintanence, please logout from your session"

.NOTES
  Author: Roan Paes
  Company: Vigilant.IT
  CreationDate: 09/04/2020
  LastUpdated: 09/04/2020
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $false)][string]$Server,
    [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $false)][string]$MessageTitle,
    [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $false)][string]$Message
    


)

if (!(Get-Command -Module RemoteDesktop)) {

    Write-Host "Importing modules"
    Import-Module  RemoteDesktop
}



$Servers = @(
    $Server
)
foreach ($x in $servers) {
    Write-Host "Sending Message"
    Send-RDUserMessage -HostServer $x -MessageTitle $MessageTitle -MessageBody $Message
}