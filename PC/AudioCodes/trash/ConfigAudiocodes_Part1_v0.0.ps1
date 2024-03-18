# Version:      0.0
# STATUS:       Протестировано на 0 устройств
# Цель:         первоначальная настройка систем ВКС AudioCodes
# реализация:   
# проблемы:     Белый список брандмауэра практически не создан + проверить запуск SCCM клиента
# Планы:        Протестировать на бОльшем кол-ве устройств
# Last Update:  Добавлены пароли для уз TrueConf и Skype
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
#НЕ РАБОТАЕТ
#Set-Culture ru-RU; 
#Set-WinSystemLocale -SystemLocale ru-RU; 
#Set-WinUILanguageOverride -Language ru-RU; 
#$list = Get-WinUserLanguageList; 
#$list.Add("ru-RU"); 
#Set-WinUserLanguageList $list -Force; 
#Set-WinHomeLocation -GeoId 203;

#Загружает из интернета. НЕ РАБОТАЕТ
#Install-Language -Language ru-ru -CopyToSettings
#Set-SystemPreferredUILanguage -Language ru-ru
#Restart-Computer

# Полная локализация Windows: https://www.outsidethebox.ms/22149/
Install-Language ru-RU -CopyToSettings
Set-WinUILanguageOverride ru-RU
$List = Get-WinUserLanguageList
$List.Add("ru-RU")
Set-WinUserLanguageList $($list[1], $list[0]) -Force
Set-WinHomeLocation -GeoId 203 # https://go.microsoft.com/fwlink/?LinkID=242308
Set-WinSystemLocale ru-RU
#Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True #выдаёт ошибку
# Бонус: переопределить дефолтный метод ввода на английский
# Set-WinDefaultInputMethodOverride -InputTip "0409:00000409"
#Restart-Computer

#Write-Host "Язык системы изменён на руский" -ForegroundColor Green
Write-Host "System language changed to RUSSIAN" -ForegroundColor Green
[Environment]::NewLine
PAUSE

# Язык teams. При первом заходе не срабатывает. Отключаю.
c:\Rigel\x64\scripts\provisioning\scriptlaunch.ps1 ApplyCurrentRegionAndLanguage.ps1
#Write-Host "Язык teams изменён на руский" -ForegroundColor Green
Write-Host "Teams language changed to RUSSIAN" -ForegroundColor Green
[Environment]::NewLine
PAUSE
#

#CHECK. Функция для смены имени машины
#Write-Host "Укажи новое имя компьютера" -ForegroundColor RED
#Write-Host "Новое имя должно начинаться с VCSXX-ConfRoomName" -ForegroundColor RED
#Write-Host "XX           - двухбуквенный код региона из AD" -ForegroundColor RED
#Write-Host "ConfRoomName - имя переговорной комнаты" -ForegroundColor RED
#Write-Host "Длина всего имени компьютера не больше 15 символов" -ForegroundColor RED
Write-Host "Set new computer name" -ForegroundColor RED
Write-Host "New name should match with mask:" -ForegroundColor RED
Write-Host "VCSXX-ConfRoomName" -ForegroundColor RED
Write-Host "where" -ForegroundColor RED
Write-Host "XX           - 2 letter code from AD" -ForegroundColor RED
Write-Host "ConfRoomName - Name of conf room" -ForegroundColor RED
Write-Host "Name length must contains max 15 letters" -ForegroundColor RED
do {
    #$PcNewName = Read-Host "Укажи Новое имя "
    $PcNewName = Read-Host "New Hostname "
} while (
    ($PcNewName -eq '') -or ($PcNewName -notmatch "[v][c][s][A-z][A-z][-].\B" -and $PcNewName.Length -le 15)
)
Rename-Computer -NewName $PcNewName -verbose
[Environment]::NewLine
PAUSE
 

#CHECK. Создаём пользователя TrueConf
#без пароля
#New-LocalUser "TrueConf" -NoPassword -UserMayNotChangePassword -AccountNeverExpires | Set-LocalUser -PasswordNeverExpires $true

#$Password = Read-Host "Enter the new password" -AsSecureString
 $tcpwdunsecur = "TeleTK2#"
 $tcpwdsecur = ConvertTo-SecureString $tcpwdunsecur -AsPlainText -Force
 New-LocalUser "TrueConf" -Password $tcpwdsecur -UserMayNotChangePassword -AccountNeverExpires | Set-LocalUser -PasswordNeverExpires $true
#New-LocalUser "Test" -Password $tcpwdsecur -UserMayNotChangePassword -AccountNeverExpires | Set-LocalUser -PasswordNeverExpires $true

Write-Host "User TrueConf was created successfully with password TeleTK2#" -ForegroundColor Green
[Environment]::NewLine
PAUSE


#Меняем пароль от УЗ Skype
$SkypePwdUnsecur = "TeleTK2#"
$SkypePwdSecur = ConvertTo-SecureString $SkypePwdUnsecur -AsPlainText -Force
Set-LocalUser -Name Skype -Password $SkypePwdSecur

Write-Host "For Skype user set password TeleTK2#" -ForegroundColor Green
Write-Host "All Teams shell settings has been reset" -ForegroundColorRed
[Environment]::NewLine
PAUSE

<#Копирование локальной GPO
#https://woshub.com/backupimport-local-group-policy-settings/
#Export Local GPO policy
#C:\AudioCodes\LGPO.exe /b c:\AudioCodes\GPO

#Import Local GPO policy
#Не сработало. Возможно, потому что запускал PS не от Админа. После перезагрузки не проверял
#Вернуться к этому решению, если натсроек Gpo станет слишком много
try {
    C:\AudioCodes\LGPO.exe /g c:\AudioCodes\GPO
    [Environment]::NewLine
    Write-Host "Local Gpo policy was imported successfully" -ForegroundColor Green
}
catch {
    Write-Host "Local Gpo policy was NOT imported" -ForegroundColor Red
}
[Environment]::NewLine
PAUSE
#>

#Редактирование локальной групповой политики вручную: Доступ к компьютеру из сети + Локальный вход в систему
$loginTrueConf = "TrueConf"
$loginSkype = "Skype"
#$loginTest = "Test"

$tmp = [System.IO.Path]::GetTempFileName()  
secedit.exe /export /cfg $tmp  
$settings = Get-Content -Path $tmp  

$accountTrueConf = New-Object System.Security.Principal.NTAccount($loginTrueConf)  
$accountSkype = New-Object System.Security.Principal.NTAccount($loginSkype)
#$accountTest = New-Object System.Security.Principal.NTAccount($loginTest)

$sidTrueConf = $accountTrueConf.Translate([System.Security.Principal.SecurityIdentifier])
$sidSkype = $accountSkype.Translate([System.Security.Principal.SecurityIdentifier])
#$sidTest = $accountTest.Translate([System.Security.Principal.SecurityIdentifier])

for($i=0; $i -lt $settings.Count; $i++){
   #$settings[$i]

   #Локальный вход в систему
   if($settings[$i] -match "SeInteractiveLogonRight"){
       #Добавляем только учётку ТК
       $settings[$i] += ",*$($sidTrueConf.Value)"
       Write-Host "For user TrueConf was added local interactive logon rights policy" -ForegroundColor Green
       [Environment]::NewLine
   }

   #Доступ к компьютеру из сети. SeRemoteInteractiveLogonRigh - НЕ ПРАВИЛЬНО
   if($settings[$i] -match "SeNetworkLogonRight"){

        $settings[$i] += ",*$($sidTrueConf.Value),*$($sidSkype.Value)"
        Write-Host "For users TrueConf and Skype was added network logon right policy" -ForegroundColor Green
        [Environment]::NewLine

       <#
       $settings[$i] += ",*$($sidTrueConf.Value)"
       Write-Host "For user TrueConf was added remote interactive logon rights" -ForegroundColor Green
       [Environment]::NewLine

       $settings[$i] += ",*$($sidSkype.Value)"
       Write-Host "For user Skype was added remote interactive logon rights" -ForegroundColor Green
       [Environment]::NewLine
       #>
   }

   #Удалённое завершение работы. Не работает
   if($settings[$i] -match "SeRemoteShutdownPrivileget"){

    $settings[$i] += ",*$($sidTrueConf.Value),*$($sidSkype.Value)"
    Write-Host "For users TrueConf and Skype was added Remote Shutdown right policy" -ForegroundColor Green
    [Environment]::NewLine
    }

   #Локальное завершение работы. Не работает
   if($settings[$i] -match "SeShutdownPrivileget"){

    $settings[$i] += ",*$($sidTrueConf.Value)"
    Write-Host "For users TrueConf was added Shutdown right policy" -ForegroundColor Green
    [Environment]::NewLine
    }

}  
$settings | Out-File $tmp  
secedit.exe /configure /db secedit.sdb /cfg $tmp  /areas User_RIGHTS  
Remove-Item -Path $tmp
[Environment]::NewLine
PAUSE

<#Allow local logon. WORK. DOESN'T EDIT!!!
#https://learn.microsoft.com/en-us/answers/questions/349374/how-to-update-security-group-policy-allow-log-on-l
$user = "TrueConf"
#$user = "Test"
$tmp = [System.IO.Path]::GetTempFileName()  
secedit.exe /export /cfg $tmp  
$settings = Get-Content -Path $tmp  
$account = New-Object System.Security.Principal.NTAccount($user)  
$sid = $account.Translate([System.Security.Principal.SecurityIdentifier])  
for($i=0;$i -lt $settings.Count;$i++){
    #$settings[$i]

    if($settings[$i] -match "SeInteractiveLogonRight"){  
        $settings[$i] += ",*$($sid.Value)"  
    }
}  
$settings | Out-File $tmp  
secedit.exe /configure /db secedit.sdb /cfg $tmp  /areas User_RIGHTS  
Remove-Item -Path $tmp

[Environment]::NewLine
Write-Host "For user TrueConf was added local logon rights" -ForegroundColor Green
[Environment]::NewLine
PAUSE
#>



#CHECK. Добавим в Пользователи удалённого рабочего стола
#Возможность подключения по RDP без пароля. 0 - allow; 1 - deny
Reg.Exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 0 /f
Write-Host "Allowed Remote Logon for users without password" -ForegroundColor Green
[Environment]::NewLine

<#
try {    
    Add-LocalGroupMember -Group 'Remote Desktop Users' -Member Test –Verbose
}
catch {    
    'Test was added to Remote Desktop Users'  
}
try {    
    #Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member $NewLocalAdminLogin –Verbose  
    #Add-LocalGroupMember -Group 'Remote Desktop Users' -Member $NewLocalAdminLogin –Verbose
    Add-LocalGroupMember -Group 'Remote Desktop Users' -Member Admin –Verbose
    Write-Host "Admin was added to Remote Desktop Users" -ForegroundColor Green
    [Environment]::NewLine
}
catch {
    #"$NewLocalAdminLogin уже добавлен в пользователи удалённого рабочего стола"
    #"$NewLocalAdminLogin was added to Remote Desktop Users"
    Write-Host "Admin was NOT added to Remote Desktop Users" -ForegroundColor Red
}#>
try {    
    #Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member Skype –Verbose
    Add-LocalGroupMember -Group 'Remote Desktop Users' -Member Skype –Verbose
    Write-Host "Skype was added to Remote Desktop Users" -ForegroundColor Green
    [Environment]::NewLine
}
catch {    
    #"Skype уже добавлен в пользователи удалённого рабочего стола"  
    Write-Host "Skype was NOT added to Remote Desktop Users" -ForegroundColor Red 
}
try {    
    #Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member TrueConf –Verbose  
    Add-LocalGroupMember -Group 'Remote Desktop Users' -Member TrueConf –Verbose
    Write-Host "TrueConf was added to Remote Desktop Users" -ForegroundColor Green
    [Environment]::NewLine
}
catch {    
    #"TrueConf уже добавлен в пользователи удалённого рабочего стола"
    Write-Host "TrueConf was NOT added to Remote Desktop Users" -ForegroundColor Red
}
[Environment]::NewLine
PAUSE

#CANCEL. Отключаем спящий режим:
#powercfg -x standby-timeout-ac 0

#CANCEL. Отключение блокировки экрана
#New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" -PropertyType "DWord" -Value "0"


#Автологин 
do {
    #$UserAutoLogin = Read-Host "Укажи имя учётной записи Skype или TrueConf, в которую настроить автологин "
    $UserAutoLogin = Read-Host "Write Skype or TrueConf for autologon setting "
    $UserAutoLogin
} while (    
    ($UserAutoLogin -ne "Skype") -and ($UserAutoLogin -ne "TrueConf")
)
#$PasswordUser = Read-Host "Input password for user "
$PasswordUser = "TeleTK2#"

#Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -PropertyType "DWord" -Value "0"
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'

#Всегда остаётся таким. Не меняем:
#Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String

#Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "Test" -type String
 Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$UserAutoLogin" -type String

#если для любой учётки, какой бы она ни была, есть пароль:
 Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$PasswordUser" -type String

<# Случай, когда для учётки Skype нет пароля, а для TrueConf есть
if ($UserAutoLogin -eq "Skype"){
    Remove-ItemProperty $RegistryPath 'DefaultPassword' -force
}
if ($UserAutoLogin -eq "TrueConf"){
    #New-ItemProperty $RegistryPath 'DefaultPassword' -Value "$tcpwdunsecur" -type String
    #CHECK. Будет ли работать SET, если ранее не была создана запись?
    Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$tcpwdunsecur" -type String
}
#>

#Write-Host "Для пользователя $UserAutoLogin установлен Автологин в систему без пароля" -ForegroundColor Green
Write-Host "For user $UserAutoLogin set autologon in the system with password" -ForegroundColor Green
[Environment]::NewLine
PAUSE



#####  Брандмауэр  #####
#Меняем тип сетевого подключения:
#Get-NetConnectionProfile #не проверял
 Set-NetConnectionProfile -NetworkCategory Private -Verbose
#Write-Host "Выбран ЧАСТНЫЙ тип сети для брандмауэра" -ForegroundColor Green
 Write-Host "Set private network type for firewall" -ForegroundColor Green
#[Environment]::NewLine
#PAUSE

#CHECK. разрешить ICMP (ping). проверить, может быть, уже включен
Enable-NetFirewallRule -Name FPS-ICMP4-ERQ-In
#Write-Host "Включена доступность устройства по ICMP" -ForegroundColor Green
Write-Host "ICMP enabled" -ForegroundColor Green
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

#Write-Host "открыты порты на firewall для SCCM и Касперского" -ForegroundColor Green
Write-Host "Opened ports for kasper and SCCM" -ForegroundColor Green
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


#Открытие порта 5985 и доступ по WMI и CIM
try {
    Enable-PSRemoting -SkipNetworkProfileCheck -Force -verbose -ErrorAction Stop -ErrorVariable ErrWinRM
    Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -RemoteAddress Any
    Set-Service WinRM -startuptype Automatic -Verbose
    Write-Host "WinRM was enabled successfully" -ForegroundColor Green
}
catch {
    Write-Host "WinRM was NOT enabled" -ForegroundColor Red
    Write-Host $ErrWinRM -ForegroundColor Red
}
[Environment]::NewLine
#PAUSE

#CHECK.Проверить ещё эту штуку, если по-прежнему будут проблемы с авторизацией команд:
#Write-Host "Проверь, заработал ли WinRM, перед тем, как продолжать скрипт и включать дополнительную опцию для этого" -ForegroundColor RED
#PAUSE
#Set-Item wsman:\localhost\Client\TrustedHosts -value 10.57.179.121
Set-Item wsman:\localhost\Client\TrustedHosts -value * -Force -verbose
[Environment]::NewLine 
PAUSE


#CHECK.Включение протокола удаленного рабочего стола:
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
#Write-Host "Удалённый рабочий стол включен" -ForegroundColor Green
Write-Host "Remote Desktop was enabled" -ForegroundColor Green
[Environment]::NewLine 
PAUSE

#CANCEL.Выключаем UAC. А надо ли его выключать?
#try {    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system\' -name "LocalAccountTokenFilterPolicy" -PropertyType DWORD -Value 1} 
#catch {'UAC уже выключен'  }
#[Environment]::NewLine


#CHECK. Cert for skype
$params1 = @{
    #FilePath = 'C:\Users\Xyz\Desktop\BackupCert.cer'
    #FilePath = 'Tele2RootCA.cer'
     FilePath = 'C:\AudioCodes\Tele2RootCA.cer'
    #CertStoreLocation = 'Cert:\CurrentUser\Root'
    #CertStoreLocation = 'Cert:\LocalMachine\Root'
     CertStoreLocation = 'Cert:\LocalMachine\Root'
}
$params2 = @{
    #FilePath = 'C:\Users\Xyz\Desktop\BackupCert.cer'
    #FilePath = 'Tele2EnterpriseCA.cer'
     FilePath = 'C:\AudioCodes\Tele2EnterpriseCA.cer'
    #CertStoreLocation = 'Cert:\CurrentUser\Root'
    #CertStoreLocation = 'Cert:\LocalMachine\Root'
     CertStoreLocation = 'Cert:\LocalMachine\Root'
}
Import-Certificate @params1 -Verbose
Import-Certificate @params2 -Verbose
#Write-Host "Сертификаты для работы skype импортированы" -ForegroundColor Green
Write-Host "Skype certificates was imported" -ForegroundColor Green
[Environment]::NewLine 
PAUSE #sleep 180



#####  Установка ПО  #####
#CHECK. SCCM
$PathSccmSetupExe = "C:\AudioCodes\SCCMclient\CCMSetup.exe"
#Клиент лежит тут: \\t2ru\folders\Software\SCCMClient
#Его нужно скопировать на устройство и в командной строке перейти в папку, где он лежит: 
#cd c:\SCCMclient
#После чего выполнить команду:
#CCMSetup.exe /mp:T2RU-SCCM-01.corp.tele2.ru SMSSITECODE=T2M FSP=T2RU-SCCM-01
#& ./CCMSetup.exe /mp:T2RU-SCCM-01.corp.tele2.ru SMSSITECODE=T2M FSP=T2RU-SCCM-01
try {
    Start-Process -FilePath $PathSccmSetupExe -ArgumentList "/mp:T2RU-SCCM-01.corp.tele2.ru SMSSITECODE=T2M FSP=T2RU-SCCM-01" -Verbose -ErrorVariable ErrSccmInstall -ErrorAction Stop
    #Write-Host "SCCM-клиент установлен и запущен" -ForegroundColor GREEN
    Write-Host "SCCM-client was installed and ran" -ForegroundColor GREEN
    Write-Host "check SCCM" -ForegroundColor green
}
catch {
    #Write-Host "SCCM-клиент не смог установиться или запуститься." -ForegroundColor RED
    #Write-Host "Проверь, что файлы лежат в этой директории:" -ForegroundColor RED
    Write-Host "SCCM-client was NOT installed and ran" -ForegroundColor RED
    Write-Host "Check files in the directory:" -ForegroundColor RED
    Write-Host $PathSccmSetupExe -ForegroundColor RED
}
PAUSE
[Environment]::NewLine 


#CHECK. Kaspersky. Агент администрирования
#https://wiki.tele2.ru/pages/viewpage.action?pageId=44720938
#https://wiki.tele2.ru/pages/viewpage.action?pageId=44720978
try {
    #1.В CMD от имени администратора перейти в папку с Kaspersky Network Agent.msi (например NetAgent_10.5.1781(4)\exec)
    #2. выполнить в CMD от имени администратора рабочей станции
    #Для установки приложения в тихом режиме используйте ключи /s и /qn
    #"Kaspersky Network Agent.msi"
    msiexec.exe /i "C:\AudioCodes\Kaspersky\NetAgent_14.2.0.26967\exec\Kaspersky Network Agent.msi" /qn /l*vx c:\windows\temp\nag_inst.log SERVERADDRESS="t2ru-ksc-01.corp.tele2.ru" DONT_USE_ANSWER_FILE=1 PRIVACYPOLICY=1 EULA=1 CERTSELECTION=GetOnFirstConnection LAUNCHPROGRAM=1
    #не тихая установка не работает:
    #msiexec.exe /i "C:\AudioCodes\Kaspersky\NetAgent_14.2.0.26967\exec\Kaspersky Network Agent.msi" /l*vx c:\windows\temp\nag_inst.log SERVERADDRESS="t2ru-ksc-01.corp.tele2.ru" DONT_USE_ANSWER_FILE=1 PRIVACYPOLICY=1 EULA=1 CERTSELECTION=GetOnFirstConnection LAUNCHPROGRAM=1
    Write-Host "Command for install Kaspersky Agent was run" -ForegroundColor Green
    [Environment]::NewLine
    #PAUSE

    #3.По желанию, проверить лог C:\Windows\Temp\nag_inst.log должен заканчиваться нулем
    Write-Host "You can see log" -ForegroundColor Green
    #D:\Logs\ping.txt
    C:\Windows\Temp\nag_inst.log
    [Environment]::NewLine
    #PAUSE

    #4. Проверить утилитой что связь появилась - отправить пакет пульс
    $PathKasperPuls = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\klrbtagt.exe"

    Write-Host "Check puls connection" -ForegroundColor Green
    Start-Process -FilePath $PathKasperPuls
    [Environment]::NewLine
    #PAUSE

    #!! Ключ тихой установки для НОУТБУКА находящемся за пределами офисной сети - не использовать при локальном подключении!
    #msiexec.exe /i "Kaspersky Network Agent.msi" /qn /l*vx c:\windows\temp\nag_inst.log SERVERADDRESS="t2ru-ksc-01.corp.tele2.ru" DONT_USE_ANSWER_FILE=1 PRIVACYPOLICY=1 EULA=1 CERTSELECTION=GetOnFirstConnection LAUNCHPROGRAM=1 GATEWAYMODE=2 GATEWAYADDRESS=kscgw01.tele2.ru

    Write-Host "Kaspersky Agent was install successfully" -ForegroundColor Green
    Write-Host "KES will install after some time automatically" -ForegroundColor Green
    #Write-Host "Now you can install KES manually from:" -ForegroundColor Green
    #Write-Host "C:\AudioCodes\Kaspersky\KES_12.2.0.462" -ForegroundColor Green
}
catch {
    Write-Host "Kaspersky was NOT installed" -ForegroundColor RED
    Write-Host "Check log. Open:" -ForegroundColor RED
    Write-Host "C:\Windows\Temp\nag_inst.log" -ForegroundColor RED

}
[Environment]::NewLine
PAUSE

<#DISABLE. Kaspersky. Endpoint Security
#Установится сам через какое-то время после установки Агента
#https://wiki.tele2.ru/pages/viewpage.action?pageId=44720938
#https://wiki.tele2.ru/pages/viewpage.action?pageId=1121052
#https://support.kaspersky.ru/kes12/123468
try {
    #C:\AudioCodes\Kaspersky\KES_12.2.0.462\setup.exe

    #setup_kes.exe /pEULA=1 /pPRIVACYPOLICY=1 [/pKSN=1|0] [/pALLOWREBOOT=1] [/pSKIPPRODUCTCHECK=1] [/pSKIPPRODUCTUNINSTALL=1] [/pKLLOGIN=<user name> /pKLPASSWD=<password> /pKLPASSWDAREA=<password scope>] [/pENABLETRACES=1|0 /pTRACESLEVEL=<tracing scope>] [/s]

    #setup_kes.exe /pEULA=1 /pPRIVACYPOLICY=1 /pKSN=1 /pALLOWREBOOT=1
    #setup_kes.exe /pEULA=1 /pPRIVACYPOLICY=1 /pKSN=1 /pENABLETRACES=1 /pTRACESLEVEL=600 /s

    #C:\AudioCodes\Kaspersky\KES_12.2.0.462\setup_kes.exe /pEULA=1 /pPRIVACYPOLICY=1 [/pKSN=1|0] [/pALLOWREBOOT=1] [/pSKIPPRODUCTCHECK=1] [/pSKIPPRODUCTUNINSTALL=1] [/pKLLOGIN=<user name> /pKLPASSWD=<password> /pKLPASSWDAREA=<password scope>] [/pENABLETRACES=1|0 /pTRACESLEVEL=<tracing scope>] [/s]


    #msiexec /i <distribution kit name> EULA=1 PRIVACYPOLICY=1 [KSN=1|0] [ALLOWREBOOT=1] [SKIPPRODUCTCHECK=1] [KLLOGIN=<user name> KLPASSWD=<password> KLPASSWDAREA=<password scope>] [ENABLETRACES=1|0 TRACESLEVEL=<tracing scope>] [/qn]

    #msiexec /i kes_win.msi EULA=1 PRIVACYPOLICY=1 KSN=1 KLLOGIN=Admin KLPASSWD=Password KLPASSWDAREA=EXIT;DISPOLICY;UNINST /qn

    #msiexec /i "C:\AudioCodes\Kaspersky\KES_12.2.0.462\exec\kes_win.msi" EULA=1 PRIVACYPOLICY=1 [KSN=1|0] [ALLOWREBOOT=1|0] [SKIPPRODUCTCHECK=1|0] [SKIPPRODUCTUNINSTALL=1|0] [KLLOGIN=<имя пользователя> KLPASSWD=<пароль> KLPASSWDAREA=<область действия пароля>] [ENABLETRACES=1|0 TRACESLEVEL=<уровень трассировки>] [/qn]

}
catch {
    Write-Host "Kaspersky Endpoint Security was NOT installed" -ForegroundColor RED
    Write-Host "Check log. Open:" -ForegroundColor RED
    Write-Host "C:\Windows\Temp\???????????.log" -ForegroundColor RED
    [Environment]::NewLine
}
#>


<#TrueConf Client
try {
}
catch {
}
#>


<#TrueConf Room
try {
}
catch {
}
#>



#Get-NetIPAddress | Format-Table | Select-Object -Property * | Select IPAddress
#Get-NetAdapter | Where-Object status -eq ‘up’ | Get-NetIPAddress -ea 0 | Format-Table ipaddress, AddressFamily
#Get-NetAdapter | Get-NetIpAddress
Get-WmiObject win32_networkadapterconfiguration | Select-Object -Property @{
    Name = 'IPAddress'
    Expression = {($PSItem.IPAddress[0])}
},MacAddress | Where IPAddress -NE $null
#Write-Host "На основании mac-адреса сверху заведи обращение на резервацию адреса на DHCP в том регионе, где планируешь устанавливать устройство" -ForegroundColor Red
Write-Host "Use this information to reserve ip-address on DHCP in target region" -ForegroundColor Red
[Environment]::NewLine
Pause



#Write-Host "Далее можешь перезагрузить компьютер" -ForegroundColor Green
#Write-Host "После чего можно будет приступить к настройке оболочек Teams и Trueconf Room" -ForegroundColor Green
Write-Host "After reboot RDP will available" -ForegroundColor Green
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



#CHECK. Локальный администратор
$NewLocalAdminLogin = "AdminTele25"
<#Создание новой отдельной УЗ администратора
#$AdminPassword = Read-Host 'Задай пароль локального администратора: Tele2#adm' –AsSecureString
 $AdminPassword = ConvertTo-SecureString "Tele25s@pport" -AsPlainText -Force
#Set-LocalUser -Name "Администратор" -Password $AdminPassword -Verbose
New-LocalUser $NewLocalAdminLogin -Password $AdminPassword -FullName $NewLocalAdminLogin -Description "T2 local admin" -Verbose
Write-Verbose "$NewLocalAdmin local user crated"
Add-LocalGroupMember -Group "Administrators" -Member "$NewLocalAdminLogin"
Write-Verbose "$NewLocalAdminLogin added to the local administrator group"
#>
Rename-LocalUser -Name "Admin" -NewName $NewLocalAdminLogin -Verbose
Disable-LocalUser -Name "Administrator" -Verbose
Write-Host "Admin user renamed to $NewLocalAdminLogin" -ForegroundColor Green
Write-Host "Administrator user was disabled" -ForegroundColor Green
[Environment]::NewLine
PAUSE



#CHECK.
Restart-Computer -Confirm -Force







<#Про проверку списка регионов в заявке bro - просто жалко удалять...
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

<#
"HostMetadata=Region=Нижний Новгород:UserLogin=roman.novotorov:RoomName=Бежин Луг:IsVcs=true:VcsType=Lenovo"
    (Get-Content -Path $PathZabbixConf -ErrorVariable ErrGetZabbixConfig -ErrorAction Stop) `
    -replace '#Server=WillChangeFromScript', "Server=$ZabbixServer"`
    -replace '#ServerActive=WillChangeFromScript', "ServerActive=$ZabbixServer"`
    -replace '#Hostname=WillChangeFromScript', "Hostname=$PcNewName"`
    -replace '#HostMetadata=WillChangeFromScript', "HostMetadata=Region=$Region:UserLogin=$UserLogin:RoomName=$RoomName:IsVcs=true:VcsType=$VcsType" | 
    Out-File $PathZabbixConf #zabbix_agentd.conf
#>



<#CHECK. ZABBIX
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
#>
