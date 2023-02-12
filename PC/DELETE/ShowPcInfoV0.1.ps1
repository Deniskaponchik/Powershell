# \\t2ru\folders\IT-Support\Scripts\ADComputers\ShowPcInfo.ps1

# while($true){     # Можно зациклить скрипт
write-host "`n"

($us,$login,$PC,$c) = $null

#import-module activedirectory
#if (Test-Connection -ComputerName $PC -Quiet) 
if (($c = Read-Host "Имя компьютера или IP-адрес") -ne "") {$PC = $c}
if (Test-Connection -ComputerName $PC -Quiet) {

 $serv = Get-Service -ComputerName $PC | where-object {$_.name -like 'WDP'}
 $serv1 = Get-Service -ComputerName $PC | where-object {$_.name -like 'EDPA'}

 $OS = Get-WmiObject -Class Win32_OperatingSystem -Computername $PC
 $PCProperties = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $PC

 $MemoryProperties = Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $PC
 $proc = Get-WmiObject -computername $PC -query 'SELECT * FROM Win32_Processor'
 
 <# Попытка определить сокет процессора:
 Get-WmiObject -Class Win32_Processor -computername $PC | select *
 (Get-WmiObject -computername $PC -query 'SELECT * FROM Win32_Processor').SocketDesignation
 $proc.SocketDesignation
 $Socket = (get-ciminstance win32_processor -computername $PC).socketdesignation
 #>


 $us = Get-WMIObject -Class Win32_ComputerSystem -Computer $PC
 $login = $us.Username.split('\')[1]
 $sn = Get-WmiObject win32_bios -ComputerName $PC
 $mon = Get-WmiObject WmiMonitorID -computername $PC -Namespace root\wmi
 $p = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC
 $disks = (Get-WmiObject -Class win32_diskdrive -ComputerName $PC).Model
 $i=1
 $j=1
 #$sn=Get-WmiObject -Class Win32_SystemEnclosure -ComputerName $PC
 #$snhp=Get-WmiObject -Class Win32_SystemEnclosure -ComputerName $PC
 #Display free memory on PC/Server
 

# Тип машины
 $ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure -ComputerName $PC).ChassisTypes
 [int[]]$ChaNout = 2,8,9,10,11,12,14,18,21
 [int[]]$ChaMonoblock = 13
 [int[]]$ChaPC = 3,4,5,6,7,15,16
 [int[]]$ChaServ = 17,23
 if ($ChaNout -match $ChassisType) {$TypePC = 'Ноутбук'}
 elseif ($ChaMonoblock -match $ChassisType) {$TypePC = 'Моноблок'}
 elseif ($ChaPC -match $ChassisType) {$TypePC = 'Системный блок'}
 elseif ($ChaServ -match $ChassisType) {$TypePC = 'Сервер'}
 else {$TypePC = 'Не удалось определить'}

# ОЗУ
# Generation
# Get-WmiObject Win32_PhysicalMemory -ComputerName $PC| Select-Object SMBIOSMemoryType
$OZUGen = (Get-WmiObject Win32_PhysicalMemory -ComputerName $PC).SMBIOSMemoryType[0]
 [int[]]$OzuDDR5 = 28
 [int[]]$OzuDDR4 = 26
 [int[]]$OzuDDR3 = 24
 [int[]]$OzuDDR2 = 22
     if ($OzuDDR5 -match $OZUGen) {$FFOzu = 'DDR5'}
 elseif ($OzuDDR4 -match $OZUGen) {$FFOzu = 'DDR4'}
 elseif ($OzuDDR3 -match $OZUGen) {$FFOzu = 'DDR3'}
 elseif ($OzuDDR2 -match $OZUGen) {$FFOzu = 'DDR2'}
 else {$OZUGen = 'Не удалось определить'}

# Form Factor
$OZUFF = (Get-WmiObject Win32_PhysicalMemory -ComputerName $PC).FormFactor[0]
 [int[]]$OzuNout = 12
 [int[]]$OzuPC = 8
 [int[]]$OzuServ = 4
 if ($OzuNout -match $OZUFF) {$FFOzu = 'SODIMM - Ноутбук'}
 elseif ($OzuPC -match $OZUFF) {$FFOzu = 'DIMM - Системный блок'}
 elseif ($OzuServ -match $OZUFF) {$FFOzu = 'Серверная ОЗУ'}
 else {$FFOzu = 'Не удалось определить'}


 "---------PC Parameters----------"
 ""
 "Computer type    : {0}" -f $TypePC
 "System Name      : {0}" -f $OS.csname
 #"User            : {0}" -f $us.Username
 "User             : {0}" -f $login
 #"S/N Lenovo      : {0}" -f $sn.SerialNumber
 #"S/N HP          : {0}" -f $snhp.SMBIOSAssetTag
 "Processor        : {0}" -f $proc.Name
 "Socket           : {0}" -f $proc.Socket
 "Manufacturer     : {0}" -f $PCProperties.Manufacturer
 "Model            : {0}" -f $PCProperties.Model
 "S/N              : {0}" -f $sn.SerialNumber
 "OS Type          : {0}" -f $OS.Caption  + $OS.CSDVersion
 "OS Architect     : {0}" -f $OS.OSArchitecture

 "Service WDP      : {0}" -f $serv.Name  + "  " + $serv.Status
 "Service EDPA     : {0}" -f $serv1.Name  + " " + $serv1.Status

 "OZU Total (MB)   : {0}" -F ([math]::round(($PCProperties.TotalPhysicalMemory / 1024 / 1024), 2))
 "OZU Banks number : {0}" -f $MemoryProperties.Length
 "OZU Generation   : {0}" -f $OZUGen
 "OZU Form Factor  : {0}" -f $FFOzu
 #"Free Memory (MB) : {0}" -f ([math]::round($OS.FreePhysicalMemory / 1024, 2)) # Свободной памяти ОЗУ

 <#
 "Disk  Model      : {0}" -f (Get-WmiObject  -Class win32_diskdrive -ComputerName $PC).Model
 "Disk C Size      : {0}" -f ((Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | ? {$_.DeviceID -eq 'C:'}).Size / 1GB).ToString("F01") 
 "Disk C FreeSpace : {0}" -f ((Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | ? {$_.DeviceID -eq 'C:'}).FreeSpace / 1GB).ToString("F01") 
 "Disk D Size      : {0}" -f ((Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | ? {$_.DeviceID -eq 'D:'}).Size / 1GB).ToString("F01") 
 "Disk D FreeSpace : {0}" -f ((Get-WmiObject -Class Win32_LogicalDisk -ComputerName $PC | ? {$_.DeviceID -eq 'D:'}).FreeSpace / 1GB).ToString("F01") 
 #>
 foreach ($disk in $disks){
    "Disk $j Model     : {0}" -f $disk
    $j++}  

 foreach ($comp in $p) {
    #"Disk  Model      : {0}" -f $m
    #"Disk " + $comp.DeviceID + " Size     : {0}" -f $comp.VolumeName + " " + ($comp.Size / 1GB).ToString("F01")
    #"Disk " + $comp.DeviceID + " FreeSpace: {0}" -f $comp.VolumeName + " " + ($comp.FreeSpace / 1GB).ToString("F01")
    "Disk " + $comp.DeviceID + " Size     : {0}" -f ($comp.Size / 1GB).ToString("F01") + " GB" 
    "Disk " + $comp.DeviceID + " FreeSpace: {0}" -f ($comp.FreeSpace / 1GB).ToString("F01") + " GB" }
 foreach ($monitor in $mon)  {
    $m= ($monitor.ManufacturerName -notmatch 0 | ForEach-Object{[char]$_}) -join "" 
    $u=($monitor.UserFriendlyName -notmatch 0 | ForEach-Object{[char]$_}) -join "" 
    $s=($monitor.SerialNumberID -notmatch 0 | ForEach-Object{[char]$_}) -join "" 
    "Display $i Manufac: {0}" -f $m
    "Display $i Model  : {0}" -f $u
    "Display $i s/n    : {0}" -f $s
    $i++}



  # 'Последние 5 залогинившихся пользователей:'
  $wcusers = "\\$PC\C$\Users\"
  get-ChildItem $wcUsers | Sort-Object -property LastWriteTime, Name -descending | Select-Object -first 5 | Format-Table Name, LastWriteTime

 <#
 if($login) {''
   Set-Clipboard -Value $login
   write-host "Логин пользователя скопирован в буфер обмена. Можешь внести его в поле дальше, чтобы узнать информацию о нём." -ForeGroundColor Magenta
   \\t2ru\folders\IT-Support\Scripts\ADUsers\ShowUser.ps1

 #>
 ''
   if($login) {Set-Clipboard -Value $login
      write-host "Логин пользователя скопирован в буфер обмена. Можешь внести его в поле дальше, чтобы узнать информацию о нём." -ForeGroundColor Magenta}
   else{write-host "Логин пользователя не был вычислен. Если нашёл его другими способами, то можешь внести его в поле дальше, чтобы узнать информацию о нём." -ForeGroundColor Magenta}
   \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Users\ShowUserV0.1.ps1

}
#else {"ПК - "+ $PC + " недоступен"}   # }
else {Write-host "Компьютер $PC недоступен" -ForeGroundColor Red}  #}
''

Write-host 'Информация об учётке компьютера в AD:' -ForeGroundColor Yellow
Get-ADComputer -Identity $PC -properties CanonicalName,CN,Created,DistinguishedName,dSCorePropagationData,Enabled,instanceType,isCriticalSystemObject,Modified,modifyTimeStamp,Name,PasswordExpired,PasswordLastSet,whenChanged,whenCreated
