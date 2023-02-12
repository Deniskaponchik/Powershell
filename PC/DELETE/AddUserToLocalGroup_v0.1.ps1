<# 
  !!!   R E A D   M E   !!!
Популярные локальные группы для добавления (скопировать и вставить, когда скрипт запросит):
 
для возможности изменения ip-адреса машины для инженеров базовых станций и сетевиков:
Операторы настройки сети
Network Configuration Operator
 
Администраторы
Administartors

Пользователи удаленного рабочего стола
Remote Desktop Users

 

Общая структура скрипта:
$User = [ADSI]"WinNT://домен/учетка,user"
$Group = [ADSI]"WinNT://домен/комп/Администраторы,group"
$Group.Invoke("Add",$User.PSBase.Path)
#>



''
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
$user, $u, $us, $login, $ADSIuser = $Null

# новый идеальный код:
do {$Error[0] = $null
  $lo = $Null
if ($null -eq $u) {$u = Read-Host "Логин или ФИО"}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {$u = $us.SamAccountName
  $lo = 1}
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {$u
            Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $Null -eq $us -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  # $u.count -eq 1 -or 

$user = Get-ADUser -identity $u -properties *
$login = [string]$user.SamAccountName
$ADSIuser = [ADSI]"WinNT://t2ru/$user,user"


do {$PC = Read-Host "Имя компьютера"}
while ((Test-Connection $PC -Quiet) -eq $False){}
# if (Test-Connection -ComputerName $PC -Quiet)

[Environment]::NewLine
write-host  'Примеры локальных групп для добавления:'  -ForegroundColor Green
'Операторы настройки сети'
'Network Configuration Operator'
'Администраторы'
'Administartors'
'Пользователи удаленного рабочего стола'
'Remote Desktop Users'

[Environment]::NewLine
if (($g = Read-Host "Локальная группа, в которую добавить") -ne "") {
     $Group = [ADSI]"WinNT://t2ru/$PC/$g,group"
   # $Group_Test = Test-Connection -"$PC/Операторы настройки сети,group"
   # if ($Group_Test -eq $true){ 
 }

if ($Group.Invoke("Add",$ADSIlogin.PSBase.Path)) {
   # else {
   # $Group = [ADSI]"WinNT://t2ru/$PC/Network Configuration Operator,group"
   # $Group.Invoke("Add",$User.PSBase.Path)}
 }
else {
   write-host "Пользователь успешно добавлен в $g на $PC!" -ForegroundColor Green
   write-host "`n"
 }
