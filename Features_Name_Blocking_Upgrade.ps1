<#
.SYNOPSIS
  <#finding Feature Name Blocking Upgrade Using PowerShell>
.DESCRIPTION
  <#finding Feature Name Blocking Upgrade Using PowerShell>
.Demo
<YouTube video link--> https://www.youtube.com/watch?v=hAVgNvEAdKc
.INPUTS
  <No User Imput Needed>
.NOTES
  Version:        1.0
  Author:         Chander Mani Pandey
  Creation Date:  08 Feb 2023
  Find Author on 
  Youtube:-        https://www.youtube.com/@chandermanipandey8763
  Twitter:-        https://twitter.com/Mani_CMPandey
  Facebook:-       https://www.facebook.com/profile.php?id=100087275409143&mibextid=ZbWKwL
  LinkedIn:-       https://www.linkedin.com/in/chandermanipandey
  Reddit:-         https://www.reddit.com/u/ChanderManiPandey 
 #>

#Check for existence of C:\$WINDOWS.~BT\Sources\Panther path 

$SourceDir = 'C:\$WINDOWS.~BT\Sources\Panther'
$DirExists = Test-Path $SourceDir
If ($DirExists -eq $True) 

{
# Searches the Windows 10 Setup Compatibility logs for upgrade hard blockers

# Find all the compatibility xml files
$SearchPath = 'C:\$WINDOWS.~BT\Sources\Panther'
$XMLFiles = Get-childitem "$SearchPath\compat*.xml" | Sort LastWriteTime -Descending

# Create an array to hold the results
$BlockingData = @()

# Search each file for any hard blockers
Foreach ($XML in $XMLFiles)
{
    $xmlDoc = [xml]::new()
    $xmlDoc.Load($XML)
    $BlockerReports = $xmlDoc.CompatReport.Hardware.HardwareItem | Where {$_.InnerXml -match 'BlockingType="Hard"'}
    If($BlockerReports)
    {
        Foreach ($Blocker in $BlockerReports)
        {
            $FileDuration = (Get-Date).ToUniversalTime() - $XML.LastWriteTimeUTC
            $BlockingData += [pscustomobject]@{
                LastModifiedUTC = $XML.LastWriteTimeUTC
                Duration = "$($FileDuration.Days) days $($FileDuration.hours) hours $($FileDuration.minutes) minutes"
                Type = $Blocker.HardwareType
                Feature = $Blocker.Action.Name
                Status =$Blocker.Action.ResolveState
                InfoLink =$Blocker.Action.link
            }
        }
    }
}

# Report results
If ($BlockingData)
{
   $Output=  "FeatureBlocking_Name = "+ $BlockingData.Type +  ", File_Duration = "+$BlockingData.Duration
   $Output 
    
}
Else
{
    Write-host "No hard blockers found"
}

} Else {Write-Host "$SourceDir Not Exist"}
