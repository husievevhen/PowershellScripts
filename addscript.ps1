
$path = "D:\SheluderScripts\ex_vm_v2.ps1"
$trigger =  New-ScheduledTaskTrigger -Daily -DaysInterval 3 -At 3:48pm
$User= "Administrator"
$Action= New-ScheduledTaskAction -Execute "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -Argument `
"-NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File $path"
Register-ScheduledTask -TaskName "Test2" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force
