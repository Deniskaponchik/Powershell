# Скрипт на локальном принт-сервере добавляет КАЖДОМУ устройству
# учётку service.ast с правами Manage this printer, Manage documents

# внутренняя функция, которая преобразовывает числовой код возврата операции записи ACL
# в текстовое значение.
function _PrinterUtils_Get-Code ($Write) {
    switch ($Write.ReturnValue) {
        "0" {"Success"}
        "2" {"Access Denied"}
        "8" {"Unknown Error"}
        "9" {"The user does not have adequate privileges to execute the method"}
        "21" {"A parameter specified in the method call is invalid"}
        default {"Unknown error $Write.ReturnValue"}
    }
}

# функция получения списка (списков) ACL принтера или всех принтеров
function Get-Printer ($Computer = ".", $name) {
    # Если переменная $name пустая, то возвращается список всех локальных принтеров
    if ($name) {
        $Printers = gwmi Win32_Printer -ComputerName $Computer -Filter "name = '$name'"
    } else {
        $Printers = gwmi Win32_Printer -ComputerName $Computer -Filter "local = '$True'"
    }
    # объявление массива списков ACL
    $PrinterInfo = @()
    # извлечение списка ACL из каждого элемента массива списков ACL
    foreach ($Printer in $Printers) {
        if ($printer) {
            # в переменную $SD получаем дескриптор безопасности для каждого принтера и каждый элемент ACE (DACL)
            # и добавляем в $PrinterInfo
            $SD = $Printer.GetSecurityDescriptor()
            $PrinterInfo += $SD.Descriptor.DACL | %{
                $_ | Select @{e = {$Printer.SystemName}; n = 'Computer'},
                @{e = {$Printer.name}; n = 'Name'},
                AccessMask,
                AceFlags,
                AceType,
                @{e = {$_.trustee.Name}; n = 'User'},
                @{e = {$_.trustee.Domain}; n = 'Domain'},
                @{e = {$_.trustee.SIDString}; n = 'SID'}
            }
        } else {
            Write-Warning "Specified printer not found!"
        }
    }
    # выдача сведений об ACL на выход функции для последующей подачи на конвейер
    $PrinterInfo
}

# функция записи в ACL принтера. Она не принимает никаких аргументов,
# а только принимает данные с конвейера
function Set-Printer {
    # по конвейеру получаем массив ACE из внешнего источника
    $PrinterInfo = @($Input)
    # расшиваем полученный массив по имени принтера и дальше по циклу подаём на
    # обработку только ACL одного принтера
    $PrinterInfo | Select -Unique Computer, Name | % {
        $Computer = $_.Computer
        $name = $_.name
        # создаём новые объекты необходимых классов
        $SD = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance()
        $ace = ([WMIClass] "Win32_Ace").CreateInstance()
        $Trustee = ([WMIClass] "Win32_Trustee").CreateInstance()
        # теперь расшиваем каждый ACE уже отфильтрованного списка ACL из PrinterInfo и
        # заполняем форму SecurityDescriptor
        $PrinterInfo | ? {$_.Computer -eq $Computer -and $_.name -eq $name} | % {
            $SID = new-object security.principal.securityidentifier($_.SID)
            [byte[]] $SIDArray = ,0 * $SID.BinaryLength
            $SID.GetBinaryForm($SIDArray,0)
            $Trustee.Name = $_.user
            $Trustee.SID = $SIDArray
            $ace.AccessMask = $_.AccessMask
            $ace.AceType = $_.AceType
            $ace.AceFlags = $_.AceFlags
            $ace.trustee = $Trustee
            # набор ACE поэтапно добавляем в DACL дескриптора безопасности
            $SD.DACL += @($ace.psobject.baseobject)
            # устанавливаем флаг SE_DACL_PRESENT, что будет говорить о том, что мы изменяем
            # только DACL и ничего более
            $SD.ControlFlags = 0x0004
        }
        # когда полный список ACL для текущего принтера собран, выбираем имя текущего принтера
        $Printer = gwmi Win32_Printer -ComputerName $Computer -Filter "name = '$name'"
        # проверяется, что принтер для записи ACL найден и производится запись.
        # В противном случае запись ACL пропускается
        if ($Printer) {
            $Write = $Printer.SetSecurityDescriptor($SD)
            Write-Host "Processing current printer: $name"
            _PrinterUtils_Get-Code $Write
        } else {
            Write-Warning "Skipping non-present printer: $name"
        }
    }
}

# внутренняя функция, которая только формирует объект пользователя с набором прав
# и возвращает объект в вызывающую функцию для последующих преобразований
function _Create-SDObject ( $user, $AceType, $AccessMask) {
    # преобразование текстового вида прав в числовые значения
    $masks = @{ManagePrinters = 983052; ManageDocuments = 983088; Print = 131080;
        TakeOwnership = 524288; ReadPermissions = 131072; ChangePermissions = 262144}
    $types = @{Allow = 0; Deny = 1}
    # создание необходимых свойств для объекта. Для поддержки удалённого управления
    # было добавлено свойство Computer, которое будет принимать от Get-Printer аналогичное
    # значение. Тем самым обеспечивается сквозная трансляция имени компьютера, где
    # подключен принтер, по конвейеру для последующей записи
    $AddInfo = New-Object System.Management.Automation.PSObject
    $AddInfo | Add-Member NoteProperty Computer ([PSObject]$null)
    $AddInfo | Add-Member NoteProperty Name ([PSObject]$null)
    $AddInfo | Add-Member NoteProperty AccessMask ([uint32]$null)
    $AddInfo | Add-Member NoteProperty AceFlags ([uint32]$null)
    $AddInfo | Add-Member NoteProperty AceType ([uint32]$null)
    $AddInfo | Add-Member NoteProperty User ([PSObject]$null)
    $AddInfo | Add-Member NoteProperty Domain ([PSObject]$null)
    $AddInfo | Add-Member NoteProperty SID ([PSObject]$null)
    # заполнение объекта данными, которые были указаны в качестве аргументов вызова функции и возврат
    # объекта в вызывающую функцию
    $AddInfo.Name = $name
    $AddInfo.User = $user
    $AddInfo.SID = (new-object security.principal.ntaccount $user).translate([security.principal.securityidentifier])
    $AddInfo.AccessMask = $masks.$AccessMask
    $AddInfo.AceType = $types.$AceType
    if ($masks.$AccessMask -eq 983088) {$AddInfo.AceFlags = 9}
    $AddInfo
}

# функция для установки разрешений на принтер. При её использовании, текущий ACL очищается
# от всех записей и устанавливается только один ползователь/группа с правом ManagePrinters
function Set-PrinterPermission ($user) {
    # принимаются данные с конвейера
    $PrinterInfo = @($Input)
    $AddInfo = _Create-SDObject $user Allow ManagePrinters
    # в этом цикле перебираются по именам все имена принтеров и для каждого из них
    # записывается указанный в аргументах пользователь с удалением текущих ACE из ACL принтера
    # это видно по тому, что никакая часть $PrinterInfo не передаётся по конвейеру на запись
    foreach ($Printer in ($PrinterInfo | select -Unique Computer, Name)) {
        $AddInfo.Computer = $Printer.Computer
        $AddInfo.Name = $Printer.name
        $AddInfo | Set-Printer
    }
}

# функция добавления пользователя/группу в имеющийся список ACL принтера. Основное отличие от
# предыдущего варианта, что для каждого принтера ACE не устанавливается, а добавляется
function Add-PrinterPermission ($user, $AceType, $AccessMask) {
    $PrinterInfo = @($Input)
    $AddInfo = _Create-SDObject $user $AceType $AccessMask
    foreach ($Printer in ($PrinterInfo | select -Unique Computer, Name)) {
        $AddInfo.Name = $Printer.name
        $AddInfo.Computer = $Printer.Computer
        # вот этой строкой мы из списка всех принтеров итеративно перебираем каждый принтер
        $PrinterInfoNew = $PrinterInfo | ?{$_.name -eq $Printer.name}
        # и в хвост списка ACL добавляем новый ACE
        $PrinterInfoNew += $AddInfo
        # и подаём на запись
        $PrinterInfoNew | Set-Printer
    }
}

# функция для удаления ACE пользователя/группы из ACL
function Remove-PrinterPermission ($user) {
    $Printers = @($Input)
    # просто берём списки ACL, которые пришли по конвейеру и выкидываем оттуда все ACE,
    # в которых фигурирует указанный в аргументах пользователь/группа и записывем ACE обратно в ACL
    $printers | ? {$_.user -ne $user} | Set-Printer
}

function New-NetworkPrinter ($Computer, $name) {
    ([wmiclass]'Win32_Printer').AddPrinterConnection("\\$Computer\$name")
}

function Remove-NetworkPrinter ($name) {
    if ($name) {
        (gwmi Win32_Printer -Filter "sharename='$name'").delete()
    } else {
        (gwmi Win32_Printer -Filter "local='$false'").delete()
    }
}

function Set-DefaultPrinter ($name) {
    if (!$name) {
        Write-Warning "You must to specify printer name. Operation aborted!"
    } else {
        if (gwmi win32_Printer -Filter "name='$name'") {
            $SetDefault = (gwmi win32_Printer -Filter "name='$name'").SetDefaultPrinter()
            switch ($SetDefault.ReturnValue) {
                "0" {Write-Host "Now your default printer is $name"}
                default {Write-Warning "Some error occur"}
            }
        } else {
            Write-Warning "Specified printer not exist!"
        }
    }
}

function Get-PrinterInfo ($Computer = ".", $name) {
    # здесь я предлагаю получить как полный набор свойств, так и упрощённый вывод сведений. 
    if ($name) {
        gwmi Win32_Printer -ComputerName $Computer -Filter "name='$name'" | select *
    } else {
        gwmi Win32_Printer -ComputerName $Computer
    }
}

function New-PrinterShare ($Computer = ".", $name, $ShareName) {
    $Printer = gwmi win32_Printer -ComputerName $Computer -Filter "name='$name'"
    if ($Printer) {
        $Printer.shared = $True
        $Printer.ShareName = $ShareName
        $Printer.put()
    } else {
        Write-Warning "Specified printer not exist!"
    }
}

function Remove-PrinterShare ($Computer = ".", $name) {
    if ($name) {
        $filter = "name = '$name'"
    } else {
        $filter = "local = '$false'"
    }
    gwmi Win32_Printer -ComputerName $Computer -Filter $filter | % {
        $_.shared = $false
        $_.put()
    }
}

# Без выборки по именам:
  Get-Printer | Add-PrinterPermission Service.Ast Allow ManagePrinters
  Get-Printer | Add-PrinterPermission Service.Ast Allow ManageDocuments

# Выборка по имени:
# Get-Printer | Where-Object Name -notlike '*Shadow' | Add-PrinterPermission Service.Ast Allow ManagePrinters
# Get-Printer | Where-Object Name -notlike '*Shadow' | Add-PrinterPermission Service.Ast Allow ManageDocuments
# или:
# Get-Printer | Where-Object (Name -notlike '*Shadow' -and Name -notlike '*tech') | Add-PrinterPermission Service.Ast Allow ManagePrinters
# Get-Printer | Where-Object (Name -notlike '*Shadow' -and Name -notlike '*tech') | Add-PrinterPermission Service.Ast Allow ManageDocuments
# или (не работает):
# $Dep = 'tech', 'razv', 'dir', 'ener', 'shadow'
# Get-Printer | Where-Object Name -notcontains $Dep | Add-PrinterPermission Service.Ast Allow ManagePrinters
# Get-Printer | Where-Object Name -notcontains $Dep | Add-PrinterPermission Service.Ast Allow ManageDocuments
# или (не работает):
# $Dep = 'tech', 'razv', 'dir', 'ener', 'shadow'
# Get-Printer | Where-Object $Dep -notcontains Name | Add-PrinterPermission Service.Ast Allow ManagePrinters
# Get-Printer | Where-Object $Dep -notcontains Name | Add-PrinterPermission Service.Ast Allow ManageDocuments

# Выполнение на удалённом хосте:
# Get-Printer -ComputerName t2zi-fps-01 | Add-PrinterPermission Service.Ast Allow ManagePrinters
# Get-Printer -ComputerName t2zi-fps-01 | Add-PrinterPermission Service.Ast Allow ManagePrinters
