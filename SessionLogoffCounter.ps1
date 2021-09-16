<#
.SYNOPSIS
  Counts the number of session logoffs while this script is running
.DESCRIPTION
  This script counts the number of session logoffs while running
.INPUTS
  None
.OUTPUTS
  Number of session logoffs
.NOTES
  Version:        1.0
  Author:         Bart Jacobs - @Cloudsparkle
  Creation Date:  16/09/2021
  Purpose/Change: Count session logoffs
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
$Logoffcount = 0
$KeyList = @()
$startTime = $(get-date)
$sleepTimer=500 #in milliseconds
$QuitKey=81 #Character code for 'q' key.

while($true)
{
  if($host.UI.RawUI.KeyAvailable)
  {
    $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
    if($key.VirtualKeyCode -eq $QuitKey)
    {
      #For Key Combination: eg., press 'LeftCtrl + q' to quit.
      #Use condition: (($key.VirtualKeyCode -eq $Qkey) -and ($key.ControlKeyState -match "LeftCtrlPressed"))
      Write-Host -ForegroundColor Yellow ("'q' is pressed! Stopping the script now.")
      break
    }
  }
  $Logoffsessions = Get-BrokerSession -adminaddress $CTXDDC -maxrecordcount 10000 | where-object -Property LogoffInProgress -like 'True' | Select SessionKey
  foreach ($Logofsession in $Logoffsessions)
  {
    $KeyList += ,$Logoffsession.sessionkey
  }
  $ElapsedTime = new-timespan $startTime $(get-date)
  cls
  Write-Host "SessionLogoffCounter has been running for:" $($ElapsedTime.ToString("hh\:mm\:ss"))
  Write-Host ("Press 'q' to stop the script!")
  Start-Sleep -m $sleepTimer
}

$Logoffcount = ($KeyList | select -Unique).count
cls
Write-Host -ForegroundColor Green "SessionLogoffCounter runtime:" $($elapsedTime.ToString("hh\:mm\:ss"))
Write-Host -ForegroundColor Green "The number of logoffs counted:" $Logoffcount
