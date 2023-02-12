
$PC = Read-Host "Имя компьютера или IP-адрес"
$hklm = "2147483650" #HKEY_LOCAL_MACHINE
$key = "SYSTEM\CurrentControlSet\Control\Terminal Server"
$valuename = "FdenyTSConnections"
$value = "00000000"
<##>


$wmi = get-wmiobject -list "StdRegProv" -namespace root\default -computername $PC -credential $credential
$wmi.SetDWORDValue($hklm,$key,$valuename,$value)

#Перезагружаем и пингуем
shutdown /r /m $PC
ping $PC -t
