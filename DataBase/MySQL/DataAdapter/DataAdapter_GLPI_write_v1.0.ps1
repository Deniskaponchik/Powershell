

# READ from DB

$login = "denis.tirskikh"

#Set-ExecutionPolicy -Scope CurrentUser
#Set-ExecutionPolicy RemoteSigned

[Environment]::NewLine
#Add-Type –Path ‘C:\Program Files (x86)\MySQL\MySQL Connector Net 6.9.8\Assemblies\v4.5\MySql.Data.dll'
Add-Type –Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\MySQL\MySql.Data.dll"

$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{
    #ConnectionString='server=10.10.1.13;uid=posh;pwd=P@ssw0rd;database=aduser'}
     ConnectionString='server=10.77.252.153;uid=root;pwd=t2root;database=glpi_db'}
$Connection.Open()
$MYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
$MYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
$MYSQLDataSet = New-Object System.Data.DataSet
$MYSQLCommand.Connection=$Connection

#$MYSQLCommand.CommandText='SELECT * from  users'
#$MYSQLCommand.CommandText="SELECT * FROM glpi_db.glpi_computers where contact = 'denis.tirskikh'"
 $MYSQLCommand.CommandText="SELECT * FROM glpi_db.glpi_computers where contact = '$login'"

$MYSQLDataAdapter.SelectCommand=$MYSQLCommand
$NumberOfDataSets=$MYSQLDataAdapter.Fill($MYSQLDataSet, "data")
foreach($DataSet in $MYSQLDataSet.tables[0]){
    #write-host "User:" $DataSet.name  "Email:" $DataSet.email
     write-host "PC:" $DataSet.name  "Login:" $DataSet.contact
}
$Connection.Close()
[Environment]::NewLine






# WRITE to DB
Set-ExecutionPolicy RemoteSigned

#подключаем библиотеку MySql.Data.dll
#Add-Type –Path ‘C:\Program Files (x86)\MySQL\MySQL Connector Net 6.9.8\Assemblies\v4.5\MySql.Data.dll'
 Add-Type –Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\MySQL\MySql.Data.dll"

# строка подключения к БД
$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{
    ConnectionString='server=10.10.1.13;uid=posh;pwd=P@ssw0rd;database=aduser'}
$Connection.Open()
$sql = New-Object MySql.Data.MySqlClient.MySqlCommand
$sql.Connection = $Connection

#формируем список пользователей с именами и email адресами
Import-Module activedirectory
$UserList=Get-ADUser -SearchBase ‘OU=Users,OU=London,DC=contoso,DC=ru’ -filter * -properties name, EmailAddress
ForEach($user in $UserList)
{
    $uname=$user.Name;
    $uemail=$user.EmailAddress;
    #записываем информацию о каждом пользователе в табдицу БД
    $sql.CommandText = "INSERT INTO users (Name,Email) VALUES ('$uname','$uemail')"
    $sql.ExecuteNonQuery()
}
$Reader.Close()
$Connection.Close()




