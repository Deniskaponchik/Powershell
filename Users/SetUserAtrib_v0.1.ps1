# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Users\SetUserAtrib_v0.1.ps1

<# 
Массовая смена атрибутов из файла:
Import-CSV -Path "D:\Scripts\AddAtrib.csv" -Delimiter ";" -Encoding Default | foreach {

#переменные для замены атрибитутов (можно оставлять в таблице пустые ячейки):
$login = $_.'login'
$employeeid = $_.'employeeId(#outstaff)'
$SapGivenName = $_.'sapGivenName(ИмяНаРусском)'
$SapSurName = $_.'sapSurName(ФамилияНаРусском)'
$mobile = $_.'mobile(+7)'
$MobilePhone = $_.'MobilePhone(+7)'

#фильтрация
$user = Get-ADUser -Filter {samaccountname -eq $login} 
# if ($user){
#ну и сама замена
Set-ADUser $user -Replace @{employeeid = $employeeid}
Set-ADUser $user -Replace @{sapGivenName = $SapGivenName}
Set-ADUser $user -Replace @{sapSurName = $SapSurName}
Set-ADUser $user -Replace @{mobile = $mobile}
Set-ADUser $user -Replace @{MobilePhone = $MobilePhone}
# }
 }
write-host "`n"
write-host "Атрибуты из заполненных ячеек из файла AllAtrib.csv успешно внесены!" -ForegroundColor Green
write-host "`n"
#>
 
''
# Единичная замена параметров через запрос (не нужное можно оставлять пустым, может выдавать ничего не значащие ошибки):
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
$u, $user = $null
$us = ''
# новый идеальный код:
do {$Error[0] = $null
  $lo = $Null
if ($null -eq $u) {$u = Read-Host "Логин или ФИО или Фамилия"}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {$u = $us.SamAccountName
  $lo = 1}
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {$u
            Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  # $u.count -eq 1 -or 
$user = Get-ADUser -identity $u -properties *


# Get-ADUser -Filter {DisplayName -like "Тирских Денис*"} -Properties *
# Get-ADUser -Filter {DisplayName -like $User*} -Properties *
  Get-ADUser $user -Properties *

pause
[Environment]::NewLine
Write-Host "ENTER - Атрибуты, которые не нужно менять" -ForegroundColor Green
Write-Host "ПРОБЕЛ - СТЕРЕТЬ атрибут. СДЕЛАТЬ пустым" -ForegroundColor Red
[Environment]::NewLine

  $employeeid = Read-Host "employeeid (ID физлица) (Пример: outstaff)"
  $SapGivenName = Read-Host "SapGivenName (имя на кириллице)"
  $SapSurName = Read-Host "SapSurName (фамилия на кириллице)"
  $mobile = Read-Host "mobile(+7)"
  $MobilePhone = Read-Host "MobilePhone(+7)"
  $AvayaPhone = Read-Host "Avaya Phone"
  $Office = Read-Host "Кабинет / Office"
[Environment]::NewLine

<# ЭТО РАБОЧЕЕ:
Set-ADUser -Identity $user -Replace @{employeeid=$employeeid}
Set-ADUser -Identity $user -Replace @{sapGivenName=$SapGivenName}
Set-ADUser -Identity $user -Replace @{sapSurName=$SapSurName}
Set-ADUser -Identity $user -Replace @{mobile=$mobile}
Set-ADUser -Identity $user -Replace @{MobilePhone=$MobilePhone}
#>
try {Set-ADUser -Identity $user -Replace @{employeeid=$employeeid}}
catch {Write-Host  "Параметр Employeeid не задан и сменён не был" -ForegroundColor Red}

try {Set-ADUser -Identity $user -Replace @{sapGivenName=$SapGivenName}}
catch {Write-Host  "Параметр SapGivenName не задан и сменён не был" -ForegroundColor Red}

try {Set-ADUser -Identity $user -Replace @{sapSurName=$SapSurName}}
catch {Write-Host  "Параметр SapSurName не задан и сменён не был" -ForegroundColor Red}

try {Set-ADUser -Identity $user -Replace @{mobile=$mobile}}
catch {Write-Host  "Параметр Mobile не задан и сменён не был" -ForegroundColor Red}

try {Set-ADUser -Identity $user -Replace @{MobilePhone=$MobilePhone}}
catch {Write-Host  "Параметр MobilePhone не задан и сменён не был" -ForegroundColor Red}

try {Set-ADUser -Identity $user -Replace @{MobilePhone=$MobilePhone}}
catch {Write-Host  "Параметр MobilePhone не задан и сменён не был" -ForegroundColor Red}

try {Set-ADUser -Identity $user -Replace @{otherTelephone=$AvayaPhone}}
catch {Write-Host  "Параметр otherTelephone не задан и сменён не был" -ForegroundColor Red}

try {Set-ADUser -Identity $user -Replace @{physicalDeliveryOfficeName=$Office}}
catch {Write-Host  "Параметр Office не задан и сменён не был" -ForegroundColor Red}

[Environment]::NewLine


# Включаем учётку:
  Set-ADUser $User -Enabled:$true

# Итоговый вывод атрибутов
  Get-ADUser $user -Properties *