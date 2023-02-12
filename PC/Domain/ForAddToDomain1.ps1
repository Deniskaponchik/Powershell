

# Сначала запускаем только эту одну строку кода (выделить или поставить курсор и F8):
Set-ExecutionPolicy Unrestricted



# Меняем имя Компьютера:
Write-Host  "Введи новое имя для машины, согласно стандартам Теле2: `
(WS или NB) двухбуквенный код региона - фамилия пользователя `
Например: WSRU-Petrov (для рабочей станции) или NBRU-Ivanov-G (для ноутбука)" -ForegroundColor RED
$NamePC = Read-Host "Новое имя вводить сюда"
Rename-Computer -NewName $NamePC
"`n"
Write-Host "Перезагружать компьютер не нужно" -ForegroundColor Green
"`n"


# Меняем тип сетевого подключения:
# Get-NetConnectionProfile
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Отключаем брандмауэр:
Set-NetFirewallProfile -Enabled False

# Включение протокола удаленного рабочего стола:
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
# Выключаем UAC:
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system\' `
-name "LocalAccountTokenFilterPolicy" -PropertyType DWORD -Value 1
# Необязательно:
# Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Открытием порт 5985 и доступ по WMI:
Enable-PSRemoting
# Enable-PSRemoting -Force
# Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any
Set-Service WinRM -startuptype Automatic
# !!! Проверить ещё эту штуку, если по-прежнему будут проблемы с авторизацией команд:
# Set-Item wsman:\localhost\Client\TrustedHosts -value 10.57.179.121

# Добавляем ключ:
Set-Item wsman:\localhost\Client\TrustedHosts -value * -Force

# Messages:
"`n"
Write-Host "Брандмауэр выключен, Уд. рабочий стол включен, Порт VMI открыт" -ForegroundColor Green
Write-Host "Можно отправлять письмо на IT_Support@tele2.ru с информацией:" -ForegroundColor Green
Write-Host "Номер заявки, Логин/пасс админской учётки, ip:" -ForegroundColor Green
# Get-NetIPAddress | Format-Table | Select-Object -Property * | Select IPAddress
Get-NetAdapter | ? status -eq ‘up’ | Get-NetIPAddress -ea 0 | ft ipaddress, AddressFamily
# Get-NetAdapter | Get-NetIpAddress