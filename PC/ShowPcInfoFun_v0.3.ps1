# Версия: 0.3
# Статус: Можно использовать в запросах
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




# Определение Сервисных инженеров на основании имени машины:
$PCut = $PC.Substring(0,4)
. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WSIRit01_RegionCodes_v0.1.ps1
$RegionCodes = RegionCodes -Operation ShowPCinfo -PCname $Pcut
$BPMgroup = $RegionCodes.BPMgroup21

if ($Null -eq $BPMgroup){
Write-host 'Не удалось определить ответственную группу ИТ. необходимо занести в базу' -ForegroundColor Red}
else {
Write-host "IT BPM Group      : $BPMgroup"}




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




#$PC= 'wsir-broner'
#$LastBootUpTime = Get-WmiObject Win32_OperatingSystem -Computername $PC | Select-Object @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
$LastBootUpTime = Get-WmiObject Win32_OperatingSystem -Computername $PC | Select-Object @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}} | select -First 1 -ExpandProperty LastBootUpTime
$LastReboot = Get-Date $LastBootUpTime -Format 'dd.MM.yyyy HH:mm'
#$datetime
if ( $LastBootUpTime -lt (Get-Date).AddDays(-14) ) {
     write-host "LastReboot        : $LastReboot" -ForeGroundColor Red}
else{write-host "LastReboot        : $LastReboot"}

<# Get-CimInstance ИБ не согласовало использовать
Get-CimInstance Win32_OperatingSystem -Computername wsir-IT-01  | Select-Object LastBootUpTime
(Get-Date) – (Get-CimInstance Win32_operatingSystem).lastbootuptime
$boottime = Get-CimInstance Win32_OperatingSystem | select LastBootUpTime
$datetime = (Get-Date) - $boottime.LastBootUpTime | SELECT Days,Hours,Minutes,Seconds
$datetime  #>





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
write-host "Mother S/N        : $MotherSN"





#
#$OS = Get-WmiObject -Class Win32_OperatingSystem -Computername 'wsir-it-03' | Select-Object -Property *
 $OS = Get-WmiObject -Class Win32_OperatingSystem -Computername $PC
 $OStype = $OS.Caption + $OS.CSDVersion
 $OsBuildNumber = $OS.BuildNumber
#$OsBuildNumber = $Null
 $OSArchitecture = $OS.OSArchitecture
# "OS Type          : {0}" -f $OS.Caption  + $OS.CSDVersion
#"OS Type           : {0}" -f $OSversion
write-host "OS Type           : $OStype"

#"OS Build          : {0}" -f $OS.BuildNumber
#write-host "OS Build          : $OSBuildNumber"

# https://docs.microsoft.com/en-us/windows/release-health/release-information
$HashBuildVersion = [ordered]@{
    ([uint32]17763) = '1809'
    ([uint32]18362) = '1903'        
    ([uint32]18363) = '1909'
    ([uint32]19041) = '2004'
    ([uint32]19042) = '20H2'
    ([uint32]19043) = '21H1'
    ([uint32]19044) = '21H2'
    ([uint32]22000) = '21H2'
    #([string]) = 'не удалось определить'
}
$OsVersion = $HashBuildVersion[[uint32]$OsBuildNumber]

<# $OSVersion2 = Write-Host '1809 - версия ОС устарела' -ForeGroundColor Red
    if ($OS.BuildNumber -eq '17763') {
                $OsVersion = '1809'
    write-host "OS Version        : $OsVersion - версия ОС устарела" -ForeGroundColor Red}
elseif ($OS.BuildNumber -like '18362') {
                $OsVersion = '1903'
    write-host "OS Version        : $OsVersion - версия ОС устарела" -ForeGroundColor Red}  
elseif ($OS.BuildNumber -like '18363') {
                $OsVersion = '1909'
    write-host "OS Version        : $OsVersion - версия ОС устарела" -ForeGroundColor Red}
elseif ($OS.BuildNumber -like '19041') {
                $OsVersion = '2004'
    write-host "OS Version        : $OsVersion - версия ОС устарела" -ForeGroundColor Red}
elseif ($OS.BuildNumber -like '19042') {
                $OsVersion = '20H2'
    write-host "OS Version        : $OsVersion - версия ОС устарела" -ForeGroundColor Red}
elseif ($OS.BuildNumber -like '19043') {
                $OsVersion =  '21H1'
    write-host "OS Version        : $OsVersion - версия ОС устарела" -ForeGroundColor Red}
elseif ($OS.BuildNumber -eq '19044') {
                $OsVersion =  '21H1'
    write-host "OS Version        : $OsVersion - версия ОС устарела" -ForeGroundColor Red}
elseif ($OS.BuildNumber -like '22000') {
                $OsVersion = '21H2'
    write-host "OS Version        : $OsVersion"}
else {write-host 'Не удалось определить' -ForeGroundColor Red
    $OsVersion = "Не удалось определить"}            
#"OS Version        : {0}" -f $OSVersion2
#> <#
if ( $OSbuildNumber -le 19050 ) {
    write-host "OS Version        : $OsVersion - версия ОС устарела" -ForeGroundColor Red}
elseif ( $OSbuildNumber -gt 19050 ){
    write-host "OS Version        : $OsVersion" -ForeGroundColor Green}
else {
    $OsVersion = "Не удалось определить"
    write-host "OS Version        : $OsVersion" -ForeGroundColor Red}
#>
#
if ( $OSbuildNumber -lt 19044 ) {
  write-host "OS Build          : $OSBuildNumber" -ForeGroundColor Red
  write-host "OS Version        : $OsVersion" -ForeGroundColor Red}
else {
  write-host "OS Build          : $OSBuildNumber" -ForeGroundColor Green
  write-host "OS Version        : $OsVersion" -ForeGroundColor Green}
#>

#"OS Architect      : {0}" -f $OS.OSArchitecture        
write-host "OS Architect      : $OSarchitecture"
                            




#$OzuTotal = [math]::round(($PCProperties.TotalPhysicalMemory / 1024 / 1024), 2)
 $OzuTotal = [math]::round(($PCProperties.TotalPhysicalMemory / 1073741824), 2)
#"OZU Total (MB)    : {0}" -F ([math]::round(($PCProperties.TotalPhysicalMemory / 1024 / 1024), 2))
write-host "OZU Total (GB)    : $OzuTotal"

#$OzuFree = ([math]::round($PCProperties.FreePhysicalMemory / 1024, 2))
#"Free Memory (MB) : {0}" -f ([math]::round($OS.FreePhysicalMemory / 1024, 2))
#"Free Memory (MB) : {0}" -f ([math]::round($PCProperties.FreePhysicalMemory / 1024, 2))
#write-host "OZU Free  (MB)    : $OzuFree"

#$PC = 'wsir-it-01'
$OZU = Get-WmiObject Win32_PhysicalMemory -ComputerName $PC #| Select-Object SMBIOSMemoryType

<# Закладываем номера для поколения ОЗУ $OzuDDR -> Опрашиваем и Получаем $OzuGen -> Сравниваем и выводим итоговую $GenOZU
[int[]]$OzuDDR5 = 28
[int[]]$OzuDDR4 = 26
[int[]]$OzuDDR3 = 24
[int[]]$OzuDDR2 = 22
#$OZUGen = (Get-WmiObject Win32_PhysicalMemory -ComputerName $PC).SMBIOSMemoryType[0] 
 $OZUGenNumber = $OZU.SMBIOSMemoryType[0]
     if ($OzuDDR5 -match $OZUGenNumber) {$GenOzu = 'DDR5'}
 elseif ($OzuDDR4 -match $OZUGenNumber) {$GenOzu = 'DDR4'}
 elseif ($OzuDDR3 -match $OZUGenNumber) {$GenOzu = 'DDR3'}
 elseif ($OzuDDR2 -match $OZUGenNumber) {$GenOzu = 'DDR2'}
                             else {$GenOZU = 'Не удалось определить'}
"OZU Generation    : {0}" -f $GenOzu #>
$OZUGenNumber = $OZU.SMBIOSMemoryType[0]
$HashOzuGen = [ordered]@{
  ([uint32]22) = 'DDR2'
  ([uint32]24) = 'DDR3'        
  ([uint32]26) = 'DDR4'
  ([uint32]28) = 'DDR5'
  #([string]) = 'не удалось определить'
}
$OzuGen = $HashOzuGen[[uint32]$OZUGenNumber]
write-host "OZU Generation    : $OzuGen"


<# Закладываем номера для форм-фактора ОЗУ $OzuType -> Опрашиваем и Получаем $OzuFF -> Сравниваем и выводим итоговую $FFOzu
[int[]]$OzuNout = 12
[int[]]$OzuPC = 8
[int[]]$OzuServ = 4
#$OZUFF = (Get-WmiObject Win32_PhysicalMemory -ComputerName $PC).FormFactor[0]
 $OzuFF = $OZU.FormFactor[0]
     if ($OzuNout -match $OZUFF) {$FFOzu = 'SODIMM - Ноутбук'}
   elseif ($OzuPC -match $OZUFF) {$FFOzu = 'DIMM - Системный блок'}
 elseif ($OzuServ -match $OZUFF) {$FFOzu = 'Серверная ОЗУ'}
                            else {$FFOzu = 'Не удалось определить'} 
 "OZU Form Factor   : {0}" -f $FFOzu #>
$OzuFFnumber = $OZU.FormFactor[0]
$HashOzuFF = [ordered]@{
   ([uint32]4) = 'Серверная ОЗУ'
   ([uint32]8) = 'DIMM - Системный блок'        
  ([uint32]12) = 'SODIMM - Ноутбук'
  #([string]) = 'не удалось определить'
}
$OzuFF = $HashOzuFF[[uint32]$OzuFFnumber]
write-host "OZU FormFactor    : $OzuFF"


#$OzuBankCount = $OZU.count
#write-host "OZU Bank Count    : $OzuBankCount"








# $PC = 'wsir-broner'
# Get-WmiObject -Class win32_diskdrive -ComputerName $PC | Select-Object -Property *
$disks = (Get-WmiObject -Class win32_diskdrive -ComputerName $PC).Model
#         Get-WmiObject -Class win32_diskdrive -ComputerName $PC | Format-Table
$j=1
foreach ($disk in $disks){
    #"Disk $j Model      : {0}" -f $disk
    Write-Host "Disk $j Model      : $disk"
    $j++
  }  

$p = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC #| Select-Object -Property *
$i=1
foreach ($comp in $p) {
    #"Disk  Model      : {0}" -f $m
    #"Disk " + $comp.DeviceID + " Size     : {0}" -f $comp.VolumeName + " " + ($comp.Size / 1GB).ToString("F01")
    #"Disk " + $comp.DeviceID + " FreeSpace: {0}" -f $comp.VolumeName + " " + ($comp.FreeSpace / 1GB).ToString("F01")
    
    #$DiskTotalSize = ($comp.Size / 1GB).ToString("F01")
    $DiskTotalSize = [math]::Round($comp.Size / 1073741824)
   #$DiskFreeSpace = ($comp.FreeSpace / 1GB).ToString("F01")
    $DiskFreeSpace = [math]::Round($comp.FreeSpace / 1073741824)
    $DiskLabel = $comp.DeviceID

    #"Disk " + $comp.DeviceID + " Size      : {0}" -f ($comp.Size / 1GB).ToString("F01") + " GB" 
    if ( $DiskTotalSize -le 120 ) {
      Write-Host "Disk $DiskLabel Size      : $DiskTotalSize GB" -ForeGroundColor Red}
    else{
      Write-Host "Disk $DiskLabel Size      : $DiskTotalSize GB"}
    
    
    #"Disk " + $comp.DeviceID + " FreeSpace : {0}" -f ($comp.FreeSpace / 1GB).ToString("F01") + " GB"
    if ( $DiskFreeSpace -le 15 ) {
      Write-Host "Disk $DiskLabel FreeSpace : $DiskFreeSpace GB" -ForeGroundColor Red}
    else{
      Write-Host "Disk $DiskLabel FreeSpace : $DiskFreeSpace GB"}
}


$NoutWithoutSSD = @('HP ProBook 430 G8 Notebook PC')
#if ($PCProperties.Model -match $NoutWithoutSSD) {$FreeSSD = 'НЕТ места под дополнительный SSD'}
 if ($NoutWithoutSSD -match $PCProperties.Model) {
    $FreeSSD = 'НЕТ места под дополнительный SSD'
    Write-Host "Disk For SSD Space: $FreeSSD" -ForeGroundColor Red}
  else {
    $FreeSSD = 'ЕСТЬ место под дополнительный SSD'
    Write-Host "Disk For SSD Space: $FreeSSD"}
#"Disk For SSD Space: {0}" -f $FreeSSD




#$PC = 'wsir-broner'
# enable-psremoting
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
  } #>  function Decode {
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
    <#
    "Display $i Manufac : {0}" -f $Manufacturer
    "Display $i Model   : {0}" -f $Model
    "Display $i s/n     : {0}" -f $Serial #>
    Write-Host "Display $i Manufac : $Manufacturer"
    Write-Host "Display $i Model   : $Model"
    Write-Host "Display $i s/n     : $Serial"
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
  ''
  Write-host "Компьютер $PC недоступен или подключен по VPN" -ForeGroundColor Magenta

  #$PC = 'NBKE-LUKASHOVA'
  #[Environment]::NewLine
  Write-host 'Будет выведена Информация об учётке компьютера из SCCM / GLPI / Spareparts и AD ниже' -ForeGroundColor Magenta
  Write-host 'ВАЖНО: Информация об мониторах в GLPI сохраняется вся по датам их подкючения от нового к старому' -ForeGroundColor RED
  . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\MySQL\DataAdapter\DataAdapter_GLPI_read_v1.2.ps1
  $GLPIread = GlpiRead -Nomination $pc -SearchTarget login
  $GLPIread[1]
  # $GLPIread[1].OSversion
  

  #[Environment]::NewLine
  #Write-host 'Информация об учётке компьютера из AD:' -ForeGroundColor Yellow
  #$GetADpc = Get-ADComputer -Identity 'WSZI-LEADER-08' -properties *
   $GetADpc = Get-ADComputer -Identity $PC -properties *
  #$GetADpc.CN
  #Get-ADComputer -Identity 'WSZI-LEADER-08' -properties CanonicalName,CN,Created,DistinguishedName,dSCorePropagationData,Enabled,instanceType,Modified,modifyTimeStamp,Name,PasswordExpired,PasswordLastSet,whenChanged,whenCreated, OperatingSystem, OperatingSystemVersion
   Get-ADComputer -Identity $PC -properties CanonicalName,CN,Created,DistinguishedName,Enabled,instanceType,Modified,Name,PasswordExpired,PasswordLastSet,whenChanged, OperatingSystem, OperatingSystemVersion

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

<#
$PC = 'wsir-broner'
PCinfo -PC $PC
#$PCinfo = PCinfo -PC $PC
#$PCinfo
#>