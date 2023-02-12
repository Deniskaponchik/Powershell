# Версия: 0.2
# Статус: ТЕСТ
# Реализация: Функция без возврата множества значений отдельными параметрами
# Проблемы:
# Вопросы: denis.tirskikh@tele2.ru


Function PCinfo (
    [string]$PC
)
{

write-host "`n"
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
#$PCProperties, $login, $PC, $c, $TypePC, $GenOzu, $OU = $null



if ($PC -eq '' -or $PC -eq $Null){
  do {
    $PC = Read-Host "Имя компьютера или IP-адрес"
  } while ($PC -eq '')
}
#else {$PC = $PCname}




#$PC = 'nbrh-00001'
#if (Test-Connection -ComputerName $PC -Quiet) {
 if ($OS = Get-WmiObject -Class Win32_OperatingSystem -Computername $PC) {
#'Hi'}else{'Buy'}



[Environment]::NewLine
 write-host "---------PC Parameters----------"
 write-host ""




# Закладываем номера для типов машин $ChaType -> Опрашиваем и Получаем $ChassisType -> Сравниваем и выводим итоговую $TypePC
[int[]]$ChaNout = 2,8,9,10,11,12,14,18,21
[int[]]$ChaMonoblock = 13
[int[]]$ChaPC = 3,4,5,6,7,15,16
[int[]]$ChaServ = 17,23
$ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure -ComputerName $PC).ChassisTypes

          if ($ChaNout -match "\b$ChassisType\b") {$TypePC = 'Ноутбук'}
 elseif ($ChaMonoblock -match "\b$ChassisType\b") {$TypePC = 'Моноблок'}
        elseif ($ChaPC -match "\b$ChassisType\b") {$TypePC = 'Системный блок'}
      elseif ($ChaServ -match "\b$ChassisType\b") {$TypePC = 'Сервер'}
                                             else {$TypePC = 'Не удалось определить'}

#"Computer type     : $TypePC"
write-host "Computer type     : $TypePC"




# $PC = 'wsir-broner'
$OU = Get-ADComputer -Identity $PC -properties DistinguishedName
$SysName = $OU.Name
#"OU                : {0}" -f $OU
#"System Name       : {0}" -f $OU.Name
write-host "OU                : $OU"
write-host "System Name       : $SysName"



# $PCProperties ещё используется ниже
$PCProperties = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $PC
$User = $PCProperties.UserName
# $vendor = (Get-WMIObject -ComputerName $PC Win32_ComputerSystemProduct).Vendor
# $name = (Get-WMIObject -ComputerName $PC  Win32_ComputerSystemProduct).Name
#"User             : {0}" -f $us.Username
#"User              : {0}" -f $PCProperties.UserName
write-host "User              : $User"





  $proc = Get-WmiObject -computername $PC -query 'SELECT * FROM Win32_Processor'
#Get-WmiObject -Class Win32_Processor -computername $PC | select *
#$Socket = (Get-WmiObject -computername $PC -query 'SELECT * FROM Win32_Processor').SocketDesignation
 $ProcName = $proc.Name
 $Socket = $proc.SocketDesignation
#$Socket = (get-ciminstance win32_processor -computername $PC).socketdesignation
#"Processor         : {0}" -f $proc.Name
#"Socket            : {0}" -f $Socket
write-host "Processor         : $ProcName"
write-host "Socket            : $Socket"



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





# $PCProperties использовался выше
$MotherManuf = $PCProperties.Manufacturer
$MotherModel = $PCProperties.Model
#"S/N Lenovo       : {0}" -f $sn.SerialNumber
#"S/N HP           : {0}" -f $snhp.SMBIOSAssetTag
#"Manufacturer      : {0}" -f $PCProperties.Manufacturer
#"Model             : {0}" -f $PCProperties.Model
write-host "MotherManuf       : $MotherManuf"
write-host "MotherModel       : $MotherModel"



$sn = Get-WmiObject win32_bios -ComputerName $PC
$MotherSN = $sn.SerialNumb
#"S/N               : {0}" -f $sn.SerialNumber
write-host "S/N               : $MotherSN"





 
#$OS = Get-WmiObject -Class Win32_OperatingSystem -Computername 'wsir-it-03' | Select-Object -Property *
 $OS = Get-WmiObject -Class Win32_OperatingSystem -Computername $PC
 $OSversion = $OS.Caption + $OS.CSDVersion
# https://docs.microsoft.com/en-us/windows/release-health/release-information
# $OSVersion2 = Write-Host '1809 - версия ОС устарела' -ForeGroundColor Red
    if ($OS.BuildNumber -like '17763') {$OSVersion2 = '1809 - версия ОС устарела'}
elseif ($OS.BuildNumber -like '18362') {$OSVersion2 = '1903 - версия ОС устарела'}  
elseif ($OS.BuildNumber -like '18363') {$OSVersion2 = '1909 - версия ОС устарела'}
elseif ($OS.BuildNumber -like '19041') {$OSVersion2 = '2004 - версия ОС устарела'}
elseif ($OS.BuildNumber -like '19042') {$OSVersion2 = '20H2 - версия ОС устарела'}
elseif ($OS.BuildNumber -like '19043') {$OSVersion2 = '21H1 - версия ОС устарела'}
elseif ($OS.BuildNumber -like '19044') {$OSVersion2 = '21H1 - версия ОС устарела'}
elseif ($OS.BuildNumber -like '22000') {$OSVersion2 = '21H2'}
                            else {$OSVersion2 = 'Не удалось определить'}                             

# "OS Type          : {0}" -f $OS.Caption  + $OS.CSDVersion
 "OS Type           : {0}" -f $OSversion
 "OS Build          : {0}" -f $OS.BuildNumber
 "OS Version        : {0}" -f $OSVersion2
 "OS Architect      : {0}" -f $OS.OSArchitecture        
                            




# ОЗУ Generation
# Get-WmiObject Win32_PhysicalMemory -ComputerName $PC| Select-Object SMBIOSMemoryType
# Закладываем номера для поколения ОЗУ $OzuDDR -> Опрашиваем и Получаем $OzuGen -> Сравниваем и выводим итоговую $GenOZU
[int[]]$OzuDDR5 = 28
[int[]]$OzuDDR4 = 26
[int[]]$OzuDDR3 = 24
[int[]]$OzuDDR2 = 22
$OZUGen = (Get-WmiObject Win32_PhysicalMemory -ComputerName $PC).SMBIOSMemoryType[0] 
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
$OZUFF = (Get-WmiObject Win32_PhysicalMemory -ComputerName $PC).FormFactor[0]
     if ($OzuNout -match $OZUFF) {$FFOzu = 'SODIMM - Ноутбук'}
   elseif ($OzuPC -match $OZUFF) {$FFOzu = 'DIMM - Системный блок'}
 elseif ($OzuServ -match $OZUFF) {$FFOzu = 'Серверная ОЗУ'}
                            else {$FFOzu = 'Не удалось определить'}


 "OZU Total (MB)    : {0}" -F ([math]::round(($PCProperties.TotalPhysicalMemory / 1024 / 1024), 2))
#"OZU Banks quantity : {0}" -f $MemoryProperties.Length
 "OZU Generation    : {0}" -f $GenOzu
 "OZU Form Factor   : {0}" -f $FFOzu
 #"Free Memory (MB) : {0}" -f ([math]::round($OS.FreePhysicalMemory / 1024, 2)) # Свободной памяти ОЗУ








# DRIVES
       $p = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC
  $disks = (Get-WmiObject -Class win32_diskdrive -ComputerName $PC).Model
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




$mon = Get-WmiObject WmiMonitorID -computername $PC -Namespace root\wmi
# [System.Text.Encoding]::ASCII.GetString($(Get-CimInstance WmiMonitorID -Namespace root\wmi)[1].SerialNumberID -notmatch 0)
# Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ComputerName $PC
# gwmi WmiMonitorID -Namespace root\wmi | ForEach-Object {($_.UserFriendlyName -ne 0 | foreach {[char]$_}) -join ""; ($_.SerialNumberID -ne 0 | foreach {[char]$_}) -join ""}
<#
 foreach ($monitor in $mon)  {
    $m = ($monitor.ManufacturerName -notmatch 0 | ForEach-Object{[char]$_}) -join ""
    try {
      $u = ($monitor.UserFriendlyName -notmatch 0 | ForEach-Object{[char]$_}) -join "" 
    }
    catch {
      $u = 'Не удалось определить'
    }    
    $s = ($monitor.SerialNumberID -notmatch 0 | ForEach-Object{[char]$_}) -join "" 
    "Display $i Manufac: {0}" -f $m
    "Display $i Model  : {0}" -f $u
    "Display $i s/n    : {0}" -f $s
    $i++
  } #>

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
  $wcusers = "\\$PC\C$\Users\"
  get-ChildItem $wcUsers -ErrorAction SilentlyContinue -ErrorVariable ErrGCI | Sort-Object -property LastWriteTime, Name -descending | Select-Object -first 5 | Format-Table Name, LastWriteTime
  if ($ErrGCI -like 'Не удаётся найти путь') {
    "Директория $wcusers недоступна. Возможно, компьютер подключен по VPN."
  }
  
 
} # END of IF



else {
  #''
  Write-host "Компьютер $PC недоступен или подключен по VPN" -ForeGroundColor Red

  #''
  #[Environment]::NewLine
  Write-host 'Информация об учётке компьютера из SCCM / GLPI / Spareparts и AD ниже' -ForeGroundColor Magenta
  Write-host 'ВАЖНО: Информация об мониторах в GLPI сохраняется вся по датам их подкючения от нового к старому' -ForeGroundColor RED
  . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\MySQL\DataAdapter\DataAdapter_GLPI_read_v1.2.ps1
  $GLPIread = GlpiRead -Nomination $pc -SearchTarget login
  $GLPIread[1]
  

  #[Environment]::NewLine
  #Write-host 'Информация об учётке компьютера из AD:' -ForeGroundColor Yellow
  #$GetADpc = Get-ADComputer -Identity 'WSZI-LEADER-08' -properties *
   $GetADpc = Get-ADComputer -Identity $PC -properties *
  #$GetADpc.CN
  #Get-ADComputer -Identity 'WSZI-LEADER-08' -properties CanonicalName,CN,Created,DistinguishedName,dSCorePropagationData,Enabled,instanceType,Modified,modifyTimeStamp,Name,PasswordExpired,PasswordLastSet,whenChanged,whenCreated, OperatingSystem, OperatingSystemVersion
   Get-ADComputer -Identity $PC -properties CanonicalName,CN,Created,DistinguishedName,Enabled,instanceType,Modified,Name,PasswordExpired,PasswordLastSet,whenChanged,whenCreated, OperatingSystem, OperatingSystemVersion

# $OSversion = (Get-ADComputer -Identity 'NBPT-CHORNYI' -properties OperatingSystem).OperatingSystem
# $OSversion = (Get-ADComputer -Identity $PC -properties OperatingSystem).OperatingSystem
  $OSversion = $GetADpc.OperatingSystem


# $OSbuildNumber = $OSbuildNumberSplit[1].trimstart("(").trimEnd(")")
# $OSB = (Get-ADComputer -Identity $PC -properties OperatingSystemVersion).OperatingSystemVersion
# $OSbuildNumberSplit = ((Get-ADComputer -Identity $PC -properties OperatingSystemVersion).OperatingSystemVersion).split(" ")
  $OSbuildNumberSplit = ($GetADpc.OperatingSystemVersion).split(" ")
  $OSbuildNumber = $OSbuildNumberSplit[1].trimstart("(").trimEnd(")") 

}





# Версия ОС устарела:

function TxtTicketOldOS ($ParamOS, $ParamBuild) {
    [Environment]::NewLine
    write-host "Версия Windows ДОЛЖНА быть обновлена" -ForeGroundColor Red
    $TxtBpmOldOS = 'Текущая версия операционной системы:', $ParamOS, $ParamBuild, 'ДОЛЖНА быть ОБНОВЛЕНА до:', 'Windows 10 PRO 22H1', '', 'Необходимо произвести очистку диска для обновления', 'Потом попробовать обновиться через Центр Программного Обеспечения', 'Если обновиться не удастся, то завести обращения на МОДЕРНИЗАЦИЮ диском или полную ЗАМЕНУ компьютера', 'Если сотрудник уволен или компьютером никто давно не пользуется и он просто лежит в непонятном состоянии, то УДАЛИТЬ учётку машины из AD',''
    Set-Clipboard $TxtBpmOldOS
    write-host "текст комментария для заявки в bpm скопирован в буфер обмена" -ForeGroundColor Magenta
    [Environment]::NewLine
    # Return $TxtBpmOldOS
  }


if ($OSbuildNumber -lt 19000) {
    TxtTicketOldOS $OSversion $OSbuildNumber
  }


} # Function Pcinfo END

#
 $PC = 'wsir-broner'
 $PCinfo = PCinfo -PC $PC
#$PCinfo
#>