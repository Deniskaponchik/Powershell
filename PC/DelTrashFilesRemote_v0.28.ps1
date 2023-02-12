# Version: 0.28
# STATUS: РАБОТАЕТ
# Цель: помощь в Обработке обращений System Monitoring Auto Create на очистку ПК
# реализация: БД MS SQL Server на WSIR-IT-01, БД MySQL Server на T2Ru-GLPI-01 
# проблемы:
# Планы: Подключение к шине bpm
# Author: denis.tirskikh


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




# Проверка на существование машины в домене:
  do{
    # $Error[0] = $Null
      $PcNOTexis = $Null
      $PC = Read-Host "Имя компьютера или IP-адрес"
    # Получение ip-адреса устройства:
    # [string]$ip = [System.Net.Dns]::GetHostEntry($PC).addresslist[0].ipaddresstostring  
    try {
      [string]$ip = [System.Net.Dns]::GetHostEntry($PC).addresslist[0].ipaddresstostring     
     } 
     catch {
       $PcNOTexis = 1
       Write-Host  "Такое устройство не светилось в сети Теле2" -ForegroundColor Red
       [Environment]::NewLine
      }
    }
    # while ($Error[0] -like '*Этот хост неизвестен*' -or $Error[0] -like '*указывать на позицию*')
      while ($PcNOTexis -or $PC -eq '')






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
Write-Host "1. Заканчивается место на диске C:"
Write-Host "2. Увеличить ОЗУ"
Write-Host "3. SMART Диска не ОК"
Write-Host "4. Обновление Windows"
Write-Host "5. Другое"
[Environment]::NewLine
$Choice = Read-Host "Укажи номер варианта иницидента"
$IncidentType = switch($Choice){
    1{"Заканчивается место на диске C:"}
    2{"Увеличить ОЗУ"}
    3{"SMART Диска не ОК"}
    4{"Обновление Windows"}
    5{"Другое"}
    Default {"0. Не указано"}
}
<#
[Environment]::NewLine
$IncidentTypes = (
  #"0. Не указано",
  "1. Заканчивается место на диске C:",
  "2. Увеличить ОЗУ",
  "3. SMART Диска не ОК",
  "4. Обновление Windows",
  "5. Другое"
)
$IncidentTypes
[Environment]::NewLine
$IncidentChoice = Read-Host "Укажи номер варианта иницидента"
if ($IncidentChoice -le 5) {
    #$IncidentType = (Get-Variable -Name "WorkType$Choice").Value
     $IncidentType = $IncidentTypes[$IncidentChoice]
}
else {
    $IncidentType = Type = "Не указано"
}
$IncidentType  #>





# Поиск групп ответсвенных в зависимости от имени машины
[Environment]::NewLine
$PCut = $PC.Substring(0,4)


<# РАБОЧЕЕ. Убираю в связи с переход на подключение к БД WSIR-IT-01/ITsupport
# Добавить это инфо в сравнительный файл:
$ITmacro = $Null
# $PCcut =  "WSCP"
  $Hash_Reg = @{
  #Name/Keys = Value 

    wsmu = 'IT MNW'
    nbmu = 'IT MNW'  
    wsva = 'IT MNW'
    nbva = 'IT MNW'  
    wsvn = 'IT MNW'
    nbvn = 'IT MNW'  

    wsvl = 'IT MCN'
    nbvl = 'IT MCN'  

    wssa = 'IT MVU'
    nbsa = 'IT MVU' 
    wski = 'IT MVU'
    nbki = 'IT MVU'         
  
  
    wsbe = 'IT MCB'
    nbbe = 'IT MCB'
    wsli = 'IT MCB'
    nbli = 'IT MCB'
    wssn = 'IT MCB'
    nbsn = 'IT MCB'
    wssr = 'IT MCB'
    nbsr = 'IT MCB'

    wssy = 'IT MUR'
    nbsy = 'IT MUR'

    wske = 'IT MSB'
    nbke = 'IT MSB'
    wsnk = 'IT MSB'
    nbnk = 'IT MSB'

    wsbb = 'IT MFE'
    nbbb = 'IT MFE'
    wskh = 'IT MFE'
    nbkh = 'IT MFE'
    wsrh = 'IT MFE'
    nbrh = 'IT MFE'
    wsvk = 'IT MFE'
    nbvk = 'IT MFE'

 
  }
# $Hash_Reg
  foreach ($Item in $Hash_Reg.Keys) {
    #$msg = 'Key {0} Value {1}' -f $Item,$Hash_Reg[$item]
    #Write-Output $msg

    if ($Item -like $Pcut) {
      Write-host 'В регионе нет постоянного ИТ-специалиста.' -ForegroundColor Red
      Write-host "Группа макрорегиональных инженеров скопирована в буфер обмена:" -ForegroundColor Red
      $Hash_Reg[$item]
      Set-Clipboard -Value $Hash_Reg[$item]
      $ITmacro = 1
      Pause
    }
  }




  $ITreg = $Null
# $PCcut =  "WSCP"
  $Hash_Reg = @{
  #Name/Keys = Value 
    wsvo = 'IT VO'
    nbvo = 'IT VO'
    wsrv = 'IT VO'
    nbrv = 'IT VO'
    wsek = 'IT EK'
    nbek = 'IT EK'
    wsir = 'IT IR'
    nbir = 'IT IR'
    wskz = 'IT KZ'
    nbkz = 'IT KZ'
    wskr = 'IT KR'
    nbkr = 'IT KR'
    wsky = 'IT KY'
    nbky = 'IT KY'
    wsnn = 'IT NN'
    nbnn = 'IT NN'
    wsrn = 'IT NN'
    nbrn = 'IT NN'
    wsns = 'IT NS'
    nbns = 'IT NS'
    wsrs = 'IT NS'
    nbrs = 'IT NS'
    wsom = 'IT OM'
    nbom = 'IT OM'
    wsrp = 'IT SP'
    nbrp = 'IT SP'
    wssp = 'IT SP'
    nbsp = 'IT SP'
    wspr = 'IT PR'
    nbpr = 'IT PR'
    wsro = 'IT RO'
    nbro = 'IT RO'
    wstu = 'IT TU'
    nbtu = 'IT TU'
    wstm = 'IT TM'
    nbtm = 'IT TM'
    wsch = 'IT CH'
    nbch = 'IT CH'
  }
# $Hash_Reg
  foreach ($Item in $Hash_Reg.Keys) {
    #$msg = 'Key {0} Value {1}' -f $Item,$Hash_Reg[$item]
    #Write-Output $msg

    if ($Item -like $Pcut) {
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
    wssc = 'IT SC'
    nbsc = 'IT SC'
    wszi = 'IT ZI'
    nbzi = 'IT ZI'
    wsmo = 'IT MO'
    nbmo = 'IT MO'
    wsms = 'IT MS'
    nbms = 'IT MS'
    wscn = 'IT CN'
    nbcn = 'IT CN'
    wscp = 'IT CP'
    nbcp = 'IT CP'
    wszr = 'IT ZR'
    nbzr = 'IT ZR'
    wszs = 'IT ZS'
    nbzs = 'IT ZS'
    wszc = 'IT ZC'
    nbzc = 'IT ZC'
    wsru = 'IT RU'
    nbru = 'IT RU'
    }
  # $Hash_Reg
    foreach ($Item in $Hash_CF.Keys) {
      #$msg = 'Key {0} Value {1}' -f $Item,$Hash_Reg[$item]
      #Write-Output $msg  
      if ($Item -like $Pcut) {
        Write-host 'В ЦФ есть свои ИТ. Тикет можно перевести на них.' -ForegroundColor Red
        Write-host 'Группа скопирована в буфер обмена:' -ForegroundColor Red
        $Hash_CF[$item]
        Set-Clipboard -Value $Hash_CF[$item]
        $ITCF = 1
        Pause
      }
    }

  if ($ITreg -eq $Null -and $ITCF -eq $Null -and $ITmacro -eq $Null) {
    "Не удалось определить ответственную группу ИТ. необходимо занести в базу регион"}
#>


# Определение сервисных инженеров на основании имени машины:
[Environment]::NewLine
. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WSIRit01_RegionCodes_v0.1.ps1
$RegionCodes = RegionCodes -Operation DelTrashFilesRemote -PCname $Pcut
$BPMgroup = $RegionCodes.BPMgroup21
$Comment = $RegionCodes.Comment1

if ($Null -eq $BPMgroup){
    Write-host 'Не удалось определить ответственную группу ИТ. необходимо занести в базу' -ForegroundColor Red
}
else {
    Write-host $Comment -ForegroundColor Red
    Write-host 'Группа скопирована в буфер обмена:' -ForegroundColor Red
    $BPMgroup
    [Environment]::NewLine
    Set-Clipboard -Value $BPMgroup
}
Pause



# Выведение информации о характеристиках ПК
[Environment]::NewLine
. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\PC\ShowPCinfoFun_v0.3.ps1
#$PC = Read-Host "Имя компьютера или IP-адрес"
PCinfo -PC $PC





<#
  [Environment]::NewLine
  'Последние 5 залогинившихся пользователей:'
  $wcusers = "\\$PC\C$\Users\"
  get-ChildItem $wcUsers -ErrorAction SilentlyContinue -ErrorVariable NotAccessC | Sort-Object -property LastWriteTime, Name -descending | Select-Object -first 5 | Format-Table Name, LastWriteTime
  # Обработка непрерывающих ошибок
  if ($NotAccessC -like '*удается найти*') {
    Write-Host "Нет доступа к диску C:" -ForegroundColor Red
    ''
    # GLPIread function
    . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\MySQL\DataAdapter\DataAdapter_GLPI_read_v1.2.ps1
     $GLPIread = GlpiRead -Nomination $pc -SearchTarget login
    #$GLPIread[1]
    [Environment]::NewLine
    Write-host 'Информация о пользователе компьютера из SCCM / GLPI / Spareparts:' -ForeGroundColor Yellow
    $GLPIread[1].login
    
  }
  # Если возникнет доселе не описанная ошибка, то вывести её на экран:
  elseif ($NotAccessC) {$NotAccessC}
  #>


  
# Запрос пользователя, которого не удалять ни при каких условиях
# НОВОЕ
Write-Host 'Введи в поле нижe ФИО или логин пользователя, чей профиль не будет удаляться в рамках данного скрипта' -ForegroundColor Green
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
}
catch {
    Write-Host 'Контактные данные пользователя не удалось скопировать в буфер обмена' -ForegroundColor RED `n
}










[Environment]::NewLine
$ActualWindowsVersion = 'Windows 10 Pro 22H1'
$ActualSsdSize = 'SSD на 240 ГБ'

#function CommentsBPM {    
# Write-Host "На основании информации выше выбери вариант дальнейших действий :" -ForegroundColor Magenta
"На основании информации выше выбери вариант дальнейших действий :"

$WorkType1 = "1. Диск РАЗБИТ и его объём можно увеличить слиянием разделов. Добавить SSD или HDD. "
Write-Host $WorkType1 -ForegroundColor Cyan
$Oth1 = "Необходимо добавить $ActualSsdSize", 'Затем клонировать на него текущую Windows или установить новую.', 'Затем сделать слияние разделов на старом диске (который сейчас установлен на машине пользователя), удалив один из них (скорее всего, диск С).', 'Также оказать помощь пользователю по переносу личных файлов на новый диск D, очистив тем самым диск С: не менее чем на 150 ГБ.', "Модернизации в рамках тикетов System Monitoring Auto Create не производим. необходимо завести дополнительное обращение на Модернизацию рабочего места", ''

$WorkType2 = "2. Диск РАЗБИТ и его объём можно увеличить слиянием разделов. Добавить SSD или HDD. (для УСТАРЕВШИХ версий Windows)"
Write-Host $WorkType2 -ForegroundColor Cyan
$Oth2 = "Необходимо добавить $ActualSsdSize", "Затем установить на него $ActualWindowsVersion", 'Затем сделать слияние разделов на старом диске (который сейчас установлен на машине пользователя).', 'Провести работу с пользователем по обучению сохранению личных файлов на новый созданный диск D:', "Модернизации в рамках тикетов System Monitoring Auto Create не производим. необходимо завести дополнительное обращение на Модернизацию рабочего места", ''

$WorkType3 = "3. На ПК НЕ УСТАНОВЛЕН SSD и объём памяти компьютера можно увеличить установкой SSD."
Write-Host $WorkType3 -ForegroundColor Magenta
$Oth3 = "Необходимо добавить $ActualSsdSize", 'Затем клонировать на него текущую Windows или установить новую.', 'Потом оказать помощь пользователю по переносу личных файлов на диск D, очистив тем самым диск С: не менее чем на 150 ГБ.', "Модернизации в рамках тикетов System Monitoring Auto Create не производим. необходимо завести дополнительное обращение на Модернизацию рабочего места", ''

$WorkType4 = "4. На ПК НЕ УСТАНОВЛЕН SSD и объём памяти компьютера можно увеличить установкой SSD. (для УСТАРЕВШИХ версий Windows)"
Write-Host $WorkType4 -ForegroundColor Magenta
$Oth4 = "Необходимо добавить $ActualSsdSize", "Затем ОБЯЗАТЕЛЬНО установить на него $ActualWindowsVersion или клонировать старую ОС с обновлением до свежей версии Windows через Центр программного обеспечения.", 'Потом оказать помощь пользователю по переносу личных файлов на диск D, очистив тем самым диск С: не менее чем на 100 ГБ.', '', "На основании заявки System Monitoring Auto Create: $Ticket", "Модернизации в рамках тикетов System Monitoring Auto Create не производим. необходимо завести дополнительное обращение на Модернизацию рабочего места", ''

$WorkType5 = "5. На ноутбуке комбинация: NVME 120 ГБ + HDD 500 GB. Замена HDD на SSD 240 ГБ или 500 ГБ."
Write-Host $WorkType5 -ForegroundColor Yellow
$Oth5 = 'Заменить HDD диск на SSD 500 GB', 'Клонировать потом на него систему', 'Не забыть расширить раздел на новом диске и перенести файлы пользователя', 'Текущий NVME-диск потом отформатировать и использовать под файловое хранилище', '', "На основании заявки System Monitoring Auto Create: $Ticket", ''

$WorkType6 = "6. На ноутбуке комбинация: NVME 120 ГБ + HDD 500 GB. Замена HDD на SSD 240 ГБ или 500 ГБ. (Вариант для УСТАРЕВШИХ Windows)"
Write-Host $WorkType6 -ForegroundColor Yellow
$Oth6 = 'Заменить HDD диск на SSD 500 GB', "Установить на него новую $ActualWindowsVersion или клонировать старую, но с ОБЯЗАТЕЛЬНЫМ условием её последующего апгрейда до $ActualWindowsVersion через Центр программного обеспечения", 'Не забыть расширить раздел на новом диске и перенести файлы пользователя', 'Текущий NVME-диск потом отформатировать и использовать под файловое хранилище', '', "На основании заявки System Monitoring Auto Create: $Ticket", ''

$WorkType7 = "7. На ноутбуке всего один диск на 240 ГБ. Замена или добавление SSD на 500 ГБ."
Write-Host $WorkType7 -ForegroundColor Yellow
$Oth7 = "Если устройство позволяет, то добавить $ActualSsdSize", 'Очистить потом диск C: не менее чем на 100 ГБ переносом пользовательской информации на новый диск', 'Если места для установки второго диска нет, то просто заменить на SSD 500 ГБ.', "Модернизации в рамках тикетов System Monitoring Auto Create не производим. необходимо завести дополнительное обращение на Модернизацию рабочего места", ''


$WorkType8 = "8. На ноутбуке всего один диск на 240 ГБ. Замена или добавление SSD на 500 ГБ. (Вариант для УСТАРЕВШИХ Windows)"
Write-Host $WorkType8 -ForegroundColor Yellow
$Oth8 = "Если устройство позволяет, то добавить диск $ActualSsdSize и ОБЯЗАТЕЛЬНО установить $ActualWindowsVersion", 'Очистить потом диск C: не менее чем на 150 ГБ, переносом пользовательской информации на новый диск', "Если места для установки второго диска нет, то просто заменить на SSD 500 ГБ и установить $ActualWindowsVersion", "Модернизации в рамках тикетов System Monitoring Auto Create не производим. необходимо завести дополнительное обращение на Модернизацию рабочего места", ''


$WorkType9 = "9. На ПК не установлен HDD и объём памяти компьютера можно увеличить установкой HDD. "
Write-Host $WorkType9 -ForegroundColor Cyan
$Oth9 = "Добавить HDD на 500 ГБ.", 'Провести работу с сотрудником по обучению переносу личных файлов на диск D: очистив тем самым диск C: не менее чем на 40 ГБ.', $PC, "Модернизации в рамках тикетов System Monitoring Auto Create не производим. Необходимо завести дополнительное обращение на Модернизацию рабочего места", ''

$WorkType10 = "10. На ПК не установлен HDD и объём памяти компьютера можно увеличить установкой HDD. (Вариант для УСТАРЕВШИХ Windows)"
Write-Host $WorkType10 -ForegroundColor Cyan
$Oth10 = "Добавить HDD на 500 ГБ.", 'Провести работу с сотрудником по обучению переносу личных файлов на диск D: очистив тем самым диск C: не менее чем на 140 ГБ.', $PC, "Модернизации в рамках тикетов System Monitoring Auto Create не производим. Необходимо завести дополнительное обращение на Модернизацию рабочего места", ''


$WorkType11 = "11. Провести работу с сотрудником обучению переноса личных файлов на диск D: очистив тем самым диск C: на 140 ГБ."
Write-Host $WorkType11 -ForegroundColor Magenta
$Oth11 = "Провести работу с сотрудником обучению переноса личных файлов на диск D: очистив тем самым диск C: на 140 ГБ.", "Потом ОТМЕНИТЬ заявку, чтобы System Monitoring не беспокоил нас 3 месяца.", ''

$WorkType12 = "12. Провести работу с сотрудником обучению переноса личных файлов на диск D: очистив тем самым диск C: на 140 ГБ (Устаревшая Windows)"
Write-Host $WorkType12 -ForegroundColor Magenta
$Oth12 = "Провести работу с сотрудником по обучению переносу личных файлов на диск D: очистив тем самым диск C: минимум на 150 ГБ.", "ОБЯЗАТЕЛЬНО обновить систему до $ActualWindowsVersion"


$WorkType13 = "13. Полная замена устаревшего системного блока (Ниже i3 4-ой серии)"
Write-Host $WorkType13 -ForegroundColor Yellow
$Oth13 = "Необходимо полностью заменить устаревший системный блок:", $Proc, '',  '!!! Если на старой машине имеется ОЗУ 8 ГБ ОДНОЙ ЦЕЛЬНОЙ планкой, то её снять и передать логисту на склад !!!', 'SSD-диск со старого ПК снять и передать логисту на склад', 'Старый монитор пользователя можно оставить ему вторым', '', 'Имя машины:', $PC, "Модернизации в рамках тикетов System Monitoring Auto Create не производим. Необходимо завести дополнительное обращение на Замену рабочего места", ''

$WorkType14 = "14. Полная замена устаревшего системного блока (Ниже i3 4-ой серии) (Вариант для УСТАРЕВШЕЙ Windows)"
Write-Host $WorkType14 -ForegroundColor Yellow
$Oth14 = "Необходимо полностью заменить устаревший системный блок:", $Proc, '', "На новом ПК ОБЯЗАТЕЛЬНО установить $ActualWindowsVersion", 'Если на старой машине имеется ОЗУ 8 ГБ ОДНОЙ ЦЕЛЬНОЙ планкой, то её снять и передать логисту на склад', 'SSD-диск со старого ПК снять и передать логисту на склад', 'Старый монитор пользователя можно оставить ему вторым', '', 'Имя машины:', $PC, ''


$WorkType15 = "15. Полная замена устаревшего ноутбука (Ниже i3 4-ой серии)"
Write-Host $WorkType15 -ForegroundColor Yellow
 $Oth15 = "Необходимо полностью заменить устаревший ноутбук:", $Proc, '', 'Имя машины:', $PC

 $WorkType16 = "16. Полная замена устаревшего ноутбука (Ниже i3 4-ой серии) (Вариант для УСТАРЕВШЕЙ Windows)"
 Write-Host $WorkType16 -ForegroundColor Yellow
 $Oth16 = "Необходимо полностью заменить устаревший ноутбук:", $Proc, '', "На новом ноутбуке ОБЯЗАТЕЛЬНО установить $ActualWindowsVersion", '', 'Имя машины:', $PC


$WorkType17 = "17. Заменить SSD на больший объём"
Write-Host $WorkType17 -ForegroundColor Cyan
$Oth17 = "Заменить SSD на больший объём = 240 ГБ", 'Старый SSD-диск передать логисту на склад', "Уже далеко не первая заявка на очистку диска", "На основании тикета System Monitoring Auto Create: $Ticket", 'В рамках тикетов System Monitoring Auto Create модернизации не проводим. Необходимо завести дополнительное обращение на Модернизацию рабочего места', ''

$WorkType18 = "18. Заменить SSD на больший объём (Вариант для УСТАРЕВШЕЙ Windows)"
Write-Host $WorkType18 -ForegroundColor Cyan
$Oth18 = "Заменить SSD на больший объём = 240 ГБ", "Необходимо также ОБЯЗАТЕЛЬНО на новом диске обновить систему до $ActualWindowsVersion через Центр Программного обеспечения или установить её с нуля в случае недоступности таковой в Центре ПО.", 'Старый SSD-диск передать логисту на склад', "На основании заявки System Monitoring Auto Create: $Ticket", 'В рамках тикетов System Monitoring Auto Create модернизации не проводим. Необходимо завести дополнительное обращение на Модернизацию рабочего места', ''


$Oth00 = 'Текст комментария скопирован в буфер обмена'
$OthEnter = 'Выбрана стандартная очистка диска и продолжение скрипта'

[Environment]::NewLine
"Укажи номер дальнейшего варианта действий, чтобы скопировать текст комментария к заявке в буфер обмена."
[int]$Choice = Read-Host "ENTER - Просто продолжить очистку диска."


[Environment]::NewLine
if ($Choice -ge 1 -and $Choice -le 18) {
    $Comment = (Get-Variable -Name "Oth$Choice").Value
    Set-Clipboard -Value $Comment
    Write-Host "$Oth00" -ForegroundColor Yellow
    $WorkType = (Get-Variable -Name "WorkType$Choice").Value
}
else {
    Write-Host "$OthEnter" -ForegroundColor Yellow
    $WorkType = "Очистка диска"
}

<#
Switch ($Choice) {
     0{Exit}
     1{[Environment]::NewLine
       Set-Clipboard -Value $Oth1
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType1}
     2{[Environment]::NewLine
       Set-Clipboard -Value $Oth2
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType2}
     3{[Environment]::NewLine
       Set-Clipboard -Value $Oth3
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType3}
     4{[Environment]::NewLine
       Set-Clipboard -Value $Oth4
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType4}
     5{[Environment]::NewLine
       Set-Clipboard -Value $Oth5
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType5}
     6{[Environment]::NewLine
       Set-Clipboard -Value $Oth6
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType6}
     7{[Environment]::NewLine
       Set-Clipboard -Value $Oth7
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType7}
     8{[Environment]::NewLine
      Set-Clipboard -Value $Oth8
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType8}
     9{[Environment]::NewLine
       Set-Clipboard -Value $Oth9
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType9}
    10{[Environment]::NewLine
      Set-Clipboard -Value $Oth10
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType10}
    11{[Environment]::NewLine
      Set-Clipboard -Value $Oth11
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType11}
    12{[Environment]::NewLine
        do {
            Set-Clipboard -Value $Oth12 -ErrorVariable ErrSetClip
        } while ($ErrSetClip)      
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType12}
    13{[Environment]::NewLine
      Set-Clipboard -Value $Oth13
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType13}
    14{[Environment]::NewLine
      Set-Clipboard -Value $Oth14
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType15}
    15{[Environment]::NewLine
      Set-Clipboard -Value $Oth15
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType15}
    16{[Environment]::NewLine
      Set-Clipboard -Value $Oth16
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType16}
    17{[Environment]::NewLine
      Set-Clipboard -Value $Oth17
      Write-Host "$Oth00" -ForegroundColor Yellow
      $WorkType = $WorkType17}
    18{[Environment]::NewLine
        Set-Clipboard -Value $Oth18
        Write-Host "$Oth00" -ForegroundColor Yellow
        $WorkType = $WorkType18}

     Default {[Environment]::NewLine
       Write-Host "$OthEnter" -ForegroundColor Yellow
       $WorkType = "Очистка диска"}
} # Switch END
#Pause
#return $WorkType
#}  # END of CommentsBPM function
#$WorkType = CommentsBPM
#$WorkType
#$WorkType[5]
#>




<# Вывод информации о машине:
[Environment]::NewLine
Write-Host $PC -ForegroundColor Yellow

[Environment]::NewLine
# Новое
$OSversion = (Get-ADComputer -Identity $PC -properties OperatingSystem).OperatingSystem
$OSversion
$OSbuildNumberSplit = ((Get-ADComputer -Identity $PC -properties OperatingSystemVersion).OperatingSystemVersion).split(" ")
$OSbuildNumber = $OSbuildNumberSplit[1].trimstart("(").trimEnd(")")
$OSbuildNumber

# https://docs.microsoft.com/en-us/windows/release-health/release-information
    if ($OSBuildNumber -like '17763') {Write-Host '1809 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '18362') {Write-Host '1903 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '18363') {Write-Host '1909 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '19041') {Write-Host '2004 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '19042') {Write-Host '20H2 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '19043') {Write-Host '21H1 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '19044') {Write-Host '21H1 - версия ОС устарела' -ForegroundColor Red}
elseif ($OSBuildNumber -like '22000') {Write-Host '21H2' -ForegroundColor Green}
  else {'Не удалось определить версию OS'}
  [Environment]::NewLine  

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

    $WorkType = CommentsBPM
    # Занесение полученной информации для будущих ИТ-инженеров в БД MS SQL
    $AdminLogin = $env:USERNAME
    DelTrash -Operation Write -SRnumber $SRnumber -SRlink $SRlink -AdminLogin $AdminLogin -UserLogin $UserProp.SamAccountName -PCname $PC -WorkType $WorkType[4]
}
else {
  Write-Host "ПК $PC недоступен" -ForegroundColor Red
  [Environment]::NewLine
  Write-host 'Информация о компьютере из SCCM / GLPI / Spareparts:' -ForeGroundColor Yellow
  $GLPIread[1]
  [Environment]::NewLine

  $WorkType = CommentsBPM
  # Занесение полученной информации для будущих ИТ-инженеров в БД MS SQL
    $AdminLogin = $env:USERNAME
    DelTrash -Operation Write -SRnumber $SRnumber -SRlink $SRlink -AdminLogin $AdminLogin -UserLogin $UserProp.SamAccountName -PCname $PC -WorkType $WorkType[4]


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
#>




# Занесение полученной информации для будущих ИТ-инженеров в БД MS SQL
 $AdminLogin = $env:USERNAME
 DelTrash -Operation Write -SRnumber $SRnumber -SRlink $SRlink -AdminLogin $AdminLogin -UserLogin $UserProp.SamAccountName -PCname $PC -WorkType $WorkType -IncidentType $IncidentType
 PAUSE




# САМА ОЧИСТКА НИЖЕ
# $PC = 'wsir-it-04'
 if ((Test-Connection -ComputerName $PC -Quiet) -eq "") {
    [Environment]::NewLine
    Write-Host 'Скрипт переведён в режим постоянного отправления пингов. Как только компьютер появится в сети - сразу продолжит работу. Очистка дисков по VPN не работает.' -ForegroundColor Red
    Write-Host 'Не забудь взять заявку в работу, чтобы твой коллега не сделал того же самого с этим же компом.' -ForegroundColor Red
    Write-Host 'Для прекращения работы скрипта команда: CTRL + C' -ForegroundColor Red
    [Environment]::NewLine
    do {$Ping = (Test-Connection -ComputerName $PC -Quiet)} 
    while ($Ping -eq $False) {
      $wshell = New-Object -ComObject Wscript.Shell
      $wshell.Popup("Устройство $PC появилось в сети. Продолжаем очистку")
    }
 }

<#
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

#$DateStart = Get-Date  # Фиксируем время начала отработки скрипта
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
# $PC = 'wsir-it-01'
# Write-Host "Запрос прав администратора домена (admin.ws.)" -ForegroundColor Red
# $AdmWSDomCred = Get-Credential
# $AdmWSDomCred = "Integrated Security=SSPI;" # Не работает
try {
# Invoke-WMIMethod -cred $AdmWSDomCred -path Win32_Process -name Create -argumentlist "powercfg.exe -h off" -ComputerName $PC -ErrorVariable ErrDelHyb -Verbose
  Invoke-WMIMethod -path Win32_Process -name Create -argumentlist "powercfg.exe -h off" -ComputerName $PC -ErrorVariable ErrDelHyb -Verbose
#Write-Host 'Гибернация отключена' -ForegroundColor Magenta
# Wait-Event -Timeout 30
# $ErrDelHyb
}
catch {
    $ErrDelHyb = 'Отключить гибернацию не удалось'
    $ErrDelHyb
}




# Отключение ведение журнала записи отладочной информации при краше системы:
# $PC = 'wsir-it-01'    $PC = '
try {
  Get-WmiObject -Class Win32_OSRecoveryConfiguration -ComputerName $PC -EnableAllPrivileges | Set-WmiInstance -Arguments @{ DebugInfoType=0 }
# Set-WmiInstance -Class Win32_OSRecoveryConfiguration -ComputerName $PC -Arguments @{ DebugInfoType=1 }
# Write-Host 'Запись отладочной информации отключена' -ForegroundColor Magenta
}
catch {
    $ErrDisDebugInfo = 'Отключить гибернацию не удалось'
    $ErrDisDebugInfo
}




################################################### 
<# Вывести размер профиля каждого пользователя в папке C:\Users :
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
$UserPropsfol = Get-ChildItem $wcUsers -Force # -ErrorAction SilentlyContinue # | Sort-Object LastWriteTime
  #           Get-ChildItem "\\WSZI-NGTIATE-03\C$\Users\" -Force | Sort-Object LastWriteTime
  #           Get-ChildItem "\\WSZI-NGTIATE-03\C$\Users\" -Force | Sort-Object Name
do {$Error[0] = $Null
    $x = $x + 1  
    # $fo = $UserPropsfol[$x].lastwritetime      # $UserPropsfol[1].length Name    # $fo = $UserPropsfol[0].lastwritetime    # $UserPropsfol[0].fullname.Split("\")[-1]  # $full = 'ivan.kazanin'
    $full = $UserPropsfol[$x].fullname.Split("\")[-1]
    $full
    
     #if ($full = $UserPropsfol[$x].fullname.Split("\")[-1]){

       # Ищем профили пользователей, не изменяемые старше (Get-Date).AddDays(-250)
       $Fold = 'Все пользователи','All Users','Default','Default User','Администратор','Administrator','Public','Общие','desktop.ini',$UserProp.SamAccountName
       if (($UserPropsfol[$x].lastwritetime -lt (Get-Date).AddDays(-90)) -and $fold -notcontains $full)
       
       {Get-WMIObject -class Win32_UserProfile -ComputerName $pc | Where-Object {$_.LocalPath -like 'C:\Users\'+$full} | Remove-WmiObject 
       if ($Error[0] -like '*Wmi*') { # Write-Host 'Профиль '$full' не смог удалиться' -ForegroundColor Yellow
       Remove-Item -Path "\\$PC\C$\Users\$full\" -force -recurse -verbose -ErrorVariable ErrDel }
       else {Write-Host 'Профиль '$full' удалён' -ForegroundColor Magenta}}
    
  } while ($Error[0] -notlike '*вызвать метод*')  # $null -ne $fo)
#>
# Удаление папок/профилей неиспользуемых пользователей #2 (ВРЕМЕННО отключл):
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
<# Удаление папок/профилей неиспользуемых пользователей #3:
#$UserProp.SamAccountName = 'Polina.Mosichenko'
$NoDelUsers = 'Все пользователи','All Users','Default','Default User','Администратор','Administrator','Public','Общие','desktop.ini',$UserProp.SamAccountName
#$PC = 'wszi-leader-12'
 $PC = 'WSZI-NGTIATE-03'
#$PC = 'wszi-IT-01'
$wcusers = "\\$PC\C$\Users\"
$UserPropsfol = Get-ChildItem $wcUsers -Force

Get-WMIObject -class Win32_UserProfile -ComputerName $pc | Where-Object LastUseTime -gt (Get-Date).AddDays(-60) | ForEach-Object
Get-WMIObject -class Win32_UserProfile -ComputerName $pc | Where-Object LastUseTime -gt (Get-Date).AddDays(-60) | ForEach-Object

foreach ($UF in $UserPropsfol) {  
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
# Дата с которой сравнивать. В этом случае -15 дней от текущей даты
# $TEMPdate = (Get-Date).AddDays(-10)
# Или дата кастомная. Пустые значения будут взяты из текущего времени и даты
# $date = Get-Date -Year 2018 -Month 12 -Day 2 -Hour 12 -Minute 13

# $PC = 'WSRU-VAKULICH'
         $wc = "\\$PC\C$\"   # ДИСК С !!!

    $wcdump1 = "\\$PC\C$\Windows\MEMORY.DMP"
    $wcdump2 = "\\$PC\C$\Windows\minidump\*"
  $wcUpdate1 = "\\$PC\C$\Windows\SoftwareDistribution\Download\*"
# $wcUpdate2 = "\\$PC\C$\Windows\SoftwareDistribution\DataStore\*" # Папка не большая и удалять не очень хочется
  $wcUpdate3 = "\\$PC\C$\Windows\ccmcache\*"    # Настравиается размер кэша SCCM в корне Панели управления
        $LCU = "\\$PC\C$\Windows\servicing\LCU\*"
    $TempWin = "\\$PC\C$\Windows\temp\*"
#  $Prefetch = "\\$PC\C$\Windows\Prefetch\*"  # Никогда не вешает больше 50 мб      

  $TempLocal = "\\$PC\C$\Users\*\Appdata\Local\Temp\*"
 $TempChrome = "\\$PC\C$\Users\*\AppData\Local\Google\Chrome\User Data\Default\Code Cache\js\*" 
#  $wsSketch = "\\$PC\C$\Users\*\AppData\Local\Microsoft\Windows\Explorer\*  # Эскизы Windows
#              "\\$PC\C$\Users\*\AppData\\Local\Microsoft\Terminal Server Client\Cache\*”
#              "\\$PC\C$\Users\*\AppData\\Local\Microsoft\Windows\Explorer\*"

$wctelemetry = "\\$PC\C$\ProgramData\Microsoft\Diagnosis\ETLLogs\*"
  $Bartender = "\\$PC\c$\ProgramData\Seagull\System\Database\Backup\*"

#$wcDLPagent = "\\$PC\C$\Program Files\Manufacturer\Endpoint Agent\temp\"

  $wcoldwin1 = "\\$PC\C$\Windows.ol*\Users\*.*\"
  $wcoldwin2 = "\\$PC\C$\Windows.ol*\"

      $TempC = "\\$PC\C$\Temp\*"      # Сама Temp не удаляется
    $SetupSW = "\\$PC\C$\swsetup\"    # Полное удаление папки
  $SetupHpSw = "\\$PC\C$\hpswsetup\"  # Полное удаление папки

  Remove-Item $wcoldwin1 -force -recurse -verbose -ErrorVariable ErrDelWinOld
  Remove-Item $wcoldwin2 -force -recurse -verbose -ErrorVariable ErrDelWinOld
# Remove-Item $wcoldwin3 -force -recurse -verbose -ErrorVariable ErrDelWinOld -Exclude *All users*
# if ($ErrDelWinOld) {$ErrDelWinOld = 'Папка Windows.Old не смогла удалиться полностью. Можешь подключиться.'}
  if ($ErrDelWinOld) {$ErrDelWinOld = "Папка Windows.Old не смогла удалиться полностью. Можешь подключиться к диску C: и удалить её вручную:", $wc}

# Удаление всех файлов и папок (в т.ч. внутри папок) старше чем значение в $TEMPdate
# Get-ChildItem -Recurse -Path $wctemp1,$wctemp2 | Where-Object -Property CreationTime -gT $TEMPdate | Remove-Item -force -recurse -verbose -ErrorVariable ErrDelTemp

# $ForDelFold = @($wcoldwin1, $wcoldwin2, $wcdump1, $wcdump2, $wcUpdate1, $wctemp1, $wctemp2)
# $ForDelFold = @($wcdump1, $wcdump2, $wcUpdate1, $wctemp1, $wctemp2)
  $ForDelFold = $wcdump1, $wcdump2, $wcUpdate1, $wcUpdate3, $TempWin, $TempC, $TempLocal, $TempChrome, $LCU, $wctelemetry, $Bartender, $SetupHpSw, $SetupSw
# $ForDelFold = @($wcdump1, $wcdump2, $wcUpdate1)
# Remove-Item $tempfolders -force -recurse -verbose #-ErrorAction SilentlyContinue
  Remove-Item $ForDelFold -force -recurse -verbose #-ErrorAction SilentlyContinue
# Remove-Item $wcUpdate -force -recurse -verbose
# Remove-Item "\\wssp-e-nazarova\c$\ProgramData\Seagull\System\Database\Backup\" -force -recurse -verbose
# Remove-Item "D:\Work PC\1\Удалить\DeleteSoftIB\" -force -recurse -verbose



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




<# Советуют использовать этот командлет заместо gwmi :
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






#####   КОРЗИНА    ##############
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
# Мягкое очищение корзины:
# $PC = 'WSIR-IT-01'
$wcRecycle = "\\$PC\C$\`$Recycle.bin\S-1*\*"
Remove-Item -Path $wcRecycle -Exclude "desktop.ini" -Recurse -Force -Verbose # -ErrorAction SilentlyContinue 
#Remove-Item -Path "\\$PC\C$\`$Recycle.Bin\S-1*\*" -Exclude "desktop.ini"-Recurse -Force -Verbose  

# Грубое удаление корзины (Корзина заново заработает в течение суток):
# Remove-Item -Path \\$PC\C$\$Recycle.bin -Recurse -Force -Verbose  

<# Если необходимо очистить все диски, убрать: -Drive C:
Write-host 'Текущие объёмы корзин пользователей:' -ForegroundColor Magenta
Get-RecycleBinSize -ComputerName $PC -Drive C: 
Write-host 'Очистка корзин:' -ForegroundColor Magenta
Get-RecycleBinSize -ComputerName $PC -Drive C: -Empty
#>



# $PC = 'wsir-it-01'
Get-WmiObject -Class Win32_diskdrive -ComputerName $PC | Format-Table -Property Model, @{Label="Size(GB)"; Expression={$_.Size/1Gb}} -AutoSize
[Environment]::NewLine
# Окончательный вывод:
<#Write-host 'Было :' -ForegroundColor Magenta
"Disk " + $p.DeviceID + " FreeSpace : {0}" -f ($p.FreeSpace / 1GB).ToString("F01") + ' GB' #>
Write-host 'Стало :' -ForegroundColor Magenta
$pi = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | Where-Object {$_.deviceid -like 'C:'}
"Disk " + $pi.DeviceID + " FreeSpace : {0}" -f ($pi.FreeSpace / 1GB).ToString("F01") + ' GB'



[Environment]::NewLine
$DateEnd = Get-Date
'Процесс очистки компьютера занял:'
$DateEnd - $DateStart | Select-Object Days, Hours, Minutes | Out-Host
[Environment]::NewLine




 Write-host "Ошибки, на которые можно обратить внимание, а можно и не обращать:" -ForegroundColor Magenta
 [Environment]::NewLine
 $ErrDelHyb
 [Environment]::NewLine
 $ErrDisDebugInfo
 [Environment]::NewLine
 $ErrDelWinOld 
 [Environment]::NewLine




# Завершение Логирования НОВОЕ
  $FeedBack = Read-Host "Напиши в свободной форме, как улучшить скрипт "
  ScriptsExecute -Operation Update -AdminLogin $AdminLogin -DateStart $DateStart -DateEnd $DateEnd -Feedback $FeedBack -ScriptName $ScriptName

