# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\PC\DelSoftRemoteV0.2.ps1

# while($true){     # Можно зациклить скрипт
write-host "`n"
($PC, $Soft) = $null

# Брать файл csv




# if (Test-Connection -ComputerName $PC -Quiet) 
  if (($c = Read-Host "Имя компьютера или IP-адрес") -ne "") {$PC = $c}
  if (Test-Connection -ComputerName $PC -Quiet) {

   #$PC = 'wsir-it-01'
    Get-WmiObject Win32_Product -ComputerName $PC | Format-Table name,version,vendor,packagename
   #


 # Зацикливание при ошибке
do {
     $Error[0] = $null
     $Soft = Read-Host "Выдели = Скопируй и вставь имя удаляемой программы"
    #(Get-WmiObject Win32_Product -ComputerName $PC -Filter "Name = 'Bitvise SSH Client - FlowSshNet (x64)'").Uninstall()
     (Get-WmiObject Win32_Product -ComputerName $PC -Filter "Name = '$soft'").Uninstall()
 } 
  while ($Error[0] -like 'Невозможно вызвать метод*')


}
#else {"ПК - "+ $PC + " недоступен"}   # }
else {Write-host "Компьютер $PC недоступен" -ForeGroundColor Red}  #}
''
