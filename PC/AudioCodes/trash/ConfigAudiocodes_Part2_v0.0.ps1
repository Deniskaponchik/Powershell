# Version:      0.0
# STATUS:       НЕ Протестировано
# Цель:         второй этап настройки систем ВКС AudioCodes после перезагрузки
# реализация:   
# проблемы:     
# Планы:        Протестировать на бОльшем кол-ве устройств
# Last Update:  
# Author:       denis.tirskikh@tele2.ru


<# !!! Сначала запускаем только эту одну строку кода снизу (выделить или поставить курсор и F8)
try {
    Set-ExecutionPolicy Unrestricted
    Write-Host  "Политика выполнения PS-скриптов включена" -ForegroundColor Green
}
catch {
    Write-Host  'Политика выполнения PS-скриптов уже включена' -ForegroundColor Green  
}
[Environment]::NewLine
#>


#####  Смена языка  #####
# Язык teams
# при первом заходе не срабатывает. 
c:\Rigel\x64\scripts\provisioning\scriptlaunch.ps1 ApplyCurrentRegionAndLanguage.ps1
Write-Host "Язык teams изменён на руский" -ForegroundColor Green
#Write-Host "Teams language changed to RUSSIAN" -ForegroundColor Green
Write-Host "После окончания скрипта проверь смену языка в оболочке Teams" -ForegroundColor Green
[Environment]::NewLine
PAUSE



# ZABBIX
# 1. Конфигурируем Zabbix conf file
Write-Host "От корректности введённых данных далее зависит правильность заведения обращений в bpm в будущем при инцидентах" -ForegroundColor RED
[Environment]::NewLine 
#
Write-Host "Укажи имя компьютера" -ForegroundColor RED
Write-Host "Имя должно начинаться с VCSXX-ConfRoomName" -ForegroundColor RED
Write-Host "XX           - двухбуквенный код региона из AD" -ForegroundColor RED
Write-Host "ConfRoomName - имя переговорной комнаты" -ForegroundColor RED
Write-Host "Длина всего имени компьютера не больше 15 символов" -ForegroundColor RED
do {
    $PcNewName = Read-Host "Hostname "
} while (
    ($PcNewName -eq '') -or ($PcNewName -notmatch "[v][c][s][A-z][A-z][-].\B" -and $PcNewName.Length -le 15)
)
$PcNewName
[Environment]::NewLine
#PAUSE


Write-Host "Далее нужно будет указать регион на русском языке, как в выпадающем списке в заявке:" -ForegroundColor RED
Write-Host "Helpdesk IT - System Monitoring.ВКС" -ForegroundColor RED
<#Вариант с бро отметаем, т.к. у устройства нет возможности проверить корректность данных доменного пользователя
Write-Host "Будет попытка открытия bro, чтобы ты смог посмотреть, как там прописан параметр Регион" -ForegroundColor RED
Write-Host "Чтобы bro открылся, необходимо ввести свои доменные учётные данные (не админские)" -ForegroundColor RED
Write-Host "Логин необходимо ввести в формате: t2ru\name.family" -ForegroundColor RED
Pause

$BroSmacLink = "https://bro.tele2.ru/create-bid/8ec1af6d-c717-449b-837b-7bd443fab97a"
#Write-Host $BroSmacLink -ForegroundColor Magenta
#$BroSmacLink | Set-Clipboard
#Write-host 'ссылка на заявку скопирована в буфер обмена' -ForegroundColor Green

$credential = Get-Credential
Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" "--new-window $BroSmacLink" -Credential ($Credential)
#[system.Diagnostics.Process]::Start("msedge",$BroSmacLink)

Write-Host "Проверь открываемость bro" -ForegroundColor RED
PAUSE
#>

$Region = Read-Host "Офис "
#do {$Region = Read-Host "Офис "} 
#while (($PcNewName -eq '') -or ($PcNewName -notmatch "[v][c][s][A-z][A-z][-].\B" -and $PcNewName.Length -le 15))
$Region.Trim()
[Environment]::NewLine

Write-Host "Укажи ЛОГИН сотрудника ИТ Теле2, если есть в регионе" -ForegroundColor RED
Write-Host "ИЛИ ЛОГИН административного специалиста региона, если своих ит в офисе нет" -ForegroundColor RED
Write-Host "ИЛИ ЛОГИН приближенного к ИТ отделу сотрудника эксплуатации" -ForegroundColor RED
#do {    $Region = Read-Host "ЛОГИН "} 
#while (    ($PcNewName -eq '') -or ($PcNewName -notmatch "[v][c][s][A-z][A-z][-].\B" -and $PcNewName.Length -le 15))
$UserLogin = Read-Host "ЛОГИН "
$UserLogin.trim()
[Environment]::NewLine

#do {    $Region = Read-Host "Имя переговорной комнаты "} 
#while (    ($PcNewName -eq '') -or ($PcNewName -notmatch "[v][c][s][A-z][A-z][-].\B" -and $PcNewName.Length -le 15))
$RoomName = Read-Host "Имя переговорной комнаты на русском "
$RoomName.trim()
[Environment]::NewLine

#$ZabbixServer = ""
[Environment]::NewLine
Write-Host "1. МР Сибирь и ДВ"
Write-Host "2. МР ЮГ"
Write-Host "3. МР Северо-Запад"
Write-Host "4. МР Волга"
Write-Host "5. МР Москва"
Write-Host "6. МР Центр"
Write-Host "7. МР Урал"
[Environment]::NewLine
$ZabbixServerChoice = Read-Host "Выбери макрорегион, в котором будет установлено ВКС. Укажи НОМЕР от 1 до 7 "
switch($ZabbixServerChoice){  #$ZabbixServer = 
        1{$ZabbixServer = "t2rs-rmon-01.corp.tele2.ru"}
        2{$ZabbixServer = "t2rr-rmon-01.corp.tele2.ru"}
        3{$ZabbixServer = "t2rp-rmon-01.corp.tele2.ru"}
        4{$ZabbixServer = "t2rn-rmon-01.corp.tele2.ru"}
        5{$ZabbixServer = "t2rm-rmon-02.corp.tele2.ru"}
        6{$ZabbixServer = "t2rm-rmon-02.corp.tele2.ru"}
        7{$ZabbixServer = "t2re-rmon-02.corp.tele2.ru"}
 Default {$ZabbixServer = "t2rs-rmon-01.corp.tele2.ru"} #УТОЧНИТЬ, ИСПРАВИТЬ!!!
}
$ZabbixServer


#$VcsType = "AudioCodes"
[Environment]::NewLine
Write-Host "1. AudioCodes RXV 100"
Write-Host "2. Lenovo Tnink Smart Hub"
Write-Host "3. Lenovo Tnink Smart Core"
#Write-Host "4. Обновление Windows"
#Write-Host "5. Другое"
[Environment]::NewLine
$Choice = Read-Host "Выбери тип ВКС. Укажи НОМЕР от 1 до 3 "
switch($Choice){
    1{$VcsType = "AudioCodes RXV 100"}
    2{$VcsType = "Lenovo Tnink Smart Hub"}
    3{$VcsType = "Lenovo Tnink Smart Core"}
    #4{$VcsType = "Обновление Windows"}
    #5{$VcsType = "Другое"}
    Default {$VcsType = "Lenovo"}
}
$VcsType

$PathZabbixConf = "C:\AudioCodes\Zabbix\zabbix_agentd.conf"
$PathZabbixExe = "C:\AudioCodes\Zabbix\zabbix_agentd.exe"

try {
    #(Get-Content Input.json) -replace '"(\d+),(\d{1,})"', '$1.$2' `
    #-replace 'second regex', 'second replacement' | 
    #Out-File output.json
    #"HostMetadata=Region=Нижний Новгород:UserLogin=roman.novotorov:RoomName=Бежин Луг:IsVcs=true:VcsType=Lenovo"

    #(Get-Content -Path "D:\Test.txt" -ErrorVariable ErrGetZabbixConfig -ErrorAction Stop) `
    #-replace 'TEST', 'VCS' | 
    #Out-File "D:\Test.txt"

    #$TestTxt = Get-Content -Path "D:\Test.txt" -ErrorVariable ErrGetZabbixConfig -ErrorAction Stop
    #$TestTxt.replace('TEST', 'VCS').replace('tst', 'txt') | 
    #Out-File "D:\Test.txt"

    <#
    (Get-Content -Path $PathZabbixConf -ErrorVariable ErrGetZabbixConfig -ErrorAction Stop) `
    -replace '#Server=WillChangeFromScript', "Server=$ZabbixServer"`
    -replace '#ServerActive=WillChangeFromScript', "ServerActive=$ZabbixServer"`
    -replace '#Hostname=WillChangeFromScript', "Hostname=$PcNewName"`
    -replace '#HostMetadata=WillChangeFromScript', "HostMetadata=Region=$Region:UserLogin=$UserLogin:RoomName=$RoomName:IsVcs=true:VcsType=$VcsType" | 
    Out-File $PathZabbixConf #zabbix_agentd.conf
    #>

    <#
    (Get-Content -Path $PathZabbixConf -Encoding UTF8 -ErrorVariable ErrGetZabbixConfig -ErrorAction Stop).replace('#Server=WillChangeFromScript', "Server=$ZabbixServer").replace('#ServerActive=WillChangeFromScript', "ServerActive=$ZabbixServer").replace('#Hostname=WillChangeFromScript', "Hostname=$PcNewName").replace('#HostMetadata=WillChangeFromScript', "HostMetadata=Region=$Region;UserLogin=$UserLogin;RoomName=$RoomName;IsVcs=true;VcsType=$VcsType;") | 
    Out-File $PathZabbixConf -Encoding UTF8 #ASCII
    #>

    #https://stackoverflow.com/questions/5596982/using-powershell-to-write-a-file-in-utf-8-without-the-bom
    $MyRawString = Get-Content -Raw $PathZabbixConf
    $MyRawStringReplace = $MyRawString.replace('#Server=WillChangeFromScript', "Server=$ZabbixServer").replace('#ServerActive=WillChangeFromScript', "ServerActive=$ZabbixServer").replace('#Hostname=WillChangeFromScript', "Hostname=$PcNewName").replace('#HostMetadata=WillChangeFromScript', "HostMetadata=Region=$Region;UserLogin=$UserLogin;RoomName=$RoomName;IsVcs=true;VcsType=$VcsType;")
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($PathZabbixConf, $MyRawStringReplace, $Utf8NoBomEncoding)


    [Environment]::NewLine
    Write-Host "Изменения в файл конфигурации Zabbix-агента внесены" -ForegroundColor GREEN
}
catch {
    Write-Host "Не удалось внести изменения в файл конфигурации Zabbix агента" -ForegroundColor RED
    Write-Host "Проверь, что файлы лежат в этой директории:" -ForegroundColor RED
    Write-Host $PathZabbixExe -ForegroundColor RED
    Write-Host $PathZabbixConf -ForegroundColor RED
}
[Environment]::NewLine
Write-Host "Проверь, изменился ли файл $PathZabbixConf" -ForegroundColor RED
PAUSE

# 2. Конфигурируем Firewall
try {
    New-NetFirewallRule -DisplayName "Разрешить приложение Zabbix Agent" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Program $PathZabbixExe -Verbose -ErrorAction Stop -ErrorVariable ErrAllowZabixExe
    New-NetFirewallRule -DisplayName "Разрешить порт 10050 для Zabbix" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 10050 -Verbose -ErrorAction Stop -ErrorVariable ErrAllowZabixPort
    Write-Host "Созданы разрешающие правила на firewall для Zabbix" -ForegroundColor Green
}
catch {
    Write-Host "Разрешающие правила на брандмауэре для заббикса не были созданы" -ForegroundColor Red
    Write-Host "Без них запуск сервиса невозможен" -ForegroundColor Red
    Write-Host "Убедись, что запускаешь скрипт от имени администратора" -ForegroundColor Red
    [Environment]::NewLine
    exit
}
[Environment]::NewLine

# 3. Устанавливаем и запускаем службу
#& "C:\AudioCodes\Zabbix\zabbix_agentd.exe" --config "C:\AudioCodes\Zabbix\zabbix_agentd.conf" --install -verbose
#& "C:\AudioCodes\Zabbix\zabbix_agentd.exe" --config "C:\AudioCodes\Zabbix\zabbix_agentd.conf" --start -verbose
#Write-Host "Zabbix-агент установлен и запущен" -ForegroundColor GREEN
try {
    #Start-Process -FilePath $PathZabbixExe -ArgumentList "--config 'C:\AudioCodes\Zabbix\zabbix_agentd.conf' --install" -Verbose -ErrorVariable ErrZabbixInstall -ErrorAction Stop
    #Start-Process -FilePath $PathZabbixExe -ArgumentList "--start" -Verbose -ErrorVariable ErrZabbixInstall -ErrorAction Stop

    #Start-Process -FilePath $PathZabbixExe -ArgumentList "--config $PathZabbixConf --install" -Verbose -ErrorVariable ErrZabbixInstall -ErrorAction Stop
    #Start-Process -FilePath $PathZabbixExe -ArgumentList "--start" -Verbose -ErrorVariable ErrZabbixInstall -ErrorAction Stop

    cd "C:\AudioCodes\Zabbix\"
    .\zabbix_agentd.exe -c .\zabbix_agentd.conf -i
    .\zabbix_agentd.exe -s
    
    Write-Host "Zabbix-агент установлен и запущен" -ForegroundColor GREEN
    Write-Host "Проверь, запустилась ли служба Zabbix в Службах Диспетчера задач" -ForegroundColor Green

    start taskmgr.exe
}
catch {
    Write-Host "Zabbix агент не смог установиться или запуститься." -ForegroundColor RED
    Write-Host "Проверь, что файлы лежат в этой директории:" -ForegroundColor RED
    Write-Host $PathZabbixExe -ForegroundColor RED
    Write-Host $PathZabbixConf -ForegroundColor RED
}
[Environment]::NewLine
PAUSE




#Write-Host "Ошибки, Логи, Баги, Скрины, Проблемы, Пожелания, Предложения и Любую другую обратную связь"
#Write-Host "отправлять на:"
#Write-Host "denis.tirskikh@tele2.ru"
Write-Host "Errors, bugs, logs, screens, photos, reports, problems, suggestions and other feedback"
Write-Host "send to:"
Write-Host "denis.tirskikh@tele2.ru"
[Environment]::NewLine
PAUSE


#CHECK.
#Restart-Computer -Confirm -Force
