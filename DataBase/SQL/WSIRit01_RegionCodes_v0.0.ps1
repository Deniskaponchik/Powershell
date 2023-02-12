# Version: 0.0
# STATUS: Используется в запросах
# реализация: с выбором варианта инцидента
# проблемы:
function RegionCodes (
[ValidateSet("AddPCtoDomain", "DelTrashFilesRemote", "Move&RenamePC", "ShowPCinfo")][String]$Operation,
[string]$RegionRUS, [string]$RegionENG, [string]$PCname
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
        $Query = "select RegionENG1 from RegionCodes where PCname1 = '$PCname' OR PCname2 = '$PCname'"
        $sqlcmd.CommandText = $Query
        $result = $sqlcmd.ExecuteReader()
        $Table = [System.Data.DataTable]::new()
        $Table.Load($result)
        $con.Close()
        $Table.Columns.ColumnName | % { $Table.Columns[$_].ColumnName = $_.ToUpper()}
        [Environment]::NewLine
        return ,$Table
    }
    "Read" {
        $Query = "select * from RegionCodes where Pcname1 = '$PCname' OR PCname2 = '$PCname'" 
        #$Query = "$FileSqlTxt"
        <#$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd
        $DataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($DataSet)
        $Con.Close()
        $DataSet.Tables[0] #>
        $sqlcmd.CommandText = $Query
        $result = $sqlcmd.ExecuteReader()
        $Table = [System.Data.DataTable]::new()
        $Table.Load($result)
        $con.Close()
        $Table.Columns.ColumnName | % { $Table.Columns[$_].ColumnName = $_.ToUpper()}
        #if ($NULL -eq $Table){return 'Работа не велась'} else {return ,$Table} #$DataSet.Tables[0]}
        [Environment]::NewLine
        return ,$Table
    }
  }
}
#
#$UserLogin = 'elvira.golubenko'
$Cut = 'WSAB'
#RegionCodes -Operation AddPCtoDomain -PCname $PCname
$b = RegionCodes -Operation AddPCtoDomain -PCname $Cut
$b.REGIONENG1
#if($b -eq 'Abakan'){Write-Host 'OK'} else {'BAD'}
#>