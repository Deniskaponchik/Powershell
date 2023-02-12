# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Users\ShowUserV0.2.ps1

"`n"
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
$po, $ResultUL = $Null


<#
# Получение логина по ФИО и обратно:
$u, $us, $ResultUL = $null

do {$Error[0], $lo = $null
if ($null -eq $u) {$u = Read-Host "Логин или ФИО "}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {$u = $us.SamAccountName
  $lo = 1}
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {$u
            Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  # $u.count -eq 1 -or 
$ResultUL = Get-ADUser -identity $u -properties *
#>


#
# Подгрузка внешней функции UserLogin !!! Кодировка файла должна быть Windows-1251 !!!
# powershell -ExecutionPolicy bypass -File \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\Logging_v0.2.ps1
# 
# . C:\Scripts\Example-02-DotSourcing.ps1
  . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.2.ps1
# . "D:\Work PC\Configs\Powershell\Scripts\UserLogin_v0.1.ps1"
# Get-Content \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.2.ps1 -Encoding utf8
# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.2.ps1 -Encoding utf8
#>

<# Внутрення функция UserLogin
  function UserLogin {
# Получение логина по ФИО и обратно:
$u, $us, $ResultUL = $null

do {$Error[0], $lo = $null
if ($null -eq $u) {$u = Read-Host "Логин или ФИО "}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {
    $u = $us.SamAccountName
    $Global:lo = 1
  }
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {
              Write-Host $u
              Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')

Return Get-ADUser -identity $u -properties *
# Возврат нескольких переменных
# $return = & $delprof2 $computer $switches
} 
#>

# Вызываем функцию
# $ResultUL = UserLogin
# $ResultUL = $Result
#>



[Environment]::NewLine
# просто посмотреть все атрибуты пользователя:
# Get-ADUser natalia.osten  -Properties *   #  anatoly.broner    alla.pleshkova   denis.tirskikh  olga.khaimova

#
# "ФИО           :{0} " -f $ResultUL.displayname
  "ФИО           :{0} " -f $ResultUL.displayname

# Должность = [string]$ResultUL.description   # Показывает не совсем то
# Должность = [string]$ResultUL.title 
 "Должность     :{0} " -f $ResultUL.title 

# Отдел = [string]$ResultUL.department
 "Отдел         :{0} " -f $ResultUL.department

# GivenName = [string]$ResultUL.givenname
# Логин = [string]$ResultUL.userprincipalname
# Логин = [string]$ResultUL.SamAccountName 
 "Логин         :{0} " -f $ResultUL.SamAccountName

# employeeID = [string]$ResultUL.employeeid
 "employeeID    :{0} " -f $ResultUL.employeeid

# mail = [string]$ResultUL.mail
 "Mail          :{0} " -f $ResultUL.mail

# Руководитель = [string]$ResultUL.manager.Replace(",OU=Branches,DC=corp,DC=tele2,DC=ru","")

# OfficePhone = [string]$ResultUL.officePhone
# Avaya = [string]$ResultUL.otherTelephone
#"Avaya         :{0}" -f $ResultUL.otherTelephone
 "Avaya         : " + $ResultUL.otherTelephone
# Мобильный = [string]$ResultUL.mobilePhone
 "Мобильный     :{0} " -f $ResultUL.mobilePhone
# Телефон2 = [string]$ResultUL.telephonenumber
# Телефон = [string]$ResultUL.ipPhone
 "Телефон       :{0} " -f $ResultUL.ipPhone

# Комната = [string]$ResultUL.physicaldeliveryofficename
# Макрорегион = [string]$ResultUL.st
 "Макрорегион   :{0} " -f $ResultUL.st

# Функция = [string]$ResultUL.office
"Функция       :{0} " -f $ResultUL.office

# OU = [string]$ResultUL.distinguishedName.Replace(",OU=Branches,DC=corp,DC=tele2,DC=ru","") #.remove(35)
# OU = [string]$ResultUL.distinguishedName.split(",")[-5]
 "OU            :{0} " -f $ResultUL.distinguishedName.split(",")[-5]

# }  # | Sort-Object -Type        #  | Export-Csv -NoClobber -Encoding utf8 -Path  D:\Scripts\TEST.csv
#>



<# New-Object PsObject -Property @{
  $UserPropCash = @{
    "ФИО" = $ResultUL.displayname
    "Должность" = $ResultUL.title
  }
  $UserPropCash
#>


[Environment]::NewLine
"Дата создания УЗ                 : " + $ResultUL.whencreated.DateTime
"Срок действия УЗ до              : " + $ResultUL.AccountExpirationDate.DateTime
"Дата установки пароля            : " + $ResultUL.PasswordLastSet.DateTime
"Дата ввода неправильного пароля  : " + $ResultUL.LastBadPasswordAttempt.DateTime

#"Учётка актвна?                 : " 
#if ($ResultUL.AccountExpirationDate -lt (Get-Date)) {Write-Host 'СРОК ДЕЙСТВИЯ УЗ ИСТЁК!!!' -ForegroundColor RED}
 if ($ResultUL.AccountExpirationDate -and ($ResultUL.AccountExpirationDate -lt (Get-Date)))
 {Write-Host 'СРОК ДЕЙСТВИЯ УЗ ИСТЁК!!! Необходима заявка от руководителя аутстафера на продление' -ForegroundColor RED}
 if ($ResultUL.PasswordExpired) {Write-Host 'СРОК ДЕЙСТВИЯ ПАРОЛЯ ИСТЁК !!!' -ForegroundColor RED}
 if ($ResultUL.userAccountControl -eq 512 -or $ResultUL.userAccountControl -eq 66048) {'Учётка Включена'} 
 else{
  Write-Host 'Учётка Выключена' -ForegroundColor RED
  #"Description                      : " + $ResultUL.Description
  $des = $ResultUL.Description
  Write-Host "$Des" -ForegroundColor RED
 }
''

$t = [string]$ResultUL.title       # Должность
$o = [string]$ResultUL.department  # Отдел
$f = [string]$ResultUL.office      # Функция
$m = [string]$ResultUL.st          # Макрорегион
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


#if ($fio -eq "") {Set-Clipboard -Value $ResultUL.displayname
 if ($lo -eq 1) {
     Set-Clipboard -Value $ResultUL.displayname
     Write-Host "ФИО сотрудника скопировано в буфер обмена!" -ForegroundColor Green }
else {Set-Clipboard -Value $ResultUL.SamAccountName
      Write-Host "ЛОГИН сотрудника скопирован в буфер обмена!" -ForegroundColor Green}

Write-Host "Вывести информацию о руководителе?" -ForegroundColor Green
pause
#"`n"
#}

''
$m = $ResultUL.manager
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


