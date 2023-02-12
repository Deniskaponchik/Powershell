# Version: 0.0
# STATUS: TEST
# реализация: 
function DelTrash (
[ValidateSet("Read", "Write")][String]$Operation,
[string]$SRnumber, [string]$SRlink, [string]$Pcname, [string]$ip, [string]$UserLogin, [string]$UserFIO, [string]$AdminLogin, [string]$AdminFIO, [string]$Comment, [string]$IncidentType
){
$dataSource = "WSIR-IT-01"       # t2ru-bpmdb-read\bpmonline t2ru-tr-tst-02
$database = "ITsupport"
$auth = "Integrated Security=SSPI;"
#[DateTime]$EndDateTime = Get-Date               # Get-Date      "2021-07-27"
$connectionString = "Data Source=$DataSource; Initial Catalog=$database; $auth"
#$connectionString = "Data Source=t2ru-tr-tst-02; Initial Catalog=BPMonline7_8888; Integrated Security=SSPI"
$con = new-object "System.data.sqlclient.SQLconnection"
$con.ConnectionString =$ConnectionString
$con.open()
$sqlcmd = new-object "System.data.sqlclient.sqlcommand"
$sqlcmd.connection = $con
$sqlcmd.CommandTimeout = 10000000
switch ($Operation) {
    "Write" {
        $FileSqlTxt = Get-Content '\\t2ru\folders\IT-Outsource\Scripts\PowerShell\SQL\WsirIt01_DelTrash_v0.0_Write.sql' -Encoding UTF8 -Raw
        $Query = "$FileSqlTxt"
$Query = @"
$FileSqlTxt
"@
        $sqlcmd.CommandText = $Query
        $sqlCmd.Parameters.Add('@StartDate',$DateForSqlVariable)
        $result = $sqlcmd.ExecuteReader()
        $Table = [System.Data.DataTable]::new()
        $Table.Load($result)
        $con.Close()
    }
    "Read" {
        $FileSqlTxt = Get-Content '\\t2ru\folders\IT-Outsource\Scripts\PowerShell\SQL\WsirIt01_DelTrash_v0.0_Read.sql' -Encoding UTF8 -Raw

        $Query = "$FileSqlTxt"
$Query = @"
$FileSqlTxt
"@
        $sqlcmd.CommandText = $Query
        $sqlCmd.Parameters.Add('@StartDate',$DateForSqlVariable)
        $result = $sqlcmd.ExecuteReader()
        $Table = [System.Data.DataTable]::new()
        $Table.Load($result)
        $con.Close()
        $Table.Columns.ColumnName | % { $Table.Columns[$_].ColumnName = $_.ToUpper()}
        $Table | Export-Csv -Path "$CsvPath\SR_BPM7_$DateForCsvName.csv" -Encoding UTF8 -NoTypeInformation
        # | Export-Csv -Path "$PathScript\$NameScript\SR_BPM7_$startDateFormat.csv" -Encoding UTF8 -Delimiter "^" -NoTypeInformation
        [Environment]::NewLine
    }
  }
}
$SRlink = 'https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/cc2559dc-a0c7-41b6-a2bc-021cd0bc27b3'
$AdminLogin = $env:USERNAME
DelTrash -Operation Write -SRlink $SRlink -AdminLogin $AdminLogin