<#       ! ! !   R E A D   M E  ! ! !
#>
($ie_procinfo, $ie_procid) = $null

# Подписываем столбцы итогового файла
#[array]$res = @("Ref`tReferal") 
[array]$res = @("Col1`tCol2`tCol3`tCol4`tCol5`tCol6`tCol7`tCol8`tCol9`tCol10`tCol11`tCol12`tCol13`tCol14`tCol15") 

''
#Import-CSV -Path "\\t2ru\folders\IT-Support\Scripts\Adcomputers\Test_branch_comp.csv" -Delimiter ";" -Encoding Default | ForEach-Object { # | Out-GridView 
#Import-CSV -Path "D:\Scripts\PowerShell\7_NAME_1_0.csv" -Delimiter ";" -Encoding Default | ForEach-Object {
Import-CSV -Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\VcsRegions_v0.0_%.csv" -Delimiter "%" -Encoding Default | ForEach-Object {

    $x = $Null
    #переменные для замены атрибитутов (можно оставлять в таблице пустые ячейки): #'Из файла взяты:'
    #[uint64]$Ref0 = $_.'Ref'
    $Col1 = $_.'Col1'
    $Col16 = $_.'Col16'

    do {
           $x = $x + 1        
        $Col1 = $Col+$x
           $x = $x + 1 
        $Col2 = $Col2
           $x = $x + 1
           
           



        #$Col3 = $Col16
        #$Col2 = $Col17

        #$Col1 = $Col31
        #$Col1 = $Col32

    
        #Pause
       
        # Добавляем строку в итоговый файл 
        #$res += "$Ref`t$Referal"
        $res += "$Col1`t$Col2`t$Col3`t$Col4`t$Col5`t$Col6`t$Col7`t$Col8`t$Col9`t$Col10`t$Col11`t$Col12`t$Col13`t$Col14`t$Col15"
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
