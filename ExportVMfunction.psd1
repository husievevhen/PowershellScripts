function Export([string] $VmName, [string]$NetworkPath)
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