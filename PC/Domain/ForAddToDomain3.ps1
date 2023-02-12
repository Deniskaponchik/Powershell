
# !!! Сначала запускаем только эту одну строку кода снизу (выделить или поставить курсор и F8)
  Set-ExecutionPolicy Unrestricted

<# Временно отключаю
# Включаем встроенную уч.запись Администратора и задаём пароль :
Enable-LocalUser -Name "Администратор"
$AdminPassword = Read-Host 'Задай пароль локального администратора: Tele2#adm' –AsSecureString
Set-LocalUser -Name "Администратор" -Password $AdminPassword -Verbose
#>

# Меняем тип сетевого подключения:
# Get-NetConnectionProfile
  Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Отключаем брандмауэр:
  Set-NetFirewallProfile -Enabled False

# Включение протокола удаленного рабочего стола:
  Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

# добавим в группу локальных администраторов:
  Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member Администратор –Verbose
  Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member $ENV:Username –Verbose

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

<# Временно отключаю
# Меняем имя Компьютера:
Write-Host  "Введи новое имя для машины, согласно стандартам Теле2: `
(WS или NB) двухбуквенный код региона - фамилия пользователя `
Например: WSRU-Petrov (для рабочей станции) или NBRU-Ivanov (для ноутбука) `
не более 14 символов" -ForegroundColor RED
$NamePC = Read-Host "Новое имя вводить сюда"
Rename-Computer -NewName $NamePC
"`n"
#>

# Проверяем, есть ли такой ПК в домене:
  try {
    [string]$ip = [System.Net.Dns]::GetHostEntry($env:COMPUTERNAME).addresslist[0].ipaddresstostring
    Write-Host "Такое имя ПК есть в домене и его необходимо сменить. Текущее имя ПК:" -ForegroundColor RED
    $env:COMPUTERNAME
    [Environment]::NewLine

    $DomainNameNew = Read-Host "Укажи новое имя ПК"
    Rename-Computer -NewName $DomainNameNew
    Write-Host "Имя компьютера изменено. Через 10 с. он отправится в перезагрузку" -ForegroundColor RED
    Wait-Event -Timeout 10
    Restart-Computer
  }
  catch {
    Write-Host "ПК с имененм $env:COMPUTERNAME в доменен нет"  -ForegroundColor Green
    [Environment]::NewLine
    
    if (($DNN = Read-Host "Укажи новое имя ПК, если желаешь его сменить") -ne "") {
      $DomainNameNew = $DNN
      Rename-Computer -NewName $DomainNameNew
      Write-Host "Имя компьютера изменено. Через 10 с. он отправится в перезагрузку" -ForegroundColor RED
      Wait-Event -Timeout 10
      Restart-Computer    
    }    
  }


# Messages:
"`n"
Write-Host "Брандмауэр выключен, Уд. рабочий стол включен, Порт VMI открыт" -ForegroundColor Green
Write-Host "Можно отправлять письмо на:" -ForegroundColor Green
Write-Host "IT_Support@tele2.ru" -ForegroundColor Green
Write-Host "с информацией:" -ForegroundColor Green
Write-Host "Номер заявки, Логин/пасс админской учётки, ip-адрес, :" -ForegroundColor Green
# Get-NetIPAddress | Format-Table | Select-Object -Property * | Select IPAddress
  Get-NetAdapter | Where-Object status -eq ‘up’ | Get-NetIPAddress -ea 0 | Format-Table ipaddress, AddressFamily
# Get-NetAdapter | Get-NetIpAddress
"`n"

<# Временно отключаю
Write-Host "Скрипт поставлен на паузу на 2 минуты. После этого машина автоматически перезагрузится." -ForegroundColor Red
Wait-Event -Timeout 120
Restart-Computer
#>