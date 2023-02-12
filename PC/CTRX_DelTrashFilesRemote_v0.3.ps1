# Version: 0.3
# STATUS: ТЕСТ
# Цель: помощь в Обработке обращений VDI - очистка диска С
# реализация: БД MS SQL Server на WSIR-IT-01, БД MySQL Server на T2Ru-GLPI-01 
# проблемы:
# Планы: Подключение к шине bpm

[Environment]::NewLine
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
# $ErrAct1, $ErrAct2, $ErrDelHyb = $null

<# Логирование Старое:
  $dl = Get-Date -Format "dd.MM_HH.mm.ss"
  $ScriptName= $MyInvocation.MyCommand.Name   # имя скрипта, из которого запущена команда
  $LogName = "$dl $Env:Username $ScriptName"  # Время | Пользователь | Имя скрипта
  $NewFileLog = New-Item -Name "$LogName.txt" -Path "$PSScriptRoot\logs"
#>
# Логирование НОВОЕ через БД MS SQL Server
  $AdminLogin = $env:USERNAME
  $DateStart = Get-Date
  $ScriptName= $MyInvocation.MyCommand.Name
. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WsirIt01_ScriptEx_v0.0.ps1
  ScriptsExecute -Operation Insert -AdminLogin $AdminLogin -DateStart $DateStart -ScriptName $ScriptName -DateEnd $DateStart



# Запрос пользователя, которого не удалять ни при каких условиях
# НОВОЕ
Write-Host 'ФИО или логин пользователя' -ForegroundColor Green
#. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Users\UserLogin_v0.4.ps1
 . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Users\UserLogin_v0.5.ps1
#[string]$login = UserLogin
$UserProp = UserLogin
#$login = $login -replace '\s',''
#$UserProp = Get-ADUser -identity $Login -properties *

# Инфо о пользователе ПК
#$UserProp.displayname
#$UserProp.title
#$UserProp.mobilePhone
#$UserProp.l
$UserPropInfo = @($UserProp.displayname, $UserProp.title, $UserProp.mobilePhone, $UserProp.l)
$UserPropInfo
try {
    Write-Host 'Контактные данные пользователя скопированы в буфер обмена :' -ForegroundColor Green `n
    Set-Clipboard -Value $UserPropInfo
    Pause
}
catch {
    Write-Host 'Контактные данные пользователя не удалось скопировать в буфер обмена' -ForegroundColor RED `n
}


$wiki = @("Инструкция по очистке:", "https://wiki.tele2.ru/pages/viewpage.action?pageId=71622259")
$wikipage = 'https://wiki.tele2.ru/pages/viewpage.action?pageId=71622259'
Set-Clipboard -Value $wikipage -ErrorVariable ErrSetClip
Write-Host 'Адрес страницы скопирован в буфер обмена' -ForegroundColor Green `n
Pause



# Проверка на ранее созданные заявки по данной машине
# НОВЫЙ способ через БД MY SQL
# Function DelTrash
. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WsirIt01_DelTrash_v0.3.ps1
$DelTrash = DelTrash -Operation Read -Pcname $PC
Write-Host "Ранее работа велась в рамках таких обращений:" -ForegroundColor Green
$DelTrash
[Environment]::NewLine
$SRnumber = Read-Host "Вставь НОМЕР тикета, по которому ведёшь работу сейчас"
$SRlink = Read-Host "Вставь ССЫЛКУ на тикет, по которому ведёшь работу сейчас"




[Environment]::NewLine
# Добавить это инфо в сравнительный файл:
  $ITreg = $Null
# $PCcut =  "WSCP"
  $Hash_Reg = @{
  #Name/Keys = Value 
  Voronezh = 'IT VO'
  Ekaterinburg = 'IT EK'
  Irkutsk = 'IT IR'
  Kazan = 'IT KZ'
  Krasnodar = 'IT KR'
  Krasnoyarsk = 'IT KY'
  'Nizhniy Novgorod' = 'IT NN'
  Novosibirsk = 'IT NS'
  Omsk = 'IT OM'
  'Saint-Petersburg' = 'IT SP'
  Perm = 'IT PR'
  'Rostov-on-Don' = 'IT RO'
  Tula = 'IT TL'
  Tumen = 'IT TM'
  Chelyabinsk = 'IT CH'
  }
# $Hash_Reg
  foreach ($Item in $Hash_Reg.Keys) {
    #$msg = 'Key {0} Value {1}' -f $Item,$Hash_Reg[$item]
    #Write-Output $msg

    if ($Item -like $OU) {
      Write-host 'В регионе есть свой ИТ-специалист Теле2. Тикет можно перевести на группу региональных ИТ.' -ForegroundColor Red
      Write-host 'Группа скопирована в буфер обмена:' -ForegroundColor Red
      $Hash_Reg[$item]
      Set-Clipboard -Value $Hash_Reg[$item]
      $ITreg = 1
      Pause
    }
  }

  $ITCF = $Null
# $PCcut =  "WSCP"
  $Hash_CF = @{
    #Name/Keys = Value 
    'Voronezh-SSC' = 'IT SC'    
    'Moscow-MCC' = 'IT MO'
    Moscow = 'IT MS'
    'Nizhny Novgorod-CP' = 'IT CN'
    'Nizhny Novgorod-NOC' = 'IT CN'
    'Omsk-CP' = 'IT CP'
    'CC-Irkutsk' = 'IT ZI'
    'CC-Rostov' = 'IT ZR'
    'CC-Saransk' = 'IT ZS'
    'CC-Chelyabinsk' = 'IT ZC'
    Central = 'IT RU'
    }
  # $Hash_Reg
    foreach ($Item in $Hash_CF.Keys) {
      #$msg = 'Key {0} Value {1}' -f $Item,$Hash_Reg[$item]
      #Write-Output $msg  
      if ($Item -like $OU) {
        Write-host 'В ЦФ есть свои ИТ. Тикет можно перевести на них.' -ForegroundColor Red
        Write-host 'Группа скопирована в буфер обмена:' -ForegroundColor Red
        $Hash_CF[$item]
        Set-Clipboard -Value $Hash_CF[$item]
        $ITCF = 1
        Pause
      }
    }

if ($ITreg -eq $Null -and $ITCF -eq $Null) {"В регионе нет постоянного ИТ-специалиста"}
      




[Environment]::NewLine
"Посмотри, на каком сервере сидит сотрудник. web-адрес Citrix-Director скопирован в буфер обмена. Логин - admin.ws.XX"
do {
  Set-Clipboard -Value "https://appgate.tele2.ru/Director/default.html?locale=en_US#HOME" -ErrorVariable ErrSetClip
} while ($ErrSetClip) 
$PC = Read-Host "Citrix сервер пользователя"
$wcusers = "\\$PC\C$\Users\"


PAUSE





<#
[Environment]::NewLine
# Вывод информации о машине:
Write-Host $PC -ForegroundColor Yellow

[Environment]::NewLine
# Версия ОС
# Новое
$OSversion = (Get-ADComputer -Identity $PC -properties OperatingSystem).OperatingSystem
$OSversion
$OSbuildNumberSplit = ((Get-ADComputer -Identity $PC -properties OperatingSystemVersion).OperatingSystemVersion).split(" ")
$OSbuildNumber = $OSbuildNumberSplit[1].trimstart("(").trimEnd(")")
$OSbuildNumber


# https://docs.microsoft.com/en-us/windows/release-health/release-information
    if ($OSBuildNumber -like '17763') {Write-Host '1809 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '18362') {Write-Host '1909 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '18363') {Write-Host '1909 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '19041') {Write-Host '2004 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '19042') {Write-Host '20H2 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '19043') {Write-Host '21H1' -ForegroundColor Green}
elseif ($OSBuildNumber -like '19044') {Write-Host '21H2' -ForegroundColor Green}
  else {'Не удалось определить версию OS'}


#
#if ($Ping = Test-Connection -ComputerName $PC -Quiet) {}
if (Test-Connection -ComputerName $PC -Quiet) { #Если ПК доступен, то выуживаем инфо о дисках и процессоре
    #Get-WmiObject  -computername  $PC -query 'SELECT * FROM Win32_Processor' # Версия процессора
    $Proc = (Get-WmiObject  -computername  $PC -query 'SELECT * FROM Win32_Processor').name # Версия процессора
    $Proc
    
    [Environment]::NewLine
    # Вывод информации только для диска C:
    # Write-Host 'Установленные диски:' -ForegroundColor Green
    # (Get-WmiObject  -Class win32_diskdrive -ComputerName $PC).Model
    $p = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | Where-Object {$_.deviceid -like 'C:'}
    $Lsize = ($p.Size / 1GB).ToString("F01")
    "Disk " + $p.DeviceID + " Size      : {0}" -f ($p.Size / 1GB).ToString("F01") + ' GB'
    "Disk " + $p.DeviceID + " FreeSpace : {0}" -f ($p.FreeSpace / 1GB).ToString("F01") + ' GB'

    [Environment]::NewLine
    Write-Host 'Установленные физические диски:' -ForegroundColor Green
    # $PC = 'WSCN-KVASHENNIK'
    # Get-WmiObject -Class "Win32_LogicalDisk" -ComputerName $PC
    # $f = Get-WmiObject -Class Win32_diskdrive -ComputerName $PC
    # Get-WmiObject -Class Win32_diskdrive -ComputerName $PC | Format-Table -Property Model, @{Label="Size(GB)"; Expression={$_.Size/1Gb}} -AutoSize
      Get-WmiObject -Class Win32_diskdrive -ComputerName $PC | Format-Table -Property Model, @{Label="Size(GB)"; Expression={($_.Size/1Gb).ToString("F01")}} -AutoSize

    CommentsBPM
}
else {
  Write-Host "ПК $PC недоступен" -ForegroundColor Red
  CommentsBPM
  [Environment]::NewLine

  Write-Host 'Скрипт переведён в режим постоянного отправления пингов. Как только ПК появится в сети - сразу продолжит работу.' -ForegroundColor Red
  Write-Host 'Не забудь взять заявку в работу, чтобы твой коллега не сделал того же самого с этим же компом.' -ForegroundColor Red
  Write-Host 'Для прекращения работы скрипта команда: CTRL + C' -ForegroundColor Red
  [Environment]::NewLine
  #do {$Ping} while ($Ping -eq $False)}
  do {$Ping = (Test-Connection -ComputerName $PC -Quiet)} 
  while ($Ping -eq $False) {
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Устройство $PC появилось в сети")
  }
}


[Environment]::NewLine
if (($OS.Caption  + $OS.CSDVersion) -like '*Windows 7*') {
Write-Host "Необходимо ОБЯЗАТЕЛЬНО в рамках данного тикета предпринять ВСЕ возможные меры, чтобы избавиться от Windows 7" -ForegroundColor Red `n
Pause}

if (($OS.Caption  + $OS.CSDVersion) -like 'Windows 10 Корп*') {
Write-Host "Необходимо обновить систему до Windows 10 Pro 21H1" -ForegroundColor Red
Write-Host 'Текст комментария скопирован в буфер обмена. Можешь завершить скрипт или продолжить его выполнение' -ForegroundColor Yellow `n
Set-Clipboard -Value 'Необходимо также обновить систему до Windows 10 PRO 21H1 через Центр Программного обеспечения или установить её с нуля в случае недоступности таковой там.'
Pause}
#>





$d1 = Get-Date  # Фиксируем время начала отработки скрипта

<# Вроде, данные вводить не нужно, если скрипт запущен от имени доменного администратора. Отключаю
Write-Host "Запрос прав администратора домена (admin.ws.)" -ForegroundColor Red
$AdmWSDomCred = Get-Credential
#>


<#
# Отключение гибернации (ПРОСТОЕ):
  Invoke-WMIMethod -cred $AdmWSDomCred -path Win32_Process -name Create -argumentlist "powercfg.exe -h off" -ComputerName $PC -ErrorVariable ErrDelHyb -Verbose
  Write-Host 'Гибернация отключена' -ForegroundColor Magenta
# Wait-Event -Timeout 30

# Отключение ведение журнала записи отладочной информации при краше системы:
# $PC = 'wsir-it-01'    $PC = '
  Get-WmiObject -Class Win32_OSRecoveryConfiguration -ComputerName $PC -EnableAllPrivileges | Set-WmiInstance -Arguments @{ DebugInfoType=0 }
# Set-WmiInstance -Class Win32_OSRecoveryConfiguration -ComputerName $PC -Arguments @{ DebugInfoType=1 }
  Write-Host 'Запись отладочной информации отключена' -ForegroundColor Magenta


# Удаление папок/профилей неиспользуемых пользователей #2 (ВРЕМЕННО отключил):
#$UserProp.SamAccountName = 'Polina.Mosichenko'
$NoDelUsers = 'Все пользователи','All Users','Default','Default User','Администратор','Administrator','Public','Общие','desktop.ini',$UserProp.SamAccountName
#$PC = 'wszi-leader-12'
#$PC = 'WSZI-NGTIATE-03'
#$PC = 'wszi-IT-01'
$wcusers = "\\$PC\C$\Users\"
$UserPropsfol = Get-ChildItem $wcUsers -Force
foreach ($UF in $UserPropsfol) {  
  Write-Host $UF
  if (($UF.lastwritetime -lt (Get-Date).AddDays(-60)) -and $NoDelUsers -notcontains $UF.name){
    Get-WMIObject -class Win32_UserProfile -ComputerName $pc | Where-Object {$_.LocalPath -like 'C:\Users\'+$UF.name} | Remove-WmiObject -Verbose -ErrorVariable ErrDelUF1 # -AsJob
    Remove-Item -Path "\\$PC\C$\Users\$UF\" -force -recurse -verbose -ErrorVariable ErrDelUF2
    Write-Host "Профиль $UF удалён" -ForegroundColor Magenta
    [Environment]::NewLine}       
} #
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


<#
# $PC = 'WSRU-VAKULICH'

       $wc = "\\$PC\C$\"   # ДИСК С !!!
  $wcdump1 = "\\$PC\C$\Windows\MEMORY.DMP"
  $wcdump2 = "\\$PC\C$\Windows\minidump\*"

  $wcUpdate1 = "\\$PC\C$\Windows\SoftwareDistribution\Download\*"
# $wcUpdate2 = "\\$PC\C$\Windows\SoftwareDistribution\DataStore\*"  # Папка небольшая и удалять не очень хочется
  $wcUpdate3 = "\\$PC\C$\Windows\ccmcache\*"    # Настравиается размер кэша SCCM в корне Панели управления

# $wctemp1 = "\\$PC\C$\Windows\temp\*"
  $wctemp1 = "\\$PC\C$\Windows\temp\"

  $wcoldwin1 = "\\$PC\C$\Windows.ol*\Users\*.*\"
  $wcoldwin2 = "\\$PC\C$\Windows.ol*\"
# $wcoldwin2 = "\\wsir-it-03\C$\Windows.ol*\"
# $wcoldwin3 = "\\$PC\C$\Windows.ol*\*"
# $wcoldwin3 = "\\$PC\C$\Windows.old\Users\*"



  $wctelemetry1 = "\\$PC\C$\ProgramData\Microsoft\Diagnosis\ETLLogs\"
# $wcDLPagent = "\\$PC\C$\Program Files\Manufacturer\Endpoint Agent\temp\"
#>


# $wctemp2 = "\\$PC\C$\Users\*\Appdata\Local\Temp\*"
  $wctemp2 = "\\$PC\C$\Users\*\Appdata\Local\Temp\"
  $wctemp3 = "\\$PC\C$\Users\*\AppData\Local\Google\Chrome\User Data\Default\Code Cache\js\"
  

#   $wsSketch = "\\$PC\C$\Users\*\AppData\Local\Microsoft\Windows\Explorer\*  # Эскизы Windows
# $wcPrefetch = "\\$PC\C$\Windows\Prefetch\*"  # Никогда не вешает больше 50 мб

# Ещё какие-то варианты:
# “C:\swsetup”
# “\AppData\Local\*.auc”
# “\AppData\Local\Microsoft\Terminal Server Client\Cache\*”
# “\AppData\Local\Microsoft\Windows\Temporary Internet Files\*”
# “\AppData\Local\Microsoft\Windows\WER\ReportQueue\*”
# “\AppData\Local\Microsoft\Windows\Explorer\*”



<#
  Remove-Item $wcoldwin1 -force -recurse -verbose -ErrorVariable ErrDelWinOld
  Remove-Item $wcoldwin2 -force -recurse -verbose -ErrorVariable ErrDelWinOld
  if ($ErrDelWinOld) {$ErrDelWinOld = "Папка Windows.Old не смогла удалиться полностью. Можешь подключиться к диску C: и удалить её вручную:", $wc}
#>


# Удаление всех файлов и папок (в т.ч. внутри папок) старше чем значение в $TEMPdate
# Get-ChildItem -Recurse -Path $wctemp1,$wctemp2 | Where-Object -Property CreationTime -gT $TEMPdate | Remove-Item -force -recurse -verbose -ErrorVariable ErrDelTemp


# $ForDelFold = @($wcoldwin1, $wcoldwin2, $wcdump1, $wcdump2, $wcUpdate1, $wctemp1, $wctemp2)
# $ForDelFold = @($wcdump1, $wcdump2, $wcUpdate1, $wctemp1, $wctemp2)
# $ForDelFold = $wcdump1, $wcdump2, $wcUpdate1, $wcUpdate3, $wctemp1, $wctemp2, $wctelemetry1
  $ForDelFold = $wctemp2, $wctemp3

# Remove-Item $tempfolders -force -recurse -verbose #-ErrorAction SilentlyContinue
  Remove-Item $ForDelFold -force -recurse -verbose #-ErrorAction SilentlyContinue
# Remove-Item $wcUpdate -force -recurse -verbose


Break




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
$ExcludedUsers ="Public","Administrator","Администратор",'$UserProp','Default'
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
             {$UserPropSID = New-Object System.Security.Principal.SecurityIdentifier($Bin.Name) 
              $UserProp = $UserPropSID.Translate([System.Security.Principal.NTAccount]) 
             }#End Try 
            Catch 
             {$UserProp = $null }#End Catch 
            If (!$UserProp) 
             {#Obtaining Local Account SIDs for $Bin.Name comparison. 
              $WMI_UsrAcct = Get-WmiObject -Class Win32_UserAccount -ComputerName $Computer -Filter "Domain = '$Computer'" 
              #Using a While Loop to search Local User Accounts for Matching $Bin.Name 
              $i = 0 
              While ($i -le $WMI_UsrAcct.Count) 
               {If ($WMI_UsrAcct[$i].SID -eq $Bin.Name) 
                 {$UserProp = $WMI_UsrAcct[$i].Caption 
                  Break }  #End If ($WMI_UsrAcct[$i].SID -eq $Bin.Name) 
                $i++ 
               }#End While ($i -le $WMI_UsrAcct.Count) 
             }#End If (!$UserProp) 
             
            #Creating Output Object 
            $RecInfo = New-Object PSObject -Property @{ 
            Computer=$Computer 
            Drive=$Disk
            User=$UserProp 
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
             {$UserPropSID = New-Object System.Security.Principal.SecurityIdentifier($Bin.Name) 
              $UserProp = $UserPropSID.Translate([System.Security.Principal.NTAccount]) } # End Try 
            Catch 
             {$UserProp = $null } #End Catch 
            If (!$UserProp) 
             {#Obtaining Local Account SIDs for $Bin.Name comparison. 
              $WMI_UsrAcct = Get-WmiObject -Class Win32_UserAccount -ComputerName $Computer -Filter "Domain = '$Computer'" 
              #Using a While Loop to search Local User Accounts for Matching $Bin.Name 
              $i = 0 
              While ($i -le $WMI_UsrAcct.Count) 
               {If ($WMI_UsrAcct[$i].SID -eq $Bin.Name) 
                 {$UserProp = $WMI_UsrAcct[$i].Caption 
                  Break } 
                $i++ 
               }#End While ($i -le $WMI_UsrAcct.Count) 
             }#End If (!$UserProp) 
 
            #Creating Output Object 
            $RecInfo = New-Object PSObject -Property @{ 
            Computer=$Computer 
            Drive=$Disk.ToUpper()  # Можно не указывать, если чистим только диск C:
            User=$UserProp 
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
[Environment]::NewLine


 Write-host "Ошибки, на которые можно обратить внимание, а можно и не обращать:" -ForegroundColor Magenta
 [Environment]::NewLine
 $ErrDelHyb
 [Environment]::NewLine
 #$ErrAct1
 [Environment]::NewLine
#$ErrAct2
 $ErrDelWinOld 
 [Environment]::NewLine

<#
}else {"ПК - "+ $PC + " недоступен" #}
'Скрипт переведён в режим постоянного отправления пингов. Как только ПК появится в сети - сразу продолжит работу.'
'Не забудь взять заявку в работу, чтобы твой коллега не сделал того же самого с этим же компом'
'Для прекращения работы скрипта команда: CNTL + C'
do {$Ping = (Test-Connection -ComputerName $PC -Quiet)} while ($Ping -eq $False)}
#>