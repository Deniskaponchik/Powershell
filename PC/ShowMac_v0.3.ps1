write-host "`n"

#Задаём функцию транслитерации:
    function TranslitPC ([string]$inString) {
      $Translit = @{    
      #Создаём хеш-таблицу соответствия символов
      #[char]':' = ""
      #[char]'-' = ""
      #[char]'=' = " "
      [char]'A' = "a"
      [char]'B' = "b"
      [char]'C' = "c"
      [char]'D' = "d"
      [char]'E' = "e"
      [char]'F' = "f"
      [char]'G' = "g"
      [char]'H' = "h"
      [char]'I' = "i"
      [char]'J' = "j"
      [char]'K' = "k"
      [char]'L' = "l"
      [char]'M' = "m"
      [char]'N' = "n"
      [char]'O' = "o"
      [char]'P' = "p"
      [char]'Q' = "q"
      [char]'R' = "r"
      [char]'S' = "s"
      [char]'T' = "t"
      [char]'U' = "u"
      [char]'V' = "v"
      [char]'W' = "w"
      [char]'X' = "x"
      [char]'Y' = "y"
      [char]'Z' = "z"
      }
      $TranslitText = ""
      foreach ($CHR in $inCHR = $inString.ToCharArray()) {
          if ($Null -cne $Translit[$CHR]){
              $TranslitText += $Translit[$CHR]   #аналог записи $TranslitText = $TranslitText + $Translit[$CHR] 
           } 
          else {
              $TranslitText += $CHR   #аналог записи $TranslitText = $TranslitText + $CHR
          }  
       }
      return $TranslitText
  }  
  # Транслитерация:
  # Translit $mac
  # $MacTransl = Translit $MAC_Address  # Это было рабочее
  # $MacTransl
  
  # $mac4 = $mac2 -replace "@{macaddress ", ""
  # $MacTransl2=(($MacTransl1.replace("@{macaddress ","")).replace("}",""))   # Обрезание концов
  # $MacTransl2
 

$MAC_Address = $Null
if (($m = Read-Host "Имя компьютера или IP-адрес") -ne "") {$PC = $m}
[Environment]::NewLine


if (Test-Connection -ComputerName $PC -Quiet) {
    # Проще всего получить мак с доступного в сПК. Пробуем, проверяем:
    # $FullNetConf = Get-WmiObject -ComputerName $PC -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=True -ErrorVariable ErrNotPc -ErrorAction SilentlyContinue  |  Select-Object -Property * | Select-Object PSComputerName, @{Name="IPAddress";Expression={$_.IPAddress.get(0)}}, MACAddress, Description
      $FullNetConf = Get-WmiObject -ComputerName $PC -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=True -ErrorVariable ErrNotPc -ErrorAction SilentlyContinue


        if ($ErrNotPc -like '*Сервер RPC недоступен*') {
            # 'Устройство - не компьютер. Будет предпринята попытка получения мака с DHCP-серверов.'
        }
        elseif ($ErrNotPc) {
            'Не описанная ранее ошибка'
        }
        else {
              #$FullNetConf
              foreach ($switch in $FullNetConf){
                $switch
                $MAC_Address = $switch.MACAddress.replace(':', '-') #Получим мак-адрес формата: XX-XX-XX-XX-XX-XX
                "MAC-address      : {0}" -f $MAC_Address 
                [Environment]::NewLine
              }
              [Environment]::NewLine
              if($FullNetConf.count -gt 1){
                #Write-Host 'Выдели нужный тебе мак-адрес и вставь в поле ниже:' -ForegroundColor Red
                $MAC_Address = Read-Host "Выдели нужный тебе мак-адрес и вставь сюда"
                $MacTransl = TranslitPC $MAC_Address
                [array]$Split_Add = $MacTransl -split "-"
              }

            <# v0.2
              $MAC_Address = $FullNetConf.MACAddress
              $MAC_Address
              $MacTransl = TranslitPC $MAC_Address
            # $MacTransl
              [array]$Split_Add = $MacTransl -split ":"
              #>
        }
}

[Environment]::NewLine
# Если устройство не ПК или недоступно:
if (!$MAC_Address) {    #Если устройство не Windows или не доступно
    Write-Host 'Устройство не Windows-машина ИЛИ недоступно. Будет предпринята попытка получения мака с DHCP-серверов.' -ForegroundColor Red
    <#
    $DHCP_Servers = @{
        DHCP_Server1 = 't2rs-fps-01.corp.tele2.ru';
        DHCP_Server2 = 't2rn-fps-01.corp.tele2.ru';
        DHCP_Server3 = 't2ru-prn-01.corp.tele2.ru';
        DHCP_Server4 = 't2rp-fps-01.corp.tele2.ru';
        DHCP_Server5 = 't2rm-fps-01.corp.tele2.ru';
        DHCP_Server6 = 't2re-fps-01.corp.tele2.ru';
        DHCP_Server7 = 't2zr-fclr-01.corp.tele2.ru';
        DHCP_Server8 = 't2zc-fps-02.corp.tele2.ru';
    } #>
    $DHCP_Servers = 't2ru-dhcp-01.corp.tele2.ru', 't2rs-fps-01.corp.tele2.ru', 't2re-fps-01.corp.tele2.ru', 't2pp-fps-01.corp.tele2.ru', 't2md-fps-01.corp.tele2.ru', 't2bb-fps-01.corp.tele2.ru', 't2rn-fps-01.corp.tele2.ru', 't2rp-fps-01.corp.tele2.ru', 't2rm-fps-01.corp.tele2.ru' #'t2zr-fclr-01.corp.tele2.ru','t2zc-fps-02.corp.tele2.ru'
    <#
    $DHCP_Servers = 't2ru-dhcp-01.corp.tele2.ru',
                    't2rs-fps-01.corp.tele2.ru', 
                    't2re-fps-01.corp.tele2.ru', 
                    't2pp-fps-01.corp.tele2.ru', 
                    't2md-fps-01.corp.tele2.ru', 
                    't2bb-fps-01.corp.tele2.ru', 
                    't2rn-fps-01.corp.tele2.ru', 
                    't2rp-fps-01.corp.tele2.ru', 
                    't2rm-fps-01.corp.tele2.ru' 
                    #'t2zr-fclr-01.corp.tele2.ru',
                    #'t2zc-fps-02.corp.tele2.ru'
                    #>

    #$DHCP_Servers          
    # $PC = 'wsir-broner'
    # $PC = '10.88.179.33'
    # if (($m = Read-Host "Имя компьютера или IP-адрес") -ne "") {$PC = $m}
    $Split_Add = $Null
    if ($PC -notlike '1*') {        
        <#
        # Если не указан Ip в явном виде, то получаем его из DNS:
          $DNS_Resolution = $Null
          $DNS_Resolution = resolve-dnsname -name $PC
        # if ($DNS_Resolution -eq $Null) {Exit} # Останавливать скрипт, если нет записи на DNS
          $ip = $DNS_Resolution.IPAddress
        #>        
        foreach ($DHCP_Server in $DHCP_Servers) {
            if (!$Split_Add) {
              # $IP = '10.88.179.7'
              # $DHCP_Server = 't2rs-fps-01.corp.tele2.ru'
              # DHCP_Server = 't2md-fps-01.corp.tele2.ru'
                $DHCP_Server
                $DHCP_Leases = Get-DhcpServerv4Scope -computername $DHCP_Server | Get-DhcpServerv4Lease -computername $DHCP_Server
                $Host_Info = $DHCP_Leases | Where-Object HostName -like "$PC*"
                if ($Host_Info -notlike '') {
                  # $IPAddress = $Host_Info.IPAddress
                    $MAC_Address = $Host_Info.ClientId
                    Write-Host "$MAC_Address" -ForegroundColor Green
                    [array]$Split_Add = $MAC_Address -split "-"
                    [Environment]::NewLine
                  }
             }
         }
    }

    else {
        foreach ($DHCP_Server in $DHCP_Servers) {
            if (!$Split_Add) {
              # $IP = '10.88.179.7'
              # $DHCP_Server = 't2rs-fps-01.corp.tele2.ru'
              # $DHCP_Server = 't2md-fps-01.corp.tele2.ru'
                $DHCP_Server
                $DHCP_Leases = Get-DhcpServerv4Scope -computername $DHCP_Server | Get-DhcpServerv4Lease -computername $DHCP_Server
                $Host_Info = $DHCP_Leases | Where-Object IPAddress -eq $PC
                if ($Host_Info -notlike '') {
                  # $IPAddress = $Host_Info.IPAddress
                    $MAC_Address = $Host_Info.ClientId
                    Write-Host "$MAC_Address" -ForegroundColor Green
                    [array]$Split_Add = $MAC_Address -split "-"
                    [Environment]::NewLine
                }  
            }
         }
    }
}

# Заканчиваем скрипт, если мак таи не обнаружился:
if (!$MAC_Address) {
  Write-Host "Mac-адрес определить не удалось" -ForegroundColor Red
  Exit
}


# elseif ($MAC_Address) {


[Environment]::NewLine
#[array]$Split_Add = $MacTransl -split ":"

Write-Host "0. Скопировать как есть" -ForegroundColor Green
# [string]$JoinAddCisco2 = 'Show mac address-table | i ' + $Split_Add[0] + $Split_Add[1] + '.' + $Split_Add[2] + $Split_Add[3] + '.' + $Split_Add[4] + $Split_Add[5]

Write-Host "1. Cisco 2 layer" -ForegroundColor Cyan
[string]$JoinAddCisco2 = 'Show mac address-table | i ' + $Split_Add[0] + $Split_Add[1] + '.' + $Split_Add[2] + $Split_Add[3] + '.' + $Split_Add[4] + $Split_Add[5]

Write-Host "2. Cisco 3 layer" -ForegroundColor Cyan
[string]$JoinAddCisco3 = 'Show arp | i ' + $Split_Add[0] + $Split_Add[1] + '.' + $Split_Add[2] + $Split_Add[3] + '.' + $Split_Add[4] + $Split_Add[5]


Write-Host "3. Hp 2 layer" -ForegroundColor Magenta
[string]$JoinAddHp2 = 'Show mac-address ' + $Split_Add[0] + $Split_Add[1] + $Split_Add[2] + '-' + $Split_Add[3] + $Split_Add[4] + $Split_Add[5]

Write-Host "4. Hp 3 layer" -ForegroundColor Magenta
[string]$JoinAddHp3 = 'Show mac-address ' + $Split_Add[0] + $Split_Add[1] + '.' + $Split_Add[2] + $Split_Add[3] + '.' + $Split_Add[4] + $Split_Add[5]


Write-Host "5. 3Com 2 layer" -ForegroundColor Yellow
[string]$JoinAdd3com2 = 'display mac-address ' + $Split_Add[0] + $Split_Add[1] + '-' + $Split_Add[2] + $Split_Add[3] + '-' + $Split_Add[4] + $Split_Add[5]

Write-Host "6. 3Com 3 layer" -ForegroundColor Yellow
[string]$JoinAdd3com3 = 'display mac-address ' + $Split_Add[0] + $Split_Add[1] + '-' + $Split_Add[2] + $Split_Add[3] + '-' + $Split_Add[4] + $Split_Add[5]


Write-Host "7. bpm Услуга: Резервирование IP адреса" -ForegroundColor Cyan
#[string]$JoinAddHuawei2 = 'display mac-address ' + $Split_Add[0] + $Split_Add[1] + '-' + $Split_Add[2] + $Split_Add[3] + '-' + $Split_Add[4] + $Split_Add[5]
[string]$JoinAddBPM1 = $MAC_Address

Write-Host "8. bpm Услуга: Проверка MAC-адреса перед установкой ОС" -ForegroundColor Cyan
[string]$JoinAddBPM2 = $MAC_Address.replace('-', ':')


[Environment]::NewLine
# "Укажи вариант сохранения мак-адреса в буфер обмена."
$Choice = Read-Host "Укажи вариант сохранения мак-адреса в буфер обмена"

Switch ($Choice) {
     0{
      Set-Clipboard -Value $MAC_Address
      Write-Host "$MAC_Address" -ForegroundColor Yellow}
    #1{ClearBrowser}
    #1{Set-Clipboard -Value $PCName}
     1{[Environment]::NewLine
       Set-Clipboard -Value $JoinAddCisco2
       Write-Host "$JoinAddCisco2" -ForegroundColor Yellow}
     2{[Environment]::NewLine
       Set-Clipboard -Value $JoinAddCisco3
      Write-Host "$JoinAddCisco3" -ForegroundColor Yellow}
     3{[Environment]::NewLine
       Set-Clipboard -Value $JoinAddHp2
      Write-Host "$JoinAddHp2" -ForegroundColor Yellow}
     4{[Environment]::NewLine
       Set-Clipboard -Value $JoinAddHp3
      Write-Host "$JoinAddHp3" -ForegroundColor Yellow}
     5{[Environment]::NewLine
       Set-Clipboard -Value $JoinAdd3com2
      Write-Host "$JoinAdd3com2" -ForegroundColor Yellow}
     6{[Environment]::NewLine
       Set-Clipboard -Value $JoinAdd3com3
      Write-Host "$JoinAdd3com3" -ForegroundColor Yellow}
     7{[Environment]::NewLine
       Set-Clipboard -Value $JoinAddBPM1
      Write-Host "$JoinAddBPM1" -ForegroundColor Yellow}
      8{[Environment]::NewLine
        Set-Clipboard -Value $JoinAddBPM2
       Write-Host "$JoinAddBPM2" -ForegroundColor Yellow}
     
    #Default {Write-Host -ForegroundColor Red "Не правильно выбран режим"}
     Default {[Environment]::NewLine
       Write-Host "$MacTransl" -ForegroundColor Yellow}
}
[Environment]::NewLine
# }
# Pause






<# Копируем в буфер:
  Set-Clipboard -Value $MacTransl2
  Write-Host "Мак-адрес:" -ForegroundColor Magenta
  Write-Host "$MacTransl1" -ForegroundColor Green
  Write-Host "скопирован в буфер обмена!!!" -ForegroundColor Magenta
  write-host "`n"
#>



<#
!!! НЕ МЕНЯТЬ  !!!!
function DHCP-mac (){
    $DHCP_Servers = @{
        $DHCP_Server1 = 't2rs-fps-01.corp.tele2.ru'
        $DHCP_Server2 = 't2rn-fps-01.corp.tele2.ru'
        $DHCP_Server3 = 't2ru-prn-01.corp.tele2.ru'
        $DHCP_Server4 = 't2rp-fps-01.corp.tele2.ru'
        $DHCP_Server5 = 't2rm-fps-01.corp.tele2.ru'
        $DHCP_Server6 = 't2re-fps-01.corp.tele2.ru'
        $DHCP_Server7 = 't2zr-fclr-01.corp.tele2.ru'
        $DHCP_Server8 = 't2zc-fps-02.corp.tele2.ru'
    }
foreach ($CHR in $inCHR)

$DNS_Resolution = resolve-dnsname -name $PC

### DHCP SERVER QUERY ###
$DHCP_Server = 't2rs-fps-01.corp.tele2.ru'
$DHCP_Leases = Get-DhcpServerv4Scope -computername $DHCP_Server | Get-DhcpServerv4Lease -computername $DHCP_Server

### CLIENT INFO from DHCP ###
$Host_Info = $DHCP_Leases | Where-Object IPAddress -eq $DNS_Resolution.IPAddress

### IP ADDRESS as VARIABLE ###
$IPAddress = $Host_Info.IPAddress

### MAC ADDRESS as VARIABLE ###
$MAC_Address = $Host_Info.ClientId

# DHCP-mac $PC
!!! НЕ МЕНЯТЬ   !!!
#>