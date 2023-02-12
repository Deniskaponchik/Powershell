
# while($true){     # Можно зациклить скрипт
write-host "`n"

($PC, $Soft) = $null

# if (Test-Connection -ComputerName $PC -Quiet) 
  if (($c = Read-Host "Имя компьютера или IP-адрес") -ne "") {$PC = $c}
  if (Test-Connection -ComputerName $PC -Quiet) {

   #$PC = 'wsir-it-01'
    Get-WmiObject Win32_Product -ComputerName $PC | Format-Table name,version,vendor,packagename

    $Soft = Read-Host "Скопируй и вставь имя удаляемой программы"
   #(Get-WmiObject Win32_Product -ComputerName $PC -Filter "Name = 'Bitvise SSH Client - FlowSshNet (x64)'").Uninstall()
    (Get-WmiObject Win32_Product -ComputerName $PC -Filter "Name = '$soft'").Uninstall()



}
#else {"ПК - "+ $PC + " недоступен"}   # }
else {Write-host "Компьютер $PC недоступен" -ForeGroundColor Red}  #}
''
