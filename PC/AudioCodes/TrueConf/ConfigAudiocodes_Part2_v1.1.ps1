# Version:      1.1
# STATUS:       Протестировано на 3 устройствах
# Цель:         второй этап настройки систем ВКС AudioCodes. Настройки, требущие административных прав
# реализация:   Какие функции по итогу запускаются перечислено в самом низу документа
# проблемы:     Вроде, язык в системе так и не меняется + Время синхронизируется только до ближайшей перезагрузки
# Планы:        Получить обратную связь от инженеров
# Last Update:  Добавлен в Планировщик задач запуск скрипта, синхронизирующего время, при каждом старте
# Author:       denis.tirskikh@tele2.ru


<# Если очень хочется полноценно запустить скрипт (выделить или поставить курсор и F8)
Set-ExecutionPolicy Unrestricted
#>

<#Внешние входные параметры для скрипта
[CmdletBinding()]
Param (
    [Parameter (Position=1)] #[Parameter (Mandatory=$true, Position=1)]
    #[alias("ARG","ArgumentName")]
    #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
    #[ValidateLength(1,3)]
    [string]
    $username,

    [Parameter (Position=2)] #[Parameter (Mandatory=$true, Position=2)]
    [string]
    $device    
)
[Environment]::NewLine
Write-Host "Username : "$username
Write-Host "Device   : "$device
#>
[Environment]::NewLine
[Environment]::NewLine
[Environment]::NewLine

function Logging {
    #Логирование
    #$LogFolder = "C:\AudioCodes\Logs\"
    $DateStart = Get-Date -Format "dd.MM.yyyy_HH.mm.ss"
    $LogFile = "C:\AudioCodes\Logs\part2_$DateStart.log"

    #Dcnfdbnm проверку на наличие папки
    try {
        New-Item -Path 'C:\AudioCodes\Logs\' -ItemType Directory -ErrorAction Stop -ErrorVariable ErrCreateLogDir
        Write-Host "папка для логов скрипта уже создана" -ForegroundColor Green
    }
    catch {
        Write-Host "папка для логов скрипта была создана" -ForegroundColor Green
    }
    #[Environment]::NewLine
    Start-Transcript -Path $LogFile -Append
    Write-Host "the script logging Was started to the file:" -ForegroundColor Green
    Write-Host $LogFile -ForegroundColor Green
    [Environment]::NewLine
    PAUSE
}



#####    НАЧАЛО АДМИНСКИХ ФУНКЦИЙ    #####

function ClearDesktop {
    try {
        Write-Host "Запуск процесса очистки файлов с Рабочего стола" -ForegroundColor Magenta
        [Environment]::NewLine

        $DesktopsPath = "C:\Users\*\Desktop\*"
        #$DesktopsPath = "D:\WorkPC\1\Удалить\Diag\*"
        #$DesktopFiles = 
        #Get-Item -Path $DesktopsPath -Verbose -Force | Remove-Item -Force -Recurse -Verbose
        Get-Item -Path $DesktopsPath -Verbose -Force | ForEach-Object {
            try {
                Remove-Item $_ -Force -Recurse -Verbose -ErrorAction Stop -ErrorVariable ErrDelFile
            }
            catch {
                $_
                Write-Host "Не смог удалиться с Рабочего стола. Ты ДОЛЖЕН удалить его вручную" -ForegroundColor Red
                PAUSE
            }
        }
        #Write-Host "Ярлыки и файлы с Рабочего стола удалены" -ForegroundColor Green
        #Write-Host "Если есть файлы, которые не смогли удалиться, ты ДОЛЖЕН удалить их вручную" -ForegroundColor Red
    }
    catch {
        Write-Host "Некоторые Ярлыки и файлы не были удалены с Рабочего стола" -ForegroundColor Red
        Write-Host "Ты ДОЛЖЕН удалить их вручную" -ForegroundColor Red
    }
    [Environment]::NewLine
    PAUSE


    #Remove recycle bin
    #https://stackoverflow.com/questions/77420778/remove-recycle-bin-from-desktop-with-powershell
    try {
        if((Test-Path -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum) -eq $false) {
            New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies -Name "NonEnum"
        }
        Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 1 -Type DWord

        Write-Host "Поправки в реестр для скрытия Корзины с Рабочего стола применены успешно" -ForegroundColor Green
        [Environment]::NewLine
    
        try {
            taskkill /f /im explorer.exe
            start explorer.exe

            Write-Host "Процесс explorer.exe перезапущен успешно" -ForegroundColor Green
        }
        catch {
            Write-Host "Процесс explorer.exe НЕ смог перезапуститься. Необходимо довести скрипта до конца, перезагрузиться и проверить, что Корзина с рабочего стола удалена" -ForegroundColor Red
        }      
    }
    catch {
        Write-Host "Корзина с рабочего стола НЕ была удалена. Ты должен её удалить самостоятельно через Настройки системы" -ForegroundColor Red
    }
    [Environment]::NewLine
    PAUSE    
}

function MoveBatToTheDesktop{
    #Положить на Рабочий стол батник, запускающий всё
    #$SourcePath = "C:\AudioCodes\TrueConf"
    $SourceFile = "C:\AudioCodes\TrueConf\StartChromeRoom.bat"
    $DestinationPath = "C:\Users\TrueConf\Desktop"
    #$DestinationFile = "C:\Users\Public\Desktop\registry.lnk"
    try {
        #Копирование файла
        Copy-Item $SourceFile -Destination $DestinationPath -Verbose -ErrorAction Stop -ErrorVariable ErrCopyRegToPublicDesktop | Out-Host #вывод в консоль без задержки
        #Копирование ярлыка
        #Copy-Item $SourceFile -Destination $DestinationPath -Verbose -ErrorAction Stop -ErrorVariable ErrCopyRegToPublicDesktop | Out-Host

        #Создание ярлыка
        #$WshShell = New-Object -comObject WScript.Shell
        #$Shortcut = $WshShell.CreateShortcut($DestinationPath)
        #$Shortcut.TargetPath = $SourcePath
        #$Shortcut.Save()

        #Write-Host "Reg-files for change user parameters for Chrome and TrueConf Room" -ForegroundColor Green
        Write-Host "Батник, делающий всю магию при запуске системы, скопирован на Рабочий стол" -ForegroundColor Green
        Write-Host "Ты ДОЛЖЕН проверить, что он лежит ровно в ЛЕВОМ ВЕРХНЕМ углу на Рабочем столе" -ForegroundColor Green
        Write-Host "Туда будет кликаться мышка при старте системы и запускать его" -ForegroundColor Green
    }
    catch {
        Write-Host $ErrCopyRegToPublicDesktop -ForegroundColor Red
        Write-Host "Батник, делающий всю магию при запуске системы, НЕ БЫЛ скопирован на Рабочий стол" -ForegroundColor Red
        Write-Host "Ты должен сделать это самостоятельно вручную!!!" -ForegroundColor Red
        Write-Host "Поместить файл в крайний левый верхний угол. Именно туда будет кликаться мышка при запуске системы." -ForegroundColor RED

    }

    PAUSE
    [Environment]::NewLine
}

function TrueConfRoomInstall{
    #TrueConf Room
    $tcRoomVersion = "4.3.0.1515"
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
}

function Set-WmiPermisions {
    #Доступ учётке TrueConf для WMI, чтобы считать кол-во подключенных мониторов
    Param (
        [String]$Namespace = 'WMI', #'CIMV2',
        [String]$Account   = 'TrueConf', #'lab\Domain users',
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
    [Environment]::NewLine
}


function RegAddChromeAllowExtensions {
    #Машинная поправка в реестр для хрома, разрешающая запуск и установку расширений
    try {
        try {
            New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\' -ErrorAction Stop -ErrorVariable ErrRegMachineChrome
        [Environment]::NewLine
        }
        catch {
            #Do this if a terminating exception happens
        }
        try {
            New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome' -ErrorAction Stop -ErrorVariable ErrRegMachineChrome
            [Environment]::NewLine
        }
        catch {
            #Do this if a terminating exception happens
        }
        try {
            New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallAllowlist' -ErrorAction Stop -ErrorVariable ErrRegMachineChrome
            [Environment]::NewLine
        }
        catch {
            #Do this if a terminating exception happens
        }        

        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallAllowlist' -name "1" -value "miljnhflnadlekbdohjgjdpeigmbiomh" -Verbose -ErrorAction Stop -ErrorVariable ErrRegChrome
        [Environment]::NewLine

        Write-Host "Machine Reg-file for allow chrome extensions Apllied successfully" -ForegroundColor Green
        #regedit.exe
    }
    catch {
        Write-Host $ErrRegChrome -ForegroundColor RED
        Write-Host "Reg-file for chrome and TrueConf Room could not Apply" -ForegroundColor RED
        Write-Host "you must add Reg-file after mannually" -ForegroundColor RED
    }
    [Environment]::NewLine
    PAUSE
}

function ChangeTeamsLanguage {
    # Язык teams. при первом заходе не срабатывает.
    try {
        c:\Rigel\x64\scripts\provisioning\scriptlaunch.ps1 ApplyCurrentRegionAndLanguage.ps1
        Write-Host "Язык Teams изменён на руский" -ForegroundColor Green
        #Write-Host "Teams language changed to RUSSIAN" -ForegroundColor Green
        #Write-Host "После окончания скрипта проверь смену языка в оболочке Teams" -ForegroundColor Green
    }
    catch {
        #Do this if a terminating exception happens
    }
    [Environment]::NewLine
    PAUSE
    #[Environment]::NewLine
}

function ChangeTrueConfPassword{
    [Environment]::NewLine
    #$regex = "/^[аАбБвВгГдДеЕёЁжЖзЗиИйЙкКлЛмМнНоОпПрРсСтТуУфФхХцЦчЧшШщЩъЪыЫьЬэЭюЮяЯ]+$/"
    #$regex = "/[\wа-яА-Я]+/ig"
    #$regex = "/[\w\u0430-\u044f]+/ig"
    #$regex = "/[\w\p{sc=Cyrillic}]+/ug"
    $regex = "[\u0401\u0451\u0410-\u044f]"

    <#
    try {
        $login = "denis.tirskikh"
        $glTrueConf = Get-LocalUser -Name $login -ErrorAction Stop -ErrorVariable ErrGetlocaluser
        $glTrueConf | Select-Object -ExpandProperty PasswordRequired
    }
    catch {
        #Do this if a terminating exception happens
    }
    #>

    do {    
        $TrueConfPwdUnsecur = Read-Host "Input password for TrueConf user. CHECK INPUT LANGUAGE!!! "
        $TrueConfPwdUnsecur.trim()
        [Environment]::NewLine
    }while(
        ($TrueConfPwdUnsecur  -eq '') -or ($TrueConfPwdUnsecur -match $regex)
    )
    $TrueConfPwdSecur = ConvertTo-SecureString $TrueConfPwdUnsecur -AsPlainText -Force

    try {
        Get-LocalUser -Name TrueConf -ErrorAction Stop -ErrorVariable ErrGetlocaluser | Set-LocalUser -Password $TrueConfPwdSecur -PasswordNeverExpires $true -Verbose -ErrorAction Stop -ErrorVariable ErrSetPwd
        Write-Host "For user TrueConf set password $TrueConfPwdUnsecur" -ForegroundColor Green
    }
    catch {
        Write-Host $ErrGetlocaluser -ForegroundColor Red
        Write-Host $ErrSetPwd -ForegroundColor Red
        Write-Host "For user TrueConf was NOT set password $TrueConfPwdUnsecur" -ForegroundColor Red
    }
    [Environment]::NewLine

     $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    #Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$UserAutoLogin" -type String -Verbose
     Set-ItemProperty $RegistryPath 'DefaultPassword' -Value $TrueConfPwdUnsecur -type String -Verbose
     Write-Host "For user TrueConf set autologon in the system with password $TrueConfPwdUnsecur" -ForegroundColor Green

    [Environment]::NewLine
    PAUSE
}

function DeleteTrueConfUserFromAdministrators {
    #Удаление пользователя TrueConf из администраторов
    Write-Host "Далее запуститься блок, удаляющий пользователя TrueConf из локальных администраторов" -ForegroundColor Red
    Write-Host "Запускай его ТОЛЬКо, когда закончил полностью настройку TrueConf Room" -ForegroundColor Red
    try {    
        Remove-LocalGroupMember -Group 'Administrators' -Member TrueConf –Verbose
        Write-Host "TrueConf user was REMOVED from Administrators" -ForegroundColor Green
        [Environment]::NewLine
    }
    catch {     
        Write-Host "TrueConf user was NOT removed from Administrators" -ForegroundColor Red
        Write-Host "You MUST REMOVE TrueConf user from Administrators manually" -ForegroundColor Red 
    }
    [Environment]::NewLine
    PAUSE
}

function TimeSynchronize{
    #Синхронизация времени
    try{
        #net time \\server_name_to_synch_with /set
        #net time ntp1.tele2.ru /set    net time ntp2.tele2.ru /set    net time ntp3.tele2.ru /set
        try {
            #net start w32time
            Start-Service W32Time -ErrorAction Stop -ErrorVariable ErrStartServiceTime
            Write-Host "Windows Time service run" -ForegroundColor Green
        }
        catch {
            Write-Host $ErrStartServiceTime -ForegroundColor Red
            Write-Host "Windows Time service WAS NOT run" -ForegroundColor Red
        }
        [Environment]::NewLine

        #https://edico.no/tech/dl/DateAndTime.ps1
        #w32tm /register
        #https://stackoverflow.com/questions/17507339/setting-ntp-server-on-windows-machine-using-powershell
        #https://ab57.ru/cmdlist/w32tm.html
        #w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"
        w32tm /config /syncfromflags:manual /manualpeerlist:"ntp1.tele2.ru ntp2.tele2.ru ntp3.tele2.ru" /update
        #w32tm /resync [/nowait] [/rediscover] [/soft] [/computer: <компьютер>]

        Write-Host "Time setting was syncronized with ntp servers successfully" -ForegroundColor Green
    }catch{
        Write-Host "Time setting was not syncronized with ntp servers" -ForegroundColor Red
    }
    [Environment]::NewLine
    PAUSE
}


function CreateTaskSchedulerTimeSync {

    Write-Host "Создание задачи в Планировщике задач для Синхронизации времени при старте машины" -ForegroundColor Magenta
    Write-Host "Потребуется ввести данные локального администратора" -ForegroundColor Magenta

    do {
        [Environment]::NewLine
        do {    
            $AdminLogin = Read-Host "Input local administrator login "
            $AdminLogin.trim()
            [Environment]::NewLine
        }while(
            ($AdminLogin -eq '') #
        )
    
        do {    
            $AdminPassword = Read-Host "Input local administrator password "
            $AdminPassword.trim()
            [Environment]::NewLine
        }while(
            ($AdminPassword -eq '') #
        )
    
        try {
            #https://blog.netwrix.com/2018/07/03/how-to-automate-powershell-scripts-with-task-scheduler/
            #$Trigger = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME #-AtStartup -AtLogon
            $Trigger = New-ScheduledTaskTrigger -AtStartup
            
            #$User = $env:USERNAME #"NT AUTHORITYSYSTEM"  $env:computername   $env:computername + "/" + $env:USERNAM
            
             $chroomPath = "C:\AudioCodes\TrueConf\StartChromeRoom_v0.2.ps1"
            
            #$ActionArg = "-executionPolicy bypass -noexit -Command &{C:\AudioCodes\TrueConf\StartChromeRoom_v0.0.ps1 -username trueconf} -WindowStyle Minimized"
            $ActionArg = "-executionPolicy bypass -noexit -Command &{$chroomPath -username admin}"
    
            $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $ActionArg
            
            #
            Register-ScheduledTask -TaskName "StartUp Tyme Sync" -Trigger $Trigger -User $AdminLogin -Password $AdminPassword -Action $Action -RunLevel Highest –Force -Verbose -ErrorAction Stop -ErrorVariable ErrCreateTask
            
            [Environment]::NewLine
             Write-Host "Добавлена задача в Планировщик задач на синхронизацию времени при запуске системы" -ForegroundColor Green
             
             #taskschd.msc
        }
        catch {
             Write-Host $ErrCreateTask -ForegroundColor Red
             Write-Host "Задача в Планировщик задач на на синхронизацию времени при запуске системы НЕ БЫЛА добавлена" -ForegroundColor red  
        }
    } while (
        $ErrCreateTask
    )
    
    [Environment]::NewLine 
    PAUSE
}

function CreateTaskSchedulerCountMonitors {
    try {
        #$env:USERNAME #"NT AUTHORITYSYSTEM"  $env:computername + "/" + $env:USERNAM
        #$AdminLogin = $env:computername + "\" + 'УказатьАдминскуюУЗ'  
        #$AdminPassword = ""

        do {    
            $AdminLogin = Read-Host "Input local Admin login "
            $AdminLogin.trim()
            [Environment]::NewLine
        }while(
            ($AdminLogin -eq '') #
        )

        do {    
            $AdminPassword = Read-Host "Input local Admin password "
            $AdminPassword.trim()
            [Environment]::NewLine
        }while(
            ($AdminPassword -eq '') #
        )

        #https://blog.netwrix.com/2018/07/03/how-to-automate-powershell-scripts-with-task-scheduler/
        #$Trigger = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME #-AtStartup -AtLogon
        $Trigger = New-ScheduledTaskTrigger -AtStartup #-User 'УказатьАдминскуюУЗ' #-AtStartup -AtLogon
        
        #$ActionArg = "-executionpolicy bypass -noprofile -file C:\AudioCodes\TrueConf\StartChromeRoom.ps1 trueconf"
         $ActionArg = "-executionPolicy bypass -noexit -Command &{C:\AudioCodes\TrueConf\StartChromeRoom.ps1 -username admin} -WindowStyle Minimized"
        $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $ActionArg
        
        #-RunLevel Highest Access Denied
        #-WindowStyle Minimized
        Register-ScheduledTask -TaskName "StartUp Count Connected Monitors" -Trigger $Trigger -User $AdminLogin -Action $Action -Password $AdminPassword -Force -Verbose -ErrorAction Stop -ErrorVariable ErrCreateTaskCountMonitors -RunLevel Highest
        #Register-ScheduledTask -TaskName "TEST" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force
        
        [Environment]::NewLine
        Write-Host "Добавлена задача в Планировщик задач на запуск скрипта при загрузке системы на подсчёт подключенных мониторов" -ForegroundColor Green
        taskschd.msc
    }
    catch {
        #[Microsoft.Management.Infrastructure.CimException]
        #$Error[0].Exception | Get-Member
        #$ErrCreateTaskCountMonitors.Exception.GetType().FullName
        Write-Host $ErrCreateTaskCountMonitors -ForegroundColor Red
        Write-Host "задача в Планировщике задач на запуск скрипта при загрузке системы на подсчёт подключенных мониторов НЕ БЫЛА создана" -ForegroundColor red
    }
    [Environment]::NewLine
    PAUSE
}

#####   КОНЕЦ АДМИНСКИХ ФУНКЦИЙ   #####


function CreateTaskSchedulerRoomServiceBat {
    try {
        #https://blog.netwrix.com/2018/07/03/how-to-automate-powershell-scripts-with-task-scheduler/
        $Trigger = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME #-AtStartup -AtLogon
        $User = $env:USERNAME     #"NT AUTHORITYSYSTEM"  $env:computername   $env:computername + "/" + $env:USERNAM        
    
        #$ActionArg = "C:\AudioCodes\TrueConf\StartChromeTopMost.ps1"
        $ActionArg = ""

        $Action= New-ScheduledTaskAction -Execute "C:\AudioCodes\TrueConf\StartRoomService.bat" #-Argument $ActionArg
        
        #-RunLevel Highest Access Denied
        Register-ScheduledTask -TaskName "StartUp Room Service Bat" -Trigger $Trigger -User $User -Action $Action –Force -Verbose -ErrorAction Stop -ErrorVariable ErrCreateTaskChrome -RunLevel Highest
        #Register-ScheduledTask -TaskName "StartUp Chrome and Room" -Trigger $Trigger -User $User -Action $Action –Force -Verbose -ErrorAction Stop -ErrorVariable ErrCreateTaskChrome
        
        [Environment]::NewLine
        Write-Host "Добавлена задача в Планировщик задач на запуск Room Service через батник" -ForegroundColor Green
        taskschd.msc
    }
    catch {
        Write-Host $ErrCreateTaskChrome -ForegroundColor Red
        Write-Host "Задача в Планировщик задач на запуск Room Service через батник НЕ БЫЛА создана" -ForegroundColor red
        #Write-Host "Задача в Планировщик задач на запуск Room и Chrome НЕ БЫЛА создана" -ForegroundColor red
    }
    [Environment]::NewLine
    PAUSE
}

function CreateTaskSchedulerVbsF11 {
    try {
        #https://blog.netwrix.com/2018/07/03/how-to-automate-powershell-scripts-with-task-scheduler/
        $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME #-AtStartup -AtLogon
        $Trigger.Delay = 'PT1M'
        $User = $env:USERNAME #"NT AUTHORITYSYSTEM"  $env:computername   $env:computername + "/" + $env:USERNAM
        
        #$ActionArg = "-executionpolicy bypass -noprofile -file 'C:\AudioCodes\TrueConf\StartChromeRoom.ps1 -username trueconf'"
        $ActionArg = "C:\AudioCodes\TrueConf\F11_Press.vbs"

        $Action= New-ScheduledTaskAction -Execute "wscript.exe" -Argument $ActionArg
        
        #-RunLevel Highest Access Denied БЕЗ ПРАВ АДМИНА
        Register-ScheduledTask -TaskName "VBS F11" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force -Verbose -ErrorAction Stop -ErrorVariable ErrCreateTask
        #Register-ScheduledTask -TaskName "TEST" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force
        
        [Environment]::NewLine
         Write-Host "Добавлена задача в Планировщик задач на прожимание F11 через минуту после входа в систему" -ForegroundColor Green
         taskschd.msc
    }
    catch {
         Write-Host $ErrCreateTask -ForegroundColor Red
         Write-Host "Задача в Планировщик задач на прожимание F11 через минуту после входа в систему НЕ БЫЛА добавлена" -ForegroundColor red  
    }
    [Environment]::NewLine 
    PAUSE
}

function CreateTaskSchedulerChromeRoom {
    try {
        #https://blog.netwrix.com/2018/07/03/how-to-automate-powershell-scripts-with-task-scheduler/
        $Trigger = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME #-AtStartup -AtLogon
        $User = $env:USERNAME #"NT AUTHORITYSYSTEM"  $env:computername   $env:computername + "/" + $env:USERNAM
        
         $chroomPath = "C:\AudioCodes\TrueConf\StartChromeRoom_v0.2.ps1"
        
        #$ActionArg = "-executionPolicy bypass -noexit -Command &{C:\AudioCodes\TrueConf\StartChromeRoom_v0.0.ps1 -username trueconf} -WindowStyle Minimized"
        $ActionArg = "-executionPolicy bypass -noexit -Command &{$chroomPath -username trueconf} -WindowStyle Minimized"

        $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $ActionArg
        
        #-RunLevel Highest #Если нужно запускать из под админа. Мне не нужно
        #-WindowStyle Minimized
        Register-ScheduledTask -TaskName "StartUp Chrome and Room" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force -Verbose -ErrorAction Stop -ErrorVariable ErrCreateTask
        #Register-ScheduledTask -TaskName "TEST" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force
        
        [Environment]::NewLine
         Write-Host "Добавлена задача в Планировщик задач на запуск Room и Chrome через PS-script" -ForegroundColor Green
        #taskschd.msc
    }
    catch {
         Write-Host $ErrCreateTask -ForegroundColor Red
         Write-Host "Задача в Планировщик задач на запуск Room и Chrome НЕ БЫЛА добавлена" -ForegroundColor red  
    }
    [Environment]::NewLine 
    PAUSE
}

function CreateTaskSchedulerChrome {
    try {
        #https://blog.netwrix.com/2018/07/03/how-to-automate-powershell-scripts-with-task-scheduler/
        $Trigger = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME #-AtStartup -AtLogon
        $User = $env:USERNAME     #"NT AUTHORITYSYSTEM"  $env:computername   $env:computername + "/" + $env:USERNAM        
    
        #$ActionArg = "C:\AudioCodes\TrueConf\StartChromeTopMost.ps1"
        $ActionArg = "-executionPolicy bypass -noexit -Command &{C:\AudioCodes\TrueConf\StartChromeRoom_v0.0.ps1 -username trueconf}"

        $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $ActionArg
        
        #-RunLevel Highest Access Denied
        #-WindowStyle Minimized
        Register-ScheduledTask -TaskName "StartUp Chrome Top Most" -Trigger $Trigger -User $User -Action $Action –Force -Verbose -ErrorAction Stop -ErrorVariable ErrCreateTaskChrome -RunLevel Highest
        #Register-ScheduledTask -TaskName "StartUp Chrome and Room" -Trigger $Trigger -User $User -Action $Action –Force -Verbose -ErrorAction Stop -ErrorVariable ErrCreateTaskChrome
    
        
        [Environment]::NewLine
        Write-Host "Добавлена задача в Планировщик задач на запуск Chrome поверх всех окон при логоне" -ForegroundColor Green
        taskschd.msc
    }
    catch {
        Write-Host $ErrCreateTaskChrome -ForegroundColor Red
        Write-Host "Задача в Планировщик задач на запуск Chrome на весь экран поверх всех окон НЕ БЫЛА создана" -ForegroundColor red
        #Write-Host "Задача в Планировщик задач на запуск Room и Chrome НЕ БЫЛА создана" -ForegroundColor red
    }
    [Environment]::NewLine
    PAUSE
}

function NeverTranslateThisSite{
    #https://superuser.com/questions/1037114/how-to-revert-never-translate-this-site-in-chrome

    #Go to C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Preferences
    #Search translate_site_blacklist
    #Find and delete url of the page you want translated "translate_site_blacklist":["page you want translated","some other url","one another"],
    #After edits it should look exactly like this : "translate_site_blacklist":[""]

    #$ChromePref = "C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Preferences"
     $ChromePref = "C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data\Default\Preferences"
    try {
        #$json = Get-Content -Path C:\PS\userroles.json -Raw | ConvertFrom-Json
        $pref = Get-Content -Path $ChromePref -Raw -ErrorAction Stop -ErrorVariable ErrGetPref

        try {
            $PrefStrReplace = $pref.Replace("`"translate_site_blacklist`":[]","`"translate_site_blacklist`":[`"http://localhost/`"]")

            $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
            [System.IO.File]::WriteAllLines($ChromePref, $PrefStrReplace, $Utf8NoBomEncoding)
    
            Write-Host "Сайт localhost добавлен в исключения хрома на перевод страницы на английский язык." -ForegroundColor Green
        }
        catch {
            Write-Host $ErrSetJson -ForegroundColor Red
            Write-Host "Не удалось добавить Сайт localhost в исключения хрома на перевод страницы на английский язык." -ForegroundColor Red
        }
    }
    catch {
        Write-Host $ErrGetPref -ForegroundColor Red
        Write-Host "Не удалось открыть файл настроек хрома для добавления сайта localhost в исключения на перевод страницы на английский язык" -ForegroundColor Red
        Write-Host "Проверь путь:" -ForegroundColor Red
        Write-Host $ChromePref -ForegroundColor Red
    } 
    
    [Environment]::NewLine
    PAUSE



}

function AutoHideTaskBar {
    try{
        $location = @{Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'; Name = 'Settings'}
        $value = Get-ItemPropertyValue @location
        if ($value[8] -ne 123){
            #$value[8] = if ($value[8] -Eq 122) {123} Else {122}
            $value[8] = 123
            Set-ItemProperty @location $value -Verbose -ErrorAction Stop -ErrorVariable ErrRegHideTaskBar
            Stop-Process -Name Explorer -Force
            [Environment]::NewLine
            Write-Host "Отображение Панели задач переключено в Скрывать в режиме Рабочего стола" -ForegroundColor Green
            Write-Host "Ткни сюда мышкой, чтобы продолжить скрипт" -ForegroundColor Green
            [Environment]::NewLine
        }else{
            [Environment]::NewLine
            Write-Host "Отображение Панели задач уже установлено в Скрывать в режиме Рабочего стола" -ForegroundColor Green
            [Environment]::NewLine
        }    
    }
    catch {
        Write-Host $ErrRegHideTaskBar -ForegroundColor Red
        [Environment]::NewLine
        Write-Host "Пользовательская поправка к реестру для Скрытия Панели Задач НЕ БЫЛА применена. Смотри текст ошибки" -ForegroundColor Red
        [Environment]::NewLine
    }
    PAUSE
}

function RegDelAutoStartChrome {
    $RunRegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $ChromeRegName = "chrome"
    #$ChromeRegName = "Test"

    try {
        #$gipChrome = 
        Get-ItemProperty -Path $RunRegPath -Name $ChromeRegName -ErrorAction Stop
        #if ($null -ne $gipChrome){

        try {
            Remove-ItemProperty -Path $RunRegPath -Name $ChromeRegName -Verbose -ErrorVariable ErrDelRegChrome
            [Environment]::NewLine
            Write-Host "Удалена пользовательская поправка в реестре для автозапуска Хрома," -ForegroundColor Green
            Write-Host "т.к. она будет заменена на задание в Планировщике задач" -ForegroundColor Green
        }
        catch {
            Write-Host $ErrDelRegChrome -ForegroundColor Red
            [Environment]::NewLine
            Write-Host "Пользовательская поправка к реестру для Chrome НЕ БЫЛА удалена. Смотри текст ошибки" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "в реестре нет поправки для автозапуска Chrome с именем $ChromeRegName" -ForegroundColor Green
        Write-Host "Если она названа как-то по другому, отлично от $ChromeRegName" -ForegroundColor Red
        Write-Host "то её НЕОБХОДИМО УДАЛИТЬ ВРУЧНУЮ из реестра" -ForegroundColor Red
        [Environment]::NewLine
        Write-Host "Далее будет открыт редактор реестра. Поправки для автозагрузки лежат по пути:" -ForegroundColor Red
        Write-Host "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ForegroundColor Red
        Write-Host "Продолжи скрипт, как закончишь" -ForegroundColor Red
        PAUSE
        regedit.exe
    }

    [Environment]::NewLine
    PAUSE
}

function RegDelAutoStartRoom {
    $RunRegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $RoomRegName = "TrueConf Room"
    #

    try {
        #$gipRoom = 
        Get-ItemProperty -Path $RunRegPath -Name $RoomRegName -ErrorAction Stop
        #if ($null -ne $gipRoom){
        try {
            Remove-ItemProperty -Path $RunRegPath -Name $RoomRegName -Verbose -ErrorVariable ErrDelRegTCroom -ErrorAction Stop
            [Environment]::NewLine
            Write-Host "Удалена пользовательская поправка в реестре для автозапуска TrueConf Room" -ForegroundColor Green
            Write-Host "т.к. она будет заменена на задание в Планировщике задач" -ForegroundColor Green
        }
        catch {
            Write-Host $ErrDelRegTCroom -ForegroundColor Red
            [Environment]::NewLine
            Write-Host "Пользовательская поправка к реестру для TrueConf Room НЕ БЫЛА удалена. Смотри текст ошибки" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "в реестре нет поправки для автозапуска $RoomRegName" -ForegroundColor Green
        Write-Host "Если она названа как-то по другому, отлично от $RoomRegName" -ForegroundColor Red
        Write-Host "то её НЕОБХОДИМО УДАЛИТЬ ВРУЧНУЮ из реестра" -ForegroundColor Red
        [Environment]::NewLine
        Write-Host "Далее будет открыт редактор реестра. Поправки для автозагрузки лежат по пути:" -ForegroundColor Red
        Write-Host "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ForegroundColor Red
        Write-Host "Продолжи скрипт, как закончишь" -ForegroundColor Red
        PAUSE
        regedit.exe
    }
    [Environment]::NewLine
    PAUSE
}

function RegDelAutoStartRoomService {
    $RunRegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $ServiceRegName = "TrueConf Room Service AutoStart"
    #"C:\Program Files\TrueConf\Room\TrueConfRoomService.exe" start

    try {
        #$gipservice = 
        Get-ItemProperty -Path $RunRegPath -Name $ServiceRegName -ErrorAction Stop
        #if ($null -ne $gipservice){
        try {
            Remove-ItemProperty -Path $RunRegPath -Name $ServiceRegName -Verbose -ErrorVariable ErrDelRegTCRservice -ErrorAction Stop
            [Environment]::NewLine
            Write-Host "Удалена пользовательская поправка в реестре для автостарта TrueConf Room Service" -ForegroundColor Green
            Write-Host "Заместо TrueConfRoom Service мы используем Chrome" -ForegroundColor Green
        }
        catch {
            Write-Host $ErrDelRegTCRservice -ForegroundColor Red
            [Environment]::NewLine
            Write-Host "Пользовательская поправка к реестру для автостарта TrueConf Room Service НЕ БЫЛА удалена" -ForegroundColor Red
        }        
    }
    catch {
        Write-Host "в реестре нет поправки для автостарта TrueConf Room Service" -ForegroundColor Green
        Write-Host "Заместо TrueConfRoom Service мы используем Chrome" -ForegroundColor Green
        #Write-Host "Далее будет открыт редактор реестра. Поправки для автозагрузки лежат по пути:" -ForegroundColor Red
        #Write-Host "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ForegroundColor Red
        #Write-Host "Продолжи скрипт, как закончишь" -ForegroundColor Red
    }
    [Environment]::NewLine
    PAUSE
}

function RegDelAutoStartRoomService {
    $RunRegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $ServiceRegName = "TrueConf Room Service Start"
    #"C:\Program Files\TrueConf\Room\TrueConfRoomService.exe" start

    try {
        #$gipservice = 
        Get-ItemProperty -Path $RunRegPath -Name $ServiceRegName -ErrorAction Stop
        #if ($null -ne $gipservice){
        try {
            Remove-ItemProperty -Path $RunRegPath -Name $ServiceRegName -Verbose -ErrorVariable ErrDelRegTCRservice -ErrorAction Stop
            [Environment]::NewLine
            Write-Host "Удалена пользовательская поправка в реестре для старта TrueConf Room Service" -ForegroundColor Green
            Write-Host "Заместо TrueConfRoom Service мы используем Chrome" -ForegroundColor Green
        }
        catch {
            Write-Host $ErrDelRegTCRservice -ForegroundColor Red
            [Environment]::NewLine
            Write-Host "Пользовательская поправка к реестру для старта TrueConf Room Service НЕ БЫЛА удалена" -ForegroundColor Red
        }        
    }
    catch {
        Write-Host "в реестре нет поправки для старта TrueConf Room Service" -ForegroundColor Green
        Write-Host "Заместо TrueConfRoom Service мы используем Chrome" -ForegroundColor Green
        #Write-Host "Далее будет открыт редактор реестра. Поправки для автозагрузки лежат по пути:" -ForegroundColor Red
        #Write-Host "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ForegroundColor Red
        #Write-Host "Продолжи скрипт, как закончишь" -ForegroundColor Red
    }
    [Environment]::NewLine
    PAUSE
}

function RegDelReStartRoomService {
    $RunRegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $ServiceRegName = "TrueConf Room Service Restart"
    #"C:\Program Files\TrueConf\Room\TrueConfRoomService.exe" start

    try {
        #$gipservice = 
        Get-ItemProperty -Path $RunRegPath -Name $ServiceRegName -ErrorAction Stop
        #if ($null -ne $gipservice){
        try {
            Remove-ItemProperty -Path $RunRegPath -Name $ServiceRegName -Verbose -ErrorVariable ErrDelRegTCRservice -ErrorAction Stop
            [Environment]::NewLine
            Write-Host "Удалена пользовательская поправка в реестре для рестарта TrueConf Room Service" -ForegroundColor Green
            Write-Host "Заместо TrueConfRoom Service мы используем Chrome" -ForegroundColor Green
        }
        catch {
            Write-Host $ErrDelRegTCRservice -ForegroundColor Red
            [Environment]::NewLine
            Write-Host "Пользовательская поправка в реестре для рестарта TrueConf Room Service НЕ БЫЛА удалена" -ForegroundColor Red
        }        
    }
    catch {
        Write-Host "В реестре нет поправки для рестарта TrueConf Room Service" -ForegroundColor Green
        Write-Host "Заместо TrueConfRoom Service мы используем Chrome" -ForegroundColor Green
    }
    [Environment]::NewLine
    PAUSE
}

function RegAddAutoStartChrome {
    try{
        Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -name "chrome" -value '"C:\Program Files\Google\Chrome\Application\chrome.exe" --kiosk --fullscreen http://localhost/' -Verbose -ErrorVariable ErrRegChrome
        Write-Host "Пользовательская поправка к реестру для Хрома применена успешно" -ForegroundColor Green
    }
    catch {
        Write-Host $ErrRegChrome -ForegroundColor Red
        [Environment]::NewLine
        Write-Host "Пользовательская поправка к реестру для Chrome НЕ БЫЛА применена. Смотри текст ошибки" -ForegroundColor Red
    }
    [Environment]::NewLine
    PAUSE
}

function RegAddAutoStartRoom {
    try {
        #https://docs.trueconf.com/videosdk/introduction/commandline#monitor
        #--license-key
        #--pin    Aвторизоваться в web-интерфейсе по указанному пину
        #Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -name "TrueConf Room" -value 'C:\Program Files\TrueConf\Room\TrueConfRoom.exe -pin "123" --min --wsport 8765' -Verbose -ErrorVariable ErrRegChrome
        Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -name "TrueConf Room" -value 'C:\Program Files\TrueConf\Room\TrueConfRoom.exe -pin "123" --monitor 2 --wsport 8765' -Verbose -ErrorVariable ErrRegRoom

        Write-Host "Пользовательская поправка к реестру для автозапуска TrueConf Room применена успешно" -ForegroundColor Green
    }
    catch {
        Write-Host $ErrRegRoom -ForegroundColor Red
        [Environment]::NewLine
        Write-Host "Пользовательская поправка к реестру для автозапуска TrueConf Room НЕ БЫЛА применена. Смотри текст ошибки" -ForegroundColor Red
    }
    [Environment]::NewLine
    PAUSE
}

function RegAddAutoStartRoomCoordinates {
    #https://docs.trueconf.com/videosdk/introduction/commandline
    #Add-Type -AssemblyName System.Windows.Forms
    #[System.Windows.Forms.Screen]::AllScreens

    <#
    BitsPerPixel : 32
    Bounds       : {X=0,Y=0,Width=1280,Height=800}
    DeviceName   : \\.\DISPLAY1
    Primary      : True
    WorkingArea  : {X=0,Y=0,Width=1280,Height=800}

    BitsPerPixel : 32
    Bounds       : {X=1920,Y=0,Width=1920,Height=1080}
    DeviceName   : \\.\DISPLAY2
    Primary      : False
    WorkingArea  : {X=1920,Y=0,Width=1920,Height=1080}
    #>

    #Сделать функцию получения координат и вставки их сюда
    $Coordinates = "1920,0,1920,1080"

    $exeRoom = "C:\Program Files\TrueConf\Room\TrueConfRoom.exe"
    try {
        #https://docs.trueconf.com/videosdk/introduction/commandline#monitor
        #--license-key
        #--pin    Aвторизоваться в web-интерфейсе по указанному пину
        #Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -name "TrueConf Room" -value 'C:\Program Files\TrueConf\Room\TrueConfRoom.exe -pin "123" --min --wsport 8765' -Verbose -ErrorVariable ErrRegChrome
        Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -name "TrueConf Room" -value "$exeRoom -pin 123 --position $Coordinates --wsport 8765" -Verbose -ErrorVariable ErrRegRoom

        Write-Host "Пользовательская поправка к реестру для автозапуска TrueConf Room добавлена успешно" -ForegroundColor Green
    }
    catch {
        Write-Host $ErrRegRoom -ForegroundColor Red
        [Environment]::NewLine
        Write-Host "Пользовательская поправка к реестру для автозапуска TrueConf Room НЕ БЫЛА применена. Смотри текст ошибки" -ForegroundColor Red
    }
    [Environment]::NewLine
    PAUSE
}

function RegAddAutoStartRoomService {
    try {
        #"C:\Program Files\TrueConf\Room\TrueConfRoomService.exe" start
        #https://docs.trueconf.com/videosdk/introduction/commandline#monitor
        #Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -name "TrueConf Room" -value 'C:\Program Files\TrueConf\Room\TrueConfRoom.exe -pin "123" --monitor 2 --wsport 8765' -Verbose -ErrorVariable ErrRegRoom
        Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -name "TrueConf Room Service Start" -value 'C:\Program Files\TrueConf\Room\TrueConfRoomService.exe start' -Verbose -ErrorVariable ErrRegRoomService

        Write-Host "Пользовательская поправка к реестру для автозапуска TrueConf Room Service применена успешно" -ForegroundColor Green
    }
    catch {
        Write-Host $ErrRegRoomService -ForegroundColor Red
        [Environment]::NewLine
        Write-Host "Пользовательская поправка к реестру для автозапуска TrueConf Room Service НЕ БЫЛА применена. Смотри текст ошибки" -ForegroundColor Red
    }
    [Environment]::NewLine
    PAUSE
}

function RegAddAutoStartPS {
    try {
        #$ActionArg = "-executionPolicy bypass -noexit -Command &{C:\AudioCodes\TrueConf\StartChromeRoom_v0.0.ps1 -username trueconf} -WindowStyle Minimized"
        Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -name "Start Chrome Room PS" -value 'powershell.exe -executionPolicy bypass -noexit -Command &{C:\AudioCodes\TrueConf\StartChromeRoom_v0.0.ps1 -username trueconf} -WindowStyle Minimized' -Verbose -ErrorVariable ErrAddRegPsStartUp

        Write-Host "Пользовательская поправка к реестру для автозапуска PowerShel скрипта добавлена успешно" -ForegroundColor Green
    }
    catch {
        Write-Host $ErrAddRegPsStartUp -ForegroundColor Red
        [Environment]::NewLine
        Write-Host "Пользовательская поправка к реестру для автозапуска PowerShel скрипта НЕ БЫЛА применена. Смотри текст ошибки" -ForegroundColor Red
    }
    [Environment]::NewLine
    PAUSE

}

function CreateVbsForStartPS {
    #$psPath = "c:\AudioCodes\TrueConf\StartChromeRoom_v0.1.ps1"
    #$psPath = "D:\WorkPC\1\ps.ps1"
    Set objShell = CreateObject("Wscript.Shell")
    objShell.Run("powershell.exe -noexit $psPath")

    $WShell = New-Object -Com "Wscript.Shell"
    #$WShell.SendKeys("{F11}")
    $WShell.Run("powershell.exe -noexit $psPath")
}

function ConfigRoomJson {
    #Закрыть приложение РУма
    #$exeRoom = "C:\Program Files\TrueConf\Room\TrueConfRoom.exe"
    #Get-Process

    $ProcService = "TrueConfRoomService"
    try {        
        Stop-Process -Name $ProcService -ErrorAction Stop -ErrorVariable ErrStopRoom -Force
        Write-Host "процесс $ProcService остановлен" -ForegroundColor Green
        Start-Sleep -Seconds 5
    }
    catch {
        #$ErrStopRoom
        Write-Host "Нет запущенных процессов $ProcService" -ForegroundColor Green
    }

    $ProcManager = "TrueConfRoomManager"
    try {        
        Stop-Process -Name $ProcManager -ErrorAction Stop -ErrorVariable ErrStopRoom -Force
        Write-Host "процесс $ProcManager остановлен" -ForegroundColor Green
        Start-Sleep -Seconds 5
    }
    catch {
        #$ErrStopRoom
        Write-Host "Нет запущенных процессов $ProcManager" -ForegroundColor Green
    }

    $ProcRoom = "TrueConfRoom"
    try {
        Stop-Process -Name $ProcRoom -ErrorAction Stop -ErrorVariable ErrStopRoom -Force
        Write-Host "процесс $ProcRoom остановлен" -ForegroundColor Green
        Start-Sleep -Seconds 5
    }
    catch {
        #$ErrStopRoom
        Write-Host "Нет запущенных процессов $ProcRoom" -ForegroundColor Green
    }   
    [Environment]::NewLine


    $jsonPath = "C:\ProgramData\TrueConfRoomService\settings.json"
    try {
        #$json = Get-Content -Path C:\PS\userroles.json -Raw | ConvertFrom-Json
        $json = Get-Content -Path $jsonPath -Raw -ErrorAction Stop -ErrorVariable ErrGetJson | ConvertFrom-Json
        #вывести все свойства объекта JSON:
        #$json|fl

        $json.TCRSpid = -1
        $json.roomMonitorIndex = 2
        #$json.SleepModeTimeout = 0
        $json.isRoomMonitorDefault = $true #"true"
        #$json.pin = "123"
        #$json.ScrSaverPath = "" #C:/Program Files/TrueConf/Room/SleepMode.exe
        $json.interfaceLanguage = "ru"
        $json.webMonitorIndex = 1
        $json.isWebMgrMonitorDefault = $true #"true"
        $json.webMgrStartMode = "Manual"

        try {
            #$json |ConvertTo-Json | Set-Content -Path C:\PS\userroles.json
            $json | ConvertTo-Json | Set-Content -Path $jsonPath -ErrorAction Stop -ErrorVariable ErrSetJson
    
            Write-Host "Успешно Отредактирован файл настроек TrueConf Room Service:" -ForegroundColor Green
            Write-Host $jsonPath -ForegroundColor Green
            [Environment]::NewLine
            Write-Host "Внесены следующие изменения:" -ForegroundColor Green
            #Write-Host "* Выключен спящий режим, который ВОЗМОЖНО приводит к белому экрану" -ForegroundColor Green
            Write-Host "* Для запуска приложения Room выбран дисплей номер 2" -ForegroundColor Green
            Write-Host "* Запуск web manager переведён в ручной режим" -ForegroundColor Green
            [Environment]::NewLine
            <#
            Write-Host "Далее файл настроек будет открыт."-ForegroundColor Green
            Write-Host "Можешь посмотреть и что-то изменить в нём, если есть желание (НЕ РЕКОМЕНДОВАНО)" -ForegroundColor Green
            Write-Host "Продолжи скрипт, как будешь готов" -ForegroundColor Green
            PAUSE
            Start-Process 'C:\WINDOWS\system32\notepad.exe' $jsonPath
            #>
        }
        catch {
            Write-Host $ErrSetJson -ForegroundColor Red
            Write-Host "Не удалось сохранить файл настроек TrueConf Room Service" -ForegroundColor Red
            Write-Host "Проверь путь:" -ForegroundColor Red
            Write-Host $jsonPath -ForegroundColor Red
            #Write-Host "Это критическая ошибка. Сообщи denis.tirskikh@tele2.ru" -ForegroundColor Red
        }
    }
    catch {
        Write-Host $ErrGetJson -ForegroundColor Red
        Write-Host "Не удалось открыть файл настроек TrueConf Room Service для редактирования" -ForegroundColor Red
        Write-Host "Проверь путь:" -ForegroundColor Red
        Write-Host $jsonPath -ForegroundColor Red
        #Write-Host "Это критическая ошибка. Сообщи denis.tirskikh@tele2.ru" -ForegroundColor Red
    } 
    
    [Environment]::NewLine
    PAUSE
}

function Feedback{
    [Environment]::NewLine
    Write-Host "Ошибки, Логи, Баги, Скрины, Проблемы, Пожелания, Предложения и Любую другую обратную связь" -ForegroundColor Green
    Write-Host "отправлять на:" -ForegroundColor Green
    Write-Host "denis.tirskikh@tele2.ru" -ForegroundColor Green
    #Write-Host "Errors, bugs, logs, screens, photos, reports, problems, suggestions and other feedback" -ForegroundColor Green
    #Write-Host "send to:" -ForegroundColor Green
    #Write-Host "denis.tirskikh@tele2.ru" -ForegroundColor Green
    [Environment]::NewLine
    PAUSE
}

function CheckExtensionConfig{
    #$AnswerArray = @('1','2','Yes','No','Да','Нет')
    do {
        [Environment]::NewLine
        Write-Host "1. Расширение в хроме для рума ранее было настроено на этом устройстве"
        Write-Host "2. Настройки расширения в Хроме для рума на этом устройстве ещё не производились"
        [Environment]::NewLine

        $TextChoice = Read-Host "Выбери вариант. Введи число 1 или 2 "
        [Environment]::NewLine
    } 
    until (
        #$AnswerArray -contains $TextChoice
        #$ZonesArray -match $TimeZoneChoice #рабочее  но пишет какую непонятную ошибку
        ($TextChoice -eq "1") -or ($TextChoice -eq "2")
        #($TimeZoneChoice -eq '') -or 
    )
    switch($TextChoice){
            1{
                #
                Write-Host "Далее будет предложено перезагрузиться" -ForegroundColor Green
                [Environment]::NewLine
                Write-Host "После перезагрузки НЕОБХОДИМО проверить устройство с подключенным внешним монитором/проектором/ТВ:" -ForegroundColor Green
                Write-Host "1. Что Хром стартует на экранчике ВКС поверх всех окон и его ничего не заслоняет" -ForegroundColor Green
                Write-Host "2. Окно Рума при включении внешнего монитора/проектора/ТВ появляется на нём" -ForegroundColor Green
                Write-Host "3. После выдергивания кабеля HDMI внешнего монитора/проектора/ТВ от устройства окно приложения Room не заслоняет собой хром в течение минуты." -ForegroundColor Green
                Write-Host "4. После подключения кабеля HDMI обратно окно Room возвращается на экран монитора/проектора/ТВ в течение минуты" -ForegroundColor Green
                Write-Host "5. Проделать 3 и 4 пункты минимум 4-5 раз" -ForegroundColor Green
                [Environment]::NewLine
                PAUSE

                Restart-Computer -Confirm -Force
            }
            2{
                Write-Host "Продолжай настройки по инструкции на wiki за авторством Овсянникова с 4 пункта" -ForegroundColor Green
            }
    Default {
        Write-Host "Выбран DEFAULT. передай данный кейс на denis.tirskikh@tele2.ru" -ForegroundColor red
    }
    }
    [Environment]::NewLine
}




### Какие функции по итогу запускаем ###
 Logging

#Требуются права админа
#TrueConfRoomInstall
#Set-WMIPermissions
 TimeSynchronize
 RegAddChromeAllowExtensions
#ChangeTeamsLanguage
#ChangeTrueConfPassword
#DeleteTrueConfUserFromAdministrators
#CreateTaskSchedulerCountMonitors
#CreateTaskSchedulerVbsF11 #Проверить без Highest Level
 CreateTaskSchedulerTimeSync



#Права админа НЕ требуются
#CreateTaskSchedulerChrome
 CreateTaskSchedulerChromeRoom

#RegAddAutoStartChrome
#RegAddAutoStartRoom
#RegAddAutoStartRoomService

 RegDelAutoStartChrome
 RegDelAutoStartRoom
 RegDelAutoStartRoomService
 RegDelReStartRoomService

 AutoHideTaskBar
#regedit.exe

 ConfigRoomJson
 ClearDesktop #Права админа требуются

 Feedback
 CheckExtensionConfig

 [Environment]::NewLine
 Stop-Transcript
###  Конец функций  ###



