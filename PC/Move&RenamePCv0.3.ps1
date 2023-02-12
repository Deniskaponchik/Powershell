<#       ! ! !   R E A D   M E  ! ! !
Данный скрипт переименовывает или переносит не правильно заведённые/занесённые учётки компьютеров на основании еженедельной выгрузки, присылаемой на почту IT Support от группы:
IT_INFRA_SERVICE_SUPPORT
с темой письма:
Список компьютеров с неверным кодом региона.

Полученный файл необходимо сохранить сюда, заменяя предыдущий:
\\t2ru\folders\IT-Support\Scripts\Adcomputers\Test_branch_comp.csv

Скрипт выполняет необходимые действия с учётками на основании файла:
\\t2ru\folders\IT-Support\Региональные сети\PCSubnetBranch.csv
#>


$ie_procinfo, $ie_procid, $Excel_procid, $Excel_procinfo = $null

# Логирование:
# Out-File -FilePath $PSScriptRoot -InputObject $res


[array]$res = @("PCname`tCity`tSubnet`tResult1`tNewParam`tResult2")  # Подписываем столбцы итогового файла
[array]$SplitBranch = @('Central & Rostov-on-Don','Moscow AND Moscow-MCC')

<# Файл от INFRA_SERVICE:
 [string]$file1 = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.InvocationName)), `
  ([System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "txt" )))

 [string]$file1 = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.InvocationName)), `
  ([System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv" )))

 $file1 =  Import-CSV -Path "D:\Scripts\Test_branch_comp.csv" -Delimiter ";" -Encoding Default
#>

function InfoPcUser {
# $PCname = 'OSHIMKOVICH'   $PCname = 'wsir-it-02'  $PCname = 'wsir-it-01'
try{''
  'Информация о последнем использовании ПК:'
   Get-ADComputer -Identity $PCname -Properties * | Format-List Name, LastLogonDate #-Autosize
  'Последние 5 залогинившихся пользователей:'
  $wcusers = "\\$PCname\C$\Users\"
  $users = get-ChildItem $wcUsers | Sort-Object -property LastWriteTime, Name -descending | Select-Object -first 5 | Format-Table Name, LastWriteTime
  # get-ChildItem \\WSVL-VLASOV\C$\Users\ | Sort-Object -property LastWriteTime, Name -descending | Select-Object -first 5 | Format-Table Name, LastWriteTime
  # Get-ChildItem $wcUsers | ForEach-Object {
  # Get-ChildItem $wcUsers | Where-Object lastwritetime -lt (Get-Date).AddDays(-20)
  # if ($users) { $users
  $users
  try {
  $Owner = (Get-WmiObject -Class win32_process -ComputerName $PCname -ErrorVariable ErrGWI | Where-Object name -Match explorer).getowner().user.split(" ")[0]
  }catch {
    <#}
    #$Owner = (Get-WmiObject -Class win32_process -ComputerName wsir-it-02 -ErrorVariable ErrGWI | Where-Object name -Match explorer).getowner().user.split(" ")[0]
    #$Own = Get-WmiObject -Class win32_process -ComputerName $PCname -ErrorVariable ErrGWI | Where-Object name -Match explorer
    #if ($own) {
    if (!$ErrGWI) {
      $owner = $own.getowner().user.split(" ")[0]}    # $owner = 'oxana.gonchar'  
    #Get-WmiObject -Class Win32_UserProfile -ComputerName WSYR-LIHOTA | Select-Object lastusetime, localpath, sid).localPath
    #Get-WmiObject -Class win32_process -ComputerName NBRH-OVLUKASHIK | Where-Object name -Match explorer).getowner().user.split(" ")[0]   
    #else{
    if ($ErrGWI) {
    #if ($Null -eq $Owner) { #>
     ''
     Set-Clipboard -Value $PCName
     Write-Host 'Информацию о владельце ПК не удалось получить.' -ForegroundColor Yellow
     Write-Host 'Имя компьютера скопировано в буфер обмена.' -ForegroundColor Magenta
     Write-Host '* Можешь скопировать-вставить логин одного из последних пользователей машины' -ForegroundColor Yellow
     Write-Host '* Или взять логин из других возможных источников, например, Sparepart (Открывается в отдельно окне)' -ForegroundColor Yellow
     Write-Host '* Или вставить логин любого пользователя из правильного на твой взгляд бранча' -ForegroundColor Yellow
     #Write-Host '* Или ничего не вставлять и просто ENTER' -ForegroundColor Yellow
     
     #if (!$Crome_procinfo){
      if (!$ie_procinfo) {
     $Global:ie_procinfo = Start-Process chrome -ArgumentList 'http://spareparts/site/koordinator/checkpc_n.php' -passthru
     #$ie_procinfo = Start-Process chrome -ArgumentList 'http://spareparts/site/koordinator/checkpc_n.php' -passthru
     #$Global:ie_procid = $ie_procinfo.id    #сохраняем id запущеного процесса в переменную
     Wait-Event -Timeout 5 } 
     Start-Process chrome -ArgumentList 'http://spareparts/site/koordinator/checkpc_n.php' -wait # -passthru
     #invoke-webrequest -uri 'spareparts/site/koordinator/checkpc_n.php#' -method get
     Wait-Event -Timeout 15

     # Попытка вывести все свойства учётки в AD
     Get-ADComputer -Identity $PCname -properties CanonicalName,CN,Created,DistinguishedName,dSCorePropagationData,Enabled,instanceType,isCriticalSystemObject,Modified,modifyTimeStamp,Name,PasswordExpired,PasswordLastSet,whenChanged,whenCreated
     # Попытка вычислить изменялась ли в последние 200 дн.
     if ((Get-ADComputer -Identity $PCname -Properties *).whenChanged -lt (Get-Date).AddDays(-210)){
         Write-Host 'По учётке компьютера не было никаких изменений больше полугода. Будет выдвинуто предложение об её удалении' -ForegroundColor Red
         Remove-ADComputer -Identity $Pcname -Confirm -ErrorVariable ErrDel
         Wait-Event -Timeout 10
         # Выясняем, удалилась ли учётка
         try {Get-ADComputer -Identity $PCname -properties DNSHostName}
         catch #[Microsoft.ActiveDirectory.Management.Commands.GetADComputer]
         {$Global:Result1 = 'Учётка удалена'}
      }          
     Write-Host 'Определить пользователя машины автоматически не удалось' -ForeGroundColor Yellow
     $owner = Read-Host 'Логин пользователя (если не знаешь, просто ENTER)'                 
    }

 # Из полученных выше данных в идеале мы должны получить вводные для этого:
 try {
    $user = Get-ADUser -identity $owner -properties *
    $Global:userOU = $user.distinguishedName.split(',')[-5].Replace("OU=","")
    'Предположительный Пользователь ПК : {0}' -f $user.displayname
    'Должность                         : {0}' -f $user.title 
    'Функция                           : {0}' -f $user.office
    'Макрорегион                       : {0}' -f $user.st
    'OU пользователя                   : {0}' -f $userOU
    ''
  } Catch {}
}    
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
{$Global:Result1 = 'Учётки нет в домене'}
<#'Это Catch1'} 
catch #[GetWMICOMException]
{'Это Catch2'}  #>   
} # Конец функции


function MovePC { ''
    #$Branch = 'Central & Rostov-on-Don'
    #if ($branch -like 'Central & Rostov-on-Don' -or $branch -like 'Moscow AND Moscow-MCC' -or $Error[0] -like '*проверить аргумент*'){
     if (($branch | Select-String $SplitBranch) -or $UserOU -notlike $Branch -or $Error[0] -like '*проверить аргумент*'){
        $Branch = Read-Host 'Укажи Бранч'}
    #     
    #if ($branch -like ('CBIT AND REGION','Moscow AND Moscow-MCC')){$Branch = Read-Host 'Укажи Бранч:'}
    #elseif ($Error[0] -like '*проверить аргумент*') {$Branch = $City}
    #elseif ($userOU) {$Branch = $userOU}
    #else {
    #"Не успех"}
    
            # $Branch = 'Yaroslavl'
            $TargetOU = "OU=Computers,OU=$branch,OU=Branches,DC=corp,DC=tele2,DC=ru"
            $BranchAct = (Get-ADComputer -Identity $PCname).DistinguishedName.Split(',')[2].replace('OU=','')

               if ($BranchAct -ne $Branch) {Write-host 'Учётка компьютера сейчас находится в этом бранче:' -ForeGroundColor Magenta
                 $BranchAct
                 Write-host 'А должна находиться здесь:' -ForeGroundColor Magenta
                 $branch
                 ''
                 Get-ADComputer -Identity $PCname | Move-ADObject -TargetPath $TargetOU -confirm -ErrorVariable ErrMove # перенос учётки
                 # Move-ADObject -Identity $PCname -TargetPath $TargetOU -verbose -confirm
                 Wait-Event -Timeout 15
                 $BranchAct = (Get-ADComputer -Identity $PCname).DistinguishedName.Split(',')[2].replace('OU=','')
                 if ($BranchAct -eq $Branch) {$Result0 = 'Перенесён в :'}   # Result0 НЕ МЕНЯТЬ!!!
                 else {$Result0 = 'Не перенесён в :'}}   # Result0 НЕ МЕНЯТЬ!!!
               else {$Result0 = 'Учётка компьютера уже находится в правильном бранче:'}   # Result0 НЕ МЕНЯТЬ!!!
              # $Result0
              Write-Host $Result0 -ForeGroundColor Green
              Write-Host $BranchAct -ForeGroundColor Green
              ''
   #   }
  $Global:Move = 1  # Всегда пусть будет единичка, даже в случае отказа от переноса, как о факте случившейся попытки переноса
  $Global:NewParam = $Branch
  $Global:Result1 = $Result0
  Pause
} 




''
Import-CSV -Path "\\t2ru\folders\IT-Support\Scripts\Adcomputers\Test_branch_comp.csv" -Delimiter ";" -Encoding Default | ForEach-Object { # | Out-GridView 
#Import-CSV -Path "D:\Scripts\Test_branch_comp.csv" -Delimiter ";" -Encoding Default | ForEach-Object {
  ($user, $owner, $Rename, $Move, $Error[0], $IpCut, $NewParam, $Result1, $Result2, $ip, $UserOU, $Branch) = $null  
  ''
  #переменные для замены атрибитутов (можно оставлять в таблице пустые ячейки):
  'Из файла от Infra_Service взяты:'
  $PCname = $_.'PC_name'
  [string]$PCcut = $PCname.Substring(0,4)
  Write-host $PCname -ForeGroundColor Magenta
  $City = $_.'City'
  Write-host $city -ForeGroundColor Magenta
  #Pause
    
  # $ip = $Null
  # Получение ip-адреса с DNS-сервера:
  # $PCName = Read-Host "Что ищем?"
  # if([string]$ip = [System.Net.Dns]::GetHostEntry($PCname).addresslist[0].ipaddresstostring){
    [string]$ip = [System.Net.Dns]::GetHostEntry($PCname).addresslist[0].ipaddresstostring
  if($ip){ $ip
     # Обрезаем ip:
     # $ipcut = $ip.Split(".")[-1]
     # $ipcut = $ip.TrimEnd(char[".*"])
       $ipsplit = $ip.Split(".")
       $ipcut = $ipsplit[0]+'.'+$ipsplit[1]+'.'+$ipsplit[2]+'.'
       'Компьютер находится в следующей подсети:'
       Write-host $ipcut -ForeGroundColor Yellow
       # Pause

      # Файл, с которым будем сравнивать:
      # Import-CSV -Path "\\t2ru\folders\IT-Support\Региональные сети\CutPCnameSubnetBranch.csv" -Delimiter ";" -Encoding Default | ForEach-Object {
      # Import-CSV -Path "\\t2ru\folders\IT-Support\Scripts\ADComputers\CutPCnameSubnetBranch.csv" -Delimiter ";" -Encoding Default | ForEach-Object {
        Import-CSV -Path "\\t2ru\folders\IT-Support\Scripts\ADComputers\PcSubnetBranch.csv" -Delimiter ";" -Encoding Default | ForEach-Object {
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

           $ConName = Select-String -InputObject $cutnames -Pattern $PCcut   # Ищем ошмёток имени ПК в строке файла
           $ConBra = Select-String -InputObject $SplitBranch -Pattern $Branch   # Ищем бранч в двойных брнанчах

            # Ищем подсеть:
            #if ($Subnet1 -like $ipcut -or $Subnet2 -like $ipcut -or $Subnet3 -like $ipcut -or $Subnet4 -like $ipcut) {  # if ($Subnet -eq $ipcut) {
            #if (($Subnet1, $Subnet2, $subnet3, $Subnet4, $Subnet5) -like $ipcut) {'Подсеть компьютера найдена в файле:'
             if ($Subnets | Select-String $ipcut) {'Подсеть компьютера найдена в файле:'
            #} else {'Не успех'}
             
             # Write-Host $Subnet1, $Subnet2, $Subnet3, $Subnet4, $Subnet5 -ForeGroundColor Yellow
               Write-Host $Branch -ForeGroundColor Magenta
               
               #$PCcut = 'wskr'   $PCcut = 'wsru'
               #if ($City -like $Branch) {  # Если то место, где сейчас лежит учётка ПК, совпадает с Branch, то переименовываем ПК     # ЭТО РАБОТАЕТ
               #if ($City -like $Branch -or ($Branch -like 'Central & Rostov-on-Don' -and ($cutnames | Select-String $PCcut))) {'Успех'}
               #if ($City -like $Branch -or ($Branch -like 'Central & Rostov-on-Don' -and ($cutnames | Select-String $PCcut))) {'Успех'}
               #if ($City -like $Branch -or ($Branch -like 'Central & Rostov-on-Don' -and !$ConName)) {#'Успех'}
                if ($City -like $Branch -or ($ConBra -and !$ConName)) {#'Успех'}
               #if (($PCcutName1, $PCcutName2, $NoutCutName1, $NoutCutName2) -like $PCcut) {'Успех'}
               #if ($PCcutName1 -notlike $PCcut) {'Успех'}
               #if ($PCcut -match $CutNames) {'Успех'}
               #if ($PCcut -contains $CutNames) {'Успех'}
               #if ($cutnames | Select-String $PCcut) {'Успех'}
               #else {"Не Успех"}
                    ''
                    Write-Host 'Компьютер уже находится в правильном бранче' -ForeGroundColor Blue
                    ''        
                    # $ChassisType = Get-WmiObject -Class Win32_SystemEnclosure -ComputerName $PCname | Where-Object ChassisTypes
                    # $ChassisType = Get-WmiObject -Class Win32_SystemEnclosure -ComputerName wsir-tirskih | Where-Object ChassisTypes
                      $ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure -ComputerName $PCname).ChassisTypes
                    # $ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure -ComputerName nbir-volkov).ChassisTypes
                   
                    # Chassis Types:
                    $ChaNout = 2,8,9,10,11,12,14,18,21
                    $ChaPC = 3,4,5,6,7,15,16
                    $ChaServ = 17,23

                     if ($ChaNout -Match $ChassisType) {$TypePC = 'Ноутбук'}
                    #if ($ChaNout -contains $ChassisType) {$TypePC = 'Ноутбук'}
                    #if ($ChassisType -eq 2 -or $ChassisType -eq 8 -or $ChassisType -eq 9 -or $ChassisType -eq 10 -or $ChassisType -eq 11 -or $ChassisType -eq 12 -or $ChassisType -eq 14 -or $ChassisType -eq 18 -or $ChassisType -eq 21) `
                     elseif ($ChaPC -match $ChassisType) {$TypePC = 'Системный блок'}
                    #elseif ($ChaPC -contains $ChassisType) {$TypePC = 'Системный блок'}
                    #elseif ($ChassisType -eq 3 -or $ChassisType -eq 4 -or $ChassisType -eq 5 -or $ChassisType -eq 6 -or $ChassisType -eq 7 -or $ChassisType -eq 15 -or $ChassisType -eq 16) `
                     elseif ($ChaServ -match $ChassisType) {$TypePC = 'Сервер'}
                    #elseif ($ChaServ -contains $ChassisType) {$TypePC = 'Сервер'}
                    #elseif ($ChassisType -eq 17 -or $ChassisType -eq 23) `
                     else {$TypePC = 'Не удалось определить'}
                    
                    InfoPcUser  # Вызов функции
                    #if ($ie_procinfo) {$Crome_procinfo = $ie_procinfo}            
                    'Branch из сравнительного файла   : '+$Branch
                    'Текущее имя ПК                   : '+$PCname
                    'Тип устройства                   : '+$TypePC
                    'Имя ПК должно начинаться с       : '+$PCcutName1
                    'Имя Ноута должно начинаться с    : '+$NoutCutName1
                    'Имя ПК должно начинаться         : '+$PCcutName2
                    'Имя Ноута должно начинаться      : '+$NoutCutName2
                    
                    # Get-ADComputer -Identity $PCname -Properties * | Format-Table Name, LastLogonDate -Autosize
                    # Get-ADComputer -Identity wsto-izvekov -Properties * | Format-Table Name, LastLogonDate -Autosize
                    ''

                    if($error[0] -notlike '*найти объект*'){
                      $Error[0] = $null
                      [int]$x = 2
                      do {''
                         $NewPcName = Read-Host "Новое имя компьютера"
                         if ($Null -eq $AdmWSDomCred -or $ErrRen){
                         ''
                         $AdmWSDomCred = Get-Credential}
                         #$PCName = Read-Host "Что переименовываем?"
                         #$NewPCName = Read-Host "Во что переименовываем?"
                         $x = $x - 1
                         Rename-Computer -NewName $NewPCName -ComputerName $PCname -DomainCredential $AdmWSDomCred -restart -verbose -confirm -ErrorVariable ErrRen
                         #Rename-Computer -ComputerName WSSH-BADYKOV -NewName WSUS-GUSEVA -DomainCredential $AdmWSDomCred -verbose -ErrorVariable ErrRen
                        $PingNew = (Test-Connection -ComputerName $NewPCName -Quiet -Count 20)
                        #$PingNew = (Test-Connection -ComputerName NBCP-ZHITNIK -Quiet -Count 20)
                        if ($PingNew) {Write-host 'Новое имя уже пингуется!' -ForeGroundColor Magenta}
                     #} while (($x -ne 0 -and $ErrRen) -or !$PingNew)
                      } while ($x -ne 0 -and $ErrRen -and !$PingNew)
                      #} while ($x -ne 0 -and ($ErrRen -like '*подключение WMI*' -or $ErrRen -like '*запись уже существует*'))
                      if (!$ErrRen -or $PingNew) {''
                         Write-host 'Компьютер переименован и отправился на перезагрузку' -ForeGroundColor Green
                         $Result0 = 'Переименован'}
                      else {$Result0 = 'Не удалось переименовать'
                      $RenameNo = 1}                      
                    }
                    else {$RenameNo = 1
                    $Result0 = 'Невозможно переименовать'}
                    # Можно включить ожидание до тех пор, пока новый компьютер не появится в сети:
                    # do {$PingNew = (Test-Connection -ComputerName $NewPCName -Quiet)} while ($PingNew -eq $False)
                    #'Компьютер успешно переименован!'

                    $Result1 = $Result0
                    $Result1
                    $NewParam = $NewPcName
                    $Rename = 1
                    Pause} 
             else {   # В обратном случае переносим учётку:
              ''
               Write-Host 'Запускаю процесс переноса учётки...' -ForeGroundColor Blue
               InfoPcUser
               #if ($ie_procinfo) {$Crome_procinfo = $ie_procinfo}
               MovePC}
            }
            elseif ($Subnet1 -like 'Stop' -and ($move, $Rename) -ne 1) {
            Write-Host 'Подсеть не найдена. Если начинается с 10.12. то, скорее всего, ПК подключен по VPN. Если нет, то на основании данных выше добавь её в сравнительный файл (открывается в данный момент, сохранить его можно будет только после окончания действия/остановки скрипта):' -ForeGroundColor Yellow
           #elseif ($Subnet1 -like 'Stop' -and ($move -ne 1 -or $Rename -ne 1)) {'Подсеть не найдена. На основании данных выше добавь её в сравнительный файл:'
            Write-Host '\\t2ru\folders\IT-Support\Scripts\ADComputers\PcSubnetBranch.csv' -ForeGroundColor Yellow
            #Start-Process -FilePath '\\t2ru\folders\IT-Support\Региональные сети\CutPCnameSubnetBranch.csv'
            if (!$Excel_procinfo) {
                #$Excel_procinfo = Start-Process -FilePath '\\t2ru\folders\IT-Support\РегиональныеСети\CutPCnameSubnetBranch.csv' # -PassThru
                $Excel_procinfo = Start-Process Excel -ArgumentList "\\t2ru\folders\IT-Support\Scripts\ADComputers\PcSubnetBranch.csv" -passthru
               #$Excel_procid = $Excel_procinfo.id    #сохраняем id запущеного процесса в переменную
             }
            InfoPcUser  # Вызов функции информации о пользователе
            #if ($ie_procinfo) {$Crome_procinfo = $ie_procinfo}
            ''
            Write-Host 'Единственное действие доступное при таком раскладе - это перенос учётки компьютера в другой Бранч. Осуществляю попытку данного процесса:' -ForeGroundColor Yellow
            MovePC  # вызов функции переноса учётки машины
            $Result2 = 'Подсеть не внесена в сравнительный файл'
            ''
           }
           else {}# 'Подсеть не найдена в строке. Беру следующую.'
         }

      }  
   } else {$Branch = 'Unknown'
        Write-Host $Branch -ForeGroundColor Magenta
        Write-Host 'Не обнаружена запись на DNS. Компьютер не в доменной в сети. Даже если учётка компьютера находится в правильном бранче, то при его недоступности переименовать его нельзя. Информация о последнем входе на ПК: ' -ForeGroundColor Yellow
        # ''
        # Get-ADComputer -Identity $PCname -Properties * | Format-Table Name, LastLogonDate -Autosize
        
        InfoPcUser  # Вызов функции
        #if ($ie_procinfo) {$Crome_procinfo = $ie_procinfo}
        $Result2 = 'Не пингуется'
        ''
        if (!$Result1){ # Если учётка НЕ удалена
           Write-Host 'Единственное действие доступное при таком раскладе - это перенос учётки компьютера в другой Бранч (в конце можно будет отказаться или можно указать тот же бранч, где она лежит сейчас). Осуществляю попытку данного процесса...' -ForeGroundColor Yellow
           MovePC # -PCname $PCname  # вызов функции переноса учётки машины
         } 
        Write-host $Result1 -ForegroundColor Red
      }

 # Добавляем строку в итоговый файл:
 $res += "$PCname`t$City`t$IpCut`t$Result1`t$NewParam`t$Result2"  
 #$res += "1`t2`t3`t4`t5`t6"
}

# Stop-Process -Id $ie_procid -Force     # убиваем запущеный процесс по сохраненному id

# Задаём расположение и расширение итогового файла:
[string]$resfile = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")    
"Выгрузка данных в $resfile"
Out-File -FilePath $resfile -InputObject $res
& $resfile
