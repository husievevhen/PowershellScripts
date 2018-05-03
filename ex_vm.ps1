[Cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
        [string] $VmName = "Test1",
    [Parameter(Mandatory=$false)]
        [string] $NetworkPath = "D:\export",
    [Parameter(Mandatory=$false)]
        [string] $logs = "D:\export\ExportInfo.txt"
)




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

