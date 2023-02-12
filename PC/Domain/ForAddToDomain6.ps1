
# !!! Сначала запускаем только эту одну строку кода снизу (выделить или поставить курсор и F8)
  try {
    Set-ExecutionPolicy Unrestricted
  }
  catch {
    'Политика выполнения PS-скриптов включена'
  }
  [Environment]::NewLine
 
# Open Device Manger
  devmgmt.msc
  
# Проверка ОС на соответсвие требованиям компании:
  $OS = Get-WmiObject -Class Win32_OperatingSystem
  $os.caption
  $OS.BuildNumber
# $OS = (Get-WmiObject -Class Win32_OperatingSystem).caption 


    if ($OS.caption -like '*Windows 7*') {
    Write-Host "Windows 7 в домен не вводим!!!" -ForegroundColor Red
    exit}
  elseif ($OS.caption -like '*Windows 10 Корп*') {
    Write-Host "Windows 10 Корпоративная считается устаревшей. Необходимо обновить систему до Windows 10 Pro" -ForegroundColor Red `n
    Pause}
  #else {Write-Host "Версия Windows соответствует требованияем компании" -ForegroundColor Green `n}
  # https://docs.microsoft.com/en-us/windows/release-health/release-information
      if ($OS.BuildNumber -like '17763') {Write-Host '1809 - версия ОС устарела' -ForegroundColor Red}
  elseif ($OS.BuildNumber -like '18362') {Write-Host '1903 - версия ОС устарела' -ForegroundColor Red}
  elseif ($OS.BuildNumber -like '18363') {Write-Host '1909 - версия ОС устарела' -ForegroundColor Red}
  elseif ($OS.BuildNumber -like '19041') {Write-Host '2004 - версия ОС устарела' -ForegroundColor Red}
  elseif ($OS.BuildNumber -like '19042') {Write-Host '20H2 - версия ОС устарела' -ForegroundColor Red}
  elseif ($OS.BuildNumber -like '19043') {Write-Host '21H1' -ForegroundColor Green}
  elseif ($OS.BuildNumber -like '19044') {Write-Host '21H1' -ForegroundColor Green}
  elseif ($OS.BuildNumber -like '22000') {Write-Host '21H2' -ForegroundColor Green}
    else {'Не удалось определить версию OS'}
    [Environment]::NewLine

# Меняем тип сетевого подключения:
# Get-NetConnectionProfile
  Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Отключаем брандмауэр:
  Set-NetFirewallProfile -Enabled False

# Включение протокола удаленного рабочего стола:
  Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

<# Временно отключаю
# Включаем встроенную уч.запись Администратора и задаём пароль :
Enable-LocalUser -Name "Администратор"
$AdminPassword = Read-Host 'Задай пароль локального администратора: Tele2#adm' –AsSecureString
Set-LocalUser -Name "Администратор" -Password $AdminPassword -Verbose
#>
# добавим в группу локальных администраторов:

# Добавим в Пользователи удалённого рабочего стола
  try {
    Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member Администратор –Verbose
  }
  catch {
    'Администратор уже добавлен в пользователи удалённого рабочего стола'
  }
  
  try {
    Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member $ENV:Username –Verbose
  }
  catch {
    "$ENV:Username уже добавлен в пользователи удалённого рабочего стола"
  }
  

# Выключаем UAC:
  try {
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system\' -name "LocalAccountTokenFilterPolicy" -PropertyType DWORD -Value 1
  }
  catch {
    'UAC уже выключен'
  }
  
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
  
# Отключаем спящий режим:
  powercfg -x standby-timeout-ac 0

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



 # Закладываем номера для типов машин $ChaType -> Опрашиваем и Получаем $ChassisType -> Сравниваем и выводим итоговую $TypePC
   $ChaNout = 2,8,9,10,11,12,14,18,21
   $ChaPC = 3,4,5,6,7,15,16
   $ChaServ = 17,23
#  $ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure -ComputerName $ip -Credential $LocalCred).ChassisTypes
   $ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure).ChassisTypes


          if ($ChaNout -match "\b$ChassisType\b") {$TypePC = 'Ноутбук'}
 elseif ($ChaMonoblock -match "\b$ChassisType\b") {$TypePC = 'Моноблок'}
        elseif ($ChaPC -match "\b$ChassisType\b") {$TypePC = 'Системный блок'}
      elseif ($ChaServ -match "\b$ChassisType\b") {$TypePC = 'Сервер'}
                                             else {$TypePC = 'Не удалось определить'}
 <#
 if ($ChaNout -Match $ChassisType)     {$TypePC = 'Ноутбук'}
 elseif ($ChaPC -match $ChassisType)   {$TypePC = 'Системный блок'}
 elseif ($ChaServ -match $ChassisType) {$TypePC = 'Сервер'}
 else                                  {$TypePC = 'Не удалось определить тип устройства'}
 #>
 $TypePC
 [Environment]::NewLine



# Messages:
"`n"
Write-Host "Брандмауэр выключен, Уд. рабочий стол включен, Порт VMI открыт" -ForegroundColor Green
Write-Host "Можно отправлять письмо на:" -ForegroundColor Green
Write-Host "IT_Support@tele2.ru" -ForegroundColor Green
Write-Host "с информацией:" -ForegroundColor Green
Write-Host "Номер заявки, Логин/пасс админской учётки, ip-адрес" -ForegroundColor Green
# Get-NetIPAddress | Format-Table | Select-Object -Property * | Select IPAddress
  Get-NetAdapter | Where-Object status -eq ‘up’ | Get-NetIPAddress -ea 0 | Format-Table ipaddress, AddressFamily
# Get-NetAdapter | Get-NetIpAddress
  $env:COMPUTERNAME



# Функция для смены имени машины
function RenamePC {
  Rename-Computer -NewName $DomainNameNew
  Write-Host "Имя компьютера изменено. Через 10 с. он отправится в перезагрузку" -ForegroundColor RED
  Wait-Event -Timeout 10
  Restart-Computer -Force
  }

[Environment]::NewLine
# Проверяем, есть ли такой ПК в домене:
Write-Host "Далее необходимо дождаться ответного письма, что учётки ПК с таким именем в домене нет и он успешно введён. Если же такое имя уже в домене присутсвует, то в ответном письме придёт НОВОЕ имя ПК, которое необходимо задать в поле ниже" -ForegroundColor RED


# если первоначально заданного именив домене не было, то смотрим его корректность и предлагаем сменить в случае чего:
  do {
    $DNN = Read-Host "Укажи новое имя ПК, если желаешь его сменить"
  # } while (($DNN -like '') -or ($DNN -notlike 'ws*')  -or ($DNN -notlike 'nb*')) {
    } while (($DNN -like '') -or ($DNN -notmatch "[wn][sb]..-.\B" -and $DNN.Length -le 15))
    $DomainNameNew = $DNN
    RenamePC
    

[Environment]::NewLine
