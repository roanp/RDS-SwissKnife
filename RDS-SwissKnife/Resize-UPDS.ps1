<# 

.SYNOPSIS 
Resize the  user profile disk 

.DESCRIPTION 
Every now and them as a sysadmin you should reclaim unused space from the UPD localtio

.PARAMETER Path 

.EXAMPLE 
Resize-UPD.ps1 -Path \\server\profiles$ -LargerThan 4GB

.NOTES
  Author: Roan Paes
  Company: Vigilant.IT
  CreationDate: 07/04/2020
  LastUpdated: 20/04/2020
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $false)][string]$Path,
    [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $false)][string]$LargerThan

)

#logs don't lie 
$logPath = "$ENV:ProgramData\$client\Logs"
$logFile = "$logPath\Resize-UPD.log"

Start-Transcript -Path "$logFile" -Force

#by default it will resize any VHD larger than 4GB
if (!($LargerThan)) {

    $LargerThan = "4GB"
    
}
    



#region a funcion that checks for files that are not being in use. Credits for https://mcpmag.com/

Function Test-IsFileLocked {
    [cmdletbinding()]
    Param (
        [parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [Alias('FullName', 'PSPath')]
        [string[]]$Path
    )
    Process {
        ForEach ($Item in $Path) {
            #Ensure this is a full path
            $Item = Convert-Path $Item
            #Verify that this is a file and not a directory
            If ([System.IO.File]::Exists($Item)) {
                Try {
                    $FileStream = [System.IO.File]::Open($Item, 'Open', 'Write')
                    $FileStream.Close()
                    $FileStream.Dispose()
                    $IsLocked = $False
                }
                Catch [System.UnauthorizedAccessException] {
                    $IsLocked = 'AccessDenied'
                }
                Catch {
                    $IsLocked = $True
                }
                [pscustomobject]@{
                    File     = $Item
                    IsLocked = $IsLocked
                }
            }
        }
    }
}

#endregion



$Upds = Get-ChildItem -Path $path | where-object { $_.Length -gt $LargerThan } | Test-IsFileLocked | Where-Object { $_.isLocked -like "False" }



if ($Upds.Count -gt 1) { 

    Write-Host  "There are" $Upds.Count "to be resized"

    foreach ($upd in $Upds) {


        $Disk = $Upd.File


        try {

            $VHD = mount-vhd $Disk -PassThru | Get-Disk | Get-Partition | Get-Volume
            $size = Get-PartitionSupportedSize -DriveLetter $VHD.DriveLetter
            Resize-Partition -DriveLetter $VHD.DriveLetter -Size $size.SizeMin
            Dismount-VHD $Disk
            Resize-VHD  $Disk -ToMinimumSize	
            Optimize-vhd -path $Disk  -mode full

        } 

        catch {
            Write-Host "Issue Reducing the disk to its minumum size $Disk  ."
            Write-Warning $_.Exception.Message
        }


        try {

            Resize-VHD  $Disk -SizeBytes 100GB
            $VHD = mount-vhd $Disk -PassThru | Get-Disk | Get-Partition | Get-Volume
               $size = Get-PartitionSupportedSize -DriveLetter $VHD.DriveLetter
                Resize-Partition -DriveLetter $VHD.DriveLetter -Size $size.SizeMax
                Dismount-VHD $Disk
    

        } 

        catch {
            Write-Host "Issue Resizing the disk | When bringing the disk back to normal size $Disk  ."
            Write-Warning $_.Exception.Message
        }


      


    }

}
else { 


    Write-Output "There are " $Upds.Count "UPD to be resized"

}

Stop-Transcript