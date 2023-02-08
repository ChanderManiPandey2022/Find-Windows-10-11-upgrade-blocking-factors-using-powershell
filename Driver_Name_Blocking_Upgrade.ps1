<#
.SYNOPSIS
  <#finding Driver Name Blocking Upgrade Using PowerShell>
.DESCRIPTION
  <#finding Driver Name Blocking Upgrade Using PowerShell>
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
$Path = 'C:\$WINDOWS.~BT\Sources\Panther'
$Exists = Test-Path $Path

If ($Exists -eq $True) 
{
    # Find all the compatibility XML files
    $SearchPath = 'C:\$WINDOWS.~BT\Sources\Panther'
    $XMLFiles = Get-ChildItem "$SearchPath\compat*.xml" | Sort LastWriteTime -Descending

    # Create an array to hold the results
    $DriverPackages = @()

    # Search each file for any hard blockers
    Foreach ($File in $XMLFiles)
    {
        $xml = [xml]::new()
        $xml.Load($File)
        $HardBlocks = $xml.CompatReport.DriverPackages | Where {$_.DriverPackage.BlockMigration -eq "True"}
        $BlockingDrivers = $HardBlocks.DriverPackage | Where {$_.BlockMigration -eq "True"}
        If($BlockingDrivers)
        {
            Foreach ($Driver in $BlockingDrivers)
            {
                $FileAge = (Get-Date).ToUniversalTime() - $File.LastWriteTimeUTC
                $DriverPackages += [PSCustomObject]@{
                    XMLFileAge = "$($FileAge.Days) days $($FileAge.hours) hours $($FileAge.minutes) minutes"
                    DriverInfFile = $Driver.inf
                }
            }
        }
    }

    If ($DriverPackages)
    {
        $Output = "Blocking Driver Package Names: " + $DriverPackages.DriverInfFile + " , XML File Age: " + $DriverPackages.XMLFileAge
        Write-Output $Output
    }
    Else
    {
        Write-host "No blocking driver packages found"
    }
}
Else
{
    Write-Host "$Path does not exist"
}
