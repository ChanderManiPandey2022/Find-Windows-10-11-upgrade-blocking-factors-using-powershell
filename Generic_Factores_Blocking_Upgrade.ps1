<#
.SYNOPSIS
  <#finding Generic Name Blocking Upgrade Using PowerShell>
.DESCRIPTION
  <#finding Generic Name Blocking Upgrade Using PowerShell>
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
 #Check for C:\$WINDOWS.~BT\Sources\Panther path existence
$SourcesPath = 'C:\$WINDOWS.~BT\Sources\Panther'
$PathExists = Test-Path $SourcesPath

If ($PathExists -eq $True) 
{
    $SearchDirectory = "$SourcesPath\compat*.xml"
    $CompatibilityFiles = Get-ChildItem $SearchDirectory | Sort-Object LastWriteTime -Descending
    $BlockingApplications = @()

    Foreach ($File in $CompatibilityFiles)
    {
        $XMLContent = [xml]::new()
        $XMLContent.Load($File)
        $HardBlockList = $XMLContent.CompatReport.Hardware.HardwareItem | Where-Object {$_.InnerXml -match 'BlockingType="Hard"'}

        If ($HardBlockList)
        {
            Foreach ($Block in $HardBlockList)
            {
                $FileDuration = (Get-Date).ToUniversalTime() - $File.LastWriteTimeUTC
                $BlockingApplications += [pscustomobject]@{
                    LastWriteTimeUTC = $File.LastWriteTimeUTC
                    FileDuration = "$($FileDuration.Days) days $($FileDuration.Hours) hours $($FileDuration.Minutes) minutes"
                    ApplicationTitle = $Block.CompatibilityInfo.Title
                    Message = $Block.CompatibilityInfo.Message
                    MSResolutionLink = $Block.Link.Target
                }
            }
        }
    }

    If ($BlockingApplications)
    {
        $Result = "ApplicationTitle = " + $BlockingApplications.ApplicationTitle + " Because " + $BlockingApplications.Message + " Please check MSResolutionLink for troubleshooting = " + $BlockingApplications.MSResolutionLink + " , CompatXmlFileDuration = " + $BlockingApplications.FileDuration
        Write-Output $Result
    }
    Else
    {
        Write-Host "No hard blockers found"
    }
}
Else
{
    Write-Host "$SourcesPath does not exist."
}
