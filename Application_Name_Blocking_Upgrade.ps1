<#
.SYNOPSIS
  <#finding Application Name Blocking Upgrade Using PowerShell>
.DESCRIPTION
  <#finding Application Name Blocking Upgrade Using PowerShell>
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

If ($Exists -eq $True) {
  # Searches the Windows 10 Setup Compatibility logs for upgrade hard blockers

  # Find all the compatibility XML files
  $SearchDir = 'C:\$WINDOWS.~BT\Sources\Panther'
  $XMLFiles = Get-ChildItem "$SearchDir\compat*.xml" | Sort LastWriteTime -Descending

  # Create an array to hold the results
  $HardBlockers = @()

  # Search each file for any hard blockers
  Foreach ($File in $XMLFiles) {
    $XML = [xml]::new()
    $XML.Load($File)
    $Blocked = $XML.CompatReport.Programs | Where {$_.InnerXml -match 'BlockingType="Hard"'}
    If($Blocked) {
      Foreach ($Block in $Blocked) {
        $Age = (Get-Date).ToUniversalTime() - $File.LastWriteTimeUTC
        $HardBlockers += [pscustomobject]@{
          Age = "$($Age.Days) days $($Age.Hours) hours $($Age.Minutes) minutes"
          AppName = $Block.Program.Name
          RequiredAction = $Block.Program.Action.Name
          }
      }
    }
  }

  # Report results
  If ($HardBlockers) {
    $Report = "AppName = " + $HardBlockers.AppName + ", RequiredAction = " + $HardBlockers.RequiredAction + ", FileAge = " + $HardBlockers.Age
    $Report
    
  }
  Else {
    Write-Host "No hard blockers found"
  }
}
Else {
  Write-Host "$Path does not exist"
}
