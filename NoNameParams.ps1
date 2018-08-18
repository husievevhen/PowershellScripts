param(
    [Parameter(Mandatory=$true)]
    [string] $FileName = $args[0] ,          #Имя файла
    [Parameter(Mandatory=$true)]
    [string] $CustomError = $args[1],             #Имя ошибки
    [Parameter(Mandatory=$true)]
    [Int32] $LinesBefore = $args[2],        #Количество выводимых строк до совпадения
    [Parameter(Mandatory=$true)]
    [Int32] $LinesAfter = $args[3]         #Количество выводимых строк после совпадения
    )


    
Try{
 Select-String -Path $FileName -Pattern $CustomError -Context $LinesBefore, $LinesAfter 
}
Catch{
    Write-Host "I believe that what doesn’t kill simply makes you stranger...."
}