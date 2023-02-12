# \\t2ru\folders\IT-Support\Scripts\ADComputers\AddPcToDomainV0.10.ps1

[Environment]::NewLine
# Если бы bpm позвоял, то открывалась бы страница с тикетом заявки:
# $sr = Read-Host "Номер тикета в bpm"
# Start-Process -FilePath Chrome -ArgumentList "https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/$sr"

# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
  $DomainNameNew, $DomainName, $ChassisType, $WrongName = $null


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

  do {
    $ip = Read-Host "IP-адрес машины"
  } while ($ip -eq '')
# $ip = Read-Host "IP-адрес машины"    # $ip.trim()

if (Test-Connection -ComputerName $ip -Quiet) {    
    Write-Host "Запрос прав локального администратора компьютера (5 попыток ввода)" -ForegroundColor Red
    [Environment]::NewLine
    $x = 5

    # Избавиться в будущем от использования $Error[0] с помощью try/catch или -ErrorVariable
    # Сбор информации о машине: 
    do { 
        # $Error[0] = $Null
        $x = $x - 1
        $LocalCred = Get-Credential #"Администратор" - если бы все активировали встроенную учётку администратора или использовали одинаковое имя пользователя, то можно было бы ускорить
        $OS = Get-WmiObject -Class Win32_OperatingSystem -Computername $ip -Credential $LocalCred -ErrorVariable ErrorLocCred
    # } while ($Error[0] -like '*Отказано в доступе*' -or $Error[0] -like '*Сервер RPC недоступен*' -and $x -gt 0)  # -or $Error[0] -like '*Сервер RPC недоступен*'
    } while ($ErrorLocCred -like '*Отказано в доступе*' -or $ErrorLocCred -like '*Сервер RPC недоступен*' -and $x -gt 0)

    # if ($Error[0] -like '*Не удается привязать аргумент*' -or $x -eq 0) {
      if ($ErrorLocCred -like '*Не удается привязать аргумент*' -or $x -eq 0) {
        exit  # Завершение скрипта после 2 неудачных попыток и если нажать НЕТ
    }

    [Environment]::NewLine
    # OS не соответсвующие стандарту
    if (($OS.Caption  + $OS.CSDVersion) -like '*Windows 7*') {
        Write-Host "Windows 7 в домен не вводим!!!" -ForegroundColor Red
        exit
    }
    elseif (($OS.Caption  + $OS.CSDVersion) -like '*Windows 10 Корп*') {
        Write-Host "Windows 10 Корпоративная считается устаревшей. Необходимо обновить систему до Windows 10 Pro" -ForegroundColor Red `n
        Pause
    }


    
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



    # Вывод информации о версии ОС и имени машины:
    "Текущая ОС на компьютере                        :{0}" -f $OS.Caption  + $OS.CSDVersion
    "Текущее имя машины                              :{0}" -f $OS.csname

    # Проверка на существование машины в домене:
    try {  
        $PCexis = Get-ADComputer -Identity $OS.csname
        # Get-ADComputer -Identity wsir-it-03 -ErrorVariable ErrorGetADComp
        # $ErrorGetADComp
        Write-Host  'Учётка ПК есть в домене. Далее будет предложено создать новое имя машины. После проверки его необходимо будет прописать на самой машине' -ForegroundColor Red
    }
    catch {
        Write-Host  'Машины с таким именем в доменен нет.' -ForegroundColor Green
        $PcNOTexis = 1
        #$DomainName = $OS.csname
        
        $PCexis = Read-Host "Напиши 1, если всё-таки желаешь сменить имя машины"
        #if ($QuChName -ne '') {
        #     $PCexis
        #   }
    }


    # Процесс создания и проверки нового имени машины:

    <# Old process
    if ($CheckPCexis) {Write-Host  'Учётка ПК есть в домене. Далее будет предложено создать новое имя машины. После првоерки его необходимо будет прописать на самой машине' -ForegroundColor Red}
    if (($DNN = Read-Host "Укажи новое имя машины") -ne "") {$DomainNameNew = $DNN}
    # Проверка имени на соответствие стандартам Теле2 + Существания в домене
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
    } #>




    

   # Следущий код выполняется независимо от того, найдена ли учётка в домене:
   do { 
       if ($PCexis -or $WrongName){      # 'TEST'}
           $PCexis, $PcNOTexis, $WrongName = $Null
           $DomainNameNew = Read-Host "Укажи новое имя машины (максимум 15 символов)    "
           #$DomainNameNew  = $Null
           #if ($DomainNameNew -and ($DomainNameNew -like '')){'1'}
           #else {'2'}
           try {
               $PCexis = Get-ADComputer -Identity $DomainNameNew
               Write-Host  "$DomainNameNew - есть в домене." -ForegroundColor Red
            } 
           catch {
                 $PcNOTexis = 1
               # Новое имя переносим в переменную не нового имени. В дальнейшем команда на смену имени при вводе не будет задействована.
                 $DomainName = $DomainNameNew

            }
        }     

       # Если учётки в домене нет и первоначально заданное имя полностью соответсвует стандарту
       # if ($PcNOTexis -and !$DomainNameNew -and (($OS.csname -like "nb*" -and ($OS.csname).Length -le 15) -or ($OS.csname -like "ws*" -and ($OS.csname).Length -le 15) -or $Error[0] -like '*Не удается*')) {
       # Регулярочка:
         if ($PcNOTexis -and !$DomainNameNew -and ($OS.csname -match "[wn][sb]..-.\B" -and ($OS.csname).Length -le 15)) {
            $DomainName = $OS.csname
            "В домен можно добавлять машину с текущим именем :{0}" -f $DomainName

            }

       <#  $PcName = "nbus-rgewyyhtb"
           if ($PcName -match "[wn][sb]..-.\B") {$Reg = 1}
           else {$reg = $Null}
           $Reg
           #>

        # Сотрудник IT Support указал новое имя машины и оно полностью соответсвует стандарту и его нет в домене
        # elseif ($PcNOTexis -and (($DomainNameNew -like "nb*" -and $DomainNameNew.Length -le 15) -or ($DomainNameNew -like "ws*" -and $DomainNameNew.Length -le 15) -or $Error[0] -like '*Не удается*')) {
        # Регуляроча:
          elseif ($PcNOTexis -and ($DomainNameNew -match "[wn][sb]..-.\B" -and $DomainNameNew.Length -le 15)) {
            "В домен можно добавлять машину с новым именем    : {0}" -f $DomainNameNew
            }
        # Несоответсвие стандарту или есть в домене
          else {
            "Текущее имя не подходит                          :{0}" -f $OS.csname
            $WrongName = 1        
          }
     } while (($DomainNameNew -and ($DomainNameNew -like '')) -or $PCexis -or $WrongName)
       
       # Если установленное приходящим инженером имя не подходит и мы сгенерировали новое, то отправить письмо инженеру на место событий:
       $txtTOengineer = 'Добрый день.','', 'Необходимо сменить имя компьютера на:', $DomainName, "Перезагрузить компьютер", "Сообщить по результату проведённых действий"
       if ($DomainNameNew) {
           Set-Clipboard -Value $txtTOengineer
           Write-Host  'Текст письма для инженера тех. поддержки скопирован в буфер обмена' -ForegroundColor Magenta
           Write-Host  'Дождись ответного письма, что имя изменено и компьютер перезагружен. Только после этого продолжай скрипт.' -ForegroundColor Red
           # Ждём, пока инженер не отпишется, что сменил имя и перезагрузил машину:
           pause
        }
       $DomainNameNew = $Null


    <# Удаление учётки из домена не лучший вариант. Предпочтительнее создавать новую. Отключаю до лучших времён.
    Write-Host "Проверка и удаление старой учётки компьютера из домена, если такая имелась" -ForegroundColor Red `n
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
    elseif ($Cut -like 'wsrh' -or $Cut -like 'nbrh' -or $Cut -like 'wskh' -or $Cut -like 'nbkh') { $b = 'Khabarovsk'}
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
    elseif ($Cut -like 'wssa' -or $Cut -like 'nbsa') { $b = 'Samara'}
    elseif ($Cut -like 'wssn' -or $Cut -like 'nbsn') { $b = 'Saransk'}
    elseif ($Cut -like 'wsta' -or $Cut -like 'nbta') { $b = 'Tambov'}
    elseif ($Cut -like 'wsto' -or $Cut -like 'nbto') { $b = 'Tomsk'}
    elseif ($Cut -like 'wstl' -or $Cut -like 'nbtl') { $b = 'Tula'}
    elseif ($Cut -like 'wstv' -or $Cut -like 'nbtv') { $b = 'Tver'}
    elseif ($Cut -like 'wsuu' -or $Cut -like 'nbuu') { $b = 'Ulan-Ude'}
    elseif ($Cut -like 'wsul' -or $Cut -like 'nbul') { $b = 'Ulyanovsk'}
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
    "Он отправляется в перезагрузку..."
    "Можешь дождаться сообщения об успешном вводе в домен (не обязательно)"


    [Environment]::NewLine
    if ($TypePC -like 'Ноутбук') {
        write-host "!!! ЗАВЕДИ обращение на включение Bitlocker !!!" -ForegroundColor Red
        # Start-Process chrome -ArgumentList 'https://bro.tele2.ru/create-bid/126E5AB8-276F-48E8-AE13-E14EAF6A1604' -wait # -passthru
        # Start-Process chrome -ArgumentList 'https://bro.tele2.ru/create-bid/126E5AB8-276F-48E8-AE13-E14EAF6A1604' -LoadUserProfile
        Set-Clipboard -Value 'https://bro.tele2.ru/create-bid/126E5AB8-276F-48E8-AE13-E14EAF6A1604'
        write-host "Ссылка в bro на создание заявки на Битлокер скопирована в буфер" -ForegroundColor Green
        Pause                                
        Set-Clipboard -Value $DomainName
        write-host "имя компьютера скопировано в буфер обмена" -ForegroundColor Green
        Pause

        $Comment = 'Добрый день.', '', 'Компьютер добавлен в домен.', 'Заведено обращение на включение Bitlocker', '', ''
        Set-Clipboard -Value $Comment
        write-host "Текст письма для инженера IBS скопирован в буфер" -ForegroundColor Green
        }
    else {
        $Comment = 'Добрый день.', '', 'Компьютер добавлен в домен.', '', ''
        Set-Clipboard -Value $Comment
        write-host "Текст письма для инженера IBS скопирован в буфер" -ForegroundColor Green
        Wait-Event -Timeout 20
    }   
    

    [Environment]::NewLine
    do {$PingOld = (Test-Connection -ComputerName $DomainName -Quiet)} while ($PingOld -eq $False)
    write-host "Компьютер $DomainName успешно добавлен в домен!" -ForegroundColor Green
    [Environment]::NewLine
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