# \\t2ru\folders\IT-Support\Scripts\ADComputers\AddPcToDomainV0.10.ps1

[Environment]::NewLine
# $sr = Read-Host "Номер тикета в bpm"
# Start-Process -FilePath Chrome -ArgumentList "https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/$sr"

# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
$SmallCityName, $DomainNameNew, $DomainName, $ChassisType, $Checkip, $Error[0] = $null
$Error[0] = 0


# Логирование:
  $dl = Get-Date -Format "dd.MM HH.mm.ss"
# $dl

# $PSScriptRoot   # текущая директория, из которой был запущен скрипт
# $PSCommandPath  #  полный путь и имя файла скрипта
# $MyInvocation.MyCommand.Path  # содержит полный путь и имя скрипта
# $MyInvocation.MyCommand.Name  # имя файла
  $ScriptName= $MyInvocation.MyCommand.Name   # имя файла

  $LogName = "$dl $Env:Username $ScriptName"
# $LogName = "$Env:Username $ScriptName"
# $LogName 

# Out-File -FilePath "$PSScriptRoot\logs" -InputObject $res
# Out-File -FilePath "$PSScriptRoot\logs\$dl_$Username_$MyInvocation.MyCommand.Name.txt"
# Out-File -FilePath $PSScriptRoot\logs\$dl_$Username_$MyInvocation.MyCommand.Name.txt

  $NewItem = New-Item -Name "$LogName.txt" -Path "$PSScriptRoot\logs"
# $NewItem = New-Item -Name "$LogName.txt" -Path "$PSScriptRoot\logs" -Value "Этот текст будет внутри созданного файла"



$ip = Read-Host "IP-адрес машины"    # $ip.trim()

if (Test-Connection -ComputerName $ip -Quiet) {    
    Write-Host "Запрос прав локального администратора компьютера (5 попыток ввода)" -ForegroundColor Red
    [Environment]::NewLine
    [int]$x = 5

    do { # Проверка на Windows 7:
        $Error[0] = $Null
        $x = $x - 1
        $LocalCred = Get-Credential #"Администратор" -
        $OS = Get-WmiObject -Class Win32_OperatingSystem -Computername $ip -Credential $LocalCred
    } while ($Error[0] -like '*Отказано в доступе*' -or $Error[0] -like '*Сервер RPC недоступен*' -and $x -gt 0) # -or $Error[0] -like '*Сервер RPC недоступен*'
    if ($Error[0] -like '*Не удается привязать аргумент*' -or $x -eq 0) {
        exit  # Завершение скрипта после 2 неудачных попыток и если нажать НЕТ
    }
    [Environment]::NewLine
    <# OS не соответсвующие стандарту
    if (($OS.Caption  + $OS.CSDVersion) -like '*Windows 7*') 
    {Write-Host "Windows 7 в домен не вводим!!!" -ForegroundColor Red
    exit}
    elseif (($OS.Caption  + $OS.CSDVersion) -like '*Windows 10 Корп*') {
    Write-Host "Для Windows 10 Корпоративная в компании нет лицензий. Необходимо обновить систему до Windows 10 Pro" -ForegroundColor Red `n
    Pause} 
    #>

    "Текущая ОС на компьютере                        :{0}" -f $OS.Caption  + $OS.CSDVersion
    "Текущее имя машины                              :{0}" -f $OS.csname

    try {  # Проверка на существование машины в домене
        # [string]$Checkip = [System.Net.Dns]::GetHostEntry($OS.csname).addresslist[0].ipaddresstostring
          $CheckPCexis = Get-ADComputer -Identity $OS.csname
    }
    catch {
        Write-Host  'Машины с таким именем в доменен нет.' -ForegroundColor Green
    }
    if ($Checkip) {
        Write-Host  'Учётка ПК есть в домене. Предпочтительнее сменить имя' -ForegroundColor Red
    }
    # $DomainNameNew = Read-Host "Укажи новое имя машины, если желаешь его сменить"
    if (($DNN = Read-Host "Укажи новое имя машины, если желаешь его сменить") -ne "") {$DomainNameNew = $DNN}

    
    # Проверка имени на соответствие стандартам Теле2
    # do {   # Зациклить удаление, если ПК есть в домене и необходимо переименовать новый, но не удалять старый
    # if (($OS.csname -like "nb*" -and ($OS.csname).Length -le 15) -or ($OS.csname -like "ws*" -and ($OS.csname).Length -le 15) -or $Error[0] -like '*Не удается*')
    if (!$DomainNameNew -and(($OS.csname -like "nb*" -and ($OS.csname).Length -le 15) -or ($OS.csname -like "ws*" -and ($OS.csname).Length -le 15) -or $Error[0] -like '*Не удается*')) {  # Оставлено имя машины, указанное инженером первой линии
        $DomainName = $OS.csname
        "В домен будет добавлена машина                  :{0}" -f $DomainName
    }
    elseif (($DomainNameNew -like "nb*" -and $DomainNameNew.Length -le 15) -or ($DomainNameNew -like "ws*" -and $DomainNameNew.Length -le 15) -or $Error[0] -like '*Не удается*') {  # Указал новое имя машины
        "В домен будет добавлен компьютер                : {0}" -f $DomainNameNew
    }
    else {
        "Текущее имя не соответствует стандарту Теле2   :{0}" -f $OS.csname
        do {
            $DomainNameNew = Read-Host "Новое доменное имя (максимум 15 символов)      " 
        } while ($DomainNameNew.Length -ge 16)  # }while ($Error[0] -like '*Не удается*')
    }



    Write-Host "Проверка и удаление старой учётки компьютера из домена, если такая имелась" -ForegroundColor Red `n
    #
    try {
        if (!$DomainName) {
            Remove-ADComputer -Identity $DomainNameNew
        }
        else {
            Remove-ADComputer -Identity $DomainName
        }
    }
    catch {
        Write-Host  "Машины с таким именем в доменен нет." -ForegroundColor Green
    } #>
    <#
    Remove-ADComputer -Identity $DomainNameNew
    Remove-ADComputer -Identity $DomainName
    #>
    [Environment]::NewLine
    $Des = Read-Host "Укажи описание, если желаешь"

    
    # Закладываем номера для типов машин $ChaType -> Опрашиваем и Получаем $ChassisType -> Сравниваем и выводим итоговую $TypePC
    $ChaNout = 2,8,9,10,11,12,14,18,21
    $ChaPC = 3,4,5,6,7,15,16
    $ChaServ = 17,23
    $ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure -ComputerName $ip -Credential $LocalCred).ChassisTypes

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
    

    if ($Null -eq $DomainNameNew) {$Cut = $DomainName.Substring(0,4)}  # $DomainNameNew -eq $null
    else                          {$Cut = $DomainNameNew.Substring(0,4)}
    <#
    Switch ($Cut)    { 
    {like 'wsab' -or like 'nbab'} {$b = 'Abakan'; break} 
    {like 'wsar' -or like 'nbar'} {$b = 'Arkhangelsk'}
    default  {$b = Read-Host "Бранч не найден. Введи вручную"}}
    #>
        if ($Cut -like 'wsab' -or $Cut -like 'nbab') { $b = 'Abakan'}
    elseif ($Cut -like 'wsar' -or $Cut -like 'nbar') { $b = 'Arkhangelsk'}
    elseif ($Cut -like 'wsbn' -or $Cut -like 'nbbn') { $b = 'Barnaul'}
    elseif ($Cut -like 'wsbe' -or $Cut -like 'nbbe') { $b = 'Belgorod'}
    elseif ($Cut -like 'wsbb' -or $Cut -like 'nbbb') { $b = 'Birobidzhan'}
    elseif ($Cut -like 'wsbr' -or $Cut -like 'nbbr') { $b = 'Bryansk'}
    elseif ($Cut -like 'wsch' -or $Cut -like 'nbch') { $b = 'Chelyabinsk'}
    elseif ($Cut -like 'wscb' -or $Cut -like 'nbcb') { $b = 'Cheboksary'}
    elseif ($Cut -like 'wsek' -or $Cut -like 'nbek') { $b = 'Ekaterinburg'}
    elseif ($Cut -like 'wsir' -or $Cut -like 'nbir') { $b = 'IRKUTSK'}
    elseif ($Cut -like 'wsiv' -or $Cut -like 'nbiv') { $b = 'Ivanovo'}
    elseif ($Cut -like 'wsiz' -or $Cut -like 'nbiz') { $b = 'Izhevsk'}
    elseif ($Cut -like 'wskg' -or $Cut -like 'nbkg') { $b = 'Kaliningrad'}
    elseif ($Cut -like 'wska' -or $Cut -like 'nbka') { $b = 'Kaluga'}
    elseif ($Cut -like 'wskz' -or $Cut -like 'nbkz') { $b = 'Kazan'}
    elseif ($Cut -like 'wske' -or $Cut -like 'nbke' -or $Cut -like 'wsnk' -or $Cut -like 'nbnk') { $b = 'Kemerovo'}
    elseif ($Cut -like 'wsrh' -or $Cut -like 'nbrh') { $b = 'Khabarovsk'}
    elseif ($Cut -like 'wsha' -or $Cut -like 'nbha') { $b = 'Khanty-Mansiysk'}
    elseif ($Cut -like 'wski' -or $Cut -like 'nbki') { $b = 'Kirov'}
    elseif ($Cut -like 'wsks' -or $Cut -like 'nbks') { $b = 'Kostroma'}
    elseif ($Cut -like 'wskr' -or $Cut -like 'nbkr') { $b = 'Krasnodar'}
    elseif ($Cut -like 'wsky' -or $Cut -like 'nbky') { $b = 'Krasnoyarsk'}
    elseif ($Cut -like 'wskn' -or $Cut -like 'nbkn') { $b = 'Kurgan'}
    elseif ($Cut -like 'wsku' -or $Cut -like 'nbku') { $b = 'Kursk'}
    elseif ($Cut -like 'wskl' -or $Cut -like 'nbkl') { $b = 'Kyzyl'}
    elseif ($Cut -like 'wsli' -or $Cut -like 'nbli') { $b = 'Lipetsk'}
    elseif ($Cut -like 'wsmd' -or $Cut -like 'nbmd') { $b = 'Magadan'}
    elseif ($Cut -like 'wsms' -or $Cut -like 'nbms') { $b = 'Moscow'}
    elseif ($Cut -like 'wsmo' -or $Cut -like 'nbmo') { $b = 'Moscow-MCC'}
    elseif ($Cut -like 'wsmu' -or $Cut -like 'nbmu') { $b = 'Murmansk'}
    elseif ($Cut -like 'wsrn' -or $Cut -like 'nbrn' -or $Cut -like 'nbnn' -or $Cut -like 'wsnn') { $b = 'Nizhniy NOVGOROD'}
    elseif ($Cut -like 'wsns' -or $Cut -like 'nbns' -or $Cut -like 'nbrs' -or $Cut -like 'wsrs') { $b = 'Novosibirsk'}
    elseif ($Cut -like 'wsom' -or $Cut -like 'nbom') { $b = 'Omsk'}
    elseif ($Cut -like 'wsor' -or $Cut -like 'nbor') { $b = 'Orenburg'}
    elseif ($Cut -like 'wsor' -or $Cut -like 'nbor') { $b = 'Oryol'}
    elseif ($Cut -like 'wspn' -or $Cut -like 'nbpn') { $b = 'Penza'}
    elseif ($Cut -like 'wspr' -or $Cut -like 'nbpr') { $b = 'Perm'}
    elseif ($Cut -like 'wspp' -or $Cut -like 'nbpp') { $b = 'Petropavlovsk-Kamchatsky'}
    elseif ($Cut -like 'wspt' -or $Cut -like 'nbpt') { $b = 'Petrozavodsk'}
    elseif ($Cut -like 'wsps' -or $Cut -like 'nbps') { $b = 'Pskov'}
    elseif ($Cut -like 'wsrp' -or $Cut -like 'nbrp' -or $Cut -like 'nbsp' -or $Cut -like 'wssp') { $b = 'Saint-Petersburg'}
    elseif ($Cut -like 'wsta' -or $Cut -like 'nbta') { $b = 'Tambov'}
    elseif ($Cut -like 'wsto' -or $Cut -like 'nbto') { $b = 'Tomsk'}
    elseif ($Cut -like 'wstl' -or $Cut -like 'nbtl') { $b = 'Tula'}
    elseif ($Cut -like 'wstv' -or $Cut -like 'nbtv') { $b = 'Tver'}
    elseif ($Cut -like 'wsuu' -or $Cut -like 'nbuu') { $b = 'Ulan-Ude'}
    elseif ($Cut -like 'wsuf' -or $Cut -like 'nbuf') { $b = 'Ufa'}
    elseif ($Cut -like 'wsus' -or $Cut -like 'nbus') { $b = 'Yuzhno-Sakhalinsk'}
    elseif ($Cut -like 'wsvn' -or $Cut -like 'nbvn') { $b = 'Veliky Novgorod'}
    elseif ($Cut -like 'wsvk' -or $Cut -like 'nbvk') { $b = 'Vladivostok'}
    elseif ($Cut -like 'wsva' -or $Cut -like 'nbva') { $b = 'Vologda'}
    elseif ($Cut -like 'wssh' -or $Cut -like 'nbsh') { $b = 'Salekhard'}
    elseif ($Cut -like 'wsyr' -or $Cut -like 'nbyr') { $b = 'Yaroslavl'}
    else   {$b = Read-Host "Бранч не найден. Введи вручную"}
    $ldap_path = "OU=Computers,OU=$b,OU=Branches,DC=corp,DC=tele2,DC=ru"
    $b
    [Environment]::NewLine
    
    $Error[0] = $null
    do {
        # $DomainCred -eq $Null
        # if ($Null -eq $DomainCred -or $Error[0] -like '*Не удается проверить аргумент*' -or $Error[0] -like '*Не удалось присоединить компьютер*') {
        if ($Null -eq $AdmWSDomCred -or $ErrAdd) {
            Write-Host "Запрос прав администратора домена..." -ForegroundColor Red
            $AdmWSDomCred = Get-Credential "t2ru\admin.ws.tirskikh" -ErrorVariable Otmena
            if ($Error[0] -like '*Не удается привязать аргумент к параметру*') {
                exit   # Остановка скрипта при нажатии Отмена
            }
        }
        #($Error[0]) = $null # Пережиток прошлого, когда возврат был на основании $Error[0]
        if ($null -ne $DomainNameNew) {
            # с изменением имени
            New-AdComputer -Name $DomainNameNew -SamAccountName $DomainName -Description $Des -Credential $AdmWSDomCred -Path $ldap_path  # Избавляет от некоторых ошибок
            Add-Computer -DomainName 'corp.tele2.ru' -OUPath $ldap_path -ComputerName $ip -LocalCredential $LocalCred -NewName $DomainNameNew -Restart -Force -Credential $AdmWSDomCred -ErrorVariable ErrAdd
        }
        else {
            # БЕЗ изменения имени:
            New-AdComputer -Name $DomainName -SamAccountName $DomainName -Description $Des -Credential $AdmWSDomCred -Path $ldap_path   # Избавляет от некоторых ошибок
            Add-Computer -DomainName 'corp.tele2.ru' -OUPath $ldap_path -ComputerName $ip -LocalCredential $LocalCred -Restart -Credential $AdmWSDomCred -Force -ErrorVariable ErrAdd
            # New-AdComputer -Name $DomainName -SamAccountName $DomainName -Credential $AdmWSDomCred -Path $ldap_path
        }
    }
    while ($ErrAdd)
    # while ($ErrAdd -like ('*Не удается проверить аргумент*','*Не удалось присоединить компьютер*','*Отказано в доступе*','*он уже входит*'))   # И ТАК ТОЖЕ НЕ РАБОТАЕТ
    # while (('*Не удается проверить аргумент*','*Не удалось присоединить компьютер*','*Отказано в доступе*','*он уже входит*') -like $ErrAdd)  # НЕ РАБОТАЕТ ТАК
    # while ($Error[0] -like '*Не удается проверить аргумент*' -or $Error[0] -like '*Не удалось присоединить компьютер*' -or $Error[0] -like '*Отказано в доступе*')
    # Не удалось присоединить компьютер
    
    [Environment]::NewLine
    if ($Null -ne $DomainNameNew) {$DomainName = $DomainNameNew}   # Переигровка переменных
    write-host "Операция добавления в домен с компьютером $DomainName прошла успешно" -ForegroundColor Green
    # write-host "Он отправляется в перезагрузку..." -ForegroundColor Green
    "Он отправляется в перезагрузку..."
    # write-host "Можешь дождаться сообщения об успешном вводе в домен (не обязательно)" -ForegroundColor Green
    "Можешь дождаться сообщения об успешном вводе в домен (не обязательно)" 
    Wait-Event -Timeout 20
    
    do {$PingOld = (Test-Connection -ComputerName $DomainName -Quiet)} while ($PingOld -eq $False)
    "`n"
    write-host "Компьютер $DomainName успешно добавлен в домен!" -ForegroundColor Green
    "`n"
}

else { # Если ПК недоступен
    Write-Host ""
    Write-Host "Уд. рабочему столу не удалось подключиться к компьютеру  $ip  по одной из след. причин:" -ForegroundColor Red
    Write-Host "* Не включен удаленный доступ" -ForegroundColor Red
    Write-Host "* Включен брандмауэр" -ForegroundColor Red
    Write-Host "* Компьютер находится в спящем режиме" -ForegroundColor Red
    Write-Host "Подсказка. Запустите скрипт:" -ForegroundColor Green
    Write-Host "\\t2ru\folders\IT-Outsource\Scripts,поправки\PowerShell\ForAddToDomain.ps1" -ForegroundColor Green
}