# проверить, установлены ли компоненты RSAT в вашем компьютере. представить статус установленных компонентов RSAT в более удобной таблице:
# Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property DisplayName, State

# установить сразу все доступные инструменты RSAT:
# Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online

# установить только отсутствующие компоненты RSAT:
# Get-WindowsCapability -Online |? {$_.Name -like "*RSAT*" -and $_.State -eq "NotPresent"} | Add-WindowsCapability -Online



# Если у вас на десктопах с Windows 10 есть доступ в Интернет, но при установке RSAT через Add-WindowsCapability или DISM (DISM.exe /Online /add-capability /CapabilityName:Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0), вы видите ошибку 0x800f0954, значит ваш компьютер настроен на обновление с локального сервера обновлений WSUS при помощи групповой политики.
# Для корректно установки компонентов RSAT в Windows 10 1809+ вы можете временно отключить обновление со WSUS сервера в реестре (HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU параметр UseWUServer = 0) и перезапустить службу обновления.
$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | select -ExpandProperty UseWUServer
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
Restart-Service wuauserv
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $val
Restart-Service wuauserv


