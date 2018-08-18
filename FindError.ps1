param(
    [Parameter(Mandatory=$false)]
    [string] $FileName = 'C:\Users\Administrator\Desktop\error.txt' ,          #Имя файла
    [Parameter(Mandatory=$false)]
    [string] $CustomError = "Error 44",             #Имя ошибки
    [Parameter(Mandatory=$false)]
    [Int32] $LinesBefore = 0,        #Количество выводимых строк до совпадения
    [Parameter(Mandatory=$false)]
    [Int32] $LinesAfter = 4         #Количество выводимых строк после совпадения
    )


Try{
 Select-String -Path $FileName -Pattern $CustomError -Context $LinesBefore, $LinesAfter | ForEach-Object {$_.Line} 
}
Catch{
    Write-Host "I believe that what doesn’t kill simply makes you stranger...."
}

