# Версия: 1.0
# Статус: TEST
# Реализация: return several items from a Powershell function
# Проблемы:
# Вопросы: denis.tirskikh@tele2.ru


Function PCinfo (
    [string]$PCname
)
{

write-host "`n"
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
$PCProperties, $login, $PC, $c, $TypePC, $GenOzu, $OU = $null


$PC = "" | Select-Object -Property name, ip, type, OU, user, MotherManuf, MotherModel, MotherSN, ProcessorName, ProcessorSoccet, RamFormFactor, RamGeneration, RamTotal, Monitors, Drives, OStype, OSversion, OSbuild
#Drive1Name, Drive1Total, Drive1Free, Drive2Name, Drive2Total, Drive2Free, 
#Monitor1Model, Monitor1Serial, Monitor1Manuf, Monitor2Model, Monitor2Serial, Monitor2Manuf



if ($PCname -eq ''){
  do {
    $PCname = Read-Host "Имя компьютера или IP-адрес"
  } while ($PCname -eq '')
}
#else {$PC.name = $PCname}
$PC.name = $PCname





# if (($c = Read-Host "Имя компьютера или IP-адрес") -ne "") {$PC = $c}
  if (Test-Connection -ComputerName $PC.name -Quiet) {


 
#$OS = Get-WmiObject -Class Win32_OperatingSystem -Computername 'wsir-it-03' | Select-Object -Property *
 $OS = Get-WmiObject -Class Win32_OperatingSystem -Computername $PC.name

 $OSversion = $OS.Caption + $OS.CSDVersion

# https://docs.microsoft.com/en-us/windows/release-health/release-information
    if ($OS.BuildNumber -like '17763') {$OSVersion2 = '1809 - версия ОС устарела'}
elseif ($OS.BuildNumber -like '18362') {$OSVersion2 = '1903 - версия ОС устарела'}  
elseif ($OS.BuildNumber -like '18363') {$OSVersion2 = '1909 - версия ОС устарела'}
elseif ($OS.BuildNumber -like '19041') {$OSVersion2 = '2004 - версия ОС устарела'}
elseif ($OS.BuildNumber -like '19042') {$OSVersion2 = '20H2 - версия ОС устарела'}
elseif ($OS.BuildNumber -like '19043') {$OSVersion2 = '21H1'}
elseif ($OS.BuildNumber -like '19044') {$OSVersion2 = '21H1'}
elseif ($OS.BuildNumber -like '22000') {$OSVersion2 = '21H2'}
                            else {$OSVersion2 = 'Не удалось определить'}
                             



                            
<# UPTIME
$boottime = Get-WmiObject Win32_OperatingSystem -Computername wsir-it-01 | Select-Object LastBootUpTime
$datetime = (Get-Date) - $boottime #.LastBootUpTime | SELECT Days,Hours,Minutes,Seconds
$datetime

# Get-CimInstance ИБ ещё не согласовало использовать
Get-CimInstance Win32_OperatingSystem -Computername wsir-IT-01  | Select-Object LastBootUpTime
(Get-Date) – (Get-CimInstance Win32_operatingSystem).lastbootuptime
$boottime = Get-CimInstance Win32_OperatingSystem | select LastBootUpTime
$datetime = (Get-Date) - $boottime.LastBootUpTime | SELECT Days,Hours,Minutes,Seconds
$datetime
 #>

                        


 $PCProperties = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $PC.name
 # $vendor = (Get-WMIObject -ComputerName $PC Win32_ComputerSystemProduct).Vendor
 # $name = (Get-WMIObject -ComputerName $PC  Win32_ComputerSystemProduct).Name




 
 
 
  $proc = Get-WmiObject -computername $PC.name -query 'SELECT * FROM Win32_Processor' 
# Cокет процессора:
# Get-WmiObject -Class Win32_Processor -computername $PC | select *
  $Socket = (Get-WmiObject -computername $PC.name -query 'SELECT * FROM Win32_Processor').SocketDesignation
# $Socket = $proc.SocketDesignation
# $Socket = (get-ciminstance win32_processor -computername $PC).socketdesignation




  $sn = Get-WmiObject win32_bios -ComputerName $PC.name


 

# Тип машины
# Закладываем номера для типов машин $ChaType -> Опрашиваем и Получаем $ChassisType -> Сравниваем и выводим итоговую $TypePC
[int[]]$ChaNout = 2,8,9,10,11,12,14,18,21
[int[]]$ChaMonoblock = 13
[int[]]$ChaPC = 3,4,5,6,7,15,16
[int[]]$ChaServ = 17,23
$ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure -ComputerName $PC.name).ChassisTypes

          if ($ChaNout -match "\b$ChassisType\b") {$TypePC = 'Ноутбук'}
 elseif ($ChaMonoblock -match "\b$ChassisType\b") {$TypePC = 'Моноблок'}
        elseif ($ChaPC -match "\b$ChassisType\b") {$TypePC = 'Системный блок'}
      elseif ($ChaServ -match "\b$ChassisType\b") {$TypePC = 'Сервер'}
                                       else {$TypePC = 'Не удалось определить'}



# ОЗУ Generation
# Get-WmiObject Win32_PhysicalMemory -ComputerName $PC| Select-Object SMBIOSMemoryType
# Закладываем номера для поколения ОЗУ $OzuDDR -> Опрашиваем и Получаем $OzuGen -> Сравниваем и выводим итоговую $GenOZU
[int[]]$OzuDDR5 = 28
[int[]]$OzuDDR4 = 26
[int[]]$OzuDDR3 = 24
[int[]]$OzuDDR2 = 22
$OZUGen = (Get-WmiObject Win32_PhysicalMemory -ComputerName $PC.name).SMBIOSMemoryType[0] 
     if ($OzuDDR5 -match $OZUGen) {$GenOzu = 'DDR5'}
 elseif ($OzuDDR4 -match $OZUGen) {$GenOzu = 'DDR4'}
 elseif ($OzuDDR3 -match $OZUGen) {$GenOzu = 'DDR3'}
 elseif ($OzuDDR2 -match $OZUGen) {$GenOzu = 'DDR2'}
                             else {$GenOZU = 'Не удалось определить'}

# ОЗУ Form Factor
# Закладываем номера для форм-фактора ОЗУ $OzuType -> Опрашиваем и Получаем $OzuFF -> Сравниваем и выводим итоговую $FFOzu
[int[]]$OzuNout = 12
[int[]]$OzuPC = 8
[int[]]$OzuServ = 4
$OZUFF = (Get-WmiObject Win32_PhysicalMemory -ComputerName $PC.name).FormFactor[0]
     if ($OzuNout -match $OZUFF) {$FFOzu = 'SODIMM - Ноутбук'}
   elseif ($OzuPC -match $OZUFF) {$FFOzu = 'DIMM - Системный блок'}
 elseif ($OzuServ -match $OZUFF) {$FFOzu = 'Серверная ОЗУ'}
                            else {$FFOzu = 'Не удалось определить'}



# OU
$OU = Get-ADComputer -Identity $PC.name -properties DistinguishedName





 "---------PC Parameters----------"
 ""
 "Computer type     : {0}" -f $TypePC
 "OU                : {0}" -f $OU
 "System Name       : {0}" -f $OS.csname
 #"User             : {0}" -f $us.Username
 "User              : {0}" -f $PCProperties.UserName
 #"S/N Lenovo       : {0}" -f $sn.SerialNumber
 #"S/N HP           : {0}" -f $snhp.SMBIOSAssetTag
 "Processor         : {0}" -f $proc.Name
 "Socket            : {0}" -f $Socket
 "Manufacturer      : {0}" -f $PCProperties.Manufacturer
 "Model             : {0}" -f $PCProperties.Model
 "S/N               : {0}" -f $sn.SerialNumber
 #"OS Type          : {0}" -f $OS.Caption  + $OS.CSDVersion
 "OS Type           : {0}" -f $OSversion
 "OS Build          : {0}" -f $OS.BuildNumber
 "OS Version        : {0}" -f $OSVersion2
 "OS Architect      : {0}" -f $OS.OSArchitecture

 <#
 "Service WDP       : {0}" -f $serv.Name  + "  " + $serv.Status
 "Service EDPA      : {0}" -f $serv1.Name  + " " + $serv1.Status
#>
 "OZU Total (MB)    : {0}" -F ([math]::round(($PCProperties.TotalPhysicalMemory / 1024 / 1024), 2))
#"OZU Banks quantity : {0}" -f $MemoryProperties.Length
 "OZU Generation    : {0}" -f $GenOzu
 "OZU Form Factor   : {0}" -f $FFOzu
 #"Free Memory (MB) : {0}" -f ([math]::round($OS.FreePhysicalMemory / 1024, 2)) # Свободной памяти ОЗУ


# DRIVES
       $p = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC.name
  $disks = (Get-WmiObject -Class win32_diskdrive -ComputerName $PC.name).Model
  #         Get-WmiObject -Class win32_diskdrive -ComputerName $PC | Format-Table
  #         Get-WmiObject -List -ComputerName $PC | where -Property Name -Like "*disk*"
  # Get-Partition
  $i=1
  $j=1

 <#
 "Disk  Model      : {0}" -f (Get-WmiObject  -Class win32_diskdrive -ComputerName $PC).Model
 "Disk C Size      : {0}" -f ((Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | ? {$_.DeviceID -eq 'C:'}).Size / 1GB).ToString("F01") 
 "Disk C FreeSpace : {0}" -f ((Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | ? {$_.DeviceID -eq 'C:'}).FreeSpace / 1GB).ToString("F01") 
 "Disk D Size      : {0}" -f ((Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | ? {$_.DeviceID -eq 'D:'}).Size / 1GB).ToString("F01") 
 "Disk D FreeSpace : {0}" -f ((Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | ? {$_.DeviceID -eq 'D:'}).FreeSpace / 1GB).ToString("F01") 
 #>
 foreach ($disk in $disks){
    "Disk $j Model      : {0}" -f $disk
    $j++
  }  

 foreach ($comp in $p) {
    #"Disk  Model      : {0}" -f $m
    #"Disk " + $comp.DeviceID + " Size     : {0}" -f $comp.VolumeName + " " + ($comp.Size / 1GB).ToString("F01")
    #"Disk " + $comp.DeviceID + " FreeSpace: {0}" -f $comp.VolumeName + " " + ($comp.FreeSpace / 1GB).ToString("F01")
    "Disk " + $comp.DeviceID + " Size      : {0}" -f ($comp.Size / 1GB).ToString("F01") + " GB" 
    "Disk " + $comp.DeviceID + " FreeSpace : {0}" -f ($comp.FreeSpace / 1GB).ToString("F01") + " GB" 
  }


$NoutWithoutSSD = @('HP ProBook 430 G8 Notebook PC')
#if ($PCProperties.Model -match $NoutWithoutSSD) {$FreeSSD = 'НЕТ места под дополнительный SSD'}
 if ($NoutWithoutSSD -match $PCProperties.Model) {$FreeSSD = 'НЕТ места под дополнительный SSD'}
                                           else {$FreeSSD = 'ЕСТЬ место под дополнительный SSD'}
"Disk For SSD Space: {0}" -f $FreeSSD




$mon = Get-WmiObject WmiMonitorID -computername $PC.name -Namespace root\wmi
# [System.Text.Encoding]::ASCII.GetString($(Get-CimInstance WmiMonitorID -Namespace root\wmi)[1].SerialNumberID -notmatch 0)
# Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ComputerName $PC
# gwmi WmiMonitorID -Namespace root\wmi | ForEach-Object {($_.UserFriendlyName -ne 0 | foreach {[char]$_}) -join ""; ($_.SerialNumberID -ne 0 | foreach {[char]$_}) -join ""}

  function Decode {
    If ($args[0] -is [System.Array]) {
        [System.Text.Encoding]::ASCII.GetString($args[0])
    }
    Else {
        "Not Found"
    }
}   
ForEach ($Monitor in $Mon) {  
    $Manufacturer = Decode $Monitor.ManufacturerName -notmatch 0
    $Model = Decode $Monitor.UserFriendlyName -notmatch 0
    $Serial = Decode $Monitor.SerialNumberID -notmatch 0
   
    #$Manufacturer, $Name, $Serial
    "Display $i Manufac : {0}" -f $Manufacturer
    "Display $i Model   : {0}" -f $Model
    "Display $i s/n     : {0}" -f $Serial
    $i++
}





  # 'Последние 5 залогинившихся пользователей:'
  $wcusers = "\\$PC.name\C$\Users\"
  get-ChildItem $wcUsers -ErrorAction SilentlyContinue -ErrorVariable ErrGCI | Sort-Object -property LastWriteTime, Name -descending | Select-Object -first 5 | Format-Table Name, LastWriteTime
  if ($ErrGCI -like 'Не удаётся найти путь') {
    "Директория $wcusers недоступна. Скорее всего, компьютер подключен по VPN."
  }
  
 
}






else {
  Write-host "Компьютер $PC.name недоступен" -ForeGroundColor Red

  [Environment]::NewLine
  Write-host 'Информация об учётке компьютера из SCCM / GLPI / Spareparts:' -ForeGroundColor Yellow
  . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\MySQL\DataAdapter\DataAdapter_GLPI_read_v1.2.ps1
  $GLPIread = GlpiRead -Nomination $pc.name -SearchTarget login
  $GLPIread[1]
  

  [Environment]::NewLine
  Write-host 'Информация об учётке компьютера из AD:' -ForeGroundColor Yellow
# Get-ADComputer -Identity 'WSUU-URMAEV' -properties *
# Get-ADComputer -Identity 'NBVA-SAVELYEV' -properties CanonicalName,CN,Created,DistinguishedName,dSCorePropagationData,Enabled,instanceType,isCriticalSystemObject,Modified,modifyTimeStamp,Name,PasswordExpired,PasswordLastSet,whenChanged,whenCreated, OperatingSystem, OperatingSystemVersion
  Get-ADComputer -Identity $PC.name -properties CanonicalName,CN,Created,DistinguishedName,dSCorePropagationData,Enabled,instanceType,isCriticalSystemObject,Modified,modifyTimeStamp,Name,PasswordExpired,PasswordLastSet,whenChanged,whenCreated, OperatingSystem, OperatingSystemVersion

# $OSversion = (Get-ADComputer -Identity 'NBPT-CHORNYI' -properties OperatingSystem).OperatingSystem
  $OSversion = (Get-ADComputer -Identity $PC.name -properties OperatingSystem).OperatingSystem

# $OSB = (Get-ADComputer -Identity 'NBVL-ROGOZHKIN' -properties OperatingSystemVersion).split(" ").trimstart("(").trimEnd(")")
# $OSB = (Get-ADComputer -Identity 'NBVL-ROGOZHKIN'-properties OperatingSystemVersion).OperatingSystemVersion
# $OSbuildNumberSplit = ((Get-ADComputer -Identity 'NBVL-ROGOZHKIN'-properties OperatingSystemVersion).OperatingSystemVersion).split(" ").trimstart("(").trimEnd(")")
# $OSbuildNumber = $OSbuildNumberSplit[1].trimstart("(").trimEnd(")")
# $OSB = (Get-ADComputer -Identity $PC -properties OperatingSystemVersion).OperatingSystemVersion
  $OSbuildNumberSplit = ((Get-ADComputer -Identity $PC.name -properties OperatingSystemVersion).OperatingSystemVersion).split(" ")
  $OSbuildNumber = $OSbuildNumberSplit[1].trimstart("(").trimEnd(")")
  

}





# Версия ОС устарела:

function TxtTicketOldOS ($ParamOS, $ParamBuild) {
    write-host "Версия Windows больше не поддерживается и ДОЛЖНА быть обновлена" -ForeGroundColor Red
    $TxtBpmOldOS = 'Текущая версия операционной системы ДОЛЖНА быть ОБНОВЛЕНА до:', 'Windows 10 PRO 22H1', '', 'Необходимо произвести очистку диска для обновления', 'Потом попробовать обновиться через Центр Программного Обеспечения', 'Если обновиться не удастся, то завести обращения на МОДЕРНИЗАЦИЮ диском или полную ЗАМЕНУ компьютера', 'Если сотрудник уволен или компьютером никто давно не пользуется и он просто лежит в непонятном состоянии, то УДАЛИТЬ учётку машины из AD',''
    Set-Clipboard $TxtBpmOldOS
    write-host "текст комментария для заявки в bpm скопирован в буфер обмена" -ForeGroundColor Magenta
    [Environment]::NewLine
    # Return $TxtBpmOldOS
  }


if ($OSbuildNumber -lt 19000) {
    TxtTicketOldOS $OSversion $OSbuildNumber
  }


  return $PC
} # Function Pcinfo END


$PCname = ''
$PCinfo = PCinfo -PCname $PCname
$PCinfo



