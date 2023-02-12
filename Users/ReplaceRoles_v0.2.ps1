<# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Users\ReplaceRolesV0.2.ps1

   !!!   R E A D   M E   !!!
Популярные группы для замены (скопировать и вставить, когда скрипт запросит):
 
Role CovidVpn
Role CovidVpnRDP
Role CovidVpnCC
Role Covid Token
 
Role Teleworker Tech
Role Rdsapp Access

Sys WIKI HI Editors
Sys WIKI IT_Support Editors
#> 

"`n"
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
$u, $us, $user = $null

# Подключение логинов из файла:
# $users = Get-Content D:\Scripts\users.txt

do {$Error[0] = $null
   $lo = $Null
 if ($null -eq $u) {$u = Read-Host "Логин или ФИО"}
   if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {$u = $us.SamAccountName
   $lo = 1}
   elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
             $u = $us.SamAccountName #.count
             if ($u.count -gt 1 ) {$u
             Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
 while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  # $u.count -eq 1 -or 
 $user = Get-ADUser -identity $u -properties *

 $user.SamAccountName
 [Environment]::NewLine

# Выводим список ролей пользователя на экран
# Get-AdUser $user -Properties memberof | Select-Object memberof -expandproperty memberof
  Get-ADPrincipalGroupMembership $User | Sort-Object | Select-Object -ExpandProperty name

[Environment]::NewLine
write-host "Список текущих ролей пользователя представлен сверху" -ForegroundColor Red


$AddPopRoles = 'Sys SD BPM7.9Lic', 'Sys WIKI HI Editors'
[Environment]::NewLine
write-host "Популярный список ролей для добавления:" -ForegroundColor Red
$AddPopRoles

$DelPopRoles = ''
[Environment]::NewLine
write-host "Популярный список ролей для удаления:" -ForegroundColor Red
$DelPopRoles


[Environment]::NewLine
write-host "Продолжаем скрипт для добавления/удаления ролей?" -ForegroundColor Red
Pause



if (($ga = Read-Host "ДОБАВИТЬ роль") -ne "") {
    $Error[0] = $null
  # $ga = Read-Host "ДОБАВИТЬ роль"
    Add-ADGroupMember -Identity $ga -Members $user -Confirm:$false -ErrorVariable ErrAddGM
  # Add-ADGroupMember -Identity Role ZI -Members test.zi.user -Confirm:$false
  # if ($Error[0] -notlike '*удается найти объект*')
    if (!$ErrAddGM) 
    {write-host "$ga успешно добавлена" -ForegroundColor Green}

  <# Не сработало:
  # if(Add-ADGroupMember -Identity $ga -Members $user -Confirm:$false -ErrorVariable ErrAddGM){write-host "$ga успешно добавлена" -ForegroundColor Green}
  # else {write-host "$ga НЕ добавлена" -ForegroundColor Red}
  # Не сработало:
    if (!$ErrADGM) {write-host "$ga успешно добавлена" -ForegroundColor Green}
  # if ($ErrADGM) {write-host "$ga успешно добавлена" -ForegroundColor Green}
    else {write-host "$ga НЕ добавлена" -ForegroundColor Red}
  #>
}

if (($gd = Read-Host "УДАЛИТЬ роль") -ne "") {
    $Error[0] = $null
  # $gd = Read-Host "УДАЛИТЬ роль"
    Remove-ADGroupMember -Identity $gd -Members $user -Confirm:$false
  # Remove-ADGroupMember -Identity Role ZI -Members test.zi.user -Confirm:$false
    if ($Error[0] -notlike '*удается найти объект*'){write-host "$gd успешно удалена!" -ForegroundColor Green}
}

# write-host "$ga успешно добавлена, $gd успешно удалена!" -ForegroundColor Green
''
# Припас на массовый случай изменения:
# ForEach ($user in $users){
# Write-host $user	

Get-ADPrincipalGroupMembership $User | Sort-Object | Select-Object -ExpandProperty name

 # }
write-host "`n"