write-host "`n"
$MAC_Address = $Null

if (($m = Read-Host "Имя компьютера или IP-адрес") -ne "") {$PC = $m}

if (Test-Connection -ComputerName $PC -Quiet) {
    # Проще всего получить мак с доступного в сПК. Пробуем, проверяем:
    # $FullNetConf = Get-WmiObject -ComputerName $PC -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=True -ErrorVariable ErrNotPc -ErrorAction SilentlyContinue  |  Select-Object -Property * | Select-Object PSComputerName, @{Name="IPAddress";Expression={$_.IPAddress.get(0)}}, MACAddress, Description
      $FullNetConf = Get-WmiObject -ComputerName $PC -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=True -ErrorVariable ErrNotPc -ErrorAction SilentlyContinue


        if ($ErrNotPc -like '*Сервер RPC недоступен*') {
            'Устройство - не компьютер ИЛИ недоступно. Будет предпринята попытка получения мака с DHCP-серверов.'
        }
        elseif ($ErrNotPc) {
            'Не описанная ранее ошибка'
        }
        else {
            $FullNetConf
            [Environment]::NewLine
            $MAC_Address = $FullNetConf.MACAddress
            # $MAC_Address = Get-WmiObject -ComputerName $PC -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=True  |  Select-Object -Property * | Select-Object MACAddress
        }
}

if (!$MAC_Address) {

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
    $DHCP_Servers = 't2rs-fps-01.corp.tele2.ru', 't2re-fps-01.corp.tele2.ru', 't2pp-fps-01.corp.tele2.ru', 't2md-fps-01.corp.tele2.ru', 't2bb-fps-01.corp.tele2.ru', 't2rn-fps-01.corp.tele2.ru', 't2ru-dhcp-01.corp.tele2.ru', 't2rp-fps-01.corp.tele2.ru', 't2rm-fps-01.corp.tele2.ru' #, 't2zr-fclr-01.corp.tele2.ru', 't2zc-fps-02.corp.tele2.ru'



    # $PC = 'wsir-broner'
    # $PC = '10.88.179.33'
    # if (($m = Read-Host "Имя компьютера или IP-адрес") -ne "") {$PC = $m}
    if ($PC -notlike '1*') { 
        
        #
        # Если не указан Ip в явном виде, то получаем его из DNS:
          $DNS_Resolution = $Null
          $DNS_Resolution = resolve-dnsname -name $PC
        # if ($DNS_Resolution -eq $Null) {Exit} # Останавливать скрипт, если нет записи на DNS
          $ip = $DNS_Resolution.IPAddress
        #>        
        



    }
    else {
        $ip = $PC
    }
    


    $MAC_Address = $Null
    foreach ($DHCP_Server in $DHCP_Servers) {
        if (!$MAC_Address) {
            # $IP = '10.88.179.7'
            # $DHCP_Server = 't2rs-fps-01.corp.tele2.ru'
            # $DHCP_Server = 't2md-fps-01.corp.tele2.ru'
            $DHCP_Server
            $DHCP_Leases = Get-DhcpServerv4Scope -computername $DHCP_Server | Get-DhcpServerv4Lease -computername $DHCP_Server
            $Host_Info = $DHCP_Leases | Where-Object IPAddress -eq $IP
            if ($Host_Info -notlike '') {
                $IPAddress = $Host_Info.IPAddress
                $MAC_Address = $Host_Info.ClientId
            }
        }
    }
}

# Выводим Mac-адрес, если удалось его выкдить:
  if ($MAC_Address -ne $Null) {
      Write-Host "$MAC_Address" -ForegroundColor Green
      [Environment]::NewLine
    }
  else {
    Write-Host "Mac-адрес определить не удалось" -ForegroundColor Red
    Exit
  }


# Смена регитсра букв:
   
    #Задаём функцию транслитерации:
    function Translit ([string]$inString) {
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
      $MacTransl = Translit $MAC_Address
    # $MacTransl
    
    # $mac4 = $mac2 -replace "@{macaddress ", ""
    # $MacTransl2=(($MacTransl1.replace("@{macaddress ","")).replace("}",""))   # Обрезание концов
    # $MacTransl2
   

#
[array]$Split_Add = $MacTransl -split ":"

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


Write-Host "7. Huawei" -ForegroundColor Cyan
[string]$JoinAddHuawei2 = 'display mac-address ' + $Split_Add[0] + $Split_Add[1] + '-' + $Split_Add[2] + $Split_Add[3] + '-' + $Split_Add[4] + $Split_Add[5]


[Environment]::NewLine
# "Укажи вариант сохранения мак-адреса в буфер обмена."
$Choice = Read-Host "Укажи вариант сохранения мак-адреса в буфер обмена"

Switch ($Choice) {
     0{Exit}
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
      Write-Host "$JoinAddHp30" -ForegroundColor Yellow}
     5{[Environment]::NewLine
       Set-Clipboard -Value $JoinAdd3com2
      Write-Host "$JoinAdd3com2" -ForegroundColor Yellow}
     6{[Environment]::NewLine
       Set-Clipboard -Value $JoinAdd3com3
      Write-Host "$JoinAdd3com2" -ForegroundColor Yellow}
     7{[Environment]::NewLine
       Set-Clipboard -Value $JoinAddHuawei2
      Write-Host "$JoinAddHuawei2" -ForegroundColor Yellow}
     
    #Default {Write-Host -ForegroundColor Red "Не правильно выбран режим"}
     Default {[Environment]::NewLine
       Write-Host "$MacTransl" -ForegroundColor Yellow}
}
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