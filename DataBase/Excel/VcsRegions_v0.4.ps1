# Version: 0.4
# Реализация: Внешний модуль Import-Excel (требуется отдельная установка). Скрипт установки лежит в этой же папке.
# Проблемы: Не отрабатывает Символ переноса на новую строку внутри ячейки-сбивается структура
# Вопросы: denis.tirskikh@tele2.ru

$x = 0
$y = 0
$De = '%' # DELIMITER !!!

# Подписываем столбцы итогового файла
#[array]$res = @("Ref`tReferal")
#[array]$res = @("Col1%Col2")
#[array]$res = @("Col1$DeCol2")
#[array]$res = @("Column1$DeColumn2$DeColumn3$DeColumn4$DeCollumn5$DeCol1$DeCol2$DeCol3$DeCol4$DeCol5$DeCol6$DeCol7$DeCol8$DeCol9")
[array]$res = @("Column1%Column2%Column3%Column4%Collumn5%Col1%Col2%Col3%Col4%Col5%Col6%Col7%Col8%Col9")

$data = Import-Excel -Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\Excel\VcsRegions_v0.4.xlsx" #-WorksheetName 'Sheet1' -Raw
#Import-Excel -Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\Excel\VcsRegions_v0.3.xlsx" | ForEach-Object {

do {
        #$Column1 = $data[0].Column1
        $Column1 = $Data[$y].Column1
        #$Column1
        #$Column2 = $data[1].Column2
        $Column2 = $Data[$y].Column2
        #$Column2 
        #$Column3 = $data[1].Column3
        $Column3 = $Data[$y].Column3
        #$Column3
        #$Column4 = $data[1].Column4
        $Column4 = $Data[$y].Column4
        #$Column4
        #$Column5 = $data[1].Column5
        $Column5 = $Data[$y].Column5
        #$Column5
        #Pause

        $x++
        #$Col1 = "$Data[$y].Col$x"
        [string]$Col1Name = "Col$x"
        #$Col1 = Get-Variable -Name $Col1Name
        $Col1 = $Data[$y].$Col1Name
        #$col1
        #Pause

        $x++
        [string]$Col2Name = "Col$x"
        $Col2 = $Data[$y].$Col2Name
        #$Col2

        $x++
        [string]$Col3Name = "Col$x"
        $Col3 = $Data[$y].$Col3Name
        #$Col3

        $x++
        [string]$Col4Name = "Col$x"
        $Col4 = $Data[$y].$Col4Name
        #$Col4

        $x++
        [string]$Col5Name = "Col$x"
        $Col5 = $Data[$y].$Col5Name
        #$Col5

        $x++
        [string]$Col6Name = "Col$x"
        $Col6 = $Data[$y].$Col6Name
        #$Col6

        $x++
        [string]$Col7Name = "Col$x"
        $Col7 = $Data[$y].$Col7Name
        #$Col7

        $x++
        [string]$Col8Name = "Col$x"
        $Col8 = $Data[$y].$Col8Name
        #$Col8

        $x++
        [string]$Col9Name = "Col$x"
        $Col9 = $Data[$y].$Col9Name
        #$Col9
        #Pause

        if ($x -eq 135){
            $x = 0
            $y++
        } #else {$y++}

# Добавляем строку в итоговый файл 
#$res += "$Col1`t$Col2`t$Col3`t$Col4`t$Col5`t$Col6`t$Col7`t$Col8`t$Col9"
#$res += "$Column1`t$Column2`tCollumn3`tCollumn4`tCollumn5`tCol1`tCol2`tCol3`tCol4`tCol5`tCol6`tCol7`tCol8`tCol9"
#$res += "$Column1%$Column2"
#$res += "$Column1$De$Column2"
#$res += "$Column1$De$Column2$De$Column3$De$Column4$De$Column5$De$Col1$De$Col2$De$Col3$De$Col4$De$Col5$De$Col6$De$Col7$De$Col8$De$Col9"
 $res += "$Column1%$Column2%$Column3%$Column4%$Column5%$Col1%$Col2%$Col3%$Col4%$Col5%$Col6%$Col7%$Col8%$Col9"
} while ($y -le 80) #($y -le 81) #($x -le 135)

#} | Export-Excel -Path \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\Excel\VcsRegions_v0.4_result.xlsx
#$result = ConvertFrom-Csv -InputObject $res -Delimiter '%'
 $result = ConvertFrom-Csv -InputObject $res -Delimiter '%' #"$De"
 $result | Export-Excel -Path \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\Excel\VcsRegions_v0.4_result.xlsx

<#
[string]$resfile = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")    # Результаты запроса
"Выгрузка данных в '$resfile'"
Out-File -FilePath $resfile -InputObject $res
& $resfile
#>