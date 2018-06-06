param(
    [Parameter(Mandatory=$false)]
        [string]$UserName = "lovebikso",
    [Parameter(Mandatory=$false)]
        [string]$Password = "zaq1XSW@cde3",
    [Parameter(Mandatory=$false)]
        [string]$NewCompName = "Computer",
    [Parameter(Mandatory=$false)]
    [ValidateScript({$_ -match [IPAddress]$_})]
        [string]$ip = "192.168.0.2",
    [Parameter(Mandatory=$false)]
    [ValidateScript({$_ -match [IPAddress]$_})]
        [string]$DefaultGateway = "192.168.0.1",
    [Parameter(Mandatory=$false)]
    [ValidateScript({$_ -match [IPAddress]$_})]
        [string]$ServerAddresses = "192.168.14.1"
)


#Create new user 
$group = "Administrators"
$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children | where {$_.SchemaClassName -eq 'user' -and $_.Name -eq $Username }
if ($existing -eq $null) 
{
    Write-Host "Creating new local user $Username."
    & NET USER $Username $Password /add /y /expires:never
    Write-Host "Adding local user $Username to $group."
    & NET LOCALGROUP $group $Username /add
}
else 
{
    Write-Host "Setting password for existing local user $Username."
    $existing.SetPassword($Password)
}
Write-Host "Ensuring password for $Username never expires."
& WMIC USERACCOUNT WHERE "Name='$Username'" SET PasswordExpires=FALSE




#Rename computer
$flag = $true
while($flag -eq $true)
{
  # $NewCompName = Read-Host -Prompt 'Введите новое имя компьютера'
   $CompName = $env:COMPUTERNAME 
   if($NewCompName -eq $CompName)
   {
       Write-Host("Введите другое имя компьютера. Компьютер уже называется так")
       $flag = $true
   }
   elseif($NewCompName -ne $CompName)
   {
       $flag = $false
       Rename-Computer $NewCompName
   }
}

#Add computer to the workgroup
$flag = $true
while($flag -eq $true)
{
    $a = ((Get-WmiObject -Class Win32_ComputerSystem).Workgroup).Substring(0)
    if($a -eq 'WORKGROUP')
    {
        try
        {
            Add-Computer -WorkgroupName DEVELOPERS 
            Write-Host("Вы успешно присоединились к рабочей группе DEVELOPERS")
            $flag = $false
        }
        catch [InvalidOperationException]
        {
            Write-Host("Ошибка создания рабочей группы")
            $flag = $true
        }
    }
    elseif($a -eq 'DEVELOPERS')
    {
        Write-Host("Вы уже находитесь в рабочей группе DEVELOPERS")
    $flag = $false
    }
}

$NameAdapter = ((Get-NetAdapter -Name *).Name).Substring(0)
#$StringAdapterName = [convert]::ToString($NameAdapter)
#$StringAdapterName.GetType()
New-NetIPAddress -InterfaceAlias $NameAdapter -IPAddress $ip -DefaultGateway $DefaultGateway -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias $NameAdapter -ServerAddresses $ServerAddresses
Set-TimeZone -Name "FLE Standard Time"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Enable-PSRemoting -force

#Permission inbound and outbound traffic
Set-NetFirewallProfile -DefaultInboundAction allow -DefaultOutboundAction Allow

#Network visibility
Invoke-Command -ScriptBlock {Enable-NetFirewallRule -Name "NETDIS-UPnPHost-In-TCP","NETDIS-UPnPHost-Out-TCP",`
"NETDIS-NB_Name-In-UDP", "NETDIS-NB_Name-Out-UDP",`
"NETDIS-NB_Datagram-In-UDP","NETDIS-NB_Datagram-In-UDP","NETDIS-NB_Datagram-Out-UDP","NETDIS-WSDEVNTS-In-TCP",`
"NETDIS-WSDEVNTS-Out-TCP","NETDIS-SSDPSrv-In-UDP", "NETDIS-SSDPSrv-Out-UDP", "NETDIS-UPnP-Out-TCP",`
"NETDIS-FDPHOST-In-UDP","NETDIS-FDPHOST-Out-UDP", "NETDIS-LLMNR-In-UDP", "NETDIS-LLMNR-Out-UDP",`
"NETDIS-FDRESPUB-WSD-In-UDP","NETDIS-FDRESPUB-WSD-Out-UDP"} -ComputerName $env:COMPUTERNAME

#Enable RDP
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

#deactivate IE(only for windows server with GUI)
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" 
$loop1 = Test-Path $AdminKey
$loop2 = Test-Path $UserKey

if($loop1 -eq $true -and $loop2 -eq $true)
{
    #Stop-Process -Name Explorer 
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 #-ErrorAction Stop
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 #-ErrorAction Stop
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green 
}
else
{
    Write-Host "На версии Server-core отсутствует компонент Internet Explorer" -ForegroundColor Red
}

#Stop Windows Update service
 Stop-Service wuauserv -Force 
 Set-Service wuauserv -StartupType Disabled

#Disable spying Microsoft
Function ChangeReg {
  param ([string] $RegKey,
         [string] $Value,
         [string] $SvcName,
         [Int] $CheckValue,
         [Int] $SetData)
  Write-Host "Checking if $SvcName is enabled" -ForegroundColor Green
  if (!(Test-Path $RegKey)){
      Write-Host "Registry Key for service $SvcName does not exist, creating it now" -ForegroundColor Yellow
      New-Item -Path (Split-Path $RegKey) -Name (Split-Path $RegKey -Leaf) 
     }
 $ErrorActionPreference = 'Stop'
 try{
      Get-ItemProperty -Path $RegKey -Name $Value 
      if((Get-ItemProperty -Path $RegKey -Name $Value).$Value -eq $CheckValue) {
          Write-Host "$SvcName is enabled, disabling it now" -ForegroundColor Green
          Set-ItemProperty -Path $RegKey -Name $Value -Value $SetData -Force
         }
      if((Get-ItemProperty -Path $RegKey -Name $Value).$Value -eq $SetData){
             Write-Host "$SvcName is disabled" -ForegroundColor Green
         }
     } catch [System.Management.Automation.PSArgumentException] {
       Write-Host "Registry entry for service $SvcName doesn't exist, creating and setting to disable now" -ForegroundColor Yellow
       New-ItemProperty -Path $RegKey -Name $Value -Value $SetData -Force
      }
   }
  
 # Disabling Advertising ID
 $RegKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
 $Value = "Enabled"
 $SvcName = "Advertising ID"
 $CheckValue = 1
 $SetData = 0
 ChangeReg -RegKey $RegKey -Value $Value -SvcName $SvcName -CheckValue $CheckValue -SetData $SetData
 #Telemetry Disable
 $RegKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
 $Value = "AllowTelemetry"
 $SvcName = "Telemetry"
 $CheckValue = 1
 $SetData = 0        
 ChangeReg -RegKey $RegKey -Value $Value -SvcName $SvcName -CheckValue $CheckValue -SetData $SetData        
 #SmartScreen Disable
 $RegKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost\EnableWebContentEvaluation"
 $Value = "Enabled"
 $SvcName = "Smart Screen"
 $CheckValue = 1
 $SetData = 0
 ChangeReg -RegKey $RegKey -Value $Value -SvcName $SvcName -CheckValue $CheckValue -SetData $SetData
 Write-Host "Disabling DiagTrack Services" -ForegroundColor Green 
 Get-Service -Name DiagTrack | Set-Service -StartupType Disabled | Stop-Service
 Get-Service -Name dmwappushservice | Set-Service -StartupType Disabled | Stop-Service
 Write-Host "DiagTrack Services are disabled" -ForegroundColor Green 
 Write-Host "Disabling telemetry scheduled tasks" -ForegroundColor Green
 $tasks ="SmartScreenSpecific","ProgramDataUpdater","Microsoft Compatibility Appraiser","AitAgent","Proxy","Consolidator",
         "KernelCeipTask","BthSQM","CreateObjectTask","Microsoft-Windows-DiskDiagnosticDataCollector","WinSAT",
         "GatherNetworkInfo","FamilySafetyMonitor","FamilySafetyRefresh","SQM data sender","OfficeTelemetryAgentFallBack",
         "OfficeTelemetryAgentLogOn"
 $ErrorActionPreference = 'Stop'
 $tasks | %{
    try{
       Get-ScheduledTask -TaskName $_ | Disable-ScheduledTask
       } catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] { 
    "task $($_.TargetObject) is not found"
    }
 }

#Restart Machine
Restart-Computer -ComputerName $env:COMPUTERNAME


