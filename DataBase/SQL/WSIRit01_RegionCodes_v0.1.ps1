# Version: 0.1
# STATUS: Используется в запросах
# реализация: с выбором варианта скрипта, где используется
# проблемы:
function RegionCodes (
[ValidateSet("AddPCtoDomain", "DelTrashFilesRemote", "Move&RenamePC", "ShowPCinfo")][String]$Operation,
[string]$CityRUS, [string]$CityENG, [string]$PCname
){
$dataSource = "WSIR-IT-01"       # t2ru-bpmdb-read\bpmonline t2ru-tr-tst-02
$database = "ITsupport"
$auth = "Integrated Security=SSPI;"
$connectionString = "Data Source=$DataSource; Initial Catalog=$database; $auth"
#$connectionString = "Data Source=t2ru-tr-tst-02; Initial Catalog=BPMonline7_8888; Integrated Security=SSPI"
# con=SqlConnection, Query=sql
$con = new-object "System.data.sqlclient.SQLconnection"
$con.ConnectionString = $ConnectionString
$con.open()
$sqlcmd = new-object "System.data.sqlclient.sqlcommand"
$sqlcmd.connection = $con
$sqlcmd.CommandTimeout = 10000000
switch ($Operation) {
    "AddPCtoDomain" {
        $Query = "select CityENG1 from RegionCodes where PCname1 = '$PCname' OR PCname2 = '$PCname'"
    }
    "DelTrashFilesRemote" {
        $Query = "select BPMgroup21, Comment1 from RegionCodes where Pcname1 = '$PCname' OR PCname2 = '$PCname'" 
    }
    "ShowPCinfo" {
        $Query = "select BPMgroup21 from RegionCodes where Pcname1 = '$PCname' OR PCname2 = '$PCname'" 
    }
    "Move&RenamePC" {
        #ПОКА ЧТО В СТАДИИ "НА ПОДУМАТЬ"
        $Query = "select Subnet1, Subnet2 from RegionCodes where Pcname1 = '$PCname' OR PCname2 = '$PCname'" 
    }
}
$sqlcmd.CommandText = $Query
$result = $sqlcmd.ExecuteReader()
$Table = [System.Data.DataTable]::new()
$Table.Load($result)
$con.Close()
$Table.Columns.ColumnName | % { $Table.Columns[$_].ColumnName = $_.ToUpper()}
return ,$Table
}
<#
$Cut = 'WSUB'
#RegionCodes -Operation AddPCtoDomain -PCname $Cut
$RegionCodes = RegionCodes -Operation AddPCtoDomain -PCname $Cut
#$RegionCodes
$City = $RegionCodes.CityENG1
if ($Null -eq $City){'НОЛЬ'}
else {$City}
#$RegionCodes.Comment1
#$b = $RegionCodes.CityENG1
#$b
#>