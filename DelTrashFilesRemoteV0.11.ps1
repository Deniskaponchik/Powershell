﻿# Скопировать-вставить путь для запуска в отдельном окне:
# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\PC\DelTrashFilesRemoteV0.9win7.ps1
# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\PC\DelTrashFilesRemoteV0.11.ps1

# ''
[Environment]::NewLine
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
# ($full) = $null
  ($ErrAct1, $ErrAct2, $ErrDelHyb) = $null


do{
$Error[0] = $Null # $Null -eq $Error[0]
$PC = Read-Host "Имя компьютера или IP-адрес"
$PCut = $PC.Substring(0,4)
[string]$ip = [System.Net.Dns]::GetHostEntry($PC).addresslist[0].ipaddresstostring
}while ($Error[0] -like '*Этот хост неизвестен*' -or $Error[0] -like '*указывать на позицию*')


# if($ip -like '10.12*' -or $ip -like '10.253*'){
  if($ip -like '10.253*'){
# `n
[Environment]::NewLine
Write-host 'Компьютер подключен по VPN. Удалённо очистить его не получится.' -ForegroundColor Red
Write-host '* Либо ОТМЕНЯТЬ заявку, если на данный момент Grafana показывает достаточно свободного пространства' -ForegroundColor Magenta

$VPN1 = 'Компьютер подключен по VPN. Grafana на данный момент показывает достаточно свободного места.'

Write-host '* Либо если сразу очевидно, что установлен диск на 120 ГБ., то можно попробовать добавить или заменить диск на 240 ГБ.' -ForegroundColor Magenta

$VPN2 = ''

Write-host '* Или подключаться через Линк к пользователю и запускать из под ЛОКАЛЬНОГО администратора другой скрипт по очистке:' -ForegroundColor Magenta
'‪\\t2ru\folders\IT-Outsource\Scripts\PowerShell\RemoveTrashFiles.ps1'


Write-host '* Или ставить удалённо PatchCleaner:' -ForegroundColor Magenta
"\\t2ru\folders\IT-Outsource\УСТАНОВКА ПО, ПРОГРАММЫ, SOFT\space"
#`n
[Environment]::NewLine
Set-Clipboard -Value $VPN1

Exit}

# Добавить это инфо в сравнительный файл:
# \\t2ru\folders\IT-Support\Региональные сети\CutPCnameSubnetBranch.csv


$PCreg = 'wsvo','nbvo','wsek','nbek','wsir','nbir','wskz','nbkz','wskr','nbkr','wsky','nbky','wsnn','nbnn','wsrn','nbrn','wsns','nbns','wsrs','nbrs','wsom','nbom' , `
'wsrp','nbrp','wssp','nbsp','wspr','nbpr','wsro','nbro','wstu','nbtu','wstm','nbtm','wsch','nbch'
$PCit = 'wssc','nbsc','wszi','nbzi','wsmo','nbmo','wsms','nbms','wsnn','nbnn','wscn','nbcn','wscp','nbcp','wszr','nbzr','wszs','nbzs','wszc','nbzc','wsru','nbru'
<#
if ($PCut -like 'wsvo' -or $PCut -like 'nbvo' -or $PCut -like 'wsek' -or $PCut -like 'nbek' -or $PCut -like 'wsir' -or $PCut -like 'nbir' `
-or $PCut -like 'wskz' -or $PCut -like 'nbkz' -or $PCut -like 'wskr' -or $PCut -like 'nbkr' -or $PCut -like 'wsky' -or $PCut -like 'nbky' `
-or $PCut -like 'wsnn' -or $PCut -like 'nbnn' -or $PCut -like 'wsrn' -or $PCut -like 'nbrn' -or $PCut -like 'wsns' -or $PCut -like 'nbns' `
-or $PCut -like 'wsrs' -or $PCut -like 'nbrs' -or $PCut -like 'wsom' -or $PCut -like 'nbom' -or $PCut -like 'wsrp' -or $PCut -like 'nbrp' `
-or $PCut -like 'wspr' -or $PCut -like 'nbpr' -or $PCut -like 'wsro' -or $PCut -like 'nbro' -or $PCut -like 'wssp' -or $PCut -like 'nbsp' `
-or $PCut -like 'wstu' -or $PCut -like 'nbtu' -or $PCut -like 'wstm' -or $PCut -like 'nbtm' -or $PCut -like 'wsch' -or $PCut -like 'nbch')
#>
#foreach ($PCre in $Pcreg) {if ($PCut -like $PCre)
if ($PCreg -contains $Pcut)
#if ($PC -match $PСreg)
{Write-Host "В регионе есть свой ИТ-специалист Теле2. Тикет можно перевести на группу региональных ИТ." -ForegroundColor Red
Pause} #}
<#
elseif ($PCut -like 'wssc' -or $PCut -like 'nbsc' -or $PCut -like 'wszi' -or $PCut -like 'nbzi' -or $PCut -like 'wsmo' -or $PCut -like 'nbmo' `
    -or $PCut -like 'wsms' -or $PCut -like 'nbms' -or $PCut -like 'wsnn' -or $PCut -like 'nbnn' -or $PCut -like 'wscn' -or $PCut -like 'nbcn' `
    -or $PCut -like 'wscp' -or $PCut -like 'nbcp' -or $PCut -like 'wszr' -or $PCut -like 'nbzr' -or $PCut -like 'wszs' -or $PCut -like 'nbzs' `
    -or $PCut -like 'wszc' -or $PCut -like 'nbzc' -or $PCut -like 'wsru' -or $PCut -like 'nbru')
#>
#$PCit = 'wssc','nbsc','wszi','nbzi','wsmo','nbmo','wsms','nbms','wsnn','nbnn','wscn','nbcn','wscp','nbcp','wszr','nbzr','wszs','nbzs','wszc','nbzc','wsru','nbru'
#foreach ($PCit in $PCiti) {if ($PCut -like $PCit)
elseif ($PCit -contains $Pcut)
#elseif ($PC -match $PCit)
{Write-Host "В ЦФ есть свои ИТ. Тикет можно перевести на них" -ForegroundColor Red
Pause} #}
#
# if (($PCi, $PCr) -ne 1) {"В регионе нет постоянного ИТ-специалиста"}
else {''
"В регионе нет постоянного ИТ-специалиста"}

# ''
[Environment]::NewLine
 'Последние 5 залогинившихся пользователей:'
 $wcusers = "\\$PC\C$\Users\"
 get-ChildItem $wcUsers | Sort-Object -property LastWriteTime, Name -descending | Select-Object -first 5 | Format-Table Name, LastWriteTime


# Запрос пользователя, которого не удалять не при каких условиях:
$u = $null
$us = ''
$user = $Null
do {$Error[0] = $null
  $lo = $Null
if ($null -eq $u) {$u = Read-Host "Логин или ФИО пользователя ПК"}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {$u = $us.SamAccountName
  $lo = 1}
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {$u
            Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  # $u.count -eq 1 -or 
$user = Get-ADUser -identity $u -properties *
# ''
[Environment]::NewLine

# Инфо о пользователе ПК
$user.displayname
$user.title
$user.mobilePhone
$user.l
$UserInfo = @($user.displayname, $user.title, $user.mobilePhone, $user.l)
Set-Clipboard -Value $UserInfo
Write-Host 'Контактные данные пользователя скопированы в буфер обмена' -ForegroundColor Green `n

#
if (Test-Connection -ComputerName $PC -Quiet) {}
#if ($Ping = Test-Connection -ComputerName $PC -Quiet) {}
else {"ПК - "+ $PC + " недоступен" #}
Write-Host 'Скрипт переведён в режим постоянного отправления пингов. Как только ПК появится в сети - сразу продолжит работу.' -ForegroundColor Red
Write-Host 'Не забудь взять заявку в работу, чтобы твой коллега не сделал того же самого с этим же компом.' -ForegroundColor Red
Write-Host 'Для прекращения работы скрипта команда: CTRL + C' -ForegroundColor Red
Write-Host 'Если скрипт запущен в отдельном окне, то после его завершения для его повторного запуска нажать кнопку ВВЕРХ' -ForegroundColor Green
# ''
[Environment]::NewLine
#do {$Ping} while ($Ping -eq $False)}
do {$Ping = (Test-Connection -ComputerName $PC -Quiet)} while ($Ping -eq $False)}
#
<# $Ping = Test-Connection -ComputerName $PC -Quiet
if(!$Ping = Test-Connection -ComputerName $PC -Quiet){"ПК - "+ $PC + " недоступен"
Write-Host 'Скрипт переведён в режим постоянного отправления пингов. Как только ПК появится в сети - сразу продолжит работу.' -ForegroundColor Red
Write-Host 'Не забудь взять заявку в работу, чтобы твой коллега не сделал того же самого с этим же компом.' -ForegroundColor Red
Write-Host 'Для прекращения работы скрипта команда: CTRL + C' -ForegroundColor Red
Write-Host 'Если скрипт запущен в отдельном окне, то после его завершения для его повторного запуска нажать кнопку ВВЕРХ' -ForegroundColor Green
do {$Ping} while ($Ping -eq $False)}
#>

$d1 = Get-Date  # Фиксируем время начала отработки скрипта


[Environment]::NewLine
# Вывод информации о машине:
Write-Host $PC -ForegroundColor Red
$OS = Get-WmiObject -Class Win32_OperatingSystem -Computername $PC
# "OS               : {0}" -f $OS.Caption  + $OS.CSDVersion
# "OSArchitecture   : {0}" -f $OS.OSArchitecture
$OS.Caption  + $OS.CSDVersion  # Версия Windows
#Get-WmiObject  -computername  $PC -query 'SELECT * FROM Win32_Processor' # Версия процессора
$Proc = (Get-WmiObject  -computername  $PC -query 'SELECT * FROM Win32_Processor').name # Версия процессора
$Proc
#''

[Environment]::NewLine
# Вывод информации только для диска C:
# Write-Host 'Установленные диски:' -ForegroundColor Green
# (Get-WmiObject  -Class win32_diskdrive -ComputerName $PC).Model
$p = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | Where-Object {$_.deviceid -like 'C:'}
$Lsize = ($p.Size / 1GB).ToString("F01")
"Disk " + $p.DeviceID + " Size      : {0}" -f ($p.Size / 1GB).ToString("F01") + ' GB'
"Disk " + $p.DeviceID + " FreeSpace : {0}" -f ($p.FreeSpace / 1GB).ToString("F01") + ' GB'
<# Вывод информации по всем дискам
$p=Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC
foreach ($comp in $p) {
  "Disk " + $comp.DeviceID + " Size     : {0}" -f ($comp.Size / 1GB).ToString("F01")
  "Disk " + $comp.DeviceID + " FreeSpace: {0}" -f ($comp.FreeSpace / 1GB).ToString("F01") }
#>

# ''
[Environment]::NewLine
Write-Host 'Установленные физические диски:' -ForegroundColor Green
# Get-WmiObject -Class "Win32_LogicalDisk" -ComputerName $PC
# $f = Get-WmiObject -Class Win32_diskdrive -ComputerName $PC
Get-WmiObject -Class Win32_diskdrive -ComputerName $PC | Format-Table -Property Model, @{Label="Size(GB)"; Expression={$_.Size/1Gb}} -AutoSize
#Get-WmiObject -Class Win32_diskdrive -ComputerName $PC | Format-Table -Property Model, @{Label="Size(GB)"; Expression=($_.Size/1Gb).ToString("F01")}.Split(".")[0]} -AutoSize

<# Можно подумать и продолжить, как отобразить несоответствие объёмов логичиских и физических дисков
$Fsize = ($f.Size / 1GB).ToString("F01")
$F10size = $Fsize - 10
if ($Lsize -lt $F10size){}
#>


# Write-Host "На основании информации выше выбери вариант дальнейших действий :" -ForegroundColor Magenta
"На основании информации выше выбери вариант дальнейших действий :"

$Oth00 = 'Текст комментария скопирован в буфер обмена. Можешь завершить скрипт или продолжить его выполнение'
$Oth0 = 'Выбрана стандартная очистка диска и продолжение скрипта'


Write-Host "1. Диск РАЗБИТ и его объём можно увеличить слиянием разделов. Для этого можно добавить диск SSD или HDD в рамках текущей заявки. " -ForegroundColor Cyan
#$Oth1 = 'Необходимо добавить SSD на 240 ГБ. Затем клонировать на него текущую Windows или установить новую. Затем сделать слияние разделов на старом диске (который сейчас установлен на машине пользователя), удалив один из них (скорее всего, диск С). Также оказать помощь пользователю по переносу личных файлов на новый диск D, очистив тем самым диск С: не менее чем на 100 ГБ.'
$Oth1 = 'Необходимо добавить SSD на 240 ГБ.', 'Затем клонировать на него текущую Windows или установить новую.', 'Затем сделать слияние разделов на старом диске (который сейчас установлен на машине пользователя), удалив один из них (скорее всего, диск С).', 'Также оказать помощь пользователю по переносу личных файлов на новый диск D, очистив тем самым диск С: не менее чем на 150 ГБ.'

Write-Host "2. Диск РАЗБИТ и его объём можно увеличить слиянием разделов. Для этого можно добавить диск SSD или HDD в рамках текущей заявки. (Вариант для Windows 10 КОРП.)" -ForegroundColor Cyan
#$Oth2 = 'Необходимо добавить SSD на 240 ГБ. Затем установить на него Windows 10 PRO. Затем сделать слияние разделов на старом диске (который сейчас установлен на машине пользователя). Провести работу с пользователем по обучению сохранению личных файлов на новый созданный диск D:'
$Oth2 = 'Необходимо добавить SSD на 240 ГБ.', 'Затем установить на него Windows 10 PRO.', 'Затем сделать слияние разделов на старом диске (который сейчас установлен на машине пользователя).', 'Провести работу с пользователем по обучению сохранению личных файлов на новый созданный диск D:'

Write-Host "3. На ПК НЕ УСТАНОВЛЕН SSD и объём памяти компьютера можно увеличить установкой SSD в рамках текущего тикета." -ForegroundColor Magenta
#$Oth3 = 'Необходимо добавить SSD на 240 ГБ. Затем клонировать на него текущую Windows или установить новую. Потом оказать помощь пользователю по переносу личных файлов на диск D, очистив тем самым диск С: не менее чем на 100 ГБ.'
$Oth3 = 'Необходимо добавить SSD на 240 ГБ.', 'Затем клонировать на него текущую Windows или установить новую.', 'Потом оказать помощь пользователю по переносу личных файлов на диск D, очистив тем самым диск С: не менее чем на 150 ГБ.'

Write-Host "4. На ПК НЕ УСТАНОВЛЕН SSD и объём памяти компьютера можно увеличить установкой SSD в рамках текущего тикета. (Вариант для Windows 10 КОРП.)" -ForegroundColor Magenta
#$Oth4 = 'Необходимо добавить SSD на 240 ГБ. Затем установить на него Windows 10 PRO. Потом оказать помощь пользователю по переносу личных файлов на диск D, очистив тем самым диск С: не менее чем на 100 ГБ.'
$Oth4 = 'Необходимо добавить SSD на 240 ГБ.', 'Затем установить на него Windows 10 PRO.', 'Потом оказать помощь пользователю по переносу личных файлов на диск D, очистив тем самым диск С: не менее чем на 100 ГБ.'




Write-Host "5. На ноутбуке всего один диск на 120 ГБ, можно предпринять меры в рамках текущей заявки по замене или добавлению SSD на 240 ГБ или даже 500 ГБ." -ForegroundColor Yellow
#$Oth5 = 'Если устройство позволяет, то добавить диск SSD на 240 ГБ, клонировать потом на него систему и очистить Диск C: минимум на 100 ГБ. переносом пользовательской информации на новый Диск D:. Если места для установки второго диска нет, то просто заменить на SSD 500 ГБ.'
$Oth5 = 'Если устройство позволяет, то добавить диск SSD на 240 ГБ.', 'Клонировать потом на него систему и очистить Диск C: минимум на 100 ГБ, переносом пользовательской информации на новый Диск D:', 'Если места для установки второго диска нет, то просто заменить на SSD 500 ГБ.'

Write-Host "6. На ноутбуке всего один диск на 120 ГБ, можно предпринять меры в рамках текущей заявки по замене или добавлению SSD на 240 ГБ или даже 500 ГБ. (Вариант для Windows 10 КОРП.)" -ForegroundColor Yellow
#$Oth6 = 'Если устройство позволяет, то добавить диск SSD на 240 ГБ, установить Windows 10. Если места для установки второго диска нет, то просто заменить на SSD 500 ГБ.'
$Oth6 = 'Если устройство позволяет, то добавить диск SSD на 240 ГБ, установить Windows 10.', 'Если места для установки второго диска нет, то просто заменить на SSD 500 ГБ.'

Write-Host "7. На ноутбуке всего один диск на 240 ГБ, можно предпринять меры в рамках текущей заявки по замене или добавлению SSD на 500 ГБ." -ForegroundColor Yellow
$Oth7 = 'Если устройство позволяет, то добавить диск SSD на 240 ГБ', 'Очистить потом диск C: не менее чем на 100 ГБ, переносом пользовательской информации на новый диск', 'Если места для установки второго диска нет, то просто заменить на SSD 500 ГБ.'

Write-Host "8. На ноутбуке всего один диск на 240 ГБ, можно предпринять меры в рамках текущей заявки по замене или добавлению SSD на 500 ГБ. (Вариант для Windows 10 КОРП)" -ForegroundColor Yellow
$Oth8 = 'Если устройство позволяет, то добавить диск SSD на 240 ГБ и ОБЯЗАТЕЛЬНО установить Windows 10 PRO. Очистить потом диск C: не менее чем на 150 ГБ, переносом пользовательской информации на новый диск', 'Если места для установки второго диска нет, то просто заменить на SSD 500 ГБ и установить Windows 10 PRO.'





Write-Host "9. На ПК не установлен HDD и объём памяти компьютера можно увеличить установкой HDD в рамках текущего тикета." -ForegroundColor Cyan
$Oth9 = "Добавить HDD на 500 ГБ.", 'Провести работу с сотрудником по обучению переносу личных файлов на диск D: очистив тем самым диск C: не менее чем на 40 ГБ.'

Write-Host "10.Провести работу с сотрудником по обучению переносу личных файлов на диск D: очистив тем самым диск C: минимум на 100 ГБ." -ForegroundColor Cyan
$Oth10 = "Провести работу с сотрудником по обучению переносу личных файлов на диск D: очистив тем самым диск C: минимум на 100 ГБ."




Write-Host "11.Полная замена устаревшего системного блока. (Ниже i3 4-ой серии)" -ForegroundColor Magenta
$Oth11 = "Необходимо полностью заменить устаревший системный блок:", $Proc, '', "На старом ПК ОБЯЗАТЕЛЬНО установить Windows 10 или вывести из домена и полностью выключить", '!!! Старый ПК ОБЯЗАТЕЛЬНО вывести из домена и полностью отключить !!!', '!!! Если на старой машине имеется ОЗУ 8 ГБ ОДНОЙ ЦЕЛЬНОЙ планкой, то её снять и передать логисту на склад !!!', 'SSD-диск со старого ПК снять и передать логисту на склад', 'Старый монитор пользователя можно оставить ему вторым', '', 'Имя машины:', $PC, ''

Write-Host "12.Полная замена устаревшего ноутбука. (Ниже i3 4-ой серии)" -ForegroundColor Magenta
#$Oth10 = "Необходимо полностью заменить устаревший ноутбук. $Proc"
 $Oth12 = "Необходимо полностью заменить устаревший ноутбук:", $Proc, '', "На старом ноутбуке ОБЯЗАТЕЛЬНО установить Windows 10", '', 'Имя машины:', $PC
 <#
 Необходимо рядом с сотрудницей организовать второе/параллельное временное рабочее место с новым ПК.
Установить и настроить на него все необходимые программы для пользователя.
Скопировать потом все файлы пользователя с текущего ПК
Когда пользователь убедится, что на новой машине всё работает также, как на старой,отключить и забрать старый ПК
#>



Write-Host "13. Заменить SSD на больший объём" -ForegroundColor Yellow
#$Oth10 = "Необходимо полностью заменить устаревший ноутбук. $Proc"
 $Oth13 = "Заменить SSD на больший объём = 240 ГБ", 'Старый SSD-диск передать логисту на склад', "Уже далеко не первая заявка на очистку диска"





[Environment]::NewLine
"Укажи номер дальнейшего варианта действий, чтобы скопировать текст комментария к заявке в буфер обмена."
$Choice = Read-Host "0 - Просто продолжить очистку диска."



Switch ($Choice) {
    #1{ClearBrowser}
    #1{Set-Clipboard -Value $PCName}
     1{[Environment]::NewLine
       Set-Clipboard -Value $Oth1
      Write-Host "$Oth00" -ForegroundColor Yellow}
     2{[Environment]::NewLine
       Set-Clipboard -Value $Oth2
      Write-Host "$Oth00" -ForegroundColor Yellow}
     3{[Environment]::NewLine
       Set-Clipboard -Value $Oth3
      Write-Host "$Oth00" -ForegroundColor Yellow}
     4{[Environment]::NewLine
       Set-Clipboard -Value $Oth4
      Write-Host "$Oth00" -ForegroundColor Yellow}
     5{[Environment]::NewLine
       Set-Clipboard -Value $Oth5
      Write-Host "$Oth00" -ForegroundColor Yellow}
     6{[Environment]::NewLine
       Set-Clipboard -Value $Oth6
      Write-Host "$Oth00" -ForegroundColor Yellow}
     7{[Environment]::NewLine
       Set-Clipboard -Value $Oth7
      Write-Host "$Oth00" -ForegroundColor Yellow}
     8{[Environment]::NewLine
      Set-Clipboard -Value $Oth8
      Write-Host "$Oth00" -ForegroundColor Yellow}
     9{[Environment]::NewLine
       Set-Clipboard -Value $Oth9
      Write-Host "$Oth00" -ForegroundColor Yellow}
    10{[Environment]::NewLine
      Set-Clipboard -Value $Oth10
      Write-Host "$Oth00" -ForegroundColor Yellow}
    11{[Environment]::NewLine
      Set-Clipboard -Value $Oth11
      Write-Host "$Oth00" -ForegroundColor Yellow}
    12{[Environment]::NewLine
      Set-Clipboard -Value $Oth12
      Write-Host "$Oth00" -ForegroundColor Yellow}
    13{[Environment]::NewLine
      Set-Clipboard -Value $Oth13
      Write-Host "$Oth00" -ForegroundColor Yellow}

    #Default {Write-Host -ForegroundColor Red "Не правильно выбран режим"}
     Default {[Environment]::NewLine
       Write-Host "$Oth0" -ForegroundColor Yellow}
}
Pause


# ''
[Environment]::NewLine
if (($OS.Caption  + $OS.CSDVersion) -like '*Windows 7*') {
Write-Host "Необходимо ОБЯЗАТЕЛЬНО в рамках данного тикета предпринять ВСЕ возможные меры, чтобы избавиться от Windows 7" -ForegroundColor Red `n
Pause}

if (($OS.Caption  + $OS.CSDVersion) -like '*Windows 10 Корп*') {
Write-Host "Для Windows 10 Корпоративная в компании нет лицензий. Необходимо обновить систему до Windows 10 Pro" -ForegroundColor Red
Write-Host 'Текст комментария скопирован в буфер обмена. Можешь завершить скрипт или продолжить его выполнение' -ForegroundColor Yellow `n
Set-Clipboard -Value 'Необходимо также обновить систему до Windows 10 PRO через Центр Программного обеспечения или установить её с нуля в случае недоступности таковой там.'
Pause}




<# Отключение гибернации (ЦИКЛ):
$x = 2
do {  # $DomainCred -eq $Null
    #if ($Null -eq $DomainCred -or $Error[0] -like '*Не удается проверить аргумент*' -or $Error[0] -like '*Не удалось присоединить компьютер*') { 
    #if ($Null -eq $AdmWSDomCred) { 
     $x = $x - 1
     if (!$AdmWSDomCred -or $ErrDelHyb) { 
      Write-Host "Запрос прав администратора домена (admin.ws.)" -ForegroundColor Red
      $AdmWSDomCred = Get-Credential}
     #$AdmWSDomCred = Get-Credential "t2ru\admin.ws.tirskikh" -ErrorVariable Otmena
     #$AdmWSDomCred = Get-Credential [Domain\Username]
      
   #$PC = Read-Host "Имя компьютера или IP-адрес"
   #Invoke-WMIMethod -cred $AdmWSDomCred -path Win32_Process -name Create -argumentlist "powercfg.exe -h off" -ComputerName [computer]
   Invoke-WMIMethod -cred $AdmWSDomCred -path Win32_Process -name Create -argumentlist "powercfg.exe -h off" -ComputerName $PC -ErrorVariable ErrDelHyb
   #Invoke-WMIMethod -cred $AdmWSDomCred -path Win32_Process -name Create -argumentlist "powercfg.exe -h off" -ComputerName wsir-it-01
    }
while ($ErrDelHyb -and $x -gt 0)
#while ($x -gt 0)

if (!$ErrDelHyb){
    # ''
    [Environment]::NewLine
    Write-Host "Гибернация отключена и файл гибернации удалён успешно" -ForegroundColor Magenta `n}
else {
    $ErrAct1 = 'Гибернация не была выключена и файл гибернации не смог удалиться'}
#>


# Отключение гибернации (ПРОСТОЕ):
Write-Host "Запрос прав администратора домена (admin.ws.)" -ForegroundColor Red
$AdmWSDomCred = Get-Credential

Invoke-WMIMethod -cred $AdmWSDomCred -path Win32_Process -name Create -argumentlist "powercfg.exe -h off" -ComputerName $PC -ErrorVariable ErrDelHyb -Verbose
Write-Host 'Гибернация отключена' -ForegroundColor Magenta

#Wait-Event -Timeout 30
#


################################################### 
<# Вывест размер профиля каждого пользователя в папке C:\Users :
# Get-ChildItem -force 'C:\Users'-ErrorAction SilentlyContinue | ? { $_ -is [io.directoryinfo] } | % {
  Get-ChildItem $wcUsers -Force -ErrorAction SilentlyContinue | Where-Object { $_ -is [io.directoryinfo] } | ForEach-Object {  $len = 0
  Get-ChildItem -recurse -force $_.fullname -ErrorAction SilentlyContinue | ForEach-Object { $len += $_.length }
  ($_.fullname).Split("\")[-1], '{0:N2} GB' -f ($len / 1Gb)
  $sum = $sum + $len  }
  “Общий размер профилей”,'{0:N2} GB' -f ($sum / 1Gb)  #>



<# Удаление папок/профилей неиспользуемых пользователей #1:
$wcusers = "\\$PC\C$\Users\"
$x = -1
# $90d = (Get-Date).AddDays(-90)
$usersfol = Get-ChildItem $wcUsers -Force # -ErrorAction SilentlyContinue # | Sort-Object LastWriteTime
  #           Get-ChildItem "\\WSZI-NGTIATE-03\C$\Users\" -Force | Sort-Object LastWriteTime
  #           Get-ChildItem "\\WSZI-NGTIATE-03\C$\Users\" -Force | Sort-Object Name
do {$Error[0] = $Null
    $x = $x + 1  
    # $fo = $usersfol[$x].lastwritetime      # $usersfol[1].length Name    # $fo = $usersfol[0].lastwritetime    # $usersfol[0].fullname.Split("\")[-1]  # $full = 'ivan.kazanin'
    $full = $usersfol[$x].fullname.Split("\")[-1]
    $full
    
     #if ($full = $usersfol[$x].fullname.Split("\")[-1]){

       # Ищем профили пользователей, не изменяемые старше (Get-Date).AddDays(-250)
       $Fold = 'Все пользователи','All Users','Default','Default User','Администратор','Administrator','Public','Общие','desktop.ini',$user.SamAccountName
       if (($usersfol[$x].lastwritetime -lt (Get-Date).AddDays(-90)) -and $fold -notcontains $full)
       
       {Get-WMIObject -class Win32_UserProfile -ComputerName $pc | Where-Object {$_.LocalPath -like 'C:\Users\'+$full} | Remove-WmiObject 
       if ($Error[0] -like '*Wmi*') { # Write-Host 'Профиль '$full' не смог удалиться' -ForegroundColor Yellow
       Remove-Item -Path "\\$PC\C$\Users\$full\" -force -recurse -verbose -ErrorVariable ErrDel }
       else {Write-Host 'Профиль '$full' удалён' -ForegroundColor Magenta}}
    
  } while ($Error[0] -notlike '*вызвать метод*')  # $null -ne $fo)
#>



# Удаление папок/профилей неиспользуемых пользователей #2 (ВРЕМЕННО отключл):
#$user.SamAccountName = 'Polina.Mosichenko'
$NoDelUsers = 'Все пользователи','All Users','Default','Default User','Администратор','Administrator','Public','Общие','desktop.ini',$user.SamAccountName
#$PC = 'wszi-leader-12'
#$PC = 'WSZI-NGTIATE-03'
#$PC = 'wszi-IT-01'
$wcusers = "\\$PC\C$\Users\"
$usersfol = Get-ChildItem $wcUsers -Force
foreach ($UF in $usersfol) {  
  Write-Host $UF
  if (($UF.lastwritetime -lt (Get-Date).AddDays(-60)) -and $NoDelUsers -notcontains $UF.name){
    Get-WMIObject -class Win32_UserProfile -ComputerName $pc | Where-Object {$_.LocalPath -like 'C:\Users\'+$UF.name} | Remove-WmiObject -Verbose -ErrorVariable ErrDelUF1 # -AsJob
    Remove-Item -Path "\\$PC\C$\Users\$UF\" -force -recurse -verbose -ErrorVariable ErrDelUF2
    Write-Host "Профиль $UF удалён" -ForegroundColor Magenta
    [Environment]::NewLine}       
} #



<# Удаление папок/профилей неиспользуемых пользователей #3:
#$user.SamAccountName = 'Polina.Mosichenko'
$NoDelUsers = 'Все пользователи','All Users','Default','Default User','Администратор','Administrator','Public','Общие','desktop.ini',$user.SamAccountName
#$PC = 'wszi-leader-12'
 $PC = 'WSZI-NGTIATE-03'
#$PC = 'wszi-IT-01'
$wcusers = "\\$PC\C$\Users\"
$usersfol = Get-ChildItem $wcUsers -Force

Get-WMIObject -class Win32_UserProfile -ComputerName $pc | Where-Object LastUseTime -gt (Get-Date).AddDays(-60) | ForEach-Object
Get-WMIObject -class Win32_UserProfile -ComputerName $pc | Where-Object LastUseTime -gt (Get-Date).AddDays(-60) | ForEach-Object

foreach ($UF in $usersfol) {  
  $UF
  if (($UF.lastwritetime -lt (Get-Date).AddDays(-60)) -and $NoDelUsers -notcontains $UF.name){
    Get-WMIObject -class Win32_UserProfile -ComputerName $pc | Where-Object {$_.LocalPath -like 'C:\Users\'+$UF.name} | Remove-WmiObject -Verbose -ErrorVariable ErrDelUF1
    Get-WMIObject -class Win32_UserProfile -ComputerName $pc | Where-Object {$_.LocalPath -like 'C:\Users\ksnproxy'} | Remove-WmiObject -Verbose -ErrorVariable ErrDelUF1
    Remove-Item -Path "\\$PC\C$\Users\$UF\" -force -recurse -verbose -ErrorVariable ErrDelUF2
    Write-Host "Профиль $UF удалён" -ForegroundColor Magenta
    [Environment]::NewLine}       
}
#>


###############################################
# Реализовать в будущем удаление:
# Эскизы Windows
# 
# Очистка обновлений Windows
# 

# Очистим темпы и другие папки:

# Дата с которой сравнивать. В этом случае -15 дней от текущей даты
# $TEMPdate = (Get-Date).AddDays(-10)
# Или дата кастомная. Пустые значения будут взяты из текущего времени и даты
# $date = Get-Date -Year 2018 -Month 12 -Day 2 -Hour 12 -Minute 13


# $PC = 'WSRU-VAKULICH'
       $wc = "\\$PC\C$\"   # ДИСК С !!!
  $wcdump1 = "\\$PC\C$\Windows\MEMORY.DMP"
  $wcdump2 = "\\$PC\C$\Windows\minidump\*"

  $wcUpdate1 = "\\$PC\C$\Windows\SoftwareDistribution\Download\*"
# $wcUpdate2 = "\\$PC\C$\Windows\SoftwareDistribution\DataStore\*"  # Папка небольшая и удалять не очень хочется
  $wcUpdate3 = "\\$PC\C$\Windows\ccmcache\*"    # Настравиается размер кэша SCCM в корне Панели управления

# $wctemp1 = "\\$PC\C$\Windows\temp\*"
  $wctemp1 = "\\$PC\C$\Windows\temp\"
# $wctemp2 = "\\$PC\C$\Users\*\Appdata\Local\Temp\*"
  $wctemp2 = "\\$PC\C$\Users\*\Appdata\Local\Temp\"
# $wctemp3 = "\\$PC\C$\Documents and Settings\*\Local Settings\temp\"

  $wcoldwin1 = "\\$PC\C$\Windows.ol*\Users\*.*\"
  $wcoldwin2 = "\\$PC\C$\Windows.ol*\"
# $wcoldwin3 = "\\$PC\C$\Windows.ol*\*"
# $wcoldwin3 = "\\$PC\C$\Windows.old\Users\*"

#   $wsSketch = "\\$PC\C$\Users\*\AppData\Local\Microsoft\Windows\Explorer\*  # Эскизы Windows
# $wcPrefetch = "\\$PC\C$\Windows\Prefetch\*"  # Никогда не вешает больше 50 мб

# Ещё какие-то варианты:
# “C:\swsetup”
# “\AppData\Local\*.auc”
# “\AppData\Local\Microsoft\Terminal Server Client\Cache\*”
# “\AppData\Local\Microsoft\Windows\Temporary Internet Files\*”
# “\AppData\Local\Microsoft\Windows\WER\ReportQueue\*”
# “\AppData\Local\Microsoft\Windows\Explorer\*”

  Remove-Item $wcoldwin1 -force -recurse -verbose -ErrorVariable ErrDelWinOld
  Remove-Item $wcoldwin2 -force -recurse -verbose -ErrorVariable ErrDelWinOld
# Remove-Item $wcoldwin3 -force -recurse -verbose -ErrorVariable ErrDelWinOld -Exclude "\\$PC\C$\Windows.old\Users\All Users"
# Remove-Item $wcoldwin3 -force -recurse -verbose -ErrorVariable ErrDelWinOld -Exclude *All users*
# if ($ErrDelWinOld) {$ErrAct2 = 'Папка Windows.Old не смогла удалиться полностью. Можешь подключиться к диску С и удалить её вручную.'}
  if ($ErrDelWinOld) {$ErrAct2 = "Папка Windows.Old не смогла удалиться полностью. Можешь подключиться к диску C: и удалить её вручную:", $wc}
# if ($ErrDelWinOld) {$ErrAct2 = @('Папка Windows.Old не смогла удалиться полностью. Можешь подключиться к диску С и удалить её вручную:',"$PcC")}


# Удаление всех файлов и папок (в т.ч. внутри папок) старше чем значение в $TEMPdate
# Get-ChildItem -Recurse -Path $wctemp1,$wctemp2 | Where-Object -Property CreationTime -gT $TEMPdate | Remove-Item -force -recurse -verbose -ErrorVariable ErrDelTemp

# $tempfolders = @( “C:\Windows\Temp\*”, “C:\Windows\Prefetch\*”, “C:\Documents and Settings\*\Local Settings\temp\*”, “C:\Users\*\Appdata\Local\Temp\*” )
# $tempfolders = @( “$wc'Windows.OLD\*'”, “$wc'Temp\*'”, “$wc+'Prefetch\*'”, “C:\Users\*\Appdata\Local\Temp\*” )
# $ForDelFold = @($wcoldwin1, $wcoldwin2, $wcdump1, $wcdump2, $wcUpdate1, $wctemp1, $wctemp2)
# $ForDelFold = @($wcdump1, $wcdump2, $wcUpdate1, $wctemp1, $wctemp2)
  $ForDelFold = $wcdump1, $wcdump2, $wcUpdate1, $wcUpdate3, $wctemp1, $wctemp2
# $ForDelFold = @($wcdump1, $wcdump2, $wcUpdate1)
# Remove-Item $tempfolders -force -recurse -verbose #-ErrorAction SilentlyContinue
  Remove-Item $ForDelFold -force -recurse -verbose #-ErrorAction SilentlyContinue
# Remove-Item $wcUpdate -force -recurse -verbose



<# Кэши браузеров (при желании можно чуть допилить и реализовать, но необходимо закрывать браузеры понадобится, скорее всего):
# Mozilla Firefox
C:\Users\%USERNAME%\AppData\Local\Mozilla\Firefox\Profiles\*
C:\Users\%USERNAME%\AppData\Roaming\Mozilla\Firefox\Profiles\*
        Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cookies.sqlite" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\webappsstore.sqlite" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\chromeappsstore.sqlite" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
# Google Chrome
C:\Users\%USERNAME%\AppData\Local\Google\Chrome\
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Media Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\ChromeDWriteFontCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
# Chromium
C:\Users\%USERNAME%\AppData\Local\Chromium\
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Chromium\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Chromium\User Data\Default\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Chromium\User Data\Default\Media Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Chromium\User Data\Default\Pepper Data\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Chromium\User Data\Default\Application Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
# Yandex

          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Yandex\YandexBrowser\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Yandex\YandexBrowser\User Data\Default\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Yandex\YandexBrowser\User Data\Default\Media Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Yandex\YandexBrowser\User Data\Default\Pepper Data\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Yandex\YandexBrowser\User Data\Default\Application Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
          Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Yandex\YandexBrowser\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
# Opera
Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Opera Software\Opera Stable\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose

# Internet Explorer
C:\Users\%USERNAME%\AppData\Local\Microsoft\Intern~1
C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\History
C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\Tempor~1
C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Cookies
        Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\WebCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
#>




<# Один из не работающих способов удалить профили старше 90 дн.
Конверторы дат:
# Solution 1
$LastUseDate = (Get-WMIObject -class Win32_UserProfile -ComputerName $PC).LastUsetime
[Management.ManagementDateTimeConverter]::ToDateTime($fucdate)
# Solution 2 (рабочий, что-то переводил):
([WMI] '').ConvertToDateTime($fucdate[1])
$fu = ([WMI] '').ConvertToDateTime($fucdate[1]).AddDays(-90)
([WMI] '').ConvertToDateTime($lastusetime)
$convert = ([WMI] '').ConvertToDateTime($_.$lastusetime)

# Советуют использовать этот командлет заместо gwmi :
Get-CimInstance -ClassName Win32_UserProfile -ComputerName $PC | Where-Object {(!$_.Special) -and ($_.ConvertToDateTime($_.LastUseTime) -lt (Get-Date).AddDays(-90))} | Measure-Object
(Get-CimInstance -ClassName Win32_OperatingSystem).InstallDate
$fuc = (Get-CimInstance -ClassName Win32_UserProfile).LastUseTime
$fuc = (Get-CimInstance -ClassName Win32_UserProfile -ComputerName $PC).LastUseTime


Get-Date $fucdate[1]
Get-WMIObject -class Win32_UserProfile -ComputerName $PC | Where-Object {(($_.Special) -ne $true) -and ($_.ConvertToDateTime($_.LastUseTime))} | ($_.LastUseTime).ConvertToDateTime
Get-WMIObject -class Win32_UserProfile -ComputerName $PC | $_.ConvertToDateTime($_.LastUseTime)
Get-WMIObject -class Win32_UserProfile -ComputerName $PC | Where-Object {($_.ConvertToDateTime($_.LastUseTime))} # | Out-GridView

# выведем список пользователей, профиль которых не использовался более 90 дней.
Get-WMIObject -class Win32_UserProfile -ComputerName $PC | Where-Object {(!$_.Special) -and ($_.ConvertToDateTime($_.LastUseTime) -lt (Get-Date).AddDays(-90))} | Measure-Object
# Удалить все эти профили:
Get-WMIObject -class Win32_UserProfile | Where-Object {(!$_.Special) -and (!$_.Loaded) -and ($_.ConvertToDateTime($_.LastUseTime) -lt (Get-Date).AddDays(-90))} | Remove-WmiObject –WhatIf
#Список аккаунтов, чьи профили нельзя удалять
$ExcludedUsers ="Public","Administrator","Администратор",'$user','Default'
$LocalProfiles=Get-WMIObject -class Win32_UserProfile | Where-Object {(!$_.Special) -and (!$_.Loaded) -and ($_.ConvertToDateTime($_.LastUseTime) -lt (Get-Date).AddDays(-90))}
foreach ($LocalProfile in $LocalProfiles)
# {if (!($ExcludedUsers -like $LocalProfile.LocalPath.Replace("C:\Users\",""))){
  {if (!($ExcludedUsers -like $LocalProfile.LocalPath.Replace($wc+'Users',""))){
$LocalProfile | Remove-WmiObject
Write-host $LocalProfile.LocalPath, "профиль удален" -ForegroundColor Magenta
}}
КОНЕЦ ШЛАКА #>






###################
# КОРЗИНА
<# Уменьшим корзину (нужно включать Удалённый реестр)
$Size=1024     # Size in MB
# $Volume=mountvol C:\ /L 
$Volume=mountvol $wc /L
$Guid=[regex]::Matches($Volume,'{([-0-9A-Fa-f].*?)}')
# $RegKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\"+$Guid.value
$RegKey=$PC+"\HKU\"+$sid+"\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\"+$Guid.value
New-ItemProperty -Path $RegKey -Name MaxCapacity -Value $Size -PropertyType "dword" -Force

New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null 
$LoggedOnSids = (Get-ChildItem HKU: | Where-Object { $_.Name -match '(S-([0-9-]*))|.DEFAULT$' }).PSChildName 
foreach ($sid in $LoggedOnSids) {
  # $RegKey="HKU:\"+$sid+"\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\"+$Guid.value
    $RegKey=$PC+"\HKU\"+$sid+"\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\"+$Guid.value
    try { New-ItemProperty -Path $RegKey -Name MaxCapacity -Value $Size -PropertyType "dword" -Force}
    catch { Write-Host 'Path not found' }
}   #>



# Очистка корзины
# Скрипт №1
# Мягкое удаление корзины:
$wcRecycle = "\\$PC\C$\`$Recycle.bin\S-1*\*"
Remove-Item -Path $wcRecycle -Exclude "desktop.ini" -Recurse -Force -Verbose # -ErrorAction SilentlyContinue 
#Remove-Item -Path "\\$PC\C$\`$Recycle.Bin\S-1*\*" -Exclude "desktop.ini"-Recurse -Force -Verbose  

# Грубое удаление корзины (Корзина заново заработает в течение суток):
# Remove-Item -Path \\$PC\C$\$Recycle.bin -Recurse -Force -Verbose  


# Скрипт №2 (Продвинутый. С указанием размера каждой Корзины и пользователя, которому она принадлежит)
<# Описание функции:   
Function Get-RecycleBinSize 
.SYNOPSIS 
This function will query and calculate the size of each users Recycle Bin Folder.  This function will also empty the Recycle Bin if the -Empty parameter is specified. 
.DESCRIPTION 
This function will query and calculate the size of each users Recycle Bin Folder.  The function uses the Get-ChildItem cmdlet to determine items in each users Recycle Bin Folder.  Remove-Item 
is used to remove all items in all Recycle Bin Folders.  The function uses WMI and the System.Security.Principal.SecurityIdentifier .NET Class to determine User Account to Recycle Bin 
Folder. Due to the number of objects and their values the default object output is in a "Format-List" format.  There may be SIDs that aren't translated for various reasons, the function 
will not return an error if it is unable to do so, it will however, return a $null value for the User property.  If there are a great number of items in the Recycle Bin Folders, the function 
will take a few minutes to calculate. 
.PARAMETER ComputerName 
A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME). 
.PARAMETER Drive 
A single Drive Letter or an array of Drive Letters to run the function against.  If the Drive 
parameter is not used, the function will check all "WMI Type 3" (Logical Fixed Disks) drive letters. 
The parameter will only accept, via RegEx, input that is formated as an actual drive letter C: or 
D: etc. 
.PARAMETER Empty 
The Empty parameter is used to Remove Items from the Recycle Bin Folders, according to what is 
queried.  Using the Empty parameter without the Drive parameter will Empty all the Recycle Bin 
Folders on the Local or Remote Computer. 
.EXAMPLE 
Get-RecycleBinSize -ComputerName SERVER01    # This example will return all the Recycle Bin Folders on the SERVER01 Computer. 
 
Computer : SERVER01 
Drive    : C: 
User     : SERVER01\Administrator 
BinSID   : S-1-5-21-3177594658-3897131987-2263270018-500 
Size     : 0 
 
.EXAMPLE 
Get-RecycleBinSize -ComputerName SERVER01 -Drive D: -Empty    # This example will Empty all the items in the Recycle Bin for the D: Drive. 


Function Get-RecycleBinSize 
{ [CmdletBinding()] 
param( 
 [Parameter(Position=0,ValueFromPipeline=$true)] 
 [Alias("CN","Computer")] 
 [String[]]$ComputerName="$env:COMPUTERNAME", 
 [ValidatePattern(".:")] 
 [String[]]$Drive, 
 [Switch]$Empty 
 ) 
 
Begin 
 { #Adjusting ErrorActionPreference to stop on all errors 
  $TempErrAct = $ErrorActionPreference 
  $ErrorActionPreference = "Stop" 
 }#End Begin Script Block 
Process 
 { Foreach ($Computer in $ComputerName) 
   {$Computer = $Computer.ToUpper().Trim() 
    Try 
     { # Указываем папку Корзины

      # Можно пропустить:
      # $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $PC $Computer #PC
      # Switch ($WMI_OS.BuildNumber) 
      # {#{$_ -le 3790} {$RecBin = "RECYCLER"} 
      #  #{$_ -ge 6000} {$RecBin = "`$Recycle.Bin"}
      #  {$_ -le 9999}  {$RecBin = "RECYCLER"} 
      #  {$_ -ge 10000} {$RecBin = "$Recycle.Bin"}
      #  }#End Switch ($WMI_OS.BuildNumber)

        $RecBin = "`$Recycle.Bin"

      If (!$Drive) # Если параметр -Drive в функции не указан
       {$WMI_LDisk = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $Computer -Filter "DriveType = 3" 
        Foreach ($LDisk in $WMI_LDisk) 
         {$Disk = $LDisk.DeviceID 
          $LDisk = $LDisk.DeviceID.Replace(":","$") 
          $Bins = Get-ChildItem -Path \\$Computer\$LDisk\$RecBin -Force 
          Foreach ($Bin in $Bins) 
           { If ($Empty) 
             {$Delete = $Bin.FullName + "\*" 
              Remove-Item -Path $Delete -Exclude "desktop.ini" -Force -Recurse 
             }#End If ($Empty) 
            $Size = Get-ChildItem -Path $Bin.FullName -Exclude "desktop.ini" -Force -Recurse 
            $Size = $Size | ForEach-Object {$_.Length} | Measure-Object -Sum 
             
            #Attempting to Convert the Recycle Bin "Folder" Name to the Users Account. 
            Try 
             {$UserSID = New-Object System.Security.Principal.SecurityIdentifier($Bin.Name) 
              $User = $UserSID.Translate([System.Security.Principal.NTAccount]) 
             }#End Try 
            Catch 
             {$User = $null }#End Catch 
            If (!$User) 
             {#Obtaining Local Account SIDs for $Bin.Name comparison. 
              $WMI_UsrAcct = Get-WmiObject -Class Win32_UserAccount -ComputerName $Computer -Filter "Domain = '$Computer'" 
              #Using a While Loop to search Local User Accounts for Matching $Bin.Name 
              $i = 0 
              While ($i -le $WMI_UsrAcct.Count) 
               {If ($WMI_UsrAcct[$i].SID -eq $Bin.Name) 
                 {$User = $WMI_UsrAcct[$i].Caption 
                  Break }  #End If ($WMI_UsrAcct[$i].SID -eq $Bin.Name) 
                $i++ 
               }#End While ($i -le $WMI_UsrAcct.Count) 
             }#End If (!$User) 
             
            #Creating Output Object 
            $RecInfo = New-Object PSObject -Property @{ 
            Computer=$Computer 
            Drive=$Disk
            User=$User 
            BinSID=$Bin.Name 
            #Size=$Size.Sum 
            Size=($Size.Sum / 1GB).ToString('F01')+ " GB"
            } 
            #Formatting Output Object 
            $RecInfo = $RecInfo | Select-Object Computer, Drive, User, BinSID, Size 
            $RecInfo 
           }#End Foreach ($Bin in $AllBins) 
         }#End Foreach ($Drv in $Drive) 
       }#End If ($Drive -eq $null) 
      If ($Drive)  # Если параметр -Drive в функции явно указан
       {Foreach ($Disk in $Drive) 
         {$MDisk = $Disk.Replace(":","$") 
          $Bins = Get-ChildItem -Path \\$Computer\$MDisk\$RecBin -Force 
          Foreach ($Bin in $Bins) 
           {If ($Empty) 
             {$Delete = $Bin.FullName + "\*" 
              Remove-Item -Path $Delete -Exclude "desktop.ini" -Force -Recurse 
             }#End If ($Empty) 
            $Size = Get-ChildItem -Path $Bin.FullName -Exclude "desktop.ini" -Force -Recurse 
            $Size = $Size | ForEach-Object {$_.Length} | Measure-Object -Sum 
             
            #Attempting to Convert the Recycle Bin "Folder" Name to the Users Account. 
            Try 
             {$UserSID = New-Object System.Security.Principal.SecurityIdentifier($Bin.Name) 
              $User = $UserSID.Translate([System.Security.Principal.NTAccount]) } # End Try 
            Catch 
             {$User = $null } #End Catch 
            If (!$User) 
             {#Obtaining Local Account SIDs for $Bin.Name comparison. 
              $WMI_UsrAcct = Get-WmiObject -Class Win32_UserAccount -ComputerName $Computer -Filter "Domain = '$Computer'" 
              #Using a While Loop to search Local User Accounts for Matching $Bin.Name 
              $i = 0 
              While ($i -le $WMI_UsrAcct.Count) 
               {If ($WMI_UsrAcct[$i].SID -eq $Bin.Name) 
                 {$User = $WMI_UsrAcct[$i].Caption 
                  Break } 
                $i++ 
               }#End While ($i -le $WMI_UsrAcct.Count) 
             }#End If (!$User) 
 
            #Creating Output Object 
            $RecInfo = New-Object PSObject -Property @{ 
            Computer=$Computer 
            Drive=$Disk.ToUpper()  # Можно не указывать, если чистим только диск C:
            User=$User 
            BinSID=$Bin.Name 
            Size=($Size.Sum / 1GB).ToString('F01')+ " GB"
            } 
            #Formatting Output Object 
            $RecInfo = $RecInfo | Select-Object Computer, Drive, User, BinSID, Size 
            $RecInfo 
           }#End Foreach ($Bin in $AllBins) 
         }#End Foreach ($Disk in $Drive) 
       }#End Else 
     }#End Try 
    Catch 
     { $Error[0].Exception.Message } # End Catch 
   } # End Foreach ($Computer in $ComputerName) 
 } # End Process 
End 
 {#Resetting ErrorActionPref 
  $ErrorActionPreference = $TempErrAct } # End End 
}#End Function

''
# Если необходимо очистить все диски, убрать: -Drive C:
Write-host 'Текущие объёмы корзин пользователей:' -ForegroundColor Magenta
Get-RecycleBinSize -ComputerName $PC -Drive C: 
Write-host 'Очистка корзин:' -ForegroundColor Magenta
Get-RecycleBinSize -ComputerName $PC -Drive C: -Empty
#>


Get-WmiObject -Class Win32_diskdrive -ComputerName $PC | Format-Table -Property Model, @{Label="Size(GB)"; Expression={$_.Size/1Gb}} -AutoSize

# ''
[Environment]::NewLine
# Окончательный вывод:
Write-host 'Было :' -ForegroundColor Magenta
"Disk " + $p.DeviceID + " FreeSpace : {0}" -f ($p.FreeSpace / 1GB).ToString("F01") + ' GB'
Write-host 'Стало :' -ForegroundColor Magenta
$pi = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | Where-Object {$_.deviceid -like 'C:'}
"Disk " + $pi.DeviceID + " FreeSpace : {0}" -f ($pi.FreeSpace / 1GB).ToString("F01") + ' GB'

# ''
[Environment]::NewLine
$d2 = Get-Date
'Процесс очистки компьютера занял:'
$d2 - $d1 | Select-Object Days, Hours, Minutes | Out-Host
# ''
[Environment]::NewLine


Write-host "Ошибки, на которые можно обратить внимание, а можно и не обращать:" -ForegroundColor Magenta
# ''
[Environment]::NewLine
# Write-host "$ErrAct1" -ForegroundColor Magenta
$ErrAct1
# ''
[Environment]::NewLine
# Write-host "$ErrAct2" -ForegroundColor Magenta
$ErrAct2
# ''
[Environment]::NewLine


<#
}else {"ПК - "+ $PC + " недоступен" #}
'Скрипт переведён в режим постоянного отправления пингов. Как только ПК появится в сети - сразу продолжит работу.'
'Не забудь взять заявку в работу, чтобы твой коллега не сделал того же самого с этим же компом'
'Для прекращения работы скрипта команда: CNTL + C'
do {$Ping = (Test-Connection -ComputerName $PC -Quiet)} while ($Ping -eq $False)}
#>