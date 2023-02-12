# Version: 1.3
# STATUS: TEST
# реализация: DataAdapter + функция
function GlpiRead (
    #[string]$ConnectionString,
    #[string]$Query,
    #[ValidateSet("Read", "Write")][String]$Operation
     [ValidateSet("login", "PC")][String]$SearchTarget,
     [string]$Nomination
    ){
#[string]$FileSQL = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Name)), ([System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Name, "sql" )))    
#$FileSqlTxt = Get-Content $FileSQL -Encoding UTF8 -Raw
switch ($SearchTarget) {
"login" {$FileSqlTxt = Get-Content '\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\MySQL\DataAdapter\DataAdapter_GLPI_read_v1.2_login.sql' -Encoding UTF8 -Raw}
"pc" {$FileSqlTxt = Get-Content '\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\MySQL\DataAdapter\DataAdapter_GLPI_read_v1.2_pc.sql' -Encoding UTF8 -Raw}
}
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
    $MYSQLCommand.Parameters.AddWithValue('@Nomination',$Nomination)    
    $MYSQLDataAdapter.SelectCommand = $MYSQLCommand
    $NumberOfDataSets = $MYSQLDataAdapter.Fill($MYSQLDataSet, "data")

    #$result = $MYSQLCommand.ExecuteReader()
    #$Table = [System.Data.DataTable]::new()
    #$Table.Load($result)

    <#$x = 0
    foreach($DataSet in $MYSQLDataSet.tables[0]){
        $x = $x + 1
        write-host "PCname$x : " $DataSet.PCname
        write-host "PCtype$x : " $DataSet.PCtype
        #return $DataSet
        [Environment]::NewLine  } #>
        
    $Connection.Close()
    #$Table.Columns.ColumnName | % { $Table.Columns[$_].ColumnName = $_.ToUpper()}
#return ,$Table
 return $DataSet.Tables[1]
}
#
[Environment]::NewLine
$Nomination = "denis.tirskikh"
            #GlpiRead -Nomination $login -SearchTarget PC
 $GLPIread = GlpiRead -Nomination $login -SearchTarget PC
 #$GLPIread.PCname[0]
 $GLPIread
 [Environment]::NewLine
#>