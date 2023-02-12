<# \\t2ru\folders\IT-Support\Scripts\ADUsers\ReplaceRolesV0.1.ps1

   !!!   R E A D   M E   !!!
Популярные группы для замены (скопировать и вставить, когда скрипт запросит):
 
Role CovidVpn
Role CovidVpnRDP
Role CovidVpnCC
Role Covid Token
 
Role Teleworker Tech
Role Rdsapp Access

Sys WIKI HI Editors

#> 

"`n"
# Подключение логинов из файла:
# $users = Get-Content D:\Scripts\users.txt

# Запрос логина:
# $user = Read-Host "Логин пользователя"

$u = $null
$us = ''
$user = $Null
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


# Get-AdUser $user -Properties memberof | Select-Object memberof -expandproperty memberof
Get-ADPrincipalGroupMembership $User | Sort-Object | Select-Object -ExpandProperty name

write-host "Список текущих ролей пользователя. Продолжаем скрипт?" -ForegroundColor Red
Pause

if (($ga = Read-Host "ДОБАВИТЬ роль") -ne "") {
  # $ga = Read-Host "ДОБАВИТЬ роль"
    Add-ADGroupMember -Identity $ga -Members $user -Confirm:$false -ErrorVariable ErrAddGM
  # Add-ADGroupMember -Identity Role ZI -Members test.zi.user -Confirm:$false

  # if(Add-ADGroupMember -Identity $ga -Members $user -Confirm:$false -ErrorVariable ErrAddGM){write-host "$ga успешно добавлена" -ForegroundColor Green}
  # else {write-host "$ga НЕ добавлена" -ForegroundColor Red}
  
  if (!$ErrADGM) {write-host "$ga успешно добавлена" -ForegroundColor Green}
  #if ($ErrADGM) {write-host "$ga успешно добавлена" -ForegroundColor Green}
  else {write-host "$ga НЕ добавлена" -ForegroundColor Red}
  #>
}

if (($gd = Read-Host "УДАЛИТЬ роль") -ne "") {
 #$gd = Read-Host "УДАЛИТЬ роль"
 Remove-ADGroupMember -Identity $gd -Members $user -Confirm:$false
 #Remove-ADGroupMember -Identity Role ZI -Members test.zi.user -Confirm:$false
 write-host "$gd успешно удалена!" -ForegroundColor Green
}
# write-host "$ga успешно добавлена, $gd успешно удалена!" -ForegroundColor Green
''
# Припас на массовый случай изменения:
# ForEach ($user in $users){
# Write-host $user	

Get-ADPrincipalGroupMembership $User | Sort-Object | Select-Object -ExpandProperty name

 # }
write-host "`n"