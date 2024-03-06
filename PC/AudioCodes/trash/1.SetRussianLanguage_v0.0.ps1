# Version:      0.0
# STATUS:       Не протестировано
# Цель:         первоначальная настройка систем ВКС AudioCodes
# реализация:   
# проблемы:     Белый список брандмауэра
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


#####  Смена языка  #####
#CHECK. язык системы
Set-Culture ru-RU; 
Set-WinSystemLocale -SystemLocale ru-RU; 
Set-WinUILanguageOverride -Language ru-RU; 
$list = Get-WinUserLanguageList; 
$list.Add("ru-RU"); 
Set-WinUserLanguageList $list -Force; 
Set-WinHomeLocation -GeoId 203;
#Write-Host "Язык системы изменён на руский" -ForegroundColor Green
Write-Host "System language changed to RUSSIAN" -ForegroundColor Green
[Environment]::NewLine
PAUSE

#CHECK. язык teams
c:\Rigel\x64\scripts\provisioning\scriptlaunch.ps1 ApplyCurrentRegionAndLanguage.ps1
#Write-Host "Язык teams изменён на руский" -ForegroundColor Green
Write-Host "Teams language changed to RUSSIAN" -ForegroundColor Green
[Environment]::NewLine
PAUSE


#CHECK. Автологин без пароля
$UserAutoLogin = "Admin"
#Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -PropertyType "DWord" -Value "0"
 $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
#Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String
 Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$UserAutoLogin" -type String
#Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "" -type String
#Write-Host "Для пользователя $UserAutoLogin установлен Автолог в систему без пароля" -ForegroundColor Green
Write-Host "For user $UserAutoLogin set autologon in the system without password" -ForegroundColor Green
[Environment]::NewLine
PAUSE



#####  Брандмауэр  #####
#Меняем тип сетевого подключения:
#Get-NetConnectionProfile
#Get-NetConnectionProfile | 
 Set-NetConnectionProfile -NetworkCategory Private -Verbose
 Write-Host "Выбран ЧАСТНЫЙ тип сети для брандмауэра" -ForegroundColor Green
 [Environment]::NewLine
 PAUSE

#CHECK. разрешить ICMP (ping). проверить, может быть, уже включен
Write-Host "Проверь, доступно ли устройство по ICMP, перед тем, как включать его" -ForegroundColor RED
PAUSE
Enable-NetFirewallRule -Name FPS-ICMP4-ERQ-In
Write-Host "Включена доступность устройства по ICMP" -ForegroundColor Green
[Environment]::NewLine
PAUSE
#Необязательно:
#Enable-NetFirewallRule -DisplayGroup "Remote Desktop"


# Set-NetFirewallProfile -Enabled False #DISABLE

#SCCM
New-NetFirewallRule -DisplayName 'SCCM-01-IN' -Profile @('Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('80', '443', '10123') -Verbose
New-NetFirewallRule -DisplayName 'SUP-01-IN' -Profile @('Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('80', '443', '8530', '8531') -Verbose

#Касперский наверное, сам при установке откроет нужные ему порты
#New-NetFirewallRule -DisplayName 'KASPER-01-IN' -Profile @('Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('8060', '8061', '13000', '14000') -Verbose
#New-NetFirewallRule -DisplayName 'KASPER-02-IN' -Profile @('Private') -Direction Inbound -Action Allow-Protocol UDP -LocalPort @('13000', '15000', '15111', '17000', '19170') -Verbose

Write-Host "открыты порты на firewall для SCCM и Касперского" -ForegroundColor Green
#TODO. FireWall позволяет ходить только по белому списку(сервера Скайпа, Труконф, SCCM, Касперский, Windows Update) 


#Отображение созданных правил
#Write-Host "Созданные правила на Firewall:" -ForegroundColor Green
#Список активных правил для входящего трафика:
#Get-NetFirewallRule | where {($_.enabled -eq $True) -and ($_.Direction -eq "Inbound")} | ft
#вывести список блокирующих исходящих правил:
#Get-NetFirewallRule -Action Block -Enabled True -Direction Outbound

<#вывести всю информацию о разрешенных входящих (исходящих) подключениях с отображением номеров портов:
Get-NetFirewallRule -Action Allow -Enabled True -Direction Inbound |
Format-Table -Property Name,
@{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}},
@{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
@{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}},
@{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}},
Enabled,Profile,Direction,Action
#>
<#вывести всю информацию о разрешенных исходящих подключениях с отображением номеров портов:
Get-NetFirewallRule -Action Allow -Enabled True -Direction Outbound |
Format-Table -Property Name,
@{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}},
@{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
@{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}},
@{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}},
Enabled,Profile,Direction,Action
#>
[Environment]::NewLine
PAUSE


#Открытием порт 5985 и доступ по WMI и CIM
#Enable-PSRemoting
 Enable-PSRemoting -Force -verbose
 [Environment]::NewLine
#PAUSE

#Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any
 Set-Service WinRM -startuptype Automatic -Verbose
[Environment]::NewLine 

#CHECK.Проверить ещё эту штуку, если по-прежнему будут проблемы с авторизацией команд:
Write-Host "Проверь, заработал ли WinRM, перед тем, как продолжать скрипт и включать дополнительную опцию для этого" -ForegroundColor RED
PAUSE
#Set-Item wsman:\localhost\Client\TrustedHosts -value 10.57.179.121
Set-Item wsman:\localhost\Client\TrustedHosts -value * -Force -verbose
[Environment]::NewLine 
PAUSE


#CHECK.Включение протокола удаленного рабочего стола:
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Write-Host "Удалённый рабочий стол включен" -ForegroundColor Green
[Environment]::NewLine 
PAUSE

#CANCEL.Выключаем UAC. А надо ли его выключать?
#try {    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system\' -name "LocalAccountTokenFilterPolicy" -PropertyType DWORD -Value 1} 
#catch {'UAC уже выключен'  }
#[Environment]::NewLine


#CHECK. Cert for skype
$params1 = @{
    #FilePath = 'C:\Users\Xyz\Desktop\BackupCert.cer'
     FilePath = 'Tele2RootCA.cer'
    #CertStoreLocation = 'Cert:\CurrentUser\Root'
    #CertStoreLocation = 'Cert:\LocalMachine\Root'
     CertStoreLocation = 'Cert:\LocalMachine\Root'
}
$params2 = @{
    #FilePath = 'C:\Users\Xyz\Desktop\BackupCert.cer'
     FilePath = 'Tele2EnterpriseCA.cer'
    #CertStoreLocation = 'Cert:\CurrentUser\Root'
    #CertStoreLocation = 'Cert:\LocalMachine\Root'
     CertStoreLocation = 'Cert:\LocalMachine\Root'
}
Import-Certificate @params1 -Verbose
Import-Certificate @params2 -Verbose
Write-Host "Сертификаты для работы skype импортированы" -ForegroundColor Green
[Environment]::NewLine 
PAUSE #sleep 180



#####  Установка ПО  #####
#CHECK. ZABBIX
[Environment]::NewLine
Write-Host "0. Zabbix Agent НЕ УСТАНОВЛЕН"
Write-Host "1. Zabbix Agent уже был установлен ранее отдельно"
[Environment]::NewLine
$ZabbixAgentInstall = Read-Host "Устанавливал ты уже отдельно Zabbix Agent? Укажи НОМЕР 0 или 1 "
switch($ZabbixAgentInstall){
        0{$isZabbixInstall = $false}
        1{$isZabbixInstall = $true}
 Default {$isZabbixInstall = $false}
}
$isZabbixInstall

if (!$isZabbixInstall){
    # 1. Конфигурируем Zabbix conf file
    Write-Host "От корректности введённых данных далее зависит правильность заведения обращений в bpm в будущем при инцидентах" -ForegroundColor RED
    [Environment]::NewLine 


    Write-Host "Далее нужно будет указать регион на русском языке, как в выпадающем списке в заявке:" -ForegroundColor RED
    Write-Host "Helpdesk IT - System Monitoring.ВКС" -ForegroundColor RED
    <#
    Write-Host "Далее нужно будет указать регион на русском языке, как в выпадающем списке в заявке System Monitoring.ВКС" -ForegroundColor RED
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
    Default {$ZabbixServer = "t2ru-rmon-01.corp.tele2.ru"} #УТОЧНИТЬ, ИСПРАВИТЬ!!!
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

        <#"HostMetadata=Region=Нижний Новгород:UserLogin=roman.novotorov:RoomName=Бежин Луг:IsVcs=true:VcsType=Lenovo"
        (Get-Content -Path $PathZabbixConf -ErrorVariable ErrGetZabbixConfig -ErrorAction Stop) `
        -replace '#Server=WillChangeFromScript', "Server=$ZabbixServer"`
        -replace '#ServerActive=WillChangeFromScript', "ServerActive=$ZabbixServer"`
        -replace '#Hostname=WillChangeFromScript', "Hostname=$PcNewName"`
        -replace '#HostMetadata=WillChangeFromScript', "HostMetadata=Region=$Region:UserLogin=$UserLogin:RoomName=$RoomName:IsVcs=true:VcsType=$VcsType" | 
        Out-File $PathZabbixConf #zabbix_agentd.conf
        #>

        (Get-Content -Path $PathZabbixConf -ErrorVariable ErrGetZabbixConfig -ErrorAction Stop).replace('#Server=WillChangeFromScript', "Server=$ZabbixServer").replace('#ServerActive=WillChangeFromScript', "ServerActive=$ZabbixServer").replace('#Hostname=WillChangeFromScript', "Hostname=$PcNewName").replace('#HostMetadata=WillChangeFromScript', "HostMetadata=Region=$Region;UserLogin=$UserLogin;RoomName=$RoomName;IsVcs=true;VcsType=$VcsType") | 
        Out-File $PathZabbixConf -Encoding "UTF8"

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
    New-NetFirewallRule -DisplayName "Разрешить приложение Zabbix Agent" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Program $PathZabbixExe -Verbose
    New-NetFirewallRule -DisplayName "Разрешить порт 10050 для Zabbix" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 10050 -Verbose
    Write-Host "Созданы разрешающие правила на firewall для Zabbix" -ForegroundColor Green
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
    }
    catch {
        Write-Host "Zabbix агент не смог установиться или запуститься." -ForegroundColor RED
        Write-Host "Проверь, что файлы лежат в этой директории:" -ForegroundColor RED
        Write-Host $PathZabbixExe -ForegroundColor RED
        Write-Host $PathZabbixConf -ForegroundColor RED
    }
    [Environment]::NewLine
    PAUSE
}





#CHECK. SCCM
$PathSccmSetupExe = "C:\AudioCodes\SCCNclient\CCMSetup.exe"
#Клиент лежит тут: \\t2ru\folders\Software\SCCMClient
#Его нужно скопировать на устройство и в командной строке перейти в папку, где он лежит: 
#cd c:\SCCMclient
#После чего выполнить команду:
#CCMSetup.exe /mp:T2RU-SCCM-01.corp.tele2.ru SMSSITECODE=T2M FSP=T2RU-SCCM-01
#& ./CCMSetup.exe /mp:T2RU-SCCM-01.corp.tele2.ru SMSSITECODE=T2M FSP=T2RU-SCCM-01
try {
    Start-Process -FilePath $PathSccmSetupExe -ArgumentList "/mp:T2RU-SCCM-01.corp.tele2.ru SMSSITECODE=T2M FSP=T2RU-SCCM-01" -Verbose -ErrorVariable ErrSccmInstall -ErrorAction Stop
    Write-Host "SCCM-клиент установлен и запущен" -ForegroundColor GREEN
}
catch {
    Write-Host "SCCM-клиент не смог установиться или запуститься." -ForegroundColor RED
    Write-Host "Проверь, что файлы лежат в этой директории:" -ForegroundColor RED
    Write-Host $PathSccmSetupExe -ForegroundColor RED
}
Write-Host "Проверь установку SCCM" -ForegroundColor RED
PAUSE
[Environment]::NewLine 

#Kaspersky
#Предполагаю, что будет установлен вручную


#Get-NetIPAddress | Format-Table | Select-Object -Property * | Select IPAddress
#Get-NetAdapter | Where-Object status -eq ‘up’ | Get-NetIPAddress -ea 0 | Format-Table ipaddress, AddressFamily
#Get-NetAdapter | Get-NetIpAddress
Get-WmiObject win32_networkadapterconfiguration | Select-Object -Property @{
    Name = 'IPAddress'
    Expression = {($PSItem.IPAddress[0])}
},MacAddress | Where IPAddress -NE $null
Write-Host "На основании mac-адреса сверху заведи обращение на резервацию адреса на DHCP в том регионе, где планируешь устанавливать устройство" -ForegroundColor Red
[Environment]::NewLine
Pause



Write-Host "Далее можешь перезагрузить компьютер" -ForegroundColor Green
Write-Host "После чего можно будет приступить к настройке оболочек Teams и Trueconf Room" -ForegroundColor Green
[Environment]::NewLine


#CHECK. Disable local admin
Disable-LocalUser -Name "Администратор" -Verbose
Pause
[Environment]::NewLine


Write-Host "Ошибки, Логи, Баги, Скрины, Проблемы, Пожелания, Предложения и Любую другую обратную связь"
Write-Host "отправлять на:"
Write-Host "denis.tirskikh@tele2.ru"
[Environment]::NewLine

#CHECK. проверить, дойдёт ли вообще до этой строчки.
#не вижу смысла сразу перезагружаться. итак когда-нибудь выключат и включат
#Restart-Computer -Confirm #-Force
