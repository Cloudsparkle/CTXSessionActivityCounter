asnp citrix*
$Logoncount = 0
$KeyList = @()
$startTime = $(get-date)
$sleepTimer=500 #in milliseconds
$QuitKey=81 #Character code for 'q' key.
while($true)
{
    if($host.UI.RawUI.KeyAvailable) {
        $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
        if($key.VirtualKeyCode -eq $QuitKey) {
            #For Key Combination: eg., press 'LeftCtrl + q' to quit.
            #Use condition: (($key.VirtualKeyCode -eq $Qkey) -and ($key.ControlKeyState -match "LeftCtrlPressed"))
            Write-Host -ForegroundColor Yellow ("'q' is pressed! Stopping the script now.")
            break
        }
    }
    $Logonsessions = Get-BrokerSession -maxrecordcount 10000 | where-object -Property LogonInProgress -like 'True' | Select SessionKey
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

$Logoncount = ($KeyList | select -Unique).count
cls
Write-Host -ForegroundColor Green "SessionLogonCounter runtime:" $($elapsedTime.ToString("hh\:mm\:ss"))
Write-Host -ForegroundColor Green "The number of logons counted:" $Logoncount