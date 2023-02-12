 <#            !!!   R E A D   M E   !!!
 Данный скрипт служит шаблоном для любой популярной выгрузки списка компьютеров
 
 1. Берёт данные из txt-файла (называется как имя скрипта). Для выгрузки всез машин в бранче можно воспользоваться скриптом:
 \\t2ru\folders\IT-Support\Scripts\ADComputers\GetPCbranch.ps1 
 2. В обработке участвует файл:
 \\t2ru\folders\IT-Support\Scripts\ADComputers\PCSubnetBranch.csv
 3. Выкладывает итоговые данные в csv-файл (называется как имя скрипта)

 !!!   Данный скрипт НЕ рекомендуется редактировать  !!! Создавай свою копию под свои нужды!!!
 Или можно закомментировать вывод не нужной информации (с указанием кто и когда закомментировал)
 #>

# Get-ADComputer -Filter {(Enabled -eq $False)} -ResultPageSize 2000 -ResultSetSize $null -Server corp.tele2.ru -Properties Name, OperatingSystem

 [Environment]::NewLine
 [string]$file = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.InvocationName)), `
  ([System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "txt" )))

 # Подписываем столбцы:
   [array]$res = @("Name`tIP`tOSversion`tOSbuildNumber`tManufacturer`tModel`tMemory`tProcessors`tDiskName`tDiskType`tBIOS`tSerialNumber`tBranch`tMacro`tLogin`tFIO`tMobile")
 # [array]$res = @("Name`tIP`tOS`tManufacturer`tModel`tMemory`tProcessors`tDisks`tBIOS`tSerial number`tSQL server")
 # [array]$res = @("Name`tIP")

 # Вариант с автоматическим удалением пустых строк:
 # Get-Content $file | ?{$_.Trim() -ne ""} | %{ 
 # Берём данные, включая пустые строки:
   Get-Content $file | Where-Object{$_ -or $_ -eq ''} | ForEach-Object{
       # Пропускаем имя, если оно такое же, как предыдущее
       if ($_ -ne $PrevPCname -and $_ -notlike "") {   # !!! Вариант с УДАЛЕНИЕМ ПУСТЫХ СТРОК  !!!
     # if ($_ -ne $PrevPCname -and $_ -notlike "") {   # !!! Вариант с ОСТАВЛЕНИЕМ ПУСТЫХ СТРОК  !!! 
           $PrevPCname = $_
           $ip, $OSversion, $OSbuildNumber, $Manufacturer, $Model, $Memory, $Proc, $DiskName, $DiskType, $BIOS, $SerialNumber, $Branch, $Macro, $Login, $FIO, $Mobile = $Null
           $_
           
           
           
           # Если взята пустая строка, то и на выходе добавить пустую строку:
           if ($_ -eq ''){
               [string]$server = ""
               [string]$ip = ""
               [string]$OSversion = ""
               [string]$OSbuildNumber = ""
               [string]$Man = ""
               [string]$Mod = ""
               [string]$Memory = ""
               [string]$Proc = ""
               [string]$DiskName = ""
               [string]$DiskType = ""
               [string]$BIOS = ""
               [string]$Serial = ""
               [string]$Branch = ""
               [string]$Macro = ""
               [string]$Login = ""
               [string]$FIO = ""
               [string]$Mobile = ""
             }
            else {
                   $server = $_.Trim()
                 # $server

                 
                 <# Получение ip-адреса
                  # с DNS-сервера:
                    [string]$ip = [System.Net.Dns]::GetHostEntry($server).addresslist[0].ipaddresstostring
                  # $hostentrydetails = $Null
                  # $hostentrydetails = [System.Net.Dns]::GetHostEntry($server)
                  # [string]$ip = $hostentrydetails.addresslist[0].ipaddresstostring
                  #>
                  
                  
                  
                  # Определение ОС и билда 
                 <# Старое
                     if ($winfo = Get-WmiObject Win32_OperatingSystem -ComputerName $ip -Property "Name,CSDVersion") {
                         [string]$os = $winfo.Name.Split("|")[0].Replace("Microsoft ","").Replace(" Edition","").Trim()
                         if ($winfo.CSDVersion) {
                             $os += " " + $winfo.CSDVersion.Replace("Service Pack ","SP").Trim()
                            }
                        } else {[string]$os = ""}
                  #>
                  # Новое
                     $OSversion = (Get-ADComputer -Identity $server -properties OperatingSystem).OperatingSystem
                     $OSversion
                     $OSbuildNumberSplit = ((Get-ADComputer -Identity $server -properties OperatingSystemVersion).OperatingSystemVersion).split(" ")
                     $OSbuildNumber = $OSbuildNumberSplit[1].trimstart("(").trimEnd(")")
                     $OSbuildNumber
                     
                     
                     
                 <#
                 if ($wcinfo = Get-WmiObject Win32_ComputerSystem -ComputerName $ip -Property "Manufacturer,Model") {
                     [string]$man = $wcinfo.Manufacturer.Trim()
                     [string]$mod = $wcinfo.Model.Trim()
                    } else { [string]$man = ""; [string]$mod = "" }
                #>              
                  


                # ОЗУ
                <#
                if ($minfo = Get-WmiObject Win32_PhysicalMemory -ComputerName $server -Property "Capacity") {
                    [int]$tot = 0
                    [array]$cap = @()
                    $minfo | %{ $tot += $_.Capacity / 1024 / 1024; $cap += ($_.Capacity / 1024 / 1024).ToString() + "Mb" 
                }
                [string]$mem = ($tot / 1024).ToString() + "Gb (" + [string]::join( ", ", $cap ) + ")"
                 } else {[string]$mem = ""}
                 #>

                 $PCProperties = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $server
                 #$MemoryProperties = Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $server
                 #"OZU Total (MB)   : {0}" -F ([math]::round(($PCProperties.TotalPhysicalMemory / 1024 / 1024), 2))
                 #$Memory = ([math]::round(($PCProperties.TotalPhysicalMemory / 1024 / 1024), 0))
                 #$Memory = ([math]::round(($PCProperties.TotalPhysicalMemory / 1024 / 1024), 0))
                 $Memory = [int] ( $PCProperties.TotalPhysicalMemory / 1073741824 )
                 $Memory
                 #>






                 # Определение версии процессора
                 # Запрос напрямую:
                 # $Server = "WSIR-IT-03"
                 $Proc = (Get-WmiObject  -computername  $server -query 'SELECT * FROM Win32_Processor').name # Версия процессора
                 $Proc
                 <#
                 if ($pinfo = Get-WmiObject Win32_Processor -ComputerName $server -Property "Name") {
                     [string]$proc = [string]::join( "`r`n`t", @($pinfo | %{ $_.Name.Trim() }) )
                    } else {[string]$proc = ""}                
                  
                  # Парсинг сайта графаны
                  Invoke-WebRequest -Uri "https://www.ya.ru"
                  $Gragana = Invoke-WebRequest -Uri "http://grafana-usrm.corp.tele2.ru/d/KS9jU12mk/hosts?refresh=10s&orgId=1&from=now-3d&to=now&var-Macroregion=All&var-host=WSVD-GUROV"
                  Invoke-WebRequest -Uri "http://grafana-usrm.corp.tele2.ru/d/KS9jU12mk/hosts?refresh=10s&orgId=1&from=now-3d&to=now&var-Macroregion=All&var-host=WSVD-GUROV" -UseDefaultCredentials
                  -Credential<PSCredential>

                  $Grafana.Content

                  $html = Invoke-WebRequest -Uri "https://example.com"
                  $link = $html.ParsedHtml.getElementsByClassName("Example1")['0'].getAttribute("Example2")
                  $Reply = Invoke-WebRequest -Uri $link
                  Write-Host $Reply

                  $html = Invoke-WebRequest -Uri "http://grafana-usrm.corp.tele2.ru/d/KS9jU12mk/hosts?refresh=10s&orgId=1&from=now-3d&to=now&var-Macroregion=All&var-host=WSVD-GUROV"
                  $link = $html.ParsedHtml.body.getElementsByClassName("singlestat-panel-value-container")['0'].getAttribute("singlestat-panel-value")
                  $Reply = Invoke-WebRequest -Uri $link
                  Write-Host $Reply
                 #>





                    

                #    

                <#
                if ($dinfo = Get-WmiObject Win32_DiskDrive -ComputerName $ip -Property "Model,Size") {
                    [string]$disk = [string]::join( ", ", @($dinfo | %{ ($_.Size / 1024 / 1024 / 1024).ToString("f0") + "Gb (" + $_.Model.Trim() + ")" }) )
                } else {[string]$disk = ""}  
                #>

                <#
                    if ($OS.BuildNumber -like '17763') {$OSVersion2 = '1809 - версия ОС устарела'}
                elseif ($OS.BuildNumber -like '18363') {$OSVersion2 = '1909 - версия ОС устарела'}
                elseif ($OS.BuildNumber -like '19041') {$OSVersion2 = '2004 - версия ОС устарела'}
                elseif ($OS.BuildNumber -like '19042') {$OSVersion2 = '20H2 - версия ОС устарела'}
                elseif ($OS.BuildNumber -like '19043') {$OSVersion2 = '21H1'}
                elseif ($OS.BuildNumber -like '19044') {$OSVersion2 = '21H2'}
                                                  else {$OSVersion2 = 'Не удалось определить'}

                $Server = "wsir-aageenko"
                $Server = "NBIR-ZINATULIN"

                (Get-WmiObject Win32_DiskDrive -ComputerName "WSIR-IT-03").Caption
                (Get-WmiObject Win32_DiskDrive -ComputerName "WSIR-IT-03").Model
                (Get-WmiObject Win32_DiskDrive -ComputerName "WSIR-IT-03").InterfaceType
                Get-WmiObject Win32_DiskDrive -ComputerName "WSIR-IT-03" | Select-Object -Property * 
                Get-WmiObject Win32_DiskDrive -ComputerName "WSIR-IT-03" | Select-Object -Property MediaType

                Invoke-Command -ComputerName "WSIR-IT-03" -ScriptBlock {Get-PhysicalDisk | select @{n='ComputerName';e={$Computer}} FriendlyName,BusType,MediaType}                
                Get-PhysicalDisk | Format-Table -AutoSize DeviceId,Model,MediaType,BusType,Size
                #>

                $DISKS = Get-WmiObject -Class MSFT_PhysicalDisk -ComputerName $Server -Namespace root\Microsoft\Windows\Storage | Select-Object FriendlyName, MediaType
                foreach ($drive in $DISKS) {
                  <#
                  if ($_.mediatype -eq 4) {
                    $DiskName = $_.FriendlyName
                    $DiskName
                    $DiskType = "SSD"
                    $DiskType       
                  }
                  #>
                  if ($drive.mediatype -eq 4) {
                    $DiskName = $drive.FriendlyName
                    $DiskName
                    $DiskType = "SSD или m2"
                    $DiskType
                  }
                  else {
                    $DiskType = "Машина не в сети"
                  } 

              }  
                


                

                <#
                if ($binfo = Get-WmiObject Win32_BIOS -ComputerName $ip -Property "SMBIOSBIOSVersion,ReleaseDate,SerialNumber") {
                    $reldate = $binfo.ReleaseDate.Substring(6,2) + "." + $binfo.ReleaseDate.Substring(4,2) + "." + $binfo.ReleaseDate.Substring(0,4)
                    [string]$bios = $binfo.SMBIOSBIOSVersion.Trim() + " (" + $reldate + ")"
                    [string]$serialNumber = $binfo.SerialNumber.Trim()
                } else {[string]$bios = ""; [string]$serialNumber = ""}
                #>
                
                
                
                <# Что-то связанное с SQL:
                if ($sqlinfo = Get-WmiObject -Namespace "root\Microsoft\SqlServer\ComputerManagement11" -Class "SqlServiceAdvancedProperty" -ComputerName $ip -Filter "PropertyName='SKUNAME'" -Property "ServiceName,PropertyStrValue") {
                    [string]$sqlserv = [string]::join( ", ", @($sqlinfo | %{ $_.ServiceName.Trim() + " - " +$_.PropertyStrValue.Trim() }) )
                 } elseif ($sqlinfo = Get-WmiObject -Namespace "root\Microsoft\SqlServer\ComputerManagement10" -Class "SqlServiceAdvancedProperty" -ComputerName $ip -Filter "PropertyName='SKUNAME'" -Property "ServiceName,PropertyStrValue") {
                     [string]$sqlserv = [string]::join( ", ", @($sqlinfo | %{ $_.ServiceName.Trim() + " - " +$_.PropertyStrValue.Trim() }) )
                    } else {[string]$sqlserv = ""}
                 #>
                 
                 
                 
                 # Определение бранча и макрорегиона:
                  # $Server = "WSIR-IT-03"
                    $DIST = (Get-ADComputer -Identity $server -property DistinguishedName).DistinguishedName
                  # Get-ADComputer -Identity $server | Select-Object -Property *
                  # $DIST = Get-ADComputer -Identity $server | Select-Object -Property DistinguishedName
                    $Branch = [string]$DIST.split(",")[2].trimstart("OU=")
                    $Branch
         
                  # $OSbuildNumberSplit = ((Get-ADComputer -Identity $server -properties OperatingSystemVersion).OperatingSystemVersion).split(" ")
                  # $OSbuildNumber = $OSbuildNumberSplit[1].trimstart("(").trimEnd(")")

                 
                <#
                 $ConName = $Null
                 [string]$PCcut = $server.Substring(0,4)
                 # Файл, с которым будем сравнивать:
                 # Import-CSV -Path "\\t2ru\folders\IT-Support\Scripts\ADComputers\CutPCnameSubnetBranch.csv" -Delimiter ";" -Encoding Default | ForEach-Object {
                   Import-CSV -Path "\\t2ru\folders\IT-Support\Scripts\ADComputers\PCSubnetBranch.csv" -Delimiter ";" -Encoding Default | ForEach-Object {
                       if ($ConName) {}#'Пустой прогон оставшихся подсетей/бранчей
                       else {
                           $PCcutName1 = $_.'Name1'
                           $PCcutName2 = $_.'Name3'
                           $NoutCutName1 = $_.'Name2'
                           $NoutCutName2 = $_.'Name4'
                           [array]$CutNames = $PCcutName1,$PCcutName2,$NoutCutName1,$NoutCutName2
                         # $CutNames = @($PCcutName1,$PCcutName2,$NoutCutName1,$NoutCutName2)
                           $BranchCSV = $_.'Branch'
                           $TownCSV = $_.'Town'
                           $MacroCSV = $_.'Macro'
                           
                           $ConName = Select-String -InputObject $cutnames -Pattern $PCcut   # Ищем ошмёток имени ПК в строке файла
                         # $ConBra = Select-String -InputObject $SplitBranch -Pattern $Branch   # Ищем бранч в двойных брнанчах
                           if ($ConName) {
                               $Branch = $BranchCSV
                               $Branch
                               $Macro = $MacroCSV
                               $Macro
                             }
                        } 
                  }
                  #>




       <# Определение логина:
         $us = Get-WMIObject -Class Win32_ComputerSystem -Computer $_
         $login = $us.Username.split('\')[1]
         $Login
         $LoginProp = Get-ADUser -identity $Login -properties *
       # Опеределение ФИО и должности:
       if ($Login) {
          $FIO = $LoginProp.displayname
          $FIO
          $Mobile = $LoginProp.mobilePhone
          $Mobile
       }
       #>





      [Environment]::NewLine
    # Занесение данных в новую строку таблички:  
      $res += "$server`t$ip`t$OSversion`t$OSbuildNumber`t$man`t$mod`t$Memory`t$Proc`t$DiskName`t$DiskType`t$bios`t$serial`t$Branch`t$Macro`t$Login`t$FIO`t$Mobile"
    # $res += "$server`t$ip`t$os`t$man`t$mod`t$mem`t$Proc`t$disk`t$bios`t$serial"
    # $res += "$server`t$ip"
    # $res += "$server`t$Branch,`t$Macro"
    }
  }
}  

 [string]$resfile = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")    # Результаты запроса
 "Выгрузка данных в '$resfile'"
 Out-File -FilePath $resfile -InputObject $res
 & $resfile