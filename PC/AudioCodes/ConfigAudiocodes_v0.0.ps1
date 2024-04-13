# Version:      0.0
# STATUS:       Протестировано на 0 устройств
# Цель:         первоначальная настройка систем ВКС AudioCodes
# реализация:   https://wiki.tele2.ru/pages/viewpage.action?pageId=315167075
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

#Общие переменные:
$loginTrueConf = "TrueConf"
$loginSkype = "Skype"
#$loginTest = "Test"

$TcClientVersion = "8.4.0.1925" #"8.3.2"
$tcRoomVersion = "4.3.0.1515"   #"4.3.0.1341"
$ChromeVersion = "ChromeStandaloneSetup64"
#$KasperAgentVersion = "14.2.0.26967"
$KasperAgentVersion = "14.2.0.26967(3)"
[Environment]::NewLine


#Логирование
$DateStart = Get-Date -Format "dd.MM.yyyy_HH.mm.ss"
$LogFile = "C:\AudioCodes\Logs\part1_$DateStart.log"
Start-Transcript -Path $LogFile -Append

Write-Host "the script logging Was started to the file:" -ForegroundColor Green
Write-Host $LogFile -ForegroundColor Green
[Environment]::NewLine
#PAUSE



#Смена часового пояса
$ZonesArray = @('-1','0','+1','+2','+3','+4','+5','+6','+7','+8','+9')
#Get-TimeZone -ListAvailable
do {
    [Environment]::NewLine
    Write-Host "-1. Kaliningrad"
    Write-Host " 0. Moscow (Russian Standard Time)"
    Write-Host "+1. Ulyanovsk (Saratov Standard Time)"
    Write-Host "+2. Ural"
    Write-Host "+3. Omsk"
    Write-Host "+4. Novosibirsk"
    Write-Host "+5. Irkutsk, UU"
    Write-Host "+6. Chita, Yakutsk"
    Write-Host "+7. Vladivostok, Khabarovsk, Birobidzhan"
    Write-Host "+8. Sakhalin, Magadan"
    Write-Host "+9. Kamchatka"
    [Environment]::NewLine

    $TimeZoneChoice = Read-Host "Choose TimeZone. Input NUMBER with PLUS or MINUS from -1 to +9 "
} 
until (
    $ZonesArray -contains $TimeZoneChoice
    #$ZonesArray -match $TimeZoneChoice #рабочее  но пишет какую непонятную ошибку
    #($TimeZoneChoice -eq "-1") -or ($TimeZoneChoice -eq "0") -or ($TimeZoneChoice -eq "+1")
    #($TimeZoneChoice -eq '') -or 
)
switch($TimeZoneChoice){
        -1{$TimeZone = "Kaliningrad Standard Time"}
         0{$TimeZone = "Russian Standard Time"}
        +1{$TimeZone = "Saratov Standard Time"}
        +2{$TimeZone = "Ekaterinburg Standard Time"}
        +3{$TimeZone = "Omsk Standard Time"}
        +4{$TimeZone = "Tomsk Standard Time"}
        +5{$TimeZone = "Ulaanbaatar Standard Time"}
        +6{$TimeZone = "Yakutsk Standard Time"}
        +7{$TimeZone = "Vladivostok Standard Time"}
        +8{$TimeZone = "Sakhalin Standard Time"}
        +9{$TimeZone = "Kamchatka Standard Time"}
 Default {$TimeZone = "Russian Standard Time"}
}
[Environment]::NewLine
$TimeZone
[Environment]::NewLine
#PAUSE

#Синхронизация времени
try{
    #net time \\server_name_to_synch_with /set
    #net time ntp1.tele2.ru /set    net time ntp2.tele2.ru /set    net time ntp3.tele2.ru /set
    try {
        net start w32time
    }
    catch {
        Write-Host "Windows Time service run" -ForegroundColor Green
    }
    [Environment]::NewLine

    #https://stackoverflow.com/questions/17507339/setting-ntp-server-on-windows-machine-using-powershell
    #https://ab57.ru/cmdlist/w32tm.html
    #w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"
    w32tm /config /syncfromflags:manual /manualpeerlist:"ntp1.tele2.ru ntp2.tele2.ru ntp3.tele2.ru" /update
    #w32tm /resync [/nowait] [/rediscover] [/soft] [/computer: <компьютер>]

    Write-Host "Time setting was syncronized with ntp servers successfully" -ForegroundColor Green
}catch{
    Write-Host "Time setting was not syncronized with ntp servers" -ForegroundColor Red
}
#

try {
    #Set-TimeZone -Id "UTC"
    Set-TimeZone -Id $TimeZone -Verbose -ErrorAction Stop -ErrorVariable ErrChangeTimeZone
    Write-Host "TimeZone was changed successfully to" -ForegroundColor Green
    Write-Host $TimeZone -ForegroundColor Green
}
catch {
    Write-Host "TimeZone was NOT changed" -ForegroundColor Red
    Write-Host $ErrChangeTimeZone -ForegroundColor Red
}
[Environment]::NewLine
PAUSE




#####  Смена языка  #####
#Отдельные проверочные команды
#Get-InstalledLanguage

<#РАБОТАЕТ, но в Teams не меняет
Set-Culture ru-RU; 
Set-WinSystemLocale -SystemLocale ru-RU; 
Set-WinUILanguageOverride -Language ru-RU; 
$list = Get-WinUserLanguageList; 
$list.Add("ru-RU"); 
Set-WinUserLanguageList $list -Force; 
Set-WinHomeLocation -GeoId 203;
#>

#Windows 11. Загружает из интернета. НЕ РАБОТАЕТ
#Install-Language -Language ru-ru -CopyToSettings
#Set-SystemPreferredUILanguage -Language ru-ru
#Restart-Computer

# Windows 11. https://www.outsidethebox.ms/22149/
try {
    #$LogFile = "D:\WorkPC\1\log.log"
    Install-Language ru-RU -CopyToSettings -Verbose #-ErrorVariable ErrInstallLanguage 
    #$ErrInstallLanguage | Tee-Object -file $LogFile -Append

    Set-WinUILanguageOverride ru-RU -Verbose

    $List = Get-WinUserLanguageList -Verbose
    $List.Add("ru-RU")
    Set-WinUserLanguageList $($list[1], $list[0]) -Force -Verbose

    # https://go.microsoft.com/fwlink/?LinkID=242308
    Set-WinHomeLocation -GeoId 203  -Verbose
    Set-WinSystemLocale ru-RU -Verbose
    Set-Culture ru-RU -Verbose
    #Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True #выдаёт ошибку
    # Бонус: переопределить дефолтный метод ввода на английский
    # Set-WinDefaultInputMethodOverride -InputTip "0409:00000409"
    #Restart-Computer
    
    #что-то про DISM
    #dism /image:c:\target /set-sysuilang:ru-ru
    
    #$LogFile = "D:\WorkPC\1\log.log"
    $OutText1 = "System language changed to RUSSIAN"

    #$ErrInstallLanguage, $OutText1 | Out-File -FilePath $LogFile -Append
    #Write-Host "Язык системы изменён на руский" -ForegroundColor Green
    Write-Host $OutText1 -ForegroundColor Green #
    #Write-Host "Bugs when tried language changed to RUSSIAN" -ForegroundColor Red

}
catch {
    #$LogFile = "D:\WorkPC\1\log.log"
    $OutText1 = "System language was NOT changed to RUSSIAN"
    $OutText2 = "You can:"
    $OutText3 = "Install russian language mannually now or later"
    $OutText4 = "OR istall last update from Windows Update and try again run this script later"
    
    #$OutText1, $OutText2 | Out-File -FilePath $LogFile -Append
    Write-Host $OutText1 -ForegroundColor Red
    Write-Host $OutText2 -ForegroundColor Red
    Write-Host $OutText3 -ForegroundColor Red
    Write-Host $OutText4 -ForegroundColor Red

    #Для борьбы с ошибкой: "the term install-language is not recognized as the name of a cmdlet, function"
    <#Все эти пакеты ниже или не помогают или не протестированы до конца
    #https://stackoverflow.com/questions/41585758/install-module-the-term-install-module-is-not-recognized-as-the-name-of-a-cm/56965990#56965990
    Install-Module -Name PackageManagement -RequiredVersion 1.4.7 -verbose
    [Environment]::NewLine

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -verbose
    [Environment]::NewLine

    #Install-PackageProvider -Name Powershellget -Force
    #[Environment]::NewLine

    Install-Language ru-RU -CopyToSettings -verbose
    #>
}
[Environment]::NewLine
PAUSE

<# Язык Teams. При первом заходе не срабатывает. Отключаю.
c:\Rigel\x64\scripts\provisioning\scriptlaunch.ps1 ApplyCurrentRegionAndLanguage.ps1
#Write-Host "Язык teams изменён на руский" -ForegroundColor Green
Write-Host "Teams language changed to RUSSIAN" -ForegroundColor Green
[Environment]::NewLine
PAUSE
#>

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
Write-Host "Example:  VCSIR-SELENGA" -ForegroundColor RED
do {
    #$PcNewName = Read-Host "Укажи Новое имя "
    $PcNewName = Read-Host "New Hostname "
} while (
    ($PcNewName -eq '') -or ($PcNewName -notmatch "[v][c][s][A-z][A-z][-].\B" -and $PcNewName.Length -le 15)
)
Rename-Computer -NewName $PcNewName -verbose
[Environment]::NewLine
PAUSE


#Задаём пароль для учёток Skype и TrueConf
do {
    Write-Host "The Password for local users Skype and TrueConf must not EMPTY !!!" -ForegroundColor RED
    Write-Host "The Password to get from Confluence IT Support space" -ForegroundColor RED
    [Environment]::NewLine

    $SkypeTrueConfPwdUnsecur = Read-Host "Input password which will use for local users Skype and TrueConf "
    [Environment]::NewLine

} while (
    $SkypeTrueConfPwdUnsecur -eq ''
)
$SkypeTrueConfPwdSecur = ConvertTo-SecureString $SkypeTrueConfPwdUnsecur -AsPlainText -Force


#CHECK. Создаём пользователя TrueConf
try {
    #без пароля
    #New-LocalUser "TrueConf" -NoPassword -UserMayNotChangePassword -AccountNeverExpires | Set-LocalUser -PasswordNeverExpires $true

    #$Password = Read-Host "Enter the new password" -AsSecureString
    #$tcpwdunsecur = ""
    #$tcpwdsecur = ConvertTo-SecureString $tcpwdunsecur -AsPlainText -Force
    New-LocalUser $loginTrueConf -Password $SkypeTrueConfPwdSecur -UserMayNotChangePassword -AccountNeverExpires -Verbose -ErrorVariable ErrTCuserCreate -ErrorAction Stop | Set-LocalUser -PasswordNeverExpires $true
    #New-LocalUser "Test" -Password $tcpwdsecur -UserMayNotChangePassword -AccountNeverExpires | Set-LocalUser -PasswordNeverExpires $true
    
    Write-Host "User $loginTrueConf was created successfully with password $SkypeTrueConfPwdUnsecur" -ForegroundColor Green
}
catch {
    Write-Host $ErrTCuserCreate -ForegroundColor Red
}
[Environment]::NewLine
PAUSE

#Добавление пользователя TrueConf в администраторы
#$loginTrueConf = "TrueConf"
try {    
    #Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member Skype –Verbose
    Add-LocalGroupMember -Group 'Administrators' -Member $loginTrueConf –Verbose -ErrorVariable ErrAddAdmin1 -ErrorAction Stop

    Write-Host "$loginTrueConf was added to Administrators" -ForegroundColor Green
    Write-Host "!!! DON'T FORGET REMOVE $loginTrueConf FROM ADMINISTRATORS AFTER TrueConf Room CONFIGURATION !!!" -ForegroundColor Red 
}
catch {    
    try {
        Add-LocalGroupMember -Group 'Администраторы' -Member $loginTrueConf –Verbose -ErrorVariable ErrAddAdmin2 -ErrorAction Stop

        Write-Host "$loginTrueConf добавлен в группы Администраторы" -ForegroundColor Green
        Write-Host "!!! Не забудь удалить $loginTrueConf из Администраторов ПОСЛЕ настройки TrueConf Room !!!" -ForegroundColor Red
    }
    catch {
        Write-Host "$loginTrueConf was NOT added to Administrators" -ForegroundColor Red
        Write-Host "For TrueConf Room configuration you can add local user $loginTrueConf to Administrators mannually" -ForegroundColor Red
    }
}
[Environment]::NewLine


#Доступ учётке TrueConf для WMI, чтобы считать кол-во подключенных мониторов
Function Set-WMIPermissions {
    Param (
        [String]$Namespace = 'WMI', #'CIMV2',
        [String]$Account   = $loginTrueConf, #'lab\Domain users',
        [String]$Computer  = $env:COMPUTERNAME
    )

    Function Get-Sid {
        Param (
            $Account
        )
        $ID = New-Object System.Security.Principal.NTAccount($Account)
        Return $ID.Translate([System.Security.Principal.SecurityIdentifier]).toString()
    }

    $SID = Get-Sid $Account
    $SDDL = "A;CI;CCSWWP;;;$SID"
    $DCOMSDDL = "A;;CCDCRP;;;$SID"
    $Reg = [WMICLASS]"\\$Computer\root\default:StdRegProv"
    $DCOM = $Reg.GetBinaryValue(2147483650,'software\microsoft\ole','MachineLaunchRestriction').uValue
    $Security = Get-WmiObject -ComputerName $Computer -Namespace "root\$Namespace" -Class __SystemSecurity
    $Converter = New-Object System.Management.ManagementClass Win32_SecurityDescriptorHelper
    $BinarySD = @($null)
    $Result = $Security.PsBase.InvokeMethod('GetSD', $BinarySD)
    $OutSDDL = $Converter.BinarySDToSDDL($BinarySD[0])
    $OutDCOMSDDL = $Converter.BinarySDToSDDL($DCOM)
    $NewSDDL = $OutSDDL.SDDL += '(' + $SDDL + ')'
    $NewDCOMSDDL = $OutDCOMSDDL.SDDL += '(' + $DCOMSDDL + ')'
    $WMIbinarySD = $Converter.SDDLToBinarySD($NewSDDL)
    $WMIconvertedPermissions = ,$WMIbinarySD.BinarySD
    $DCOMbinarySD = $Converter.SDDLToBinarySD($NewDCOMSDDL)
    $Result = $Security.PsBase.InvokeMethod('SetSD', $WMIconvertedPermissions)
    $Result = $Reg.SetBinaryValue(2147483650,'software\microsoft\ole','MachineLaunchRestriction', $DCOMbinarySD.binarySD)
    Write-Verbose 'WMI Permissions set'
}
[Environment]::NewLine


#Меняем пароль от УЗ Skype
try {
    #$SkypePwdUnsecur = ""
    #$SkypePwdSecur = ConvertTo-SecureString $SkypePwdUnsecur -AsPlainText -Force
    Set-LocalUser -Name $loginSkype -Password $SkypeTrueConfPwdSecur -ErrorAction Stop -ErrorVariable ErrChangeSkypeUserPwd

    Write-Host "For $loginSkype user set password $SkypeTrueConfPwdUnsecur" -ForegroundColor Green
    Write-Host "All Teams shell settings has been reset" -ForegroundColor Red
}
catch {
    Write-Host $ErrChangeSkypeUserPwd -ForegroundColor Red
}

[Environment]::NewLine
PAUSE


#Автологон 
<#Выбор учётки автологона отключаю в виду направления на TrueConf, невозможностью смены скриптом языка в teams и увеличения кол-ва запускаемых скриптов
do {
    #$UserAutoLogin = Read-Host "Укажи имя учётной записи Skype или TrueConf, в которую настроить автологин "
    $UserAutoLogin = Read-Host "Write Skype or TrueConf for autologon setting "
    $UserAutoLogin
} while (    
    ($UserAutoLogin -ne "Skype") -and ($UserAutoLogin -ne "TrueConf") -and ($UserAutoLogin -ne "Test")
)
#>
$UserAutoLogin = "TrueConf"

#Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -PropertyType "DWord" -Value "0"
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'

#Всегда остаётся таким. Не меняем:
#Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String

#Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "Test" -type String
 Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$UserAutoLogin" -type String -Verbose

#если для любой учётки, какой бы она ни была, есть пароль:
#Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$PasswordUser" -type String
 Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$SkypeTrueConfPwdUnsecur" -type String -Verbose

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
Write-Host "For user $UserAutoLogin set autologon in the system with password $SkypeTrueConfPwdUnsecur" -ForegroundColor Green
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
    C:\AudioCodes\GPO\LGPO.exe /g c:\AudioCodes\GPO
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
}
#>
try {
    Add-LocalGroupMember -Group 'Remote Desktop Users' -Member Skype –Verbose -ErrorVariable ErrAddSkypeRemote1 -ErrorAction Stop
    Write-Host "Skype was added to Remote Desktop Users" -ForegroundColor Green
}
catch {
    try {
        Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member Skype –Verbose -ErrorVariable ErrAddSkypeRemote2 -ErrorAction Stop
        Write-Host "Skype добавлен в Пользователи удаленного рабочего стола" -ForegroundColor Green
    }
    catch {
        Write-Host "Skype was NOT added to Remote Desktop Users" -ForegroundColor Red
        Write-Host "You can do that mannually later" -ForegroundColor Red
    }     
}
[Environment]::NewLine
PAUSE

try {     
    Add-LocalGroupMember -Group 'Remote Desktop Users' -Member $loginTrueConf –Verbose -ErrorVariable ErrAddTcRemote1 -ErrorAction Stop
    Write-Host "$loginTrueConf was added to Remote Desktop Users" -ForegroundColor Green
}
catch {
    try {
        Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member $loginTrueConf –Verbose -ErrorVariable ErrAddTcRemote2 -ErrorAction Stop
        Write-Host "$loginTrueConf добавлен в Пользователи удаленного рабочего стола" -ForegroundColor Green
    }
    catch {
        Write-Host "$loginTrueConf was NOT added to Remote Desktop Users" -ForegroundColor Red
        Write-Host "You can do that mannually later" -ForegroundColor Red
    }     
}
[Environment]::NewLine
PAUSE

#CANCEL. Отключаем спящий режим:
#powercfg -x standby-timeout-ac 0

#CANCEL. Отключение блокировки экрана
#New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" -PropertyType "DWord" -Value "0"




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
     FilePath = 'C:\AudioCodes\SkypeTeams\Tele2RootCA.cer'
    #CertStoreLocation = 'Cert:\CurrentUser\Root'
    #CertStoreLocation = 'Cert:\LocalMachine\Root'
     CertStoreLocation = 'Cert:\LocalMachine\Root'
}
$params2 = @{
    #FilePath = 'C:\Users\Xyz\Desktop\BackupCert.cer'
    #FilePath = 'Tele2EnterpriseCA.cer'
     FilePath = 'C:\AudioCodes\SkypeTeams\Tele2EnterpriseCA.cer'
    #CertStoreLocation = 'Cert:\CurrentUser\Root'
    #CertStoreLocation = 'Cert:\LocalMachine\Root'
     CertStoreLocation = 'Cert:\LocalMachine\Root'
}
try {
    Import-Certificate @params1 -Verbose -ErrorAction Stop -ErrorVariable ErrImportT2rootCA
    Import-Certificate @params2 -Verbose -ErrorAction Stop -ErrorVariable ErrImportT2enterCA
    #Write-Host "Сертификаты для работы skype импортированы" -ForegroundColor Green
    Write-Host "Skype certificates was imported successfully" -ForegroundColor Green
}
catch {
    Write-Host $ErrImportT2rootCA -ForegroundColor Red
    Write-Host $ErrImportT2enterCA -ForegroundColor Red
    Write-Host "Skype certificates was NOT imported" -ForegroundColor Red
}
[Environment]::NewLine 
PAUSE #sleep 180


#настройка teams. Сделано для того, чтобы инженеры потом не мучались с ошибкой "Подключить консоль Док-станции"
#Отключить, когда откажемся от скайпа

Write-Host "Teams configuration" -ForegroundColor Magenta
[Environment]::NewLine

try{
    Install-Module LDAPCmdlets -Verbose -ErrorAction Stop -ErrorVariable ErrInstallLdap

    Write-Host "LDAPCmdlets was installed successfully" -ForegroundColor Green
    Write-Host "We can check login and password" -ForegroundColor Green
}catch{
    #Write-Host $ErrInstallLdap -ForegroundColor Red
    Write-Host "LDAPCmdlets was NOT installed" -ForegroundColor Red
    Write-Host "We will can NOT check correctness of login and password" -ForegroundColor Red
}
[Environment]::NewLine


do{
    do {    
        $SkypeSignInAddress = Read-Host "Input room skype sign in address. Example: VK_Nadezhda@tele2.ru "
        $SkypeSignInAddress.trim()
        [Environment]::NewLine
    }until(
        $SkypeSignInAddress -like "*@tele2.ru"
        #($SkypeSignInAddress -eq '') -or ($SkypeSignInAddress -notcontains "@tele2.ru") #-or ($SkypeSignInAddress -notmatch "*@tele2.ru")
    )

    do {    
        $ExchangeAddress = Read-Host "Input room Exchange mail. Example: VK_Nadezhda@tele2.ru "
        $ExchangeAddress.trim()
        [Environment]::NewLine
    }until(
        $ExchangeAddress -like "*@tele2.ru"
        #($ExchangeAddress -eq '')
    )

    do {    
        $RoomPassword = Read-Host "Input room password "
        $RoomPassword.trim()
        [Environment]::NewLine
    }while(
        ($RoomPassword -eq '') #
    )

    #Если ошибок при установке Ldap командлета не было
    if (!$ErrInstallLdap){
        try{
            #Пробуем подключиться к LDAP
            $LdapUser = $SkypeSignInAddress.Split("@")[0]
            $LdapUser
            PAUSE

            $ldap = Connect-LDAP -User $LdapUser -Password $RoomPassword -Server "ldaps://ldap.corp.tele2.ru" -Port "636" -Verbose -ErrorAction Stop -ErrorVariable ErrLdapConnect

            Write-Host "The Connection to LDAP is established successfully" -ForegroundColor Green
            [Environment]::NewLine

            #Ищем учётку с такой почтой
            try{
                #$cn = "Administrator"
                #$user = Select-LDAP -Connection $ldap -Table "User" -Where "CN = `'$CN`'"

                $RoomProp = Select-LDAP -Connection $ldap -Table "User" -Where "mail = `'$ExchangeAddress`'" -Verbose -ErrorAction Stop -ErrorVariable ErrFindMail
            }catch{
                Write-Host $ErrFindMail -ForegroundColor Red
            }
        }catch{
            Write-Host "The Connection to LDAP is NOT established" -ForegroundColor Red
            Write-Host "Check skype sign in address" -ForegroundColor Red
        }
        
    }
}while(
    $ErrLdapConnect -or $ErrFindMail
)


#Копируем файл настроек. Пока что ничего не редактируем
$SourceSkypeSettingsFile = "C:\AudioCodes\SkypeTeams\skypesettings.xml"
$TargetSkypeSettingsPath = "C:\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState"
try {
    Copy-Item $SourceSkypeSettingsFile -Destination $TargetSkypeSettingsPath -Verbose -ErrorAction Stop -ErrorVariable ErrCopySkypeSettingsFile | Out-Host

    Write-Host "Teams settings file was copied successfully to the directory:" -ForegroundColor Green
    Write-Host $TargetSkypeSettingsPath -ForegroundColor Green
}
catch {
    Write-Host $ErrCopySkypeSettingsFile  -ForegroundColor Red
    Write-Host "Teams settings file was NOT copied from:" -ForegroundColor Red
    Write-Host $SourceSkypeSettingsFile -ForegroundColor Red
    Write-Host "to the directory:" -ForegroundColor RED
    Write-Host $TargetSkypeSettingsPath -ForegroundColor RED
}
[Environment]::NewLine
PAUSE


#Редактируем файл настроек
$SkypeSettingsFile = "C:\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState\skypesettings.xml"
try {
    #https://stackoverflow.com/questions/5596982/using-powershell-to-write-a-file-in-utf-8-without-the-bom

    $MyRawString = Get-Content -Raw $SkypeSettingsFile

    $MyRawStringReplace = $MyRawString.
    replace('test1@tele2.ru', "$SkypeSignInAddress").
    replace('test2@tele2.ru', "$ExchangeAddress").
    replace('test3', "$RoomPassword")

    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($SkypeSettingsFile, $MyRawStringReplace, $Utf8NoBomEncoding)

    Write-Host "The Teams configuration file was changed successfully" -ForegroundColor GREEN
    Start-Process 'C:\WINDOWS\system32\notepad.exe' $SkypeSettingsFile
}
catch {
    Write-Host "The Teams configuration file was NOT changed" -ForegroundColor RED
    Write-Host "Check file in the directory:" -ForegroundColor RED
    Write-Host $SkypeSettingsFile -ForegroundColor RED
}
[Environment]::NewLine
PAUSE
#





#####  Установка ПО  #####

#ZABBIX
try {
    Write-Host "Zabbix config" -ForegroundColor Magenta
    [Environment]::NewLine

    C:\AudioCodes\Zabbix\ConfigZabbix_v0.1.ps1 -Language ENG -Hostname $PcNewName #-ErrorVariable ErrZabInstall
}
catch {
    #Write-Host $ErrZabInstall -ForegroundColor RED
    Write-Host "Zabbix config script was NOT started" -ForegroundColor RED
    Write-Host "Check files in the directory:" -ForegroundColor RED
    Write-Host "C:\AudioCodes\Zabbix\" -ForegroundColor RED
}
PAUSE
[Environment]::NewLine


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
    Write-Host "You can check SCCM" -ForegroundColor green
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





#TrueConf Client
#$TcClientVersion = "8.3.2"
try {
    #C:\AudioCodes\TrueConf\trueconf_room_$tcRoomVersion.exe
    $PathTCclientSetupExe = "C:\AudioCodes\TrueConf\trueconf_client_$TcClientVersion.exe"
    Start-Process -FilePath $PathTCclientSetupExe -Verbose -ErrorAction Stop -ErrorVariable ErrTcClientSetupExe
    Write-Host "Finish installing of TrueConf Client in the separate dialog window and continue this script" -ForegroundColor Green
    #Write-Host "KES will install after some time automatically" -ForegroundColor Green
}
catch {
    Write-Host $ErrTcClientSetupExe -ForegroundColor RED
    Write-Host "TrueConf Client was NOT installed" -ForegroundColor RED
    Write-Host "Check files in the directory:" -ForegroundColor RED
    Write-Host "C:\AudioCodes\TrueConf\trueconf_client_$TcClientVersion.exe" -ForegroundColor RED  
}
Start-Sleep -Seconds 30
PAUSE
[Environment]::NewLine


#TrueConf Room
#$tcRoomVersion = "4.3.0.1341"
try {
    #C:\AudioCodes\TrueConf\trueconf_room_$tcRoomVersion.exe
    $PathTCroomSetupExe = "C:\AudioCodes\TrueConf\trueconf_room_$tcRoomVersion.exe"
    Start-Process -FilePath $PathTCroomSetupExe -Verbose -ErrorAction Stop -ErrorVariable ErrtcRoomSetupExe
    Write-Host "Finish installing of TrueConf Room in the separate dialog window and continue this script" -ForegroundColor Green
    #Write-Host "KES will install after some time automatically" -ForegroundColor Green
}
catch {
    Write-Host $ErrtcRoomSetupExe -ForegroundColor RED
    Write-Host "TrueConf Room was NOT installed" -ForegroundColor RED
    Write-Host "Check files in the directory:" -ForegroundColor RED
    Write-Host "C:\AudioCodes\TrueConf\trueconf_room_$tcRoomVersion.exe" -ForegroundColor RED  
}
Start-Sleep -Seconds 30
PAUSE
[Environment]::NewLine


#Положить на Рабочий стол ярлык на Reg-File
#$SourcePath = "C:\AudioCodes\TrueConf"
$SourceFile = "C:\AudioCodes\TrueConf\AudioCodes.lnk"
$DestinationPath = "C:\Users\Public\Desktop"
#$DestinationFile = "C:\Users\Public\Desktop\registry.lnk"
try {
    #Копирование файла
    #Copy-Item $SourceFile -Destination $DestinationPath -Verbose -ErrorAction Stop -ErrorVariable ErrCopyRegToPublicDesktop | Out-Host #вывод в консоль без задержки

    #Копирование ярлыка
    Copy-Item $SourceFile -Destination $DestinationPath -Verbose -ErrorAction Stop -ErrorVariable ErrCopyRegToPublicDesktop | Out-Host

    #Создание ярлыка
    #$WshShell = New-Object -comObject WScript.Shell
    #$Shortcut = $WshShell.CreateShortcut($DestinationPath)
    #$Shortcut.TargetPath = $SourcePath
    #$Shortcut.Save()


    #Write-Host "Reg-files for change user parameters for Chrome and TrueConf Room" -ForegroundColor Green
    Write-Host "Link of Reg-files for change user parameters for Chrome and TrueConf Room" -ForegroundColor Green
    Write-Host "was copied to the Public desktop successfully" -ForegroundColor Green
}
catch {
    Write-Host $ErrCopyRegToPublicDesktop -ForegroundColor Red
    Write-Host "Reg-file for change user parameters for Chrome and TrueConf Room" -ForegroundColor Red
    Write-Host "was NOT copied to the Public desktop" -ForegroundColor Red
    Write-Host "you must install Reg-file for change user parameters after mannually" -ForegroundColor RED
}
PAUSE
[Environment]::NewLine


#Chrome
#$ChromeVersion = "ChromeStandaloneSetup64"
try {
    #MsiExec.exe /i "C:\AudioCodes\TrueConf\trash\googlechromestandaloneenterprise64.msi" /qn /L*V C:\AudioCodes\Logs
    #MsiExec.exe /i "C:\AudioCodes\TrueConf\googlechromestandaloneenterprise64.msi" /qn /L*V "C:\AudioCodes\Logs"
    #C:\AudioCodes\TrueConf\ChromeStandaloneSetup64.exe

    #$PathTCroomSetupExe = "C:\AudioCodes\trash\.exe"
    $PathTCroomSetupExe = "C:\AudioCodes\TrueConf\$ChromeVersion.exe"
    Start-Process -FilePath $PathTCroomSetupExe -Verbose -ErrorAction Stop -ErrorVariable ErrChromeSetupExe

    Write-Host "You MUST FINISH installing Chrome in the separate dialog window and continue this script" -ForegroundColor Green
    #Write-Host "KES will install after some time automatically" -ForegroundColor Green

    Start-Sleep -Seconds 30
}
catch {
    Write-Host $ErrChromeSetupExe -ForegroundColor RED
    Write-Host "Chrome was NOT installed" -ForegroundColor RED
    Write-Host "Check files in the directory:" -ForegroundColor RED
    Write-Host "C:\AudioCodes\TrueConf\$ChromeVersion.exe" -ForegroundColor RED
    Write-Host "you must install chrome after mannually" -ForegroundColor RED
}
PAUSE
[Environment]::NewLine

#Chrome. Изменения параметров в реестре. Рабочее, но отключаю. 
#Будут запусть PS из под админа в учётке TrueConf и запускать registry.reg
try {
    #Проверить что chrome установлен?
    #1. Check folder
    #2. Check exe
    #3. Check Reg-path

    #[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ExtensionInstallAllowlist]
    #"1"="miljnhflnadlekbdohjgjdpeigmbiomh"

    New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\'
    [Environment]::NewLine
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome'
    [Environment]::NewLine
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallAllowlist'
    [Environment]::NewLine

    #Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist' -name "2" -value "miljnhflnadlekbdohjgjdpeigmbiomh"
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallAllowlist' -name "1" -value "miljnhflnadlekbdohjgjdpeigmbiomh" -Verbose -ErrorAction Stop -ErrorVariable ErrRegChrome
    [Environment]::NewLine

    Write-Host "Machine Reg-file for chrome and TrueConf Room Apllied successfully" -ForegroundColor Green
}
catch {
    Write-Host $ErrRegChrome -ForegroundColor RED
    Write-Host "Reg-file for chrome and TrueConf Room could not Apply" -ForegroundColor RED
    Write-Host "you must add Reg-file after mannually" -ForegroundColor RED
}
PAUSE
[Environment]::NewLine
#



#https://wiki.tele2.ru/pages/viewpage.action?pageId=44720938
#https://wiki.tele2.ru/pages/viewpage.action?pageId=44720978
#$KasperAgentVersion = "14.2.0.26967"
#$KasperAgentVersion = "14.2.0.26967(3)"
function KasperAgentInstallManual {
    try {
        #$PathKagentSetupExe = "D:\Programms\Kaspersky\NetAgent_$KasperAgentVersion\exec\installer.exe"
         $PathKagentSetupExe = "C:\AudioCodes\Kaspersky\NetAgent_$KasperAgentVersion\exec\installer.exe"
        #$PathKagentSetupExe = "D:\Programms\Kaspersky\NetAgent_$KasperAgentVersion\setup.exe"
        #$PathKagentSetupExe = "C:\AudioCodes\Kaspersky\NetAgent_$KasperAgentVersion\setup.exe"

        Start-Process -FilePath $PathKagentSetupExe -Verbose -ErrorAction Stop -ErrorVariable ErrKagentSetupExe

        Write-Host "Finish installing of Kaspersky Agent in the separate dialog window and continue this script" -ForegroundColor Green
        Write-Host "See photo in the folder" -ForegroundColor Green
        Write-Host "Server    : t2ru-ksc-01" -ForegroundColor Green
        Write-Host "port      : 14000" -ForegroundColor Green
        Write-Host "SSL-port  : 13000" -ForegroundColor Green
        Write-Host "UDP-port  : 15000" -ForegroundColor Green

        #explorer.exe "D:\WorkPC"
        explorer.exe "C:\AudioCodes\Kaspersky\NetAgent_photo"
    }
    catch {
        Write-Host $ErrKagentSetupExe -ForegroundColor RED
        Write-Host "Kaspersky Agent was NOT installed" -ForegroundColor RED
        Write-Host "Check files in the directory:" -ForegroundColor RED
        Write-Host $PathKagentSetupExe -ForegroundColor RED  
    }
    Start-Sleep -Seconds 45
    PAUSE
    [Environment]::NewLine
}
KasperAgentInstallManual


function KasperAgentInstallAuto {
    try {
        #1.В CMD от имени администратора перейти в папку с Kaspersky Network Agent.msi (например NetAgent_10.5.1781(4)\exec)
        #2. выполнить в CMD от имени администратора рабочей станции
        #Для установки приложения в тихом режиме используйте ключи /s и /qn
        #"Kaspersky Network Agent.msi"
        msiexec.exe /i "C:\AudioCodes\Kaspersky\NetAgent_$KasperAgentVersion\exec\Kaspersky Network Agent.msi" /qn /l*vx c:\windows\temp\nag_inst.log SERVERADDRESS="t2ru-ksc-01.corp.tele2.ru" DONT_USE_ANSWER_FILE=1 PRIVACYPOLICY=1 EULA=1 CERTSELECTION=GetOnFirstConnection LAUNCHPROGRAM=1
        #громкая установка не работает:
        #msiexec.exe /i "C:\AudioCodes\Kaspersky\NetAgent_$KasperAgentVersion\exec\Kaspersky Network Agent.msi" /l*vx c:\windows\temp\nag_inst.log SERVERADDRESS="t2ru-ksc-01.corp.tele2.ru" DONT_USE_ANSWER_FILE=1 PRIVACYPOLICY=1 EULA=1 CERTSELECTION=GetOnFirstConnection LAUNCHPROGRAM=1
        Write-Host "Command for install Kaspersky Agent was run" -ForegroundColor Green
        [Environment]::NewLine
        Start-Sleep -Seconds 15
        PAUSE    
        
    
        <#Отключаю. Не срабатывает
        #4. Проверить утилитой что связь появилась - отправить пакет пульс
        $PathKasperPuls = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\klrbtagt.exe"
    
        Write-Host "Check puls connection" -ForegroundColor Green
        Start-Process -FilePath $PathKasperPuls
        [Environment]::NewLine
        #PAUSE
        #>
    
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
    
    #3.По желанию, проверить лог C:\Windows\Temp\nag_inst.log должен заканчиваться нулем
    Write-Host "You can see Kaspersky Agent installing log" -ForegroundColor Green
    #D:\Logs\ping.txt
    C:\Windows\Temp\nag_inst.log
    [Environment]::NewLine
    PAUSE
}
#KasperAgentInstallAuto


<#DISABLED. Kaspersky. Endpoint Security
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


#Вывод в консоль ip и mac
#Get-NetIPAddress | Format-Table | Select-Object -Property * | Select IPAddress
#Get-NetAdapter | Where-Object status -eq ‘up’ | Get-NetIPAddress -ea 0 | Format-Table ipaddress, AddressFamily
#Get-NetAdapter | Get-NetIpAddress
Get-WmiObject win32_networkadapterconfiguration | Select-Object -Property @{
    Name = 'IPAddress'
    Expression = {($PSItem.IPAddress[0])}
},MacAddress | Where IPAddress -NE $null
[Environment]::NewLine
#Write-Host "На основании mac-адреса сверху заведи обращение на резервацию адреса на DHCP в том регионе, где планируешь устанавливать устройство" -ForegroundColor Red
Write-Host "Use this information to reserve ip-address on DHCP in target region" -ForegroundColor Green
Write-Host "You can photo this" -ForegroundColor Green
[Environment]::NewLine
Pause



#CHECK. Локальный администратор
$NewLocalAdminLogin = "AdminTele25"
<#Создание новой отдельной УЗ администратора
#$AdminPassword = Read-Host 'Задай пароль локального администратора: Tele2#adm' –AsSecureString
 $AdminPassword = ConvertTo-SecureString "InputPassword" -AsPlainText -Force
#Set-LocalUser -Name "Администратор" -Password $AdminPassword -Verbose
New-LocalUser $NewLocalAdminLogin -Password $AdminPassword -FullName $NewLocalAdminLogin -Description "T2 local admin" -Verbose
Write-Verbose "$NewLocalAdmin local user crated"
Add-LocalGroupMember -Group "Administrators" -Member "$NewLocalAdminLogin"
Write-Verbose "$NewLocalAdminLogin added to the local administrator group"
#>
try {
    Rename-LocalUser -Name "Admin" -NewName $NewLocalAdminLogin -Verbose -ErrorAction Stop -ErrorVariable ErrRenameAdmin
    Write-Host "Admin user was renamed to $NewLocalAdminLogin" -ForegroundColor Green
}
catch {
    Write-Host ErrRenameAdmin -ForegroundColor Red
    Write-Host "Admin user was NOT renamed to $NewLocalAdminLogin" -ForegroundColor Red
}
[Environment]::NewLine
PAUSE

try {
    Disable-LocalUser -Name "Administrator" -Verbose -ErrorAction Stop -ErrorVariable ErrDisAdmin
    Write-Host "Administrator user was disabled" -ForegroundColor Green
}
catch {
    Disable-LocalUser -Name "Администратор" -Verbose
    Write-Host "Учётная запись Администратор деактивирована" -ForegroundColor Green
}
[Environment]::NewLine
PAUSE


#Останавливаем логирование в файл
Stop-Transcript
[Environment]::NewLine

#Write-Host "Ошибки, Логи, Баги, Скрины, Проблемы, Пожелания, Предложения и Любую другую обратную связь"
#Write-Host "отправлять на:"
#Write-Host "denis.tirskikh@tele2.ru"
Write-Host "Errors, bugs, logs, screens, photos, reports, problems, suggestions and other feedback"
Write-Host "send to:"
Write-Host "denis.tirskikh@tele2.ru"
[Environment]::NewLine
PAUSE


#Write-Host "Далее можешь перезагрузить компьютер" -ForegroundColor Green
#Write-Host "После чего можно будет приступить к настройке оболочек Teams и Trueconf Room" -ForegroundColor Green
#Write-Host "After reboot connect via RDP as administrator and run second part of this script" -ForegroundColor Green
Write-Host "After reboot you will autologon in $loginTrueConf local user" -ForegroundColor Green
Write-Host "And you will can configure TrueConf Room" -ForegroundColor Green
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
