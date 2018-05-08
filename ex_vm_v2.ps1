#function ExportVMfunction.psd1 need to import before using ex_vm_v2.ps1

[Cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
        [string] $VmName,
    [Parameter(Mandatory=$false)]
        [string] $NetworkPath = "D:\export"
)



if($VmName -eq [String]::Empty)
{
    [System.Array] $AllVm = Get-VM
    foreach ($VM in $AllVm)
    {
        [String] $VmName = $VM.Name
        Export -VmName $VmName -NetworkPath $NetworkPath
 
    }
}
else
{
    Export -VmName $VmName -NetworkPath $NetworkPath
}


