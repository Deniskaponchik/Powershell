$Attempts = '10'   ### NUMBER of TIMES TO SEND MAGIC PACKET ###
$Sleep = '3'   ### PAUSE BETWEEN ATTEMPTS ###
$WOL_Port = '9'   ### WAKE ON LAN PORT NUMBER ###
### DO NOT EDIT BELOW THIS POINT ###
### VARIABLES to EDIT ###
#$DHCP_Server = 't2rs-fps-01.corp.tele2.ru'
$DHCP_Server = 't2rn-fps-01.corp.tele2.ru'
#$DHCP_Server = 't2ru-prn-01.corp.tele2.ru'
#$DHCP_Server = 't2rr-fps-01.corp.tele2.ru'
#$DHCP_Server = 

### PROMPT USER FOR HOST NAME ###
if(!$args[0]){
    $Host_Name = Read-Host -prompt "Host Name"}
else{$Host_Name = $args[0];}
Write-Host "Try to send wol to hostname $Host_name"

### RESOLVE DNS NAME ###
$DNS_Resolution = resolve-dnsname -name $Host_Name
### DHCP SERVER QUERY ###
$DHCP_Leases = Get-DhcpServerv4Scope -computername $DHCP_Server | Get-DhcpServerv4Lease -computername $DHCP_Server
### CLIENT INFO from DHCP ###
$Host_Info = $DHCP_Leases | Where-Object IPAddress -eq $DNS_Resolution.IPAddress
### IP ADDRESS as VARIABLE ###
$IPAddress = $Host_Info.IPAddress
### MAC ADDRESS as VARIABLE ###
$MAC_Address = $Host_Info.ClientId

### WOL FUNCTION ###
function Send-WOL
{
[CmdletBinding()]
param(
[Parameter(Mandatory=$True,Position=1)]
[string]$mac,
[string]$ip="255.255.255.255", 
[int]$port=9
)
$broadcast = [Net.IPAddress]::Parse($ip)
 
$mac=(($mac.replace(":","")).replace("-","")).replace(".","")
$target=0,2,4,6,8,10 | % {[convert]::ToByte($mac.substring($_,2),16)}
$packet = (,[byte]255 * 6) + ($target * 16)
 
$UDPclient = new-Object System.Net.Sockets.UdpClient
$UDPclient.Connect($broadcast,$port)
[void]$UDPclient.Send($packet, 102) 
}

$Ping_Test = Test-Connection -ComputerName $IPAddress -Quiet
### START of MAGIC PACKET ###
$Attempt = 1
while ($Ping_Test -eq $false -and $Attempt -le $Attempts) {
        Write-Host "Sending Magic Packet...Attempt - " $Attempt -ForegroundColor Yellow
        Send-WOL -mac $MAC_Address -ip $IPAddress -port $WOL_Port
        Start-Sleep $Sleep
        $Ping_Test = Test-Connection -ComputerName $IPAddress -Quiet
        $Attempt++}      
if ($Ping_Test -eq $true){ 
    Write-Host ""
    Write-Host "###############" -ForegroundColor Green
    Write-Host "Host is Online!" -ForegroundColor Green
    Write-Host "###############" -ForegroundColor Green}
else {
    Write-Host ""
    Write-Host "########################################" -ForegroundColor Red
    Write-Host "Host is still offline. Please try again." -ForegroundColor Red
    Write-Host "########################################" -ForegroundColor Red
}


