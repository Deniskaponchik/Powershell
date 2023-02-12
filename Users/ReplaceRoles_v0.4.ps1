# Version: 0.4
# Цель: Просмотр и изменение ролей пользователя в AD
# Реализация: Внешняя функция замены ФИО в логин\
# Проблемы:
# Вопросы / Предложения: denis.tirskikh@tele2.ru

"`n"
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
$u, $us, $user = $null


 . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Users\UserLogin_v0.5.ps1
 $UserProp = UserLogin
 $User =  $UserProp.SamAccountName



 [Environment]::NewLine

# Выводим список ролей пользователя на экран
# Get-AdUser $user -Properties memberof | Select-Object memberof -expandproperty memberof
  Get-ADPrincipalGroupMembership $User | Sort-Object | Select-Object -ExpandProperty name

[Environment]::NewLine
write-host "Список текущих ролей пользователя представлен сверху" -ForegroundColor Red


$AddPopRoles = 'Sys SD BPM7.9Lic', 'Sys WIKI HI Editors', 'Role CovidVpn', 'Role CovidVpnRDP'
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


[Environment]::NewLine
<#
if (($ga = Read-Host "ДОБАВИТЬ роль") -ne "") { # Если нужно добавить роль, пишем что именно
  do {
    Add-ADGroupMember -Identity $ga -Members $user -Confirm:$false -ErrorVariable ErrAddGM
  }
  while ($ErrAddGM)
  write-host "$ga успешно добавлена" -ForegroundColor Green
}
#>
do {
  if (($ga = Read-Host "ДОБАВИТЬ роль") -ne "")  {# Если нужно добавить роль, пишем что именно
    Add-ADGroupMember -Identity $ga -Members $user -Confirm:$false -ErrorVariable ErrAddGM
  }  
} while ($ErrAddGM)
if ($ga -ne "") {
  write-host "$ga успешно добавлена" -ForegroundColor Green
}

do {
  if (($gd = Read-Host "УДАЛИТЬ роль") -ne "") { # Если нужно удалить роль, пишем что именно
      Remove-ADGroupMember -Identity $gd -Members $user -Confirm:$false -ErrorVariable ErrRemGM
    # Remove-ADGroupMember -Identity "Role CovidVPN" -Members denis.tirskikh -Confirm:$false -ErrorVariable ErrRemGM
    # Get-ADPrincipalGroupMembership denis.tirskikh | Sort-Object | Select-Object -ExpandProperty name | Where-Object "Role CovidVpn Pilot"
    # Get-ADGroupMember -Identity "Role CovidVPN" | Where-Object name -like denis.tirskikh
    # Remove-ADGroupMember -Identity "Role CovidVPN" -Members denis.tirskikh -Confirm:$false -Verbose
  }  
} while ($ErrRemGM)
if ($gd -ne "") {
  write-host "$gd успешно удалена!" -ForegroundColor Green
}
<# OLD WORKED!!!
if (($gd = Read-Host "УДАЛИТЬ роль") -ne "") {
    $Error[0] = $null
  # $gd = Read-Host "УДАЛИТЬ роль"
    Remove-ADGroupMember -Identity $gd -Members $user -Confirm:$false
  # Remove-ADGroupMember -Identity Role ZI -Members test.zi.user -Confirm:$false
    if ($Error[0] -notlike '*удается найти объект*'){
      write-host "$gd успешно удалена!" -ForegroundColor Green
    }
}
#>



# write-host "$ga успешно добавлена, $gd успешно удалена!" -ForegroundColor Green
''
# Припас на массовый случай изменения:
# ForEach ($user in $users){
# Write-host $user	

Get-ADPrincipalGroupMembership $User | Sort-Object | Select-Object -ExpandProperty name

 # }




write-host "`n"
# Логирование НОВОЕ через БД MS SQL Server
$AdminLogin = $env:USERNAME
$DateStart = Get-Date
$ScriptName= $MyInvocation.MyCommand.Name
$FeedBack = Read-Host "Напиши в свободной форме, как улучшить скрипт "
. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WsirIt01_ScriptEx_v0.0.ps1
ScriptsExecute -Operation Insert -AdminLogin $AdminLogin -DateStart $DateStart -ScriptName $ScriptName -DateEnd $DateStart -FeedBack $FeedBack


[Environment]::NewLine