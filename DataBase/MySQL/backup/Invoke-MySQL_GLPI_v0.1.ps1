

$attempt = 2
do {
    $attempt = 
    
} while (
    $attempt = 0)
)

try {

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

}
catch {
    Install-Module MySQLCmdlets
    $attempt = 1
}







