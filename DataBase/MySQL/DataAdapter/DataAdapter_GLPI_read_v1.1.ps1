# Version: 1.1
# реализация: DataAdapter + функция

function GlpiRead (
    #[string]$ConnectionString,
    #[string]$Query,
    #[ValidateSet("Read", "Write")][String]$Operation
    [string]$login
    ){
#$result = $sqlcmd.ExecuteReader()
#$Table = [System.Data.DataTable]::new()
#$Table.Load($result)
#$con.Close()
#$Table.Columns.ColumnName | % { $Table.Columns[$_].ColumnName = $_.ToUpper()}
#return ,$Table

#[string]$FileSQL = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Name)), ([System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Name, "sql" )))    
#$FileSqlTxt = Get-Content $FileSQL -Encoding UTF8 -Raw
$FileSqlTxt = Get-Content 'DataAdapter_GLPI_read_fun_v0.1.sql' -Encoding UTF8 -Raw
$Query = "$FileSqlTxt"

#[void][system.reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.30\Assemblies\v4.5.2\MySql.Data.dll")
[void][system.reflection.Assembly]::LoadFrom("\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\MySQL\DataAdapter\Data.dll")
            
    $Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString='server=10.77.252.153;uid=root;pwd=t2root;database=glpi_db'}
    $Connection.Open()
    $MYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
    $MYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
    $MYSQLDataSet = New-Object System.Data.DataSet
    $MYSQLCommand.Connection=$Connection            

    $MYSQLCommand.CommandText = $Query
    $MYSQLCommand.Parameters.AddWithValue('@login',$login)    
    $MYSQLDataAdapter.SelectCommand = $MYSQLCommand
    $NumberOfDataSets = $MYSQLDataAdapter.Fill($MYSQLDataSet, "data")

    $result = $MYSQLCommand.ExecuteReader()
    $Table = [System.Data.DataTable]::new()
    $Table.Load($result)

    <#$x = 0
    foreach($DataSet in $MYSQLDataSet.tables[0]){
        $x = $x + 1

        write-host "PCname$x : " $DataSet.PCname
        write-host "PCtype$x : " $DataSet.PCtype
        #return $DataSet
        [Environment]::NewLine
    } #>

    $Connection.Close()
return ,$Table #$DataSet
}

[Environment]::NewLine
$login = "denis.tirskikh"
GlpiRead -login $login
$GLPIread = GlpiRead -login $login
$GLPIread.PCname[1]

