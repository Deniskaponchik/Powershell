
# https://techexpert.tips/powershell/powershell-query-mysql-server/
# READ from DB

#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')
#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('UTF-8')
#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('windows-1251')

#$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

$login = "denis.tirskikh"

#Set-ExecutionPolicy -Scope CurrentUser
#Set-ExecutionPolicy RemoteSigned

[Environment]::NewLine
#Add-Type –Path ‘C:\Program Files (x86)\MySQL\MySQL Connector Net 6.9.8\Assemblies\v4.5\MySql.Data.dll'
#Add-Type –Path 'C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.30\Assemblies\v4.5.2\MySql.Data.dll'
#Add-Type –Path "C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.30\Assemblies\v4.8\MySql.Data.dll"
#Add-Type –Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\MySQL\DataAdapter\Data.dll"

#[void][system.reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.25\Assemblies\v4.5.2\MySql.Data.dll")
#[void][system.reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.30\Assemblies\v4.5.2\MySql.Data.dll")
 [void][system.reflection.Assembly]::LoadFrom("\\t2ru\folders\IT-Outsource\Scripts\PowerShell\MySQL\DataAdapter\Data.dll")

$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{
    #ConnectionString='server=10.10.1.13;uid=posh;pwd=P@ssw0rd;database=aduser'}
     ConnectionString='server=10.77.252.153;uid=root;pwd=t2root;database=glpi_db'}
$Connection.Open()
$MYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
$MYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
$MYSQLDataSet = New-Object System.Data.DataSet
$MYSQLCommand.Connection=$Connection

#$MYSQLCommand.CommandText="SELECT * FROM glpi_computers LIMIT 10"
#$MYSQLCommand.CommandText="SELECT * FROM glpi_computers where contact = 'denis.tirskikh'"
 $MYSQLCommand.CommandText="SELECT * FROM glpi_computers where contact = '$login'"

$MYSQLDataAdapter.SelectCommand=$MYSQLCommand
$NumberOfDataSets=$MYSQLDataAdapter.Fill($MYSQLDataSet, "data")
foreach($DataSet in $MYSQLDataSet.tables[0]){
    #write-host "User:" $DataSet.name  "Email:" $DataSet.email
     write-host "PC:" $DataSet.name  "Login:" $DataSet.contact
}
$Connection.Close()
[Environment]::NewLine




