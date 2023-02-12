<#       ! ! !   R E A D   M E  ! ! !
#>
$x = $null

# Подписываем столбцы итогового файла
#[array]$res = @("Ref`tReferal") 
#[array]$res = @("Col1`tCol2`tCol3`tCol4`tCol5`tCol6`tCol7`tCol8`tCol9`tCol10`tCol11`tCol12`tCol13`tCol14`tCol15") 
[array]$res = @("Col1`tCol2`tCol3`tCol4`tCol5`tCol6`tCol7`tCol8`tCol9")
''

#Import-CSV -Path "\\t2ru\folders\IT-Support\Scripts\Adcomputers\Test_branch_comp.csv" -Delimiter ";" -Encoding Default | ForEach-Object { # | Out-GridView 
#Import-CSV -Path "D:\Scripts\PowerShell\7_NAME_1_0.csv" -Delimiter ";" -Encoding Default | ForEach-Object {
Import-CSV -Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\csv\VcsRegions_v0.1_%.csv" -Delimiter "%" -Encoding utf8 | ForEach-Object {

    #$x = $Null
    #переменные для замены атрибитутов (можно оставлять в таблице пустые ячейки): #'Из файла взяты:'
    #[uint64]$Ref0 = $_.'Ref'
    #. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\csv\VcsRegions_v0.1_columns.ps1
    #Get-Content \\t2ru\folders\IT-Outsource\Scripts\PowerShell\csv\VcsRegions_v0.1.txt -Encoding utf8

    [string]$Column1 = $_.'Column1'
    [string]$Column1
    PAuse

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
    # Добавляем строку в итоговый файл 
    #$res += "$Ref`t$Referal"
    #$res += "$Col1`t$Col2`t$Col3`t$Col4`t$Col5`t$Col6`t$Col7`t$Col8`t$Col9`t$Col10`t$Col11`t$Col12`t$Col13`t$Col14`t$Col15"
    $res += "$Col1`t$Col2`t$Col3`t$Col4`t$Col5`t$Col6`t$Col7`t$Col8`t$Col9"
    } while ($x -le 135)

} # while ($x -le 19)
    
    <# Файл, с которым будем сравнивать:
      Import-CSV -Path "\\t2ru\folders\IT-Support\Региональные сети\CutPCnameSubnetBranch.csv" -Delimiter ";" -Encoding Default | ForEach-Object {
        if (($Move, $Rename) -eq 1) {}#'Пустой прогон оставшихся подсетей'}
        else {
           $PCcutName1 = $_.'Name1'
           $PCcutName2 = $_.'Name3'
           $NoutCutName1 = $_.'Name2'
           $NoutCutName2 = $_.'Name4'
           [array]$CutNames = $PCcutName1,$PCcutName2,$NoutCutName1,$NoutCutName2
           #$CutNames = @($PCcutName1,$PCcutName2,$NoutCutName1,$NoutCutName2)
           $Subnet1 = $_.'Subnet1'
           $Subnet2 = $_.'Subnet2'
           $Subnet3 = $_.'Subnet3'
           $Subnet4 = $_.'Subnet4'
           $Subnet5 = $_.'Subnet5'
           [array]$Subnets = $Subnet1,$Subnet2,$Subnet3,$Subnet4,$Subnet5
           $Branch = $_.'Branch'
           $Town = $_.'Town'
           Pause
        }       
    }  #>
 #$res += "$Ref`t$Referal"  # Добавляем строку в итоговый файл}


[string]$resfile = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")    # Результаты запроса
"Выгрузка данных в '$resfile'"
Out-File -FilePath $resfile -InputObject $res
& $resfile
