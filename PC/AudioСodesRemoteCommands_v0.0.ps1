# Version:      0.0
# STATUS:       Какие-то функции работают. Какие-то ещё нет
# Цель:         Удалённая настройка систем ВКС AudioCodes
# реализация:   
# проблемы:     
# Планы:        
# Last Update:  
# Author:       denis.tirskikh@tele2.ru


#Input PC name
 $ip = Read-Host "ip-address "
#$ip = "10.57.179.141" #Селенга


#Выбор варианта работы скрипта
#$ChooseArray = @('0','1','2','3','4','5','6','7','8','9')
$ChooseArray = @(0,1,2,3,4,5,6,7,8,9)
#Get-TimeZone -ListAvailable
do {
    [Environment]::NewLine
    Write-Host "0. ПУСТО"
    Write-Host "1. Перезагрузка"
    Write-Host "2. Сменить учётку для автологона"
    Write-Host "3. СДЕЛАТЬ. Назначить права админа на учётку"
    Write-Host "4. СДЕЛАТЬ. Забрать права админа у учётки"
    Write-Host "5. ПУСТО"
    Write-Host "6. ПУСТО"
    Write-Host "7. System Info"
    Write-Host "8. СДЕЛАТЬ. Video Devices"
    Write-Host "9. СДЕЛАТЬ. Teams Logs"
    [Environment]::NewLine

    $ChooseChoice = Read-Host "Выбери вариант отработки скрипта. Укажи номер от 0 до 9 "
} 
until (
    ($ChooseArray -contains $ChooseChoice) -and ($ChooseChoice -ne '')
    #$ZonesArray -match $TimeZoneChoice #рабочее  но пишет какую непонятную ошибку
    #($TimeZoneChoice -eq "-1") -or ($TimeZoneChoice -eq "0") -or ($TimeZoneChoice -eq "+1")
    #($TimeZoneChoice -eq '') -or 
)
#$ChooseChoice

Write-Host "Далее будет предложено ввести данные локалького админа на ВКС " -ForegroundColor RED
[Environment]::NewLine
#PAUSE

switch($ChooseChoice){
         0{"EMPTY"}
         1{Reboot -ip $ip}
         2{ChangeAutoLogon -ip $ip}
         3{AssignAdminRights -ip $ip} 
         4{RemoveAdminRights -ip $ip}
         5{"EMPTY"}
         6{"EMPTY"}
         7{SystemInfo -ip $ip} #SystemInfo $ip
         8{VideoDevices($ip, $AdminCred)}
         9{TeamsLogs($ip, $AdminCred)}
 Default {"EMPTY"}
}
[Environment]::NewLine
#$TimeZone


function Reboot{
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [alias("ip","ip-address")]
        #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
        #[ValidateLength(1,10)]
        [string]$ip
    )

    $AdminCred = get-credential
    #$ip = "10.57.178.102" Надежда
    #Restart-Computer -ComputerName $ip -Force -ErrorVariable ErrResPC -Credential $cred

    #-Verbose -ErrorAction Stop -ErrorVariable ErrReboot
    invoke-command -ComputerName $ip -credential $AdminCred {
        Shutdown /r /t 0 
    }
}

function ChangeAutoLogon([string]$ip) {
    <#
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [alias("ip","ip-address")]
        #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
        #[ValidateLength(1,10)]
        [string]$ip
    )#>

    $AdminCred = get-credential
    #$UserCred = get-credential

    #Параметр FilePath указывает скрипт, расположенный на локальном компьютере.
    #-RunAsAdministrator
    #-ArgumentList <Object[]>
    invoke-command -ComputerName $ip -credential $AdminCred -FilePath \\t2ru\folders\IT-Outsource\ПО\AudioCodes\SwitchUserAutoLogon_v1.1.ps1 -RunAsAdministrator
}

function AssignAdminRights{
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [alias("ip","ip-address")]
        #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
        #[ValidateLength(1,10)]
        [string]$ip
    )

    $AdminCred = get-credential
}

function RemoveAdminRights{
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [alias("ip","ip-address")]
        #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
        #[ValidateLength(1,10)]
        [string]$ip
    )

    $AdminCred = get-credential
}

function SystemInfo([string]$ip) {  #[securestring]
    <#
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [alias("ip","ip-address")]
        #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
        #[ValidateLength(1,10)]
        [string]$ip
    )#>
    $AdminCred = get-credential

    invoke-command -ComputerName $ip -credential $AdminCred -Verbose -ErrorAction Stop -ErrorVariable ErrReboot {
        gwmi -Class Win32_ComputerSystem | Format-List PartOfDomain,Domain,Workgroup,Manufacturer,Model
        gwmi -Class Win32_Bios | Format-List SerialNumber,SMBIOSBIOSVersion
        gwmi -Class win32_networkadapterconfiguration | Format-List IPAddress,MacAddress
    }
    <#
    Get-WmiObject win32_networkadapterconfiguration | Select-Object -Property @{
        Name = 'IPAddress'
        Expression = {($PSItem.IPAddress[0])}
    },MacAddress | Where IPAddress -NE $null
    #>  
}

function TeamsVideoDevices {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [alias("ip","ip-address")]
        #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
        #[ValidateLength(1,10)]
        [string]$ip
    )
    $AdminCred = get-credential
    
    <#
    #Push an XML configuration file (or theme graphic)
    $movefile = "<path>";
    #$targetDevice = "\\<Device fqdn> \Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState\SkypeSettings.xml";
    $targetDevice = "\\$ip\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState\SkypeSettings.xml"; 
    Copy-Item $movefile $targetDevice -Credential $cred -Verbose -ErrorAction Stop -ErrorVariable ErrCopyFile
    #>
}
 
function TeamsLogs {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [alias("ip","ip-address")]
        #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
        #[ValidateLength(1,10)]
        [string]$ip
    )
    $AdminCred = get-credential

    <#
    $targetDevice = "<Device fqdn> "
    $logFile = invoke-command {$output = Powershell.exe -ExecutionPolicy Bypass -File C:\Rigel\x64\Scripts\Provisioning\ScriptLaunch.ps1 CollectSrsV2Logs.ps1
    Get-ChildItem -Path C:\Rigel\*.zip | Sort-Object -Descending -Property LastWriteTime | Select-Object -First 1} -ComputerName $targetDevice
    $session = new-pssession -ComputerName $targetDevice
    Copy-Item -Path $logFile.FullName -Destination .\ -FromSession $session; invoke-command {remove-item -force C:\Rigel\*.zip} -ComputerName $targetDevice
    #>
}