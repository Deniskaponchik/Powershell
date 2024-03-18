# Version:      0.0
# STATUS:       Не протестировано
# Цель:         настройка и запуск Zabbix для систем ВКС AudioCodes
# реализация:   Меняет параметры в conf.file, устанавливает и запускает службу
# проблемы:     
# Планы:        Протестировать
# Last Update:  Все функции в принципе добавлены. нужно проверять
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

#Внешние входные параметры для скрипта
[CmdletBinding()]
Param (
    [Parameter (Position=1)] #[Parameter (Mandatory=$true, Position=1)]
    #[alias("ARG","ArgumentName")]
    #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
    #[ValidateLength(1,3)]
    [string]
    $language,

    [Parameter (Position=2)] #[Parameter (Mandatory=$true, Position=2)]
    [string]
    $hostname
)
Write-Host "Language : "$language
Write-Host "Hostname : "$hostname

[Environment]::NewLine 
#PAUSE

#Если скрипт запускается не в рамках другого PS-скрипта и язык явно не указан в параметрах
if (!$language){
    do {
        Write-Host "Choose language of this script "
        [Environment]::NewLine

        Write-Host "0. English"
        Write-Host "1. Russian"
        [Environment]::NewLine

        $LangChoice = Read-Host "Input NUMBER of language "
        switch($LangChoice){
            0{$language = "ENG"}
            1{$language = "RUS"}
            Default {$language = "ENG"}
        }
        $language
    } while (
        ($language -ne "ENG") -and ($language -ne "RUS") #-and ($language -ne "Test")
    )

    [Environment]::NewLine
    PAUSE
}


<#Предупреждение, что от заббикса зависит создание заявок в bpm
if ($language -eq "RUS"){
    Write-Host "От корректности введённых данных далее зависит правильность заведения обращений в bpm в будущем при инцидентах" -ForegroundColor RED
}else{
    Write-Host "The correctness of placing requests depends on the entered data" -ForegroundColor RED
}
[Environment]::NewLine 
#>


# 1. Конфигурируем Zabbix conf file
#Если скрипт запускается не в рамках другого PS-скрипта и имя компьютера явно не указано в параметрах
if (!$hostname){
    if ($language -eq "RUS"){
        Write-Host "Укажи имя компьютера" -ForegroundColor RED
        Write-Host "Имя должно начинаться с VCSXX-ConfRoomName" -ForegroundColor RED
        Write-Host "XX           - двухбуквенный код региона из AD" -ForegroundColor RED
        Write-Host "ConfRoomName - имя переговорной комнаты" -ForegroundColor RED
        Write-Host "Длина всего имени компьютера не больше 15 символов" -ForegroundColor RED
    }else{
        Write-Host "Input computer name" -ForegroundColor RED
        Write-Host "name should match with mask:" -ForegroundColor RED
        Write-Host "VCSXX-ConfRoomName" -ForegroundColor RED
        Write-Host "where" -ForegroundColor RED
        Write-Host "XX           - 2 letter code from AD" -ForegroundColor RED
        Write-Host "ConfRoomName - Name of conf room" -ForegroundColor RED
        Write-Host "Name length must contains max 15 letters" -ForegroundColor RED
    }
    [Environment]::NewLine

    do {
        $hostname = Read-Host "Hostname "
    } while (
        ($hostname -eq '') -or ($hostname -notmatch "[v][c][s][A-z][A-z][-].\B" -and $hostname.Length -le 15)
    )
    $hostname

    [Environment]::NewLine
    PAUSE
}


do {
    if ($language -eq "RUS"){
        Write-Host "Укажи ЛОГИН сотрудника ИТ Теле2, если есть в регионе" -ForegroundColor RED
        Write-Host "ИЛИ ЛОГИН административного специалиста региона, если своих ит в офисе нет" -ForegroundColor RED
        Write-Host "ИЛИ ЛОГИН приближенного к ИТ отделу сотрудника эксплуатации" -ForegroundColor RED
        [Environment]::NewLine
        $UserLogin = Read-Host "ЛОГИН "
    }else{
        Write-Host "Input IT engineer login, if locate in the region" -ForegroundColor RED
        Write-Host "OR Administrative specialist login, if the region doesn't have own IT Tele2" -ForegroundColor RED
        Write-Host "OR login of Technical department exploitation engineer, which approximate to IT department" -ForegroundColor RED
        [Environment]::NewLine
        $UserLogin = Read-Host "Login "
    }
} while (
    $UserLogin -eq '' #or #Добавить проверку на наличие точки посередине логина
)
$UserLogin.trim()
[Environment]::NewLine


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


do {
    if ($language -eq "RUS"){
        Write-Host "Далее нужно будет указать регион на русском языке, как в выпадающем списке в заявке:" -ForegroundColor RED
        Write-Host "Helpdesk IT - System Monitoring.ВКС" -ForegroundColor RED
        [Environment]::NewLine
        $Region = Read-Host "Офис "
    }else{
        Write-Host "Input the Region ON RUSSIAN LANGUAGE as in drop-down list from bpm ticket:" -ForegroundColor RED
        Write-Host "Helpdesk IT - System Monitoring.VCS" -ForegroundColor RED
        Write-Host "Russian letters can be displayed as QUESTIONS mark - it's NORMAL" -ForegroundColor RED
        [Environment]::NewLine
        $Region = Read-Host "Office "
    }
    $Region.Trim()
    [Environment]::NewLine
} 
while (
    ($Region -eq '') -or ($Region.Length -lt 3) #$PcNewName -notmatch "[v][c][s][A-z][A-z][-].\B" -and 
)
[Environment]::NewLine



do {    
    if ($language -eq "RUS"){
        $RoomName = Read-Host "Имя переговорной комнаты на русском "
        $RoomName.trim()
        [Environment]::NewLine

    }else{
        $RoomName = Read-Host "Input room name ON RUSSIAN LANGUAGE "
        Write-Host "Russian letters can be displayed as QUESTIONS mark - it's NORMAL" -ForegroundColor RED
        $RoomName.trim()
        [Environment]::NewLine
    }
}while(
    ($RoomName -eq '')
)


do {    
    if ($language -eq "RUS"){
        
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

    }else{
        
        #$ZabbixServer = ""
        [Environment]::NewLine
        Write-Host "1. MR Sibir and Far East"
        Write-Host "2. MR South"
        Write-Host "3. MR North-West"
        Write-Host "4. MR Volga"
        Write-Host "5. MR Moscow"
        Write-Host "6. MR Center"
        Write-Host "7. MR Ural"
        [Environment]::NewLine
        $ZabbixServerChoice = Read-Host "Choose macroregion, where vcs will install. Input NUMBER from 1 to 7 "
    }
} 
while (    
    ($ZabbixServerChoice -eq '') #-or ($PcNewName -notmatch "[v][c][s][A-z][A-z][-].\B" -and $PcNewName.Length -le 15)
)
switch($ZabbixServerChoice){
        1{$ZabbixServer = "t2rs-rmon-01.corp.tele2.ru"}
        2{$ZabbixServer = "t2rr-rmon-01.corp.tele2.ru"}
        3{$ZabbixServer = "t2rp-rmon-01.corp.tele2.ru"}
        4{$ZabbixServer = "t2rn-rmon-01.corp.tele2.ru"}
        5{$ZabbixServer = "t2rm-rmon-02.corp.tele2.ru"}
        6{$ZabbixServer = "t2rm-rmon-02.corp.tele2.ru"}
        7{$ZabbixServer = "t2re-rmon-02.corp.tele2.ru"}
 Default {$ZabbixServer = "t2rs-rmon-01.corp.tele2.ru"} #Не корректные машины будут попадать в Сибирь и ДВ
}
$ZabbixServer



#$VcsType = "AudioCodes"
[Environment]::NewLine
Write-Host "1. AudioCodes RXV 100"
Write-Host "2. Lenovo Tnink Smart Hub"
Write-Host "3. Lenovo Tnink Smart Core"
[Environment]::NewLine
do {
    if ($language -eq "RUS"){
        $VcsTypeChoice = Read-Host "Выбери тип ВКС. Укажи НОМЕР от 1 до 3 "
    }else{
        $VcsTypeChoice = Read-Host "Choose VCS type. Input NUMBER from 1 to 3 "
    }
} while (
    ($VcsTypeChoice -eq '')
)
switch($Choice){
    1{$VcsType = "AudioCodes RXV 100"}
    2{$VcsType = "Lenovo Tnink Smart Hub"}
    3{$VcsType = "Lenovo Tnink Smart Core"}
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
    $MyRawStringReplace = $MyRawString.
    replace('#Server=WillChangeFromScript', "Server=$ZabbixServer").
    replace('#ServerActive=WillChangeFromScript', "ServerActive=$ZabbixServer").
    replace('#Hostname=WillChangeFromScript', "Hostname=$PcNewName").
    replace('#HostMetadata=WillChangeFromScript', "HostMetadata=Region=$Region;UserLogin=$UserLogin;RoomName=$RoomName;IsVcs=true;VcsType=$VcsType;")
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($PathZabbixConf, $MyRawStringReplace, $Utf8NoBomEncoding)


    [Environment]::NewLine
    if ($language -eq "RUS"){
        Write-Host "Изменения в файл конфигурации Zabbix-агента внесены" -ForegroundColor GREEN
    }else{
        Write-Host "The Zabbix Agent conf.file was changed successfully" -ForegroundColor GREEN
    }
   
}
catch {
    if ($language -eq "RUS"){
        Write-Host "Не удалось внести изменения в файл конфигурации Zabbix агента" -ForegroundColor RED
        Write-Host "Проверь, что файлы лежат в этой директории:" -ForegroundColor RED
    }else{
        Write-Host "The Zabbix Agent conf.file was NOT changed" -ForegroundColor RED
        Write-Host "Check file in the directory:" -ForegroundColor RED
    }
    Write-Host $PathZabbixExe -ForegroundColor RED
    Write-Host $PathZabbixConf -ForegroundColor RED
}
[Environment]::NewLine


try {
    #Start-Process 'C:\WINDOWS\system32\notepad.exe' 'D:\WorkPC\1\log.log'
    Start-Process 'C:\WINDOWS\system32\notepad.exe' $PathZabbixConf

    if ($language -eq "RUS"){
        #Write-Host "Если имеются какие-либо неточности или вопросы в РАСКОММЕНТИРОВАННЫХ строках" -ForegroundColor RED
        #Write-Host "То можешь передать скрин/фото неточностей" -ForegroundColor RED
        #Write-Host "denis.tirskikh@tele2.ru" -ForegroundColor RED
        Write-Host "Ты можешь ознакомиться с итоговым файлом конфигурации" -ForegroundColor Green
    }else{
        Write-Host "You can view the zabbix agent conf file" -ForegroundColor Green
    }
}
catch {
    if ($language -eq "RUS"){
        Write-Host "не удалось открыть файл конфигурации Zabbix агента" -ForegroundColor RED
        Write-Host "Проверь файл $PathZabbixConf" -ForegroundColor RED
    }else{
        Write-Host "Could not open the Zabbix agent conf.file" -ForegroundColor RED
        Write-Host "Check $PathZabbixConf" -ForegroundColor RED
    }
}
[Environment]::NewLine
PAUSE


# 2. Конфигурируем Firewall
try {
    New-NetFirewallRule -DisplayName "Allow Zabbix Agent app" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Program $PathZabbixExe -Verbose -ErrorAction Stop -ErrorVariable ErrAllowZabixExe

    New-NetFirewallRule -DisplayName "Allow port 10050 for Zabbix Agent" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 10050 -Verbose -ErrorAction Stop -ErrorVariable ErrAllowZabixPort

    if ($language -eq "RUS"){
        Write-Host "Созданы разрешающие правила на firewall для Zabbix" -ForegroundColor Green
    }else{
        Write-Host "Allow firewall rules for Zabbix Agent was created successfully" -ForegroundColor Green
    }
}
catch {
    if ($language -eq "RUS"){
        Write-Host "Разрешающие правила на брандмауэре для заббикса не были созданы" -ForegroundColor Red
        Write-Host "Без них запуск сервиса невозможен" -ForegroundColor Red
        Write-Host "Убедись, что запускаешь скрипт от имени администратора" -ForegroundColor Red
    }else{
        Write-Host "Allow firewall rules for Zabbix Agent was NOT created" -ForegroundColor Red
        Write-Host "Without them running of zabbix agent impossible" -ForegroundColor Red
        Write-Host "Check that run script as admin user" -ForegroundColor Red
    }

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
    
    if ($language -eq "RUS"){
        Write-Host "Zabbix-агент установлен и запущен" -ForegroundColor GREEN
        Write-Host "Проверь, запустилась ли служба Zabbix Agent в Службах Диспетчера задач" -ForegroundColor Green
    }else{
        Write-Host "Zabbix-агент was installed and ran successfully" -ForegroundColor GREEN
        Write-Host "Check that Zabbix service is working in the Task manager" -ForegroundColor Green
    }

    start taskmgr.exe
}
catch {
    if ($language -eq "RUS"){
        Write-Host "Zabbix агент не смог установиться или запуститься." -ForegroundColor RED
        Write-Host "Проверь, что файлы лежат в этой директории:" -ForegroundColor RED
    }else{
        Write-Host "Zabbix-агент was NOT installed and ran" -ForegroundColor RED
        Write-Host "Check files in the directory:" -ForegroundColor RED
    }
    Write-Host $PathZabbixExe -ForegroundColor RED
    Write-Host $PathZabbixConf -ForegroundColor RED
}
[Environment]::NewLine
PAUSE


if ($language -eq "RUS"){
    Write-Host "Ошибки, Логи, Баги, Скрины, Проблемы, Пожелания, Предложения и Любую другую обратную связь"
    Write-Host "отправлять на:"
    Write-Host "denis.tirskikh@tele2.ru"
}else{
    Write-Host "Errors, bugs, logs, screens, photos, reports, problems, suggestions and other feedback"
    Write-Host "send to:"
    Write-Host "denis.tirskikh@tele2.ru"
}
[Environment]::NewLine