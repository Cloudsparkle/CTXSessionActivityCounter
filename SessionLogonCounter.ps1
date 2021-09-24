<#
.SYNOPSIS
  Counts the number of logons while this script is running
.DESCRIPTION
  This script counts the number of session logons while running
.INPUTS
  None
.OUTPUTS
  Number of session logons
.NOTES
  Version:        1.0
  Author:         Bart Jacobs - @Cloudsparkle
  Creation Date:  16/09/2021
  Purpose/Change: Count session logons
.EXAMPLE
  None
#>
#Try loading Citrix Powershell modules, exit when failed
If ((Get-PSSnapin "Citrix*" -EA silentlycontinue) -eq $null)
  {
    try {Add-PSSnapin Citrix* -ErrorAction Stop }
    catch {Write-error "Error loading Citrix Powershell snapins"; Return }
  }

#Variables to be customized
$CTXDDC = "localhost" #Choose any Delivery Controller

#Setting inital values
$Logoncount = 0
$KeyList = @()
$startTime = $(get-date)
$sleepTimer=500 #in milliseconds
$QuitKey=81 #Character code for 'q' key.

while($true)
{
  # Catch 'q' keypress
  if($host.UI.RawUI.KeyAvailable)
  {
    $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if($key.VirtualKeyCode -eq $QuitKey)
    {
      break
    }
  }

  # Get all sessions in LogonInProgress state
  $Logonsessions = Get-BrokerSession -adminaddress $CTXDDC -maxrecordcount 10000 | where-object -Property LogonInProgress -like 'True' | Select SessionKey

  # Get all SessionKeys for those sessions
  foreach ($Logonsession in $Logonsessions)
  {
    $KeyList += ,$Logonsession.sessionkey
  }
  $ElapsedTime = new-timespan $startTime $(get-date)
  cls
  Write-Host "SessionLogonCounter has been running for:" $($ElapsedTime.ToString("hh\:mm\:ss"))
  Write-Host ("Press 'q' to stop the script!")
  Start-Sleep -m $sleepTimer
}
# Count all unique sessionkeys in LogonInProgress state
$Logoncount = ($KeyList | select -Unique).count
cls
Write-Host -ForegroundColor Green "SessionLogonCounter runtime:" $($elapsedTime.ToString("hh\:mm\:ss"))
Write-Host -ForegroundColor Green "The number of logons counted:" $Logoncount
