# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\PC\RebootPC.ps1

# Данный скрипт выводит сообщения в отдельно окне, когда сетевое устройство исчезает/появляется в сети

[Environment]::NewLine
# if (($p = Read-Host "Имя компьютера") -ne "") {$PC = "$p"}
$PC = Read-Host "Имя компьютера"

# Необходимо включ. службы WMI в оснастке:
Restart-Computer -ComputerName $PC -Force -ErrorVariable ErrResPC
if (!$ErrResPC) {Write-Host 'Команда отправки в перезагрузку прошла успешно.' -ForegroundColor Green
'Отключение может занять не один десяток минут, если прилетали обновления...'}
else {Write-Host 'Команда отправки в ребут не сработала, но всё равно включена отправка постоянных пингов, если вдруг компьютер ребутнётся...' -ForegroundColor Magenta}

do {$PingOld = (Test-Connection -ComputerName $PC -Quiet)} while ($PingOld -eq $True)
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Устройство отключилось: $PC")

do {$PingOld = (Test-Connection -ComputerName $PC -Quiet)} while ($PingOld -eq $False)
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Устройство $PC появилось в сети")


# От имени другого пользователя:
# Restart-Computer -ComputerName w10-cl02, w10-cl03 -Credential t2ru\admin.ws. -Force

# С задержкой в секундах:
# Start-Sleep -Seconds 60; Restart-Computer -ComputerName w10-cl03 -Force







<# !!!   ВЫКЛЮЧЕНИЕ МАШИНЫ   !!!

[Environment]::NewLine
$PC = Read-Host "Имя компьютера"
Stop-Computer -ComputerName $PC -Force -ErrorVariable ErrShutPC
if (!$ErrResPC) {Write-Host 'Команда отправки в перезагрузку прошла успешно.' -ForegroundColor Green
'Отключение может занять не один десяток минут, если прилетали обновления...'}
else {Write-Host 'Команда отправки в ребут не сработала, но всё равно включена отправка постоянных пингов, если вдруг компьютер ребутнётся...' -ForegroundColor Red}

do {$PingOld = (Test-Connection -ComputerName $PC -Quiet)} while ($PingOld -eq $True)
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Устройство отключилось: $PC")


#>