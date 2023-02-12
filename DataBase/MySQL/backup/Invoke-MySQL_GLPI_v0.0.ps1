



try {
    Connect-MySQL
}
catch {
    <# Install-Module не работает
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module MySQLCmdlets -Force
    #>
     

    #Write-Host "Запрос прав локального администратора компьютера (5 попыток ввода)"
    #$AdminCred = Get-Credential
     $proxy = "https://t2rs-fgproxy.corp.tele2.ru"
     
     $MySqlCmdletsVersion = "21.0.7930.1"
     $MySQLCmdletNupg = "mysqlcmdlets.$MySqlCmdletsVersion.nupkg"

     $WebPathMySQlModule = "https://www.powershellgallery.com/packages/MySQLCmdlets/$MySqlCmdletsVersion/"
     $FpsPathMySQLmodule = "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\MySQL\$MySQLCmdletNupg"     
     $LocPathPsModules = "$env:ProgramFiles\WindowsPowerShell\Modules\"
     $LocPathMySQLmodule = "$env:ProgramFiles\WindowsPowerShell\Modules\MySQLCmdlets\"
    
     New-Item -Path $LocPathMySQLmodule -ItemType Directory

    #Invoke-WebRequest $myDownloadUrl -OutFile c:\file.ext
    #Invoke-WebRequest $WebPathMySQlModule -OutFile "$LocPathMySQLmodule\$MySqlCmdletsVersion.zip" -Proxy $proxy
    #Invoke-WebRequest : Невозможно соединиться с удаленным сервером
    #Move-Item -Path .\sqlserver.21.1.18230.nupkg -Destination .\sqlserver.21.1.18230.zip
    #Move-Item -Path .\$MySQLCmdletNupg -Destination $LocPathMySQLmodule\$MySqlCmdletsVersion.zip
     Move-Item -Path $FpsPathMySQLmodule -Destination $LocPathMySQLmodule\$MySqlCmdletsVersion.zip
    
    #Expand-Archive -Path .\sqlserver.21.1.18230.zip
     Expand-Archive -Path $LocPathMySQLmodule\$MySqlCmdletsVersion.zip -DestinationPath $LocPathMySQLmodule\$MySqlCmdletsVersion
     Import-Module MySQLCmdlets
     Pause
}


[Environment]::NewLine
$user = "root"
$Password = "t2root"
$Server = "10.77.252.153"
$Database = "glpi_db"

#$mysql = Connect-MySQL  -User "$User" -Password "$Password" -Database "$Database" -Server "$Server" -Port "$Port"
 $mysql = Connect-MySQL  -User "$User" -Password "$Password" -Database "$Database" -Server "$Server" -Port "$Port"

#$shipcountry = "USA"
 $contact

#$orders = Select-MySQL -Connection $mysql -Table "Orders" -Where "ShipCountry = `'$ShipCountry`'"
 $orders = Select-MySQL -Connection $mysql -Table "glpi_computers" -Where "contact = `'$contact`'"
 $orders


#$orders = Invoke-MySQL -Connection $mysql -Query 'SELECT * FROM Orders WHERE ShipCountry = @ShipCountry' -Params @{'@ShipCountry'='USA'}
 $orders = Invoke-MySQL -Connection $mysql -Query 'SELECT * FROM Orders WHERE contact = @contact' -Params @{'@contact'='denis.tirskikh'}


 Update-MySQL -Connection $MySQL -Columns @('ShipName','Freight') -Values @('MyShipName', 'MyFreight') -Table Orders -Id "MyId"


