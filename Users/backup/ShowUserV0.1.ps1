﻿# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Users\ShowUserV0.1.ps1

# просто посмотреть все атрибуты пользователя:
# Get-ADUser denis.tirskikh  -Properties *   #  anatoly.broner    alla.pleshkova   denis.tirskikh  olga.khaimova

"`n"
$po = $Null

# новый идеальный код:
$u = $null
$us = ''
$user = $Null
do {$Error[0] = $null
  $lo = $Null
if ($null -eq $u) {$u = Read-Host "Логин или ФИО "}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {$u = $us.SamAccountName
  $lo = 1}
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {$u
            Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  # $u.count -eq 1 -or 
$user = Get-ADUser -identity $u -properties *
''
#>



<# Старый полностью рабочий код:
do {$Error[0] = $null
$u = Read-Host "Логин (оставь пустым, если укажешь ФИО)"
$fio = Read-Host "ФИО (оставь пустым, если указал логин)"
if ($fio -ne "") {     #$fio =[string]$fi     # Поиск по ФИО:
                       #$us = Get-ADUser -Filter {(displayname -like $fio)} -Properties "SamAccountName" # | Select-Object SamAccountName
  if ($null -eq ($us = Get-ADUser -Filter "displayname -like '$fio'")) {$us = Get-ADUser -Filter "displayname -like '$fio*'"}
  #                      $us = Get-ADUser -Filter "displayname -like '$fio'"
  #if ( $null -eq $us ) {$us = Get-ADUser -Filter "displayname -like '$fio*'"} # -Properties "SamAccountName"}     #$us.count = 0
  $u = $us.SamAccountName
    if ($u.count -gt 1 ) {$u
    Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED
    $u = Read-Host "Логин пользователя"} 
    #else {$u = $us.SamAccountName}
}  $user = Get-ADUser -identity $u -properties * }  #}
while ($u -eq '' -or $Null -eq $u -or $Error[0] -like '*найти объект*' -or $Error[0] -like '*преобразовать*')
#>



#if($s -eq 0){$user = Get-ADUser -identity $u -properties *}
#else {$user= Get-ADUser -filter { (displayname -like $u) -and (userAccountControl -eq "512")} -properties *}



# Write-Host "Формат вывода дат: МЕСЯЦ / ДЕНЬ / ГОД" -ForegroundColor Red
# New-Object PsObject -Property @{

# ФИО = [string]$user.cn 
# ФИО = [string]$user.displayname
 "ФИО           :{0}" -f $user.displayname

# Должность = [string]$user.description   # Показывает не совсем то
# Должность = [string]$user.title 
 "Должность     :{0}" -f $user.title 

# Отдел = [string]$user.department
 "Отдел         :{0}" -f $user.department

# GivenName = [string]$user.givenname
# Логин = [string]$user.userprincipalname
# Логин = [string]$user.SamAccountName 
 "Логин         :{0}" -f $user.SamAccountName

# employeeID = [string]$user.employeeid
 "employeeID    :{0}" -f $user.employeeid

# mail = [string]$user.mail
 "Mail          :{0}" -f $user.mail

# Руководитель = [string]$user.manager.Replace(",OU=Branches,DC=corp,DC=tele2,DC=ru","")

# OfficePhone = [string]$user.officePhone
# Avaya = [string]$user.otherTelephone
#"Avaya         :{0}" -f $user.otherTelephone
 "Avaya         :" + $user.otherTelephone
# Мобильный = [string]$user.mobilePhone
 "Мобильный     :{0}" -f $user.mobilePhone
# Телефон2 = [string]$user.telephonenumber
# Телефон = [string]$user.ipPhone
 "Телефон       :{0}" -f $user.ipPhone

# Комната = [string]$user.physicaldeliveryofficename
# Макрорегион = [string]$user.st
 "Макрорегион   :{0}" -f $user.st

# Функция = [string]$user.office
"Функция       :{0}" -f $user.office

# OU = [string]$user.distinguishedName.Replace(",OU=Branches,DC=corp,DC=tele2,DC=ru","") #.remove(35)
# OU = [string]$user.distinguishedName.split(",")[-5]
 "OU            :{0}" -f $user.distinguishedName.split(",")[-5]

# }  # | Sort-Object -Type        #  | Export-Csv -NoClobber -Encoding utf8 -Path  D:\Scripts\TEST.csv


'' 
#"##################################################"
# $pass = Get-ADUser -identity $user -properties *

"Дата создания УЗ                 : " + $user.whencreated.DateTime
"Дата установки пароля            : " + $user.PasswordLastSet.DateTime
"Дата ввода неправильного пароля  : " + $user.LastBadPasswordAttempt.DateTime
#"Учётка актвна?                 : " 
if ($user.PasswordExpired) {Write-Host 'СРОК ДЕЙСТВИЯ ПАРОЛЯ ИСТЁК!!!' -ForegroundColor RED} 
if ($user.userAccountControl -eq 512 -or $user.userAccountControl -eq 66048) {'Учётка Активна'} 
else{Write-Host 'Учётка Заблокирована' -ForegroundColor RED
#"Description                      : " + $user.Description
$des = $user.Description
Write-Host "$Des" -ForegroundColor RED
}
#"Учётка актвна?                   : " + -not [bool]($user.userAccountControl[0] -band $ACCOUNTDISABLE)
#"##################################################"
''

$t = [string]$user.title       # Должность
$o = [string]$user.department  # Отдел
$f = [string]$user.office      # Функция
$m = [string]$user.st          # Макрорегион
[array]$tofm = $t,$o,$f,$M


[array]$Compet = 'Центр компетенций CRM','Центр компетенций ERP','Центр компетенций Data','Центр компетенций больших данных','Центр компетенций данных','Центр компетенций интеграции'
[array]$IT = 'Отдел технической поддержки пользователей','Центральная функция. Билинг и ИТ'

[array]$CP = 'Омск Центральная Функция','Центральная функция. Центр Планирования'#,'Нижний Новгород центральная функция'
[array]$NOC = 'Центральная функция. Центр обслуживания сети'
[array]$Engin = 'Департамент по эксплуатации сети','Группа по обслуживанию сети',`
'Группа по эксплуатации и планированию транспортной сети','Отдел по развитию транспортных сетей',`
'Группа эксплуатации базовых станций и транспортной сети','Отдел эксплуатации',`
'Отдел подсистем голосовой коммутации','Группа подсистем голосовой коммутации'
[array]$EnginRazv = 'Отдел развития','Департамент по развитию сети'

[array]$Rouming = 'Департамент роуминга'
[array]$COP = 'Отдел операционной поддержки технической функции'
[array]$OCO = 'Центральная функция. Общий Центр Обслуживания', 'Воронеж Центральная Функция'
[array]$Nalog = 'Дирекция по налогам'
[array]$Retail = 'Тренер розничной сети','Старший тренер розничной сети','Служба Теле2 Ритейл','Служба по развитию массового рынка'
[array]$Corp = 'Департамент по развитию корпоративного бизнеса'
[array]$director = ''

# Второй монитор:      (Внести: Старший специалист по управлению контентом , * по взаиморасчетам * , )
[array]$AllMon = $OCO + $COP + $EnginRazv + $Compet + $IT + $Engin + $CP + $NOC
# Увеличение ОЗУ:
[array]$AllOzu = $Compet + $IT + $Engin + $CP + $NOC
# ПК повышенной производительности:
[array]$AllPC = $Compet + $IT + $Engin + $CP + $NOC
# Монитор или ОЗУ или ПК:
# [array]$Allmop = $AllMon + $AllOZu + $AllPC
# Ноутбук:
[array]$AllNout = $Retail + $Corp + $Director + $Rouming + $Engin + $CP

# СУПЕРстандарт для налоговиков:
[array]$AllNalog = $Nalog

'Должность сотрудника позволяет ему получить:'
# Switch
$SwiAll = switch ($true) {
# {Compare-Object $tofm $AllMOP -includeEqual -excludeDifferent -PassThru} {"Должность сотрудника позволяет ему получить без визы директора:"}
  {Compare-Object $tofm $AllMon -includeEqual -excludeDifferent -PassThru} {Write-Host "Второй монитор" -ForegroundColor Magenta}
  {Compare-Object $tofm $AllOZu -includeEqual -excludeDifferent -PassThru} {Write-Host 'Озу сверх стандарта' -ForegroundColor Magenta}
  {Compare-Object $tofm $AllPC -includeEqual -excludeDifferent -PassThru} {Write-Host 'Системный блок повышенной производительности' -ForegroundColor Magenta}
  {Compare-Object $tofm $AllNalog -includeEqual -excludeDifferent -PassThru} {Write-Host 'Ноутбук + 2 МОНИТОРА К НЕМУ + Док-станция' -ForegroundColor Magenta}
  {Compare-Object $tofm $AllNout -includeEqual -excludeDifferent -PassThru} {Write-Host 'Должность сотрудника предполагает использование ноутбука' -ForegroundColor Magenta}
  Default {'Ничего'}
} $SwiAll
''

<# 
Второй монитор:   (Внести: ЦОП ???, Старший специалист по управлению контентом)
[array]$TitMon = 0
[array]$DepMon = 'Отдел технической поддержки пользователей',`
'Департамент по эксплуатации сети','Группа по эксплуатации и планированию транспортной сети',`
'Отдел развития','Отдел операционной поддержки технической функции',`
'Центр компетенций CRM','Центр компетенций ERP','Центр компетенций Data','Центр компетенций больших данных','Центр компетенций данных','Центр компетенций интеграции',`
'Группа по эксплуатации и планированию транспортной сети','Отдел подсистем голосовой коммутации','Группа подсистем голосовой коммутации'
[array]$FunMon = 'Омск Центральная Функция','Нижний Новгород центральная функция','Воронеж Центральная Функция'
[array]$MakMon = 'Центральная функция. Центр Планирования','Центральная функция. Билинг и ИТ','Центральная функция. Общий Центр Обслуживания'
[array]$AllMon = $TitMon + $DepMon + $FunMon + $MakMon

# Увеличение ОЗУ:
[array]$TitOzu = 0
[array]$DepOzu = 'Отдел технической поддержки пользователей','Департамент по эксплуатации сети','Группа по эксплуатации и планированию транспортной сети',`
'Центр компетенций CRM','Центр компетенций ERP','Центр компетенций Data','Центр компетенций больших данных','Центр компетенций данных','Центр компетенций интеграции',`
'Отдел подсистем голосовой коммутации','Группа подсистем голосовой коммутации'
[array]$FunOzu = 'Омск Центральная Функция','Нижний Новгород центральная функция'
[array]$MakOzu = 'Центральная функция. Центр Планирования','Центральная функция. Билинг и ИТ'
[array]$AllOzu = $TitOzu + $DepOzu + $FunOzu + $MakOzu

# ПК повышенной производительности:
[array]$TitPC = 0
[array]$DepPC = 'Отдел технической поддержки пользователей',`
'Департамент по эксплуатации сети','Группа по эксплуатации и планированию транспортной сети',`
'Отдел подсистем голосовой коммутации','Группа подсистем голосовой коммутации',`
'Центр компетенций CRM','Центр компетенций ERP','Центр компетенций Data','Центр компетенций больших данных','Центр компетенций данных','Центр компетенций интеграции',`
''
[array]$FunPC = 'Омск Центральная Функция','Нижний Новгород центральная функция'
[array]$MakPC = 'Центральная функция. Центр Планирования','Центральная функция. Билинг и ИТ'
[array]$AllPC = $TitPC + $DepPC + $FunPC + $MakPC

# Ноутбук:
[array]$TitNout = 'Тренер розничной сети','Старший тренер розничной сети'
[array]$DepNout = 'Служба Теле2 Ритейл',`
'Группа по эксплуатации и планированию транспортной сети','Департамент по эксплуатации сети'
[array]$FunNout = 'Омск Центральная Функция','Нижний Новгород центральная функция'
[array]$MakNout = 'Центральная функция. Центр Планирования'
[array]$AllNout = $TitNout + $DepNout + $FunNout + $MakNout
#>

<#
$switch = switch ($t,$o,$f,$m) {
  ($TitMon,$DepMon,$FunMon,$MakMon) {'Второй монитор'}
  ($TitOzu,$DepOzu,,$FunOzu,$MakOzu) {'Озу сверх стандарта'}
  ($TitPC,$DepPC,$FunPC,$MakPC) {'Системный блок повышенной производительности'}
  Default {'Ничего'}
} $switch
<#
$switch = switch ($t,$o,$f,$m) {
  ($TitMon -or $DepMon -or $FunMon -or $MakMon) {'Второй монитор'}
  ($TitOzu -or $DepOzu -or $FunOzu -or $MakOzu) {'Озу сверх стандарта'}
  ($TitPC -or $DepPC -or $FunPC -or $MakPC) {'Системный блок повышенной производительности'}
  Default {'Ничего'}
} $switch
<#
$switch = switch ($t) {
  $TitMon {'Второй монитор'}
  $TitOzu {'Озу сверх стандарта'}
  $TitPC  {'Системный блок повышенной производительности'}
  Default {'Ничего'}
} $switch
# # РАБОТАЕТ:
$switch = switch -Wildcard ($o) {
  $DepMon {'Второй монитор'}
  $DepOzu {'Озу сверх стандарта'}
  $DepPC  {'Системный блок повышенной производительности'}
  Default {'Ничего'}
} $switch
# # РАБОТАЕТ:
$switch = switch -Wildcard ($t,$o,$f,$M) {
  $TitMon {'Второй монитор'}
  $DepMon {'Второй монитор'}
  $FunMon {'Второй монитор'}
  $MakMon {'Второй монитор'}
  $TitOzu {'Озу сверх стандарта'}
  $DepOzu {'Озу сверх стандарта'}
  $FunOzu {'Озу сверх стандарта'}
  $MakOzu {'Озу сверх стандарта'}
  $TitPC {'Системный блок повышенной производительности'}
  $DepPC  {'Системный блок повышенной производительности'}
  $FunPC {'Системный блок повышенной производительности'}
  $MakPC {'Системный блок повышенной производительности'}
  Default {'Ничего'}
} $switch
#>


<# Match, Contains, Compare
  if ($TitMon -contains $t -or $DepMon -contains $o -or $FunMon -contains $f -or $MakMon -contains $m)  # С ЭТИМ РАБОТАЕТ ТОЖЕ
# If ($AllMon -contains ($t -or $o -or $f -or $m))
# if ($T -match $TitMon -or $O -match $DepMon -or $F -match $FunMon -or $M -match $MakMon)
# if ($AllMon -match ($T -or $O -or $F -or $M))
# if ($AllMon -match $T)
  if (Compare-Object $tofm $AllMon -includeEqual -excludeDifferent)   # С ЭТИМ РАБОТАЕТ ТОЖЕ
{'Второй монитор'}

  if ($TitOzu -contains $t -or $DepOzu -contains $o -or $FunOzu -contains $f -or $MakOzu -contains $m)   # С ЭТИМ РАБОТАЕТ ТОЖЕ
# if ($AllOzu -contains ($t -or $o -or $f -or $m))
# if ($T -match $TitOzu -or $O -match $DepOzu -or $F -match $FunOzu -or $M -match $MakOzu)
# if ($AllOZu -match ($T -or $O -or $F -or $M))
# if ($AllOzu -match $T)
  if (Compare-Object $tofm $AllOZu -includeEqual -excludeDifferent)   # С ЭТИМ РАБОТАЕТ ТОЖЕ
{'Озу сверх стандарта'}

  if($TitPC -contains $t -or $DepPC -contains $o -or $FunPC -contains $f -or $MakPC -contains $m)   # С ЭТИМ РАБОТАЕТ ТОЖЕ
# if($AllPC -contains ($t -or $o -or $f -or $m))
# if ($T -match $TitPC -or $O -match $DepPC -or $F -match $FunPC -or $M -match $MakPC)
# if ($AllPC -match ($T -or $O -or $F -or $M))
# if ($AllPC -match $T)
  if (Compare-Object $tofm $AllPC -includeEqual -excludeDifferent)   # С ЭТИМ РАБОТАЕТ ТОЖЕ
{'Системный блок повышенной производительности'}

# else {'Ничего'}

  if($TitNout -contains $t -or $DepNout -contains $o -or $FunNout -contains $f -or $MakNout -contains $m)   # С ЭТИМ РАБОТАЕТ ТОЖЕ
  if (Compare-Object $tofm $AllNout -includeEqual -excludeDifferent)   # С ЭТИМ РАБОТАЕТ ТОЖЕ
{'Должность сотрудника предполагает использование ноутбука'}
#>



<# ЭТО ТОЖЕ ВСЁ РАБОТАЕТ ПРИ ЖЕЛАНИИ:

if ($t -like 'инженер по эксплуатации*' -or $t -like 'Старший инженер по эксплуатации*' -or $t -like 'инженер по подсистемам*' `
-or $o -like 'Отдел по развитию трансп*' -or $o -like 'Департамент по эксплуатации*' -or $o -like 'Группа по эксплуатации*' `
-or $f -like '*Омск центральная*' -or $f -like '*Нижний Новгород центральная*' ) {
  Write-Host 'Должность сотрудника позволяет ему получить без визы директора:' -ForegroundColor RED
  Write-Host "Второй монитор, Увеличение ОЗУ сверх стандарта, ПК повышенной производительности" -ForegroundColor White 
  Write-Host 'Должность сотрудника предполагает использование ноутбука' -ForegroundColor RED}
elseif ($o -like 'центр компетенций*' -or $o -like 'Отдел технической*' `
-or $t -like 'инженер по Обслуживанию*') {
    Write-Host 'Должность сотрудника позволяет ему получить без визы директора:' -ForegroundColor RED
    Write-Host "Второй монитор, Увеличение ОЗУ сверх стандарта, ПК повышенной производительности" -ForegroundColor White} 
# -or $t -like '* по взаиморасчетам *' 
elseif ($t -like 'Старший специалист по управлению контентом*' -or $f -like '*Воронеж центральная *' `
-or $t -like 'Инженер по строительству*' -or $O -like 'Центр операционной поддержки*') {
  Write-Host 'Должность сотрудника позволяет ему получить без визы директора:' -ForegroundColor RED
  Write-Host "Второй монитор" -ForegroundColor White}
# elseif ($t -like 'Тренер*') {
elseif ($t -like 'Тренер*' -or $t -like 'Старший тренер*') {
  Write-Host 'Должность сотрудника предполагает использование ноутбука' -ForegroundColor RED}
else {Write-Host 'Должность сотрудника не найдена в базе льготников на предоставление какого-либо оборудования' -ForegroundColor White}
#>



#if ($fio -eq "") {Set-Clipboard -Value $user.displayname
 if ($lo -eq 1) {
     Set-Clipboard -Value $user.displayname
     Write-Host "ФИО сотрудника скопировано в буфер обмена!" -ForegroundColor Green }
else {Set-Clipboard -Value $u
    Write-Host "ЛОГИН сотрудника скопирован в буфер обмена!" -ForegroundColor Green}

Write-Host "Вывести информацию о руководителе?" -ForegroundColor Green
pause
#"`n"
#}

''
$m = $user.manager
$ruk = [adsi]"LDAP://$m"
"Руководитель сотрудника : " + $ruk.displayname
"Должность руководителя  : " + $ruk.title
Set-Clipboard -Value $ruk.displayname

''
if ($ruk.title -like 'Директор*'){ Write-Host "Руководитель сотрудника - ДИРЕКТОР!" -ForegroundColor Red }
Write-Host "ФИО руководителя скопировано в буфер обмена!" -ForegroundColor Green
Write-Host "Вывести информацию о директоре?" -ForegroundColor Green
pause
"`n"
# } else{

<#
$d = $ruk.manager
if ($f -like '*Центральная функция') { do {
   $dir = [adsi]"LDAP://$d"
   $dirtit = [string]$dir.title
   $d = $dir.manager   }
 while ($dirtit -notlike 'Директор*')}
#>

  function mt {$dirname -like 'Провоторов*' -or $dirname -like 'Патока*' -or $dirname -like 'Хлебников*' -or $dirname -like 'Майстренко*' -or $dirname -like 'Телков*' -or $dirname -like 'Лопатухин*' -or $dirname -like 'Скворцова*' -or $dirname -like 'Иванова Елена Викторовна*' -or $dirname -like 'Суриков*' -or $dirname -like 'Роговой*' -or $dirname -like 'Дивак*' -or $dirname -like 'Мартынов*'}
 #function mt {$dirname -notlike 'Суриков'}
 function dirmr {$dirtit -like 'директор макрорегиона*'}
 #function dirmr {$dirtit -notlike 'директор макрорегиона*'}
 #function alldir {$dirtit -like 'директор макрорегиона*' -or (mt)}

 
 # Фиксируем инфо по МТ-1:
 $p = [string]$ruk.manager
 $pod = [adsi]"LDAP://$p"
# Цикл для ЦФ:
 if ($f -like '*Центральная функция') { 
    do {  
    if ($Null -eq $po) {$po = $p}
    $dir = [adsi]"LDAP://$po"
    $dirtit = [string]$dir.title
    $dirname = [string]$dir.displayname
    $po = $dir.manager   }
  while ($dirtit -notlike 'Директор*')}
  # Цикл для регионов:    # Пример, когда отрабатывает некорректно: olga.panferova, dmitry.grazhdankin, Anton.Volkov
else {   
    do {    
    $dir = [adsi]"LDAP://$p"
    $dirtit = [string]$dir.title
    $dirname = [string]$dir.displayname
    $p = $dir.manager
    # Ген. директор:
    #$gd = [adsi]"LDAP://$p"
    #$gendir = [string]$gd.title  
  }
  #while ( dirmr -or mt )}
  #while ($dirtit -notlike 'директор макрорегиона*' -or $dirtit -notlike '*директор')}
  #while (($director -notlike 'Директор макрорегиона*') -or ($director -notlike '*директор'))}
  #while ([string]$director -notlike '*директор макрорегиона*' -or [string]$director -notlike 'Директор макрорегиона*')}
  #while ($director -notlike 'Директор макрорегиона*' -or $gendir -notlike 'Генеральный директор')}
  #while ($dirtit -notlike 'директор макрорегиона*' -or $dirname -notlike 'Суриков*')}
   #while ($dirtit -like 'директор макрорегиона*' `
   #-or $dirname -like 'Провоторов*' -or $dirname -like 'Патока*' -or $dirname -like 'Хлебников*' -or $dirname -like 'Майстренко*' -or $dirname -like 'Телков*' -or $dirname -like 'Лопатухин*' -or $dirname -like 'Скворцова*' -or $dirname -like 'Иванова*' -or $dirname -like 'Суриков*' -or $dirname -like 'Роговой*' `
   #-or $dirname -like 'Дивак*' -or $dirname -like 'Мартынов*')}   # Директора, которые попросили их не беспокоить
  
   #until (all)} # РАБОТАЕТ
   #until (dirmr)}
   #until (mt)}
   until ((dirmr) -or (mt))}
   #until ( dirmr mt )}
   #until ( dirmr -and mt )}
  <# !!! РАБОЧИЙ ПОЛНОСТЬЮ НЕ МЕНЯТЬ !!! :
  until ($dirtit -like 'директор макрорегиона*' `
  -or $dirname -like 'Провоторов*' -or $dirname -like 'Патока*' -or $dirname -like 'Хлебников*' -or $dirname -like 'Майстренко*' -or $dirname -like 'Телков*' -or $dirname -like 'Лопатухин*' -or $dirname -like 'Скворцова*' -or $dirname -like 'Иванова Елена*' -or $dirname -like 'Суриков*' -or $dirname -like 'Роговой*' `
  -or $dirname -like 'Дивак*' -or $dirname -like 'Мартынов*')}   # Директора, которые попросили их не беспокоить
  #>
  
  #while (dirmr)}
  #while ($dirtit -notlike 'Директор макрорегиона*')}
  #while ($dirtit -notlike '*директор')}
  #while ($dirtit -notlike '*директор макрорегиона*')}
  #while ($gendir -notlike 'Генеральный директор')}
  #while ($dirname -notlike 'Суриков*')}
"Директор              : " + $dirname #$dir.displayname
"Должность             : " + $dirtit  #$dir.title

# Проверка на МТ:
#$mt = $dir.displayname
#if ($dirname -like 'Мартынов*' -or $mt -like 'Суриков*') {
if ( mt ) {Set-Clipboard -Value $pod.displayname
Write-Host "Директор - МТ! В буфер скопировано ФИО его первого заместителя:" -ForegroundColor RED
# Write-Host "[string]$pod.displayname" -ForegroundColor RED
[string]$pod.displayname}
else {Set-Clipboard -Value $dir.displayname
Write-Host "ФИО директора скопировано в буфер обмена!" -ForegroundColor Green}
Write-Host "Вывести информацию о Руководителе направления сервиса информационных технологий?" -ForegroundColor Green
pause
"`n"


Set-Clipboard -Value "Гражданкин Дмитрий Сергеевич"
Write-Host "ФИО Руководителя направления сервиса информационных технологий скопировано в буфер обмена!" -ForegroundColor Green





<#
$ACCOUNTDISABLE       = 0x000002
$DONT_EXPIRE_PASSWORD = 0x010000
$PASSWORD_EXPIRED     = 0x800000
$Searcher = New-Object DirectoryServices.DirectorySearcher
$Searcher.Filter = '(&(objectCategory=person)(anr=Vasyanin Alexander))'
$Searcher.SearchRoot = 'LDAP://OU=Branches,DC=corp,DC=tele2,DC=ru'
$Searcher.FindAll()  | ForEach-Object {
  $user = [adsi]$_.Properties.adspath[0]
# $user = [adsi]"LDAP://$m".Properties.adspath[0]
  New-Object -Type PSCustomObject -Property @{
    SamAccountName       = $user.sAMAccountName[0]
    Name                 = $user.name[0]
    Mail                 = $user.mail[0]
    PasswordLastSet      = [DateTime]::FromFileTime($_.Properties.pwdlastset[0])
    Enabled              = -not [bool]($user.userAccountControl[0] -band
                           $ACCOUNTDISABLE)
    PasswordNeverExpires = [bool]($user.userAccountControl[0] -band
                           $DONT_EXPIRE_PASSWORD)
    PasswordExpired      = [bool]($user.userAccountControl[0] -band
                           $PASSWORD_EXPIRED)}}
#>


# модернизируем монитор? да или нет


