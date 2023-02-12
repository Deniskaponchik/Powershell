# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\PC\DelSoftRemoteV0.3.ps1

# while($true){     # Можно зациклить скрипт
  write-host "`n"
  $PC, $Soft = $null

# Брать список машин из файла csv

# if (Test-Connection -ComputerName $PC -Quiet) 
  if (($c = Read-Host "Имя компьютера или IP-адрес") -ne "") {$PC = $c}
  if (Test-Connection -ComputerName $PC -Quiet) {
# $PC = 'wsir-it-01'    $PC = 'wsru-nikolaev'


# Список ПО через WMI:
  #Get-WmiObject -Class Win32_Product | Format-Table name,vendor
   Get-WmiObject -Class Win32_Product -ComputerName $PC | Format-Table name,version,vendor,packagename
  #Get-WmiObject -Class Win32_Product -ComputerName $PC | Format-Table name,version,vendor,packagename

# Брать список удаляемого ПО из файла csv:

# Список ПО в виде переменных:
  $Soft1 = 'Adobe Flash Player 32 PPAPI'
  $Soft2 = 'Adobe Flash Player 32 NPAPI'

<# Список ПО из реестра
  Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName | Sort-Object DisplayName
  Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select DisplayName | Sort DisplayName
#>




 # Удаление
do {    # Зацикливание при ошибке получения программы
     $Error[0] = $null
     $Soft = Read-Host "Выдели = Скопируй и вставь имя удаляемой программы"
    # 
    #(Get-WmiObject -Class Win32_Product -ComputerName $PC -Filter "Name = 'Bitvise SSH Client - FlowSshNet (x64)'").Uninstall()
     (Get-WmiObject -Class Win32_Product -ComputerName $PC -Filter "Name = '$soft'").Uninstall()
    #(Get-WmiObject -Class Win32_Product -ComputerName $PC -Filter "Name = '$soft1'").Uninstall()
    #(Get-WmiObject -Class Win32_Product -ComputerName $PC -Filter "Name = '$soft2'").Uninstall()

   <# MsiExec Реестр
     (Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object{ $_.DisplayName -like "*TeamViewer*" }).PSChildName | ForEach-Object { msiexec.exe /x $_ /qn }
     (Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object{ $_.DisplayName -like "Adobe Flash Player 32 PPAPI" }).PSChildName | ForEach-Object { msiexec.exe /x $_ }
     (Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object{ $_.DisplayName -like "Cisco AnyConnect Secure Mobility Client" }).PSChildName | ForEach-Object { msiexec.exe /x $_ }
     (Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object{ $_.DisplayName -like "*Any*" }).PSChildName | ForEach-Object { msiexec.exe /x $_ }
     msiexec.exe /x 'Cisco AnyConnect Secure Mobility Client'

     Invoke-Command -ComputerName AD1 -ScriptBlock {Get-ChildItem 'HKCU:\Control Panel\Accessibility\' -Include "*mouse*" -Recurse}
     Invoke-Command -ComputerName wsir-it-01 -ScriptBlock {Get-ChildItem 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' -Recurse}
    #>
 } 
  while ($Error[0] -like 'Невозможно вызвать метод*')

<# WMIC
# Находим процесс по имени программы в имени пути к ней
  wmic /node:CompName process where "ExecutablePath like '%ByteFuse 1.6.6%'" get Description /format:list
  wmic /node:'wsru-nikolaev' process where "ExecutablePath like '%ByteFuse 1.6.6%'" get Description /format:list
  wmic /node:'wsru-nikolaev' process get Description
  wmic /node:'wsru-nikolaev' OS get Caption
 
# Завершаем нужный процесс
  wmic /node:CompName process where "ExecutablePath like '%7-zip%'" delete

# Ищем имя нужной программы в полном списке
  wmic /node:CompName product get name
  wmic /node:'wsru-nikolaev' product get name

# Просмотр сведений по конкретной установке программы
  wmic /node:CompName product where "name like '%7-zip%'" list brief
  wmic /node:'wsir-it-01' product where "name like '%Adobe%'" list brief

# Выполняем удаленную деинсталляцию пакета
  wmic /node:CompName product where "name like '%7-zip%'" call uninstall /nointeractive
  wmic /node:'wsru-nikolaev' product where "name like '%Adobe Flash Player 32 PPAPI%'" call uninstall /nointeractive
  wmic /node:'wsir-it-01' product where "name like '%Adobe Flash Player 32 PPAPI%'" call uninstall /nointeractive
  wmic /node:'wsir-it-01' product where "name like '%Google Earth Pro%'" call uninstall /nointeractive
#>




Write-Host "ожешь убедиться, что программа была удалена успешно" -ForegroundColor Green
Get-WmiObject Win32_Product -ComputerName $PC | Format-Table name,version,vendor,packagename
}
else {Write-host "Компьютер $PC недоступен" -ForeGroundColor Red}  #}
''