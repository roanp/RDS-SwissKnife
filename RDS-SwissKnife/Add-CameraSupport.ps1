$alias = <collection Alias>
$RDPFileContents = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\CentralPublishedResources\PublishedFarms\$alias\RemoteDesktops\$alias\").RDPFileContents
$RDPFileContents += "camerastoredirect:s:*`n"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\CentralPublishedResources\PublishedFarms\$alias\RemoteDesktops\$alias\" -Name RDPFileContents -Value $RDPFileContents