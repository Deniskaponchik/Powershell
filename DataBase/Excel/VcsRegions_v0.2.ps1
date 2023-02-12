<#       ! ! !   R E A D   M E  ! ! !
#>
$x = $null
$De = '%' # DELEMITER !!!

# Подписываем столбцы итогового файла
#[array]$res = @("Ref`tReferal") 
#[array]$res = @("Col1`tCol2`tCol3`tCol4`tCol5`tCol6`tCol7`tCol8`tCol9`tCol10`tCol11`tCol12`tCol13`tCol14`tCol15") 
#[array]$res = @("Col1`tCol2`tCol3`tCol4`tCol5`tCol6`tCol7`tCol8`tCol9")
#[array]$res = @("Col1%Col2")
[array]$res = @("Col1$DeCol2")


#$result = Import-Excel -Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\Excel\VcsRegions_v0.2.xlsx" -WorksheetName 'Sheet1' -Raw
Import-Excel -Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\Excel\VcsRegions_v0.2.xlsx" | ForEach-Object {
    #$x = $Null

    $_.Value
    #$Column1 = $PSItem.Column1
    #$Column2 = $PSItem.Column2
    #$Column3 = $_.'Column3'
    #$Column4 = $_.'Column4'
    #$Column5 = $_.'Column5'   
    #$Column1
    #$Column2
    #$Column3
    #$Column4
    #$Column5
    PAuse

    <#
    do {
        $x++
        $Col1
        $Col1 = Get-Variable -Name Col$x
        $Col1
        $x++
        $Col2
        $Col2 = Get-Variable -Name Col$x
        $Col2
        $x++
        $Col3
        $Col3 = Get-Variable -Name Col$x
        $Col3
        $x++
        $Col4 = Get-Variable -Name Col$x
        $Col4
        $x++
        $Col5 = Get-Variable -Name Col$x
        $Col5
        $x++
        $Col6 = Get-Variable -Name Col$x
        $Col6
        $x++
        $Col7 = Get-Variable -Name Col$x
        $Col7
        $x++
        $Col8 = Get-Variable -Name Col$x
        $Col8
        $x++
        $Col9 = Get-Variable -Name Col$x
        $Col9
        #$Col3 = $Col16
        #$Col2 = $Col17
        #$Col1 = $Col31
        #$Col1 = $Col32  

        Pause       
        #>
        $Column1 = $result[1].Column1
        $Column2 = $result[1].Column2
        $Column1 = $result[2].Column1
        $Column2 = $result[2].Column2
    # Добавляем строку в итоговый файл 
    #$res += "$Ref`t$Referal"
    #$res += "$Col1`t$Col2`t$Col3`t$Col4`t$Col5`t$Col6`t$Col7`t$Col8`t$Col9`t$Col10`t$Col11`t$Col12`t$Col13`t$Col14`t$Col15"
    #$res += "$Col1`t$Col2`t$Col3`t$Col4`t$Col5`t$Col6`t$Col7`t$Col8`t$Col9"
    #$res += "$Column1%$Column2"
    $res += "$Column1$De$Column2"
    #} while ($x -le 2)

} | Export-Excel -Path \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\Excel\VcsRegions_v0.2_result.xlsx
#$result = ConvertFrom-Csv -InputObject $res -Delimiter '%'
 $result = ConvertFrom-Csv -InputObject $res -Delimiter $De
 $result | Export-Excel -Path \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\Excel\VcsRegions_v0.2_result.xlsx
<#
[string]$resfile = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")    # Результаты запроса
"Выгрузка данных в '$resfile'"
Out-File -FilePath $resfile -InputObject $res
& $resfile
#>