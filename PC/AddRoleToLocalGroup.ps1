<# 
  !!!   R E A D   M E   !!!
Популярные локальные группы (скопировать и вставить, когда скрипт запросит):
 
для возможности изменения ip-адреса машины для инженеров базовых станций и сетевиков:
Операторы настройки сети
Network Configuration Operator
 
Администраторы
Administartors

Пользователи удаленного рабочего стола
Remote Desktop Users

Role CovidVpn
Role CovidVpnRDP
Role CovidVpnCC 
 

Общая структура скрипта:
$User = [ADSI]"WinNT://домен/учетка,user"
$Group = [ADSI]"WinNT://домен/комп/Администраторы,group"
$Group.Invoke("Add",$User.PSBase.Path)
#>

# Старая схема:
# if (($u = Read-Host "Логин пользователя") -ne "") {$User = [ADSI]"WinNT://t2ru/$u,user"}

''
#
$u = $null
$us = ''
$user = $Null
# новый идеальный код:
do {$Error[0] = $null
  $lo = $Null
if ($null -eq $u) {$u = Read-Host "Логин или ФИО, у которого есть необходимая группа"}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {$u = $us.SamAccountName
  $lo = 1}
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {$u
            Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $Null -eq $us -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  # $u.count -eq 1 -or 
# $user = Get-ADUser -identity $u -properties *
Get-ADPrincipalGroupMembership $u | Sort-Object | Select-Object -ExpandProperty name
# $user = [string]$user.SamAccountName
# $User = [ADSI]"WinNT://t2ru/$user,user"
#>

[Environment]::NewLine
do {
  $ADG = Read-Host "Название группы в AD, которую добавить (можно Выделить->Вставить)"
} while ($ADG -eq "")
$ADgroup = [ADSI]"WinNT://t2ru/$PC/$ADG,group"

<#
$ADG = Read-Host "Название группы в AD, которую добавить (можно Выделить->Вставить)"
# if (($ADgroup = Read-Host "Название группы в AD, которую добавить (можно Выделить->Вставить)") -ne "") {
  if ($ADgroup -ne "") {
      $ADgroup = [ADSI]"WinNT://t2ru/$PC/$g,group"
  # $Group_Test = Test-Connection -"$PC/Операторы настройки сети,group"
  # if ($Group_Test -eq $true){ 
}
#>

do {$PC = Read-Host "Имя компьютера"}
while ((Test-Connection $PC -Quiet) -eq $False){}
# if (($p = Read-Host "Имя компьютера") -ne "") {$PC = "$p"}
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
if (($LG = Read-Host "Название локальной группы, в которую добавить") -ne "") {
     $LocalGroup = [ADSI]"WinNT://t2ru/$PC/$LG,group"
   # Get-LocalGroupMember
   # [ADSI]$group = "WinNT://$computer/$Name,group"
   # $members = $group.invoke("Members") 
 }

if ($LocalGroup.Invoke("Add",$ADgroup.PSBase.Path)) {
   # else {
   # $Group = [ADSI]"WinNT://t2ru/$PC/Network Configuration Operator,group"
   # $Group.Invoke("Add",$User.PSBase.Path)}
 }
else {
   write-host "Группа $ADG успешно добавлена в $LG на $PC!" -ForegroundColor Green
   write-host "`n"
 }
