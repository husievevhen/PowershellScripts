<#
.SYNOPSIS

Script for exporting a virtual machine
You can export 1 or more machine. This script for windows server 2016/2012 R2/2012

.DESCRIPTION

.PARAMETER VmName
List of names virtual machine. 

.Paramter NetworkPath
Path of the export virtual machine


#>

[Cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
        [String[]] $VmName = @("Test2";"Test3"),
    [Parameter(Mandatory=$false)]
        [string] $NetworkPath = "D:\export"
)


try{
    if((Test-Path -Path $NetworkPath) -eq $false)
    {
        New-Item -ItemType Directory -Path $NetworkPath
    }
    else
    {
        Write-Host "Все заебись"
    }
}
catch{
    Write-Host $Error 
}

if($VmName -eq [String]::Empty)
{
    [System.Array] $AllVm = Get-VM
    foreach ($VM in $AllVm)
    {
        [String] $VmName = $VM.Name
        try{
            if (((Get-VM -Name $VmName).State -eq 'Running'))
            {
                Stop-VM -Name $VmName -Force
                Remove-Item -Path $NetworkPath\$VmName -force -Recurse 
                Export-VM -Name $VmName -Path $NetworkPath 
                Start-Vm $VmName
            }
            else
            {
                Remove-Item -Path $NetworkPath\$VmName -force -Recurse 
                Export-VM -Name $VmName -Path $NetworkPath
                Start-Vm $VmName 
            } 
        }
        catch{
            Write-Host $Error 
        }
 
    }
}
else
{
     foreach($VM in $VmName)
     { 
        for($i =0; $i -le $AllVm.Count; $i++)
        {
            If($Vm -eq $AllVm[$i].Name)
            {
                try{
                    if (((Get-VM -Name $Vm).State -eq 'Running'))
                    {
                        Stop-VM -Name $Vm -Force
                        Remove-Item -Path $NetworkPath\$Vm -force -Recurse  
                        Export-VM -Name $Vm -Path $NetworkPath
                        Start-Vm $Vm 
                    }
                    else
                    {
                        Remove-Item -Path $NetworkPath\$Vm -force -Recurse 
                        Export-VM -Name $Vm -Path $NetworkPath
                        Start-Vm $Vm 
                    } 
                }
                catch{
                    Write-Host $Error 
                }  
            }
            else
            {
                Write-Host "Что то пошло не так"
            }
        }
   
}
}


